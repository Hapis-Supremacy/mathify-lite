package com.mathify.dao;

import com.mathify.db.DBUtil;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;

/**
 * Data access for the {@code subscriptions} table, which holds a single row per
 * student while they are (or were last) premium. Payments are tracked via the
 * {@code midtrans_order_id} / {@code payment_status} columns added in
 * {@code database/migration_add_payment_tracking.sql}.
 */
public class SubscriptionDAO {

    /** Snapshot of a student's subscription row, or null when none exists. */
    public record SubscriptionInfo(String plan, LocalDate expiry, boolean canceled,
                                   String orderId, String paymentStatus) {
        public boolean isActive() {
            return !canceled && expiry != null && !expiry.isBefore(LocalDate.now());
        }
    }

    public SubscriptionInfo getByStudentId(String studentId) throws SQLException {
        String sql = "SELECT subscription_plan, subscription_expiry, is_canceled, "
                   + "midtrans_order_id, payment_status "
                   + "FROM subscriptions WHERE student_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Date expiry = rs.getDate("subscription_expiry");
                    return new SubscriptionInfo(
                            rs.getString("subscription_plan"),
                            expiry == null ? null : expiry.toLocalDate(),
                            rs.getBoolean("is_canceled"),
                            rs.getString("midtrans_order_id"),
                            rs.getString("payment_status"));
                }
            }
        }
        return null;
    }

    /**
     * Grants (or renews) premium after a verified payment. If the student
     * already has an active subscription the new period is stacked on top of the
     * later of today / current expiry; otherwise it runs for {@code days} from
     * today. Idempotent per call but callers should verify payment first.
     *
     * @return the new expiry date
     */
    public LocalDate activatePremium(String studentId, String plan, int days,
                                     String orderId, String paymentStatus) throws SQLException {
        try (Connection conn = DBUtil.getConnection()) {
            LocalDate base = LocalDate.now();
            SubscriptionInfo existing = getByStudentIdOn(conn, studentId);
            if (existing != null && existing.isActive() && existing.expiry().isAfter(base)) {
                base = existing.expiry();
            }
            LocalDate newExpiry = base.plusDays(days);

            String sql =
                "INSERT INTO subscriptions "
              + "(student_id, subscription_plan, subscription_expiry, is_canceled, "
              + " midtrans_order_id, payment_status) "
              + "VALUES (?, ?, ?, FALSE, ?, ?) "
              + "ON DUPLICATE KEY UPDATE "
              + " subscription_plan = VALUES(subscription_plan), "
              + " subscription_expiry = VALUES(subscription_expiry), "
              + " is_canceled = FALSE, "
              + " midtrans_order_id = VALUES(midtrans_order_id), "
              + " payment_status = VALUES(payment_status)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, studentId);
                ps.setString(2, plan);
                ps.setDate(3, Date.valueOf(newExpiry));
                ps.setString(4, orderId);
                ps.setString(5, paymentStatus);
                ps.executeUpdate();
            }
            return newExpiry;
        }
    }

    /**
     * Cancels a student's premium (admin override). Keeps the row for history but
     * flags it canceled so {@link SubscriptionInfo#isActive()} returns false.
     * No-op if the student has no subscription row.
     */
    public void revokePremium(String studentId) throws SQLException {
        String sql = "UPDATE subscriptions SET is_canceled = TRUE, payment_status = 'canceled' "
                   + "WHERE student_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ps.executeUpdate();
        }
    }

    private SubscriptionInfo getByStudentIdOn(Connection conn, String studentId) throws SQLException {
        String sql = "SELECT subscription_plan, subscription_expiry, is_canceled, "
                   + "midtrans_order_id, payment_status "
                   + "FROM subscriptions WHERE student_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Date expiry = rs.getDate("subscription_expiry");
                    return new SubscriptionInfo(
                            rs.getString("subscription_plan"),
                            expiry == null ? null : expiry.toLocalDate(),
                            rs.getBoolean("is_canceled"),
                            rs.getString("midtrans_order_id"),
                            rs.getString("payment_status"));
                }
            }
        }
        return null;
    }
}

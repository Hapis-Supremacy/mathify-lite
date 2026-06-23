package com.mathify.dao;

import com.mathify.db.DBUtil;
import com.mathify.model.Admin;
import com.mathify.model.PremiumStudent;
import com.mathify.model.Student;
import com.mathify.model.User;

import java.sql.*;
import java.util.UUID;

public class UserDAO {
    private static final int MAX_ENERGY = 5;

    /**
     * Looks up a student by email.
     * Returns null if the email doesn't belong to a student account.
     */
    public Student findStudentByEmail(String email) throws SQLException {
        refreshAllDueEnergy();
        String sql =
            "SELECT u.user_id, u.name, u.email, u.password_hash, s.energy " +
            "FROM users u JOIN students s ON s.student_id = u.user_id " +
            "WHERE u.email = ? AND u.is_disabled = FALSE";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Student student = new Student(rs.getString("user_id"));
                    student.setUserId(rs.getString("user_id"));
                    student.setName(rs.getString("name"));
                    student.setEmail(rs.getString("email"));
                    student.setPasswordHash(rs.getString("password_hash"));
                    student.setEnergy(rs.getInt("energy"));
                    hydrateSubscription(student);
                    hydrateEnergyRenewal(student);
                    return student;
                }
            }
        }
        return null;
    }

    /**
     * Looks up a student by ID.
     */
    public Student getStudentById(String studentId) throws SQLException {
        refreshEnergyIfDue(studentId);
        String sql =
            "SELECT u.user_id, u.name, u.email, u.password_hash, s.energy " +
            "FROM users u JOIN students s ON s.student_id = u.user_id " +
            "WHERE u.user_id = ? AND u.is_disabled = FALSE";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Student student = new Student(rs.getString("user_id"));
                    student.setUserId(rs.getString("user_id"));
                    student.setName(rs.getString("name"));
                    student.setEmail(rs.getString("email"));
                    student.setPasswordHash(rs.getString("password_hash"));
                    student.setEnergy(rs.getInt("energy"));
                    hydrateSubscription(student);
                    hydrateEnergyRenewal(student);
                    return student;
                }
            }
        }
        return null;
    }

    /**
     * Looks up an admin by email.
     */
    public Admin findAdminByEmail(String email) throws SQLException {
        String sql =
            "SELECT u.user_id, u.name, u.email, u.password_hash " +
            "FROM users u JOIN admins a ON a.admin_id = u.user_id " +
            "WHERE u.email = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Admin admin = new Admin(rs.getString("user_id"));
                    admin.setUserId(rs.getString("user_id"));
                    admin.setName(rs.getString("name"));
                    admin.setEmail(rs.getString("email"));
                    admin.setPasswordHash(rs.getString("password_hash"));
                    return admin;
                }
            }
        }
        return null;
    }

    /**
     * Looks up an admin by ID.
     */
    public Admin getAdminById(String adminId) throws SQLException {
        String sql =
            "SELECT u.user_id, u.name, u.email, u.password_hash " +
            "FROM users u JOIN admins a ON a.admin_id = u.user_id " +
            "WHERE u.user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, adminId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Admin admin = new Admin(rs.getString("user_id"));
                    admin.setUserId(rs.getString("user_id"));
                    admin.setName(rs.getString("name"));
                    admin.setEmail(rs.getString("email"));
                    admin.setPasswordHash(rs.getString("password_hash"));
                    return admin;
                }
            }
        }
        return null;
    }

    /** Returns true if the email is already registered in any account type. */
    public boolean emailExists(String email) throws SQLException {
        String sql = "SELECT 1 FROM users WHERE email = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * Inserts a new student account (users + students + user_progress rows)
     * inside a single transaction. The password must already be hashed.
     */
    public void createStudent(String name, String email, String passwordHash) throws SQLException {
        String userId = UUID.randomUUID().toString();

        String sqlUser     = "INSERT INTO users (user_id, name, email, password_hash) VALUES (?, ?, ?, ?)";
        String sqlStudent  = "INSERT INTO students (student_id, energy) VALUES (?, ?)";
        String sqlProgress = "INSERT INTO user_progress (student_id) VALUES (?)";

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(sqlUser)) {
                    ps.setString(1, userId);
                    ps.setString(2, name);
                    ps.setString(3, email);
                    ps.setString(4, passwordHash);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(sqlStudent)) {
                    ps.setString(1, userId);
                    ps.setInt(2, MAX_ENERGY);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(sqlProgress)) {
                    ps.setString(1, userId);
                    ps.executeUpdate();
                }
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }
    }

    /**
     * Retrieves a summarized list of all students for the admin dashboard.
     */
    public java.util.List<com.mathify.model.AdminStudentDTO> getAllStudentSummaries() throws SQLException {
        java.util.List<com.mathify.model.AdminStudentDTO> summaries = new java.util.ArrayList<>();
        String sql =
            "SELECT u.user_id, u.name, u.email, u.is_disabled, " +
            "       COALESCE(up.total_xp, 0) as total_xp, " +
            "       sub.subscription_plan, sub.subscription_expiry, sub.is_canceled " +
            "FROM users u " +
            "JOIN students s ON s.student_id = u.user_id " +
            "LEFT JOIN user_progress up ON up.student_id = u.user_id " +
            "LEFT JOIN subscriptions sub ON sub.student_id = u.user_id " +
            "ORDER BY u.name ASC";
            
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
             
             while (rs.next()) {
                 com.mathify.model.AdminStudentDTO dto = new com.mathify.model.AdminStudentDTO();
                 dto.setStudentId(rs.getString("user_id"));
                 dto.setName(rs.getString("name"));
                 dto.setEmail(rs.getString("email"));
                 dto.setTotalXp(rs.getInt("total_xp"));
                 
                 String plan = "Free";
                 String subPlan = rs.getString("subscription_plan");
                 if (subPlan != null && !rs.getBoolean("is_canceled")) {
                     java.sql.Date expiry = rs.getDate("subscription_expiry");
                     if (expiry != null && expiry.after(new java.util.Date())) {
                         plan = "Premium";
                     }
                 }
                 dto.setPlan(plan);
                 
                 boolean isDisabled = rs.getBoolean("is_disabled");
                 dto.setStatus(isDisabled ? "Disabled" : "Active");
                 
                 summaries.add(dto);
             }
        }
        return summaries;
    }

    public void setStudentDisabled(String studentId, boolean disabled) throws SQLException {
        String sql = "UPDATE users SET is_disabled = ? WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, disabled);
            ps.setString(2, studentId);
            ps.executeUpdate();
        }
    }

    public void deleteUser(String userId) throws SQLException {
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM subscriptions WHERE student_id = ?")) {
                    ps.setString(1, userId); ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM user_progress WHERE student_id = ?")) {
                    ps.setString(1, userId); ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM students WHERE student_id = ?")) {
                    ps.setString(1, userId); ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM users WHERE user_id = ?")) {
                    ps.setString(1, userId); ps.executeUpdate();
                }
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }
    }

    public void decreaseEnergy(String studentId, int amount) throws SQLException {
        refreshEnergyIfDue(studentId);
        if (isStudentPremiumActive(studentId)) {
            return;
        }
        String sql = "UPDATE students SET energy = GREATEST(0, energy - ?) WHERE student_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, amount);
            ps.setString(2, studentId);
            ps.executeUpdate();
        }
    }

    private boolean isStudentPremiumActive(String studentId) throws SQLException {
        String sql = "SELECT subscription_plan, subscription_expiry, is_canceled FROM subscriptions WHERE student_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    PremiumStudent premium = new PremiumStudent(
                            rs.getString("subscription_plan"),
                            rs.getDate("subscription_expiry")
                    );
                    if (rs.getBoolean("is_canceled")) {
                        premium.cancelSubscription();
                    }
                    return premium.isActive();
                }
            }
        }
        return false;
    }

    private void hydrateSubscription(Student student) throws SQLException {
        String sql = "SELECT subscription_plan, subscription_expiry, is_canceled FROM subscriptions WHERE student_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, student.getStudentId());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    PremiumStudent premium = new PremiumStudent(
                            rs.getString("subscription_plan"),
                            rs.getDate("subscription_expiry")
                    );
                    if (rs.getBoolean("is_canceled")) {
                        premium.cancelSubscription();
                    }
                    student.setSubscription(premium);
                }
            }
        }
    }

    private void refreshAllDueEnergy() throws SQLException {
        String sql = "UPDATE students s " +
                     "LEFT JOIN (SELECT student_id, MAX(completed_at) AS last_quiz_at FROM quiz_attempts GROUP BY student_id) q " +
                     "ON q.student_id = s.student_id " +
                     "SET s.energy = ? " +
                     "WHERE s.energy < ? " +
                     "AND (q.last_quiz_at IS NULL OR q.last_quiz_at <= DATE_SUB(NOW(), INTERVAL 4 HOUR))";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, MAX_ENERGY);
            ps.setInt(2, MAX_ENERGY);
            ps.executeUpdate();
        }
    }

    private void refreshEnergyIfDue(String studentId) throws SQLException {
        String sql = "UPDATE students s " +
                     "LEFT JOIN (SELECT student_id, MAX(completed_at) AS last_quiz_at FROM quiz_attempts GROUP BY student_id) q " +
                     "ON q.student_id = s.student_id " +
                     "SET s.energy = ? " +
                     "WHERE s.student_id = ? AND s.energy < ? " +
                     "AND (q.last_quiz_at IS NULL OR q.last_quiz_at <= DATE_SUB(NOW(), INTERVAL 4 HOUR))";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, MAX_ENERGY);
            ps.setString(2, studentId);
            ps.setInt(3, MAX_ENERGY);
            ps.executeUpdate();
        }
    }

    private void hydrateEnergyRenewal(Student student) throws SQLException {
        student.setMaxEnergy(MAX_ENERGY);
        if (student.getEnergy() >= MAX_ENERGY) {
            student.setEnergyRenewalEpochMillis(0L);
            return;
        }

        String sql = "SELECT LEAST(14400, GREATEST(0, TIMESTAMPDIFF(SECOND, NOW(), DATE_ADD(MAX(completed_at), INTERVAL 4 HOUR)))) " +
                     "AS seconds_until_renewal FROM quiz_attempts WHERE student_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, student.getStudentId());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int secondsUntilRenewal = rs.getInt("seconds_until_renewal");
                    if (!rs.wasNull()) {
                        student.setEnergyRenewalEpochMillis(System.currentTimeMillis() + (secondsUntilRenewal * 1000L));
                        return;
                    }
                }
            }
        }
        student.setEnergyRenewalEpochMillis(System.currentTimeMillis());
    }
}

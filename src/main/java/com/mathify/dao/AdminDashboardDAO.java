package com.mathify.dao;

import com.mathify.db.DBUtil;
import com.mathify.model.CourseCompletionDTO;
import com.mathify.model.CoursePopularityDTO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Aggregate queries for the admin dashboard. All "active user" metrics are
 * based on {@code quiz_attempts.completed_at} because the app does not
 * track sessions or logins directly - quiz activity is the most meaningful
 * engagement signal available.
 */
public class AdminDashboardDAO {

    // ------------------------------------------------------------------
    // Active-user counts
    // ------------------------------------------------------------------

    /** Students with at least one quiz attempt today. */
    public int getDailyActiveUsers() throws SQLException {
        return countDistinctActive("completed_at >= CURDATE()");
    }

    /** Students with at least one quiz attempt in the last 7 days. */
    public int getWeeklyActiveUsers() throws SQLException {
        return countDistinctActive("completed_at >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)");
    }

    /** Students with at least one quiz attempt in the last 30 days. */
    public int getMonthlyActiveUsers() throws SQLException {
        return countDistinctActive("completed_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)");
    }

    /** DAU for yesterday (used for the week-over-week delta). */
    public int getPreviousDailyActiveUsers() throws SQLException {
        return countDistinctActive(
            "completed_at >= DATE_SUB(CURDATE(), INTERVAL 1 DAY) AND completed_at < CURDATE()");
    }

    /** WAU for the 7-day window ending 7 days ago. */
    public int getPreviousWeeklyActiveUsers() throws SQLException {
        return countDistinctActive(
            "completed_at >= DATE_SUB(CURDATE(), INTERVAL 14 DAY) " +
            "AND completed_at < DATE_SUB(CURDATE(), INTERVAL 7 DAY)");
    }

    private int countDistinctActive(String whereClause) throws SQLException {
        String sql = "SELECT COUNT(DISTINCT student_id) FROM quiz_attempts WHERE " + whereClause;
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    // ------------------------------------------------------------------
    // Retention
    // ------------------------------------------------------------------

    /**
     * Retention rate: percentage of students active in the prior 7-day window
     * (8-14 days ago) who were also active in the recent 7-day window (1-7
     * days ago).
     */
    public float getRetentionRate() throws SQLException {
        return computeRetention(
            "completed_at >= DATE_SUB(CURDATE(), INTERVAL 14 DAY) " +
            "AND completed_at < DATE_SUB(CURDATE(), INTERVAL 7 DAY)",
            "completed_at >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) " +
            "AND completed_at < CURDATE()");
    }

    /**
     * Previous retention: students active 15-21 days ago who returned 8-14
     * days ago - used for the delta.
     */
    public float getPreviousRetentionRate() throws SQLException {
        return computeRetention(
            "completed_at >= DATE_SUB(CURDATE(), INTERVAL 21 DAY) " +
            "AND completed_at < DATE_SUB(CURDATE(), INTERVAL 14 DAY)",
            "completed_at >= DATE_SUB(CURDATE(), INTERVAL 14 DAY) " +
            "AND completed_at < DATE_SUB(CURDATE(), INTERVAL 7 DAY)");
    }

    private float computeRetention(String priorWindow, String recentWindow) throws SQLException {
        String sql =
            "SELECT " +
            "  COUNT(DISTINCT prior.student_id) AS prior_count, " +
            "  COUNT(DISTINCT recent.student_id) AS retained_count " +
            "FROM (SELECT DISTINCT student_id FROM quiz_attempts WHERE " + priorWindow + ") prior " +
            "LEFT JOIN (SELECT DISTINCT student_id FROM quiz_attempts WHERE " + recentWindow + ") recent " +
            "ON prior.student_id = recent.student_id";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                int priorCount = rs.getInt("prior_count");
                int retainedCount = rs.getInt("retained_count");
                if (priorCount > 0) {
                    return (float) retainedCount / priorCount * 100f;
                }
            }
        }
        return 0f;
    }

    // ------------------------------------------------------------------
    // Course popularity (enrollment counts)
    // ------------------------------------------------------------------

    /**
     * Returns every course with its enrollment count, ordered most-popular
     * first. The {@code progressPercent} on each DTO is set relative to the
     * top course (which gets 100%).
     */
    public List<CoursePopularityDTO> getCoursePopularity() throws SQLException {
        List<CoursePopularityDTO> list = new ArrayList<>();
        String sql =
            "SELECT c.title, COUNT(ce.student_id) AS learner_count " +
            "FROM courses c " +
            "LEFT JOIN course_enrollments ce ON ce.course_id = c.course_id " +
            "GROUP BY c.course_id, c.title " +
            "ORDER BY learner_count DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new CoursePopularityDTO(
                    rs.getString("title"),
                    rs.getInt("learner_count"),
                    0));
            }
        }

        // Compute relative percentages (most popular = 100%)
        if (!list.isEmpty()) {
            int max = list.get(0).getLearnerCount();
            for (CoursePopularityDTO dto : list) {
                dto.setProgressPercent(max > 0
                    ? Math.round((float) dto.getLearnerCount() / max * 100f)
                    : 0);
            }
        }
        return list;
    }

    // ------------------------------------------------------------------
    // Course completion rates
    // ------------------------------------------------------------------

    /**
     * Per-course completion rate: completed enrollments / total enrollments
     * as a percentage.
     */
    public List<CourseCompletionDTO> getCourseCompletionRates() throws SQLException {
        List<CourseCompletionDTO> list = new ArrayList<>();
        String sql =
            "SELECT c.title, " +
            "  COUNT(ce.student_id) AS total_enrolled, " +
            "  COUNT(ce.completed_at) AS total_completed " +
            "FROM courses c " +
            "LEFT JOIN course_enrollments ce ON ce.course_id = c.course_id " +
            "GROUP BY c.course_id, c.title " +
            "ORDER BY c.title ASC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                int enrolled = rs.getInt("total_enrolled");
                int completed = rs.getInt("total_completed");
                int pct = (enrolled > 0)
                    ? Math.round((float) completed / enrolled * 100f)
                    : 0;
                list.add(new CourseCompletionDTO(rs.getString("title"), pct));
            }
        }
        return list;
    }
}

package com.mathify.dao;

import com.mathify.db.DBUtil;
import com.mathify.model.UserProgress;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class ProgressDAO {

    public record EnrolledCourse(String courseId, String title, String category, int progressPercent, boolean completed) {}
    public record QuizProgressResult(int xpDelta, boolean streakAwarded, int currentStreak) {}

    public void enrollCourse(String studentId, String courseId) throws SQLException {
        String sql = "INSERT INTO course_enrollments (student_id, course_id, enrolled_at) " +
                     "VALUES (?, ?, NOW()) " +
                     "ON DUPLICATE KEY UPDATE enrolled_at = enrolled_at";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ps.setString(2, courseId);
            ps.executeUpdate();
        }
    }

    /**
     * Loads the high-level progress (xp, level, streak) for a student.
     */
    public UserProgress getUserProgress(String studentId) throws SQLException {
        reconcileUserXP(studentId);
        reconcileUserStreak(studentId);

        UserProgress progress = new UserProgress(studentId);
        String sql = "SELECT total_xp, level, current_streak FROM user_progress WHERE student_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    progress.addXP(rs.getInt("total_xp"));
                    // UserProgress level defaults to 0 natively.
                    progress.addLevel(rs.getInt("level")); 
                    progress.addStreak(rs.getInt("current_streak"));
                }
            }
            
            // Load achievements
            String sqlAch = "SELECT a.achievement_id, a.title, a.category, a.requirement, a.icon, sa.unlocked_at " +
                            "FROM student_achievements sa " +
                            "JOIN achievements a ON sa.achievement_id = a.achievement_id " +
                            "WHERE sa.student_id = ?";
            try (PreparedStatement psAch = conn.prepareStatement(sqlAch)) {
                psAch.setString(1, studentId);
                try (ResultSet rsAch = psAch.executeQuery()) {
                    while (rsAch.next()) {
                        com.mathify.model.Achievement a = new com.mathify.model.Achievement();
                        a.setId(rsAch.getString("achievement_id"));
                        a.setTitle(rsAch.getString("title"));
                        a.setCategory(rsAch.getString("category"));
                        a.setRequirement(rsAch.getString("requirement"));
                        a.setIcon(rsAch.getString("icon"));
                        
                        java.time.LocalDateTime unlockedAt = rsAch.getTimestamp("unlocked_at").toLocalDateTime();
                        progress.getAchievements().add(new UserProgress.AchievementUnlock(a, unlockedAt));
                    }
                }
            }
        }
        return progress;
    }

    /**
     * Gets the count of courses the student has completed.
     */
    public int getCompletedCoursesCount(String studentId) throws SQLException {
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM course_enrollments WHERE student_id = ? AND completed_at IS NOT NULL")) {
            reconcileProgress(conn, studentId);
            ps.setString(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    public boolean hasCompletedCourse(String studentId, String courseId) throws SQLException {
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT 1 FROM course_enrollments WHERE student_id = ? AND course_id = ? AND completed_at IS NOT NULL")) {
            reconcileProgress(conn, studentId);
            ps.setString(1, studentId);
            ps.setString(2, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public int reconcileCourseCompletions(String studentId) throws SQLException {
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int updated = reconcileCourseCompletions(conn, studentId);
                conn.commit();
                return updated;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }
    }

    private int reconcileCourseCompletions(Connection conn, String studentId) throws SQLException {
        String sql = "UPDATE course_enrollments ce " +
                     "SET ce.completed_at = NOW() " +
                     "WHERE ce.student_id = ? " +
                     "AND ce.completed_at IS NULL " +
                     "AND EXISTS ( " +
                     "  SELECT 1 FROM chapters ch " +
                     "  WHERE ch.course_id = ce.course_id " +
                     "  AND EXISTS (SELECT 1 FROM quizzes q WHERE q.chapter_id = ch.chapter_id) " +
                     ") " +
                     "AND NOT EXISTS ( " +
                     "  SELECT 1 FROM chapters ch " +
                     "  WHERE ch.course_id = ce.course_id " +
                     "  AND EXISTS (SELECT 1 FROM quizzes q WHERE q.chapter_id = ch.chapter_id) " +
                     "  AND EXISTS ( " +
                     "    SELECT 1 FROM quizzes q " +
                     "    WHERE q.chapter_id = ch.chapter_id " +
                     "    AND NOT EXISTS ( " +
                     "      SELECT 1 FROM quiz_attempts qa " +
                     "      WHERE qa.student_id = ce.student_id " +
                     "      AND qa.quiz_id = q.quiz_id " +
                     "      AND qa.score >= q.passing_score " +
                     "    ) " +
                     "  ) " +
                     ")";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            return ps.executeUpdate();
        }
    }

    private void reconcileProgress(Connection conn, String studentId) throws SQLException {
        completeReadyChapters(conn, studentId);
        reconcileMissingEnrollments(conn, studentId);
        reconcileCourseCompletions(conn, studentId);
        reconcileAchievements(conn, studentId);
    }

    private void reconcileMissingEnrollments(Connection conn, String studentId) throws SQLException {
        String chapterProgressSql = "INSERT INTO course_enrollments (student_id, course_id, enrolled_at) " +
                                    "SELECT ?, ch.course_id, MIN(cp.completed_at) " +
                                    "FROM chapter_progress cp " +
                                    "JOIN chapters ch ON cp.chapter_id = ch.chapter_id " +
                                    "WHERE cp.student_id = ? " +
                                    "GROUP BY ch.course_id " +
                                    "ON DUPLICATE KEY UPDATE enrolled_at = LEAST(enrolled_at, VALUES(enrolled_at))";
        try (PreparedStatement ps = conn.prepareStatement(chapterProgressSql)) {
            ps.setString(1, studentId);
            ps.setString(2, studentId);
            ps.executeUpdate();
        }

        String quizAttemptSql = "INSERT INTO course_enrollments (student_id, course_id, enrolled_at) " +
                                "SELECT ?, ch.course_id, MIN(qa.completed_at) " +
                                "FROM quiz_attempts qa " +
                                "JOIN quizzes q ON qa.quiz_id = q.quiz_id " +
                                "JOIN chapters ch ON q.chapter_id = ch.chapter_id " +
                                "WHERE qa.student_id = ? " +
                                "GROUP BY ch.course_id " +
                                "ON DUPLICATE KEY UPDATE enrolled_at = LEAST(enrolled_at, VALUES(enrolled_at))";
        try (PreparedStatement ps = conn.prepareStatement(quizAttemptSql)) {
            ps.setString(1, studentId);
            ps.setString(2, studentId);
            ps.executeUpdate();
        }
    }

    /**
     * Gets courses the student is currently enrolled in (not necessarily completed).
     * Calculates a simple progress percentage based on completed chapters vs total chapters.
     */
    public List<EnrolledCourse> getRecentEnrollments(String studentId) throws SQLException {
        List<EnrolledCourse> list = new ArrayList<>();
        String sql = 
            "SELECT c.course_id, c.title, c.category, ce.completed_at, " +
            "  (SELECT COUNT(*) FROM chapters ch " +
            "   WHERE ch.course_id = c.course_id " +
            "   AND EXISTS (SELECT 1 FROM quizzes q WHERE q.chapter_id = ch.chapter_id)) AS total_chapters, " +
            "  (SELECT COUNT(*) FROM chapter_progress cp " +
            "   JOIN chapters ch ON cp.chapter_id = ch.chapter_id " +
            "   WHERE ch.course_id = c.course_id AND cp.student_id = ? " +
            "   AND EXISTS (SELECT 1 FROM quizzes q WHERE q.chapter_id = ch.chapter_id) " +
            "   AND NOT EXISTS ( " +
            "     SELECT 1 FROM quizzes q " +
            "     WHERE q.chapter_id = ch.chapter_id " +
            "     AND NOT EXISTS ( " +
            "       SELECT 1 FROM quiz_attempts qa " +
            "       WHERE qa.student_id = cp.student_id " +
            "       AND qa.quiz_id = q.quiz_id " +
            "       AND qa.score >= q.passing_score " +
            "     ) " +
            "   )) AS completed_chapters " +
            "FROM course_enrollments ce " +
            "JOIN courses c ON ce.course_id = c.course_id " +
            "WHERE ce.student_id = ? " +
            "ORDER BY ce.enrolled_at DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            reconcileProgress(conn, studentId);
            ps.setString(1, studentId);
            ps.setString(2, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String courseId = rs.getString("course_id");
                    String title = rs.getString("title");
                    String category = rs.getString("category");
                    int total = rs.getInt("total_chapters");
                    int completed = rs.getInt("completed_chapters");
                    boolean courseCompleted = rs.getTimestamp("completed_at") != null;
                    
                    int percent = (total > 0) ? (int) Math.round((double) completed / total * 100.0) : 0;
                    if (courseCompleted) {
                        percent = 100;
                    }
                    list.add(new EnrolledCourse(courseId, title, category, percent, courseCompleted));
                }
            }
        }
        return list;
    }

    /**
     * Awards XP for completing a chapter if not already awarded.
     */
    public boolean awardChapterXP(String studentId, String chapterId) throws SQLException {
        String checkSql = "SELECT 1 FROM chapter_progress WHERE student_id = ? AND chapter_id = ?";
        String insertSql = "INSERT INTO chapter_progress (student_id, chapter_id, completed_at, time_spent_secs) VALUES (?, ?, NOW(), 0)";
        boolean awarded = false;
        
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                boolean exists = false;
                try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                    ps.setString(1, studentId);
                    ps.setString(2, chapterId);
                    try (ResultSet rs = ps.executeQuery()) {
                        exists = rs.next();
                    }
                }
                if (!exists) {
                    try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                        ps.setString(1, studentId);
                        ps.setString(2, chapterId);
                        ps.executeUpdate();
                    }
                    reconcileUserXP(conn, studentId);
                    awarded = true;
                }
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }
        return awarded;
    }

    /**
     * Retrieves completed chapters for a specific course and student.
     */
    public Set<String> getCompletedChapters(String studentId, String courseId) throws SQLException {
        Set<String> completed = new HashSet<>();
        String sql = "SELECT cp.chapter_id FROM chapter_progress cp " +
                     "JOIN chapters ch ON cp.chapter_id = ch.chapter_id " +
                     "WHERE cp.student_id = ? AND ch.course_id = ? " +
                     "AND EXISTS (SELECT 1 FROM quizzes q WHERE q.chapter_id = ch.chapter_id) " +
                     "AND NOT EXISTS ( " +
                     "  SELECT 1 FROM quizzes q " +
                     "  WHERE q.chapter_id = ch.chapter_id " +
                     "  AND NOT EXISTS ( " +
                     "    SELECT 1 FROM quiz_attempts qa " +
                     "    WHERE qa.student_id = cp.student_id " +
                     "    AND qa.quiz_id = q.quiz_id " +
                     "    AND qa.score >= q.passing_score " +
                     "  ) " +
                     ")";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
             ps.setString(1, studentId);
             ps.setString(2, courseId);
             try (ResultSet rs = ps.executeQuery()) {
                 while(rs.next()) {
                     completed.add(rs.getString(1));
                 }
             }
        }
        return completed;
    }

    public Set<String> getCompletedModules(String studentId, String courseId) throws SQLException {
        return new HashSet<>();
    }

    public void recordQuizAttempt(String studentId, String quizId, int scorePercent) throws SQLException {
        String sql = "INSERT INTO quiz_attempts (student_id, quiz_id, score, completed_at) " +
                     "VALUES (?, ?, ?, NOW()) " +
                     "ON DUPLICATE KEY UPDATE score = GREATEST(score, VALUES(score)), completed_at = NOW()";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ps.setString(2, quizId);
            ps.setInt(3, scorePercent);
            ps.executeUpdate();
        }
    }

    public QuizProgressResult recordQuizAttemptAndSyncXP(
            String studentId,
            String quizId,
            int scorePercent
    ) throws SQLException {
        String upsertSql = "INSERT INTO quiz_attempts (student_id, quiz_id, score, completed_at) " +
                           "VALUES (?, ?, ?, NOW()) " +
                           "ON DUPLICATE KEY UPDATE score = GREATEST(score, VALUES(score)), completed_at = NOW()";
        int xpDelta;
        int streakValue;
        boolean streakAwarded;

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                StreakUpdate streakUpdate = applyQuizStreak(conn, studentId);
                streakValue = streakUpdate.currentStreak();
                streakAwarded = streakUpdate.awarded();

                try (PreparedStatement ps = conn.prepareStatement(upsertSql)) {
                    ps.setString(1, studentId);
                    ps.setString(2, quizId);
                    ps.setInt(3, scorePercent);
                    ps.executeUpdate();
                }

                xpDelta = reconcileUserXP(conn, studentId);
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }

        return new QuizProgressResult(xpDelta, streakAwarded, streakValue);
    }

    public Set<String> getCompletedQuizzes(String studentId, String courseId) throws SQLException {
        Set<String> completed = new HashSet<>();
        String sql = "SELECT qa.quiz_id FROM quiz_attempts qa " +
                     "JOIN quizzes q ON qa.quiz_id = q.quiz_id " +
                     "JOIN chapters c ON q.chapter_id = c.chapter_id " +
                     "WHERE qa.student_id = ? AND c.course_id = ? AND qa.score >= q.passing_score";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ps.setString(2, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    completed.add(rs.getString(1));
                }
            }
        }
        return completed;
    }

    public Map<String, Integer> getQuizScoresForCourse(String studentId, String courseId) throws SQLException {
        Map<String, Integer> scores = new HashMap<>();
        String sql = "SELECT qa.quiz_id, qa.score FROM quiz_attempts qa " +
                     "JOIN quizzes q ON qa.quiz_id = q.quiz_id " +
                     "JOIN chapters c ON q.chapter_id = c.chapter_id " +
                     "WHERE qa.student_id = ? AND c.course_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ps.setString(2, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    scores.put(rs.getString("quiz_id"), rs.getInt("score"));
                }
            }
        }
        return scores;
    }

    public String getChapterIdForModule(String moduleId) throws SQLException {
        String sql = "SELECT chapter_id FROM learning_modules WHERE module_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, moduleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString(1);
                }
            }
        }
        return null;
    }

    public boolean completeChapterIfReady(String studentId, String chapterId) throws SQLException {
        if (chapterId == null) {
            return false;
        }
        try (Connection conn = DBUtil.getConnection()) {
            if (!isChapterReadyForCompletion(conn, studentId, chapterId)) {
                return false;
            }
        }
        return awardChapterXP(studentId, chapterId);
    }

    private boolean isChapterReadyForCompletion(Connection conn, String studentId, String chapterId) throws SQLException {
        String sql = "SELECT " +
                     "  (SELECT COUNT(*) FROM quizzes WHERE chapter_id = ?) AS quiz_count, " +
                     "  (SELECT COUNT(*) FROM quizzes q " +
                     "   WHERE q.chapter_id = ? " +
                     "   AND EXISTS ( " +
                     "     SELECT 1 FROM quiz_attempts qa " +
                     "     WHERE qa.student_id = ? " +
                     "     AND qa.quiz_id = q.quiz_id " +
                     "     AND qa.score >= q.passing_score " +
                     "   )) AS passed_quiz_count";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, chapterId);
            ps.setString(2, chapterId);
            ps.setString(3, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int quizCount = rs.getInt("quiz_count");
                    int passedQuizCount = rs.getInt("passed_quiz_count");
                    return quizCount > 0 && passedQuizCount == quizCount;
                }
            }
        }
        return false;
    }

    public int reconcileUserXP(String studentId) throws SQLException {
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int delta = reconcileUserXP(conn, studentId);
                conn.commit();
                return delta;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }
    }

    private int reconcileUserXP(Connection conn, String studentId) throws SQLException {
        completeReadyChapters(conn, studentId);
        reconcileMissingEnrollments(conn, studentId);
        reconcileCourseCompletions(conn, studentId);

        int currentXP = getStoredXP(conn, studentId);
        int correctedXP = calculateQuizXP(conn, studentId) + calculateValidChapterXP(conn, studentId);

        if (currentXP != correctedXP) {
            String updateSql = "UPDATE user_progress SET total_xp = ? WHERE student_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setInt(1, correctedXP);
                ps.setString(2, studentId);
                ps.executeUpdate();
            }
        }

        return correctedXP - currentXP;
    }

    private void completeReadyChapters(Connection conn, String studentId) throws SQLException {
        String sql = "INSERT INTO chapter_progress (student_id, chapter_id, completed_at, time_spent_secs) " +
                     "SELECT ?, ch.chapter_id, NOW(), 0 " +
                     "FROM chapters ch " +
                     "WHERE EXISTS (SELECT 1 FROM quizzes q WHERE q.chapter_id = ch.chapter_id) " +
                     "AND NOT EXISTS ( " +
                     "  SELECT 1 FROM chapter_progress cp " +
                     "  WHERE cp.student_id = ? AND cp.chapter_id = ch.chapter_id " +
                     ") " +
                     "AND NOT EXISTS ( " +
                     "  SELECT 1 FROM quizzes q " +
                     "  WHERE q.chapter_id = ch.chapter_id " +
                     "  AND NOT EXISTS ( " +
                     "    SELECT 1 FROM quiz_attempts qa " +
                     "    WHERE qa.student_id = ? " +
                     "    AND qa.quiz_id = q.quiz_id " +
                     "    AND qa.score >= q.passing_score " +
                     "  ) " +
                     ")";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ps.setString(2, studentId);
            ps.setString(3, studentId);
            ps.executeUpdate();
        }
    }

    private int getStoredXP(Connection conn, String studentId) throws SQLException {
        String sql = "SELECT total_xp FROM user_progress WHERE student_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total_xp");
                }
            }
        }
        return 0;
    }

    private int calculateQuizXP(Connection conn, String studentId) throws SQLException {
        String sql = "SELECT COALESCE(SUM(ROUND(qa.score * qp.total_points / 100)), 0) AS quiz_xp " +
                     "FROM quiz_attempts qa " +
                     "JOIN quizzes q ON qa.quiz_id = q.quiz_id " +
                     "JOIN ( " +
                     "  SELECT quiz_id, SUM(points) AS total_points " +
                     "  FROM questions " +
                     "  GROUP BY quiz_id " +
                     ") qp ON qp.quiz_id = qa.quiz_id " +
                     "WHERE qa.student_id = ? AND qa.score >= q.passing_score";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("quiz_xp");
                }
            }
        }
        return 0;
    }

    private int calculateValidChapterXP(Connection conn, String studentId) throws SQLException {
        String sql = "SELECT COALESCE(SUM(ch.xp_reward), 0) AS chapter_xp " +
                     "FROM chapter_progress cp " +
                     "JOIN chapters ch ON cp.chapter_id = ch.chapter_id " +
                     "WHERE cp.student_id = ? " +
                     "AND EXISTS (SELECT 1 FROM quizzes q WHERE q.chapter_id = ch.chapter_id) " +
                     "AND NOT EXISTS ( " +
                     "  SELECT 1 FROM quizzes q " +
                     "  WHERE q.chapter_id = ch.chapter_id " +
                     "  AND NOT EXISTS ( " +
                     "    SELECT 1 FROM quiz_attempts qa " +
                     "    WHERE qa.student_id = cp.student_id " +
                     "    AND qa.quiz_id = q.quiz_id " +
                     "    AND qa.score >= q.passing_score " +
                     "  ) " +
                     ")";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("chapter_xp");
                }
            }
        }
        return 0;
    }

    public int reconcileUserStreak(String studentId) throws SQLException {
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int streak = reconcileUserStreak(conn, studentId);
                conn.commit();
                return streak;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }
    }

    private int reconcileUserStreak(Connection conn, String studentId) throws SQLException {
        int currentStreak = getStoredStreak(conn, studentId);
        LocalDate lastQuizDate = getLastQuizDate(conn, studentId);
        LocalDate today = LocalDate.now();

        int correctedStreak = currentStreak;
        if (lastQuizDate == null || lastQuizDate.isBefore(today.minusDays(1))) {
            correctedStreak = 0;
        } else if (currentStreak < 1) {
            correctedStreak = 1;
        }

        if (correctedStreak != currentStreak) {
            updateStoredStreak(conn, studentId, correctedStreak);
        }
        return correctedStreak;
    }

    private StreakUpdate applyQuizStreak(Connection conn, String studentId) throws SQLException {
        int currentStreak = reconcileUserStreak(conn, studentId);
        LocalDate lastQuizDate = getLastQuizDate(conn, studentId);
        LocalDate today = LocalDate.now();

        int newStreak;
        if (today.equals(lastQuizDate)) {
            newStreak = Math.max(currentStreak, 1);
        } else if (today.minusDays(1).equals(lastQuizDate)) {
            newStreak = currentStreak + 1;
        } else {
            newStreak = 1;
        }

        if (newStreak != currentStreak) {
            updateStoredStreak(conn, studentId, newStreak);
        }
        return new StreakUpdate(newStreak, newStreak > currentStreak);
    }

    private int getStoredStreak(Connection conn, String studentId) throws SQLException {
        String sql = "SELECT current_streak FROM user_progress WHERE student_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("current_streak");
                }
            }
        }
        return 0;
    }

    private LocalDate getLastQuizDate(Connection conn, String studentId) throws SQLException {
        String sql = "SELECT MAX(DATE(completed_at)) AS last_quiz_date FROM quiz_attempts WHERE student_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getDate("last_quiz_date") != null) {
                    return rs.getDate("last_quiz_date").toLocalDate();
                }
            }
        }
        return null;
    }

    private void updateStoredStreak(Connection conn, String studentId, int streak) throws SQLException {
        String sql = "UPDATE user_progress SET current_streak = ? WHERE student_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, streak);
            ps.setString(2, studentId);
            ps.executeUpdate();
        }
    }

    private record StreakUpdate(int currentStreak, boolean awarded) {}

    public Map<String, Integer> completeChaptersIfReadyForCourse(String studentId, String courseId) throws SQLException {
        Map<String, Integer> newlyCompleted = new HashMap<>();
        String sql = "SELECT chapter_id, xp_reward FROM chapters WHERE course_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String chapterId = rs.getString("chapter_id");
                    int xpReward = rs.getInt("xp_reward");
                    if (completeChapterIfReady(studentId, chapterId)) {
                        newlyCompleted.put(chapterId, xpReward);
                    }
                }
            }
        }
        return newlyCompleted;
    }

    public int getChapterXpReward(String chapterId) throws SQLException {
        String sql = "SELECT xp_reward FROM chapters WHERE chapter_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, chapterId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    public List<com.mathify.model.Achievement> getAllAchievements() throws SQLException {
        List<com.mathify.model.Achievement> list = new ArrayList<>();
        String sql = "SELECT achievement_id, title, category, requirement, icon FROM achievements";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                com.mathify.model.Achievement a = new com.mathify.model.Achievement();
                a.setId(rs.getString("achievement_id"));
                a.setTitle(rs.getString("title"));
                a.setCategory(rs.getString("category"));
                a.setRequirement(rs.getString("requirement"));
                a.setIcon(rs.getString("icon"));
                list.add(a);
            }
        }
        return list;
    }

    private void reconcileAchievements(Connection conn, String studentId) throws SQLException {
        int currentStreak = getStoredStreak(conn, studentId);
        int totalXP = getStoredXP(conn, studentId);

        // 1. First Steps: Has completed at least one chapter
        if (checkQuery(conn, "SELECT 1 FROM chapter_progress WHERE student_id = ? LIMIT 1", studentId)) {
            unlockAchievement(conn, studentId, "ach-1");
        }
        // 2. Quiz Whiz: Passed 5 quizzes
        if (checkCount(conn, "SELECT COUNT(*) FROM quiz_attempts qa JOIN quizzes q ON qa.quiz_id = q.quiz_id WHERE qa.student_id = ? AND qa.score >= q.passing_score", studentId) >= 5) {
            unlockAchievement(conn, studentId, "ach-2");
        }
        // 3. On Fire: 7-day streak
        if (currentStreak >= 7) {
            unlockAchievement(conn, studentId, "ach-3");
        }
        // 4. Scholar: 1,000 XP
        if (totalXP >= 1000) {
            unlockAchievement(conn, studentId, "ach-4");
        }
        // 5. Course Champion: Completed 1 course
        if (checkQuery(conn, "SELECT 1 FROM course_enrollments WHERE student_id = ? AND completed_at IS NOT NULL LIMIT 1", studentId)) {
            unlockAchievement(conn, studentId, "ach-5");
        }
        // 6. Perfectionist: 100% on a quiz
        if (checkQuery(conn, "SELECT 1 FROM quiz_attempts WHERE student_id = ? AND score = 100 LIMIT 1", studentId)) {
            unlockAchievement(conn, studentId, "ach-6");
        }
        // 7. Marathoner: 30-day streak
        if (currentStreak >= 30) {
            unlockAchievement(conn, studentId, "ach-7");
        }
        // 8. Polymath: Enroll in 3 categories
        if (checkCount(conn, "SELECT COUNT(DISTINCT c.category) FROM course_enrollments ce JOIN courses c ON ce.course_id = c.course_id WHERE ce.student_id = ?", studentId) >= 3) {
            unlockAchievement(conn, studentId, "ach-8");
        }
    }

    private boolean checkQuery(Connection conn, String sql, String studentId) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private int checkCount(Connection conn, String sql, String studentId) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    private void unlockAchievement(Connection conn, String studentId, String achievementId) throws SQLException {
        String sql = "INSERT INTO student_achievements (student_id, achievement_id, unlocked_at) " +
                     "VALUES (?, ?, NOW()) ON DUPLICATE KEY UPDATE unlocked_at = unlocked_at";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ps.setString(2, achievementId);
            int affected = ps.executeUpdate();
            if (affected == 1) { 
                 // Insert notification
                 try (PreparedStatement psNotif = conn.prepareStatement("INSERT INTO notifications (user_id, type, sent_at, is_read) VALUES (?, 'ACHIEVEMENT_UNLOCKED', NOW(), FALSE)")) {
                      psNotif.setString(1, studentId);
                      psNotif.executeUpdate();
                 }
            }
        }
    }
}

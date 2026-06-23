package com.mathify.db;

import java.sql.Connection;
import java.sql.Statement;

public class DBUpdater {
    public static void main(String[] args) {
        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement()) {
            
            // Add is_disabled column
            String sql = "ALTER TABLE users ADD COLUMN is_disabled BOOLEAN NOT NULL DEFAULT FALSE";
            stmt.executeUpdate(sql);
            System.out.println("SUCCESS: Added is_disabled column to users table.");
            
        } catch (Exception e) {
            System.err.println("INFO: " + e.getMessage() + " (might already exist)");
        }

        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement()) {
            
            // Add icon column to achievements
            String sqlIcon = "ALTER TABLE achievements ADD COLUMN icon VARCHAR(50) NOT NULL DEFAULT 'bi-star-fill'";
            stmt.executeUpdate(sqlIcon);
            System.out.println("SUCCESS: Added icon column to achievements table.");
            
        } catch (Exception e) {
            System.err.println("INFO: " + e.getMessage() + " (might already exist)");
        }

        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement()) {
            
            // Populate default achievements
            String sqlInsert = "INSERT INTO achievements (achievement_id, title, category, requirement, icon) VALUES " +
                "('ach-1', 'First Steps',     'General', 'Complete your first lesson',     'bi-flag-fill'), " +
                "('ach-2', 'Quiz Whiz',       'Quiz',    'Pass 5 quizzes',                 'bi-patch-check-fill'), " +
                "('ach-3', 'On Fire',         'Streak',  'Reach a 7-day quiz streak',      'bi-fire'), " +
                "('ach-4', 'Scholar',         'XP',      'Earn 1,000 XP',                  'bi-mortarboard-fill'), " +
                "('ach-5', 'Course Champion', 'Course',  'Finish a full course',           'bi-trophy-fill'), " +
                "('ach-6', 'Perfectionist',   'Quiz',    'Score 100% on a quiz',           'bi-star-fill'), " +
                "('ach-7', 'Marathoner',      'Streak',  'Reach a 30-day quiz streak',     'bi-calendar-check-fill'), " +
                "('ach-8', 'Polymath',        'Course',  'Enroll in 3 categories',         'bi-stars') " +
                "ON DUPLICATE KEY UPDATE title=VALUES(title), category=VALUES(category), requirement=VALUES(requirement), icon=VALUES(icon)";
            stmt.executeUpdate(sqlInsert);
            System.out.println("SUCCESS: Populated achievements table.");
            
        } catch (Exception e) {
            System.err.println("ERROR: " + e.getMessage());
        }
    }
}

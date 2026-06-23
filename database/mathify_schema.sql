-- ============================================================================
-- Mathify — Initial Database & Table Setup (MySQL 8.0+)
-- Generated from Mathify.json (Lucidchart UML class diagram)
--
-- Conventions:
--   - All primary keys are UUID strings -> CHAR(36)
--   - Surrogate-generated PKs default to (UUID()) (MySQL 8.0.13+)
--   - Duration fields -> INT seconds
--   - quizAttempts modeled as "latest attempt only" (matches the
--     Map<quizId, QuizAttempt> in UserProgress) — composite PK, upsert on retry
--   - InnoDB + utf8mb4 throughout
-- ============================================================================

CREATE DATABASE IF NOT EXISTS mathify_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE mathify_db;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================================
-- 1. USER HIERARCHY  (User <<abstract>>  -> Student, Admin)
-- ============================================================================

DROP TABLE IF EXISTS users;
CREATE TABLE users (
    user_id       CHAR(36)     NOT NULL DEFAULT (UUID()),
    name          VARCHAR(150) NOT NULL,
    email         VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    is_disabled   BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
                               ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id),
    UNIQUE KEY uq_users_email (email)
) ENGINE=InnoDB;

-- Student extends User (joined-table inheritance: student_id = user_id)
DROP TABLE IF EXISTS students;
CREATE TABLE students (
    student_id CHAR(36) NOT NULL,
    energy     INT      NOT NULL DEFAULT 0,
    PRIMARY KEY (student_id),
    CONSTRAINT fk_students_user
        FOREIGN KEY (student_id) REFERENCES users (user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Admin extends User
DROP TABLE IF EXISTS admins;
CREATE TABLE admins (
    admin_id CHAR(36) NOT NULL,
    PRIMARY KEY (admin_id),
    CONSTRAINT fk_admins_user
        FOREIGN KEY (admin_id) REFERENCES users (user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Subscribable <<interface>>, implemented by PremiumStudent.
-- Student "has-a" Subscribable (composition) — modeled as an optional
-- 1:1 row: a row exists only while the student is premium.
DROP TABLE IF EXISTS subscriptions;
CREATE TABLE subscriptions (
    subscription_id     CHAR(36)     NOT NULL DEFAULT (UUID()),
    student_id           CHAR(36)     NOT NULL,
    subscription_plan    VARCHAR(50)  NOT NULL,
    subscription_expiry DATE         NOT NULL,
    is_canceled          BOOLEAN      NOT NULL DEFAULT FALSE,
    midtrans_order_id    VARCHAR(100) NULL,
    payment_status       VARCHAR(30)  NULL,
    created_at           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
                                      ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (subscription_id),
    UNIQUE KEY uq_subscriptions_student (student_id),
    CONSTRAINT fk_subscriptions_student
        FOREIGN KEY (student_id) REFERENCES students (student_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Notification — composed by User
DROP TABLE IF EXISTS notifications;
CREATE TABLE notifications (
    notification_id CHAR(36) NOT NULL DEFAULT (UUID()),
    user_id          CHAR(36) NOT NULL,
    type             ENUM('STREAK_REMINDER','XP_BOOST','LESSON_REMINDER','ACHIEVEMENT_UNLOCKED')
                              NOT NULL,
    sent_at          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_read          BOOLEAN  NOT NULL DEFAULT FALSE,
    PRIMARY KEY (notification_id),
    KEY idx_notifications_user (user_id),
    CONSTRAINT fk_notifications_user
        FOREIGN KEY (user_id) REFERENCES users (user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================================================
-- 2. ACHIEVEMENTS
-- ============================================================================

DROP TABLE IF EXISTS achievements;
CREATE TABLE achievements (
    achievement_id CHAR(36)     NOT NULL DEFAULT (UUID()),
    title          VARCHAR(150) NOT NULL,
    category       VARCHAR(100) NOT NULL,
    requirement    VARCHAR(255) NOT NULL,
    PRIMARY KEY (achievement_id)
) ENGINE=InnoDB;

-- List<Achievement, Date> on UserProgress -> junction with unlocked_at
DROP TABLE IF EXISTS student_achievements;
CREATE TABLE student_achievements (
    student_id     CHAR(36) NOT NULL,
    achievement_id CHAR(36) NOT NULL,
    unlocked_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (student_id, achievement_id),
    CONSTRAINT fk_stud_ach_student
        FOREIGN KEY (student_id) REFERENCES students (student_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_stud_ach_achievement
        FOREIGN KEY (achievement_id) REFERENCES achievements (achievement_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================================================
-- 3. COURSE CONTENT HIERARCHY
--    Course 1--* Chapter 1--* LearningModule | Quiz *--1 Question
--    LearningModule stores both VIDEO and SLIDE types as a flat table.
-- ============================================================================

DROP TABLE IF EXISTS courses;
CREATE TABLE courses (
    course_id   CHAR(36)     NOT NULL DEFAULT (UUID()),
    title       VARCHAR(200) NOT NULL,
    description TEXT,
    category    VARCHAR(100) NOT NULL,
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
                             ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (course_id)
) ENGINE=InnoDB;

-- Course.prerequisite : List<Course> (self-referencing M:N)
DROP TABLE IF EXISTS course_prerequisites;
CREATE TABLE course_prerequisites (
    course_id              CHAR(36) NOT NULL,
    prerequisite_course_id CHAR(36) NOT NULL,
    PRIMARY KEY (course_id, prerequisite_course_id),
    CONSTRAINT fk_prereq_course
        FOREIGN KEY (course_id) REFERENCES courses (course_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_prereq_prerequisite
        FOREIGN KEY (prerequisite_course_id) REFERENCES courses (course_id)
        ON DELETE CASCADE,
    CONSTRAINT chk_prereq_not_self
        CHECK (course_id <> prerequisite_course_id)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS chapters;
CREATE TABLE chapters (
    chapter_id  CHAR(36)     NOT NULL DEFAULT (UUID()),
    course_id   CHAR(36)     NOT NULL,
    title       VARCHAR(200) NOT NULL,
    description TEXT,
    xp_reward   INT          NOT NULL DEFAULT 0,
    order_index INT          NOT NULL DEFAULT 0,
    PRIMARY KEY (chapter_id),
    KEY idx_chapters_course (course_id),
    CONSTRAINT fk_chapters_course
        FOREIGN KEY (course_id) REFERENCES courses (course_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- LearningModule — flat table merging VideoModule and SlideModule.
-- content_url is the external URL for both types.
-- duration_secs applies to VIDEO only; slide_count applies to SLIDE only.
DROP TABLE IF EXISTS learning_modules;
CREATE TABLE learning_modules (
    module_id     CHAR(36)     NOT NULL DEFAULT (UUID()),
    chapter_id    CHAR(36)     NOT NULL,
    title         VARCHAR(200) NOT NULL,
    order_index   INT          NOT NULL DEFAULT 0,
    module_type   ENUM('VIDEO','SLIDE') NOT NULL,
    content_url   VARCHAR(500) NOT NULL,
    duration_secs INT          NULL,
    slide_count   INT          NULL,
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (module_id),
    KEY idx_modules_chapter (chapter_id),
    CONSTRAINT fk_modules_chapter
        FOREIGN KEY (chapter_id) REFERENCES chapters (chapter_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_module_type_fields CHECK (
        (module_type = 'VIDEO' AND duration_secs IS NOT NULL AND slide_count IS NULL)
     OR (module_type = 'SLIDE' AND slide_count IS NOT NULL AND duration_secs IS NULL)
    )
) ENGINE=InnoDB;

-- ============================================================================
-- 4. QUIZZES & QUESTIONS
--    Question <<interface>> -> MultipleChoiceQuestion, FillBlankQuestion,
--    DragDropQuestion (Generalization); base fields come from QuestionInfo
-- ============================================================================

DROP TABLE IF EXISTS quizzes;
CREATE TABLE quizzes (
    quiz_id       CHAR(36)     NOT NULL DEFAULT (UUID()),
    chapter_id    CHAR(36)     NOT NULL,
    title         VARCHAR(200) NOT NULL,
    passing_score INT          NOT NULL DEFAULT 0,
    PRIMARY KEY (quiz_id),
    KEY idx_quizzes_chapter (chapter_id),
    CONSTRAINT fk_quizzes_chapter
        FOREIGN KEY (chapter_id) REFERENCES chapters (chapter_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS questions;
CREATE TABLE questions (
    question_id   CHAR(36) NOT NULL DEFAULT (UUID()),
    quiz_id       CHAR(36) NOT NULL,
    prompt        TEXT     NOT NULL,
    points        INT      NOT NULL DEFAULT 1,
    question_type ENUM('MULTIPLE_CHOICE','FILL_BLANK','DRAG_AND_DROP') NOT NULL,
    order_index   INT      NOT NULL DEFAULT 0,
    PRIMARY KEY (question_id),
    KEY idx_questions_quiz (quiz_id),
    CONSTRAINT fk_questions_quiz
        FOREIGN KEY (quiz_id) REFERENCES quizzes (quiz_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- MultipleChoiceQuestion.options : List<Option{id, text}>,
-- correctOptionIds : Set<String> -> is_correct flag per option
DROP TABLE IF EXISTS multiple_choice_options;
CREATE TABLE multiple_choice_options (
    option_id   CHAR(36)     NOT NULL DEFAULT (UUID()),
    question_id CHAR(36)     NOT NULL,
    option_text VARCHAR(500) NOT NULL,
    is_correct  BOOLEAN      NOT NULL DEFAULT FALSE,
    order_index INT          NOT NULL DEFAULT 0,
    PRIMARY KEY (option_id),
    KEY idx_mc_options_question (question_id),
    CONSTRAINT fk_mc_options_question
        FOREIGN KEY (question_id) REFERENCES questions (question_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- FillBlankQuestion.caseSensitive -> subtype table (only applies to this type)
DROP TABLE IF EXISTS fill_blank_questions;
CREATE TABLE fill_blank_questions (
    question_id    CHAR(36) NOT NULL,
    case_sensitive BOOLEAN  NOT NULL DEFAULT FALSE,
    PRIMARY KEY (question_id),
    CONSTRAINT fk_fb_questions_question
        FOREIGN KEY (question_id) REFERENCES questions (question_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- FillBlankQuestion.correctAnswers : List<String>
DROP TABLE IF EXISTS fill_blank_answers;
CREATE TABLE fill_blank_answers (
    answer_id   CHAR(36)     NOT NULL DEFAULT (UUID()),
    question_id CHAR(36)     NOT NULL,
    answer_text VARCHAR(255) NOT NULL,
    PRIMARY KEY (answer_id),
    KEY idx_fb_answers_question (question_id),
    CONSTRAINT fk_fb_answers_question
        FOREIGN KEY (question_id) REFERENCES fill_blank_questions (question_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- DragDropQuestion.draggables : List<DragItem>
DROP TABLE IF EXISTS drag_items;
CREATE TABLE drag_items (
    drag_item_id CHAR(36)     NOT NULL DEFAULT (UUID()),
    question_id  CHAR(36)     NOT NULL,
    label        VARCHAR(255) NOT NULL,
    PRIMARY KEY (drag_item_id),
    KEY idx_drag_items_question (question_id),
    CONSTRAINT fk_drag_items_question
        FOREIGN KEY (question_id) REFERENCES questions (question_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- DragDropQuestion.dropZones : List<DropZone>
DROP TABLE IF EXISTS drop_zones;
CREATE TABLE drop_zones (
    drop_zone_id CHAR(36)     NOT NULL DEFAULT (UUID()),
    question_id  CHAR(36)     NOT NULL,
    label        VARCHAR(255) NOT NULL,
    PRIMARY KEY (drop_zone_id),
    KEY idx_drop_zones_question (question_id),
    CONSTRAINT fk_drop_zones_question
        FOREIGN KEY (question_id) REFERENCES questions (question_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- DragDropQuestion.correctPairings : Map<draggableId, dropZoneId>
DROP TABLE IF EXISTS drag_drop_pairings;
CREATE TABLE drag_drop_pairings (
    question_id  CHAR(36) NOT NULL,
    drag_item_id CHAR(36) NOT NULL,
    drop_zone_id CHAR(36) NOT NULL,
    PRIMARY KEY (question_id, drag_item_id),
    CONSTRAINT fk_pairings_question
        FOREIGN KEY (question_id) REFERENCES questions (question_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_pairings_drag_item
        FOREIGN KEY (drag_item_id) REFERENCES drag_items (drag_item_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_pairings_drop_zone
        FOREIGN KEY (drop_zone_id) REFERENCES drop_zones (drop_zone_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================================================
-- 5. STUDENT PROGRESS  (UserProgress and its composed records)
-- ============================================================================

-- UserProgress 1:1 Student
DROP TABLE IF EXISTS user_progress;
CREATE TABLE user_progress (
    student_id     CHAR(36) NOT NULL,
    total_xp       INT      NOT NULL DEFAULT 0,
    level           INT      NOT NULL DEFAULT 1,
    current_streak INT      NOT NULL DEFAULT 0,
    PRIMARY KEY (student_id),
    CONSTRAINT fk_user_progress_student
        FOREIGN KEY (student_id) REFERENCES students (student_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- CourseEnrollment <<record>>: Map<courseId, CourseEnrollment> on UserProgress
DROP TABLE IF EXISTS course_enrollments;
CREATE TABLE course_enrollments (
    student_id   CHAR(36) NOT NULL,
    course_id    CHAR(36) NOT NULL,
    enrolled_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME NULL,
    PRIMARY KEY (student_id, course_id),
    CONSTRAINT fk_enrollments_student
        FOREIGN KEY (student_id) REFERENCES students (student_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_enrollments_course
        FOREIGN KEY (course_id) REFERENCES courses (course_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ChapterProgress <<record>>: Map<chapterId, ChapterProgress> on UserProgress
DROP TABLE IF EXISTS chapter_progress;
CREATE TABLE chapter_progress (
    student_id        CHAR(36) NOT NULL,
    chapter_id        CHAR(36) NOT NULL,
    completed_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    time_spent_secs   INT      NOT NULL DEFAULT 0,
    PRIMARY KEY (student_id, chapter_id),
    CONSTRAINT fk_chap_progress_student
        FOREIGN KEY (student_id) REFERENCES students (student_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_chap_progress_chapter
        FOREIGN KEY (chapter_id) REFERENCES chapters (chapter_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- QuizAttempt <<record>>: Map<quizId, QuizAttempt> on UserProgress
-- Modeled as "latest attempt only" — re-attempting a quiz UPSERTs this row.
DROP TABLE IF EXISTS quiz_attempts;
CREATE TABLE quiz_attempts (
    student_id   CHAR(36) NOT NULL,
    quiz_id      CHAR(36) NOT NULL,
    score        INT      NOT NULL,
    completed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (student_id, quiz_id),
    CONSTRAINT fk_quiz_attempts_student
        FOREIGN KEY (student_id) REFERENCES students (student_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_quiz_attempts_quiz
        FOREIGN KEY (quiz_id) REFERENCES quizzes (quiz_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================================================
-- 6. ADMIN REPORTING  (ReportMetric, generated snapshots)
-- ============================================================================

DROP TABLE IF EXISTS report_metrics;
CREATE TABLE report_metrics (
    report_id                       CHAR(36) NOT NULL DEFAULT (UUID()),
    admin_id                        CHAR(36) NOT NULL,
    generated_at                    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    daily_active_users              INT      NOT NULL DEFAULT 0,
    weekly_active_users             INT      NOT NULL DEFAULT 0,
    monthly_active_users            INT      NOT NULL DEFAULT 0,
    dau_mau_ratio                   FLOAT    NOT NULL DEFAULT 0,
    retention_rate                  FLOAT    NOT NULL DEFAULT 0,
    churn_rate                      FLOAT    NOT NULL DEFAULT 0,
    avg_session_duration_secs       FLOAT    NOT NULL DEFAULT 0,
    avg_weekly_user_sessions        FLOAT    NOT NULL DEFAULT 0,
    total_learning_time_secs        BIGINT   NOT NULL DEFAULT 0,
    avg_lesson_before_dropout       FLOAT    NOT NULL DEFAULT 0,
    -- Loosely structured time-series fields: stored as JSON for flexibility
    registration_trend              JSON,
    active_time_heatmap             JSON,
    PRIMARY KEY (report_id),
    KEY idx_report_metrics_admin (admin_id),
    CONSTRAINT fk_report_metrics_admin
        FOREIGN KEY (admin_id) REFERENCES admins (admin_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- lessonCompletionRate / lessonDropoutRate / averageCompletionTime
-- (all Map<Lesson/Module, value>) collapsed into one per-module-per-report row
DROP TABLE IF EXISTS report_module_metrics;
CREATE TABLE report_module_metrics (
    report_id                CHAR(36) NOT NULL,
    module_id                CHAR(36) NOT NULL,
    completion_rate          FLOAT    NOT NULL DEFAULT 0,
    dropout_rate             FLOAT    NOT NULL DEFAULT 0,
    avg_completion_time_secs INT      NOT NULL DEFAULT 0,
    PRIMARY KEY (report_id, module_id),
    CONSTRAINT fk_report_module_report
        FOREIGN KEY (report_id) REFERENCES report_metrics (report_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_report_module_module
        FOREIGN KEY (module_id) REFERENCES learning_modules (module_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- coursePopularity : List<(Course, int)>
DROP TABLE IF EXISTS report_course_popularity;
CREATE TABLE report_course_popularity (
    report_id        CHAR(36) NOT NULL,
    course_id        CHAR(36) NOT NULL,
    popularity_count INT      NOT NULL DEFAULT 0,
    PRIMARY KEY (report_id, course_id),
    CONSTRAINT fk_report_pop_report
        FOREIGN KEY (report_id) REFERENCES report_metrics (report_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_report_pop_course
        FOREIGN KEY (course_id) REFERENCES courses (course_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

SET FOREIGN_KEY_CHECKS = 1;

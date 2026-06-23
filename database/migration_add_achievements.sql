-- Migration to add achievements functionality
-- 1. Add the icon column to the achievements table
ALTER TABLE achievements ADD COLUMN icon VARCHAR(50) NOT NULL DEFAULT 'bi-star-fill';

-- 2. Populate the achievements table with default achievements
INSERT INTO achievements (achievement_id, title, category, requirement, icon) VALUES
('ach-1', 'First Steps',     'General', 'Complete your first lesson',     'bi-flag-fill'),
('ach-2', 'Quiz Whiz',       'Quiz',    'Pass 5 quizzes',                 'bi-patch-check-fill'),
('ach-3', 'On Fire',         'Streak',  'Reach a 7-day quiz streak',      'bi-fire'),
('ach-4', 'Scholar',         'XP',      'Earn 1,000 XP',                  'bi-mortarboard-fill'),
('ach-5', 'Course Champion', 'Course',  'Finish a full course',           'bi-trophy-fill'),
('ach-6', 'Perfectionist',   'Quiz',    'Score 100% on a quiz',           'bi-star-fill'),
('ach-7', 'Marathoner',      'Streak',  'Reach a 30-day quiz streak',     'bi-calendar-check-fill'),
('ach-8', 'Polymath',        'Course',  'Enroll in 3 categories',         'bi-stars')
ON DUPLICATE KEY UPDATE title=VALUES(title), category=VALUES(category), requirement=VALUES(requirement), icon=VALUES(icon);

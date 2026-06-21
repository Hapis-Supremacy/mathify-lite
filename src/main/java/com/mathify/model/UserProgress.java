package com.mathify.model;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/** Tracks all of a single student's learning progress, XP, streak and achievements. */
public class UserProgress {

    /** An unlocked achievement together with when it was earned. */
    public record AchievementUnlock(Achievement achievement, LocalDateTime unlockedAt) {
    }

    private final String studentId;
    private int totalXP;
    private int level;
    private int currentStreak;
    private final Map<String, CourseEnrollment> courseEnrollments = new HashMap<>();
    private final Map<String, ChapterProgress> chapterProgress = new HashMap<>();
    private final Map<String, QuizAttempt> quizAttempts = new HashMap<>();
    private final List<AchievementUnlock> achievements = new ArrayList<>();

    public UserProgress(String studentId) {
        this.studentId = studentId;
    }

    public String getStudentId() {
        return studentId;
    }

    public int getTotalXP() {
        return totalXP;
    }

    public int getLevel() {
        return level;
    }

    public void addXP(int xp) {
        this.totalXP += xp;
    }

    public void addLevel(int levels) {
        this.level += levels;
    }

    public int getCurrentStreak() {
        return currentStreak;
    }

    public void addStreak(int days) {
        this.currentStreak += days;
    }

    public void resetStreak() {
        this.currentStreak = 0;
    }

    // ---- courses ----
    public void enrollCourse(String courseId) {
        courseEnrollments.putIfAbsent(courseId, new CourseEnrollment(courseId, LocalDateTime.now(), null));
    }

    public void completeCourse(String courseId) {
        CourseEnrollment existing = courseEnrollments.get(courseId);
        LocalDateTime enrolledAt = existing != null ? existing.enrolledAt() : LocalDateTime.now();
        courseEnrollments.put(courseId, new CourseEnrollment(courseId, enrolledAt, LocalDateTime.now()));
    }

    public boolean hasCompletedCourse(String courseId) {
        CourseEnrollment e = courseEnrollments.get(courseId);
        return e != null && e.isCompleted();
    }

    public Optional<CourseEnrollment> getCourseEnrollment(String courseId) {
        return Optional.ofNullable(courseEnrollments.get(courseId));
    }

    // ---- chapters ----
    public void completeChapter(String chapterId, Duration timeSpent) {
        chapterProgress.put(chapterId, new ChapterProgress(chapterId, LocalDateTime.now(), timeSpent));
    }

    public boolean hasCompletedChapter(String chapterId) {
        return chapterProgress.containsKey(chapterId);
    }

    public Optional<ChapterProgress> getChapterProgress(String chapterId) {
        return Optional.ofNullable(chapterProgress.get(chapterId));
    }

    // ---- quizzes ----
    public void recordQuizAttempt(QuizAttempt attempt) {
        quizAttempts.put(attempt.quizId(), attempt);
    }

    public boolean hasAttemptedQuiz(String quizId) {
        return quizAttempts.containsKey(quizId);
    }

    public Optional<QuizAttempt> getQuizAttempt(String quizId) {
        return Optional.ofNullable(quizAttempts.get(quizId));
    }

    public boolean hasPassedQuiz(String quizId, int passingScore) {
        QuizAttempt a = quizAttempts.get(quizId);
        return a != null && a.isPassed(passingScore);
    }

    // ---- aggregates ----
    public long countCompletedCourses() {
        return courseEnrollments.values().stream().filter(CourseEnrollment::isCompleted).count();
    }

    public double averageQuizScore() {
        return quizAttempts.values().stream().mapToInt(QuizAttempt::score).average().orElse(0.0);
    }

    // ---- achievements ----
    public void completeAchievement(String achievementId) {
        if (!hasAchievement(achievementId)) {
            Achievement a = new Achievement();
            a.setId(achievementId);
            achievements.add(new AchievementUnlock(a, LocalDateTime.now()));
        }
    }

    public boolean hasAchievement(String achievementId) {
        return achievements.stream().anyMatch(u -> achievementId.equals(u.achievement().getId()));
    }

    public List<AchievementUnlock> getAchievements() {
        return achievements;
    }
}

package com.mathify.model;

/**
 * Lightweight DTO carrying a single course's enrollment count and its
 * relative popularity percentage (for progress-bar width on the admin
 * dashboard).
 */
public class CoursePopularityDTO {
    private String courseName;
    private int learnerCount;
    /** 0-100 — relative to the most-popular course (which gets 100%). */
    private int progressPercent;

    public CoursePopularityDTO() {}

    public CoursePopularityDTO(String courseName, int learnerCount, int progressPercent) {
        this.courseName = courseName;
        this.learnerCount = learnerCount;
        this.progressPercent = progressPercent;
    }

    public String getCourseName() { return courseName; }
    public void setCourseName(String courseName) { this.courseName = courseName; }

    public int getLearnerCount() { return learnerCount; }
    public void setLearnerCount(int learnerCount) { this.learnerCount = learnerCount; }

    public int getProgressPercent() { return progressPercent; }
    public void setProgressPercent(int progressPercent) { this.progressPercent = progressPercent; }
}

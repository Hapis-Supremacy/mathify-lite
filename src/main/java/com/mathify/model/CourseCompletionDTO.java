package com.mathify.model;

/**
 * Lightweight DTO carrying a single course's lesson-completion rate for
 * the admin dashboard.
 */
public class CourseCompletionDTO {
    private String courseName;
    /** 0-100 — percentage of enrolled students who completed the course. */
    private int completionPercent;

    public CourseCompletionDTO() {}

    public CourseCompletionDTO(String courseName, int completionPercent) {
        this.courseName = courseName;
        this.completionPercent = completionPercent;
    }

    public String getCourseName() { return courseName; }
    public void setCourseName(String courseName) { this.courseName = courseName; }

    public int getCompletionPercent() { return completionPercent; }
    public void setCompletionPercent(int completionPercent) { this.completionPercent = completionPercent; }
}

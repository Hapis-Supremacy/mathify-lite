package com.mathify.model;

import java.time.LocalDateTime;

/** Records that a student enrolled in a course, and when they finished it. */
public record CourseEnrollment(String courseId, LocalDateTime enrolledAt, LocalDateTime completedAt) {

    public boolean isCompleted() {
        return completedAt != null;
    }
}

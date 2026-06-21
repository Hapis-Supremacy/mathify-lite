package com.mathify.model;

import java.time.Duration;
import java.time.LocalDateTime;

/** Records a student's completion of a chapter. */
public record ChapterProgress(String chapterId, LocalDateTime completedAt, Duration timeSpent) {
}

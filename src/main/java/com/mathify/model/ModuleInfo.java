package com.mathify.model;

import java.time.LocalDateTime;

/** Shared identity/metadata for every {@link LearningModule}. */
public record ModuleInfo(String id, String title, int orderIndex, LocalDateTime createdAt, int xpReward) {
}

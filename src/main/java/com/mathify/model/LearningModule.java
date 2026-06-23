package com.mathify.model;

import java.time.Duration;
import java.time.LocalDateTime;

/** A unit of learning content within a {@link Chapter} (a video or slide deck). */
public interface LearningModule {

    String getId();

    String getTitle();

    int getOrderIndex();

    LocalDateTime getCreatedAt();

    ModuleType getType();

    Duration estimatedDuration();

    int getXpReward();
}

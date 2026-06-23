package com.mathify.model;

import java.time.Duration;
import java.time.LocalDateTime;

/** A video lesson. */
public final class VideoModule implements LearningModule {

    private final ModuleInfo info;
    private final String videoUrl;
    private final Duration duration;
    private final String thumbnailUrl;

    public VideoModule(ModuleInfo info, String videoUrl, Duration duration, String thumbnailUrl) {
        this.info = info;
        this.videoUrl = videoUrl;
        this.duration = duration;
        this.thumbnailUrl = thumbnailUrl;
    }

    public ModuleInfo getInfo() {
        return info;
    }

    @Override
    public String getId() {
        return info.id();
    }

    @Override
    public String getTitle() {
        return info.title();
    }

    @Override
    public int getOrderIndex() {
        return info.orderIndex();
    }

    @Override
    public LocalDateTime getCreatedAt() {
        return info.createdAt();
    }

    @Override
    public ModuleType getType() {
        return ModuleType.VIDEO;
    }

    @Override
    public Duration estimatedDuration() {
        return duration;
    }

    @Override
    public int getXpReward() {
        return info.xpReward();
    }

    public String getVideoUrl() {
        return videoUrl;
    }

    public String getThumbnailUrl() {
        return thumbnailUrl;
    }
}

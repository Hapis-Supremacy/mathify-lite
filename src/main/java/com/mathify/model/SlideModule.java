package com.mathify.model;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;

/** A slide-deck lesson. */
public final class SlideModule implements LearningModule {

    private final ModuleInfo info;
    private final List<Slide> slides;
    private final int secondsPerSlide;

    public SlideModule(ModuleInfo info, List<Slide> slides, int secondsPerSlide) {
        this.info = info;
        this.slides = slides;
        this.secondsPerSlide = secondsPerSlide;
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
        return ModuleType.SLIDE;
    }

    @Override
    public Duration estimatedDuration() {
        return Duration.ofSeconds((long) secondsPerSlide * slides.size());
    }

    @Override
    public int getXpReward() {
        return info.xpReward();
    }

    public List<Slide> getSlides() {
        return slides;
    }

    public int getSecondsPerSlide() {
        return secondsPerSlide;
    }
}

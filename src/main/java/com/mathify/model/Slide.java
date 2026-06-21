package com.mathify.model;

/** A single slide within a {@link SlideModule}. */
public record Slide(int order, String imageUrl, String caption) {
}

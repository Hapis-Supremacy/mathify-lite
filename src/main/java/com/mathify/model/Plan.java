package com.mathify.model;

/** A subscription plan a {@link Subscribable} can be switched to. */
public record Plan(String name, double pricePerMonth) {
}

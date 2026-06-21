package com.mathify.model;

/** Shared identity/metadata for every {@link Question}. */
public record QuestionInfo(String id, String prompt, int points) {
}

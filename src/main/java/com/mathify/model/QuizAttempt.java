package com.mathify.model;

import java.time.LocalDateTime;

/** A single attempt at a quiz, with the score achieved. */
public record QuizAttempt(String quizId, int score, LocalDateTime completedAt) {

    public boolean isPassed(int passingScore) {
        return score >= passingScore;
    }
}

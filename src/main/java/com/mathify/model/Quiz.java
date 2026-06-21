package com.mathify.model;

import java.util.ArrayList;
import java.util.List;

/** A graded set of questions attached to a {@link Chapter}. */
public class Quiz {

    private String quizId;
    private String title;
    private List<Question> questions = new ArrayList<>();
    private int passingScore;

    public Quiz() {
    }

    public Quiz(String quizId, String title, List<Question> questions, int passingScore) {
        this.quizId = quizId;
        this.title = title;
        this.questions = questions;
        this.passingScore = passingScore;
    }

    /** Sum of the points across all questions. */
    public int totalPoints() {
        return questions.stream().mapToInt(Question::getPoints).sum();
    }

    public String getQuizId() {
        return quizId;
    }

    public void setQuizId(String quizId) {
        this.quizId = quizId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public List<Question> getQuestions() {
        return questions;
    }

    public void setQuestions(List<Question> questions) {
        this.questions = questions;
    }

    public int getPassingScore() {
        return passingScore;
    }

    public void setPassingScore(int passingScore) {
        this.passingScore = passingScore;
    }
}

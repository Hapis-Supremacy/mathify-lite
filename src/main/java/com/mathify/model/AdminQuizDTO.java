package com.mathify.model;

/** Raw quiz row plus its question count, for the admin content editor. */
public class AdminQuizDTO {
    private String quizId;
    private String title;
    private int passingScore;
    private int questionCount;

    public AdminQuizDTO() {}

    public String getQuizId() { return quizId; }
    public void setQuizId(String quizId) { this.quizId = quizId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public int getPassingScore() { return passingScore; }
    public void setPassingScore(int passingScore) { this.passingScore = passingScore; }

    public int getQuestionCount() { return questionCount; }
    public void setQuestionCount(int questionCount) { this.questionCount = questionCount; }
}

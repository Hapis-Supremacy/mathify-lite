package com.mathify.model;

import java.util.ArrayList;
import java.util.List;

/** A chapter groups learning modules and quizzes inside a {@link Course}. */
public class Chapter {

    private String chapterId;
    private String title;
    private String description;
    private int xpReward;
    private List<LearningModule> modules = new ArrayList<>();
    private List<Quiz> quizzes = new ArrayList<>();
    private List<Chapter> prerequisite = new ArrayList<>();

    public Chapter() {
    }

    public Chapter(String title, String description) {
        this.title = title;
        this.description = description;
    }

    public String getChapterId() {
        return chapterId;
    }

    public void setChapterId(String chapterId) {
        this.chapterId = chapterId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getXpReward() {
        return xpReward;
    }

    public void setXpReward(int xpReward) {
        this.xpReward = xpReward;
    }

    public List<LearningModule> getModules() {
        return modules;
    }

    public void setModules(List<LearningModule> modules) {
        this.modules = modules;
    }

    public List<Quiz> getQuizzes() {
        return quizzes;
    }

    public void setQuizzes(List<Quiz> quizzes) {
        this.quizzes = quizzes;
    }

    public List<Chapter> getPrerequisite() {
        return prerequisite;
    }

    public void setPrerequisite(List<Chapter> prerequisite) {
        this.prerequisite = prerequisite;
    }
}

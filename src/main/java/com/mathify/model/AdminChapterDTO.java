package com.mathify.model;

import java.util.ArrayList;
import java.util.List;

/** A chapter with its modules and quizzes, shaped for the admin content editor. */
public class AdminChapterDTO {
    private String chapterId;
    private String title;
    private String description;
    private int xpReward;
    private int orderIndex;
    private List<AdminModuleDTO> modules = new ArrayList<>();
    private List<AdminQuizDTO> quizzes = new ArrayList<>();

    public AdminChapterDTO() {}

    public String getChapterId() { return chapterId; }
    public void setChapterId(String chapterId) { this.chapterId = chapterId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public int getXpReward() { return xpReward; }
    public void setXpReward(int xpReward) { this.xpReward = xpReward; }

    public int getOrderIndex() { return orderIndex; }
    public void setOrderIndex(int orderIndex) { this.orderIndex = orderIndex; }

    public List<AdminModuleDTO> getModules() { return modules; }
    public void setModules(List<AdminModuleDTO> modules) { this.modules = modules; }

    public List<AdminQuizDTO> getQuizzes() { return quizzes; }
    public void setQuizzes(List<AdminQuizDTO> quizzes) { this.quizzes = quizzes; }
}

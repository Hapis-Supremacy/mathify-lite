package com.mathify.model;

/** A badge a student can unlock by meeting a requirement. */
public class Achievement {

    private String achievementId;
    private String title;
    private String category;
    private String requirement;
    private String icon;

    public Achievement() {
    }

    public Achievement(String achievementId, String title, String category, String requirement, String icon) {
        this.achievementId = achievementId;
        this.title = title;
        this.category = category;
        this.requirement = requirement;
        this.icon = icon;
    }

    public String getId() {
        return achievementId;
    }

    public void setId(String achievementId) {
        this.achievementId = achievementId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getRequirement() {
        return requirement;
    }

    public void setRequirement(String requirement) {
        this.requirement = requirement;
    }

    public String getIcon() {
        return icon;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }
}

package com.mathify.model;

/**
 * Raw learning-module row for the admin content editor. Unlike
 * {@link LearningModule}, this preserves the exact stored columns
 * (content_url, duration_secs, slide_count) so the edit form is accurate.
 */
public class AdminModuleDTO {
    private String moduleId;
    private String title;
    private String moduleType; // "VIDEO" or "SLIDE"
    private String contentUrl;
    private Integer durationSecs; // VIDEO only
    private Integer slideCount;   // SLIDE only
    private int orderIndex;

    public AdminModuleDTO() {}

    public String getModuleId() { return moduleId; }
    public void setModuleId(String moduleId) { this.moduleId = moduleId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getModuleType() { return moduleType; }
    public void setModuleType(String moduleType) { this.moduleType = moduleType; }

    public String getContentUrl() { return contentUrl; }
    public void setContentUrl(String contentUrl) { this.contentUrl = contentUrl; }

    public Integer getDurationSecs() { return durationSecs; }
    public void setDurationSecs(Integer durationSecs) { this.durationSecs = durationSecs; }

    public Integer getSlideCount() { return slideCount; }
    public void setSlideCount(Integer slideCount) { this.slideCount = slideCount; }

    public int getOrderIndex() { return orderIndex; }
    public void setOrderIndex(int orderIndex) { this.orderIndex = orderIndex; }
}

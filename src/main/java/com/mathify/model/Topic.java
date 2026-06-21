package com.mathify.model;

/**
 * A content topic an {@link Admin} can manage. Referenced by the diagram's
 * Admin operations (createTopic/editTopic/deleteTopic) without its own detailed
 * shape, so modelled here as a minimal identified entity.
 */
public class Topic {

    private String topicId;
    private String title;

    public Topic() {
    }

    public Topic(String topicId, String title) {
        this.topicId = topicId;
        this.title = title;
    }

    public String getTopicId() {
        return topicId;
    }

    public void setTopicId(String topicId) {
        this.topicId = topicId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }
}

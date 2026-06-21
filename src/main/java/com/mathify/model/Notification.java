package com.mathify.model;

import java.util.Date;

/** A message sent to a {@link User} (streak reminders, XP boosts, etc.). */
public class Notification {

    /** The category of a notification. */
    public enum Type {
        STREAK_REMINDER,
        XP_BOOST,
        LESSON_REMINDER,
        ACHIEVEMENT_UNLOCKED
    }

    private String notificationId;
    private Type type;
    private Date sentAt;
    private boolean isRead;
    private String message;

    public Notification() {
    }

    public Notification(String notificationId, Type type, String message, Date sentAt) {
        this.notificationId = notificationId;
        this.type = type;
        this.message = message;
        this.sentAt = sentAt;
    }

    public void markAsRead() {
        this.isRead = true;
    }

    public String getNotification() {
        return message;
    }

    public String getNotificationId() {
        return notificationId;
    }

    public Type getType() {
        return type;
    }

    public Date getSentAt() {
        return sentAt;
    }

    public boolean isRead() {
        return isRead;
    }
}

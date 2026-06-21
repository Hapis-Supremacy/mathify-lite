package com.mathify.model;

import java.util.ArrayList;
import java.util.List;

/** Base type for every account holder (a {@link Student} or an {@link Admin}). */
public abstract class User {

    protected String userId;
    protected String name;
    protected String email;
    protected String passwordHash;
    protected final List<Notification> notifications = new ArrayList<>();

    /** Returns true if the supplied plain-text password matches the stored hash. */
    public boolean login(String email, String password) {
        return this.email != null && this.email.equals(email)
                && this.passwordHash != null && this.passwordHash.equals(hash(password));
    }

    public void logout() {
        // Session teardown handled by the web layer; no in-model state to clear.
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    /** Hashes then stores the password. */
    public void setPassword(String password) {
        this.passwordHash = hash(password);
    }

    /** Stores a pre-hashed value directly (used when loading from the database). */
    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public List<Notification> getNotifications() {
        return notifications;
    }

    /** SHA-256 hex digest. Not as strong as bcrypt but far better than hashCode(). */
    public static String hash(String password) {
        if (password == null) return null;
        try {
            java.security.MessageDigest md = java.security.MessageDigest.getInstance("SHA-256");
            byte[] digest = md.digest(password.getBytes(java.nio.charset.StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(64);
            for (byte b : digest) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (java.security.NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 unavailable", e);
        }
    }
}

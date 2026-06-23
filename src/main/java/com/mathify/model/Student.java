package com.mathify.model;

import java.util.Date;

/** A learner account. Holds a subscription, progress and an energy balance. */
public class Student extends User {

    private String studentId;
    private Subscribable subscription;
    private UserProgress progress;
    private int energy;
    private int maxEnergy = 5;
    private long energyRenewalEpochMillis;

    public Student() {
    }

    public Student(String studentId) {
        this.studentId = studentId;
        this.progress = new UserProgress(studentId);
    }

    /** Upgrade this student to a premium subscription. */
    public void goPremium() {
        this.subscription = new PremiumStudent("Premium", new Date(System.currentTimeMillis() + 30L * 24 * 60 * 60 * 1000));
    }

    public void addEnergy(int amount) {
        this.energy += amount;
    }

    public void removeEnergy(int amount) {
        this.energy = Math.max(0, this.energy - amount);
    }

    public String getStudentId() {
        return studentId;
    }

    public void setStudentId(String studentId) {
        this.studentId = studentId;
    }

    public Subscribable getSubscription() {
        return subscription;
    }

    public void setSubscription(Subscribable subscription) {
        this.subscription = subscription;
    }

    public boolean isPremiumActive() {
        return subscription != null && subscription.isActive();
    }

    public UserProgress getProgress() {
        return progress;
    }

    public void setProgress(UserProgress progress) {
        this.progress = progress;
    }

    public int getEnergy() {
        return energy;
    }

    public void setEnergy(int energy) {
        this.energy = energy;
    }

    public int getMaxEnergy() {
        return maxEnergy;
    }

    public void setMaxEnergy(int maxEnergy) {
        this.maxEnergy = maxEnergy;
    }

    public long getEnergyRenewalEpochMillis() {
        return energyRenewalEpochMillis;
    }

    public void setEnergyRenewalEpochMillis(long energyRenewalEpochMillis) {
        this.energyRenewalEpochMillis = energyRenewalEpochMillis;
    }
}

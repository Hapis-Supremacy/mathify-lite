package com.mathify.model;

import java.util.Date;

/** A paid subscription backing a {@link Student} (implements {@link Subscribable}). */
public class PremiumStudent implements Subscribable {

    private String subscriptionPlan;
    private Date subscriptionExpiry;
    private boolean isCanceled;

    public PremiumStudent(String plan, Date expiry) {
        this.subscriptionPlan = plan;
        this.subscriptionExpiry = expiry;
    }

    @Override
    public void extendSubscription(Date expiry) {
        this.subscriptionExpiry = expiry;
        this.isCanceled = false;
    }

    @Override
    public boolean isActive() {
        return !isCanceled && subscriptionExpiry != null && subscriptionExpiry.after(new Date());
    }

    @Override
    public void changePlan(Plan plan) {
        this.subscriptionPlan = plan.name();
    }

    @Override
    public String getSubscriptionPlan() {
        return subscriptionPlan;
    }

    @Override
    public Date subscriptionExpiry() {
        return subscriptionExpiry;
    }

    @Override
    public void cancelSubscription() {
        this.isCanceled = true;
    }
}

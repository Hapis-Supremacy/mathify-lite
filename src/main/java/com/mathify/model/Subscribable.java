package com.mathify.model;

import java.util.Date;

/** A subscription a {@link Student} holds; implemented by {@link PremiumStudent}. */
public interface Subscribable {

    void extendSubscription(Date expiry);

    boolean isActive();

    void changePlan(Plan plan);

    String getSubscriptionPlan();

    Date subscriptionExpiry();

    void cancelSubscription();
}

package com.mathify.util;

import static org.junit.Assert.assertEquals;

import org.junit.After;
import org.junit.Test;

/**
 * Unit tests for {@link MidtransConfig}. To stay independent of any local
 * {@code .env} file, these drive config via JVM system properties, which
 * {@code MidtransConfig.get} consults before the {@code .env} file. Each test
 * cleans up the properties it sets.
 */
public class MidtransConfigTest {

    private static final String PROD = "MIDTRANS_IS_PRODUCTION";
    private static final String PRICE_MONTHLY = "MIDTRANS_PRICE_MONTHLY";
    private static final String PRICE_YEARLY = "MIDTRANS_PRICE_YEARLY";

    @After
    public void clearProps() {
        System.clearProperty(PROD);
        System.clearProperty(PRICE_MONTHLY);
        System.clearProperty(PRICE_YEARLY);
    }

    @Test
    public void productionToggleSelectsLiveHosts() {
        System.setProperty(PROD, "true");
        assertEquals("https://app.midtrans.com", MidtransConfig.snapBaseUrl());
        assertEquals("https://api.midtrans.com", MidtransConfig.apiBaseUrl());
        assertEquals("https://app.midtrans.com/snap/snap.js", MidtransConfig.snapJsUrl());
    }

    @Test
    public void sandboxIsTheDefaultEnvironment() {
        System.setProperty(PROD, "false");
        assertEquals("https://app.sandbox.midtrans.com", MidtransConfig.snapBaseUrl());
        assertEquals("https://api.sandbox.midtrans.com", MidtransConfig.apiBaseUrl());
        assertEquals("https://app.sandbox.midtrans.com/snap/snap.js", MidtransConfig.snapJsUrl());
    }

    @Test
    public void pricesAreParsedFromConfig() {
        System.setProperty(PRICE_MONTHLY, "99000");
        System.setProperty(PRICE_YEARLY, "990000");
        assertEquals(99_000L, MidtransConfig.getMonthlyPriceIdr());
        assertEquals(990_000L, MidtransConfig.getYearlyPriceIdr());
    }

    @Test
    public void invalidPriceFallsBackToDefault() {
        System.setProperty(PRICE_MONTHLY, "not-a-number");
        // Invalid input must fall back to the in-code default, not throw.
        assertEquals(125_500L, MidtransConfig.getMonthlyPriceIdr());
    }
}

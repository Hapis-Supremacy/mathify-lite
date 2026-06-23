package com.mathify.util;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Reads Midtrans payment credentials. Resolution order for each key:
 * <ol>
 *   <li>OS environment variable (e.g. {@code MIDTRANS_SERVER_KEY})</li>
 *   <li>JVM system property of the same name</li>
 *   <li>{@code .env} file at the project root (searched upward from the
 *       working directory)</li>
 * </ol>
 *
 * The {@code .env} file is gitignored; never hard-code keys here.
 */
public final class MidtransConfig {

    private static final Map<String, String> DOT_ENV = loadDotEnv();

    private MidtransConfig() {
    }

    private static Map<String, String> loadDotEnv() {
        Map<String, String> values = new HashMap<>();
        Path envFile = findDotEnv();
        if (envFile == null) {
            return values;
        }
        try {
            List<String> lines = Files.readAllLines(envFile, StandardCharsets.UTF_8);
            for (String raw : lines) {
                String line = raw.trim();
                if (line.isEmpty() || line.startsWith("#")) {
                    continue;
                }
                int eq = line.indexOf('=');
                if (eq <= 0) {
                    continue;
                }
                String key = line.substring(0, eq).trim();
                String value = line.substring(eq + 1).trim();
                if (value.length() >= 2
                        && ((value.startsWith("\"") && value.endsWith("\""))
                         || (value.startsWith("'") && value.endsWith("'")))) {
                    value = value.substring(1, value.length() - 1);
                }
                values.put(key, value);
            }
        } catch (IOException e) {
            throw new UncheckedIOException("Failed to read .env at " + envFile, e);
        }
        return values;
    }

    /** Walk up from the working directory looking for a {@code .env} file. */
    private static Path findDotEnv() {
        Path dir = Paths.get(System.getProperty("user.dir", ".")).toAbsolutePath();
        for (int i = 0; i < 6 && dir != null; i++) {
            Path candidate = dir.resolve(".env");
            if (Files.isRegularFile(candidate)) {
                return candidate;
            }
            dir = dir.getParent();
        }
        return null;
    }

    /** Looks up a key across env vars, system properties, then the .env file. */
    private static String get(String key, String fallback) {
        String v = System.getenv(key);
        if (v == null || v.isBlank()) {
            v = System.getProperty(key);
        }
        if (v == null || v.isBlank()) {
            v = DOT_ENV.get(key);
        }
        return (v == null || v.isBlank()) ? fallback : v.trim();
    }

    public static String getServerKey() {
        return get("MIDTRANS_SERVER_KEY", "");
    }

    public static String getClientKey() {
        return get("MIDTRANS_CLIENT_KEY", "");
    }

    public static String getMerchantId() {
        return get("MIDTRANS_MERCHANT_ID", "");
    }

    public static boolean isProduction() {
        return Boolean.parseBoolean(get("MIDTRANS_IS_PRODUCTION", "false"));
    }

    /** Monthly premium price in whole IDR (Midtrans requires integer amounts). */
    public static long getMonthlyPriceIdr() {
        return getLong("MIDTRANS_PRICE_MONTHLY", 125_500L);
    }

    /** Yearly premium price in whole IDR (Midtrans requires integer amounts). */
    public static long getYearlyPriceIdr() {
        return getLong("MIDTRANS_PRICE_YEARLY", 1_224_500L);
    }

    /** Parses a whole-number config value, falling back on missing/invalid input. */
    private static long getLong(String key, long fallback) {
        try {
            return Long.parseLong(get(key, Long.toString(fallback)));
        } catch (NumberFormatException e) {
            return fallback;
        }
    }

    /** True only when a server key is present (i.e. payments can be attempted). */
    public static boolean isConfigured() {
        return !getServerKey().isBlank();
    }

    /** Base host for the Snap transaction API and the Snap.js script. */
    public static String snapBaseUrl() {
        return isProduction() ? "https://app.midtrans.com" : "https://app.sandbox.midtrans.com";
    }

    /** Base host for the Core API (used for transaction status checks). */
    public static String apiBaseUrl() {
        return isProduction() ? "https://api.midtrans.com" : "https://api.sandbox.midtrans.com";
    }

    /** Full URL of the Snap.js front-end script for the active environment. */
    public static String snapJsUrl() {
        return snapBaseUrl() + "/snap/snap.js";
    }
}

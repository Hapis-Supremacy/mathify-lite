package com.mathify.service;

import com.mathify.util.MidtransConfig;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Base64;

/**
 * Thin client for the Midtrans Snap + Core APIs.
 *
 * <p>Snap flow: {@link #createSnapTransaction} asks Midtrans for a one-time
 * payment token (server-to-server, authenticated with the Server Key). The
 * browser then opens the Snap popup with that token. After payment we call
 * {@link #getTransactionStatus} to verify the outcome before granting premium —
 * the client is never trusted to report its own success.
 */
public class MidtransService {

    /** Outcome of a Snap token request. */
    public record SnapTransaction(String token, String redirectUrl) {
    }

    /** A subset of a Core API transaction-status response. */
    public record TransactionStatus(String orderId, String transactionStatus, String fraudStatus) {
        /** True when the payment has fully cleared and premium may be granted. */
        public boolean isPaid() {
            if ("settlement".equalsIgnoreCase(transactionStatus)) {
                return true;
            }
            // "capture" is only final for card payments once fraud review accepts it.
            return "capture".equalsIgnoreCase(transactionStatus)
                    && (fraudStatus == null || "accept".equalsIgnoreCase(fraudStatus));
        }

        public boolean isPending() {
            return "pending".equalsIgnoreCase(transactionStatus);
        }
    }

    /** Raised when Midtrans returns a non-success response. */
    public static class MidtransException extends Exception {
        public MidtransException(String message) {
            super(message);
        }
    }

    private final HttpClient http = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(15))
            .build();

    /**
     * Creates a Snap transaction and returns its token.
     *
     * @param orderId      unique merchant order id (max 50 chars, [A-Za-z0-9-_])
     * @param grossAmount  amount in whole IDR
     * @param customerName customer display name
     * @param customerEmail customer email
     * @param itemName     line-item label shown in the Snap UI
     * @param finishUrl    URL Snap redirects to after a redirect-based payment
     */
    public SnapTransaction createSnapTransaction(String orderId, long grossAmount,
                                                 String customerName, String customerEmail,
                                                 String itemName, String finishUrl)
            throws MidtransException {

        JSONObject txnDetails = new JSONObject()
                .put("order_id", orderId)
                .put("gross_amount", grossAmount);

        JSONObject item = new JSONObject()
                .put("id", "premium-plan")
                .put("price", grossAmount)
                .put("quantity", 1)
                .put("name", itemName);

        JSONObject customer = new JSONObject()
                .put("first_name", customerName == null ? "" : customerName)
                .put("email", customerEmail == null ? "" : customerEmail);

        JSONObject body = new JSONObject()
                .put("transaction_details", txnDetails)
                .put("item_details", new JSONArray().put(item))
                .put("customer_details", customer);

        if (finishUrl != null && !finishUrl.isBlank()) {
            body.put("callbacks", new JSONObject().put("finish", finishUrl));
        }

        HttpResponse<String> resp = send(
                "POST", MidtransConfig.snapBaseUrl() + "/snap/v1/transactions", body.toString());

        JSONObject json = parse(resp.body());
        if (resp.statusCode() / 100 != 2) {
            throw new MidtransException(errorMessage(json, resp.statusCode()));
        }
        return new SnapTransaction(json.optString("token", null), json.optString("redirect_url", null));
    }

    /** Fetches the current status of a transaction by order id. */
    public TransactionStatus getTransactionStatus(String orderId) throws MidtransException {
        HttpResponse<String> resp = send(
                "GET", MidtransConfig.apiBaseUrl() + "/v2/" + orderId + "/status", null);

        JSONObject json = parse(resp.body());
        // 404 means Midtrans has no record of the order (e.g. user never paid).
        if (resp.statusCode() == 404) {
            return new TransactionStatus(orderId, "not_found", null);
        }
        if (resp.statusCode() / 100 != 2) {
            throw new MidtransException(errorMessage(json, resp.statusCode()));
        }
        return new TransactionStatus(
                json.optString("order_id", orderId),
                json.optString("transaction_status", ""),
                json.optString("fraud_status", null));
    }

    private HttpResponse<String> send(String method, String url, String jsonBody)
            throws MidtransException {
        String auth = Base64.getEncoder()
                .encodeToString((MidtransConfig.getServerKey() + ":").getBytes(StandardCharsets.UTF_8));

        HttpRequest.Builder builder = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .timeout(Duration.ofSeconds(30))
                .header("Accept", "application/json")
                .header("Content-Type", "application/json")
                .header("Authorization", "Basic " + auth);

        if ("POST".equals(method)) {
            builder.POST(HttpRequest.BodyPublishers.ofString(
                    jsonBody == null ? "{}" : jsonBody, StandardCharsets.UTF_8));
        } else {
            builder.GET();
        }

        try {
            return http.send(builder.build(), HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
        } catch (IOException e) {
            throw new MidtransException("Could not reach Midtrans: " + e.getMessage());
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new MidtransException("Interrupted while contacting Midtrans");
        }
    }

    private static JSONObject parse(String body) {
        if (body == null || body.isBlank()) {
            return new JSONObject();
        }
        try {
            return new JSONObject(body);
        } catch (RuntimeException e) {
            return new JSONObject();
        }
    }

    private static String errorMessage(JSONObject json, int status) {
        if (json.has("error_messages")) {
            JSONArray arr = json.optJSONArray("error_messages");
            if (arr != null && !arr.isEmpty()) {
                return String.join("; ", arr.toList().stream().map(String::valueOf).toList());
            }
        }
        String sm = json.optString("status_message", "");
        return sm.isBlank() ? ("Midtrans request failed (HTTP " + status + ")") : sm;
    }
}

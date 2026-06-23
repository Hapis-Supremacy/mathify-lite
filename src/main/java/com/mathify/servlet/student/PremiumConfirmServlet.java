package com.mathify.servlet.student;

import com.mathify.dao.SubscriptionDAO;
import com.mathify.service.MidtransService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import org.json.JSONObject;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;

/**
 * Verifies the outcome of a Snap payment against Midtrans and, only if the
 * transaction has genuinely cleared, grants the student premium. The browser's
 * {@code onSuccess} callback is never trusted on its own - we re-check the
 * status server-to-server using the order id we issued at checkout.
 *
 * <p>POST /student/premium/confirm.do?orderId=... - protected by the filter.
 */
@WebServlet("/student/premium/confirm.do")
public class PremiumConfirmServlet extends HttpServlet {

    private static final int DEFAULT_PREMIUM_DAYS = 30;

    private final MidtransService midtrans = new MidtransService();
    private final SubscriptionDAO subscriptionDAO = new SubscriptionDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        String userId = session == null ? null : (String) session.getAttribute("userId");
        if (userId == null) {
            writeError(resp, HttpServletResponse.SC_UNAUTHORIZED, "Please log in again.");
            return;
        }

        String orderId = req.getParameter("orderId");
        String pendingOrderId = (String) session.getAttribute("pendingOrderId");
        String plan = (String) session.getAttribute("pendingPlan");

        // The order id must match the one we issued for this session.
        if (orderId == null || pendingOrderId == null || !pendingOrderId.equals(orderId)) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "Unknown or stale order.");
            return;
        }

        try {
            MidtransService.TransactionStatus status = midtrans.getTransactionStatus(orderId);

            if (status.isPaid()) {
                Object daysAttr = session.getAttribute("pendingPlanDays");
                int days = (daysAttr instanceof Integer) ? (Integer) daysAttr : DEFAULT_PREMIUM_DAYS;
                LocalDate expiry = subscriptionDAO.activatePremium(
                        userId, plan == null ? "Premium" : plan, days,
                        orderId, status.transactionStatus());
                session.removeAttribute("pendingOrderId");
                session.removeAttribute("pendingPlan");
                session.removeAttribute("pendingPlanDays");

                JSONObject out = new JSONObject()
                        .put("status", "paid")
                        .put("expiry", expiry.toString())
                        .put("redirect", req.getContextPath() + "/student/premium.jsp?payment=success");
                resp.getWriter().write(out.toString());
                return;
            }

            String state = status.isPending() ? "pending" : "failed";
            resp.getWriter().write(new JSONObject()
                    .put("status", state)
                    .put("transactionStatus", status.transactionStatus())
                    .toString());

        } catch (SQLException e) {
            getServletContext().log("Confirm DB error", e);
            writeError(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Server error.");
        } catch (MidtransService.MidtransException e) {
            getServletContext().log("Midtrans status check failed", e);
            writeError(resp, HttpServletResponse.SC_BAD_GATEWAY,
                    "Could not verify payment: " + e.getMessage());
        }
    }

    private static void writeError(HttpServletResponse resp, int status, String message)
            throws IOException {
        resp.setStatus(status);
        resp.getWriter().write(new JSONObject().put("error", message).toString());
    }
}

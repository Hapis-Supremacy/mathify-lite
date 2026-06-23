package com.mathify.servlet.student;

import com.mathify.dao.UserDAO;
import com.mathify.model.Student;
import com.mathify.service.MidtransService;
import com.mathify.util.MidtransConfig;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import org.json.JSONObject;

import java.io.IOException;
import java.security.SecureRandom;
import java.sql.SQLException;

/**
 * Creates a Midtrans Snap transaction for the Premium plan and returns the Snap
 * token to the browser as JSON. The amount is fixed server-side; the client
 * cannot influence what it is charged.
 *
 * <p>POST /student/premium/checkout.do — protected by {@code StudentAuthFilter}.
 */
@WebServlet("/student/premium/checkout.do")
public class PremiumCheckoutServlet extends HttpServlet {

    private static final SecureRandom RANDOM = new SecureRandom();

    private final UserDAO userDAO = new UserDAO();
    private final MidtransService midtrans = new MidtransService();

    /** A selectable premium plan: display label, charge amount (IDR), duration. */
    private record PremiumPlan(String label, long amountIdr, int days) {}

    /** Resolves the requested plan; defaults to Monthly for anything unknown. */
    private static PremiumPlan resolvePlan(String key) {
        if ("yearly".equalsIgnoreCase(key)) {
            return new PremiumPlan("Premium Yearly", MidtransConfig.getYearlyPriceIdr(), 365);
        }
        return new PremiumPlan("Premium Monthly", MidtransConfig.getMonthlyPriceIdr(), 30);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        if (!MidtransConfig.isConfigured()) {
            writeError(resp, HttpServletResponse.SC_SERVICE_UNAVAILABLE,
                    "Payments are not configured. Set MIDTRANS_SERVER_KEY in .env.");
            return;
        }

        HttpSession session = req.getSession(false);
        String userId = session == null ? null : (String) session.getAttribute("userId");
        if (userId == null) {
            writeError(resp, HttpServletResponse.SC_UNAUTHORIZED, "Please log in again.");
            return;
        }

        try {
            Student student = userDAO.getStudentById(userId);
            if (student == null) {
                writeError(resp, HttpServletResponse.SC_UNAUTHORIZED, "Account not found.");
                return;
            }

            PremiumPlan plan = resolvePlan(req.getParameter("plan"));
            String orderId = "MF-PREM-" + System.currentTimeMillis() + "-"
                    + Integer.toHexString(RANDOM.nextInt(0x10000));
            String finishUrl = absoluteUrl(req, "/student/premium.jsp?payment=finish");

            MidtransService.SnapTransaction txn = midtrans.createSnapTransaction(
                    orderId, plan.amountIdr(), student.getName(), student.getEmail(),
                    "Mathify " + plan.label(), finishUrl);

            // Remember what we created so confirm.do can validate + grant correctly.
            session.setAttribute("pendingOrderId", orderId);
            session.setAttribute("pendingPlan", plan.label());
            session.setAttribute("pendingPlanDays", plan.days());

            JSONObject out = new JSONObject()
                    .put("token", txn.token())
                    .put("clientKey", MidtransConfig.getClientKey())
                    .put("snapJsUrl", MidtransConfig.snapJsUrl());
            resp.getWriter().write(out.toString());

        } catch (SQLException e) {
            getServletContext().log("Checkout DB error", e);
            writeError(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Server error.");
        } catch (MidtransService.MidtransException e) {
            getServletContext().log("Midtrans checkout failed", e);
            writeError(resp, HttpServletResponse.SC_BAD_GATEWAY,
                    "Could not start payment: " + e.getMessage());
        }
    }

    private static String absoluteUrl(HttpServletRequest req, String path) {
        String scheme = req.getScheme();
        int port = req.getServerPort();
        StringBuilder url = new StringBuilder(scheme).append("://").append(req.getServerName());
        boolean defaultPort = ("http".equals(scheme) && port == 80)
                || ("https".equals(scheme) && port == 443);
        if (!defaultPort) {
            url.append(':').append(port);
        }
        return url.append(req.getContextPath()).append(path).toString();
    }

    private static void writeError(HttpServletResponse resp, int status, String message)
            throws IOException {
        resp.setStatus(status);
        resp.getWriter().write(new JSONObject().put("error", message).toString());
    }
}

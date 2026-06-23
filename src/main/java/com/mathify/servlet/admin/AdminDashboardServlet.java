package com.mathify.servlet.admin;

import com.mathify.dao.AdminDashboardDAO;
import com.mathify.model.CourseCompletionDTO;
import com.mathify.model.CoursePopularityDTO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Populates admin dashboard metrics from the database and forwards to
 * the JSP view. All heavy lifting is in {@link AdminDashboardDAO}.
 */
@WebServlet("/admin/dashboard.do")
public class AdminDashboardServlet extends HttpServlet {

    private final AdminDashboardDAO dashboardDAO = new AdminDashboardDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            // ---- top-level stat cards ----
            int dau = dashboardDAO.getDailyActiveUsers();
            int wau = dashboardDAO.getWeeklyActiveUsers();
            int mau = dashboardDAO.getMonthlyActiveUsers();
            int prevDau = dashboardDAO.getPreviousDailyActiveUsers();
            int prevWau = dashboardDAO.getPreviousWeeklyActiveUsers();

            // DAU / MAU stickiness ratio
            int dauMauRatio = (mau > 0)
                ? Math.round((float) dau / mau * 100f)
                : 0;

            // Retention
            float retention = dashboardDAO.getRetentionRate();
            float prevRetention = dashboardDAO.getPreviousRetentionRate();

            // Week-over-week deltas
            req.setAttribute("dailyActive", dau);
            setDelta(req, "dailyActiveDelta", "dailyActiveDeltaColor", dau, prevDau);

            req.setAttribute("weeklyActive", wau);
            setDelta(req, "weeklyActiveDelta", "weeklyActiveDeltaColor", wau, prevWau);

            req.setAttribute("dauMauRatio", dauMauRatio);

            req.setAttribute("retentionRate", Math.round(retention));
            setDelta(req, "retentionDelta", "retentionDeltaColor",
                     retention, prevRetention);

            // ---- progress-bar cards ----
            List<CoursePopularityDTO> popularity = dashboardDAO.getCoursePopularity();
            req.setAttribute("coursePopularity", popularity);

            List<CourseCompletionDTO> completionRates = dashboardDAO.getCourseCompletionRates();
            req.setAttribute("courseCompletionRates", completionRates);

            req.getRequestDispatcher("/admin/dashboard.jsp").forward(req, resp);

        } catch (SQLException e) {
            getServletContext().log("DB error loading admin dashboard", e);
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard.jsp?error=server_error");
        }
    }

    // ---- helpers --------------------------------------------------------

    /**
     * Computes a percentage-change delta between two int values and sets
     * the text (e.g. "up 6.2%") and colour request attributes.
     */
    private void setDelta(HttpServletRequest req,
                          String textAttr, String colorAttr,
                          int current, int previous) {
        if (previous == 0 && current == 0) {
            req.setAttribute(textAttr, "-");
            req.setAttribute(colorAttr, "#6b7686");
            return;
        }
        if (previous == 0) {
            req.setAttribute(textAttr, "\u2191 new");
            req.setAttribute(colorAttr, "#1d8a5b");
            return;
        }
        float pctChange = ((float) (current - previous) / previous) * 100f;
        formatDelta(req, textAttr, colorAttr, pctChange);
    }

    /** Overload for float values (retention). */
    private void setDelta(HttpServletRequest req,
                          String textAttr, String colorAttr,
                          float current, float previous) {
        if (previous == 0f && current == 0f) {
            req.setAttribute(textAttr, "-");
            req.setAttribute(colorAttr, "#6b7686");
            return;
        }
        if (previous == 0f) {
            req.setAttribute(textAttr, "\u2191 new");
            req.setAttribute(colorAttr, "#1d8a5b");
            return;
        }
        float pctChange = ((current - previous) / previous) * 100f;
        formatDelta(req, textAttr, colorAttr, pctChange);
    }

    private void formatDelta(HttpServletRequest req,
                             String textAttr, String colorAttr,
                             float pctChange) {
        String formatted = String.format("%.1f%%", Math.abs(pctChange));
        if (pctChange > 0) {
            req.setAttribute(textAttr, "\u2191 " + formatted);
            req.setAttribute(colorAttr, "#1d8a5b");
        } else if (pctChange < 0) {
            req.setAttribute(textAttr, "\u2193 " + formatted);
            req.setAttribute(colorAttr, "#c0392b");
        } else {
            req.setAttribute(textAttr, "- 0%");
            req.setAttribute(colorAttr, "#6b7686");
        }
    }
}

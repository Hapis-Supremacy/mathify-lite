package com.mathify.servlet.student;

import com.mathify.dao.ProgressDAO;
import com.mathify.dao.SubscriptionDAO;
import com.mathify.dao.UserDAO;
import com.mathify.model.Student;
import com.mathify.model.UserProgress;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import org.json.JSONObject;

import java.io.IOException;
import java.sql.SQLException;

/**
 * Returns the logged-in student's live header data as JSON so the shared navbar
 * (assets/js/app.js) can show the real premium badge, energy, streak and XP
 * instead of the hard-coded sample values.
 *
 * <p>GET /student/profile.do — protected by {@code StudentAuthFilter}.
 */
@WebServlet("/student/profile.do")
public class StudentProfileServlet extends HttpServlet {

    /** Free-tier daily energy cap shown as "n/MAX" in the navbar. */
    private static final int ENERGY_MAX = 5;

    private final UserDAO userDAO = new UserDAO();
    private final ProgressDAO progressDAO = new ProgressDAO();
    private final SubscriptionDAO subscriptionDAO = new SubscriptionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        String userId = session == null ? null : (String) session.getAttribute("userId");
        if (userId == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().write(new JSONObject().put("error", "Not authenticated").toString());
            return;
        }

        try {
            Student student = userDAO.getStudentById(userId);
            if (student == null) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                resp.getWriter().write(new JSONObject().put("error", "Account not found").toString());
                return;
            }

            UserProgress progress = progressDAO.getUserProgress(userId);
            SubscriptionDAO.SubscriptionInfo sub = subscriptionDAO.getByStudentId(userId);
            boolean premium = sub != null && sub.isActive();

            JSONObject out = new JSONObject()
                    .put("name", student.getName())
                    .put("premium", premium)
                    .put("energy", student.getEnergy())
                    .put("energyMax", ENERGY_MAX)
                    .put("streak", progress.getCurrentStreak())
                    .put("level", progress.getLevel())
                    .put("totalXp", progress.getTotalXP());
            resp.getWriter().write(out.toString());

        } catch (SQLException e) {
            getServletContext().log("Profile lookup failed", e);
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write(new JSONObject().put("error", "Server error").toString());
        }
    }
}

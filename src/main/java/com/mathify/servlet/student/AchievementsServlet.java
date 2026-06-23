package com.mathify.servlet.student;

import com.mathify.dao.ProgressDAO;
import com.mathify.model.Achievement;
import com.mathify.model.UserProgress;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/student/achievements.do")
public class AchievementsServlet extends HttpServlet {

    private final ProgressDAO progressDAO = new ProgressDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        String studentId = (String) session.getAttribute("userId");

        try {
            // Reconcile progress (triggers achievement unlock checks) then
            // reload a fresh UserProgress so newly-unlocked badges are reflected.
            progressDAO.reconcileUserXP(studentId);
            UserProgress freshProgress = progressDAO.getUserProgress(studentId);
            req.setAttribute("globalProgress", freshProgress);

            List<Achievement> allAchievements = progressDAO.getAllAchievements();
            req.setAttribute("allAchievements", allAchievements);

            req.getRequestDispatcher("/student/achievements.jsp").forward(req, resp);
        } catch (SQLException e) {
            getServletContext().log("Error loading achievements", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
        }
    }
}

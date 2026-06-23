package com.mathify.servlet.student;

import com.mathify.dao.ProgressDAO;
import com.mathify.model.Achievement;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/student/achievements.do")
public class AchievementsServlet extends HttpServlet {

    private final ProgressDAO progressDAO = new ProgressDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            List<Achievement> allAchievements = progressDAO.getAllAchievements();
            req.setAttribute("allAchievements", allAchievements);
            req.getRequestDispatcher("/student/achievements.jsp").forward(req, resp);
        } catch (SQLException e) {
            getServletContext().log("Error loading achievements", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
        }
    }
}

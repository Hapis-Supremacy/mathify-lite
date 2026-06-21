package com.mathify.servlet.student;

import com.mathify.dao.ProgressDAO;
import com.mathify.dao.UserDAO;
import com.mathify.model.Student;
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

@WebServlet("/student/dashboard.do")
public class StudentDashboardServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final ProgressDAO progressDAO = new ProgressDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        String userId = (String) session.getAttribute("userId");
        String role = (String) session.getAttribute("userRole");

        try {
            Student student = userDAO.getStudentById(userId);
            if (student == null) {
                resp.sendRedirect(req.getContextPath() + "/login.jsp");
                return;
            }

            UserProgress progress = progressDAO.getUserProgress(userId);
            int completedCount = progressDAO.getCompletedCoursesCount(userId);
            List<ProgressDAO.EnrolledCourse> recentCourses = progressDAO.getRecentEnrollments(userId);

            req.setAttribute("student", student);
            req.setAttribute("progress", progress);
            req.setAttribute("completedCount", completedCount);
            req.setAttribute("recentCourses", recentCourses);

            req.getRequestDispatcher("/student/dashboard.jsp").forward(req, resp);
            
        } catch (SQLException e) {
            getServletContext().log("Error loading dashboard", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
        }
    }
}

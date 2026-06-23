package com.mathify.servlet.admin;

import com.mathify.dao.CourseDAO;
import com.mathify.model.Quiz;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

/** Renders the quiz editor for adding/managing questions. */
@WebServlet("/admin/quiz-editor.do")
public class AdminQuizEditorServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String quizId = req.getParameter("q");
        String courseId = req.getParameter("c"); // Passed along for the back button

        if (quizId == null || quizId.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/courses.do");
            return;
        }

        try {
            Quiz quiz = courseDAO.getQuizById(quizId);
            if (quiz == null) {
                resp.sendRedirect(req.getContextPath() + "/admin/courses.do?error=not_found");
                return;
            }
            req.setAttribute("quiz", quiz);
            req.setAttribute("courseId", courseId);
            req.setAttribute("quizEditorLoaded", true);
            req.getRequestDispatcher("/admin/quiz-editor.jsp").forward(req, resp);
        } catch (SQLException e) {
            getServletContext().log("DB error loading quiz editor", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading quiz.");
        }
    }
}

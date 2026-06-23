package com.mathify.servlet.student;

import com.mathify.dao.CourseDAO;
import com.mathify.model.Chapter;
import com.mathify.model.Course;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/student/course.do")
public class CourseDetailServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String courseId = req.getParameter("id");
        if (courseId == null || courseId.isEmpty()) {
            com.mathify.util.NavigationUtil.redirectWithLoading(req, resp, req.getContextPath() + "/student/catalog.do", "Returning to catalog...");
            return;
        }

        try {
            Course course = courseDAO.getCourseById(courseId);
            if (course == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Course not found");
                return;
            }

            for (Chapter chapter : course.getChapters()) {
                courseDAO.loadChapterContent(chapter);
            }

            req.setAttribute("course", course);
            
            // Fetch completed chapters for the Selesai pill
            String studentId = (String) req.getSession().getAttribute("userId");
            if (studentId != null) {
                com.mathify.dao.ProgressDAO progressDAO = new com.mathify.dao.ProgressDAO();
                java.util.Set<String> completedChapters = progressDAO.getCompletedChapters(studentId, courseId);
                req.setAttribute("completedChapters", completedChapters);
                
                java.util.Set<String> completedModules = progressDAO.getCompletedModules(studentId, courseId);
                req.setAttribute("completedModules", completedModules);

                java.util.Set<String> completedQuizzes = progressDAO.getCompletedQuizzes(studentId, courseId);
                req.setAttribute("completedQuizzes", completedQuizzes);

                java.util.Map<String, Integer> quizScores = progressDAO.getQuizScoresForCourse(studentId, courseId);
                req.setAttribute("quizScores", quizScores);
            }

            moveFlash(req, "flashQuizId");
            moveFlash(req, "flashQuizXp");
            moveFlash(req, "flashChapterId");
            moveFlash(req, "flashChapterXp");

            req.getRequestDispatcher("/student/course.jsp").forward(req, resp);
        } catch (SQLException e) {
            getServletContext().log("Error fetching course details", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
        }
    }

    private void moveFlash(HttpServletRequest req, String name) {
        Object value = req.getSession().getAttribute(name);
        if (value != null) {
            req.setAttribute(name, value);
            req.getSession().removeAttribute(name);
        }
    }
}

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
            resp.sendRedirect("catalog.do");
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
            req.getRequestDispatcher("/student/course.jsp").forward(req, resp);
        } catch (SQLException e) {
            getServletContext().log("Error fetching course details", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
        }
    }
}

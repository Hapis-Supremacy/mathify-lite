package com.mathify.servlet.student;

import com.mathify.dao.CourseDAO;
import com.mathify.model.Course;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/student/catalog.do")
public class CourseCatalogServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            List<Course> courses = courseDAO.getAllCourses();
            req.setAttribute("courses", courses);
            req.getRequestDispatcher("/student/catalog.jsp").forward(req, resp);
        } catch (SQLException e) {
            getServletContext().log("Error fetching courses", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
        }
    }
}

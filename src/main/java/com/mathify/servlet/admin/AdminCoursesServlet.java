package com.mathify.servlet.admin;

import com.mathify.dao.CourseDAO;
import com.mathify.model.AdminCourseDTO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/admin/courses.do")
public class AdminCoursesServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            List<AdminCourseDTO> courses = courseDAO.getCourseSummaries();
            req.setAttribute("courses", courses);
            req.setAttribute("coursesLoaded", true);
            req.getRequestDispatcher("/admin/courses.jsp").forward(req, resp);
        } catch (SQLException e) {
            getServletContext().log("DB error fetching admin courses list", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading courses.");
        }
    }
}

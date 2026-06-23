package com.mathify.servlet.student;

import com.mathify.dao.CourseDAO;
import com.mathify.model.LearningModule;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/student/module.do")
public class ModuleDetailServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String moduleId = req.getParameter("m");
        if (moduleId == null || moduleId.isEmpty()) {
            com.mathify.util.NavigationUtil.redirectWithLoading(req, resp, req.getContextPath() + "/student/catalog.do", "Returning to catalog...");
            return;
        }

        try {
            LearningModule module = courseDAO.getModuleById(moduleId);
            if (module == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Module not found");
                return;
            }

            req.setAttribute("module", module);
            String courseId = courseDAO.getCourseIdForModule(moduleId);
            req.setAttribute("courseId", courseId);
            req.getRequestDispatcher("/student/module.jsp").forward(req, resp);
        } catch (SQLException e) {
            getServletContext().log("Error fetching module details", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
        }
    }
}

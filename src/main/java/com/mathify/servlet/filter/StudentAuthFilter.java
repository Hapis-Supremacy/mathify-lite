package com.mathify.servlet.filter;

import com.mathify.dao.UserDAO;
import com.mathify.model.Admin;
import com.mathify.model.Student;
import com.mathify.util.AuthUtil;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

@WebFilter("/student/*")
public class StudentAuthFilter implements Filter {

    private final UserDAO userDAO = new UserDAO();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
            
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        // 1. Check if user already has an active session
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("userId") != null) {
            String role = (String) session.getAttribute("userRole");
            if ("STUDENT".equals(role)) {
                try {
                    String sid = (String) session.getAttribute("userId");
                    Student globalStudent = userDAO.getStudentById(sid);
                    
                    // If student no longer exists in the DB (e.g. DB was wiped), invalidate the stale session
                    if (globalStudent == null) {
                        session.invalidate();
                        AuthUtil.clearAuthCookie(resp);
                        resp.sendRedirect(req.getContextPath() + "/login.jsp?error=session_expired");
                        return;
                    }

                    com.mathify.dao.ProgressDAO pDao = new com.mathify.dao.ProgressDAO();
                    com.mathify.model.UserProgress globalProgress = pDao.getUserProgress(sid);
                    req.setAttribute("globalStudent", globalStudent);
                    req.setAttribute("globalProgress", globalProgress);
                } catch (Exception e) {
                    req.getServletContext().log("Failed to load global profile data", e);
                }
                chain.doFilter(request, response);
                return;
            } else if ("ADMIN".equals(role)) {
                // Redirect admin to admin dashboard if they try to access student routes
                com.mathify.util.NavigationUtil.redirectWithLoading(req, resp, req.getContextPath() + "/admin/dashboard.jsp", "Redirecting to admin dashboard...");
                return;
            }
        }

        // 2. No session, check for the persistent auth cookie
        String token = AuthUtil.getAuthCookieValue(req);
        if (token != null) {
            String userId = AuthUtil.validateToken(token);
            if (userId != null) {
                try {
                    // 3. Validate user exists in DB
                    Admin admin = userDAO.getAdminById(userId);
                    if (admin != null) {
                        session = req.getSession(true);
                        session.setAttribute("userId", admin.getUserId());
                        session.setAttribute("userName", admin.getName());
                        session.setAttribute("userRole", "ADMIN");
                        com.mathify.util.NavigationUtil.redirectWithLoading(req, resp, req.getContextPath() + "/admin/dashboard.jsp", "Redirecting to admin dashboard...");
                        return;
                    }
                    
                    Student student = userDAO.getStudentById(userId);
                    if (student != null) {
                        session = req.getSession(true);
                        session.setAttribute("userId", student.getUserId());
                        session.setAttribute("userName", student.getName());
                        session.setAttribute("userRole", "STUDENT");
                        
                        try {
                            com.mathify.dao.ProgressDAO pDao = new com.mathify.dao.ProgressDAO();
                            com.mathify.model.UserProgress globalProgress = pDao.getUserProgress(userId);
                            req.setAttribute("globalStudent", student);
                            req.setAttribute("globalProgress", globalProgress);
                        } catch (Exception e) {}

                        chain.doFilter(request, response);
                        return;
                    }
                } catch (SQLException e) {
                    req.getServletContext().log("DB error during cookie auth", e);
                }
            }
        }

        // 5. If we reach here, there's no session and no valid cookie. Redirect to login.
        // Clear cookie just in case it was invalid.
        AuthUtil.clearAuthCookie(resp);
        com.mathify.util.NavigationUtil.redirectWithLoading(req, resp, req.getContextPath() + "/login.jsp", "Redirecting to login...");
    }
}

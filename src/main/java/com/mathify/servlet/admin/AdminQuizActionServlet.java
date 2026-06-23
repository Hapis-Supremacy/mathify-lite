package com.mathify.servlet.admin;

import com.mathify.dao.CourseDAO;
import com.mathify.model.MultipleChoiceQuestion;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@WebServlet("/admin/quiz-action.do")
public class AdminQuizActionServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        String quizId = req.getParameter("quizId");
        String courseId = req.getParameter("courseId");

        String redirectUrl = req.getContextPath() + "/admin/quiz-editor.do?q=" + quizId + "&c=" + courseId;

        if (action == null) {
            resp.sendRedirect(redirectUrl);
            return;
        }

        try {
            switch (action) {
                case "create_question" -> handleCreateQuestion(req);
                case "delete_question" -> courseDAO.deleteQuestion(req.getParameter("questionId"));
            }
        } catch (SQLException e) {
            getServletContext().log("Error executing quiz action: " + action, e);
            resp.sendRedirect(redirectUrl + "&error=server_error");
            return;
        }

        resp.sendRedirect(redirectUrl);
    }

    private void handleCreateQuestion(HttpServletRequest req) throws SQLException {
        String quizId = req.getParameter("quizId");
        String type = req.getParameter("qType");
        String prompt = req.getParameter("prompt");
        int points = parseInt(req.getParameter("points"), 10);
        int orderIndex = parseInt(req.getParameter("orderIndex"), 0);

        if ("MULTIPLE_CHOICE".equals(type)) {
            String[] optionTexts = req.getParameterValues("mcOptionText");
            String[] correctIndicesStr = req.getParameterValues("mcCorrectIndex");
            
            if (optionTexts == null || correctIndicesStr == null) return;
            
            Set<Integer> correctIndices = new HashSet<>();
            for (String idx : correctIndicesStr) {
                correctIndices.add(parseInt(idx, -1));
            }
            
            List<MultipleChoiceQuestion.Option> options = new ArrayList<>();
            Set<String> correctText = new HashSet<>();
            for (int i = 0; i < optionTexts.length; i++) {
                String text = optionTexts[i].trim();
                if (!text.isEmpty()) {
                    options.add(new MultipleChoiceQuestion.Option(UUID.randomUUID().toString(), text));
                    if (correctIndices.contains(i)) {
                        correctText.add(text);
                    }
                }
            }
            courseDAO.createMultipleChoiceQuestion(quizId, prompt, points, orderIndex, options, correctText);
            
        } else if ("FILL_BLANK".equals(type)) {
            boolean caseSensitive = "on".equals(req.getParameter("caseSensitive"));
            String[] answersParam = req.getParameterValues("fbAnswer");
            List<String> answers = new ArrayList<>();
            if (answersParam != null) {
                for (String ans : answersParam) {
                    if (!ans.trim().isEmpty()) answers.add(ans.trim());
                }
            }
            courseDAO.createFillBlankQuestion(quizId, prompt, points, orderIndex, caseSensitive, answers);
            
        } else if ("DRAG_AND_DROP".equals(type)) {
            String[] drags = req.getParameterValues("ddDrag");
            String[] drops = req.getParameterValues("ddDrop");
            Map<String, String> pairings = new HashMap<>();
            
            if (drags != null && drops != null && drags.length == drops.length) {
                for (int i = 0; i < drags.length; i++) {
                    String drag = drags[i].trim();
                    String drop = drops[i].trim();
                    if (!drag.isEmpty() && !drop.isEmpty()) {
                        pairings.put(drag, drop);
                    }
                }
            }
            courseDAO.createDragDropQuestion(quizId, prompt, points, orderIndex, pairings);
        }
    }

    private static int parseInt(String value, int fallback) {
        if (value == null || value.isBlank()) return fallback;
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return fallback;
        }
    }
}

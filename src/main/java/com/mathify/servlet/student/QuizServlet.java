package com.mathify.servlet.student;

import com.mathify.dao.CourseDAO;
import com.mathify.dao.ProgressDAO;
import com.mathify.dao.UserDAO;
import com.mathify.model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.*;

@WebServlet("/student/quiz.do")
public class QuizServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAO();
    private final UserDAO userDAO = new UserDAO();
    private final ProgressDAO progressDAO = new ProgressDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String qId = req.getParameter("q");
        HttpSession session = req.getSession();

        if (qId != null && !qId.isEmpty()) {
            // Start a new quiz session
            try {
                Quiz quiz = courseDAO.getQuizById(qId);
                if (quiz == null) {
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Quiz not found");
                    return;
                }
                String studentId = (String) session.getAttribute("userId");
                if (studentId != null) {
                    Student student = userDAO.getStudentById(studentId);
                    if (student != null && !student.isPremiumActive() && student.getEnergy() <= 0) {
                        clearQuizSession(session);
                        req.setAttribute("energyLocked", true);
                        req.setAttribute("lockedQuiz", quiz);
                        req.setAttribute("courseId", courseDAO.getCourseIdForChapter(quiz.getChapterId()));
                        req.setAttribute("globalStudent", student);
                        req.setAttribute("globalProgress", progressDAO.getUserProgress(studentId));
                        req.getRequestDispatcher("/student/quiz.jsp").forward(req, resp);
                        return;
                    }
                }
                session.setAttribute("currentQuiz", quiz);
                session.setAttribute("quizScore", 0);
                session.setAttribute("quizIndex", 0);
                session.setAttribute("quizAnswered", false);
                session.removeAttribute("quizFeedback");
                
                // Redirect to avoid resubmission issues and drop the q parameter
                resp.sendRedirect(req.getContextPath() + "/student/quiz.do");
                return;
            } catch (SQLException e) {
                getServletContext().log("Database error", e);
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                return;
            }
        }

        Quiz quiz = (Quiz) session.getAttribute("currentQuiz");
        if (quiz == null) {
            resp.sendRedirect(req.getContextPath() + "/student/catalog.do");
            return;
        }

        Integer currentIndex = (Integer) session.getAttribute("quizIndex");
        if (currentIndex == null) currentIndex = 0;

        if (currentIndex >= quiz.getQuestions().size()) {
            finishQuiz(req, resp, quiz);
            return;
        }

        Question currentQuestion = quiz.getQuestions().get(currentIndex);
        req.setAttribute("quiz", quiz);
        req.setAttribute("question", currentQuestion);
        req.setAttribute("currentIndex", currentIndex);
        req.setAttribute("totalQuestions", quiz.getQuestions().size());
        req.setAttribute("quizAnswered", Boolean.TRUE.equals(session.getAttribute("quizAnswered")));
        try {
            req.setAttribute("courseId", courseDAO.getCourseIdForChapter(quiz.getChapterId()));
        } catch (SQLException e) {
            getServletContext().log("Error resolving course for quiz", e);
        }
        
        req.getRequestDispatcher("/student/quiz.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        Quiz quiz = (Quiz) session.getAttribute("currentQuiz");
        Integer currentIndex = (Integer) session.getAttribute("quizIndex");

        if (quiz == null || currentIndex == null || currentIndex >= quiz.getQuestions().size()) {
            resp.sendRedirect(req.getContextPath() + "/student/catalog.do");
            return;
        }

        String action = req.getParameter("action");
        boolean answered = Boolean.TRUE.equals(session.getAttribute("quizAnswered"));

        if ("next".equals(action)) {
            if (answered) {
                session.setAttribute("quizIndex", currentIndex + 1);
                session.setAttribute("quizAnswered", false);
                session.removeAttribute("quizFeedback");
            }
            resp.sendRedirect(req.getContextPath() + "/student/quiz.do");
            return;
        }

        if (answered) {
            resp.sendRedirect(req.getContextPath() + "/student/quiz.do");
            return;
        }

        Question currentQuestion = quiz.getQuestions().get(currentIndex);
        Answer answer = parseAnswer(req, currentQuestion);

        boolean isCorrect = false;
        if (answer != null) {
            isCorrect = currentQuestion.evaluate(answer);
        }

        if (isCorrect) {
            Integer score = (Integer) session.getAttribute("quizScore");
            if (score == null) score = 0;
            session.setAttribute("quizScore", score + currentQuestion.getInfo().points());
        }

        session.setAttribute("quizFeedback", isCorrect ? "correct" : "incorrect");
        session.setAttribute("quizAnswered", true);

        resp.sendRedirect(req.getContextPath() + "/student/quiz.do");
    }

    private Answer parseAnswer(HttpServletRequest req, Question question) {
        if (question instanceof MultipleChoiceQuestion) {
            String[] selected = req.getParameterValues("mc_option");
            Set<String> selectedIds = new HashSet<>();
            if (selected != null) {
                selectedIds.addAll(Arrays.asList(selected));
            }
            return new MultipleChoiceAnswer(selectedIds);
        } else if (question instanceof FillBlankQuestion) {
            List<String> values = new ArrayList<>();
            int i = 0;
            while (req.getParameter("fb_answer_" + i) != null) {
                values.add(req.getParameter("fb_answer_" + i));
                i++;
            }
            return new FillBlankAnswer(values);
        } else if (question instanceof DragDropQuestion) {
            DragDropQuestion ddq = (DragDropQuestion) question;
            Map<String, String> pairings = new HashMap<>();
            for (DropZone zone : ddq.getDropZones()) {
                String draggedItemId = req.getParameter("dd_zone_" + zone.id());
                if (draggedItemId != null && !draggedItemId.isEmpty()) {
                    pairings.put(zone.id(), draggedItemId);
                }
            }
            return new DragAndDropAnswer(pairings);
        }
        return null;
    }

    private void finishQuiz(HttpServletRequest req, HttpServletResponse resp, Quiz quiz) throws ServletException, IOException {
        HttpSession session = req.getSession();
        Integer rawScore = (Integer) session.getAttribute("quizScore");
        if (rawScore == null) rawScore = 0;

        int totalPoints = quiz.totalPoints();
        int scorePercent = totalPoints > 0 ? (int) Math.round((rawScore * 100.0) / totalPoints) : 0;
        boolean passed = scorePercent >= quiz.getPassingScore();
        int quizXpReward = 0;
        boolean quizXpAwarded = false;
        String studentId = (String) session.getAttribute("userId");
        String courseId = null;

        try {
            courseId = courseDAO.getCourseIdForChapter(quiz.getChapterId());

            if (studentId != null) {
                Student student = userDAO.getStudentById(studentId);
                if (student == null) {
                    clearQuizSession(session);
                    resp.sendRedirect(req.getContextPath() + "/student/catalog.do");
                    return;
                }

                if (!student.isPremiumActive()) {
                    userDAO.decreaseEnergy(studentId, 1);
                }

                ProgressDAO.QuizProgressResult progressResult = progressDAO.recordQuizAttemptAndSyncXP(
                        studentId,
                        quiz.getQuizId(),
                        scorePercent
                );
                int quizXpDelta = progressResult.xpDelta();
                quizXpAwarded = quizXpDelta > 0;
                quizXpReward = Math.max(0, quizXpDelta);
                req.setAttribute("streakAwarded", progressResult.streakAwarded());
                req.setAttribute("currentStreak", progressResult.currentStreak());

                if (passed) {
                    if (quizXpAwarded) {
                        session.setAttribute("flashQuizId", quiz.getQuizId());
                        session.setAttribute("flashQuizXp", quizXpReward);
                    }

                    boolean chapterXpAwarded = progressDAO.completeChapterIfReady(studentId, quiz.getChapterId());
                    if (chapterXpAwarded) {
                        session.setAttribute("flashChapterId", quiz.getChapterId());
                        session.setAttribute("flashChapterXp", progressDAO.getChapterXpReward(quiz.getChapterId()));
                    }
                }

                req.setAttribute("globalStudent", userDAO.getStudentById(studentId));
                req.setAttribute("globalProgress", progressDAO.getUserProgress(studentId));
            }
        } catch (SQLException e) {
            getServletContext().log("Error updating quiz progress", e);
        }

        req.setAttribute("quiz", quiz);
        req.setAttribute("finalScore", rawScore);
        req.setAttribute("totalPoints", totalPoints);
        req.setAttribute("scorePercent", scorePercent);
        req.setAttribute("passed", passed);
        req.setAttribute("quizXpAwarded", quizXpAwarded);
        req.setAttribute("quizXpReward", quizXpReward);
        req.setAttribute("completed", true);
        req.setAttribute("courseId", courseId);
        req.getRequestDispatcher("/student/quiz.jsp").forward(req, resp);

        session.removeAttribute("currentQuiz");
        session.removeAttribute("quizIndex");
        session.removeAttribute("quizScore");
        session.removeAttribute("quizFeedback");
        session.removeAttribute("quizAnswered");
    }

    private void clearQuizSession(HttpSession session) {
        session.removeAttribute("currentQuiz");
        session.removeAttribute("quizIndex");
        session.removeAttribute("quizScore");
        session.removeAttribute("quizFeedback");
        session.removeAttribute("quizAnswered");
    }
}

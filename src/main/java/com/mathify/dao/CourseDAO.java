package com.mathify.dao;

import com.mathify.db.DBUtil;
import com.mathify.model.*;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class CourseDAO {

    public List<Course> getAllCourses() throws SQLException {
        List<Course> courses = new ArrayList<>();
        String sql = "SELECT course_id, title, description, category FROM courses ORDER BY created_at ASC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Course course = new Course();
                course.setCourseId(rs.getString("course_id"));
                course.setTitle(rs.getString("title"));
                course.setDescription(rs.getString("description"));
                course.setCategory(rs.getString("category"));
                courses.add(course);
            }
        }
        return courses;
    }

    public Course getCourseById(String courseId) throws SQLException {
        Course course = null;
        String sql = "SELECT course_id, title, description, category FROM courses WHERE course_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, courseId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    course = new Course();
                    course.setCourseId(rs.getString("course_id"));
                    course.setTitle(rs.getString("title"));
                    course.setDescription(rs.getString("description"));
                    course.setCategory(rs.getString("category"));
                }
            }
        }

        if (course != null) {
            course.setChapters(getChaptersForCourse(courseId));
        }

        return course;
    }

    public List<Chapter> getChaptersForCourse(String courseId) throws SQLException {
        List<Chapter> chapters = new ArrayList<>();
        String sql = "SELECT chapter_id, title, description, xp_reward, order_index FROM chapters WHERE course_id = ? ORDER BY order_index ASC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, courseId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Chapter chapter = new Chapter();
                    chapter.setChapterId(rs.getString("chapter_id"));
                    chapter.setTitle(rs.getString("title"));
                    chapter.setDescription(rs.getString("description"));
                    chapter.setXpReward(rs.getInt("xp_reward"));
                    chapters.add(chapter);
                }
            }
        }
        return chapters;
    }

    public void loadChapterContent(Chapter chapter) throws SQLException {
        chapter.setModules(getModulesForChapter(chapter.getChapterId()));
        chapter.setQuizzes(getQuizzesForChapter(chapter.getChapterId()));
    }

    private List<LearningModule> getModulesForChapter(String chapterId) throws SQLException {
        List<LearningModule> modules = new ArrayList<>();
        String sql = "SELECT module_id, title, order_index, module_type, content_url, duration_secs, slide_count, created_at " +
                     "FROM learning_modules WHERE chapter_id = ? ORDER BY order_index ASC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, chapterId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    String id = rs.getString("module_id");
                    String title = rs.getString("title");
                    int orderIndex = rs.getInt("order_index");
                    java.sql.Timestamp createdAtTs = rs.getTimestamp("created_at");
                    LocalDateTime createdAt = createdAtTs != null ? createdAtTs.toLocalDateTime() : LocalDateTime.now();

                    ModuleInfo info = new ModuleInfo(id, title, orderIndex, createdAt, 0);
                    String typeStr = rs.getString("module_type");

                    if ("VIDEO".equals(typeStr)) {
                        int durationSecs = rs.getInt("duration_secs");
                        String url = rs.getString("content_url");
                        modules.add(new VideoModule(info, url, Duration.ofSeconds(durationSecs), null));
                    } else if ("SLIDE".equals(typeStr)) {
                        int slideCount = rs.getInt("slide_count");
                        List<Slide> slides = new ArrayList<>();
                        for (int i = 0; i < slideCount; i++) {
                            slides.add(new Slide(i, "", "")); // mock slide
                        }
                        modules.add(new SlideModule(info, slides, 30));
                    }
                }
            }
        }
        return modules;
    }

    private List<Quiz> getQuizzesForChapter(String chapterId) throws SQLException {
        List<Quiz> quizzes = new ArrayList<>();
        String sql = "SELECT quiz_id, title, passing_score FROM quizzes WHERE chapter_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, chapterId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Quiz quiz = new Quiz();
                    quiz.setQuizId(rs.getString("quiz_id"));
                    quiz.setChapterId(chapterId);
                    quiz.setTitle(rs.getString("title"));
                    quiz.setPassingScore(rs.getInt("passing_score"));
                    
                    quiz.setQuestions(getQuestionsForQuiz(quiz.getQuizId()));
                    quizzes.add(quiz);
                }
            }
        }
        return quizzes;
    }

    public Quiz getQuizById(String quizId) throws SQLException {
        Quiz quiz = null;
        String sql = "SELECT quiz_id, chapter_id, title, passing_score FROM quizzes WHERE quiz_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, quizId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    quiz = new Quiz();
                    quiz.setQuizId(rs.getString("quiz_id"));
                    quiz.setChapterId(rs.getString("chapter_id"));
                    quiz.setTitle(rs.getString("title"));
                    quiz.setPassingScore(rs.getInt("passing_score"));
                }
            }
        }
        if (quiz != null) {
            quiz.setQuestions(getQuestionsForQuiz(quizId));
        }
        return quiz;
    }

    private List<Question> getQuestionsForQuiz(String quizId) throws SQLException {
        List<Question> questions = new ArrayList<>();
        String sql = "SELECT question_id, prompt, points, question_type, order_index FROM questions WHERE quiz_id = ? ORDER BY order_index ASC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, quizId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    String qId = rs.getString("question_id");
                    String prompt = rs.getString("prompt");
                    int points = rs.getInt("points");
                    int orderIndex = rs.getInt("order_index");
                    String type = rs.getString("question_type");
                    
                    QuestionInfo info = new QuestionInfo(qId, prompt, points);

                    QuestionType questionType;
                    try {
                        questionType = QuestionType.valueOf(type.trim());
                    } catch (IllegalArgumentException | NullPointerException e) {
                        throw new SQLException("Unsupported question type for question " + qId + ": " + type, e);
                    }

                    switch (questionType) {
                        case MULTIPLE_CHOICE -> questions.add(getMultipleChoiceQuestion(conn, info));
                        case FILL_BLANK -> questions.add(getFillBlankQuestion(conn, info));
                        case DRAG_AND_DROP -> questions.add(getDragDropQuestion(conn, info));
                    }
                }
            }
        }
        return questions;
    }

    private MultipleChoiceQuestion getMultipleChoiceQuestion(Connection conn, QuestionInfo info) throws SQLException {
        List<MultipleChoiceQuestion.Option> options = new ArrayList<>();
        java.util.Set<String> correctIds = new java.util.HashSet<>();
        
        String sql = "SELECT option_id, option_text, is_correct FROM multiple_choice_options WHERE question_id = ? ORDER BY order_index ASC";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, info.id());
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    String optId = rs.getString("option_id");
                    options.add(new MultipleChoiceQuestion.Option(optId, rs.getString("option_text")));
                    if (rs.getBoolean("is_correct")) correctIds.add(optId);
                }
            }
        }
        return new MultipleChoiceQuestion(info, options, correctIds);
    }

    private FillBlankQuestion getFillBlankQuestion(Connection conn, QuestionInfo info) throws SQLException {
        boolean caseSensitive = false;
        String sqlInfo = "SELECT case_sensitive FROM fill_blank_questions WHERE question_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sqlInfo)) {
            stmt.setString(1, info.id());
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) caseSensitive = rs.getBoolean("case_sensitive");
            }
        }
        
        List<String> answers = new ArrayList<>();
        String sqlAns = "SELECT answer_text FROM fill_blank_answers WHERE question_id = ? ORDER BY answer_id ASC";
        try (PreparedStatement stmt = conn.prepareStatement(sqlAns)) {
            stmt.setString(1, info.id());
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) answers.add(rs.getString("answer_text"));
            }
        }
        return new FillBlankQuestion(info, answers, caseSensitive);
    }

    private DragDropQuestion getDragDropQuestion(Connection conn, QuestionInfo info) throws SQLException {
        List<DragItem> draggables = new ArrayList<>();
        List<DropZone> dropZones = new ArrayList<>();
        java.util.Map<String, String> pairings = new java.util.HashMap<>();
        
        String sqlDrag = "SELECT drag_item_id, label FROM drag_items WHERE question_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sqlDrag)) {
            stmt.setString(1, info.id());
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) draggables.add(new DragItem(rs.getString("drag_item_id"), rs.getString("label")));
            }
        }
        
        String sqlDrop = "SELECT drop_zone_id, label FROM drop_zones WHERE question_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sqlDrop)) {
            stmt.setString(1, info.id());
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) dropZones.add(new DropZone(rs.getString("drop_zone_id"), rs.getString("label")));
            }
        }
        
        String sqlPair = "SELECT drag_item_id, drop_zone_id FROM drag_drop_pairings WHERE question_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sqlPair)) {
            stmt.setString(1, info.id());
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) pairings.put(rs.getString("drop_zone_id"), rs.getString("drag_item_id"));
            }
        }
        
        return new DragDropQuestion(info, draggables, dropZones, pairings);
    }

    public LearningModule getModuleById(String moduleId) throws SQLException {
        String sql = "SELECT module_id, title, order_index, module_type, content_url, duration_secs, slide_count, created_at " +
                     "FROM learning_modules WHERE module_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, moduleId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    String id = rs.getString("module_id");
                    String title = rs.getString("title");
                    int orderIndex = rs.getInt("order_index");
                    java.sql.Timestamp createdAtTs = rs.getTimestamp("created_at");
                    LocalDateTime createdAt = createdAtTs != null ? createdAtTs.toLocalDateTime() : LocalDateTime.now();

                    ModuleInfo info = new ModuleInfo(id, title, orderIndex, createdAt, 0);
                    String typeStr = rs.getString("module_type");

                    if ("VIDEO".equals(typeStr)) {
                        int durationSecs = rs.getInt("duration_secs");
                        String url = rs.getString("content_url");
                        return new VideoModule(info, url, Duration.ofSeconds(durationSecs), null);
                    } else if ("SLIDE".equals(typeStr)) {
                        int slideCount = rs.getInt("slide_count");
                        List<Slide> slides = new ArrayList<>();
                        for (int i = 0; i < slideCount; i++) {
                            slides.add(new Slide(i, "", "")); // mock slide
                        }
                        return new SlideModule(info, slides, 30);
                    }
                }
            }
        }
        return null;
    }

    public String getCourseIdForModule(String moduleId) throws SQLException {
        String sql = "SELECT c.course_id FROM learning_modules lm " +
                     "JOIN chapters c ON lm.chapter_id = c.chapter_id " +
                     "WHERE lm.module_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, moduleId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("course_id");
                }
            }
        }
        return null;
    }

    public String getCourseIdForChapter(String chapterId) throws SQLException {
        String sql = "SELECT course_id FROM chapters WHERE chapter_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, chapterId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("course_id");
                }
            }
        }
        return null;
    }
}

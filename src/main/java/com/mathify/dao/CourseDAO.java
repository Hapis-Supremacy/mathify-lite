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
import java.util.UUID;

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
                        String url = rs.getString("content_url");
                        List<Slide> slides = new ArrayList<>();
                        for (int i = 0; i < slideCount; i++) {
                            slides.add(new Slide(i, "", "")); // mock slide
                        }
                        modules.add(new SlideModule(info, url, slides, 30));
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
                        String url = rs.getString("content_url");
                        List<Slide> slides = new ArrayList<>();
                        for (int i = 0; i < slideCount; i++) {
                            slides.add(new Slide(i, "", "")); // mock slide
                        }
                        return new SlideModule(info, url, slides, 30);
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

    // ====================================================================
    // Admin authoring: course-level CRUD + list summaries
    // ====================================================================

    /**
     * Every course with its chapter count and enrollment count, for the
     * admin Courses table. Counts are computed via correlated subqueries so
     * a course with zero chapters/enrollments still shows a 0.
     */
    public List<AdminCourseDTO> getCourseSummaries() throws SQLException {
        List<AdminCourseDTO> list = new ArrayList<>();
        String sql =
            "SELECT c.course_id, c.title, c.category, c.description, " +
            "  (SELECT COUNT(*) FROM chapters ch WHERE ch.course_id = c.course_id) AS chapter_count, " +
            "  (SELECT COUNT(*) FROM course_enrollments ce WHERE ce.course_id = c.course_id) AS enrolled_count " +
            "FROM courses c ORDER BY c.created_at ASC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                AdminCourseDTO dto = new AdminCourseDTO();
                dto.setCourseId(rs.getString("course_id"));
                dto.setTitle(rs.getString("title"));
                dto.setCategory(rs.getString("category"));
                dto.setDescription(rs.getString("description"));
                dto.setChapterCount(rs.getInt("chapter_count"));
                dto.setEnrolledCount(rs.getInt("enrolled_count"));
                list.add(dto);
            }
        }
        return list;
    }

    /** Inserts a course and returns its generated id. */
    public String createCourse(String title, String category, String description) throws SQLException {
        String courseId = UUID.randomUUID().toString();
        String sql = "INSERT INTO courses (course_id, title, category, description) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, courseId);
            stmt.setString(2, title);
            stmt.setString(3, category);
            stmt.setString(4, description);
            stmt.executeUpdate();
        }
        return courseId;
    }

    public void updateCourse(String courseId, String title, String category, String description) throws SQLException {
        String sql = "UPDATE courses SET title = ?, category = ?, description = ? WHERE course_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, title);
            stmt.setString(2, category);
            stmt.setString(3, description);
            stmt.setString(4, courseId);
            stmt.executeUpdate();
        }
    }

    /**
     * Deletes a course. Chapters/modules/quizzes cascade, but enrollments and
     * progress use ON DELETE RESTRICT, so this throws if students are enrolled
     * or have activity - the servlet surfaces that as a friendly error.
     */
    public void deleteCourse(String courseId) throws SQLException {
        String sql = "DELETE FROM courses WHERE course_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, courseId);
            stmt.executeUpdate();
        }
    }

    // ====================================================================
    // Admin authoring: chapter / module / quiz CRUD
    // ====================================================================

    public String createChapter(String courseId, String title, String description,
                                int xpReward, int orderIndex) throws SQLException {
        String chapterId = UUID.randomUUID().toString();
        String sql = "INSERT INTO chapters (chapter_id, course_id, title, description, xp_reward, order_index) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, chapterId);
            stmt.setString(2, courseId);
            stmt.setString(3, title);
            stmt.setString(4, description);
            stmt.setInt(5, xpReward);
            stmt.setInt(6, orderIndex);
            stmt.executeUpdate();
        }
        return chapterId;
    }

    public void updateChapter(String chapterId, String title, String description,
                              int xpReward, int orderIndex) throws SQLException {
        String sql = "UPDATE chapters SET title = ?, description = ?, xp_reward = ?, order_index = ? " +
                     "WHERE chapter_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, title);
            stmt.setString(2, description);
            stmt.setInt(3, xpReward);
            stmt.setInt(4, orderIndex);
            stmt.setString(5, chapterId);
            stmt.executeUpdate();
        }
    }

    /** Chapter delete cascades to its modules and quizzes (FK ON DELETE CASCADE). */
    public void deleteChapter(String chapterId) throws SQLException {
        String sql = "DELETE FROM chapters WHERE chapter_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, chapterId);
            stmt.executeUpdate();
        }
    }

    /**
     * Inserts a learning module. {@code moduleType} is VIDEO or SLIDE; the
     * schema CHECK requires exactly one of duration_secs / slide_count to be
     * set, so the other is stored NULL.
     */
    public String createModule(String chapterId, String title, String moduleType, String contentUrl,
                               Integer durationSecs, Integer slideCount, int orderIndex) throws SQLException {
        String moduleId = UUID.randomUUID().toString();
        String sql = "INSERT INTO learning_modules " +
                     "(module_id, chapter_id, title, order_index, module_type, content_url, duration_secs, slide_count) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, moduleId);
            bindModule(stmt, chapterId, title, moduleType, contentUrl, durationSecs, slideCount, orderIndex);
            stmt.executeUpdate();
        }
        return moduleId;
    }

    public void updateModule(String moduleId, String title, String moduleType, String contentUrl,
                             Integer durationSecs, Integer slideCount, int orderIndex) throws SQLException {
        String sql = "UPDATE learning_modules SET title = ?, order_index = ?, module_type = ?, " +
                     "content_url = ?, duration_secs = ?, slide_count = ? WHERE module_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, title);
            stmt.setInt(2, orderIndex);
            stmt.setString(3, moduleType);
            stmt.setString(4, contentUrl);
            setNullableInt(stmt, 5, "VIDEO".equals(moduleType) ? durationSecs : null);
            setNullableInt(stmt, 6, "SLIDE".equals(moduleType) ? slideCount : null);
            stmt.setString(7, moduleId);
            stmt.executeUpdate();
        }
    }

    public void deleteModule(String moduleId) throws SQLException {
        String sql = "DELETE FROM learning_modules WHERE module_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, moduleId);
            stmt.executeUpdate();
        }
    }

    public String createQuiz(String chapterId, String title, int passingScore) throws SQLException {
        String quizId = UUID.randomUUID().toString();
        String sql = "INSERT INTO quizzes (quiz_id, chapter_id, title, passing_score) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, quizId);
            stmt.setString(2, chapterId);
            stmt.setString(3, title);
            stmt.setInt(4, passingScore);
            stmt.executeUpdate();
        }
        return quizId;
    }

    public void updateQuiz(String quizId, String title, int passingScore) throws SQLException {
        String sql = "UPDATE quizzes SET title = ?, passing_score = ? WHERE quiz_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, title);
            stmt.setInt(2, passingScore);
            stmt.setString(3, quizId);
            stmt.executeUpdate();
        }
    }

    /** Quiz delete cascades to its questions and their subtype rows. */
    public void deleteQuiz(String quizId) throws SQLException {
        String sql = "DELETE FROM quizzes WHERE quiz_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, quizId);
            stmt.executeUpdate();
        }
    }

    public void deleteQuestion(String questionId) throws SQLException {
        String sql = "DELETE FROM questions WHERE question_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, questionId);
            stmt.executeUpdate();
        }
    }

    public void createMultipleChoiceQuestion(String quizId, String prompt, int points, int orderIndex, List<MultipleChoiceQuestion.Option> options, java.util.Set<String> correctText) throws SQLException {
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                String qId = insertQuestionRow(conn, quizId, prompt, points, "MULTIPLE_CHOICE", orderIndex);
                insertMultipleChoiceOptions(conn, qId, options, correctText);
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public void createFillBlankQuestion(String quizId, String prompt, int points, int orderIndex, boolean caseSensitive, List<String> answers) throws SQLException {
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                String qId = insertQuestionRow(conn, quizId, prompt, points, "FILL_BLANK", orderIndex);
                insertFillBlankDetails(conn, qId, caseSensitive, answers);
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public void createDragDropQuestion(String quizId, String prompt, int points, int orderIndex, java.util.Map<String, String> pairings) throws SQLException {
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                String qId = insertQuestionRow(conn, quizId, prompt, points, "DRAG_AND_DROP", orderIndex);
                insertDragDropDetails(conn, qId, pairings);
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    // ---- Question editing -----------------------------------------------
    // Each update keeps the existing question_id but rewrites its content. The
    // base row (incl. question_type) is updated and ALL subtype rows are wiped
    // first, so an admin can also switch a question from one type to another.

    public void updateMultipleChoiceQuestion(String questionId, String prompt, int points, int orderIndex, List<MultipleChoiceQuestion.Option> options, java.util.Set<String> correctText) throws SQLException {
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                updateQuestionRow(conn, questionId, prompt, points, "MULTIPLE_CHOICE", orderIndex);
                clearQuestionSubtypeData(conn, questionId);
                insertMultipleChoiceOptions(conn, questionId, options, correctText);
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public void updateFillBlankQuestion(String questionId, String prompt, int points, int orderIndex, boolean caseSensitive, List<String> answers) throws SQLException {
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                updateQuestionRow(conn, questionId, prompt, points, "FILL_BLANK", orderIndex);
                clearQuestionSubtypeData(conn, questionId);
                insertFillBlankDetails(conn, questionId, caseSensitive, answers);
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public void updateDragDropQuestion(String questionId, String prompt, int points, int orderIndex, java.util.Map<String, String> pairings) throws SQLException {
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                updateQuestionRow(conn, questionId, prompt, points, "DRAG_AND_DROP", orderIndex);
                clearQuestionSubtypeData(conn, questionId);
                insertDragDropDetails(conn, questionId, pairings);
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    // ---- Question persistence helpers (shared by create + update) -------

    private String insertQuestionRow(Connection conn, String quizId, String prompt, int points, String type, int orderIndex) throws SQLException {
        String qId = UUID.randomUUID().toString();
        String sql = "INSERT INTO questions (question_id, quiz_id, prompt, points, question_type, order_index) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, qId);
            stmt.setString(2, quizId);
            stmt.setString(3, prompt);
            stmt.setInt(4, points);
            stmt.setString(5, type);
            stmt.setInt(6, orderIndex);
            stmt.executeUpdate();
        }
        return qId;
    }

    private void updateQuestionRow(Connection conn, String questionId, String prompt, int points, String type, int orderIndex) throws SQLException {
        String sql = "UPDATE questions SET prompt = ?, points = ?, question_type = ?, order_index = ? WHERE question_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, prompt);
            stmt.setInt(2, points);
            stmt.setString(3, type);
            stmt.setInt(4, orderIndex);
            stmt.setString(5, questionId);
            stmt.executeUpdate();
        }
    }

    /** Removes every subtype row for a question across all three types (pairings before items/zones). */
    private void clearQuestionSubtypeData(Connection conn, String questionId) throws SQLException {
        String[] deletes = {
            "DELETE FROM drag_drop_pairings WHERE question_id = ?",
            "DELETE FROM drag_items WHERE question_id = ?",
            "DELETE FROM drop_zones WHERE question_id = ?",
            "DELETE FROM fill_blank_answers WHERE question_id = ?",
            "DELETE FROM fill_blank_questions WHERE question_id = ?",
            "DELETE FROM multiple_choice_options WHERE question_id = ?"
        };
        for (String sql : deletes) {
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, questionId);
                stmt.executeUpdate();
            }
        }
    }

    private void insertMultipleChoiceOptions(Connection conn, String questionId, List<MultipleChoiceQuestion.Option> options, java.util.Set<String> correctText) throws SQLException {
        String sql = "INSERT INTO multiple_choice_options (option_id, question_id, option_text, is_correct, order_index) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            int idx = 0;
            for (MultipleChoiceQuestion.Option opt : options) {
                stmt.setString(1, UUID.randomUUID().toString());
                stmt.setString(2, questionId);
                stmt.setString(3, opt.text());
                stmt.setBoolean(4, correctText.contains(opt.text()));
                stmt.setInt(5, idx++);
                stmt.addBatch();
            }
            stmt.executeBatch();
        }
    }

    private void insertFillBlankDetails(Connection conn, String questionId, boolean caseSensitive, List<String> answers) throws SQLException {
        try (PreparedStatement stmt = conn.prepareStatement("INSERT INTO fill_blank_questions (question_id, case_sensitive) VALUES (?, ?)")) {
            stmt.setString(1, questionId);
            stmt.setBoolean(2, caseSensitive);
            stmt.executeUpdate();
        }
        try (PreparedStatement stmt = conn.prepareStatement("INSERT INTO fill_blank_answers (answer_id, question_id, answer_text) VALUES (?, ?, ?)")) {
            for (String ans : answers) {
                stmt.setString(1, UUID.randomUUID().toString());
                stmt.setString(2, questionId);
                stmt.setString(3, ans);
                stmt.addBatch();
            }
            stmt.executeBatch();
        }
    }

    private void insertDragDropDetails(Connection conn, String questionId, java.util.Map<String, String> pairings) throws SQLException {
        String sqlDrag = "INSERT INTO drag_items (drag_item_id, question_id, label) VALUES (?, ?, ?)";
        String sqlDrop = "INSERT INTO drop_zones (drop_zone_id, question_id, label) VALUES (?, ?, ?)";
        String sqlPair = "INSERT INTO drag_drop_pairings (question_id, drag_item_id, drop_zone_id) VALUES (?, ?, ?)";

        try (PreparedStatement stmtDrag = conn.prepareStatement(sqlDrag);
             PreparedStatement stmtDrop = conn.prepareStatement(sqlDrop);
             PreparedStatement stmtPair = conn.prepareStatement(sqlPair)) {

            for (java.util.Map.Entry<String, String> entry : pairings.entrySet()) {
                String dragId = UUID.randomUUID().toString();
                String dropId = UUID.randomUUID().toString();

                stmtDrag.setString(1, dragId);
                stmtDrag.setString(2, questionId);
                stmtDrag.setString(3, entry.getKey());
                stmtDrag.addBatch();

                stmtDrop.setString(1, dropId);
                stmtDrop.setString(2, questionId);
                stmtDrop.setString(3, entry.getValue());
                stmtDrop.addBatch();

                stmtPair.setString(1, questionId);
                stmtPair.setString(2, dragId);
                stmtPair.setString(3, dropId);
                stmtPair.addBatch();
            }
            stmtDrag.executeBatch();
            stmtDrop.executeBatch();
            stmtPair.executeBatch();
        }
    }

    /**
     * Loads every chapter of a course with its modules and quizzes as raw
     * admin DTOs (exact stored columns), for the content editor. Returns an
     * empty list if the course has no chapters.
     */
    public List<AdminChapterDTO> getCourseEditorChapters(String courseId) throws SQLException {
        List<AdminChapterDTO> chapters = new ArrayList<>();
        String sql = "SELECT chapter_id, title, description, xp_reward, order_index " +
                     "FROM chapters WHERE course_id = ? ORDER BY order_index ASC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, courseId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    AdminChapterDTO ch = new AdminChapterDTO();
                    ch.setChapterId(rs.getString("chapter_id"));
                    ch.setTitle(rs.getString("title"));
                    ch.setDescription(rs.getString("description"));
                    ch.setXpReward(rs.getInt("xp_reward"));
                    ch.setOrderIndex(rs.getInt("order_index"));
                    chapters.add(ch);
                }
            }
        }
        for (AdminChapterDTO ch : chapters) {
            ch.setModules(getModuleRowsForChapter(ch.getChapterId()));
            ch.setQuizzes(getQuizRowsForChapter(ch.getChapterId()));
        }
        return chapters;
    }

    private List<AdminModuleDTO> getModuleRowsForChapter(String chapterId) throws SQLException {
        List<AdminModuleDTO> modules = new ArrayList<>();
        String sql = "SELECT module_id, title, module_type, content_url, duration_secs, slide_count, order_index " +
                     "FROM learning_modules WHERE chapter_id = ? ORDER BY order_index ASC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, chapterId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    AdminModuleDTO m = new AdminModuleDTO();
                    m.setModuleId(rs.getString("module_id"));
                    m.setTitle(rs.getString("title"));
                    m.setModuleType(rs.getString("module_type"));
                    m.setContentUrl(rs.getString("content_url"));
                    int dur = rs.getInt("duration_secs");
                    m.setDurationSecs(rs.wasNull() ? null : dur);
                    int sc = rs.getInt("slide_count");
                    m.setSlideCount(rs.wasNull() ? null : sc);
                    m.setOrderIndex(rs.getInt("order_index"));
                    modules.add(m);
                }
            }
        }
        return modules;
    }

    private List<AdminQuizDTO> getQuizRowsForChapter(String chapterId) throws SQLException {
        List<AdminQuizDTO> quizzes = new ArrayList<>();
        String sql = "SELECT q.quiz_id, q.title, q.passing_score, " +
                     "  (SELECT COUNT(*) FROM questions qs WHERE qs.quiz_id = q.quiz_id) AS question_count " +
                     "FROM quizzes q WHERE q.chapter_id = ? ORDER BY q.title ASC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, chapterId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    AdminQuizDTO q = new AdminQuizDTO();
                    q.setQuizId(rs.getString("quiz_id"));
                    q.setTitle(rs.getString("title"));
                    q.setPassingScore(rs.getInt("passing_score"));
                    q.setQuestionCount(rs.getInt("question_count"));
                    quizzes.add(q);
                }
            }
        }
        return quizzes;
    }

    // ---- helpers --------------------------------------------------------

    private void bindModule(PreparedStatement stmt, String chapterId, String title, String moduleType,
                            String contentUrl, Integer durationSecs, Integer slideCount, int orderIndex)
            throws SQLException {
        // module_id is placeholder 1 (set by the caller); 2-8 follow the INSERT column order.
        stmt.setString(2, chapterId);
        stmt.setString(3, title);
        stmt.setInt(4, orderIndex);
        stmt.setString(5, moduleType);
        stmt.setString(6, contentUrl);
        setNullableInt(stmt, 7, "VIDEO".equals(moduleType) ? durationSecs : null);
        setNullableInt(stmt, 8, "SLIDE".equals(moduleType) ? slideCount : null);
    }

    private void setNullableInt(PreparedStatement stmt, int index, Integer value) throws SQLException {
        if (value == null) {
            stmt.setNull(index, java.sql.Types.INTEGER);
        } else {
            stmt.setInt(index, value);
        }
    }
}

package com.mathify.model;

import java.time.Duration;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Platform-wide engagement and learning metrics produced by an {@link Admin}.
 *
 * <p>The diagram leaves several field types loose ("registrationTrend",
 * "activeTimeHeatmap", "Time", "Lesson"). Concrete Java types are chosen here:
 * trends are keyed by date, the heatmap is a [day-of-week][hour] grid, durations
 * use {@link Duration}, and per-lesson maps are keyed by lesson id.
 */
public class ReportMetric {

    /** A course paired with its learner count, for the popularity ranking. */
    public record CoursePopularity(Course course, int learners) {
    }

    public int dailyActiveUsers;
    public int weeklyActiveUsers;
    public int monthlyActiveUsers;
    public float dauMauRatio;
    public Map<LocalDate, Integer> registrationTrend = new HashMap<>();
    public float retentionRate;
    public float churnRate;
    public float avgSessionDuration;
    public float avgWeeklyUserSession;
    /** Activity intensity indexed as [dayOfWeek 0-6][hour 0-23]. */
    public int[][] activeTimeHeatmap = new int[7][24];
    public Duration totalLearningTime = Duration.ZERO;
    public Map<String, Float> lessonCompletionRate = new HashMap<>();
    public float averageLessonBeforeDropout;
    public Map<String, Float> lessonDropoutRate = new HashMap<>();
    public Map<String, Duration> averageCompletionTime = new HashMap<>();
    public List<CoursePopularity> coursePopularity = new ArrayList<>();
}

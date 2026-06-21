package com.mathify.model;

/** An administrator account: manages content and learners, and reads metrics. */
public class Admin extends User {

    private String adminId;

    public Admin() {
    }

    public Admin(String adminId) {
        this.adminId = adminId;
    }

    public ReportMetric generateReportMetric() {
        return new ReportMetric();
    }

    public void disableAccount(Student student) {
        // Flagged disabled in the persistence layer; no in-model field on Student.
    }

    public void deleteAccount(Student student) {
        // Removal handled by the persistence layer.
    }

    public void exportReportMetric(ReportMetric metric) {
        // Serialize/export handled by the reporting layer.
    }

    public Course createCourse() {
        return new Course();
    }

    public Topic createTopic() {
        return new Topic();
    }

    public void editCourse(Course course) {
        // Persisted by the course service.
    }

    public void editTopic(Topic topic) {
        // Persisted by the topic service.
    }

    public void deleteCourse(Course course) {
        // Removal handled by the persistence layer.
    }

    public void deleteTopic(Topic topic) {
        // Removal handled by the persistence layer.
    }

    public String getAdminId() {
        return adminId;
    }

    public void setAdminId(String adminId) {
        this.adminId = adminId;
    }
}

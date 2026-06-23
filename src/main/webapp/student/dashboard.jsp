<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.mathify.model.Student" %>
<%@ page import="com.mathify.model.UserProgress" %>
<%@ page import="java.util.List" %>
<%@ page import="com.mathify.dao.ProgressDAO.EnrolledCourse" %>
<%
    Student student = (Student) request.getAttribute("student");
    UserProgress progress = (UserProgress) request.getAttribute("progress");
    Integer completedCount = (Integer) request.getAttribute("completedCount");
    List<EnrolledCourse> recentCourses = (List<EnrolledCourse>) request.getAttribute("recentCourses");

    if (student == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    int nextLevelXP = (progress.getLevel() + 1) * 500; // Mock calculation for next level XP
    int xpToNextLevel = nextLevelXP - progress.getTotalXP();
    if (xpToNextLevel < 0) xpToNextLevel = 0;
    int progressPercent = (int) ((double) progress.getTotalXP() / nextLevelXP * 100);
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Dashboard · Mathify</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Source+Sans+3:wght@400;500;600;700&family=Source+Serif+4:opsz,wght@8..60,500;8..60,600;8..60,700&display=swap" rel="stylesheet">
<link href="../assets/css/app.css" rel="stylesheet">
</head>
<body data-role="student" data-page="dashboard" data-base="../"
      data-energy="${globalStudent.energy}" data-xp="${globalProgress.totalXP}"
      data-energy-max="${globalStudent.maxEnergy}" data-energy-renews-at="${globalStudent.energyRenewalEpochMillis}"
      data-premium="${globalStudent.premiumActive}"
      data-level="${globalProgress.level}" data-streak="${globalProgress.currentStreak}">

<div class="container py-4 shell">

  <div class="mb-4">
    <h2 class="mb-1">Welcome back, <%= student.getName() %></h2>
    <p class="text-secondary mb-0">Keep your streak alive — you're <%= xpToNextLevel %> XP from Level <%= progress.getLevel() + 1 %>.</p>
  </div>

  <div class="row g-3 mb-4">
    <div class="col-6 col-lg-3">
      <div class="card h-100 shadow-sm border-0"><div class="card-body">
        <div class="d-flex align-items-center gap-2 text-secondary mb-1"><i class="bi bi-fire" style="color:#d97706;"></i><span class="small fw-semibold">Quiz Streak</span></div>
        <div class="fs-3 fw-bold"><%= progress.getCurrentStreak() %></div>
        <div class="text-secondary small">One counted quiz per day</div></div></div>
    </div>
    <div class="col-6 col-lg-3">
      <div class="card h-100 shadow-sm border-0"><div class="card-body">
        <div class="d-flex align-items-center gap-2 text-secondary mb-1"><i class="bi bi-lightning-charge-fill" style="color:#1d4e89;"></i><span class="small fw-semibold">Energy</span></div>
        <div class="fs-3 fw-bold" data-energy-value><%= student.getEnergy() %>/<%= student.getMaxEnergy() %></div>
        <span class="badge rounded-pill text-bg-light border fw-semibold" data-energy-renewal></span></div></div>
    </div>
    <div class="col-6 col-lg-3">
      <div class="card h-100 shadow-sm border-0"><div class="card-body">
        <div class="d-flex align-items-center gap-2 text-secondary mb-1"><i class="bi bi-stars" style="color:#1d4e89;"></i><span class="small fw-semibold">Total XP</span></div>
        <div class="fs-3 fw-bold"><%= progress.getTotalXP() %></div></div></div>
    </div>
    <div class="col-6 col-lg-3">
      <div class="card h-100 shadow-sm border-0"><div class="card-body">
        <div class="d-flex align-items-center gap-2 text-secondary mb-1"><i class="bi bi-check2-circle" style="color:#1d8a5b;"></i><span class="small fw-semibold">Completed</span></div>
        <div class="fs-3 fw-bold"><%= completedCount %></div></div></div>
    </div>
  </div>

  <div class="card shadow-sm border-0 mb-4"><div class="card-body p-4">
    <div class="d-flex justify-content-between align-items-end mb-2">
      <div><div class="text-secondary small fw-semibold">LEVEL <%= progress.getLevel() %></div><h5 class="mb-0"><%= progress.getTotalXP() %> / <%= nextLevelXP %> XP</h5></div>
      <div class="text-secondary small">Next: Level <%= progress.getLevel() + 1 %></div>
    </div>
    <div class="progress" style="height:12px;"><% out.print("<div class=\"progress-bar\" style=\"width:" + progressPercent + "%;\"></div>"); %></div>
  </div></div>

  <div class="d-flex justify-content-between align-items-center mb-3">
    <h4 class="mb-0">Continue learning</h4>
    <a class="btn btn-sm btn-outline-primary" href="catalog.do">Browse all courses</a>
  </div>

  <div class="row g-3">
    <% if (recentCourses != null && !recentCourses.isEmpty()) { 
           for (EnrolledCourse ec : recentCourses) { %>
    <div class="col-12 col-lg-6">
      <div class="card shadow-sm border-0 h-100"><div class="card-body p-4">
        <div class="d-flex justify-content-between align-items-start mb-2">
          <div><span class="badge rounded-pill mb-2 badge-soft"><%= ec.category() %></span>
          <h5 class="mb-0"><%= ec.title() %></h5></div>
          <span class="text-secondary small"><%= ec.progressPercent() %>%</span>
        </div>
        <div class="progress mb-3" style="height:8px;"><% out.print("<div class=\"progress-bar\" style=\"width:" + ec.progressPercent() + "%;\"></div>"); %></div>
        <a class="btn btn-primary btn-sm" href="course.do?id=<%= ec.courseId() %>"><i class="bi bi-play-fill me-1"></i>Continue</a>
      </div></div>
    </div>
    <%     }
       } else { %>
    <div class="col-12">
        <p class="text-secondary">You haven't enrolled in any courses yet. Check out the <a href="catalog.do">Course Catalog</a>!</p>
    </div>
    <% } %>
  </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="../assets/js/app.js?v=6" data-username="${sessionScope.userName}"></script>
</body>
</html>

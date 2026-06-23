<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.mathify.model.Course" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Courses · Mathify</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Source+Sans+3:wght@400;500;600;700&family=Source+Serif+4:opsz,wght@8..60,500;8..60,600;8..60,700&display=swap" rel="stylesheet">
<link href="../assets/css/app.css" rel="stylesheet">
</head>
<body data-role="student" data-page="catalog" data-base="../"
      data-energy="${globalStudent.energy}" data-xp="${globalProgress.totalXP}"
      data-energy-max="${globalStudent.maxEnergy}" data-energy-renews-at="${globalStudent.energyRenewalEpochMillis}"
      data-premium="${globalStudent.premiumActive}"
      data-level="${globalProgress.level}" data-streak="${globalProgress.currentStreak}">

<div class="container py-4 shell">

  <div class="mb-4">
    <h2 class="mb-1">Course catalog</h2>
    <p class="text-secondary mb-0">Enroll to unlock chapters, lessons and quizzes.</p>
  </div>

  <div class="row g-3">
    <% 
      List<Course> courses = (List<Course>) request.getAttribute("courses");
      if (courses != null && !courses.isEmpty()) {
        for (Course c : courses) { 
    %>
    <div class="col-12 col-md-6 col-lg-4">
      <div class="card shadow-sm border-0 h-100"><div class="card-body p-4 d-flex flex-column">
        <div class="d-flex justify-content-between align-items-start mb-2">
          <span class="badge rounded-pill badge-soft"><%= c.getCategory() %></span>
        </div>
        <h5 class="mb-2"><a class="text-reset" href="course.do?id=<%= c.getCourseId() %>"><%= c.getTitle() %></a></h5>
        <p class="text-secondary small flex-grow-1"><%= c.getDescription() != null ? c.getDescription() : "" %></p>
        <div class="d-flex gap-2">
          <a class="btn btn-primary btn-sm flex-grow-1" href="course.do?id=<%= c.getCourseId() %>">View Course</a>
        </div>
      </div></div>
    </div>
    <% 
        }
      } else { 
    %>
        <div class="col-12">
            <p class="text-secondary">No courses available at the moment.</p>
        </div>
    <% } %>
  </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="../assets/js/app.js?v=6" data-username="${sessionScope.userName}"></script>
</body>
</html>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.mathify.model.UserProgress" %>
<%@ page import="java.util.List" %>
<%@ page import="com.mathify.model.Achievement" %>
<%
  UserProgress globalProgress = (UserProgress) request.getAttribute("globalProgress");
  List<Achievement> allAchievements = (List<Achievement>) request.getAttribute("allAchievements");
  int unlockedCount = globalProgress != null ? globalProgress.getAchievements().size() : 0;
  int totalAchievements = allAchievements != null ? allAchievements.size() : 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Achievements · Mathify</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Source+Sans+3:wght@400;500;600;700&family=Source+Serif+4:opsz,wght@8..60,500;8..60,600;8..60,700&display=swap" rel="stylesheet">
<link href="../assets/css/app.css" rel="stylesheet">
</head>
<body data-role="student" data-page="achievements" data-base="../"
      data-energy="${globalStudent.energy}" data-xp="${globalProgress.totalXP}"
      data-energy-max="${globalStudent.maxEnergy}" data-energy-renews-at="${globalStudent.energyRenewalEpochMillis}"
      data-premium="${globalStudent.premiumActive}"
      data-level="${globalProgress.level}" data-streak="${globalProgress.currentStreak}">

<div class="container py-4 shell">

  <div class="mb-4">
    <h2 class="mb-1">Achievements</h2>
    <p class="text-secondary mb-0"><%= unlockedCount %> of <%= totalAchievements %> unlocked.</p>
  </div>

  <div class="row g-3" id="grid">
    <%
      if (allAchievements != null) {
        for (Achievement a : allAchievements) {
          boolean unlocked = globalProgress != null && globalProgress.hasAchievement(a.getId());
          String bg = unlocked ? "#eef3fa" : "#eef1f6";
          String color = unlocked ? "#1d4e89" : "#9aa6b8";
          double opacity = unlocked ? 1.0 : 0.5;
    %>
    <div class="col-6 col-md-4 col-lg-3">
      <div class="card border-0 shadow-sm h-100 text-center" style="opacity: <%= opacity %>;">
        <div class="card-body py-4">
          <span class="d-inline-flex align-items-center justify-content-center rounded-circle mb-2" style="width:60px;height:60px;background:<%= bg %>;color:<%= color %>;">
            <i class="bi <%= a.getIcon() %> fs-3"></i>
          </span>
          <h6 class="mb-1"><%= a.getTitle() %></h6>
          <p class="text-secondary small mb-0"><%= a.getRequirement() %></p>
        </div>
      </div>
    </div>
    <%
        }
      }
    %>
  </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="../assets/js/app.js?v=8" data-username="${sessionScope.userName}"></script>
</script>
</body>
</html>

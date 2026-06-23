<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.mathify.model.Course" %>
<%@ page import="com.mathify.model.Chapter" %>
<%@ page import="com.mathify.model.LearningModule" %>
<%@ page import="com.mathify.model.Quiz" %>
<%@ page import="com.mathify.model.ModuleType" %>
<%@ page import="com.mathify.model.VideoModule" %>
<%@ page import="com.mathify.model.SlideModule" %>
<%@ page import="com.mathify.model.Student" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%
  Course course = (Course) request.getAttribute("course");
  if (course == null) {
      response.sendRedirect("catalog.do");
      return;
  }
  Set<String> completedChapters = (Set<String>) request.getAttribute("completedChapters");
  Set<String> completedModules = (Set<String>) request.getAttribute("completedModules");
  Set<String> completedQuizzes = (Set<String>) request.getAttribute("completedQuizzes");
  Map<String, Integer> quizScores = (Map<String, Integer>) request.getAttribute("quizScores");
  String flashQuizId = (String) request.getAttribute("flashQuizId");
  Integer flashQuizXp = (Integer) request.getAttribute("flashQuizXp");
  String flashChapterId = (String) request.getAttribute("flashChapterId");
  Integer flashChapterXp = (Integer) request.getAttribute("flashChapterXp");
  Student globalStudent = (Student) request.getAttribute("globalStudent");
  boolean quizEnergyLocked = globalStudent != null && !globalStudent.isPremiumActive() && globalStudent.getEnergy() <= 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><%= course.getTitle() %> · Mathify</title>
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

  <a class="text-secondary small d-inline-flex align-items-center gap-1 mb-3" href="catalog.do"><i class="bi bi-arrow-left"></i>Back to catalog</a>

  <div class="card border-0 shadow-sm mb-4"><div class="card-body p-4">
    <div class="d-flex justify-content-between align-items-start flex-wrap gap-3">
      <div style="max-width:680px;">
        <span class="badge rounded-pill mb-2 badge-soft"><%= course.getCategory() %></span>
        <h2 class="mb-2"><%= course.getTitle() %></h2>
        <p class="text-secondary mb-0"><%= course.getDescription() != null ? course.getDescription() : "" %></p>
      </div>
      <div class="text-end">
        <div class="mb-2"><span class="badge rounded-pill badge-success-soft"><i class="bi bi-check2 me-1"></i>Enrolled</span></div>
        <button class="btn btn-outline-secondary btn-sm">Unenroll</button>
      </div>
    </div>
  </div></div>

  <% 
    List<Chapter> chapters = course.getChapters();
    if (chapters != null) {
      int chapterNum = 1;
      for (Chapter chapter : chapters) {
  %>
  <!-- Chapter -->
  <div class="card border-0 shadow-sm mb-3"><div class="card-body p-4">
    <div class="d-flex justify-content-between align-items-center mb-3">
      <div><div class="text-secondary small fw-semibold">CHAPTER <%= chapterNum++ %></div><h5 class="mb-0"><%= chapter.getTitle() %></h5></div>
      <div>
        <span class="badge rounded-pill badge-warn-soft"><i class="bi bi-star-fill me-1"></i><%= chapter.getXpReward() %> XP</span>
        <% if (flashChapterId != null && flashChapterId.equals(chapter.getChapterId()) && flashChapterXp != null) { %>
        <span class="badge rounded-pill bg-warning text-dark ms-2"><i class="bi bi-stars me-1"></i>+<%= flashChapterXp %> XP</span>
        <% } %>
        <%
           if (completedChapters != null && completedChapters.contains(chapter.getChapterId())) {
        %>
        <span class="badge rounded-pill bg-success ms-2"><i class="bi bi-check-circle me-1"></i>Selesai</span>
        <% } %>
      </div>
    </div>
    <div class="list-group list-group-flush">
      <% 
        List<LearningModule> modules = chapter.getModules();
        if (modules != null) {
          for (LearningModule mod : modules) {
             String icon = "bi-file-earmark-text";
             String typeDesc = "Lesson";
             String metaInfo = "";
             if (mod.getType() == ModuleType.VIDEO) {
                 icon = "bi-play-circle-fill";
                 typeDesc = "Video";
                 long durationMins = mod.estimatedDuration().toMinutes();
                 long durationSecs = mod.estimatedDuration().toSecondsPart();
                 metaInfo = typeDesc + " · " + durationMins + ":" + String.format("%02d", durationSecs);
             } else if (mod.getType() == ModuleType.SLIDE) {
                 icon = "bi-easel-fill";
                 typeDesc = "Slides";
                 int slideCount = ((SlideModule)mod).getSlides().size();
                 metaInfo = typeDesc + " · " + slideCount + " slides";
             }
      %>
      <a class="list-group-item list-group-item-action d-flex align-items-center gap-3 px-2" style="border-color:#eef1f6;" href="module.do?m=<%= mod.getId() %>">
        <span class="icon-tile"><i class="bi <%= icon %>"></i></span>
        <span class="flex-grow-1"><span class="fw-semibold d-block"><%= mod.getTitle() %></span><span class="text-secondary small"><%= metaInfo %></span></span>
        <%
           if (completedModules != null && completedModules.contains(mod.getId())) {
        %>
        <i class="bi bi-check-circle-fill text-success fs-5"></i>
        <% } else { %>
        <i class="bi bi-chevron-right text-secondary"></i>
        <% } %>
      </a>
      <% 
          }
        }
        
        List<Quiz> quizzes = chapter.getQuizzes();
        if (quizzes != null) {
          for (Quiz q : quizzes) {
             int qCount = q.getQuestions() != null ? q.getQuestions().size() : 0;
             int passScore = q.getPassingScore();
             Integer quizScore = quizScores != null ? quizScores.get(q.getQuizId()) : null;
             boolean quizCompleted = completedQuizzes != null && completedQuizzes.contains(q.getQuizId());
             String metaInfo = "Quiz · pass " + passScore + "% · " + qCount + " questions";
             if (quizScore != null) {
                 metaInfo += " · best " + quizScore + "%";
             }
      %>
      <% if (quizEnergyLocked) { %>
      <button type="button" class="list-group-item list-group-item-action d-flex align-items-center gap-3 px-2 text-start" style="border-color:#eef1f6;" data-bs-toggle="modal" data-bs-target="#energyLockModal">
      <% } else { %>
      <a class="list-group-item list-group-item-action d-flex align-items-center gap-3 px-2" style="border-color:#eef1f6;" href="quiz.do?q=<%= q.getQuizId() %>">
      <% } %>
        <span class="icon-tile icon-tile-warn"><i class="bi bi-patch-question-fill"></i></span>
        <span class="flex-grow-1"><span class="fw-semibold d-block"><%= q.getTitle() %></span><span class="text-secondary small"><%= metaInfo %></span></span>
        <% if (quizEnergyLocked) { %>
        <span class="badge rounded-pill text-bg-warning"><i class="bi bi-lightning-charge-fill me-1"></i>No energy</span>
        <% } %>
        <% if (flashQuizId != null && flashQuizId.equals(q.getQuizId()) && flashQuizXp != null) { %>
        <span class="badge rounded-pill bg-warning text-dark"><i class="bi bi-stars me-1"></i>+<%= flashQuizXp %> XP</span>
        <% } %>
        <% if (quizCompleted) { %>
        <i class="bi bi-check-circle-fill text-success fs-5"></i>
        <% } else { %>
        <i class="bi bi-chevron-right text-secondary"></i>
        <% } %>
      <% if (quizEnergyLocked) { %>
      </button>
      <% } else { %>
      </a>
      <% } %>
      <%
          }
        }
      %>
    </div>
  </div></div>
  <% 
      }
    } 
  %>

</div>

<% if (quizEnergyLocked) { %>
<div class="modal fade" id="energyLockModal" tabindex="-1" aria-hidden="true" aria-labelledby="energyLockTitle">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content border-0 shadow">
      <div class="modal-header border-0 pb-0">
        <h5 class="modal-title d-flex align-items-center gap-2" id="energyLockTitle">
          <span class="rounded-circle d-inline-flex align-items-center justify-content-center" style="width:40px;height:40px;background:#fff4df;color:#d97706;">
            <i class="bi bi-lightning-charge-fill"></i>
          </span>
          Energy empty
        </h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body pt-3">
        <p class="mb-2">You cannot start a quiz while your energy is empty.</p>
        <div class="badge rounded-pill text-bg-light border fw-semibold mb-3" data-energy-renewal></div>
        <p class="text-secondary mb-0">Upgrade to Premium for unlimited quiz energy.</p>
      </div>
      <div class="modal-footer border-0 pt-0">
        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Wait</button>
        <a href="premium.jsp" class="btn btn-primary"><i class="bi bi-gem me-1"></i>Upgrade</a>
      </div>
    </div>
  </div>
</div>
<% } %>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="../assets/js/app.js?v=6" data-username="${sessionScope.userName}"></script>
</body>
</html>

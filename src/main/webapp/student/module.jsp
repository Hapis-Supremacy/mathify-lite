<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.mathify.model.LearningModule" %>
<%@ page import="com.mathify.model.ModuleType" %>
<%@ page import="com.mathify.model.VideoModule" %>
<%@ page import="java.net.URI" %>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%!
  private String toEmbeddableVideoUrl(String url) {
      if (url == null || url.isBlank()) {
          return "";
      }

      String trimmed = url.trim();
      try {
          URI uri = URI.create(trimmed);
          String host = uri.getHost();
          if (host == null) {
              return trimmed;
          }

          host = host.toLowerCase();
          String path = uri.getPath() == null ? "" : uri.getPath();
          if (host.endsWith("youtu.be")) {
              String videoId = firstPathSegment(path);
              return videoId.isEmpty() ? trimmed : "https://www.youtube.com/embed/" + videoId;
          }

          if (host.endsWith("youtube.com")) {
              if (path.startsWith("/embed/")) {
                  return trimmed;
              }
              String videoId = queryParam(uri.getRawQuery(), "v");
              if (!videoId.isEmpty()) {
                  return "https://www.youtube.com/embed/" + videoId;
              }
          }
      } catch (IllegalArgumentException ignored) {
          return trimmed;
      }

      return trimmed;
  }

  private boolean isDirectVideoUrl(String url) {
      if (url == null) {
          return false;
      }
      String clean = url.toLowerCase();
      int queryStart = clean.indexOf('?');
      if (queryStart >= 0) {
          clean = clean.substring(0, queryStart);
      }
      return clean.endsWith(".mp4") || clean.endsWith(".webm") || clean.endsWith(".ogg");
  }

  private String escapeHtml(String value) {
      if (value == null) {
          return "";
      }
      return value
              .replace("&", "&amp;")
              .replace("\"", "&quot;")
              .replace("<", "&lt;")
              .replace(">", "&gt;");
  }

  private String firstPathSegment(String path) {
      String normalized = path.startsWith("/") ? path.substring(1) : path;
      int slash = normalized.indexOf('/');
      return slash >= 0 ? normalized.substring(0, slash) : normalized;
  }

  private String queryParam(String rawQuery, String key) {
      if (rawQuery == null || rawQuery.isBlank()) {
          return "";
      }
      for (String pair : rawQuery.split("&")) {
          int eq = pair.indexOf('=');
          String pairKey = eq >= 0 ? pair.substring(0, eq) : pair;
          if (key.equals(URLDecoder.decode(pairKey, StandardCharsets.UTF_8))) {
              String value = eq >= 0 ? pair.substring(eq + 1) : "";
              return URLDecoder.decode(value, StandardCharsets.UTF_8);
          }
      }
      return "";
  }
%>
<%
  LearningModule module = (LearningModule) request.getAttribute("module");
  if (module == null) {
      response.sendRedirect("catalog.do");
      return;
  }
  boolean isVideo = module.getType() == ModuleType.VIDEO;
  VideoModule videoModule = isVideo ? (VideoModule) module : null;
  String videoUrl = isVideo ? toEmbeddableVideoUrl(videoModule.getVideoUrl()) : "";
  String safeVideoUrl = escapeHtml(videoUrl);
  String courseId = (String) request.getAttribute("courseId");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><%= module.getTitle() %> · Mathify</title>
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

  <a class="text-secondary small d-inline-flex align-items-center gap-1 mb-3" href="javascript:history.back()"><i class="bi bi-arrow-left"></i>Back</a>

  <div class="card border-0 shadow-sm"><div class="card-body p-4">
    <div class="text-secondary small fw-semibold mb-1"><%= isVideo ? "VIDEO LESSON" : "LESSON" %></div>
    <h3 class="mb-3"><%= module.getTitle() %></h3>

    <% if (isVideo) { %>
      <div class="rounded mb-3 overflow-hidden" style="aspect-ratio:16/9;">
        <% if (isDirectVideoUrl(videoUrl)) { %>
        <video width="100%" height="100%" src="<%= safeVideoUrl %>" controls playsinline></video>
        <% } else { %>
        <iframe width="100%" height="100%" src="<%= safeVideoUrl %>" title="<%= escapeHtml(module.getTitle()) %>" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
        <% } %>
      </div>
      <a class="btn btn-outline-primary btn-sm mb-3" href="<%= safeVideoUrl %>" target="_blank" rel="noopener"><i class="bi bi-box-arrow-up-right me-1"></i>Open video</a>
    <% } else { %>
      <div class="ph-stripe rounded d-flex flex-column align-items-center justify-content-center mb-3" style="aspect-ratio:16/9;">
        <span class="d-inline-flex align-items-center justify-content-center rounded-circle mb-2" style="width:64px;height:64px;background:#1d4e89;color:#fff;"><i class="bi bi-easel-fill fs-3"></i></span>
        <code class="text-secondary">slides placeholder</code>
      </div>
    <% } %>

    <div class="d-flex justify-content-end align-items-center pt-2 border-top" style="border-color:#eef1f6;">
      <% if (courseId != null && !courseId.isEmpty()) { %>
      <a class="btn btn-primary" href="course.do?id=<%= courseId %>"><i class="bi bi-arrow-left me-1"></i>Back to course</a>
      <% } else { %>
      <a class="btn btn-primary" href="catalog.do"><i class="bi bi-grid me-1"></i>Back to catalog</a>
      <% } %>
    </div>
  </div></div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="../assets/js/app.js?v=6" data-username="${sessionScope.userName}"></script>
</body>
</html>

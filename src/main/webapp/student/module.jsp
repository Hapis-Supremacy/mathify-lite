<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>What is a Variable? · Mathify</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Source+Sans+3:wght@400;500;600;700&family=Source+Serif+4:opsz,wght@8..60,500;8..60,600;8..60,700&display=swap" rel="stylesheet">
<link href="../assets/css/app.css" rel="stylesheet">
</head>
<body data-role="student" data-page="catalog" data-base="../">

<div class="container py-4 shell">

  <a class="text-secondary small d-inline-flex align-items-center gap-1 mb-3" href="course.jsp?c=c1"><i class="bi bi-arrow-left"></i>Back to Algebra Foundations</a>

  <div class="card border-0 shadow-sm"><div class="card-body p-4">
    <div class="text-secondary small fw-semibold mb-1">VIDEO LESSON</div>
    <h3 class="mb-3">What is a Variable?</h3>

    <!-- Video placeholder -->
    <div class="ph-stripe rounded d-flex flex-column align-items-center justify-content-center mb-3" style="aspect-ratio:16/9;">
      <span class="d-inline-flex align-items-center justify-content-center rounded-circle mb-2" style="width:64px;height:64px;background:#1d4e89;color:#fff;"><i class="bi bi-play-fill fs-3"></i></span>
      <code class="text-secondary">video player · 7:40</code>
    </div>

    <a class="btn btn-outline-primary btn-sm mb-3" href="https://www.youtube.com/watch?v=vDqOoI-4Z6M" target="_blank" rel="noopener"><i class="bi bi-box-arrow-up-right me-1"></i>Open video</a>

    <div class="d-flex justify-content-between align-items-center pt-2 border-top" style="border-color:#eef1f6;">
      <span class="text-secondary small">Earn 20 XP on completion</span>
      <a class="btn btn-primary" href="course.jsp?c=c1"><i class="bi bi-check2 me-1"></i>Mark complete &amp; continue</a>
    </div>
  </div></div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="../assets/js/app.js?v=4" data-username="${sessionScope.userName}"></script>
</body>
</html>

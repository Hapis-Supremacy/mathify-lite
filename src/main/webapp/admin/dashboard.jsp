<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Overview · Mathify Admin</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Source+Sans+3:wght@400;500;600;700&family=Source+Serif+4:opsz,wght@8..60,500;8..60,600;8..60,700&display=swap" rel="stylesheet">
<link href="../assets/css/app.css" rel="stylesheet">
</head>
<body data-role="admin" data-page="overview" data-base="../">

<div class="container py-4 shell">

  <div class="mb-4">
    <h2 class="mb-1">Platform overview</h2>
    <p class="text-secondary mb-0">Engagement and learning metrics across Mathify.</p>
  </div>

  <div class="row g-3 mb-4">
    <div class="col-6 col-lg-3"><div class="card border-0 shadow-sm h-100"><div class="card-body">
      <div class="text-secondary small fw-semibold mb-1"><i class="bi bi-person-check me-1"></i>Daily Active</div>
      <div class="fs-3 fw-bold">8,420</div>
      <div class="small" style="color:#1d8a5b;">↑ 6.2% vs last week</div>
    </div></div></div>
    <div class="col-6 col-lg-3"><div class="card border-0 shadow-sm h-100"><div class="card-body">
      <div class="text-secondary small fw-semibold mb-1"><i class="bi bi-calendar-week me-1"></i>Weekly Active</div>
      <div class="fs-3 fw-bold">31,900</div>
      <div class="small" style="color:#1d8a5b;">↑ 3.1%</div>
    </div></div></div>
    <div class="col-6 col-lg-3"><div class="card border-0 shadow-sm h-100"><div class="card-body">
      <div class="text-secondary small fw-semibold mb-1"><i class="bi bi-activity me-1"></i>DAU / MAU</div>
      <div class="fs-3 fw-bold">46%</div>
      <div class="small" style="color:#6b7686;">Stickiness</div>
    </div></div></div>
    <div class="col-6 col-lg-3"><div class="card border-0 shadow-sm h-100"><div class="card-body">
      <div class="text-secondary small fw-semibold mb-1"><i class="bi bi-arrow-repeat me-1"></i>Retention</div>
      <div class="fs-3 fw-bold">72%</div>
      <div class="small" style="color:#c0392b;">↓ 1.4%</div>
    </div></div></div>
  </div>

  <div class="row g-3">
    <div class="col-12 col-lg-6"><div class="card border-0 shadow-sm h-100"><div class="card-body p-4">
      <h6 class="mb-3">Course popularity</h6>
      <div class="mb-3"><div class="d-flex justify-content-between small mb-1"><span>Algebra Foundations</span><span class="text-secondary">312 learners</span></div>
        <div class="progress" style="height:8px;"><div class="progress-bar" style="width:100%;"></div></div></div>
      <div class="mb-3"><div class="d-flex justify-content-between small mb-1"><span>Geometry Essentials</span><span class="text-secondary">189 learners</span></div>
        <div class="progress" style="height:8px;"><div class="progress-bar" style="width:61%;"></div></div></div>
      <div class="mb-3"><div class="d-flex justify-content-between small mb-1"><span>Calculus Kickstart</span><span class="text-secondary">97 learners</span></div>
        <div class="progress" style="height:8px;"><div class="progress-bar" style="width:31%;"></div></div></div>
    </div></div></div>
    <div class="col-12 col-lg-6"><div class="card border-0 shadow-sm h-100"><div class="card-body p-4">
      <h6 class="mb-3">Lesson completion rate</h6>
      <div class="mb-3"><div class="d-flex justify-content-between small mb-1"><span>Algebra Foundations</span><span class="text-secondary">78%</span></div>
        <div class="progress" style="height:8px;"><div class="progress-bar" style="width:78%;background-color:#1d8a5b;"></div></div></div>
      <div class="mb-3"><div class="d-flex justify-content-between small mb-1"><span>Geometry Essentials</span><span class="text-secondary">64%</span></div>
        <div class="progress" style="height:8px;"><div class="progress-bar" style="width:64%;background-color:#1d8a5b;"></div></div></div>
      <div class="mb-3"><div class="d-flex justify-content-between small mb-1"><span>Calculus Kickstart</span><span class="text-secondary">52%</span></div>
        <div class="progress" style="height:8px;"><div class="progress-bar" style="width:52%;background-color:#1d8a5b;"></div></div></div>
    </div></div></div>
  </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="../assets/js/app.js?v=4" data-username="${sessionScope.userName}"></script>
</body>
</html>

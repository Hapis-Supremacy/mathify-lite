<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Go Premium · Mathify</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Source+Sans+3:wght@400;500;600;700&family=Source+Serif+4:opsz,wght@8..60,500;8..60,600;8..60,700&display=swap" rel="stylesheet">
<link href="../assets/css/app.css" rel="stylesheet">
</head>
<body data-role="student" data-page="premium" data-base="../"
      data-energy="${globalStudent.energy}" data-xp="${globalProgress.totalXP}"
      data-energy-max="${globalStudent.maxEnergy}" data-energy-renews-at="${globalStudent.energyRenewalEpochMillis}"
      data-premium="${globalStudent.premiumActive}"
      data-level="${globalProgress.level}" data-streak="${globalProgress.currentStreak}">

<div class="container py-4 shell">

  <div class="text-center mb-4">
    <h2 class="mb-1">Go Premium</h2>
    <p class="text-secondary mb-0">Unlimited energy, offline lessons and detailed progress insights.</p>
  </div>

  <div class="row g-3 justify-content-center">
    <div class="col-12 col-md-5">
      <div class="card border-0 shadow-sm h-100"><div class="card-body p-4">
        <h5>Free</h5>
        <div class="fs-2 fw-bold mb-3">$0<span class="fs-6 text-secondary fw-normal">/mo</span></div>
        <ul class="list-unstyled d-flex flex-column gap-2 mb-4 text-secondary">
          <li><i class="bi bi-check2 me-2" style="color:#1d8a5b;"></i>All courses &amp; quizzes</li>
          <li><i class="bi bi-check2 me-2" style="color:#1d8a5b;"></i>5 energy, renewed after 4 hours</li>
          <li><i class="bi bi-dash me-2 text-secondary"></i>Limited progress insights</li>
        </ul>
        <button class="btn btn-outline-secondary w-100" disabled>Current plan</button>
      </div></div>
    </div>
    <div class="col-12 col-md-5">
      <div class="card border-0 shadow-sm h-100" style="outline:2px solid #1d4e89;"><div class="card-body p-4">
        <div class="d-flex justify-content-between align-items-center">
          <h5 class="mb-0">Premium</h5>
          <span class="badge" style="background:#1d4e89;">Popular</span>
        </div>
        <div class="fs-2 fw-bold mb-3 mt-2">$9<span class="fs-6 text-secondary fw-normal">/mo</span></div>
        <ul class="list-unstyled d-flex flex-column gap-2 mb-4">
          <li><i class="bi bi-check2 me-2" style="color:#1d8a5b;"></i>Everything in Free</li>
          <li><i class="bi bi-check2 me-2" style="color:#1d8a5b;"></i>Unlimited energy</li>
          <li><i class="bi bi-check2 me-2" style="color:#1d8a5b;"></i>Detailed progress insights</li>
          <li><i class="bi bi-check2 me-2" style="color:#1d8a5b;"></i>Offline lessons</li>
        </ul>
        <button class="btn btn-primary w-100"><i class="bi bi-gem me-1"></i>Upgrade to Premium</button>
      </div></div>
    </div>
  </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="../assets/js/app.js?v=6" data-username="${sessionScope.userName}"></script>
</body>
</html>

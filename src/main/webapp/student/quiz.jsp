<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Expressions Check · Mathify</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Source+Sans+3:wght@400;500;600;700&family=Source+Serif+4:opsz,wght@8..60,500;8..60,600;8..60,700&display=swap" rel="stylesheet">
<link href="../assets/css/app.css" rel="stylesheet">
<style>
  .quiz-option { cursor:pointer; }
  .quiz-dot { width:26px; height:26px; border:2px solid #9aa6b8; color:#9aa6b8; font-size:.8rem; }
  .quiz-option.selected { border-color:#1d4e89 !important; }
  .quiz-option.selected .quiz-dot { border-color:#1d4e89; color:#1d4e89; }
</style>
</head>
<body data-role="student" data-page="catalog" data-base="../">

<div class="container py-4 shell">

  <div class="d-flex justify-content-between align-items-center mb-2">
    <span class="text-secondary small fw-semibold">Expressions Check</span>
    <a class="text-secondary small" href="course.jsp?c=c1">Exit</a>
  </div>
  <div class="progress mb-4" style="height:8px;"><div class="progress-bar" style="width:0%;"></div></div>

  <div class="card border-0 shadow-sm"><div class="card-body p-4">
    <div class="text-secondary small mb-1">Question 1 of 3 · Multiple choice · 10 pts</div>
    <h4 class="mb-4">Which expression means "5 more than a number n"?</h4>

    <div class="d-flex flex-column gap-2" id="options">
      <label class="btn text-start d-flex align-items-center border p-3 rounded quiz-option">
        <span class="d-inline-flex align-items-center justify-content-center rounded-circle me-2 quiz-dot">A</span>n - 5
      </label>
      <label class="btn text-start d-flex align-items-center border p-3 rounded quiz-option">
        <span class="d-inline-flex align-items-center justify-content-center rounded-circle me-2 quiz-dot">B</span>5n
      </label>
      <label class="btn text-start d-flex align-items-center border p-3 rounded quiz-option">
        <span class="d-inline-flex align-items-center justify-content-center rounded-circle me-2 quiz-dot">C</span>n + 5
      </label>
      <label class="btn text-start d-flex align-items-center border p-3 rounded quiz-option">
        <span class="d-inline-flex align-items-center justify-content-center rounded-circle me-2 quiz-dot">D</span>5 / n
      </label>
    </div>

    <div class="d-flex justify-content-end mt-4 pt-3 border-top" style="border-color:#eef1f6;">
      <button class="btn btn-primary disabled" id="nextBtn">Next question</button>
    </div>
  </div></div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="../assets/js/app.js?v=4" data-username="${sessionScope.userName}"></script>
<script>
  // Lightweight single-select interaction for the demo question.
  var opts = document.querySelectorAll('#options .quiz-option');
  var next = document.getElementById('nextBtn');
  opts.forEach(function (o) {
    o.addEventListener('click', function () {
      opts.forEach(function (x) { x.classList.remove('selected'); });
      o.classList.add('selected');
      next.classList.remove('disabled');
    });
  });
</script>
</body>
</html>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Edit content · Mathify Admin</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Source+Sans+3:wght@400;500;600;700&family=Source+Serif+4:opsz,wght@8..60,500;8..60,600;8..60,700&display=swap" rel="stylesheet">
<link href="../assets/css/app.css" rel="stylesheet">
</head>
<body data-role="admin" data-page="courses" data-base="../">

<div class="container py-4 shell">

  <a class="text-secondary small d-inline-flex align-items-center gap-1 mb-3" href="courses.jsp"><i class="bi bi-arrow-left"></i>Back to courses</a>

  <div class="card border-0 shadow-sm mb-4"><div class="card-body p-4 d-flex justify-content-between align-items-start flex-wrap gap-3">
    <div><span class="badge rounded-pill mb-2 badge-soft">Algebra</span><h2 class="mb-1">Algebra Foundations</h2><p class="text-secondary mb-0">Build fluency with variables, expressions and linear equations from the ground up.</p></div>
    <button class="btn btn-outline-secondary btn-sm"><i class="bi bi-gear me-1"></i>Edit details</button>
  </div></div>

  <div class="d-flex justify-content-between align-items-center mb-3">
    <h4 class="mb-0">Chapters</h4>
    <button class="btn btn-outline-primary btn-sm"><i class="bi bi-plus-lg me-1"></i>Add chapter</button>
  </div>

  <!-- Chapter 1 -->
  <div class="card border-0 shadow-sm mb-3"><div class="card-body p-4">
    <div class="d-flex justify-content-between align-items-center mb-3">
      <div><div class="text-secondary small fw-semibold">CHAPTER 1 · 50 XP</div><h5 class="mb-0">Variables &amp; Expressions</h5></div>
      <div class="d-inline-flex gap-1">
        <button class="btn btn-sm btn-outline-secondary"><i class="bi bi-pencil"></i></button>
        <button class="btn btn-sm btn-outline-danger"><i class="bi bi-trash"></i></button>
      </div>
    </div>
    <div class="list-group list-group-flush mb-2">
      <div class="list-group-item d-flex align-items-center gap-3 px-2" style="border-color:#eef1f6;">
        <span class="icon-tile" style="width:34px;height:34px;"><i class="bi bi-play-circle-fill"></i></span>
        <span class="flex-grow-1"><span class="fw-semibold d-block">What is a Variable?</span><span class="text-secondary small">Video · 7:40</span></span>
        <button class="btn btn-sm btn-outline-secondary"><i class="bi bi-pencil"></i></button>
        <button class="btn btn-sm btn-outline-danger"><i class="bi bi-trash"></i></button>
      </div>
      <div class="list-group-item d-flex align-items-center gap-3 px-2" style="border-color:#eef1f6;">
        <span class="icon-tile" style="width:34px;height:34px;"><i class="bi bi-easel-fill"></i></span>
        <span class="flex-grow-1"><span class="fw-semibold d-block">Building Expressions</span><span class="text-secondary small">Slides · 6 slides</span></span>
        <button class="btn btn-sm btn-outline-secondary"><i class="bi bi-pencil"></i></button>
        <button class="btn btn-sm btn-outline-danger"><i class="bi bi-trash"></i></button>
      </div>
      <div class="list-group-item d-flex align-items-center gap-3 px-2" style="border-color:#eef1f6;">
        <span class="icon-tile icon-tile-warn" style="width:34px;height:34px;"><i class="bi bi-patch-question-fill"></i></span>
        <span class="flex-grow-1"><span class="fw-semibold d-block">Expressions Check</span><span class="text-secondary small">Quiz · pass 70% · 3 questions</span></span>
        <a class="btn btn-sm btn-primary" href="quiz-editor.jsp?q=q1"><i class="bi bi-list-check me-1"></i>Questions</a>
        <button class="btn btn-sm btn-outline-secondary" title="Edit quiz details"><i class="bi bi-pencil"></i></button>
        <button class="btn btn-sm btn-outline-danger"><i class="bi bi-trash"></i></button>
      </div>
    </div>
    <div class="d-flex gap-2">
      <button class="btn btn-sm btn-light"><i class="bi bi-plus-lg me-1"></i>Module</button>
      <button class="btn btn-sm btn-light"><i class="bi bi-plus-lg me-1"></i>Quiz</button>
    </div>
  </div></div>

  <!-- Chapter 2 -->
  <div class="card border-0 shadow-sm mb-3"><div class="card-body p-4">
    <div class="d-flex justify-content-between align-items-center mb-3">
      <div><div class="text-secondary small fw-semibold">CHAPTER 2 · 80 XP</div><h5 class="mb-0">Linear Equations</h5></div>
      <div class="d-inline-flex gap-1">
        <button class="btn btn-sm btn-outline-secondary"><i class="bi bi-pencil"></i></button>
        <button class="btn btn-sm btn-outline-danger"><i class="bi bi-trash"></i></button>
      </div>
    </div>
    <div class="list-group list-group-flush mb-2">
      <div class="list-group-item d-flex align-items-center gap-3 px-2" style="border-color:#eef1f6;">
        <span class="icon-tile" style="width:34px;height:34px;"><i class="bi bi-play-circle-fill"></i></span>
        <span class="flex-grow-1"><span class="fw-semibold d-block">Solving for x</span><span class="text-secondary small">Video · 9:10</span></span>
        <button class="btn btn-sm btn-outline-secondary"><i class="bi bi-pencil"></i></button>
        <button class="btn btn-sm btn-outline-danger"><i class="bi bi-trash"></i></button>
      </div>
      <div class="list-group-item d-flex align-items-center gap-3 px-2" style="border-color:#eef1f6;">
        <span class="icon-tile icon-tile-warn" style="width:34px;height:34px;"><i class="bi bi-patch-question-fill"></i></span>
        <span class="flex-grow-1"><span class="fw-semibold d-block">Equations Quiz</span><span class="text-secondary small">Quiz · pass 75% · 2 questions</span></span>
        <a class="btn btn-sm btn-primary" href="quiz-editor.jsp?q=q2"><i class="bi bi-list-check me-1"></i>Questions</a>
        <button class="btn btn-sm btn-outline-secondary" title="Edit quiz details"><i class="bi bi-pencil"></i></button>
        <button class="btn btn-sm btn-outline-danger"><i class="bi bi-trash"></i></button>
      </div>
    </div>
    <div class="d-flex gap-2">
      <button class="btn btn-sm btn-light"><i class="bi bi-plus-lg me-1"></i>Module</button>
      <button class="btn btn-sm btn-light"><i class="bi bi-plus-lg me-1"></i>Quiz</button>
    </div>
  </div></div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="../assets/js/app.js?v=4" data-username="${sessionScope.userName}"></script>
</body>
</html>

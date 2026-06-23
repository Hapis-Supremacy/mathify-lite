<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Quiz questions · Mathify Admin</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Source+Sans+3:wght@400;500;600;700&family=Source+Serif+4:opsz,wght@8..60,500;8..60,600;8..60,700&display=swap" rel="stylesheet">
<link href="../assets/css/app.css" rel="stylesheet">
</head>
<body data-role="admin" data-page="courses" data-base="../">

<div class="container py-4 shell">

  <a class="text-secondary small d-inline-flex align-items-center gap-1 mb-3" href="editor.jsp?c=c1"><i class="bi bi-arrow-left"></i>Back to course content</a>

  <div class="card border-0 shadow-sm mb-4"><div class="card-body p-4 d-flex justify-content-between align-items-start flex-wrap gap-3">
    <div>
      <div class="text-secondary small fw-semibold">QUIZ · Variables &amp; Expressions</div>
      <h2 class="mb-1">Expressions Check</h2>
      <span class="badge rounded-pill badge-warn-soft">Passing score 70%</span>
    </div>
    <button class="btn btn-outline-secondary btn-sm"><i class="bi bi-gear me-1"></i>Edit details</button>
  </div></div>

  <div class="d-flex justify-content-between align-items-center mb-3">
    <h4 class="mb-0">Questions</h4>
    <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#questionModal"><i class="bi bi-plus-lg me-1"></i>Add question</button>
  </div>

  <!-- Q1 multiple choice -->
  <div class="card border-0 shadow-sm mb-2"><div class="card-body p-3 d-flex align-items-start gap-3">
    <span class="badge rounded-pill mt-1 badge-soft" style="flex:none;">Multiple choice</span>
    <div class="flex-grow-1">
      <div class="fw-semibold">1. Which expression means "5 more than a number n"?</div>
      <div class="text-secondary small">4 options · 10 pts</div>
    </div>
    <button class="btn btn-sm btn-outline-secondary"><i class="bi bi-pencil"></i></button>
    <button class="btn btn-sm btn-outline-danger"><i class="bi bi-trash"></i></button>
  </div></div>

  <!-- Q2 fill -->
  <div class="card border-0 shadow-sm mb-2"><div class="card-body p-3 d-flex align-items-start gap-3">
    <span class="badge rounded-pill mt-1 badge-warn-soft" style="flex:none;">Fill in the blank</span>
    <div class="flex-grow-1">
      <div class="fw-semibold">2. Simplify: 3x + 2x = ___ x</div>
      <div class="text-secondary small">1 accepted · 10 pts</div>
    </div>
    <button class="btn btn-sm btn-outline-secondary"><i class="bi bi-pencil"></i></button>
    <button class="btn btn-sm btn-outline-danger"><i class="bi bi-trash"></i></button>
  </div></div>

  <!-- Q3 match -->
  <div class="card border-0 shadow-sm mb-2"><div class="card-body p-3 d-flex align-items-start gap-3">
    <span class="badge rounded-pill mt-1 badge-success-soft" style="flex:none;">Match pairs</span>
    <div class="flex-grow-1">
      <div class="fw-semibold">3. Match each phrase to its expression.</div>
      <div class="text-secondary small">3 pairs · 15 pts</div>
    </div>
    <button class="btn btn-sm btn-outline-secondary"><i class="bi bi-pencil"></i></button>
    <button class="btn btn-sm btn-outline-danger"><i class="bi bi-trash"></i></button>
  </div></div>

</div>

<!-- Add question modal (type switches the body) -->
<div class="modal fade" id="questionModal" tabindex="-1">
  <div class="modal-dialog modal-lg">
    <div class="modal-content border-0">
      <div class="modal-header"><h5 class="modal-title">Add question</h5><button class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="mb-3"><label class="form-label small fw-semibold">Question type</label>
          <select class="form-select" id="qType">
            <option value="MULTIPLE_CHOICE">Multiple choice</option>
            <option value="FILL_BLANK">Fill in the blank</option>
            <option value="DRAG_AND_DROP">Match pairs</option>
          </select></div>
        <div class="mb-3"><label class="form-label small fw-semibold">Prompt</label><textarea class="form-control" rows="2"></textarea></div>
        <div class="mb-3" style="max-width:150px;"><label class="form-label small fw-semibold">Points</label><input class="form-control" type="number" value="10"></div>

        <div data-qbody="MULTIPLE_CHOICE">
          <label class="form-label small fw-semibold mb-2">Options <span class="text-secondary fw-normal">— tick the correct answer(s)</span></label>
          <div class="d-flex align-items-center gap-2 mb-2"><input class="form-check-input mt-0" type="checkbox" style="flex:none;"><input class="form-control" placeholder="Option text"><button class="btn btn-sm btn-outline-secondary" style="flex:none;"><i class="bi bi-x-lg"></i></button></div>
          <div class="d-flex align-items-center gap-2 mb-2"><input class="form-check-input mt-0" type="checkbox" style="flex:none;"><input class="form-control" placeholder="Option text"><button class="btn btn-sm btn-outline-secondary" style="flex:none;"><i class="bi bi-x-lg"></i></button></div>
          <button class="btn btn-sm btn-light"><i class="bi bi-plus-lg me-1"></i>Add option</button>
        </div>

        <div data-qbody="FILL_BLANK" class="d-none">
          <label class="form-label small fw-semibold mb-2">Accepted answers</label>
          <div class="d-flex align-items-center gap-2 mb-2"><input class="form-control" placeholder="e.g. 5"><button class="btn btn-sm btn-outline-secondary" style="flex:none;"><i class="bi bi-x-lg"></i></button></div>
          <button class="btn btn-sm btn-light"><i class="bi bi-plus-lg me-1"></i>Add answer</button>
          <div class="form-check mt-3"><input class="form-check-input" type="checkbox" id="csbox"><label class="form-check-label small" for="csbox">Case sensitive</label></div>
        </div>

        <div data-qbody="DRAG_AND_DROP" class="d-none">
          <label class="form-label small fw-semibold mb-2">Pairs to match</label>
          <div class="d-flex align-items-center gap-2 mb-2"><input class="form-control" placeholder="Term"><i class="bi bi-arrow-right text-secondary" style="flex:none;"></i><input class="form-control" placeholder="Matches with"><button class="btn btn-sm btn-outline-secondary" style="flex:none;"><i class="bi bi-x-lg"></i></button></div>
          <div class="d-flex align-items-center gap-2 mb-2"><input class="form-control" placeholder="Term"><i class="bi bi-arrow-right text-secondary" style="flex:none;"></i><input class="form-control" placeholder="Matches with"><button class="btn btn-sm btn-outline-secondary" style="flex:none;"><i class="bi bi-x-lg"></i></button></div>
          <button class="btn btn-sm btn-light"><i class="bi bi-plus-lg me-1"></i>Add pair</button>
        </div>
      </div>
      <div class="modal-footer">
        <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
        <button class="btn btn-primary" data-bs-dismiss="modal">Add question</button>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="../assets/js/app.js?v=4" data-username="${sessionScope.userName}"></script>
<script>
  // Show the matching question body for the selected type.
  var qType = document.getElementById('qType');
  function syncQBody() {
    document.querySelectorAll('[data-qbody]').forEach(function (b) {
      b.classList.toggle('d-none', b.dataset.qbody !== qType.value);
    });
  }
  qType.addEventListener('change', syncQBody);
  syncQBody();
</script>
</body>
</html>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:if test="${empty requestScope.quizEditorLoaded}">
    <jsp:forward page="/admin/quiz-editor.do" />
</c:if>
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

  <a class="text-secondary small d-inline-flex align-items-center gap-1 mb-3" href="editor.do?c=${courseId}"><i class="bi bi-arrow-left"></i>Back to course content</a>

  <div class="card border-0 shadow-sm mb-4"><div class="card-body p-4 d-flex justify-content-between align-items-start flex-wrap gap-3">
    <div>
      <div class="text-secondary small fw-semibold">QUIZ</div>
      <h2 class="mb-1"><c:out value="${quiz.title}"/></h2>
      <span class="badge rounded-pill badge-warn-soft">Passing score ${quiz.passingScore}%</span>
    </div>
  </div></div>

  <div class="d-flex justify-content-between align-items-center mb-3">
    <h4 class="mb-0">Questions</h4>
    <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#questionModal"><i class="bi bi-plus-lg me-1"></i>Add question</button>
  </div>

  <c:forEach var="q" items="${quiz.questions}" varStatus="st">
      <div class="card border-0 shadow-sm mb-2"><div class="card-body p-3 d-flex align-items-start gap-3">
        <c:choose>
            <c:when test="${q.type.name() == 'MULTIPLE_CHOICE'}">
                <span class="badge rounded-pill mt-1 badge-soft" style="flex:none;">Multiple choice</span>
            </c:when>
            <c:when test="${q.type.name() == 'FILL_BLANK'}">
                <span class="badge rounded-pill mt-1 badge-warn-soft" style="flex:none;">Fill in the blank</span>
            </c:when>
            <c:when test="${q.type.name() == 'DRAG_AND_DROP'}">
                <span class="badge rounded-pill mt-1 badge-success-soft" style="flex:none;">Match pairs</span>
            </c:when>
        </c:choose>
        
        <div class="flex-grow-1">
          <div class="fw-semibold">${st.index + 1}. <c:out value="${q.info.prompt()}"/></div>
          <div class="text-secondary small">${q.info.points()} pts</div>
        </div>
        <form action="${pageContext.request.contextPath}/admin/quiz-action.do" method="post" class="m-0 p-0" onsubmit="return confirm('Delete this question?');">
            <input type="hidden" name="action" value="delete_question"/>
            <input type="hidden" name="quizId" value="${quiz.quizId}"/>
            <input type="hidden" name="courseId" value="${courseId}"/>
            <input type="hidden" name="questionId" value="${q.info.id()}"/>
            <button type="submit" class="btn btn-sm btn-outline-danger"><i class="bi bi-trash"></i></button>
        </form>
      </div></div>
  </c:forEach>
  <c:if test="${empty quiz.questions}">
      <div class="text-center text-secondary py-4">No questions yet.</div>
  </c:if>

</div>

<!-- Add question modal -->
<div class="modal fade" id="questionModal" tabindex="-1">
  <div class="modal-dialog modal-lg">
    <form class="modal-content border-0" action="${pageContext.request.contextPath}/admin/quiz-action.do" method="post">
      <input type="hidden" name="action" value="create_question"/>
      <input type="hidden" name="quizId" value="${quiz.quizId}"/>
      <input type="hidden" name="courseId" value="${courseId}"/>
      <input type="hidden" name="orderIndex" value="${quiz.questions.size()}"/>
      
      <div class="modal-header"><h5 class="modal-title">Add question</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="mb-3"><label class="form-label small fw-semibold">Question type</label>
          <select class="form-select" name="qType" id="qType">
            <option value="MULTIPLE_CHOICE">Multiple choice</option>
            <option value="FILL_BLANK">Fill in the blank</option>
            <option value="DRAG_AND_DROP">Match pairs</option>
          </select></div>
        <div class="mb-3"><label class="form-label small fw-semibold">Prompt</label><textarea class="form-control" name="prompt" rows="2" required></textarea></div>
        <div class="mb-3" style="max-width:150px;"><label class="form-label small fw-semibold">Points</label><input class="form-control" name="points" type="number" value="10" required></div>

        <div data-qbody="MULTIPLE_CHOICE" id="mcContainer">
          <label class="form-label small fw-semibold mb-2">Options <span class="text-secondary fw-normal">- tick the correct answer(s)</span></label>
          <div id="mcRows">
              <div class="d-flex align-items-center gap-2 mb-2 mc-row">
                  <input class="form-check-input mt-0 mc-cb" type="checkbox" name="mcCorrectIndex" value="0" style="flex:none;">
                  <input class="form-control" name="mcOptionText" placeholder="Option text" required>
                  <button type="button" class="btn btn-sm btn-outline-secondary btn-rm" style="flex:none;"><i class="bi bi-x-lg"></i></button>
              </div>
          </div>
          <button type="button" class="btn btn-sm btn-light" id="btnAddMc"><i class="bi bi-plus-lg me-1"></i>Add option</button>
        </div>

        <div data-qbody="FILL_BLANK" class="d-none" id="fbContainer">
          <label class="form-label small fw-semibold mb-2">Accepted answers</label>
          <div id="fbRows">
              <div class="d-flex align-items-center gap-2 mb-2 fb-row">
                  <input class="form-control" name="fbAnswer" placeholder="e.g. 5">
                  <button type="button" class="btn btn-sm btn-outline-secondary btn-rm" style="flex:none;"><i class="bi bi-x-lg"></i></button>
              </div>
          </div>
          <button type="button" class="btn btn-sm btn-light" id="btnAddFb"><i class="bi bi-plus-lg me-1"></i>Add answer</button>
          <div class="form-check mt-3"><input class="form-check-input" type="checkbox" name="caseSensitive" id="csbox"><label class="form-check-label small" for="csbox">Case sensitive</label></div>
        </div>

        <div data-qbody="DRAG_AND_DROP" class="d-none" id="ddContainer">
          <label class="form-label small fw-semibold mb-2">Pairs to match</label>
          <div id="ddRows">
              <div class="d-flex align-items-center gap-2 mb-2 dd-row">
                  <input class="form-control" name="ddDrag" placeholder="Term">
                  <i class="bi bi-arrow-right text-secondary" style="flex:none;"></i>
                  <input class="form-control" name="ddDrop" placeholder="Matches with">
                  <button type="button" class="btn btn-sm btn-outline-secondary btn-rm" style="flex:none;"><i class="bi bi-x-lg"></i></button>
              </div>
          </div>
          <button type="button" class="btn btn-sm btn-light" id="btnAddDd"><i class="bi bi-plus-lg me-1"></i>Add pair</button>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="submit" class="btn btn-primary">Save question</button>
      </div>
    </form>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
  // Show the matching question body for the selected type.
  var qType = document.getElementById('qType');
  function syncQBody() {
    document.querySelectorAll('[data-qbody]').forEach(function (b) {
      b.classList.toggle('d-none', b.dataset.qbody !== qType.value);
    });
    // disable inputs in hidden containers to prevent them from validating or submitting empty arrays
    document.querySelectorAll('[data-qbody] input').forEach(function(inp) {
        if (inp.closest('.d-none')) {
            inp.disabled = true;
        } else {
            inp.disabled = false;
        }
    });
  }
  qType.addEventListener('change', syncQBody);
  syncQBody();

  // Dynamic row logic
  document.getElementById('btnAddMc').addEventListener('click', function() {
      var rows = document.getElementById('mcRows');
      var idx = rows.children.length;
      var html = '<div class="d-flex align-items-center gap-2 mb-2 mc-row">' +
          '<input class="form-check-input mt-0 mc-cb" type="checkbox" name="mcCorrectIndex" value="' + idx + '" style="flex:none;">' +
          '<input class="form-control" name="mcOptionText" placeholder="Option text" required>' +
          '<button type="button" class="btn btn-sm btn-outline-secondary btn-rm" style="flex:none;"><i class="bi bi-x-lg"></i></button></div>';
      rows.insertAdjacentHTML('beforeend', html);
  });

  document.getElementById('btnAddFb').addEventListener('click', function() {
      var rows = document.getElementById('fbRows');
      var html = '<div class="d-flex align-items-center gap-2 mb-2 fb-row">' +
          '<input class="form-control" name="fbAnswer" placeholder="e.g. 5">' +
          '<button type="button" class="btn btn-sm btn-outline-secondary btn-rm" style="flex:none;"><i class="bi bi-x-lg"></i></button></div>';
      rows.insertAdjacentHTML('beforeend', html);
  });

  document.getElementById('btnAddDd').addEventListener('click', function() {
      var rows = document.getElementById('ddRows');
      var html = '<div class="d-flex align-items-center gap-2 mb-2 dd-row">' +
          '<input class="form-control" name="ddDrag" placeholder="Term">' +
          '<i class="bi bi-arrow-right text-secondary" style="flex:none;"></i>' +
          '<input class="form-control" name="ddDrop" placeholder="Matches with">' +
          '<button type="button" class="btn btn-sm btn-outline-secondary btn-rm" style="flex:none;"><i class="bi bi-x-lg"></i></button></div>';
      rows.insertAdjacentHTML('beforeend', html);
  });

  document.addEventListener('click', function(e) {
      if (e.target.closest('.btn-rm')) {
          var btn = e.target.closest('.btn-rm');
          btn.parentElement.remove();
          // Update mcCorrectIndex values for Multiple Choice
          var mcRows = document.querySelectorAll('.mc-row');
          mcRows.forEach(function(row, i) {
              var cb = row.querySelector('.mc-cb');
              if(cb) cb.value = i;
          });
      }
  });
</script>
</body>
</html>

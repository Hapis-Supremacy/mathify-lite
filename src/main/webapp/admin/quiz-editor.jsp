<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
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
        <button type="button" class="btn btn-sm btn-outline-secondary" data-bs-toggle="modal" data-bs-target="#editModal-${q.info.id()}"><i class="bi bi-pencil"></i></button>
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
<my:questionForm modalId="questionModal" title="Add question" action="create_question"
                 quizId="${quiz.quizId}" courseId="${courseId}" index="${quiz.questions.size()}"/>

<!-- Per-question edit modals -->
<c:forEach var="q" items="${quiz.questions}" varStatus="st">
  <my:questionForm modalId="editModal-${q.info.id()}" title="Edit question" action="update_question"
                   quizId="${quiz.quizId}" courseId="${courseId}" index="${st.index}" question="${q}"/>
</c:forEach>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
  // Each question form (the Add modal and every Edit modal) manages its own
  // type toggle and dynamic rows, scoped to itself so multiple forms coexist.
  document.querySelectorAll('.question-form').forEach(function (form) {
    var qType = form.querySelector('.js-qtype');

    function syncQBody() {
      form.querySelectorAll('[data-qbody]').forEach(function (b) {
        var hidden = b.dataset.qbody !== qType.value;
        b.classList.toggle('d-none', hidden);
        // Disable inputs in hidden bodies so they neither validate nor submit.
        b.querySelectorAll('input').forEach(function (inp) { inp.disabled = hidden; });
      });
    }
    qType.addEventListener('change', syncQBody);
    syncQBody();

    var addMc = form.querySelector('.js-add-mc');
    if (addMc) addMc.addEventListener('click', function () {
      var rows = form.querySelector('.js-mc-rows');
      var idx = rows.querySelectorAll('.mc-row').length;
      rows.insertAdjacentHTML('beforeend',
        '<div class="d-flex align-items-center gap-2 mb-2 mc-row">' +
        '<input class="form-check-input mt-0 mc-cb" type="checkbox" name="mcCorrectIndex" value="' + idx + '" style="flex:none;">' +
        '<input class="form-control" name="mcOptionText" placeholder="Option text" required>' +
        '<button type="button" class="btn btn-sm btn-outline-secondary btn-rm" style="flex:none;"><i class="bi bi-x-lg"></i></button></div>');
    });

    var addFb = form.querySelector('.js-add-fb');
    if (addFb) addFb.addEventListener('click', function () {
      var rows = form.querySelector('.js-fb-rows');
      rows.insertAdjacentHTML('beforeend',
        '<div class="d-flex align-items-center gap-2 mb-2 fb-row">' +
        '<input class="form-control" name="fbAnswer" placeholder="e.g. 5">' +
        '<button type="button" class="btn btn-sm btn-outline-secondary btn-rm" style="flex:none;"><i class="bi bi-x-lg"></i></button></div>');
    });

    var addDd = form.querySelector('.js-add-dd');
    if (addDd) addDd.addEventListener('click', function () {
      var rows = form.querySelector('.js-dd-rows');
      rows.insertAdjacentHTML('beforeend',
        '<div class="d-flex align-items-center gap-2 mb-2 dd-row">' +
        '<input class="form-control" name="ddDrag" placeholder="Term">' +
        '<i class="bi bi-arrow-right text-secondary" style="flex:none;"></i>' +
        '<input class="form-control" name="ddDrop" placeholder="Matches with">' +
        '<button type="button" class="btn btn-sm btn-outline-secondary btn-rm" style="flex:none;"><i class="bi bi-x-lg"></i></button></div>');
    });
  });

  // Remove a dynamic row, then re-index the multiple-choice checkboxes in that
  // form so mcCorrectIndex stays aligned with the option order on submit.
  document.addEventListener('click', function (e) {
    var rm = e.target.closest('.btn-rm');
    if (!rm) return;
    var form = rm.closest('.question-form');
    rm.parentElement.remove();
    if (form) {
      form.querySelectorAll('.mc-row').forEach(function (row, i) {
        var cb = row.querySelector('.mc-cb');
        if (cb) cb.value = i;
      });
    }
  });
</script>
</body>
</html>

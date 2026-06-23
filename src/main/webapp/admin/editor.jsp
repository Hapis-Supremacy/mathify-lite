<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:if test="${empty requestScope.editorLoaded}">
    <jsp:forward page="/admin/courses.do" />
</c:if>
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

  <a class="text-secondary small d-inline-flex align-items-center gap-1 mb-3" href="courses.do"><i class="bi bi-arrow-left"></i>Back to courses</a>

  <div id="editor-alert" class="alert d-none" role="alert"></div>

  <div class="card border-0 shadow-sm mb-4"><div class="card-body p-4">
    <span class="badge rounded-pill mb-2 badge-soft"><c:out value="${course.category}"/></span>
    <h2 class="mb-1"><c:out value="${course.title}"/></h2>
    <p class="text-secondary mb-0"><c:out value="${course.description}"/></p>
  </div></div>

  <div class="d-flex justify-content-between align-items-center mb-3">
    <h4 class="mb-0">Chapters</h4>
    <button class="btn btn-outline-primary btn-sm js-add-chapter" data-next-order="${chapters.size()}"><i class="bi bi-plus-lg me-1"></i>Add chapter</button>
  </div>

  <c:if test="${empty chapters}">
    <div class="card border-0 shadow-sm mb-3"><div class="card-body p-4 text-secondary text-center">
      No chapters yet. Click <span class="fw-semibold">Add chapter</span> to start building this course.
    </div></div>
  </c:if>

  <c:forEach var="chapter" items="${chapters}" varStatus="cs">
  <div class="card border-0 shadow-sm mb-3"><div class="card-body p-4">
    <div class="d-flex justify-content-between align-items-center mb-3">
      <div>
        <div class="text-secondary small fw-semibold">CHAPTER ${cs.index + 1} · ${chapter.xpReward} XP</div>
        <h5 class="mb-0"><c:out value="${chapter.title}"/></h5>
      </div>
      <div class="d-inline-flex gap-1">
        <button class="btn btn-sm btn-outline-secondary js-edit-chapter"
                data-chapter-id="${chapter.chapterId}"
                data-title="<c:out value="${chapter.title}"/>"
                data-description="<c:out value="${chapter.description}"/>"
                data-xp="${chapter.xpReward}" data-order="${chapter.orderIndex}"><i class="bi bi-pencil"></i></button>
        <button class="btn btn-sm btn-outline-danger js-delete"
                data-entity="chapter" data-id-param="chapterId" data-id="${chapter.chapterId}"
                data-name="<c:out value="${chapter.title}"/>"><i class="bi bi-trash"></i></button>
      </div>
    </div>

    <div class="list-group list-group-flush mb-2">
      <c:forEach var="module" items="${chapter.modules}">
      <div class="list-group-item d-flex align-items-center gap-3 px-2" style="border-color:#eef1f6;">
        <span class="icon-tile" style="width:34px;height:34px;">
          <i class="bi ${module.moduleType == 'VIDEO' ? 'bi-play-circle-fill' : 'bi-easel-fill'}"></i>
        </span>
        <span class="flex-grow-1">
          <span class="fw-semibold d-block"><c:out value="${module.title}"/></span>
          <span class="text-secondary small">
            <c:choose>
              <c:when test="${module.moduleType == 'VIDEO'}">Video · ${module.durationSecs}s</c:when>
              <c:otherwise>Slides · ${module.slideCount} slides</c:otherwise>
            </c:choose>
          </span>
        </span>
        <button class="btn btn-sm btn-outline-secondary js-edit-module"
                data-module-id="${module.moduleId}"
                data-title="<c:out value="${module.title}"/>"
                data-type="${module.moduleType}"
                data-url="<c:out value="${module.contentUrl}"/>"
                data-duration="${module.durationSecs}" data-slides="${module.slideCount}"
                data-order="${module.orderIndex}"><i class="bi bi-pencil"></i></button>
        <button class="btn btn-sm btn-outline-danger js-delete"
                data-entity="module" data-id-param="moduleId" data-id="${module.moduleId}"
                data-name="<c:out value="${module.title}"/>"><i class="bi bi-trash"></i></button>
      </div>
      </c:forEach>

      <c:forEach var="quiz" items="${chapter.quizzes}">
      <div class="list-group-item d-flex align-items-center gap-3 px-2" style="border-color:#eef1f6;">
        <span class="icon-tile icon-tile-warn" style="width:34px;height:34px;"><i class="bi bi-patch-question-fill"></i></span>
        <span class="flex-grow-1">
          <span class="fw-semibold d-block"><c:out value="${quiz.title}"/></span>
          <span class="text-secondary small">Quiz · pass ${quiz.passingScore}% · ${quiz.questionCount} questions</span>
        </span>
        <a class="btn btn-sm btn-primary" href="quiz-editor.do?q=${quiz.quizId}"><i class="bi bi-list-check me-1"></i>Questions</a>
        <button class="btn btn-sm btn-outline-secondary js-edit-quiz"
                data-quiz-id="${quiz.quizId}"
                data-title="<c:out value="${quiz.title}"/>"
                data-pass="${quiz.passingScore}"><i class="bi bi-pencil"></i></button>
        <button class="btn btn-sm btn-outline-danger js-delete"
                data-entity="quiz" data-id-param="quizId" data-id="${quiz.quizId}"
                data-name="<c:out value="${quiz.title}"/>"><i class="bi bi-trash"></i></button>
      </div>
      </c:forEach>

      <c:if test="${empty chapter.modules and empty chapter.quizzes}">
      <div class="list-group-item px-2 text-secondary small" style="border-color:#eef1f6;">No modules or quizzes yet.</div>
      </c:if>
    </div>

    <div class="d-flex gap-2">
      <button class="btn btn-sm btn-light js-add-module" data-chapter-id="${chapter.chapterId}" data-next-order="${chapter.modules.size()}"><i class="bi bi-plus-lg me-1"></i>Module</button>
      <button class="btn btn-sm btn-light js-add-quiz" data-chapter-id="${chapter.chapterId}"><i class="bi bi-plus-lg me-1"></i>Quiz</button>
    </div>
  </div></div>
  </c:forEach>

</div>

<!-- Chapter modal -->
<div class="modal fade" id="chapterModal" tabindex="-1">
  <div class="modal-dialog">
    <form class="modal-content border-0" action="${pageContext.request.contextPath}/admin/content-action.do" method="post">
      <input type="hidden" name="entity" value="chapter"/>
      <input type="hidden" name="action" id="chapter-action"/>
      <input type="hidden" name="courseId" value="${course.courseId}"/>
      <input type="hidden" name="chapterId" id="chapter-id"/>
      <div class="modal-header"><h5 class="modal-title" id="chapter-modal-title">Add chapter</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="mb-3"><label class="form-label small fw-semibold">Title</label><input class="form-control" name="title" id="chapter-title" required></div>
        <div class="mb-3"><label class="form-label small fw-semibold">Description</label><textarea class="form-control" name="description" id="chapter-description" rows="2"></textarea></div>
        <div class="row g-3">
          <div class="col-6"><label class="form-label small fw-semibold">XP reward</label><input type="number" min="0" class="form-control" name="xpReward" id="chapter-xp" value="0"></div>
          <div class="col-6"><label class="form-label small fw-semibold">Order</label><input type="number" min="0" class="form-control" name="orderIndex" id="chapter-order" value="0"></div>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="submit" class="btn btn-primary">Save chapter</button>
      </div>
    </form>
  </div>
</div>

<!-- Module modal -->
<div class="modal fade" id="moduleModal" tabindex="-1">
  <div class="modal-dialog">
    <form class="modal-content border-0" action="${pageContext.request.contextPath}/admin/content-action.do" method="post">
      <input type="hidden" name="entity" value="module"/>
      <input type="hidden" name="action" id="module-action"/>
      <input type="hidden" name="courseId" value="${course.courseId}"/>
      <input type="hidden" name="chapterId" id="module-chapter-id"/>
      <input type="hidden" name="moduleId" id="module-id"/>
      <div class="modal-header"><h5 class="modal-title" id="module-modal-title">Add module</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="mb-3"><label class="form-label small fw-semibold">Title</label><input class="form-control" name="title" id="module-title" required></div>
        <div class="mb-3"><label class="form-label small fw-semibold">Type</label>
          <select class="form-select" name="moduleType" id="module-type">
            <option value="VIDEO">Video</option>
            <option value="SLIDE">Slides</option>
          </select>
        </div>
        <div class="mb-3"><label class="form-label small fw-semibold">Content URL</label><input class="form-control" name="contentUrl" id="module-url" placeholder="https://..." required></div>
        <div class="row g-3">
          <div class="col-6" id="module-duration-wrap"><label class="form-label small fw-semibold">Duration (seconds)</label><input type="number" min="0" class="form-control" name="durationSecs" id="module-duration" value="0"></div>
          <div class="col-6 d-none" id="module-slides-wrap"><label class="form-label small fw-semibold">Slide count</label><input type="number" min="1" class="form-control" name="slideCount" id="module-slides" value="1"></div>
          <div class="col-6"><label class="form-label small fw-semibold">Order</label><input type="number" min="0" class="form-control" name="orderIndex" id="module-order" value="0"></div>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="submit" class="btn btn-primary">Save module</button>
      </div>
    </form>
  </div>
</div>

<!-- Quiz modal -->
<div class="modal fade" id="quizModal" tabindex="-1">
  <div class="modal-dialog">
    <form class="modal-content border-0" action="${pageContext.request.contextPath}/admin/content-action.do" method="post">
      <input type="hidden" name="entity" value="quiz"/>
      <input type="hidden" name="action" id="quiz-action"/>
      <input type="hidden" name="courseId" value="${course.courseId}"/>
      <input type="hidden" name="chapterId" id="quiz-chapter-id"/>
      <input type="hidden" name="quizId" id="quiz-id"/>
      <div class="modal-header"><h5 class="modal-title" id="quiz-modal-title">Add quiz</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="mb-3"><label class="form-label small fw-semibold">Title</label><input class="form-control" name="title" id="quiz-title" required></div>
        <div class="mb-3"><label class="form-label small fw-semibold">Passing score (%)</label><input type="number" min="0" max="100" class="form-control" name="passingScore" id="quiz-pass" value="70"></div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="submit" class="btn btn-primary">Save quiz</button>
      </div>
    </form>
  </div>
</div>

<!-- Delete confirm modal -->
<div class="modal fade" id="confirmDeleteModal" tabindex="-1">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content border-0 shadow">
      <div class="modal-header border-0 pb-0">
        <h5 class="modal-title d-flex align-items-center gap-2">
          <span class="d-inline-flex align-items-center justify-content-center rounded-circle bg-danger-subtle text-danger-emphasis" style="width:2.25rem;height:2.25rem;"><i class="bi bi-trash"></i></span>
          <span class="js-delete-heading">Delete</span>
        </h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body pt-2 text-secondary js-delete-message"></div>
      <div class="modal-footer border-0 pt-0">
        <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
        <button type="button" class="btn btn-danger js-delete-ok">Delete</button>
      </div>
    </div>
  </div>
</div>

<form id="content-delete-form" action="${pageContext.request.contextPath}/admin/content-action.do" method="post" class="d-none">
  <input type="hidden" name="action" value="delete"/>
  <input type="hidden" name="courseId" value="${course.courseId}"/>
  <input type="hidden" name="entity" id="del-entity"/>
  <input type="hidden" name="" id="del-id"/>
</form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
  (function () {
    // ---- error banner ----
    var errors = {
      in_use: "That item can't be deleted because students already have progress or attempts on it.",
      server_error: "Something went wrong. Please try again.",
      not_found: "That course no longer exists."
    };
    var code = new URLSearchParams(window.location.search).get("error");
    if (code) {
      var alertEl = document.getElementById("editor-alert");
      alertEl.textContent = errors[code] || "Something went wrong.";
      alertEl.classList.remove("d-none");
      alertEl.classList.add("alert-danger");
    }

    function val(id) { return document.getElementById(id); }

    // ---- chapter modal ----
    var chapterModal = new bootstrap.Modal(document.getElementById("chapterModal"));
    document.querySelector(".js-add-chapter").addEventListener("click", function () {
      val("chapter-action").value = "create";
      val("chapter-id").value = "";
      val("chapter-title").value = "";
      val("chapter-description").value = "";
      val("chapter-xp").value = "0";
      val("chapter-order").value = this.dataset.nextOrder || "0";
      val("chapter-modal-title").textContent = "Add chapter";
      chapterModal.show();
    });
    document.querySelectorAll(".js-edit-chapter").forEach(function (btn) {
      btn.addEventListener("click", function () {
        val("chapter-action").value = "update";
        val("chapter-id").value = btn.dataset.chapterId;
        val("chapter-title").value = btn.dataset.title;
        val("chapter-description").value = btn.dataset.description || "";
        val("chapter-xp").value = btn.dataset.xp || "0";
        val("chapter-order").value = btn.dataset.order || "0";
        val("chapter-modal-title").textContent = "Edit chapter";
        chapterModal.show();
      });
    });

    // ---- module modal ----
    var moduleModal = new bootstrap.Modal(document.getElementById("moduleModal"));
    function toggleModuleType() {
      var isVideo = val("module-type").value === "VIDEO";
      val("module-duration-wrap").classList.toggle("d-none", !isVideo);
      val("module-slides-wrap").classList.toggle("d-none", isVideo);
    }
    val("module-type").addEventListener("change", toggleModuleType);
    document.querySelectorAll(".js-add-module").forEach(function (btn) {
      btn.addEventListener("click", function () {
        val("module-action").value = "create";
        val("module-id").value = "";
        val("module-chapter-id").value = btn.dataset.chapterId;
        val("module-title").value = "";
        val("module-type").value = "VIDEO";
        val("module-url").value = "";
        val("module-duration").value = "0";
        val("module-slides").value = "1";
        val("module-order").value = btn.dataset.nextOrder || "0";
        val("module-modal-title").textContent = "Add module";
        toggleModuleType();
        moduleModal.show();
      });
    });
    document.querySelectorAll(".js-edit-module").forEach(function (btn) {
      btn.addEventListener("click", function () {
        val("module-action").value = "update";
        val("module-id").value = btn.dataset.moduleId;
        val("module-chapter-id").value = "";
        val("module-title").value = btn.dataset.title;
        val("module-type").value = btn.dataset.type;
        val("module-url").value = btn.dataset.url || "";
        val("module-duration").value = (btn.dataset.duration && btn.dataset.duration !== "") ? btn.dataset.duration : "0";
        val("module-slides").value = (btn.dataset.slides && btn.dataset.slides !== "") ? btn.dataset.slides : "1";
        val("module-order").value = btn.dataset.order || "0";
        val("module-modal-title").textContent = "Edit module";
        toggleModuleType();
        moduleModal.show();
      });
    });

    // ---- quiz modal ----
    var quizModal = new bootstrap.Modal(document.getElementById("quizModal"));
    document.querySelectorAll(".js-add-quiz").forEach(function (btn) {
      btn.addEventListener("click", function () {
        val("quiz-action").value = "create";
        val("quiz-id").value = "";
        val("quiz-chapter-id").value = btn.dataset.chapterId;
        val("quiz-title").value = "";
        val("quiz-pass").value = "70";
        val("quiz-modal-title").textContent = "Add quiz";
        quizModal.show();
      });
    });
    document.querySelectorAll(".js-edit-quiz").forEach(function (btn) {
      btn.addEventListener("click", function () {
        val("quiz-action").value = "update";
        val("quiz-id").value = btn.dataset.quizId;
        val("quiz-chapter-id").value = "";
        val("quiz-title").value = btn.dataset.title;
        val("quiz-pass").value = btn.dataset.pass || "0";
        val("quiz-modal-title").textContent = "Edit quiz";
        quizModal.show();
      });
    });

    // ---- delete confirm ----
    var delModal = new bootstrap.Modal(document.getElementById("confirmDeleteModal"));
    var delModalEl = document.getElementById("confirmDeleteModal");
    var delHeading = delModalEl.querySelector(".js-delete-heading");
    var delMessage = delModalEl.querySelector(".js-delete-message");
    var delOk = delModalEl.querySelector(".js-delete-ok");
    var pending = null;
    document.querySelectorAll(".js-delete").forEach(function (btn) {
      btn.addEventListener("click", function () {
        pending = { entity: btn.dataset.entity, idParam: btn.dataset.idParam, id: btn.dataset.id };
        delHeading.textContent = "Delete " + btn.dataset.entity;
        var extra = btn.dataset.entity === "chapter"
          ? " and everything inside it" : "";
        delMessage.textContent = "Delete “" + (btn.dataset.name || "this item") + "”" + extra + "? This cannot be undone.";
        delModal.show();
      });
    });
    delOk.addEventListener("click", function () {
      if (!pending) return;
      val("del-entity").value = pending.entity;
      var idInput = val("del-id");
      idInput.name = pending.idParam;
      idInput.value = pending.id;
      document.getElementById("content-delete-form").submit();
    });
  })();
</script>
<script src="../assets/js/app.js?v=9" data-username="${sessionScope.userName}"></script>
</body>
</html>

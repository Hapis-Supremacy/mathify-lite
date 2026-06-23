<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:if test="${empty requestScope.coursesLoaded}">
    <jsp:forward page="/admin/courses.do" />
</c:if>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Courses · Mathify Admin</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Source+Sans+3:wght@400;500;600;700&family=Source+Serif+4:opsz,wght@8..60,500;8..60,600;8..60,700&display=swap" rel="stylesheet">
<link href="../assets/css/app.css" rel="stylesheet">
</head>
<body data-role="admin" data-page="courses" data-base="../">

<div class="container py-4 shell">

  <div id="course-alert" class="alert d-none" role="alert"></div>

  <div class="d-flex justify-content-between align-items-center mb-4">
    <div><h2 class="mb-1">Courses</h2><p class="text-secondary mb-0">Create, edit and manage course content.</p></div>
    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#courseCreateModal"><i class="bi bi-plus-lg me-1"></i>New course</button>
  </div>

  <div class="card border-0 shadow-sm"><div class="table-responsive"><table class="table align-middle mb-0">
    <thead class="thead-soft"><tr class="text-secondary small">
      <th class="ps-4">Course</th><th>Category</th><th class="text-center">Chapters</th><th class="text-center">Enrolled</th><th class="text-end pe-4">Actions</th>
    </tr></thead>
    <tbody>
      <c:forEach var="course" items="${courses}">
      <tr>
        <td class="ps-4">
          <span class="fw-semibold"><c:out value="${course.title}"/></span>
          <span class="d-block text-secondary small"><c:out value="${course.description}"/></span>
        </td>
        <td><span class="badge rounded-pill badge-soft"><c:out value="${course.category}"/></span></td>
        <td class="text-center">${course.chapterCount}</td>
        <td class="text-center"><fmt:formatNumber value="${course.enrolledCount}" type="number"/></td>
        <td class="text-end pe-4">
          <form id="course-form-${course.courseId}" action="${pageContext.request.contextPath}/admin/course-action.do" method="post" class="d-inline-flex gap-1 mb-0">
            <input type="hidden" name="courseId" value="${course.courseId}"/>
          </form>
          <div class="d-inline-flex gap-1">
            <a class="btn btn-sm btn-primary" href="editor.do?c=${course.courseId}"><i class="bi bi-pencil-square me-1"></i>Content</a>
            <button type="button" class="btn btn-sm btn-outline-secondary js-edit-course" title="Edit details"
                    data-course-id="${course.courseId}"
                    data-title="<c:out value="${course.title}"/>"
                    data-category="<c:out value="${course.category}"/>"
                    data-description="<c:out value="${course.description}"/>"><i class="bi bi-gear"></i></button>
            <button type="button" class="btn btn-sm btn-outline-danger js-confirm-delete" title="Delete"
                    data-form-id="course-form-${course.courseId}"
                    data-course-title="<c:out value="${course.title}"/>"><i class="bi bi-trash"></i></button>
          </div>
        </td>
      </tr>
      </c:forEach>
      <c:if test="${empty courses}">
      <tr><td colspan="5" class="text-center text-secondary py-4">No courses yet. Click <span class="fw-semibold">New course</span> to create one.</td></tr>
      </c:if>
    </tbody>
  </table></div></div>

</div>

<!-- New course modal -->
<div class="modal fade" id="courseCreateModal" tabindex="-1">
  <div class="modal-dialog">
    <form class="modal-content border-0" action="${pageContext.request.contextPath}/admin/course-action.do" method="post">
      <input type="hidden" name="action" value="create"/>
      <div class="modal-header"><h5 class="modal-title">New course</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="mb-3"><label class="form-label small fw-semibold">Title</label><input class="form-control" name="title" required></div>
        <div class="mb-3"><label class="form-label small fw-semibold">Category</label><input class="form-control" name="category" required></div>
        <div class="mb-3"><label class="form-label small fw-semibold">Description</label><textarea class="form-control" name="description" rows="3"></textarea></div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="submit" class="btn btn-primary">Create course</button>
      </div>
    </form>
  </div>
</div>

<!-- Edit course details modal -->
<div class="modal fade" id="courseEditModal" tabindex="-1">
  <div class="modal-dialog">
    <form class="modal-content border-0" action="${pageContext.request.contextPath}/admin/course-action.do" method="post">
      <input type="hidden" name="action" value="update"/>
      <input type="hidden" name="courseId" id="edit-course-id"/>
      <div class="modal-header"><h5 class="modal-title">Edit course details</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="mb-3"><label class="form-label small fw-semibold">Title</label><input class="form-control" name="title" id="edit-course-title" required></div>
        <div class="mb-3"><label class="form-label small fw-semibold">Category</label><input class="form-control" name="category" id="edit-course-category" required></div>
        <div class="mb-3"><label class="form-label small fw-semibold">Description</label><textarea class="form-control" name="description" id="edit-course-description" rows="3"></textarea></div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="submit" class="btn btn-primary">Save changes</button>
      </div>
    </form>
  </div>
</div>

<!-- Delete confirm modal -->
<div class="modal fade" id="confirmDeleteModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content border-0 shadow">
      <div class="modal-header border-0 pb-0">
        <h5 class="modal-title d-flex align-items-center gap-2">
          <span class="d-inline-flex align-items-center justify-content-center rounded-circle bg-danger-subtle text-danger-emphasis"
                style="width:2.25rem;height:2.25rem;"><i class="bi bi-trash"></i></span>
          Delete course
        </h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body pt-2 text-secondary js-delete-message"></div>
      <div class="modal-footer border-0 pt-0">
        <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
        <button type="button" class="btn btn-danger js-delete-ok">Delete course</button>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
  (function () {
    // ---- error banner from ?error= ----
    var errors = {
      missing_fields: "Please fill in the required fields (title and category).",
      course_in_use: "This course can't be deleted because students are enrolled or have progress in it.",
      server_error: "Something went wrong. Please try again."
    };
    var params = new URLSearchParams(window.location.search);
    var code = params.get("error");
    if (code) {
      var alertEl = document.getElementById("course-alert");
      alertEl.textContent = errors[code] || "Something went wrong.";
      alertEl.classList.remove("d-none");
      alertEl.classList.add("alert-danger");
    }

    // ---- edit-details modal population ----
    var editModalEl = document.getElementById("courseEditModal");
    var editModal = new bootstrap.Modal(editModalEl);
    document.querySelectorAll(".js-edit-course").forEach(function (btn) {
      btn.addEventListener("click", function () {
        document.getElementById("edit-course-id").value = btn.dataset.courseId;
        document.getElementById("edit-course-title").value = btn.dataset.title;
        document.getElementById("edit-course-category").value = btn.dataset.category;
        document.getElementById("edit-course-description").value = btn.dataset.description || "";
        editModal.show();
      });
    });

    // ---- delete confirm ----
    var delModalEl = document.getElementById("confirmDeleteModal");
    var delModal = new bootstrap.Modal(delModalEl);
    var delMessage = delModalEl.querySelector(".js-delete-message");
    var delOk = delModalEl.querySelector(".js-delete-ok");
    var pendingFormId = null;
    document.querySelectorAll(".js-confirm-delete").forEach(function (btn) {
      btn.addEventListener("click", function () {
        pendingFormId = btn.dataset.formId;
        delMessage.textContent = "Permanently delete “" + (btn.dataset.courseTitle || "this course") +
          "” and all of its chapters, modules and quizzes? This cannot be undone.";
        delModal.show();
      });
    });
    delOk.addEventListener("click", function () {
      if (!pendingFormId) return;
      var form = document.getElementById(pendingFormId);
      if (form) {
        var input = document.createElement("input");
        input.type = "hidden";
        input.name = "action";
        input.value = "delete";
        form.appendChild(input);
        form.submit();
      }
      pendingFormId = null;
      delModal.hide();
    });
  })();
</script>
<script src="../assets/js/app.js?v=9" data-username="${sessionScope.userName}"></script>
</body>
</html>

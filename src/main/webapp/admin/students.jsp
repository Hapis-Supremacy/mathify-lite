<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:if test="${empty requestScope.studentsLoaded}">
    <jsp:forward page="/admin/students.do" />
</c:if>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Students · Mathify Admin</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Source+Sans+3:wght@400;500;600;700&family=Source+Serif+4:opsz,wght@8..60,500;8..60,600;8..60,700&display=swap" rel="stylesheet">
<link href="../assets/css/app.css" rel="stylesheet">
</head>
<body data-role="admin" data-page="students" data-base="../">

<div class="container py-4 shell">

  <div class="mb-4"><h2 class="mb-1">Students</h2><p class="text-secondary mb-0">Manage learner accounts.</p></div>

  <div class="card border-0 shadow-sm"><div class="table-responsive"><table class="table align-middle mb-0">
    <thead class="thead-soft"><tr class="text-secondary small">
      <th class="ps-4">Name</th><th>Email</th><th>Plan</th><th class="text-center">XP</th><th>Status</th><th class="text-end pe-4">Actions</th>
    </tr></thead>
    <tbody>
      <c:forEach var="student" items="${students}">
      <tr>
        <td class="ps-4 fw-semibold"><c:out value="${student.name}"/></td>
        <td class="text-secondary"><c:out value="${student.email}"/></td>
        <td>
          <c:choose>
            <c:when test="${student.plan == 'Premium'}">
              <span class="badge rounded-pill text-bg-primary">Premium</span>
            </c:when>
            <c:otherwise>
              <span class="badge rounded-pill text-bg-light border">Free</span>
            </c:otherwise>
          </c:choose>
        </td>
        <td class="text-center"><fmt:formatNumber value="${student.totalXp}" type="number"/></td>
        <td>
          <c:choose>
            <c:when test="${student.status == 'Active'}">
              <span class="badge rounded-pill text-bg-success">Active</span>
            </c:when>
            <c:otherwise>
              <span class="badge rounded-pill text-bg-secondary">Disabled</span>
            </c:otherwise>
          </c:choose>
        </td>
        <td class="text-end pe-4">
          <form id="student-form-${student.studentId}" action="${pageContext.request.contextPath}/admin/student-action.do" method="post" class="d-inline-flex gap-1 mb-0">
            <input type="hidden" name="studentId" value="${student.studentId}"/>
            <c:choose>
              <c:when test="${student.plan == 'Premium'}">
                <button type="submit" name="action" value="revoke_premium" class="btn btn-sm btn-outline-warning">Revoke Premium</button>
              </c:when>
              <c:otherwise>
                <button type="submit" name="action" value="grant_premium" class="btn btn-sm btn-outline-primary"><i class="bi bi-gem me-1"></i>Make Premium</button>
              </c:otherwise>
            </c:choose>
            <c:choose>
              <c:when test="${student.status == 'Active'}">
                <button type="button" class="btn btn-sm btn-outline-secondary js-confirm-action"
                        data-form-id="student-form-${student.studentId}" data-variant="disable"
                        data-student-name="<c:out value="${student.name}"/>">Disable</button>
              </c:when>
              <c:otherwise>
                <button type="submit" name="action" value="enable" class="btn btn-sm btn-outline-secondary">Enable</button>
              </c:otherwise>
            </c:choose>
            <button type="button" class="btn btn-sm btn-outline-danger js-confirm-action"
                    data-form-id="student-form-${student.studentId}" data-variant="delete"
                    data-student-name="<c:out value="${student.name}"/>" aria-label="Delete student"><i class="bi bi-trash"></i></button>
          </form>
        </td>
      </tr>
      </c:forEach>
    </tbody>
  </table></div></div>

</div>

<div class="modal fade" id="confirmActionModal" tabindex="-1" aria-hidden="true" aria-labelledby="confirmActionTitle">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content border-0 shadow">
      <div class="modal-header border-0 pb-0">
        <h5 class="modal-title d-flex align-items-center gap-2" id="confirmActionTitle">
          <span class="js-confirm-icon d-inline-flex align-items-center justify-content-center rounded-circle"
                style="width:2.25rem;height:2.25rem;"><i class="bi"></i></span>
          <span class="js-confirm-heading"></span>
        </h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body pt-2 text-secondary js-confirm-message"></div>
      <div class="modal-footer border-0 pt-0">
        <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
        <button type="button" class="btn js-confirm-ok"></button>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
  (function () {
    var modalEl = document.getElementById('confirmActionModal');
    if (!modalEl) return;
    var modal = new bootstrap.Modal(modalEl);
    var iconWrap = modalEl.querySelector('.js-confirm-icon');
    var iconEl = iconWrap.querySelector('i');
    var headingEl = modalEl.querySelector('.js-confirm-heading');
    var messageEl = modalEl.querySelector('.js-confirm-message');
    var okBtn = modalEl.querySelector('.js-confirm-ok');

    var variants = {
      disable: {
        heading: 'Disable account',
        icon: 'bi-pause-circle',
        iconWrap: 'bg-warning-subtle text-warning-emphasis',
        okClass: 'btn-warning',
        okLabel: 'Disable account',
        message: function (name) {
          return 'Disable ' + name + "'s account? They will not be able to sign in until you re-enable it.";
        }
      },
      delete: {
        heading: 'Delete account',
        icon: 'bi-trash',
        iconWrap: 'bg-danger-subtle text-danger-emphasis',
        okClass: 'btn-danger',
        okLabel: 'Delete account',
        message: function (name) {
          return 'Permanently delete ' + name + "'s account? This removes all of their progress and cannot be undone.";
        }
      }
    };

    var pending = null;

    document.querySelectorAll('.js-confirm-action').forEach(function (btn) {
      btn.addEventListener('click', function () {
        var cfg = variants[btn.dataset.variant];
        if (!cfg) return;
        var name = btn.dataset.studentName || 'this student';
        pending = { formId: btn.dataset.formId, variant: btn.dataset.variant };

        headingEl.textContent = cfg.heading;
        messageEl.textContent = cfg.message(name);
        iconEl.className = 'bi ' + cfg.icon;
        iconWrap.className = 'js-confirm-icon d-inline-flex align-items-center justify-content-center rounded-circle ' + cfg.iconWrap;
        okBtn.className = 'btn js-confirm-ok ' + cfg.okClass;
        okBtn.textContent = cfg.okLabel;
        modal.show();
      });
    });

    okBtn.addEventListener('click', function () {
      if (!pending) return;
      var form = document.getElementById(pending.formId);
      if (form) {
        var input = document.createElement('input');
        input.type = 'hidden';
        input.name = 'action';
        input.value = pending.variant;
        form.appendChild(input);
        form.submit();
      }
      pending = null;
      modal.hide();
    });
  })();
</script>
<script src="../assets/js/app.js?v=8" data-username="${sessionScope.userName}"></script>
</body>
</html>

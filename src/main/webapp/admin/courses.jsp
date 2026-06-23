<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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

  <div class="d-flex justify-content-between align-items-center mb-4">
    <div><h2 class="mb-1">Courses</h2><p class="text-secondary mb-0">Create, edit and manage course content.</p></div>
    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#courseModal"><i class="bi bi-plus-lg me-1"></i>New course</button>
  </div>

  <div class="card border-0 shadow-sm"><div class="table-responsive"><table class="table align-middle mb-0">
    <thead class="thead-soft"><tr class="text-secondary small">
      <th class="ps-4">Course</th><th>Category</th><th class="text-center">Chapters</th><th class="text-center">Enrolled</th><th class="text-end pe-4">Actions</th>
    </tr></thead>
    <tbody>
      <tr>
        <td class="ps-4"><span class="fw-semibold">Algebra Foundations</span><span class="d-block text-secondary small">Build fluency with variables, expressions and linear equations from the ground up.</span></td>
        <td><span class="badge rounded-pill badge-soft">Algebra</span></td>
        <td class="text-center">2</td>
        <td class="text-center">312</td>
        <td class="text-end pe-4"><div class="d-inline-flex gap-1">
          <a class="btn btn-sm btn-primary" href="editor.jsp?c=c1"><i class="bi bi-pencil-square me-1"></i>Content</a>
          <button class="btn btn-sm btn-outline-secondary" title="Edit details"><i class="bi bi-gear"></i></button>
          <button class="btn btn-sm btn-outline-danger" title="Delete"><i class="bi bi-trash"></i></button>
        </div></td>
      </tr>
      <tr>
        <td class="ps-4"><span class="fw-semibold">Geometry Essentials</span><span class="d-block text-secondary small">Angles, triangles and the properties that shape the plane.</span></td>
        <td><span class="badge rounded-pill badge-soft">Geometry</span></td>
        <td class="text-center">1</td>
        <td class="text-center">189</td>
        <td class="text-end pe-4"><div class="d-inline-flex gap-1">
          <a class="btn btn-sm btn-primary" href="editor.jsp?c=c2"><i class="bi bi-pencil-square me-1"></i>Content</a>
          <button class="btn btn-sm btn-outline-secondary" title="Edit details"><i class="bi bi-gear"></i></button>
          <button class="btn btn-sm btn-outline-danger" title="Delete"><i class="bi bi-trash"></i></button>
        </div></td>
      </tr>
      <tr>
        <td class="ps-4"><span class="fw-semibold">Calculus Kickstart</span><span class="d-block text-secondary small">A gentle on-ramp to limits and the idea of the derivative.</span></td>
        <td><span class="badge rounded-pill badge-soft">Calculus</span></td>
        <td class="text-center">1</td>
        <td class="text-center">97</td>
        <td class="text-end pe-4"><div class="d-inline-flex gap-1">
          <a class="btn btn-sm btn-primary" href="editor.jsp?c=c3"><i class="bi bi-pencil-square me-1"></i>Content</a>
          <button class="btn btn-sm btn-outline-secondary" title="Edit details"><i class="bi bi-gear"></i></button>
          <button class="btn btn-sm btn-outline-danger" title="Delete"><i class="bi bi-trash"></i></button>
        </div></td>
      </tr>
    </tbody>
  </table></div></div>

</div>

<!-- New course modal -->
<div class="modal fade" id="courseModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content border-0">
      <div class="modal-header"><h5 class="modal-title">New course</h5><button class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="mb-3"><label class="form-label small fw-semibold">Title</label><input class="form-control"></div>
        <div class="mb-3"><label class="form-label small fw-semibold">Category</label><input class="form-control"></div>
        <div class="mb-3"><label class="form-label small fw-semibold">Description</label><textarea class="form-control" rows="3"></textarea></div>
      </div>
      <div class="modal-footer">
        <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
        <button class="btn btn-primary" data-bs-dismiss="modal">Create course</button>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="../assets/js/app.js?v=4" data-username="${sessionScope.userName}"></script>
</body>
</html>

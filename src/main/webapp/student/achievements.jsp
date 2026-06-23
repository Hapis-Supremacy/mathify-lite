<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Achievements · Mathify</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Source+Sans+3:wght@400;500;600;700&family=Source+Serif+4:opsz,wght@8..60,500;8..60,600;8..60,700&display=swap" rel="stylesheet">
<link href="../assets/css/app.css" rel="stylesheet">
</head>
<body data-role="student" data-page="achievements" data-base="../">

<div class="container py-4 shell">

  <div class="mb-4">
    <h2 class="mb-1">Achievements</h2>
    <p class="text-secondary mb-0">4 of 8 unlocked.</p>
  </div>

  <div class="row g-3" id="grid"></div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="../assets/js/app.js?v=4" data-username="${sessionScope.userName}"></script>
<script>
  var achievements = [
    { title:'First Steps',     req:'Complete your first lesson', icon:'bi-flag-fill',          unlocked:true },
    { title:'Quiz Whiz',       req:'Pass 5 quizzes',            icon:'bi-patch-check-fill',   unlocked:true },
    { title:'On Fire',         req:'Reach a 7-day streak',      icon:'bi-fire',               unlocked:true },
    { title:'Scholar',         req:'Earn 1,000 XP',             icon:'bi-mortarboard-fill',   unlocked:true },
    { title:'Course Champion', req:'Finish a full course',      icon:'bi-trophy-fill',        unlocked:false },
    { title:'Perfectionist',   req:'Score 100% on a quiz',      icon:'bi-star-fill',          unlocked:false },
    { title:'Marathoner',      req:'Reach a 30-day streak',     icon:'bi-calendar-check-fill',unlocked:false },
    { title:'Polymath',        req:'Enroll in 3 categories',    icon:'bi-stars',              unlocked:false }
  ];
  document.getElementById('grid').innerHTML = achievements.map(function (a) {
    var bg = a.unlocked ? '#eef3fa' : '#eef1f6';
    var color = a.unlocked ? '#1d4e89' : '#9aa6b8';
    return '<div class="col-6 col-md-4 col-lg-3">' +
      '<div class="card border-0 shadow-sm h-100 text-center" style="opacity:' + (a.unlocked ? 1 : 0.5) + ';"><div class="card-body py-4">' +
        '<span class="d-inline-flex align-items-center justify-content-center rounded-circle mb-2" style="width:60px;height:60px;background:' + bg + ';color:' + color + ';"><i class="bi ' + a.icon + ' fs-3"></i></span>' +
        '<h6 class="mb-1">' + a.title + '</h6>' +
        '<p class="text-secondary small mb-0">' + a.req + '</p>' +
      '</div></div></div>';
  }).join('');
</script>
</body>
</html>

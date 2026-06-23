<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Create Account · Mathify</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Source+Sans+3:wght@400;500;600;700&family=Source+Serif+4:opsz,wght@8..60,500;8..60,600;8..60,700&display=swap" rel="stylesheet">
<link href="assets/css/app.css" rel="stylesheet">
<style>
  body { display: flex; min-height: 100vh; margin: 0; }
</style>
</head>
<body>

<!-- ============ BRAND PANEL ============ -->
<div class="auth-brand-panel d-none d-lg-flex flex-column justify-content-between">
  <span class="glyph-bg" style="font-size:300px;top:-40px;right:-30px;">&Sigma;</span>
  <span class="glyph-bg" style="font-size:150px;bottom:40px;left:-10px;">&pi;</span>
  <span class="glyph-bg" style="font-size:120px;top:46%;right:18%;">&radic;</span>
  <span class="glyph-bg" style="font-size:90px;bottom:34%;right:8%;">&infin;</span>

  <div class="d-flex align-items-center gap-2 brandfont fw-bold" style="font-size:1.5rem;position:relative;">
    <span style="display:inline-flex;width:40px;height:40px;border-radius:10px;background:#fff;color:#1d4e89;align-items:center;justify-content:center;font-size:1.35rem;">&Sigma;</span>
    Mathify
  </div>

  <div style="position:relative;max-width:420px;">
    <h1 class="mb-3" style="font-size:2.6rem;line-height:1.15;">Start learning math the fun way.</h1>
    <p style="color:rgba(255,255,255,.82);font-size:1.08rem;line-height:1.6;">Master algebra, geometry and calculus through bite-sized lessons, quizzes and streaks that keep you coming back.</p>
    <div class="d-flex gap-4 mt-4">
      <div>
        <div class="brandfont fw-bold" style="font-size:1.6rem;">40+</div>
        <div style="color:rgba(255,255,255,.7);font-size:.85rem;">Courses</div>
      </div>
      <div>
        <div class="brandfont fw-bold" style="font-size:1.6rem;">180k</div>
        <div style="color:rgba(255,255,255,.7);font-size:.85rem;">Learners</div>
      </div>
      <div>
        <div class="brandfont fw-bold" style="font-size:1.6rem;">4.8&#9733;</div>
        <div style="color:rgba(255,255,255,.7);font-size:.85rem;">Avg rating</div>
      </div>
    </div>
  </div>

  <div style="position:relative;color:rgba(255,255,255,.6);font-size:.85rem;">&copy; 2026 Mathify &middot; Learning, multiplied.</div>
</div>

<!-- ============ FORM PANEL ============ -->
<div class="flex-grow-1 d-flex align-items-center justify-content-center" style="padding:40px 20px;background:#eef1f6;">
  <div style="width:100%;max-width:420px;">

    <!-- mobile brand -->
    <div class="d-flex d-lg-none align-items-center gap-2 brandfont fw-bold mb-4" style="font-size:1.4rem;color:#1d4e89;">
      <span style="display:inline-flex;width:36px;height:36px;border-radius:9px;background:#1d4e89;color:#fff;align-items:center;justify-content:center;font-size:1.2rem;">&Sigma;</span>
      Mathify
    </div>

    <div class="mb-4">
      <h2 class="mb-1" style="font-size:1.9rem;">Create your account</h2>
      <p class="text-secondary mb-0">Free forever. No card required.</p>
    </div>

    <div id="alertBanner" class="alert alert-danger d-none mb-3" role="alert" style="font-size:.9rem;"></div>

    <form action="/register" method="post" novalidate>

      <div class="mb-3">
        <label class="form-label small fw-semibold" for="fullName">Full name</label>
        <div class="position-relative">
          <i class="bi bi-person position-absolute text-secondary" style="left:14px;top:50%;transform:translateY(-50%);pointer-events:none;"></i>
          <input id="fullName" name="fullName" class="auth-input form-control" type="text" style="padding-left:38px;" placeholder="Alex Rivera" autocomplete="name">
        </div>
      </div>

      <div class="mb-3">
        <label class="form-label small fw-semibold" for="email">Email address</label>
        <div class="position-relative">
          <i class="bi bi-envelope position-absolute text-secondary" style="left:14px;top:50%;transform:translateY(-50%);pointer-events:none;"></i>
          <input id="email" name="email" class="auth-input form-control" type="email" style="padding-left:38px;" placeholder="you@school.edu" autocomplete="email">
        </div>
      </div>

      <div class="mb-3">
        <label class="form-label small fw-semibold mb-0" for="password">Password</label>
        <div class="position-relative mt-1">
          <i class="bi bi-lock position-absolute text-secondary" style="left:14px;top:50%;transform:translateY(-50%);pointer-events:none;"></i>
          <input id="password" name="password" class="auth-input form-control" type="password" style="padding-left:38px;padding-right:42px;" placeholder="At least 8 characters" autocomplete="new-password">
          <i id="pwToggle" class="bi bi-eye position-absolute text-secondary" style="right:14px;top:50%;transform:translateY(-50%);cursor:pointer;" role="button" aria-label="Toggle password visibility"></i>
        </div>
        <div class="d-flex gap-1 mt-2">
          <span id="bar0" style="flex:1;height:4px;border-radius:2px;background:#dde3ec;"></span>
          <span id="bar1" style="flex:1;height:4px;border-radius:2px;background:#dde3ec;"></span>
          <span id="bar2" style="flex:1;height:4px;border-radius:2px;background:#dde3ec;"></span>
          <span id="bar3" style="flex:1;height:4px;border-radius:2px;background:#dde3ec;"></span>
        </div>
        <div id="strengthLabel" class="text-secondary mt-1" style="font-size:.78rem;">Use 8+ characters with a mix of letters, numbers &amp; symbols</div>
      </div>

      <div class="form-check mb-3">
        <input class="form-check-input" type="checkbox" id="terms" name="terms">
        <label class="form-check-label small text-secondary" for="terms">
          I agree to the <a href="#" style="color:#1d4e89;">Terms</a> and <a href="#" style="color:#1d4e89;">Privacy Policy</a>
        </label>
      </div>

      <button type="submit" class="btn btn-auth w-100 fw-semibold" style="padding:.65rem;">Create account</button>

    </form>

    <p class="text-center text-secondary small mt-4 mb-0">
      Already have an account? <a href="login.jsp" style="color:#1d4e89;font-weight:600;">Sign in</a>
    </p>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
  (function () {
    var errorMessages = {
      missing_fields:  'Please fill in all required fields.',
      weak_password:   'Password must be at least 8 characters.',
      terms_required:  'You must agree to the Terms and Privacy Policy.',
      email_taken:     'An account with that email already exists.',
      server_error:    'A server error occurred. Please try again later.'
    };
    var params = new URLSearchParams(window.location.search);
    var error = params.get('error');
    var banner = document.getElementById('alertBanner');
    if (error && errorMessages[error]) {
      banner.textContent = errorMessages[error];
      banner.classList.remove('d-none');
    }
  })();

  (function () {
    var btn = document.getElementById('pwToggle');
    var input = document.getElementById('password');
    var label = document.getElementById('strengthLabel');
    var bars = [
      document.getElementById('bar0'),
      document.getElementById('bar1'),
      document.getElementById('bar2'),
      document.getElementById('bar3')
    ];
    var activeColors = ['#c0392b', '#d97706', '#d97706', '#1d8a5b'];
    var labels = ['', 'Weak password', 'Fair - add numbers or symbols', 'Good password', 'Strong password'];

    function strength(pw) {
      var n = 0;
      if (pw.length >= 8) n++;
      if (/[A-Z]/.test(pw) && /[a-z]/.test(pw)) n++;
      if (/[0-9]/.test(pw)) n++;
      if (/[^A-Za-z0-9]/.test(pw)) n++;
      return n;
    }

    input.addEventListener('input', function () {
      var pw = input.value;
      var sc = pw ? strength(pw) : 0;
      var color = sc > 0 ? activeColors[sc - 1] : '#dde3ec';
      bars.forEach(function (b, i) {
        b.style.background = i < sc ? color : '#dde3ec';
      });
      label.textContent = pw
        ? labels[sc]
        : 'Use 8+ characters with a mix of letters, numbers & symbols';
    });

    btn.addEventListener('click', function () {
      var show = input.type === 'password';
      input.type = show ? 'text' : 'password';
      btn.className = (show ? 'bi bi-eye-slash' : 'bi bi-eye') +
        ' position-absolute text-secondary';
    });
  })();
</script>
</body>
</html>

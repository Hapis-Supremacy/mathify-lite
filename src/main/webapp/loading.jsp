<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Loading - Mathify</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Source+Sans+3:wght@400;600&family=Source+Serif+4:opsz,wght@8..60,700&display=swap">
  <style>
    body { font-family: 'Source Sans 3', system-ui, -apple-system, sans-serif; color: #1f2733; margin: 0; }
    .brandfont { font-family: 'Source Serif 4', Georgia, serif; letter-spacing: -.02em; }

    @keyframes mf-topbar {
      0%   { left: -60%; width: 60%; }
      100% { left: 110%; width: 60%; }
    }
    @keyframes mf-pulse {
      0%, 100% { box-shadow: 0 8px 32px rgba(29,78,137,.22), 0 0 0 0 rgba(29,78,137,.28); }
      50%       { box-shadow: 0 8px 32px rgba(29,78,137,.22), 0 0 0 18px rgba(29,78,137,0); transform: scale(1.045); }
    }
    @keyframes mf-fadein {
      from { opacity: 0; transform: translateY(12px); }
      to   { opacity: 1; transform: translateY(0); }
    }
    @keyframes mf-dot {
      0%, 80%, 100% { transform: scale(0.55); opacity: .2; }
      40%            { transform: scale(1);    opacity: 1; }
    }

    .mf-topbar { position: fixed; top: 0; left: 0; right: 0; height: 3px; background: rgba(29,78,137,.1); z-index: 9999; overflow: hidden; }
    .mf-topbar-fill { position: absolute; top: 0; height: 100%; background: #1d4e89; animation: mf-topbar 1.7s cubic-bezier(.4,0,.6,1) infinite; }
    .mf-screen { min-height: 100vh; background: #eef1f6; display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 40px 20px; position: relative; }
    .mf-logo { width: 80px; height: 80px; border-radius: 22px; background: #1d4e89; color: #fff; display: flex; align-items: center; justify-content: center; font-family: 'Source Serif 4', Georgia, serif; font-size: 2.5rem; font-weight: 700; box-shadow: 0 8px 32px rgba(29,78,137,.22); animation: mf-pulse 2.4s ease-in-out infinite; }
    .mf-brand { font-family: 'Source Serif 4', Georgia, serif; font-weight: 700; font-size: 1.8rem; color: #1d4e89; margin-top: 20px; letter-spacing: -.025em; }
    .mf-dots { display: flex; gap: 10px; margin-top: 44px; align-items: center; }
    .mf-dot { display: inline-block; width: 9px; height: 9px; border-radius: 50%; background: #1d4e89; animation: mf-dot 1.5s ease-in-out infinite; }
    .mf-dot:nth-child(2) { animation-delay: .2s; }
    .mf-dot:nth-child(3) { animation-delay: .4s; }
    .mf-msg { font-size: .93rem; color: #6c757d; margin-top: 20px; min-height: 1.5em; text-align: center; margin-bottom: 0; }
    .mf-footer { position: absolute; bottom: 28px; left: 0; right: 0; text-align: center; color: #c0c8d4; font-size: .78rem; }
    .mf-entry   { animation: mf-fadein .6s ease both; }
    .mf-entry-2 { animation: mf-fadein .6s .13s ease both; }
    .mf-entry-3 { animation: mf-fadein .6s .26s ease both; }
    .mf-entry-4 { animation: mf-fadein .6s .40s ease both; }
  </style>
</head>
<body>

  <div class="mf-topbar"><div class="mf-topbar-fill"></div></div>

  <div class="mf-screen">
    <div class="mf-entry"><div class="mf-logo">Σ</div></div>
    <div class="mf-brand mf-entry-2">Mathify</div>
    <div class="mf-dots mf-entry-3">
      <span class="mf-dot"></span>
      <span class="mf-dot"></span>
      <span class="mf-dot"></span>
    </div>
    <p class="mf-msg mf-entry-4">${loadingMessage}</p>
    <div class="mf-footer">&copy; 2026 Mathify</div>
  </div>

  <script>
    // Set in servlet: request.setAttribute("redirectUrl", "/dashboard");
    var url = '${redirectUrl}';
    setTimeout(function() {
      window.location.href = url || '/dashboard';
    }, url ? 300 : 2500);
  </script>

</body>
</html>

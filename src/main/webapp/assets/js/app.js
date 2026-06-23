/* ============================================================
   Mathify — shared shell (navbar + profile header)
   Injects the top navigation into every page.

   Each page declares its context on <body>:
     data-role="student" | "admin"
     data-page="dashboard" | "catalog" | ... (matches a nav key)
     data-base="..."   relative path back to /assets root (e.g. "../")
   ============================================================ */
(function () {
  "use strict";

  // Read dynamic user info injected into the script tag
  var currentScript = document.querySelector('script[src*="app.js"]');
  var dynamicUserName = currentScript ? currentScript.getAttribute("data-username") : null;
  if (!dynamicUserName || dynamicUserName.trim() === "") {
    dynamicUserName = "User";
  }

  // Sample profile — mirrors the prototype's initial state or dynamic values.
  var profile = {
    name: dynamicUserName,
    level: document.body.dataset.level ? parseInt(document.body.dataset.level, 10) : 0,
    totalXP: document.body.dataset.xp ? parseInt(document.body.dataset.xp, 10) : 0,
    streak: document.body.dataset.streak ? parseInt(document.body.dataset.streak, 10) : 0,
    energy: document.body.dataset.energy ? parseInt(document.body.dataset.energy, 10) : 0,
    energyMax: document.body.dataset.energyMax ? parseInt(document.body.dataset.energyMax, 10) : 5,
    energyRenewsAt: document.body.dataset.energyRenewsAt ? parseInt(document.body.dataset.energyRenewsAt, 10) : 0,
    premium: document.body.dataset.premium === "true",
    subscriptionPlan: document.body.dataset.subscriptionPlan || ""
  };
  var energyCountdownTimer = null;
  var energyLockReloaded = false;

  var NAV = {
    student: [
      { key: "dashboard", label: "Dashboard", icon: "bi-house-door", href: "dashboard.do" },
      { key: "catalog", label: "Courses", icon: "bi-grid", href: "catalog.do" },
      { key: "achievements", label: "Achievements", icon: "bi-trophy", href: "achievements.jsp" },
      { key: "premium", label: "Premium", icon: "bi-gem", href: "premium.jsp" }
    ],
    admin: [
      { key: "overview", label: "Overview", icon: "bi-graph-up-arrow", href: "dashboard.do" },
      { key: "courses", label: "Courses", icon: "bi-mortarboard", href: "courses.jsp" },
      { key: "students", label: "Students", icon: "bi-people", href: "students.do" }
    ]
  };

  function initials(name) {
    return name.split(" ").map(function (w) { return w[0]; }).join("");
  }

  function el(html) {
    var t = document.createElement("template");
    t.innerHTML = html.trim();
    return t.content.firstChild;
  }

  function formatCountdown(ms) {
    var totalSeconds = Math.max(0, Math.ceil(ms / 1000));
    var hours = Math.floor(totalSeconds / 3600);
    var minutes = Math.floor((totalSeconds % 3600) / 60);
    return String(hours).padStart(2, "0") + ":" + String(minutes).padStart(2, "0");
  }

  function energyRenewalText() {
    if (profile.premium) {
      return "Unlimited energy";
    }
    if (profile.energy >= profile.energyMax) {
      return "Energy full";
    }
    if (!profile.energyRenewsAt) {
      return "Energy renews after 00:00";
    }
    return "Energy renews after " + formatCountdown(profile.energyRenewsAt - Date.now());
  }

  function updateEnergyCountdown() {
    var energyValues = document.querySelectorAll("[data-energy-value]");
    var energyPills = document.querySelectorAll("[data-energy-renewal]");
    if (!energyValues.length && !energyPills.length) {
      return;
    }

    if (profile.premium) {
      energyValues.forEach(function (node) {
        node.textContent = "Unlimited";
      });
      energyPills.forEach(function (node) {
        node.textContent = "";
        node.style.display = "none";
      });
      return;
    }

    if (profile.energy < profile.energyMax && profile.energyRenewsAt && Date.now() >= profile.energyRenewsAt) {
      profile.energy = profile.energyMax;
      profile.energyRenewsAt = 0;
      if (document.body.dataset.energyLocked === "true" && !energyLockReloaded) {
        energyLockReloaded = true;
        window.location.reload();
        return;
      }
    }

    energyValues.forEach(function (node) {
      node.textContent = profile.energy + "/" + profile.energyMax;
    });
    energyPills.forEach(function (node) {
      node.style.display = "";
      node.textContent = energyRenewalText();
    });
  }

  function render() {
    var body = document.body;
    var role = body.dataset.role || "student";
    var page = body.dataset.page || "";
    var base = body.dataset.base || "";          // path to webapp root

    // Idempotent: drop any previously injected navbar so render() can re-run
    // once live profile data arrives.
    var existing = document.getElementById("appShellNav");
    if (existing) { existing.remove(); }
    var isStudent = role === "student";
    var items = NAV[role] || NAV.student;

    var navLinks = items.map(function (n) {
      var active = n.key === page ? " active" : "";
      return '<li class="nav-item"><a class="nav-link px-3' + active + '" href="' + n.href + '">' +
        '<i class="bi ' + n.icon + ' me-2"></i>' + n.label + "</a></li>";
    }).join("");

    // student-only profile cluster (streak / energy / level)
    var cluster = "";
    if (isStudent) {
      var energyLabel = profile.premium ? "&#8734;" : (profile.energy + "/" + profile.energyMax);
      var premiumBadge = profile.premium
        ? '<span class="badge rounded-pill d-inline-flex align-items-center gap-1" style="background:#1d4e89;color:#fff;font-weight:600;padding:.4em .7em;"><i class="bi bi-gem"></i>Premium</span>'
        : '<a class="btn btn-sm btn-outline-primary d-inline-flex align-items-center gap-1" href="premium.jsp"><i class="bi bi-gem"></i>Upgrade</a>';
      cluster =
        '<div class="d-none d-md-flex align-items-center gap-3">' +
        premiumBadge +
        '<span class="d-flex align-items-center gap-1 fw-semibold" style="color:#d97706;" title="Quiz-day streak"><i class="bi bi-fire"></i>' + profile.streak + "</span>" +
        '<span class="d-flex align-items-center gap-2 fw-semibold" style="color:#1d4e89;" title="Energy">' +
        '<span class="d-flex align-items-center gap-1"><i class="bi bi-lightning-charge-fill"></i><span data-energy-value>' + energyLabel + "</span></span>" +
        (profile.premium ? "" : '<span class="badge rounded-pill text-bg-light border fw-semibold" data-energy-renewal>' + energyRenewalText() + "</span>") +
        "</span>" +
        '<span class="badge rounded-pill" style="background:#eef3fa;color:#1d4e89;border:1px solid #d6e2f1;font-weight:600;">Lv ' + profile.level + " &middot; " + profile.totalXP + " XP</span>" +
        "</div>";
    }

    var avatarHtml = '<i class="bi bi-person-fill" style="font-size:1.2rem;"></i>';

    var nav = el(
      '<nav id="appShellNav" class="navbar navbar-expand-md sticky-top px-3" style="background:#fff;border-bottom:1px solid #e2e7ef;z-index:1030;">' +
      '<div class="container-fluid shell">' +
      '<a class="navbar-brand brandfont fw-bold d-flex align-items-center gap-2 mb-0" style="color:#1d4e89;font-size:1.4rem;" href="' + base + (isStudent ? "student/dashboard.do" : "admin/dashboard.do") + '">' +
      '<span class="brand-mark">&Sigma;</span>Mathify' +
      "</a>" +
      '<button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#appNav"><span class="navbar-toggler-icon"></span></button>' +
      '<div class="collapse navbar-collapse" id="appNav">' +
      '<ul class="nav nav-pills gap-1 mx-auto">' + navLinks + "</ul>" +
      '<div class="d-flex align-items-center gap-3 ms-auto">' +
      cluster +
      '<div class="dropdown">' +
      '<div class="rounded-circle d-flex align-items-center justify-content-center fw-semibold avatar" role="button" data-bs-toggle="dropdown">' + avatarHtml + "</div>" +
      '<ul class="dropdown-menu dropdown-menu-end">' +
      '<li><h6 class="dropdown-header">' + (isStudent ? profile.name : "Administrator") + "</h6></li>" +
      '<li><hr class="dropdown-divider"></li>' +
      '<li><a class="dropdown-item text-danger" href="' + base + 'logout.do"><i class="bi bi-box-arrow-right me-2"></i>Log out</a></li>' +
      "</ul>" +
      "</div>" +
      "</div>" +
      "</div>" +
      "</div>" +
      "</nav>"
    );

    body.insertBefore(nav, body.firstChild);
    updateEnergyCountdown();
    if (!energyCountdownTimer) {
      energyCountdownTimer = window.setInterval(updateEnergyCountdown, 1000);
    }
  }

  // Pull the student's real header data (premium status, energy, streak, XP)
  // and re-render the navbar with it. Falls back silently to sample values.
  function hydrateProfile() {
    var base = document.body.dataset.base || "";
    fetch(base + "student/profile.do", { headers: { "Accept": "application/json" } })
      .then(function (r) { return r.ok ? r.json() : null; })
      .then(function (data) {
        if (!data || data.error) { return; }
        profile.name = data.name || profile.name;
        profile.premium = !!data.premium;
        profile.subscriptionPlan = data.subscriptionPlan || "";
        if (typeof data.energy === "number") { profile.energy = data.energy; }
        if (typeof data.energyMax === "number") { profile.energyMax = data.energyMax; }
        if (typeof data.energyRenewsAt === "number") { profile.energyRenewsAt = data.energyRenewsAt; }
        if (typeof data.streak === "number") { profile.streak = data.streak; }
        if (typeof data.level === "number") { profile.level = data.level; }
        if (typeof data.totalXp === "number") { profile.totalXP = data.totalXp; }
        render();
      })
      .catch(function () { /* keep the sample navbar on any failure */ });
  }

  function start() {
    render();
    if ((document.body.dataset.role || "student") === "student") {
      hydrateProfile();
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", start);
  } else {
    start();
  }

  // expose for any page that wants the sample profile
  window.Mathify = { profile: profile };
})();

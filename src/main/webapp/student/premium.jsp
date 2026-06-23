<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Go Premium · Mathify</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Source+Sans+3:wght@400;500;600;700&family=Source+Serif+4:opsz,wght@8..60,500;8..60,600;8..60,700&display=swap" rel="stylesheet">
<link href="../assets/css/app.css" rel="stylesheet">
</head>
<body data-role="student" data-page="premium" data-base="../"
      data-energy="${globalStudent.energy}" data-xp="${globalProgress.totalXP}"
      data-energy-max="${globalStudent.maxEnergy}" data-energy-renews-at="${globalStudent.energyRenewalEpochMillis}"
      data-premium="${globalStudent.premiumActive}" data-subscription-plan="${globalStudent.subscription.subscriptionPlan}"
      data-level="${globalProgress.level}" data-streak="${globalProgress.currentStreak}">

<div class="container py-4 shell">

  <div class="text-center mb-4">
    <h2 class="mb-1">Go Premium</h2>
    <p class="text-secondary mb-0">Unlimited energy, offline lessons and detailed progress insights.</p>
  </div>

  <div id="payAlert" class="alert d-none mx-auto" style="max-width:620px;" role="alert"></div>

  <div class="row g-3 justify-content-center">
    <div class="col-12 col-md-4">
      <div class="card border-0 shadow-sm h-100"><div class="card-body p-4">
        <h5>Free</h5>
        <div class="fs-2 fw-bold mb-3">Rp 0<span class="fs-6 text-secondary fw-normal">/mo</span></div>
        <ul class="list-unstyled d-flex flex-column gap-2 mb-4 text-secondary">
          <li><i class="bi bi-check2 me-2" style="color:#1d8a5b;"></i>All courses &amp; quizzes</li>
          <li><i class="bi bi-check2 me-2" style="color:#1d8a5b;"></i>5 energy, renewed after 4 hours</li>
          <li><i class="bi bi-dash me-2 text-secondary"></i>Limited progress insights</li>
        </ul>
        <button class="btn btn-outline-secondary w-100" data-plan="free" disabled>Current plan</button>
      </div></div>
    </div>

    <div class="col-12 col-md-4">
      <div class="card border-0 shadow-sm h-100" style="outline:2px solid #1d4e89;"><div class="card-body p-4">
        <div class="d-flex justify-content-between align-items-center">
          <h5 class="mb-0">Premium Monthly</h5>
          <span class="badge" style="background:#1d4e89;">Popular</span>
        </div>
        <div class="fs-2 fw-bold mb-3 mt-2">Rp 125.500<span class="fs-6 text-secondary fw-normal">/mo</span></div>
        <ul class="list-unstyled d-flex flex-column gap-2 mb-4">
          <li><i class="bi bi-check2 me-2" style="color:#1d8a5b;"></i>Everything in Free</li>
          <li><i class="bi bi-check2 me-2" style="color:#1d8a5b;"></i>Unlimited energy</li>
          <li><i class="bi bi-check2 me-2" style="color:#1d8a5b;"></i>Detailed progress insights</li>
          <li><i class="bi bi-check2 me-2" style="color:#1d8a5b;"></i>Offline lessons</li>
        </ul>
        <button class="btn btn-primary w-100 upgrade-btn" data-plan="monthly"><i class="bi bi-gem me-1"></i>Upgrade Monthly</button>
      </div></div>
    </div>

    <div class="col-12 col-md-4">
      <div class="card border-0 shadow-sm h-100" style="outline:2px solid #1d8a5b;"><div class="card-body p-4">
        <div class="d-flex justify-content-between align-items-center">
          <h5 class="mb-0">Premium Yearly</h5>
          <span class="badge" style="background:#1d8a5b;">Best value</span>
        </div>
        <div class="fs-2 fw-bold mb-3 mt-2">Rp 1.224.500<span class="fs-6 text-secondary fw-normal">/yr</span></div>
        <ul class="list-unstyled d-flex flex-column gap-2 mb-4">
          <li><i class="bi bi-check2 me-2" style="color:#1d8a5b;"></i>Everything in Monthly</li>
          <li><i class="bi bi-check2 me-2" style="color:#1d8a5b;"></i>Best value vs monthly</li>
          <li><i class="bi bi-check2 me-2" style="color:#1d8a5b;"></i>Priority support</li>
        </ul>
        <button class="btn w-100 text-white upgrade-btn" style="background:#1d8a5b;" data-plan="yearly"><i class="bi bi-gem me-1"></i>Upgrade Yearly</button>
      </div></div>
    </div>
  </div>

  <p class="text-secondary small text-center mt-3 mb-0" style="max-width:640px;margin-inline:auto;">
    Secure payment by Midtrans opens in this page. Sandbox test mode - no real
    money is charged. Premium activates automatically once payment clears.
  </p>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="../assets/js/app.js?v=8" data-username="${sessionScope.userName}"></script>
<script>
(function () {
  "use strict";

  var alertBox = document.getElementById("payAlert");
  var buttons = document.querySelectorAll(".upgrade-btn");
  var freeButton = document.querySelector('[data-plan="free"]');
  var snapLoading = null;

  function normalizePlan(plan) {
    plan = (plan || "").toLowerCase();
    if (plan.indexOf("year") !== -1) { return "yearly"; }
    if (plan.indexOf("month") !== -1) { return "monthly"; }
    if (plan === "premium") { return "monthly"; }
    return plan;
  }

  function applyCurrentPlanState() {
    var isPremium = document.body.dataset.premium === "true";
    var currentPlan = normalizePlan(document.body.dataset.subscriptionPlan);

    if (freeButton) {
      freeButton.textContent = isPremium ? "Free plan" : "Current plan";
    }

    buttons.forEach(function (button) {
      if (!isPremium || button.dataset.plan !== currentPlan) {
        return;
      }
      button.disabled = true;
      button.classList.remove("btn-primary", "text-white");
      button.classList.add("btn-secondary");
      button.removeAttribute("style");
      button.innerHTML = "Current plan";
    });
  }

  function showAlert(kind, message) {
    alertBox.className = "alert mx-auto alert-" + kind;
    alertBox.style.maxWidth = "620px";
    alertBox.textContent = message;
  }

  function setBusy(busy) {
    buttons.forEach(function (b) {
      b.disabled = busy;
      if (busy && b === document.activeElement) {
        b.dataset.label = b.innerHTML;
        b.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span>Processing...';
      } else if (!busy && b.dataset.label) {
        b.innerHTML = b.dataset.label;
        delete b.dataset.label;
      }
    });
  }

  // Load Snap.js once, using the client key returned by checkout.
  function loadSnap(snapUrl, clientKey) {
    if (window.snap) { return Promise.resolve(); }
    if (snapLoading) { return snapLoading; }
    snapLoading = new Promise(function (resolve, reject) {
      var s = document.createElement("script");
      s.src = snapUrl;
      s.setAttribute("data-client-key", clientKey);
      s.onload = resolve;
      s.onerror = function () { reject(new Error("Failed to load the payment script.")); };
      document.head.appendChild(s);
    });
    return snapLoading;
  }

  function confirmPayment(orderId) {
    return fetch("premium/confirm.do?orderId=" + encodeURIComponent(orderId), {
      method: "POST",
      headers: { "Accept": "application/json" }
    }).then(function (r) { return r.json(); });
  }

  function handleResult(orderId) {
    showAlert("info", "Verifying your payment...");
    confirmPayment(orderId).then(function (res) {
      if (res.status === "paid") {
        showAlert("success", "Payment confirmed — you are now Premium! Redirecting...");
        setTimeout(function () { window.location.href = res.redirect; }, 1200);
      } else if (res.status === "pending") {
        showAlert("warning", "Your payment is pending. Premium will activate once it clears.");
        setBusy(false);
      } else {
        showAlert("danger", res.error || "We could not verify your payment.");
        setBusy(false);
      }
    }).catch(function () {
      showAlert("danger", "Network error while verifying payment.");
      setBusy(false);
    });
  }

  function startCheckout(plan) {
    setBusy(true);
    showAlert("info", "Starting secure checkout...");

    fetch("premium/checkout.do?plan=" + encodeURIComponent(plan), {
      method: "POST",
      headers: { "Accept": "application/json" }
    }).then(function (r) {
      return r.json().then(function (body) { return { ok: r.ok, body: body }; });
    }).then(function (res) {
      if (!res.ok || !res.body.token) {
        throw new Error(res.body.error || "Could not start checkout.");
      }
      var data = res.body;
      return loadSnap(data.snapJsUrl, data.clientKey).then(function () {
        alertBox.className = "alert d-none";
        window.snap.pay(data.token, {
          onSuccess: function (result) { handleResult(result.order_id); },
          onPending: function (result) { handleResult(result.order_id); },
          onError: function () {
            showAlert("danger", "Payment failed. Please try again.");
            setBusy(false);
          },
          onClose: function () {
            showAlert("warning", "Checkout closed before payment was completed.");
            setBusy(false);
          }
        });
      });
    }).catch(function (err) {
      showAlert("danger", err.message || "Something went wrong.");
      setBusy(false);
    });
  }

  buttons.forEach(function (b) {
    b.addEventListener("click", function () { startCheckout(b.dataset.plan); });
  });
  applyCurrentPlanState();
})();
</script>
</body>
</html>

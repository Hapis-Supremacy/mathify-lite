<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>
    <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
      <!DOCTYPE html>
      <html lang="en">

      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Overview · Mathify Admin</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link
          href="https://fonts.googleapis.com/css2?family=Source+Sans+3:wght@400;500;600;700&family=Source+Serif+4:opsz,wght@8..60,500;8..60,600;8..60,700&display=swap"
          rel="stylesheet">
        <link href="../assets/css/app.css" rel="stylesheet">
      </head>

      <body data-role="admin" data-page="overview" data-base="../">

        <div class="container py-4 shell">

          <div class="mb-4">
            <h2 class="mb-1">Platform overview</h2>
            <p class="text-secondary mb-0">Engagement and learning metrics across Mathify.</p>
          </div>

          <div class="row g-3 mb-4">
            <div class="col-6 col-lg-3">
              <div class="card border-0 shadow-sm h-100">
                <div class="card-body">
                  <div class="text-secondary small fw-semibold mb-1"><i class="bi bi-person-check me-1"></i>Daily Active
                  </div>
                  <div class="fs-3 fw-bold">
                    <fmt:formatNumber value="${dailyActive}" groupingUsed="true" />
                  </div>
                  <div class="small" style="color:${dailyActiveDeltaColor};">${dailyActiveDelta}</div>
                </div>
              </div>
            </div>
            <div class="col-6 col-lg-3">
              <div class="card border-0 shadow-sm h-100">
                <div class="card-body">
                  <div class="text-secondary small fw-semibold mb-1"><i class="bi bi-calendar-week me-1"></i>Weekly
                    Active</div>
                  <div class="fs-3 fw-bold">
                    <fmt:formatNumber value="${weeklyActive}" groupingUsed="true" />
                  </div>
                  <div class="small" style="color:${weeklyActiveDeltaColor};">${weeklyActiveDelta}</div>
                </div>
              </div>
            </div>
            <div class="col-6 col-lg-3">
              <div class="card border-0 shadow-sm h-100">
                <div class="card-body">
                  <div class="text-secondary small fw-semibold mb-1"><i class="bi bi-activity me-1"></i>DAU / MAU</div>
                  <div class="fs-3 fw-bold">${dauMauRatio}%</div>
                  <div class="small" style="color:#6b7686;">Stickiness</div>
                </div>
              </div>
            </div>
            <div class="col-6 col-lg-3">
              <div class="card border-0 shadow-sm h-100">
                <div class="card-body">
                  <div class="text-secondary small fw-semibold mb-1"><i class="bi bi-arrow-repeat me-1"></i>Retention
                  </div>
                  <div class="fs-3 fw-bold">${retentionRate}%</div>
                  <div class="small" style="color:${retentionDeltaColor};">${retentionDelta}</div>
                </div>
              </div>
            </div>
          </div>

          <div class="row g-3">
            <div class="col-12 col-lg-6">
              <div class="card border-0 shadow-sm h-100">
                <div class="card-body p-4">
                  <h6 class="mb-3">Course popularity</h6>
                  <c:choose>
                    <c:when test="${not empty coursePopularity}">
                      <c:forEach var="cp" items="${coursePopularity}">
                        <div class="mb-3">
                          <div class="d-flex justify-content-between small mb-1"><span>${cp.courseName}</span><span
                              class="text-secondary">
                              <fmt:formatNumber value="${cp.learnerCount}" groupingUsed="true" /> learners
                            </span></div>
                          <div class="progress" style="height:8px;">
                            <div class="progress-bar" style="width:${cp.progressPercent}%;"></div>
                          </div>
                        </div>
                      </c:forEach>
                    </c:when>
                    <c:otherwise>
                      <p class="text-secondary small mb-0">No enrollment data yet.</p>
                    </c:otherwise>
                  </c:choose>
                </div>
              </div>
            </div>
            <div class="col-12 col-lg-6">
              <div class="card border-0 shadow-sm h-100">
                <div class="card-body p-4">
                  <h6 class="mb-3">Lesson completion rate</h6>
                  <c:choose>
                    <c:when test="${not empty courseCompletionRates}">
                      <c:forEach var="cr" items="${courseCompletionRates}">
                        <div class="mb-3">
                          <div class="d-flex justify-content-between small mb-1"><span>${cr.courseName}</span><span
                              class="text-secondary">${cr.completionPercent}%</span></div>
                          <div class="progress" style="height:8px;">
                            <div class="progress-bar" style="width:${cr.completionPercent}%;background-color:#1d8a5b;">
                            </div>
                          </div>
                        </div>
                      </c:forEach>
                    </c:when>
                    <c:otherwise>
                      <p class="text-secondary small mb-0">No completion data yet.</p>
                    </c:otherwise>
                  </c:choose>
                </div>
              </div>
            </div>
          </div>

        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script src="../assets/js/app.js?v=9" data-username="${sessionScope.userName}"></script>
      </body>

      </html>
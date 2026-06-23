<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ page import="com.mathify.model.*" %>
    <%@ page import="java.util.List" %>
      <% Boolean energyLocked=(Boolean) request.getAttribute("energyLocked"); Quiz lockedQuiz=(Quiz) request.getAttribute("lockedQuiz");
        String lockedCourseId=(String) request.getAttribute("courseId");
        if (Boolean.TRUE.equals(energyLocked)) {
      %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <title>Energy Empty · Mathify</title>
          <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
          <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
          <link href="../assets/css/app.css" rel="stylesheet">
        </head>

        <body data-role="student" data-page="catalog" data-base="../"
              data-energy="${globalStudent.energy}" data-xp="${globalProgress.totalXP}"
              data-energy-max="${globalStudent.maxEnergy}" data-energy-renews-at="${globalStudent.energyRenewalEpochMillis}"
              data-premium="${globalStudent.premiumActive}"
              data-level="${globalProgress.level}" data-streak="${globalProgress.currentStreak}">
          <div class="container py-4 shell">
            <div class="card border-0 shadow-sm mt-5">
              <div class="card-body p-4 text-center">
                <div class="display-4 mb-3" style="color:#d97706;"><i class="bi bi-lightning-charge-fill"></i></div>
                <h2 class="mb-2">Energy is empty</h2>
                <p class="text-secondary mb-4">
                  You need energy to start <strong><%= lockedQuiz != null ? lockedQuiz.getTitle() : "this quiz" %></strong>.
                </p>
                <div class="d-flex justify-content-center gap-2 flex-wrap">
                  <% if (lockedCourseId != null && !lockedCourseId.isEmpty()) { %>
                    <a href="course.do?id=<%= lockedCourseId %>" class="btn btn-outline-secondary">Back to Course</a>
                  <% } else { %>
                    <a href="catalog.do" class="btn btn-outline-secondary">Back to Catalog</a>
                  <% } %>
                  <a href="premium.jsp" class="btn btn-primary"><i class="bi bi-gem me-1"></i>Upgrade to Premium</a>
                </div>
              </div>
            </div>
          </div>

          <div class="modal fade" id="energyLockModal" tabindex="-1" aria-hidden="true" aria-labelledby="energyLockTitle">
            <div class="modal-dialog modal-dialog-centered">
              <div class="modal-content border-0 shadow">
                <div class="modal-header border-0 pb-0">
                  <h5 class="modal-title d-flex align-items-center gap-2" id="energyLockTitle">
                    <span class="rounded-circle d-inline-flex align-items-center justify-content-center" style="width:40px;height:40px;background:#fff4df;color:#d97706;">
                      <i class="bi bi-lightning-charge-fill"></i>
                    </span>
                    Energy empty
                  </h5>
                  <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body pt-3">
                  <p class="mb-2">You cannot start a quiz while your energy is empty.</p>
                  <div class="badge rounded-pill text-bg-light border fw-semibold mb-3" data-energy-renewal></div>
                  <p class="text-secondary mb-0">Upgrade to Premium for unlimited quiz energy.</p>
                </div>
                <div class="modal-footer border-0 pt-0">
                  <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Wait</button>
                  <a href="premium.jsp" class="btn btn-primary"><i class="bi bi-gem me-1"></i>Upgrade</a>
                </div>
              </div>
            </div>
          </div>

          <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
          <script src="../assets/js/app.js?v=6" data-username="${sessionScope.userName}"></script>
          <script>
            document.addEventListener('DOMContentLoaded', function () {
              var energyModal = document.getElementById('energyLockModal');
              if (energyModal && window.bootstrap) {
                new bootstrap.Modal(energyModal).show();
              }
            });
          </script>
        </body>

        </html>
        <% return; } Boolean completed=(Boolean) request.getAttribute("completed"); Quiz quiz=(Quiz) request.getAttribute("quiz");
        if (completed !=null && completed) {
          Integer finalScore=(Integer) request.getAttribute("finalScore");
          Integer totalPoints=(Integer) request.getAttribute("totalPoints");
          Integer scorePercent=(Integer) request.getAttribute("scorePercent");
          Boolean passed=(Boolean) request.getAttribute("passed");
          Boolean quizXpAwarded=(Boolean) request.getAttribute("quizXpAwarded");
          Integer quizXpReward=(Integer) request.getAttribute("quizXpReward");
          Boolean streakAwarded=(Boolean) request.getAttribute("streakAwarded");
          Integer currentStreak=(Integer) request.getAttribute("currentStreak");
          String courseId=(String) request.getAttribute("courseId");
      %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <title>Quiz Completed · Mathify</title>
          <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
          <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"
            rel="stylesheet">
          <link href="../assets/css/app.css" rel="stylesheet">
        </head>

        <body data-role="student" data-page="catalog" data-base="../"
              data-energy="${globalStudent.energy}" data-xp="${globalProgress.totalXP}"
              data-energy-max="${globalStudent.maxEnergy}" data-energy-renews-at="${globalStudent.energyRenewalEpochMillis}"
              data-premium="${globalStudent.premiumActive}"
              data-level="${globalProgress.level}" data-streak="${globalProgress.currentStreak}">
          <div class="container py-4 shell text-center mt-5">
            <div class="display-1 text-success mb-3"><i class="bi bi-check-circle-fill"></i></div>
            <h2>Quiz Completed!</h2>
            <p class="lead">You scored <strong>
                <%= finalScore %>
              </strong> / <%= totalPoints %> points (<%= scorePercent %>%) on <%= quiz.getTitle() %>.</p>
            <% if (Boolean.TRUE.equals(passed)) { %>
              <div class="alert alert-success d-inline-block">Congratulations! You passed the quiz.</div>
              <% if (Boolean.TRUE.equals(quizXpAwarded) && quizXpReward != null) { %>
                <div class="alert alert-warning d-inline-block ms-2"><i class="bi bi-stars me-1"></i>+<%= quizXpReward %> XP earned</div>
              <% } else { %>
                <div class="alert alert-secondary d-inline-block ms-2">Quiz XP already claimed.</div>
              <% } %>
              <% if (Boolean.TRUE.equals(streakAwarded) && currentStreak != null) { %>
                <div class="alert alert-warning d-inline-block ms-2"><i class="bi bi-fire me-1"></i><%= currentStreak %>-day streak</div>
              <% } %>
              <% } else { %>
                <div class="alert alert-danger d-inline-block">You did not meet the passing score of <%=
                    quiz.getPassingScore() %>.</div>
                <% } %>
                  <div class="mt-4">
                    <% if (courseId != null && !courseId.isEmpty()) { %>
                    <a href="course.do?id=<%= courseId %>" class="btn btn-primary">Return to Course</a>
                    <% } else { %>
                    <a href="catalog.do" class="btn btn-primary">Return to Catalog</a>
                    <% } %>
                  </div>
          </div>
          <% if (Boolean.TRUE.equals(streakAwarded) && currentStreak != null) { %>
          <div class="modal fade" id="streakModal" tabindex="-1" aria-hidden="true" aria-labelledby="streakModalTitle">
            <div class="modal-dialog modal-dialog-centered">
              <div class="modal-content border-0 shadow">
                <div class="modal-header border-0 pb-0">
                  <h5 class="modal-title d-flex align-items-center gap-2" id="streakModalTitle">
                    <span class="rounded-circle d-inline-flex align-items-center justify-content-center" style="width:40px;height:40px;background:#fff4df;color:#d97706;">
                      <i class="bi bi-fire"></i>
                    </span>
                    Streak updated
                  </h5>
                  <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body pt-3">
                  <div class="display-5 fw-bold" style="color:#d97706;"><%= currentStreak %> days</div>
                  <p class="text-secondary mb-0">You kept your streak alive by completing a quiz today.</p>
                </div>
                <div class="modal-footer border-0 pt-0">
                  <button type="button" class="btn btn-primary" data-bs-dismiss="modal">Nice</button>
                </div>
              </div>
            </div>
          </div>
          <% } %>
          <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
          <% if (Boolean.TRUE.equals(streakAwarded) && currentStreak != null) { %>
          <script>
            document.addEventListener('DOMContentLoaded', function () {
              var streakModal = document.getElementById('streakModal');
              if (streakModal && window.bootstrap) {
                new bootstrap.Modal(streakModal).show();
              }
            });
          </script>
          <% } %>
          <script src="../assets/js/app.js?v=6" data-username="${sessionScope.userName}"></script>
        </body>

        </html>
        <% return; } Question question=(Question) request.getAttribute("question"); Integer currentIndex=(Integer)
          request.getAttribute("currentIndex"); Integer totalQuestions=(Integer) request.getAttribute("totalQuestions");
          Boolean quizAnsweredAttr=(Boolean) request.getAttribute("quizAnswered");
          boolean quizAnswered=quizAnsweredAttr != null && quizAnsweredAttr;
          String questionTypeLabel = "Question";
          String questionTypeIcon = "bi-question-circle";
          if (question instanceof MultipleChoiceQuestion) {
            MultipleChoiceQuestion mcqForLabel = (MultipleChoiceQuestion) question;
            questionTypeLabel = mcqForLabel.getCorrectOptionCount() > 1 ? "Multiple select" : "Multiple choice";
            questionTypeIcon = "bi-ui-checks-grid";
          } else if (question instanceof FillBlankQuestion) {
            questionTypeLabel = "Short answer";
            questionTypeIcon = "bi-input-cursor-text";
          } else if (question instanceof DragDropQuestion) {
            questionTypeLabel = "Matching";
            questionTypeIcon = "bi-arrows-move";
          }
          String feedback=(String) session.getAttribute("quizFeedback"); int progressPercent=(int) (((double)
          (currentIndex + (quizAnswered ? 1 : 0)) / totalQuestions) * 100); %>
          <!DOCTYPE html>
          <html lang="en">

          <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <title>
              <%= quiz.getTitle() %> · Mathify
            </title>
            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
            <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"
              rel="stylesheet">
            <link rel="preconnect" href="https://fonts.googleapis.com">
            <link
              href="https://fonts.googleapis.com/css2?family=Source+Sans+3:wght@400;500;600;700&family=Source+Serif+4:opsz,wght@8..60,500;8..60,600;8..60,700&display=swap"
              rel="stylesheet">
            <link href="../assets/css/app.css" rel="stylesheet">
            <style>
              .quiz-option {
                cursor: pointer;
              }

              .quiz-dot {
                width: 26px;
                height: 26px;
                border: 2px solid #9aa6b8;
                color: #9aa6b8;
                font-size: .8rem;
              }

              .quiz-option input:checked+.quiz-dot {
                border-color: #1d4e89;
                color: #1d4e89;
                background-color: rgba(29, 78, 137, 0.1);
              }

              .quiz-option:has(input:checked) {
                border-color: #1d4e89 !important;
              }

              .dragging {
                opacity: 0.5;
              }

              .drop-zone {
                min-height: 60px;
                border: 2px dashed #ccc !important;
                transition: background-color 0.2s;
              }

              .drag-item {
                cursor: grab;
                user-select: none;
              }

              .drag-item:active {
                cursor: grabbing;
              }
            </style>
          </head>

          <body data-role="student" data-page="catalog" data-base="../"
                data-energy="${globalStudent.energy}" data-xp="${globalProgress.totalXP}"
                data-energy-max="${globalStudent.maxEnergy}" data-energy-renews-at="${globalStudent.energyRenewalEpochMillis}"
                data-premium="${globalStudent.premiumActive}"
                data-level="${globalProgress.level}" data-streak="${globalProgress.currentStreak}">

            <div class="container py-4 shell">

              <div class="d-flex justify-content-between align-items-center mb-2">
                <span class="text-secondary small fw-semibold">
                  <%= quiz.getTitle() %>
                </span>
                <a class="text-secondary small" href="catalog.do">Exit</a>
              </div>
              <div class="progress mb-4" style="height:8px;">
                <div class="progress-bar" id="quizProgressBar"></div>
              </div>
              <script>document.getElementById('quizProgressBar').style.width = '<%= progressPercent %>' + '%';</script>

            <% if ("correct".equals(feedback)) { %>
              <div class="alert alert-success d-flex align-items-center"><i class="bi bi-check-circle-fill me-2"></i>
                Correct! Well done.</div>
              <% } else if ("incorrect".equals(feedback)) { %>
                <div class="alert alert-danger d-flex align-items-center"><i class="bi bi-x-circle-fill me-2"></i>
                  Incorrect. Let's keep trying!</div>
                <% } %>

                  <div class="card border-0 shadow-sm">
                    <div class="card-body p-4">
                      <div class="d-flex justify-content-between align-items-center gap-2 mb-2 flex-wrap">
                        <div class="text-secondary small">Question <%= currentIndex + 1 %> of <%= totalQuestions %>
                              &middot; <%= question.getInfo().points() %> pts</div>
                        <span class="badge rounded-pill text-bg-light border"><i class="bi <%= questionTypeIcon %> me-1"></i><%= questionTypeLabel %></span>
                      </div>
                      <h4 class="mb-4">
                        <%= question.getInfo().prompt() %>
                      </h4>

                      <form action="quiz.do" method="post" id="quizForm">
                        <input type="hidden" name="action" value="<%= quizAnswered ? "next" : "submit" %>">
                        <% if (question instanceof MultipleChoiceQuestion) { MultipleChoiceQuestion
                          mcq=(MultipleChoiceQuestion) question; char optionLetter='A';
                          boolean multiSelect = mcq.getCorrectOptionCount() > 1;
                          String choiceType = multiSelect ? "checkbox" : "radio";
                        %>
                          <div class="d-flex flex-column gap-2">
                            <% for (MultipleChoiceQuestion.Option opt : mcq.getOptions()) { %>
                              <label class="btn text-start d-flex align-items-center border p-3 rounded quiz-option">
                                <input type="<%= choiceType %>" name="mc_option" value="<%= opt.id() %>" class="d-none" <%= (!multiSelect && !quizAnswered) ? "required" : "" %> <%= quizAnswered ? "disabled" : "" %>>
                                <span
                                  class="d-inline-flex align-items-center justify-content-center rounded-circle me-3 quiz-dot">
                                  <%= optionLetter++ %>
                                </span>
                                <%= opt.text() %>
                              </label>
                              <% } %>
                          </div>

                          <% } else if (question instanceof FillBlankQuestion) {
                            FillBlankQuestion fbq = (FillBlankQuestion) question;
                            int blankCount = Math.max(1, fbq.getBlankCount());
                          %>
                            <div class="d-flex flex-column gap-3">
                              <p class="text-secondary small">Type your answer in the box below. <%=
                                  fbq.isCaseSensitive() ? "(Case sensitive)" : "" %>
                              </p>
                              <% for (int i = 0; i < blankCount; i++) { %>
                              <input type="text" name="fb_answer_<%= i %>" class="form-control form-control-lg" <%= quizAnswered ? "disabled" : "required" %>
                                placeholder="Answer <%= i + 1 %>">
                              <% } %>
                            </div>

                            <% } else if (question instanceof DragDropQuestion) { DragDropQuestion
                              ddq=(DragDropQuestion) question; %>
                              <div class="alert alert-info small mb-3"><i class="bi bi-info-circle me-2"></i> Drag the
                                items from the top box and drop them into the correct matching zones below.</div>

                              <div id="draggables" class="d-flex flex-wrap gap-2 mb-4 p-3 bg-light rounded"
                                style="min-height: 80px;">
                                <% for (DragItem item : ddq.getDraggables()) { %>
                                  <div class="drag-item p-2 border rounded bg-white shadow-sm fw-semibold"
                                    draggable="<%= !quizAnswered %>" data-id="<%= item.id() %>">
                                    <%= item.text() %>
                                  </div>
                                  <% } %>
                              </div>

                              <div id="dropzones" class="d-flex flex-column gap-3">
                                <% for (DropZone zone : ddq.getDropZones()) { %>
                                  <div class="d-flex align-items-center gap-3">
                                    <div class="flex-grow-1 fw-semibold text-end" style="flex-basis: 50%;">
                                      <%= zone.label() %>
                                    </div>
                                    <div
                                      class="drop-zone border rounded p-2 text-center bg-light d-flex align-items-center justify-content-center"
                                      style="flex-basis: 50%;" data-id="<%= zone.id() %>">
                                      <span class="text-secondary small placeholder-text">Drop item here</span>
                                    </div>
                                    <input type="hidden" name="dd_zone_<%= zone.id() %>"
                                      id="input_zone_<%= zone.id() %>" value="" required <%= quizAnswered ? "disabled" : "" %>>
                                  </div>
                                  <% } %>
                              </div>

                              <% } %>

                                <div class="d-flex justify-content-end mt-4 pt-3 border-top"
                                  style="border-color:#eef1f6;">
                                  <button type="submit" class="btn btn-primary" id="nextBtn"><%= quizAnswered ? (currentIndex + 1 >= totalQuestions ? "See Result" : "Next Question") : "Submit Answer" %></button>
                                </div>
                      </form>
                    </div>
                  </div>

                  </div>

                  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
                  <script>
                    const quizAnswered = <%= quizAnswered %>;
                    // Drag and Drop Logic
                    const draggables = document.querySelectorAll('.drag-item');
                    const dropZones = document.querySelectorAll('.drop-zone');
                    const draggablesArea = document.getElementById('draggables');

                    draggables.forEach(draggable => {
                      draggable.addEventListener('dragstart', () => {
                        draggable.classList.add('dragging');
                      });
                      draggable.addEventListener('dragend', () => {
                        draggable.classList.remove('dragging');
                      });
                    });

                    dropZones.forEach(zone => {
                      zone.addEventListener('dragover', e => {
                        e.preventDefault();
                        zone.classList.add('bg-secondary', 'bg-opacity-10');
                      });
                      zone.addEventListener('dragleave', e => {
                        zone.classList.remove('bg-secondary', 'bg-opacity-10');
                      });
                      zone.addEventListener('drop', e => {
                        e.preventDefault();
                        zone.classList.remove('bg-secondary', 'bg-opacity-10');
                        const draggable = document.querySelector('.dragging');
                        if (draggable) {
                          // If there's already an item in this zone, move it back to the draggables area
                          const existingItem = zone.querySelector('.drag-item');
                          if (existingItem) {
                            draggablesArea.appendChild(existingItem);
                          }

                          // Hide placeholder text
                          const placeholder = zone.querySelector('.placeholder-text');
                          if (placeholder) placeholder.style.display = 'none';

                          zone.appendChild(draggable);

                          // Update hidden input
                          const zoneId = zone.getAttribute('data-id');
                          const dragId = draggable.getAttribute('data-id');
                          document.getElementById('input_zone_' + zoneId).value = dragId;
                        }
                      });
                    });

                    if (draggablesArea) {
                      draggablesArea.addEventListener('dragover', e => {
                        e.preventDefault();
                        draggablesArea.classList.add('border-primary');
                      });
                      draggablesArea.addEventListener('dragleave', e => {
                        draggablesArea.classList.remove('border-primary');
                      });
                      draggablesArea.addEventListener('drop', e => {
                        e.preventDefault();
                        draggablesArea.classList.remove('border-primary');
                        const draggable = document.querySelector('.dragging');
                        if (draggable) {
                          draggablesArea.appendChild(draggable);
                          // Clear any hidden input this might have been in
                          const allInputs = document.querySelectorAll('input[name^="dd_zone_"]');
                          allInputs.forEach(inp => {
                            if (inp.value === draggable.getAttribute('data-id')) {
                              inp.value = '';
                              // Show placeholder text again
                              const zone = document.querySelector('.drop-zone[data-id="' + inp.id.replace('input_zone_', '') + '"]');
                              if (zone) {
                                const placeholder = zone.querySelector('.placeholder-text');
                                if (placeholder) placeholder.style.display = 'block';
                              }
                            }
                          });
                        }
                      });
                    }

                    // Custom form validation for Drag and Drop
                    const quizForm = document.getElementById('quizForm');
                    if (quizForm && !quizAnswered) {
                      quizForm.addEventListener('submit', function (e) {
                        const choices = document.querySelectorAll('input[name="mc_option"]');
                        if (choices.length && !Array.from(choices).some(input => input.checked)) {
                          e.preventDefault();
                          alert('Please choose at least one answer.');
                          return;
                        }

                        if (!document.getElementById('draggables')) {
                          return;
                        }

                        let allFilled = true;
                        document.querySelectorAll('input[name^="dd_zone_"]').forEach(inp => {
                          if (!inp.value) allFilled = false;
                        });
                        if (!allFilled) {
                          e.preventDefault();
                          alert('Please match all items before submitting.');
                        }
                      });
                    }
                  </script>
                  <script src="../assets/js/app.js?v=6" data-username="${sessionScope.userName}"></script>
          </body>

          </html>

<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ attribute name="modalId" required="true" %>
<%@ attribute name="title" required="true" %>
<%@ attribute name="action" required="true" %>
<%@ attribute name="quizId" required="true" %>
<%@ attribute name="courseId" required="false" %>
<%@ attribute name="index" required="true" %>
<%@ attribute name="question" required="false" type="com.mathify.model.Question" %>

<c:set var="currentType" value="${question != null ? question.type.name() : 'MULTIPLE_CHOICE'}" />

<div class="modal fade" id="${modalId}" tabindex="-1">
  <div class="modal-dialog modal-lg">
    <form class="modal-content border-0 question-form" action="${pageContext.request.contextPath}/admin/quiz-action.do" method="post">
      <input type="hidden" name="action" value="${action}"/>
      <input type="hidden" name="quizId" value="${quizId}"/>
      <input type="hidden" name="courseId" value="${courseId}"/>
      <input type="hidden" name="orderIndex" value="${index}"/>
      <c:if test="${question != null}">
        <input type="hidden" name="questionId" value="${question.info.id()}"/>
      </c:if>

      <div class="modal-header"><h5 class="modal-title">${title}</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="mb-3"><label class="form-label small fw-semibold">Question type</label>
          <select class="form-select js-qtype" name="qType">
            <option value="MULTIPLE_CHOICE" ${currentType == 'MULTIPLE_CHOICE' ? 'selected' : ''}>Multiple choice</option>
            <option value="FILL_BLANK" ${currentType == 'FILL_BLANK' ? 'selected' : ''}>Fill in the blank</option>
            <option value="DRAG_AND_DROP" ${currentType == 'DRAG_AND_DROP' ? 'selected' : ''}>Match pairs</option>
          </select></div>
        <div class="mb-3"><label class="form-label small fw-semibold">Prompt</label><textarea class="form-control" name="prompt" rows="2" required><c:out value="${question.info.prompt()}"/></textarea></div>
        <div class="mb-3" style="max-width:150px;"><label class="form-label small fw-semibold">Points</label><input class="form-control" name="points" type="number" value="${question != null ? question.info.points() : 10}" required></div>

        <div data-qbody="MULTIPLE_CHOICE" class="${currentType != 'MULTIPLE_CHOICE' ? 'd-none' : ''}">
          <label class="form-label small fw-semibold mb-2">Options <span class="text-secondary fw-normal">- tick the correct answer(s)</span></label>
          <div class="js-mc-rows">
            <c:choose>
              <c:when test="${currentType == 'MULTIPLE_CHOICE'}">
                <c:forEach var="opt" items="${question.options}" varStatus="ost">
                  <div class="d-flex align-items-center gap-2 mb-2 mc-row">
                    <input class="form-check-input mt-0 mc-cb" type="checkbox" name="mcCorrectIndex" value="${ost.index}" ${question.correctOptionIds.contains(opt.id()) ? 'checked' : ''} style="flex:none;">
                    <input class="form-control" name="mcOptionText" placeholder="Option text" value="<c:out value='${opt.text()}'/>" required>
                    <button type="button" class="btn btn-sm btn-outline-secondary btn-rm" style="flex:none;"><i class="bi bi-x-lg"></i></button>
                  </div>
                </c:forEach>
              </c:when>
              <c:otherwise>
                <div class="d-flex align-items-center gap-2 mb-2 mc-row">
                  <input class="form-check-input mt-0 mc-cb" type="checkbox" name="mcCorrectIndex" value="0" style="flex:none;">
                  <input class="form-control" name="mcOptionText" placeholder="Option text" required>
                  <button type="button" class="btn btn-sm btn-outline-secondary btn-rm" style="flex:none;"><i class="bi bi-x-lg"></i></button>
                </div>
              </c:otherwise>
            </c:choose>
          </div>
          <button type="button" class="btn btn-sm btn-light js-add-mc"><i class="bi bi-plus-lg me-1"></i>Add option</button>
        </div>

        <div data-qbody="FILL_BLANK" class="${currentType != 'FILL_BLANK' ? 'd-none' : ''}">
          <label class="form-label small fw-semibold mb-2">Accepted answers</label>
          <div class="js-fb-rows">
            <c:choose>
              <c:when test="${currentType == 'FILL_BLANK'}">
                <c:forEach var="ans" items="${question.correctAnswers}">
                  <div class="d-flex align-items-center gap-2 mb-2 fb-row">
                    <input class="form-control" name="fbAnswer" placeholder="e.g. 5" value="<c:out value='${ans}'/>">
                    <button type="button" class="btn btn-sm btn-outline-secondary btn-rm" style="flex:none;"><i class="bi bi-x-lg"></i></button>
                  </div>
                </c:forEach>
              </c:when>
              <c:otherwise>
                <div class="d-flex align-items-center gap-2 mb-2 fb-row">
                  <input class="form-control" name="fbAnswer" placeholder="e.g. 5">
                  <button type="button" class="btn btn-sm btn-outline-secondary btn-rm" style="flex:none;"><i class="bi bi-x-lg"></i></button>
                </div>
              </c:otherwise>
            </c:choose>
          </div>
          <button type="button" class="btn btn-sm btn-light js-add-fb"><i class="bi bi-plus-lg me-1"></i>Add answer</button>
          <div class="form-check mt-3"><input class="form-check-input" type="checkbox" name="caseSensitive" id="cs-${modalId}" ${currentType == 'FILL_BLANK' && question.caseSensitive ? 'checked' : ''}><label class="form-check-label small" for="cs-${modalId}">Case sensitive</label></div>
        </div>

        <div data-qbody="DRAG_AND_DROP" class="${currentType != 'DRAG_AND_DROP' ? 'd-none' : ''}">
          <label class="form-label small fw-semibold mb-2">Pairs to match</label>
          <div class="js-dd-rows">
            <c:choose>
              <c:when test="${currentType == 'DRAG_AND_DROP'}">
                <c:forEach var="pair" items="${question.labelPairs}">
                  <div class="d-flex align-items-center gap-2 mb-2 dd-row">
                    <input class="form-control" name="ddDrag" placeholder="Term" value="<c:out value='${pair[0]}'/>">
                    <i class="bi bi-arrow-right text-secondary" style="flex:none;"></i>
                    <input class="form-control" name="ddDrop" placeholder="Matches with" value="<c:out value='${pair[1]}'/>">
                    <button type="button" class="btn btn-sm btn-outline-secondary btn-rm" style="flex:none;"><i class="bi bi-x-lg"></i></button>
                  </div>
                </c:forEach>
              </c:when>
              <c:otherwise>
                <div class="d-flex align-items-center gap-2 mb-2 dd-row">
                  <input class="form-control" name="ddDrag" placeholder="Term">
                  <i class="bi bi-arrow-right text-secondary" style="flex:none;"></i>
                  <input class="form-control" name="ddDrop" placeholder="Matches with">
                  <button type="button" class="btn btn-sm btn-outline-secondary btn-rm" style="flex:none;"><i class="bi bi-x-lg"></i></button>
                </div>
              </c:otherwise>
            </c:choose>
          </div>
          <button type="button" class="btn btn-sm btn-light js-add-dd"><i class="bi bi-plus-lg me-1"></i>Add pair</button>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="submit" class="btn btn-primary">Save question</button>
      </div>
    </form>
  </div>
</div>

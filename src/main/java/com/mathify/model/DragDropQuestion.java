package com.mathify.model;

import java.util.List;
import java.util.Map;

/** A question where draggable terms are matched to drop zones. */
public final class DragDropQuestion implements Question {

    private final QuestionInfo info;
    private final List<DragItem> draggables;
    private final List<DropZone> dropZones;
    /** Map of dropZoneId to the draggableId that belongs in it. */
    private final Map<String, String> correctPairings;

    public DragDropQuestion(QuestionInfo info, List<DragItem> draggables,
                            List<DropZone> dropZones, Map<String, String> correctPairings) {
        this.info = info;
        this.draggables = draggables;
        this.dropZones = dropZones;
        this.correctPairings = correctPairings;
    }

    @Override
    public QuestionInfo getInfo() {
        return info;
    }

    @Override
    public QuestionType getType() {
        return QuestionType.DRAG_AND_DROP;
    }

    @Override
    public boolean evaluate(Answer answer) {
        if (answer instanceof DragAndDropAnswer dd) {
            return correctPairings.equals(dd.pairings());
        }
        return false;
    }

    public List<DragItem> getDraggables() {
        return draggables;
    }

    public List<DropZone> getDropZones() {
        return dropZones;
    }
}

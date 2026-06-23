package com.mathify.model;

import java.util.ArrayList;
import java.util.HashMap;
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

    /**
     * The correct matches expressed as {@code [term, match]} label pairs, for
     * pre-filling the admin editor (which works in labels, not ids). Order is
     * not significant since each pair is independent.
     */
    public List<String[]> getLabelPairs() {
        Map<String, String> dragLabelById = new HashMap<>();
        for (DragItem d : draggables) {
            dragLabelById.put(d.id(), d.text());
        }
        Map<String, String> dropLabelById = new HashMap<>();
        for (DropZone z : dropZones) {
            dropLabelById.put(z.id(), z.label());
        }
        List<String[]> pairs = new ArrayList<>();
        // correctPairings maps dropZoneId -> dragItemId
        for (Map.Entry<String, String> e : correctPairings.entrySet()) {
            pairs.add(new String[]{ dragLabelById.get(e.getValue()), dropLabelById.get(e.getKey()) });
        }
        return pairs;
    }
}

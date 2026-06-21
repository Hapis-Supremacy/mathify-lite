package com.mathify.model;

import java.util.Map;

/** Answer to a {@link DragDropQuestion}: a map of draggableId to dropZoneId. */
public record DragAndDropAnswer(Map<String, String> pairings) implements Answer {
}

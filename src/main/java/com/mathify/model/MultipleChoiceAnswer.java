package com.mathify.model;

import java.util.Set;

/** Answer to a {@link MultipleChoiceQuestion}: the ids of the selected options. */
public record MultipleChoiceAnswer(Set<String> selectedOptionIds) implements Answer {
}

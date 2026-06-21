package com.mathify.model;

/**
 * A learner's submitted answer to a {@link Question}.
 * Sealed so the permitted record types form a closed set, mirroring the
 * {@code Answer} interface from the class diagram's code block.
 */
public sealed interface Answer
        permits MultipleChoiceAnswer, FillBlankAnswer, DragAndDropAnswer {
}

package com.mathify.model;

import java.util.List;

/**
 * Answer to a {@link FillBlankQuestion}.
 * A list because a prompt can have multiple blanks: "__ is the capital of __".
 */
public record FillBlankAnswer(List<String> filledValues) implements Answer {
}

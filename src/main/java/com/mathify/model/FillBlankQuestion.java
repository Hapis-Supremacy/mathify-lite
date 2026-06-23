package com.mathify.model;

import java.util.List;

/** A question answered by typing text into one or more blanks. */
public final class FillBlankQuestion implements Question {

    private final QuestionInfo info;
    private final List<String> correctAnswers;
    private final boolean caseSensitive;

    public FillBlankQuestion(QuestionInfo info, List<String> correctAnswers, boolean caseSensitive) {
        this.info = info;
        this.correctAnswers = correctAnswers;
        this.caseSensitive = caseSensitive;
    }

    @Override
    public QuestionInfo getInfo() {
        return info;
    }

    @Override
    public QuestionType getType() {
        return QuestionType.FILL_BLANK;
    }

    @Override
    public boolean evaluate(Answer answer) {
        if (!(answer instanceof FillBlankAnswer fb)) {
            return false;
        }
        List<String> filled = fb.filledValues();
        if (filled.size() != correctAnswers.size()) {
            return false;
        }
        for (int i = 0; i < filled.size(); i++) {
            String given = filled.get(i) == null ? "" : filled.get(i).trim();
            String expected = correctAnswers.get(i) == null ? "" : correctAnswers.get(i).trim();
            boolean equal = caseSensitive ? given.equals(expected) : given.equalsIgnoreCase(expected);
            if (!equal) {
                return false;
            }
        }
        return true;
    }

    public boolean isCaseSensitive() {
        return caseSensitive;
    }

    public int getBlankCount() {
        return correctAnswers.size();
    }
}

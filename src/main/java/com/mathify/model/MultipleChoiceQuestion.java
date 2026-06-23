package com.mathify.model;

import java.util.List;
import java.util.Set;

/** A question where the learner selects one or more correct options. */
public final class MultipleChoiceQuestion implements Question {

    /** A selectable option. */
    public record Option(String id, String text) {
    }

    private final QuestionInfo info;
    private final List<Option> options;
    private final Set<String> correctOptionIds;

    public MultipleChoiceQuestion(QuestionInfo info, List<Option> options, Set<String> correctOptionIds) {
        this.info = info;
        this.options = options;
        this.correctOptionIds = correctOptionIds;
    }

    @Override
    public QuestionInfo getInfo() {
        return info;
    }

    @Override
    public QuestionType getType() {
        return QuestionType.MULTIPLE_CHOICE;
    }

    @Override
    public boolean evaluate(Answer answer) {
        if (answer instanceof MultipleChoiceAnswer mc) {
            return correctOptionIds.equals(mc.selectedOptionIds());
        }
        return false;
    }

    public List<Option> getOptions() {
        return options;
    }

    public int getCorrectOptionCount() {
        return correctOptionIds.size();
    }
}

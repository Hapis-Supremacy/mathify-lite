package com.mathify.model;

/**
 * A quiz question. Concrete kinds carry their own data but share identity via
 * {@link QuestionInfo}; the {@code getId/getPrompt/getPoints} accessors are
 * provided as defaults that delegate to that info.
 */
public interface Question {

    QuestionInfo getInfo();

    QuestionType getType();

    boolean evaluate(Answer answer);

    // Default, not implemented by concrete classes:
    default String getId() {
        return getInfo().id();
    }

    default String getPrompt() {
        return getInfo().prompt();
    }

    default int getPoints() {
        return getInfo().points();
    }
}

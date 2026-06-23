package com.mathify.util;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotEquals;
import static org.junit.Assert.assertNull;

import org.junit.Test;

/**
 * Unit tests for {@link AuthUtil} token generation/validation. These are
 * DB-free and run in CI without a MySQL service.
 */
public class AuthUtilTest {

    @Test
    public void generateThenValidateRoundTrips() {
        String token = AuthUtil.generateToken("user-123");
        assertEquals("user-123", AuthUtil.validateToken(token));
    }

    @Test
    public void validateRejectsNullAndEmpty() {
        assertNull(AuthUtil.validateToken(null));
        assertNull(AuthUtil.validateToken(""));
    }

    @Test
    public void validateRejectsGarbage() {
        assertNull(AuthUtil.validateToken("not-a-real-token"));
        assertNull(AuthUtil.validateToken("@@@invalid-base64@@@"));
    }

    @Test
    public void validateRejectsTamperedSignature() {
        String token = AuthUtil.generateToken("user-123");
        // Flip the last character to corrupt the signature while keeping the
        // base64 alphabet valid.
        char last = token.charAt(token.length() - 1);
        char swapped = last == 'A' ? 'B' : 'A';
        String tampered = token.substring(0, token.length() - 1) + swapped;
        assertNull(AuthUtil.validateToken(tampered));
    }

    @Test
    public void differentUsersProduceDifferentTokens() {
        assertNotEquals(
            AuthUtil.generateToken("user-123"),
            AuthUtil.generateToken("user-456"));
    }
}

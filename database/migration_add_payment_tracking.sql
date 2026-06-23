-- ============================================================================
-- Migration: add Midtrans payment tracking to subscriptions
-- Run once against an existing mathify_db. Fresh installs already include
-- these columns (see mathify_schema.sql).
-- ============================================================================

USE mathify_db;

ALTER TABLE subscriptions
    ADD COLUMN midtrans_order_id VARCHAR(100) NULL AFTER is_canceled,
    ADD COLUMN payment_status    VARCHAR(30)  NULL AFTER midtrans_order_id;

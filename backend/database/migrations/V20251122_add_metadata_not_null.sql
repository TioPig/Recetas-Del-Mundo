-- Safe migration: set sesion_pago.metadata to empty JSON where NULL
-- and add NOT NULL constraint.
-- Run only after a verified backup.

BEGIN;

-- 1) Normalize existing NULLs to empty JSON
UPDATE sesion_pago
SET metadata = '{}'::jsonb
WHERE metadata IS NULL;

-- 2) Ensure there are no NULLs left (manual check recommended)
-- SELECT count(*) FROM sesion_pago WHERE metadata IS NULL;

-- 3) Add NOT NULL constraint
ALTER TABLE sesion_pago
ALTER COLUMN metadata SET NOT NULL;

COMMIT;

-- Notes:
-- - This migration is intentionally minimal: it replaces NULL metadata with an
--   empty JSON object. If you prefer a different sentinel value, edit before
--   applying.
-- - Apply in staging first and verify application behavior before production.
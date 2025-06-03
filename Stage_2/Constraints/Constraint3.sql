ALTER TABLE Equipment
ALTER COLUMN warranty_expiration
SET DEFAULT (CURRENT_DATE + INTERVAL '2 years');
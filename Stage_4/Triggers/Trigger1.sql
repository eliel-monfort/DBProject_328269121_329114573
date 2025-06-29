-- Trigger function: Log warehouse entity transfer (generic for all relevant tables)
CREATE OR REPLACE FUNCTION log_warehouse_entity_transfer() RETURNS trigger AS $$
DECLARE
    log_flag TEXT;
BEGIN
    BEGIN
        log_flag := current_setting('myapp.log_transfer', true);
    EXCEPTION WHEN OTHERS THEN
        log_flag := NULL;
    END;

    IF log_flag = 'on' AND NEW.warehouse_ID IS DISTINCT FROM OLD.warehouse_ID THEN
        RAISE NOTICE 'Entity of type % [entity: %] moved from warehouse % to warehouse %',
            TG_TABLE_NAME, NEW.*::record, OLD.warehouse_ID, NEW.warehouse_ID;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Attach the trigger to all relevant tables (example: equipment)
CREATE TRIGGER trg_log_equipment_transfer
AFTER UPDATE OF warehouse_ID ON equipment
FOR EACH ROW EXECUTE FUNCTION log_warehouse_entity_transfer();

CREATE TRIGGER trg_log_ammunition_transfer
AFTER UPDATE OF warehouse_ID ON ammunition
FOR EACH ROW EXECUTE FUNCTION log_warehouse_entity_transfer();

CREATE TRIGGER trg_log_armored_vehicle_transfer
AFTER UPDATE OF warehouse_ID ON armored_vehicle
FOR EACH ROW EXECUTE FUNCTION log_warehouse_entity_transfer();
-- Trigger function: Prevent assigning a not-ready vehicle to a mission
CREATE OR REPLACE FUNCTION trg_fn_prevent_assign_not_ready_vehicle()
RETURNS trigger AS $$
DECLARE
    is_ready BOOLEAN;
BEGIN
    -- Check if the vehicle is ready (maintenance is valid)
    SELECT (next_maintenance_date > CURRENT_DATE)
    INTO is_ready
    FROM armored_vehicle
    WHERE vehicle_ID = NEW.vehicle_ID;

    -- If not ready, cancel the assignment and raise a warning
    IF NOT is_ready THEN
        RAISE WARNING 'Assign canceled: Vehicle % is NOT ready (maintenance overdue)', NEW.vehicle_ID;
        RETURN NULL; -- Cancel the insert
    END IF;

    RETURN NEW; -- Allow the insert if ready
END;
$$ LANGUAGE plpgsql;


-- Trigger: Call the function before inserting a vehicle-mission assignment
CREATE TRIGGER trg_prevent_assign_not_ready_vehicle
BEFORE INSERT ON vehicle_mission_assignment
FOR EACH ROW
EXECUTE FUNCTION trg_fn_prevent_assign_not_ready_vehicle();
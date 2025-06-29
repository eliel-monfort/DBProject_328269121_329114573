CREATE OR REPLACE PROCEDURE manage_mission_operations(
    p_mission_id INT,
    p_action TEXT,
    p_vehicle_id INT DEFAULT NULL,
    p_unit_id INT DEFAULT NULL,
    p_soldier_id INT DEFAULT NULL,
    p_new_unit_id INT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    vehicle_in_use INT;
    available_vehicle_id INT;
    not_ready_vehicle_id INT;
    soldier_exists INT;
    summary_rec RECORD;
    vehicle_count INT;
    inserted_vehicle_id INT;
    cur CURSOR FOR
        SELECT vma.vehicle_ID, av.model, av.next_maintenance_date
        FROM vehicle_mission_assignment vma
        JOIN armored_vehicle av ON vma.vehicle_ID = av.vehicle_ID
        WHERE vma.mission_ID = p_mission_id;
BEGIN
	-- Explicit cursor: Check if vehicle is already assigned
    IF p_action = 'assign_vehicle' THEN
        OPEN cur;
        LOOP
            FETCH cur INTO summary_rec;
            EXIT WHEN NOT FOUND;
            IF summary_rec.vehicle_ID = p_vehicle_id THEN
                RAISE WARNING 'Vehicle % is already assigned to mission %', p_vehicle_id, p_mission_id;
                CLOSE cur;
                RETURN;
            END IF;
        END LOOP;
        CLOSE cur;

        -- Assign vehicle with RETURNING clause
        BEGIN
            INSERT INTO vehicle_mission_assignment (vehicle_ID, mission_ID)
            VALUES (p_vehicle_id, p_mission_id)
            RETURNING vehicle_ID INTO inserted_vehicle_id;

            -- Only print success if vehicle was actually inserted
            IF inserted_vehicle_id IS NOT NULL THEN
                RAISE NOTICE 'Vehicle % assigned to mission %', p_vehicle_id, p_mission_id;
            END IF;
        EXCEPTION
            WHEN unique_violation THEN
                RAISE WARNING 'Vehicle % already assigned (unique constraint)', p_vehicle_id;
            WHEN OTHERS THEN
                RAISE WARNING 'Error assigning vehicle: %', SQLERRM;
        END;

	-- Remove vehicle
    ELSIF p_action = 'remove_vehicle' THEN
        DELETE FROM vehicle_mission_assignment
        WHERE vehicle_ID = p_vehicle_id AND mission_ID = p_mission_id;
        GET DIAGNOSTICS vehicle_count = ROW_COUNT;
        IF vehicle_count > 0 THEN
            RAISE NOTICE 'Vehicle % removed from mission %', p_vehicle_id, p_mission_id;
        ELSE
            RAISE NOTICE 'Vehicle % not assigned to mission %', p_vehicle_id, p_mission_id;
        END IF;

	-- Find not-ready vehicle (implicit cursor)
    ELSIF p_action = 'replace_vehicle' THEN
        SELECT vma.vehicle_ID INTO not_ready_vehicle_id
        FROM vehicle_mission_assignment vma
        JOIN armored_vehicle av ON vma.vehicle_ID = av.vehicle_ID
        WHERE vma.mission_ID = p_mission_id
          AND av.next_maintenance_date <= CURRENT_DATE
        LIMIT 1;

        IF not_ready_vehicle_id IS NULL THEN
            RAISE WARNING 'No not-ready vehicle found for mission %', p_mission_id;
        ELSE
            -- Find available ready vehicle not assigned to any mission
            SELECT av.vehicle_ID INTO available_vehicle_id
            FROM armored_vehicle av
            WHERE av.next_maintenance_date > CURRENT_DATE
              AND av.vehicle_ID NOT IN (
                  SELECT vehicle_ID FROM vehicle_mission_assignment
              )
            LIMIT 1;

            IF available_vehicle_id IS NULL THEN
                RAISE WARNING 'No available ready vehicle to replace';
            ELSE
                DELETE FROM vehicle_mission_assignment
                WHERE vehicle_ID = not_ready_vehicle_id AND mission_ID = p_mission_id;
                INSERT INTO vehicle_mission_assignment (vehicle_ID, mission_ID)
                VALUES (available_vehicle_id, p_mission_id);
                RAISE NOTICE 'Vehicle % replaced by vehicle % in mission %',
                    not_ready_vehicle_id, available_vehicle_id, p_mission_id;
            END IF;
        END IF;

	-- Move a soldier from one unit to another
    ELSIF p_action = 'move_soldier' THEN
        IF p_soldier_id IS NULL OR p_new_unit_id IS NULL THEN
            RAISE WARNING 'Soldier ID and new unit ID must be provided for move_soldier action';
        ELSE
            SELECT COUNT(*) INTO soldier_exists FROM soldier WHERE personnel_ID = p_soldier_id;
            IF soldier_exists = 0 THEN
                RAISE WARNING 'Soldier % does not exist', p_soldier_id;
            ELSE
                UPDATE soldier SET unit_ID = p_new_unit_id WHERE personnel_ID = p_soldier_id;
                RAISE NOTICE 'Soldier % moved to unit %', p_soldier_id, p_new_unit_id;
            END IF;
        END IF;

	-- Use a temporary table for summary
    ELSIF p_action = 'summary' THEN
        CREATE TEMP TABLE tmp_summary AS
            SELECT 
                m.mission_ID, m.mission_name, u.unit_ID, u.unit_name,
                COUNT(DISTINCT vma.vehicle_ID) AS total_vehicles,
                SUM(CASE WHEN av.next_maintenance_date > CURRENT_DATE THEN 1 ELSE 0 END) AS ready_vehicles,
                COUNT(DISTINCT s.personnel_ID) AS total_soldiers
            FROM mission m
            JOIN unit_mission_assignment uma ON m.mission_ID = uma.mission_ID
            JOIN unit u ON uma.unit_ID = u.unit_ID
            LEFT JOIN vehicle_mission_assignment vma ON m.mission_ID = vma.mission_ID
            LEFT JOIN armored_vehicle av ON vma.vehicle_ID = av.vehicle_ID
            LEFT JOIN soldier s ON s.unit_ID = u.unit_ID
            WHERE m.mission_ID = p_mission_id AND u.unit_ID = p_unit_id
            GROUP BY m.mission_ID, m.mission_name, u.unit_ID, u.unit_name;

        FOR summary_rec IN SELECT * FROM tmp_summary
        LOOP
            RAISE NOTICE 'Mission: %, Unit: %, Vehicles: %, Ready: %, Soldiers: %',
                summary_rec.mission_ID, summary_rec.unit_ID, summary_rec.total_vehicles,
                summary_rec.ready_vehicles, summary_rec.total_soldiers;
        END LOOP;
        DROP TABLE IF EXISTS tmp_summary;

    ELSE
        RAISE WARNING 'Invalid action: %', p_action;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Error in manage_mission_operations: %', SQLERRM;
END;
$$;
-- Main Program: Mission Management System
DO $$
DECLARE
    mission_cursor REFCURSOR;
    mission_rec RECORD;
    test_mission_id INT := 1669;
    test_unit_id INT := 1082;
    test_vehicle_id INT := 1055;
    test_soldier_id INT := 1101;
	test_not_ready_vehicle INT := 9991;
BEGIN
    RAISE NOTICE '===== MISSION MANAGEMENT SYSTEM =====';
    RAISE NOTICE '=== PHASE 1: Initial Mission Report ===';
    
    -- Step 1: Get mission preparedness report
    mission_cursor := get_mission_preparedness(2);
    LOOP
        FETCH mission_cursor INTO mission_rec;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Mission: % (ID: %), Unit: % - Status: %',
            mission_rec.mission_name, mission_rec.mission_id,
            mission_rec.unit_name, mission_rec.mission_status;
        RAISE NOTICE '  - Vehicles: % (% ready), Soldiers: %',
            mission_rec.total_vehicles, mission_rec.ready_vehicles,
            mission_rec.total_soldiers;
        RAISE NOTICE '  - Assessment: %', mission_rec.mission_comment;
    END LOOP;
    CLOSE mission_cursor;
    
    RAISE NOTICE '';
    RAISE NOTICE '=== PHASE 2: Mission Operations ===';
    
    -- Step 2: Assign vehicle to mission
    RAISE NOTICE 'Operation 1: Assigning vehicle % to mission %', test_vehicle_id, test_mission_id;
    CALL manage_mission_operations(
        p_mission_id => test_mission_id,
        p_unit_id => test_unit_id,
        p_action => 'assign_vehicle',
        p_vehicle_id => test_vehicle_id
    );
    
    -- Step 3: Replace non-ready vehicle
    RAISE NOTICE 'Operation 2: Replacing non-ready vehicle in mission %', test_mission_id;
    CALL manage_mission_operations(
        p_mission_id => test_mission_id,
        p_unit_id => test_unit_id,
        p_action => 'replace_vehicle'
    );
    
    -- Step 4: Move soldier to new unit
    RAISE NOTICE 'Operation 3: Moving soldier % to new unit', test_soldier_id;
    CALL manage_mission_operations(
        p_mission_id => NULL,
        p_unit_id => NULL,
        p_action => 'move_soldier',
        p_soldier_id => test_soldier_id,
        p_new_unit_id => 1083
    );

	-- Step 5: Trigger Demo - Prevent Assign Not-Ready Vehicle
	RAISE NOTICE 'Operation 4: Trigger demo - assign NOT READY and READY vehicles';
	CALL manage_mission_operations(
        p_mission_id => test_mission_id,
        p_unit_id => test_unit_id,
        p_action => 'assign_vehicle',
        p_vehicle_id => 9991  -- Vehicle with next_maintenance_date <= CURRENT_DATE
    );
	
    -- Step 6: Get mission summary
    RAISE NOTICE 'Operation 5: Getting summary for mission %', test_mission_id;
    CALL manage_mission_operations(
        p_mission_id => test_mission_id,
        p_unit_id => test_unit_id,
        p_action => 'summary'
    );
    
    RAISE NOTICE '';
    RAISE NOTICE '=== PHASE 3: Updated Mission Report ===';
    
    -- Step 6: Get updated report
    DROP TABLE IF EXISTS tmp_mission_report;
    mission_cursor := get_mission_preparedness(2);
    LOOP
        FETCH mission_cursor INTO mission_rec;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Mission: % (ID: %), Unit: % - Status: %',
            mission_rec.mission_name, mission_rec.mission_id,
            mission_rec.unit_name, mission_rec.mission_status;
    END LOOP;
    CLOSE mission_cursor;
    
    RAISE NOTICE '';
    RAISE NOTICE '=== PHASE 4: Exception Handling Demo ===';
    
    -- Step 7: Demonstrate error handling (duplicate assignment)
    BEGIN
        RAISE NOTICE 'Operation 5: Attempting duplicate vehicle assignment...';
        CALL manage_mission_operations(
            p_mission_id => test_mission_id,
            p_unit_id => test_unit_id,
            p_action => 'assign_vehicle',
            p_vehicle_id => test_vehicle_id
        );
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Error handled: %', SQLERRM;
    END;
    
    RAISE NOTICE '=======================================';
    RAISE NOTICE 'Program completed successfully';
END $$;
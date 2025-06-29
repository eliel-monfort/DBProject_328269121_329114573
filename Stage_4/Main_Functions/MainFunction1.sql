-- Main Program: Warehouse Management System
DO $$
DECLARE
    cur refcursor;
    rec RECORD;
BEGIN
    -- === PHASE 1: Initial Warehouse Status Report ===
    cur := 'phase1_cursor';
    PERFORM get_warehouses_status(cur);
    RAISE NOTICE '=== PHASE 1: Initial Warehouse Status Report ===';
    LOOP
        FETCH cur INTO rec;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Warehouse % (%): %/% used, % vehicles, % equipment, % ammo | Alert: %',
            rec.warehouse_id, rec.location_name, rec.used_space, rec.capacity,
            rec.total_vehicles, rec.total_equipment, rec.total_ammunition, rec.warehouse_alert;
    END LOOP;
    CLOSE cur;
	
	RAISE NOTICE '';
	
    -- === PHASE 2: All Transfers (with resets to ensure success) ===
    RAISE NOTICE '=== PHASE 2: Transfer Operations ===';

    -- Equipment transfer
    CALL transfer_warehouse_entity('equipment', 2402, 2301, 2300);

    -- Ammunition transfer
    CALL transfer_warehouse_entity('ammunition', 2501, 2301, 2300);

    -- Armored vehicle transfer
    CALL transfer_warehouse_entity('armored_vehicle', 2601, 2301, 2300);

    -- Reset vehicle location before part transfer
    UPDATE armored_vehicle SET warehouse_ID = 2301 WHERE vehicle_ID = 2601;
    -- Vehicle part transfer
    CALL transfer_warehouse_entity('vehicle_part', 2701, 2301, 2300, 2601);
	
	RAISE NOTICE '';
    
	-- === PHASE 3: Updated Warehouse Status Report ===
    cur := 'phase3_cursor';
    PERFORM get_warehouses_status(cur);
    RAISE NOTICE '=== PHASE 3: Updated Warehouse Status Report ===';
    LOOP
        FETCH cur INTO rec;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Warehouse % (%): %/% used, % vehicles, % equipment, % ammo | Alert: %',
            rec.warehouse_id, rec.location_name, rec.used_space, rec.capacity,
            rec.total_vehicles, rec.total_equipment, rec.total_ammunition, rec.warehouse_alert;
    END LOOP;
    CLOSE cur;

      RAISE NOTICE '=======================================';
    RAISE NOTICE 'Program completed successfully';
END $$;
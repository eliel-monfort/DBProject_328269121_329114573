CREATE OR REPLACE PROCEDURE transfer_warehouse_entity(
    IN p_entity_type TEXT,           -- 'equipment', 'ammunition', 'armored_vehicle', 'vehicle_part'
    IN p_entity_id INT,              -- equipment_id / ammunition_id / vehicle_id / part_id
    IN p_source_warehouse INT,
    IN p_target_warehouse INT,
    IN p_entity_vehicle_id INT DEFAULT NULL -- Only for vehicle_part
)
LANGUAGE plpgsql
AS $$
BEGIN
	PERFORM set_config('myapp.log_transfer', 'on', true);
    -- Check target warehouse has enough capacity
    IF NOT EXISTS (
        SELECT 1
        FROM warehouse
        WHERE warehouse_ID = p_target_warehouse
          AND capacity > (
              SELECT COUNT(*) FROM (
                  SELECT equipment_ID FROM equipment WHERE warehouse_ID = p_target_warehouse
                  UNION ALL
                  SELECT ammunition_ID FROM ammunition WHERE warehouse_ID = p_target_warehouse
                  UNION ALL
                  SELECT vehicle_ID FROM armored_vehicle WHERE warehouse_ID = p_target_warehouse
              ) AS all_items
          )
    ) THEN
        RAISE EXCEPTION 'Target warehouse % has no available capacity', p_target_warehouse;
    END IF;

    -- Transfer equipment
    IF p_entity_type = 'equipment' THEN
        IF NOT EXISTS (
            SELECT 1 FROM equipment
            WHERE equipment_ID = p_entity_id AND warehouse_ID = p_source_warehouse
        ) THEN
            RAISE EXCEPTION 'Equipment ID % not found in source warehouse %', p_entity_id, p_source_warehouse;
        END IF;

        UPDATE equipment
        SET warehouse_ID = p_target_warehouse
        WHERE equipment_ID = p_entity_id;

    -- Transfer ammunition (simple move)
    ELSIF p_entity_type = 'ammunition' THEN
        IF NOT EXISTS (
            SELECT 1 FROM ammunition
            WHERE ammunition_ID = p_entity_id AND warehouse_ID = p_source_warehouse
        ) THEN
            RAISE EXCEPTION 'Ammunition ID % not found in source warehouse %', p_entity_id, p_source_warehouse;
        END IF;

        IF EXISTS (
            SELECT 1 FROM ammunition
            WHERE ammunition_ID = p_entity_id AND warehouse_ID = p_target_warehouse
        ) THEN
            RAISE EXCEPTION 'Ammunition ID % already exists in target warehouse %', p_entity_id, p_target_warehouse;
        END IF;

        UPDATE ammunition
        SET warehouse_ID = p_target_warehouse
        WHERE ammunition_ID = p_entity_id AND warehouse_ID = p_source_warehouse;

    -- Transfer armored vehicle
    ELSIF p_entity_type = 'armored_vehicle' THEN
        IF NOT EXISTS (
            SELECT 1 FROM armored_vehicle
            WHERE vehicle_ID = p_entity_id AND warehouse_ID = p_source_warehouse
        ) THEN
            RAISE EXCEPTION 'Armored vehicle ID % not found in source warehouse %', p_entity_id, p_source_warehouse;
        END IF;

        UPDATE armored_vehicle
        SET warehouse_ID = p_target_warehouse
        WHERE vehicle_ID = p_entity_id;

    -- Transfer vehicle part (moves the specific vehicle)
    ELSIF p_entity_type = 'vehicle_part' THEN
        IF p_entity_vehicle_id IS NULL THEN
            RAISE EXCEPTION 'vehicle_id parameter is required for vehicle_part transfer';
        END IF;

        IF NOT EXISTS (
            SELECT 1 FROM vehicle_part vp
            JOIN armored_vehicle av ON vp.vehicle_ID = av.vehicle_ID
            WHERE vp.part_ID = p_entity_id
              AND vp.vehicle_ID = p_entity_vehicle_id
              AND av.warehouse_ID = p_source_warehouse
        ) THEN
            RAISE EXCEPTION 'Vehicle part ID % with vehicle ID % not found in source warehouse %',
                p_entity_id, p_entity_vehicle_id, p_source_warehouse;
        END IF;

        UPDATE armored_vehicle
        SET warehouse_ID = p_target_warehouse
        WHERE vehicle_ID = p_entity_vehicle_id;

        RAISE NOTICE 'Vehicle with part ID % with vehicle ID % transferred successfully',
            p_entity_id, p_entity_vehicle_id;

    ELSE
        RAISE EXCEPTION 'Unsupported entity type: %', p_entity_type;
    END IF;
	PERFORM set_config('myapp.log_transfer', '', true);
END;
$$;
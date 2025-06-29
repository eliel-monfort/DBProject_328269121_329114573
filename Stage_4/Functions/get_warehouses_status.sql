CREATE OR REPLACE FUNCTION get_warehouses_status(INOUT cur refcursor)
RETURNS refcursor AS
$$
BEGIN
    -- Open a cursor for warehouse status with useful dashboard fields
    OPEN cur FOR
    SELECT
        -- Alert if warehouse is full or almost full
        CASE
            WHEN w.capacity - (COALESCE(eq.equip_count, 0) + COALESCE(am.ammo_count, 0) + COALESCE(av.vehicle_count, 0)) <= 0
                THEN 'NO SPACE LEFT'
            WHEN w.capacity - (COALESCE(eq.equip_count, 0) + COALESCE(am.ammo_count, 0) + COALESCE(av.vehicle_count, 0)) < 5
                THEN 'ALERT: Almost full'
            ELSE NULL
        END AS warehouse_alert,

        -- Basic warehouse info
        w.warehouse_ID,
        l.location_name,
        p.first_name || ' ' || p.last_name AS warehouse_manager,
        w.capacity,

        -- Usage stats
        COALESCE(eq.equip_count, 0) + COALESCE(am.ammo_count, 0) + COALESCE(av.vehicle_count, 0) AS used_space,
        w.capacity - (COALESCE(eq.equip_count, 0) + COALESCE(am.ammo_count, 0) + COALESCE(av.vehicle_count, 0)) AS remaining_space,
        COALESCE(av.vehicle_count, 0) AS total_vehicles,
        COALESCE(eq.equip_count, 0) AS total_equipment,
        COALESCE(am.ammo_count, 0) AS total_ammunition

    FROM warehouse w
    LEFT JOIN locations l ON w.location_ID = l.location_ID
    LEFT JOIN personnel p ON w.personnel_ID = p.personnel_ID

    -- Equipment count per warehouse
    LEFT JOIN (
        SELECT warehouse_ID, COUNT(*) AS equip_count
        FROM equipment
        GROUP BY warehouse_ID
    ) eq ON w.warehouse_ID = eq.warehouse_ID

    -- Ammunition quantity per warehouse
    LEFT JOIN (
        SELECT warehouse_ID, SUM(quantity) AS ammo_count
        FROM ammunition
        GROUP BY warehouse_ID
    ) am ON w.warehouse_ID = am.warehouse_ID

    -- Vehicle count per warehouse
    LEFT JOIN (
        SELECT warehouse_ID, COUNT(*) AS vehicle_count
        FROM armored_vehicle
        GROUP BY warehouse_ID
    ) av ON w.warehouse_ID = av.warehouse_ID

    ORDER BY w.warehouse_ID;

    RETURN;
END;
$$ LANGUAGE plpgsql;
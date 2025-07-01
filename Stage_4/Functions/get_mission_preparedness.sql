CREATE OR REPLACE FUNCTION get_mission_preparedness(
    INOUT cur refcursor,
    min_ready_vehicles INT DEFAULT 2
)
AS $$
BEGIN
    -- Drop temp table if exists
    DROP TABLE IF EXISTS tmp_mission_report;

    CREATE TEMP TABLE tmp_mission_report AS
    WITH mission_units AS (
        SELECT 
            m.mission_ID,
            m.mission_name,
            u.unit_ID,
            u.unit_name
        FROM mission m
        JOIN unit_mission_assignment uma ON m.mission_ID = uma.mission_ID
        JOIN unit u ON uma.unit_ID = u.unit_ID
        WHERE m.mission_ID IS NOT NULL
    ),
    vehicle_counts AS (
        SELECT
            vma.mission_ID,
            COUNT(*) AS total_vehicles,
            SUM(CASE WHEN av.next_maintenance_date > CURRENT_DATE THEN 1 ELSE 0 END) AS ready_vehicles
        FROM vehicle_mission_assignment vma
        JOIN armored_vehicle av ON vma.vehicle_ID = av.vehicle_ID
        GROUP BY vma.mission_ID
    ),
    soldier_counts AS (
        SELECT
            unit_ID,
            COUNT(*) AS total_soldiers
        FROM soldier
        GROUP BY unit_ID
    )
    SELECT
        mu.mission_ID,
        mu.mission_name,
        mu.unit_ID,
        mu.unit_name,
        COALESCE(vc.total_vehicles, 0) AS total_vehicles,
        COALESCE(vc.ready_vehicles, 0) AS ready_vehicles,
        COALESCE(sc.total_soldiers, 0) AS total_soldiers,
        -- Mission status and comment
        CASE
            WHEN COALESCE(vc.total_vehicles, 0) = 0 THEN 'Not Ready'
            WHEN COALESCE(vc.ready_vehicles, 0) >= min_ready_vehicles THEN 'Ready'
            ELSE 'Not Ready'
        END AS mission_status,
        CASE
            WHEN COALESCE(vc.total_vehicles, 0) = 0 THEN 'No vehicles assigned'
            WHEN COALESCE(vc.ready_vehicles, 0) >= min_ready_vehicles THEN 'Sufficient ready vehicles'
            ELSE 'Not enough ready vehicles'
        END AS mission_comment
    FROM mission_units mu
    LEFT JOIN vehicle_counts vc ON mu.mission_ID = vc.mission_ID
    LEFT JOIN soldier_counts sc ON mu.unit_ID = sc.unit_ID;

    OPEN cur FOR SELECT * FROM tmp_mission_report;
END;
$$ LANGUAGE plpgsql;

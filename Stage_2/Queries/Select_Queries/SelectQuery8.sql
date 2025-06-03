SELECT
  V.vehicle_ID,
  V.model,
  W1.location AS current_warehouse_location,
  V.last_maintenance_date,
  CURRENT_DATE - V.last_maintenance_date AS days_since_maintenance,
  (
    SELECT W2.location
    FROM Warehouse W2
    WHERE W2.warehouse_ID <> V.warehouse_ID
      AND NOT EXISTS (
        SELECT 1
        FROM Armored_Vehicle V2
        WHERE V2.warehouse_ID = W2.warehouse_ID
          AND V2.vehicle_ID IN (
            SELECT vehicle_ID
            FROM Vehicle_Mission_Assignment
          )
      )
    ORDER BY W2.warehouse_ID ASC
    LIMIT 1
  ) AS suggested_target_warehouse_location
FROM Armored_Vehicle V, Warehouse W1
WHERE V.warehouse_ID = W1.warehouse_ID
  AND V.vehicle_ID NOT IN (
    SELECT vehicle_ID
    FROM Vehicle_Mission_Assignment
  )
  AND CURRENT_DATE - V.last_maintenance_date <= 90
ORDER BY days_since_maintenance ASC;
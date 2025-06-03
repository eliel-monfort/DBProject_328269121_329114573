SELECT
  V.vehicle_ID AS vehicle_number,
  V.model AS model,
  W.location AS warehouse_location,
  V.last_maintenance_date AS last_maintenance,
  W.last_inspection_date AS last_inspection,
  CURRENT_DATE - V.last_maintenance_date AS days_since_maintenance
FROM Armored_Vehicle V, Warehouse W
WHERE V.warehouse_ID = W.warehouse_ID
  AND V.vehicle_ID NOT IN (
    SELECT vehicle_ID
    FROM Vehicle_Mission_Assignment
  )
  AND EXTRACT(YEAR FROM V.last_maintenance_date) = EXTRACT(YEAR FROM W.last_inspection_date)
  AND EXTRACT(MONTH FROM V.last_maintenance_date) = EXTRACT(MONTH FROM W.last_inspection_date)
GROUP BY
  V.vehicle_ID,
  V.model,
  W.location,
  V.last_maintenance_date,
  W.last_inspection_date
ORDER BY days_since_maintenance DESC;
SELECT
  V.vehicle_ID,
  V.model,
  V.next_maintenance_date,
  M.mission_ID,
  M.mission_name,
  MAX(UMA.assigned_date) AS last_mission_date,
  MAX(UMA.assigned_date) - V.next_maintenance_date AS days_late
FROM Armored_Vehicle V, Vehicle_Mission_Assignment VMA, Mission M, Unit_Mission_Assignment UMA
WHERE V.vehicle_ID = VMA.vehicle_ID
  AND VMA.mission_ID = M.mission_ID
  AND M.mission_ID = UMA.mission_ID
  AND UMA.assigned_date > (
    SELECT next_due
    FROM Maintenance
    WHERE maintenance_ID = (
      SELECT MAX(maintenance_ID)
      FROM Undergoes
      WHERE vehicle_ID = V.vehicle_ID
    )
  )
GROUP BY
  V.vehicle_ID,
  V.model,
  V.next_maintenance_date,
  M.mission_ID,
  M.mission_name
ORDER BY days_late DESC;
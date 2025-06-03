SELECT
  VP.vehicle_ID,
  VP.part_ID,
  VP.part_name,
  COUNT(*) AS number_of_failures,
  SUM(PW.cost_of_repair) AS total_repair_cost,
  MIN(PW.replaced_on) AS first_failure_date,
  MAX(PW.replaced_on) AS last_failure_date
FROM Vehicle_Part VP, Problem_With PW
WHERE VP.vehicle_ID = PW.vehicle_ID
  AND VP.part_ID = PW.part_ID
  AND PW.maintenance_ID IN (
    SELECT M1.maintenance_ID
    FROM Maintenance M1
    WHERE M1.description = (
      SELECT M2.description
      FROM Maintenance M2
      WHERE M2.maintenance_ID = PW.maintenance_ID
    )
  )
GROUP BY VP.vehicle_ID, VP.part_ID, VP.part_name
HAVING COUNT(*) >= 2
ORDER BY total_repair_cost DESC;
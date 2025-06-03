DELETE FROM Problem_With
WHERE replaced_on < CURRENT_DATE - INTERVAL '2 years'
  AND NOT EXISTS (
    SELECT 1
    FROM Undergoes U
    JOIN Maintenance M ON U.maintenance_ID = M.maintenance_ID
    WHERE U.vehicle_ID = Problem_With.vehicle_ID
      AND M.performed_on > Problem_With.replaced_on
  );
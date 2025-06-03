SELECT
  M.mission_ID,
  M.mission_name,
  S.personnel_ID AS soldier_ID,
  P.first_name || ' ' || P.last_name AS soldier_name,
  E.equipment_ID,
  E.name AS equipment_name,
  SEU.use_start,
  E.warranty_expiration
FROM Mission M, Soldier_Mission_Assignment SMA, Soldier S, Personnel P, Soldier_Equipment_Use SEU, Equipment E
WHERE M.mission_ID = SMA.mission_ID
  AND SMA.personnel_ID = S.personnel_ID
  AND S.personnel_ID = P.personnel_ID
  AND S.personnel_ID = SEU.personnel_ID
  AND SEU.equipment_ID = E.equipment_ID
  AND SEU.use_start > (
    SELECT warranty_expiration
    FROM Equipment E2
    WHERE E2.equipment_ID = E.equipment_ID
      AND E2.equipment_ID IN (
        SELECT equipment_ID
        FROM Soldier_Equipment_Use
        WHERE personnel_ID = S.personnel_ID
      )
  )
ORDER BY M.mission_ID, SEU.use_start DESC;
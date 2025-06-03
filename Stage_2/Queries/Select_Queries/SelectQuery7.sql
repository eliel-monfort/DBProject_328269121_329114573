SELECT
  S.personnel_ID AS soldier_ID,
  P.first_name || ' ' || P.last_name AS soldier_name,
  M.mission_ID,
  M.mission_name,
  SMA.join_date,
  SMA.leave_date,
  U.unit_name
FROM Soldier S, Personnel P, Soldier_Mission_Assignment SMA, Mission M, Unit U
WHERE S.personnel_ID = P.personnel_ID
  AND S.personnel_ID = SMA.personnel_ID
  AND SMA.mission_ID = M.mission_ID
  AND S.unit_ID = U.unit_ID
  AND NOT EXISTS (
    SELECT 1
    FROM Soldier_Equipment_Use SEU
    WHERE SEU.personnel_ID = S.personnel_ID
      AND EXISTS (
        SELECT 1
        FROM Equipment E
        WHERE E.equipment_ID = SEU.equipment_ID
          AND SEU.use_start <= SMA.leave_date
          AND SEU.use_end >= SMA.join_date
      )
  )
ORDER BY M.mission_ID, SMA.join_date;
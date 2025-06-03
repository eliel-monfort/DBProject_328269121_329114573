SELECT
  S.personnel_ID,
  P.first_name || ' ' || P.last_name AS soldier_name,
  S.rank,
  S.unit_ID,
  (
    SELECT U.unit_name
    FROM Unit U
    WHERE U.unit_ID = S.unit_ID
      AND U.personnel_ID = (
        SELECT C.personnel_ID
        FROM Commander C
        WHERE C.personnel_ID = U.personnel_ID
      )
  ) AS unit_name,
  S.enlistment_date,
  CURRENT_DATE - S.enlistment_date AS days_of_service
FROM Soldier S, Personnel P
WHERE S.personnel_ID = P.personnel_ID
  AND CURRENT_DATE - S.enlistment_date > 973
ORDER BY days_of_service DESC;
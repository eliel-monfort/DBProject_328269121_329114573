SELECT
  S.personnel_ID AS soldier_ID,
  P.first_name || ' ' || P.last_name AS soldier_name,
  E.equipment_ID AS equipment_ID,
  E.name AS equipment_name,
  SEU.use_start AS use_start,
  E.warranty_expiration AS warranty_expiration,
  SEU.use_start - E.warranty_expiration AS days_after_expiration
FROM Soldier S, Personnel P, Soldier_Equipment_Use SEU, Equipment E
WHERE S.personnel_ID = P.personnel_ID
  AND S.personnel_ID = SEU.personnel_ID
  AND SEU.equipment_ID = E.equipment_ID
  AND SEU.use_start > E.warranty_expiration
GROUP BY
  S.personnel_ID,
  P.first_name,
  P.last_name,
  E.equipment_ID,
  E.name,
  SEU.use_start,
  E.warranty_expiration
ORDER BY days_after_expiration DESC;
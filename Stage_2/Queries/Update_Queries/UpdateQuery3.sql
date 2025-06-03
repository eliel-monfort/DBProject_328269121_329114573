UPDATE Equipment
SET warranty_expiration = CURRENT_DATE + INTERVAL '1 year'
WHERE equipment_ID IN (
    SELECT DISTINCT E.equipment_ID
    FROM Equipment E
    JOIN Equipment_Type ET ON E.type_ID = ET.type_ID
    JOIN Soldier_Equipment_Use SEU ON E.equipment_ID = SEU.equipment_ID
    JOIN Soldier_Mission_Assignment SMA ON SEU.personnel_ID = SMA.personnel_ID
    WHERE SEU.use_end IS NULL
      AND E.warranty_expiration < CURRENT_DATE
);
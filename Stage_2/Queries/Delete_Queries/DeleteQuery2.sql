DELETE FROM Soldier_Equipment_Use
WHERE equipment_ID IN (
    SELECT seu.equipment_ID
    FROM Soldier_Equipment_Use seu, Soldier s, Equipment e
    WHERE seu.personnel_ID = s.personnel_ID
      AND seu.equipment_ID = e.equipment_ID
      AND EXTRACT(YEAR FROM seu.use_end) <= 2022
      AND NOT EXISTS (
          SELECT 1
          FROM Soldier_Equipment_Use seu2
          WHERE seu2.equipment_ID = seu.equipment_ID
            AND seu2.use_start > seu.use_end
      )
);
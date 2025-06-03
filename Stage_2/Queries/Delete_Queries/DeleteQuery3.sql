DELETE FROM Commander
WHERE personnel_ID IN (
    SELECT c.personnel_ID
    FROM Commander c, Personnel p
    WHERE
        c.personnel_ID = p.personnel_ID
        AND c.years_of_experience < 3
        AND EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.date_of_birth)) > 55
        AND NOT EXISTS (
            SELECT 1
            FROM Unit u, Unit_Mission_Assignment uma
            WHERE u.personnel_ID = c.personnel_ID
              AND u.unit_ID = uma.unit_ID
              AND uma.assigned_date >= CURRENT_DATE - INTERVAL '3 years'
        )
);
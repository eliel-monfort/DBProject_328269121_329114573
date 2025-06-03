UPDATE Soldier
SET rank = CASE
    WHEN rank = 'Private' AND (
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, enlistment_date)) > 2 OR
        (EXTRACT(YEAR FROM AGE(CURRENT_DATE, enlistment_date)) = 2 AND
         EXTRACT(MONTH FROM AGE(CURRENT_DATE, enlistment_date)) >= 8)
    ) THEN 'Sergeant'

    WHEN rank = 'Sergeant' AND (
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, enlistment_date)) > 6
    ) THEN 'Lieutenant'

    WHEN rank = 'Lieutenant' AND (
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, enlistment_date)) > 8
    ) THEN 'Major'

    WHEN rank = 'Major' AND (
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, enlistment_date)) > 10
    ) THEN 'Captain'

    ELSE rank
END;
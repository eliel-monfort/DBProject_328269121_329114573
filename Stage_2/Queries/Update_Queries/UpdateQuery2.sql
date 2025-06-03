UPDATE Equipment
SET warehouse_ID = (
    SELECT W.warehouse_ID
    FROM Warehouse W
    LEFT JOIN Equipment E ON W.warehouse_ID = E.warehouse_ID
    GROUP BY W.warehouse_ID, W.capacity
    HAVING COUNT(E.equipment_ID) < W.capacity
    ORDER BY (W.capacity - COUNT(E.equipment_ID)) DESC
    LIMIT 1
)
WHERE equipment_ID IN (
    SELECT E1.equipment_ID
    FROM Equipment E1
    JOIN (
        SELECT W1.warehouse_ID, COUNT(EQ.equipment_ID) AS current_amount, W1.capacity
        FROM Warehouse W1
        JOIN Equipment EQ ON W1.warehouse_ID = EQ.warehouse_ID
        GROUP BY W1.warehouse_ID, W1.capacity
        HAVING COUNT(EQ.equipment_ID) > W1.capacity
    ) AS OW ON E1.warehouse_ID = OW.warehouse_ID
    WHERE (
        SELECT COUNT(*)
        FROM Equipment E2
        WHERE E2.warehouse_ID = OW.warehouse_ID AND E2.equipment_ID <= E1.equipment_ID
    ) <= (OW.current_amount - OW.capacity)
);
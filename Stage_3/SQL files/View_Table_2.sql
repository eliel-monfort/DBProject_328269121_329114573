-- View Table 2
CREATE VIEW Ammunition_Storage_Info AS
SELECT
  a.ammunition_ID,
  a.type AS ammo_type,
  a.quantity,
  a.date_added,
  w.warehouse_ID,
  w.capacity
FROM
  Ammunition a,
  Warehouse w
WHERE
  a.warehouse_ID = w.warehouse_ID;


-- Query 1
SELECT
  warehouse_ID,
  SUM(quantity) AS total_ammo
FROM
  Ammunition_Storage_Info
GROUP BY
  warehouse_ID
HAVING
  SUM(quantity) > 1000;


-- Query 2
SELECT
  ammo_type,
  quantity
FROM
  Ammunition_Storage_Info
WHERE
  warehouse_ID = (
    SELECT warehouse_ID
    FROM Warehouse
    ORDER BY capacity DESC
    LIMIT 1
  );
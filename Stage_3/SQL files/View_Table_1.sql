-- View Table 1
CREATE VIEW Logistics_Equipment_Info AS
SELECT
  w.warehouse_ID,
  e.equipment_ID,
  e.name AS equipment_name,
  et.type_name,
  et.category
FROM
  Warehouse w,
  Equipment e,
  Equipment_Type et
WHERE
  e.warehouse_ID = w.warehouse_ID
  AND e.type_ID = et.type_ID;


-- Query 1
SELECT
  warehouse_ID,
  category,
  COUNT(DISTINCT equipment_ID) AS total_equipment
FROM Logistics_Equipment_Info
GROUP BY warehouse_ID, category
ORDER BY warehouse_ID, total_equipment DESC;


-- Query 2
SELECT DISTINCT
  warehouse_ID,
  equipment_name
FROM Logistics_Equipment_Info
WHERE category = 'Communication';
-- View Table 3
SELECT
  inspection_ID AS action_id,
  'Inspection' AS action_type,
  inspection_date AS action_date,
  status AS action_details
FROM Inspections

UNION ALL

-- Orders
SELECT
  orders_ID AS action_id,
  'Order' AS action_type,
  order_time::DATE AS action_date,
  CONCAT('Moved from ', from_location, ' to ', to_movement) AS action_details
FROM Orders

UNION ALL

-- Maintenance
SELECT
  maintenance_ID AS action_id,
  'Maintenance' AS action_type,
  performed_on AS action_date,
  description AS action_details
FROM Maintenance;


-- Query 1
SELECT *
FROM System_Activity_Log
WHERE action_date > '2025-06-01';


-- Query 2
SELECT action_type, COUNT(*) AS total
FROM System_Activity_Log
GROUP BY action_type;
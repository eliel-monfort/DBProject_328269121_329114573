## 📚 Table of Contents

1. [📘 Stage B Overview](#-stage-b-overview)
2. [📊 Complex SELECT Queries](#-complex-select-queries)
3. [🧹 DELETE Queries](#-delete-queries)
4. [🔁 UPDATE Queries](#-update-queries)
5. [🧾 Constraints (ALTER TABLE)](#-constraints-alter-table)
6. [🔄 Rollback & Commit](#-rollback--commit)
7. [💾 Updated Backup](#-updated-backup)

---

## 📘 Stage B Overview

In Stage B of the project, we focused on advanced database operations including complex queries, data manipulation (updates and deletions), transactional controls (rollback/commit), and enforcement of new constraints.

The goal is to simulate real-world use cases and verify the robustness, integrity, and usability of the system under realistic conditions.

---

## 📊 SELECT Queries

Each SELECT query includes:
- A short explanation of what the query does
- The full SQL code
- Screenshot of running the query with few results

---

### 🔎 Select Query 1 – Idle Vehicles in Inspected Warehouses

**Purpose:**  
To find vehicles that are ready for immediate use — not assigned to any mission and stored in warehouses recently inspected.

**What it returns:**  
Vehicle ID, model, warehouse location, last maintenance date, last inspection date, and days since maintenance.

**How it works:**  
The query joins vehicles with their warehouses, filters out those used in missions, and matches inspection and maintenance dates by year and month.

**SQL:**
```sql
SELECT
  V.vehicle_ID AS vehicle_number,
  V.model AS model,
  W.location AS warehouse_location,
  V.last_maintenance_date AS last_maintenance,
  W.last_inspection_date AS last_inspection,
  CURRENT_DATE - V.last_maintenance_date AS days_since_maintenance
FROM Armored_Vehicle V, Warehouse W
WHERE V.warehouse_ID = W.warehouse_ID
  AND V.vehicle_ID NOT IN (
    SELECT vehicle_ID
    FROM Vehicle_Mission_Assignment
  )
  AND EXTRACT(YEAR FROM V.last_maintenance_date) = EXTRACT(YEAR FROM W.last_inspection_date)
  AND EXTRACT(MONTH FROM V.last_maintenance_date) = EXTRACT(MONTH FROM W.last_inspection_date)
GROUP BY
  V.vehicle_ID,
  V.model,
  W.location,
  V.last_maintenance_date,
  W.last_inspection_date
ORDER BY days_since_maintenance DESC;
```

📸 **Running Query Screenshot:**

![SelectQuery1](Stage_2/Queries/Select_Queries/Images/SelectQuery1.png)

---

### 🔎 Select Query 2 – Soldiers Using Expired Equipment

**Purpose:**  
To detect cases where soldiers used equipment after its warranty had expired, which could indicate safety or maintenance issues.

**What it returns:**  
Details of each soldier and the equipment used, the usage start date, warranty expiration date, and how many days usage exceeded the warranty.

**How it works:**  
The query joins soldier, equipment, and usage tables, and filters records where the use_start date is after the warranty_expiration.

**SQL:**
```sql
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
```

📸 **Running Query Screenshot:**

![SelectQuery2](Stage_2/Queries/Select_Queries/Images/SelectQuery2.png)

---

### 🔎 Select Query 3 – Missions with Expired Equipment Usage

**Purpose:**  
To identify missions where soldiers used equipment that was no longer under warranty, raising potential safety and operational concerns.

**What it returns:**  
Details about the mission, the involved soldier, the equipment used, usage start date, and warranty expiration.

**How it works:**  
The query joins missions, soldier assignments, equipment usage, and personnel data. It includes a subquery that ensures the equipment's warranty was expired before the usage began.

**SQL:**
```sql
SELECT
  M.mission_ID,
  M.mission_name,
  S.personnel_ID AS soldier_ID,
  P.first_name || ' ' || P.last_name AS soldier_name,
  E.equipment_ID,
  E.name AS equipment_name,
  SEU.use_start,
  E.warranty_expiration
FROM Mission M, Soldier_Mission_Assignment SMA, Soldier S, Personnel P, Soldier_Equipment_Use SEU, Equipment E
WHERE M.mission_ID = SMA.mission_ID
  AND SMA.personnel_ID = S.personnel_ID
  AND S.personnel_ID = P.personnel_ID
  AND S.personnel_ID = SEU.personnel_ID
  AND SEU.equipment_ID = E.equipment_ID
  AND SEU.use_start > (
    SELECT warranty_expiration
    FROM Equipment E2
    WHERE E2.equipment_ID = E.equipment_ID
      AND E2.equipment_ID IN (
        SELECT equipment_ID
        FROM Soldier_Equipment_Use
        WHERE personnel_ID = S.personnel_ID
      )
  )
ORDER BY M.mission_ID, SEU.use_start DESC;
```

📸 **Running Query Screenshot:**

![SelectQuery3](Stage_2/Queries/Select_Queries/Images/SelectQuery3.png)

---

### 🔎 Select Query 4 – Overdue Maintenance Vehicles Used in Missions

**Purpose:**  
To detect cases where vehicles were sent on missions even though they had missed their scheduled maintenance.

**What it returns:**  
Details about the vehicle, the mission it was used in, the planned maintenance date, last mission date, and how many days the maintenance was overdue.

**How it works:**  
The query joins vehicles, missions, and unit assignments, and checks if the latest mission date is after the latest scheduled maintenance using nested subqueries.

**SQL:**
```sql
SELECT
  V.vehicle_ID,
  V.model,
  V.next_maintenance_date,
  M.mission_ID,
  M.mission_name,
  MAX(UMA.assigned_date) AS last_mission_date,
  MAX(UMA.assigned_date) - V.next_maintenance_date AS days_late
FROM Armored_Vehicle V, Vehicle_Mission_Assignment VMA, Mission M, Unit_Mission_Assignment UMA
WHERE V.vehicle_ID = VMA.vehicle_ID
  AND VMA.mission_ID = M.mission_ID
  AND M.mission_ID = UMA.mission_ID
  AND UMA.assigned_date > (
    SELECT next_due
    FROM Maintenance
    WHERE maintenance_ID = (
      SELECT MAX(maintenance_ID)
      FROM Undergoes
      WHERE vehicle_ID = V.vehicle_ID
    )
  )
GROUP BY
  V.vehicle_ID,
  V.model,
  V.next_maintenance_date,
  M.mission_ID,
  M.mission_name
ORDER BY days_late DESC;
```

📸 **Running Query Screenshot:**

![SelectQuery4](Stage_2/Queries/Select_Queries/Images/SelectQuery4.png)

---

### 🔎 Select Query 5 – Frequently Faulty Parts with Repair Cost

**Purpose:**  
To monitor vehicle parts that repeatedly failed and caused high repair costs.

**What it returns:**  
For each faulty part, it shows the number of failures, total repair cost, and the date range between the first and last repair.

**How it works:**  
The query joins parts with their reported issues and groups them by vehicle and part. It uses a subquery to match maintenance descriptions and filters parts with at least 2 failures.

**SQL:**
```sql
SELECT
  VP.vehicle_ID,
  VP.part_ID,
  VP.part_name,
  COUNT(*) AS number_of_failures,
  SUM(PW.cost_of_repair) AS total_repair_cost,
  MIN(PW.replaced_on) AS first_failure_date,
  MAX(PW.replaced_on) AS last_failure_date
FROM Vehicle_Part VP, Problem_With PW
WHERE VP.vehicle_ID = PW.vehicle_ID
  AND VP.part_ID = PW.part_ID
  AND PW.maintenance_ID IN (
    SELECT M1.maintenance_ID
    FROM Maintenance M1
    WHERE M1.description = (
      SELECT M2.description
      FROM Maintenance M2
      WHERE M2.maintenance_ID = PW.maintenance_ID
    )
  )
GROUP BY VP.vehicle_ID, VP.part_ID, VP.part_name
HAVING COUNT(*) >= 2
ORDER BY total_repair_cost DESC;
```

📸 **Running Query Screenshot:**

![SelectQuery5](Stage_2/Queries/Select_Queries/Images/SelectQuery5.png)

---

### 🔎 Select Query 6 – Long-Term Soldiers with Unit Info

**Purpose:**  
To identify soldiers who have been serving for a long time — more than 973 days — which may indicate permanent or senior positions.

**What it returns:**  
Each soldier’s full name, rank, enlistment date, total days of service, unit ID, and unit name (with commander info).

**How it works:**  
The query joins soldiers with their personal info and uses a subquery to extract the unit name if it has an assigned commander. It filters by days of service using `CURRENT_DATE - enlistment_date`.

**SQL:**
```sql
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
```

📸 **Running Query Screenshot:**

![SelectQuery6](Stage_2/Queries/Select_Queries/Images/SelectQuery6.png)

---

### 🔎 Select Query 7 – Soldiers Assigned to Missions Without Equipment

**Purpose:**  
To identify soldiers who were assigned to missions but did not use any equipment during the mission period, revealing potential logistical failures.

**What it returns:**  
Soldier ID and name, mission ID and name, mission join and leave dates, and the soldier’s unit name.

**How it works:**  
The query joins mission assignments with personnel and unit data. It uses `NOT EXISTS` with nested `EXISTS` to exclude soldiers whose equipment usage doesn't overlap with the mission period.

**SQL:**
```sql
SELECT
  S.personnel_ID AS soldier_ID,
  P.first_name || ' ' || P.last_name AS soldier_name,
  M.mission_ID,
  M.mission_name,
  SMA.join_date,
  SMA.leave_date,
  U.unit_name
FROM Soldier S, Personnel P, Soldier_Mission_Assignment SMA, Mission M, Unit U
WHERE S.personnel_ID = P.personnel_ID
  AND S.personnel_ID = SMA.personnel_ID
  AND SMA.mission_ID = M.mission_ID
  AND S.unit_ID = U.unit_ID
  AND NOT EXISTS (
    SELECT 1
    FROM Soldier_Equipment_Use SEU
    WHERE SEU.personnel_ID = S.personnel_ID
      AND EXISTS (
        SELECT 1
        FROM Equipment E
        WHERE E.equipment_ID = SEU.equipment_ID
          AND SEU.use_start <= SMA.leave_date
          AND SEU.use_end >= SMA.join_date
      )
  )
ORDER BY M.mission_ID, SMA.join_date;
```

📸 **Running Query Screenshot:**

![SelectQuery7](Stage_2/Queries/Select_Queries/Images/SelectQuery7.png)

---

### 🔎 Select Query 8 – Suggesting Target Warehouses for Available Vehicles

**Purpose:**  
To recommend new warehouse locations for vehicles that are available (not assigned to missions) and have been recently maintained.

**What it returns:**  
Vehicle ID, model, current warehouse location, days since last maintenance, and a suggested warehouse for relocation.

**How it works:**  
The query filters vehicles that haven't been used in missions, checks if their maintenance was done in the last 90 days, and uses a subquery to find the first available warehouse without mission-assigned vehicles.

**SQL:**
```sql
SELECT
  V.vehicle_ID,
  V.model,
  W1.location AS current_warehouse_location,
  V.last_maintenance_date,
  CURRENT_DATE - V.last_maintenance_date AS days_since_maintenance,
  (
    SELECT W2.location
    FROM Warehouse W2
    WHERE W2.warehouse_ID <> V.warehouse_ID
      AND NOT EXISTS (
        SELECT 1
        FROM Armored_Vehicle V2
        WHERE V2.warehouse_ID = W2.warehouse_ID
          AND V2.vehicle_ID IN (
            SELECT vehicle_ID
            FROM Vehicle_Mission_Assignment
          )
      )
    ORDER BY W2.warehouse_ID ASC
    LIMIT 1
  ) AS suggested_target_warehouse_location
FROM Armored_Vehicle V, Warehouse W1
WHERE V.warehouse_ID = W1.warehouse_ID
  AND V.vehicle_ID NOT IN (
    SELECT vehicle_ID
    FROM Vehicle_Mission_Assignment
  )
  AND CURRENT_DATE - V.last_maintenance_date <= 90
ORDER BY days_since_maintenance ASC;
```

📸 **Running Query Screenshot:**

![SelectQuery8](Stage_2/Queries/Select_Queries/Images/SelectQuery8.png)

---

## 🧹 DELETE Queries

Each DELETE section includes:
- Description
- SQL (before/after)
- 📸 Screenshots before and after deletion

**Important note:**  
To run the queries, you must write the command `BEGIN` before the query and `ROLLBACK` after the query so that the changes are not saved.
Here is an example of how it should look:

```sql
BEGIN;

-- The query...

ROLLBACK;
```

---

### ❌ Delete Query 1 – Old Repairs with No Recent Maintenance

**Purpose:**  
To clean up the database by removing old part repair records that are no longer relevant and have not had follow-up maintenance.

**What it deletes:**  
Part failure records (`Problem_With`) where the repair occurred over 2 years ago and no later maintenance has been recorded for the vehicle.

**How it works:**  
Filters part repair entries based on the `replaced_on` date and checks for absence of any newer maintenance using a `NOT EXISTS` clause.

**SQL:**
```sql
DELETE FROM Problem_With
WHERE replaced_on < CURRENT_DATE - INTERVAL '2 years'
  AND NOT EXISTS (
    SELECT 1
    FROM Undergoes U
    JOIN Maintenance M ON U.maintenance_ID = M.maintenance_ID
    WHERE U.vehicle_ID = Problem_With.vehicle_ID
      AND M.performed_on > Problem_With.replaced_on
  );
```

**To view the changes:**  
Run the command `SELECT * FROM Problem_With` before and after the deletion.

📸 **Before Deletion:**

![DeleteQuery1_Before](Stage_2/Queries/Delete_Queries/Images/DeleteQuery1_Before.png)

📸 **After Deletion:**

![DeleteQuery1_After](Stage_2/Queries/Delete_Queries/Images/DeleteQuery1_After.png)

---

### ❌ Delete Query 2 – Unused Equipment Allocations Since 2022

**Purpose:**  
To remove outdated equipment usage entries for soldiers where the equipment hasn't been reused since 2022.

**What it deletes:**  
Records in the `Soldier_Equipment_Use` table where the last use ended in 2022 or earlier, and no further use of the equipment has been recorded.

**How it works:**  
Filters based on `use_end` year and ensures there are no future usages of the same equipment using a nested `NOT EXISTS`.

**SQL:**
```sql
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
```

**To view the changes:**  
Run the command `SELECT * FROM Soldier_Equipment_Use` before and after the deletion.

📸 **Before Deletion:**

![DeleteQuery2_Before](Stage_2/Queries/Delete_Queries/Images/DeleteQuery2_Before.png)

📸 **After Deletion:**

![DeleteQuery2_After](Stage_2/Queries/Delete_Queries/Images/DeleteQuery2_After.png)

---

### ❌ Delete Query 3 – Remove Inactive Commanders (Over Age 55)

**Purpose:**  
To remove inactive commanders who are over 55, have little experience, and haven’t participated in missions in the last 3 years.

**What it deletes:**  
Rows from the `Commander` table that match the age, experience, and inactivity criteria.

**How it works:**  
Uses a multi-join query to cross-check `Commander`, `Personnel`, `Unit`, and `Unit_Mission_Assignment` to ensure the commander is not active.

**SQL:**
```sql
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
```

**To view the changes:**  
Run the command `SELECT * FROM Commander` before and after the deletion.

📸 **Before Deletion:**

![DeleteQuery3_Before](Stage_2/Queries/Delete_Queries/Images/DeleteQuery3_Before.png)

📸 **After Deletion:**

![DeleteQuery3_After](Stage_2/Queries/Delete_Queries/Images/DeleteQuery3_After.png)

---

## 🔁 UPDATE Queries

Each UPDATE section includes:
- Description
- SQL (before/after)
- 📸 Screenshots before and after update

**Important note:**  
To run the queries, you must write the command `BEGIN` before the query and `ROLLBACK` after the query so that the changes are not saved.
Here is an example of how it should look:

```sql
BEGIN;

-- The query...

ROLLBACK;
```

---

### 🔧 Update Query 1 – Auto-Promote Soldiers Based on Years of Service

**Purpose:**  
To automatically promote soldiers based on how long they have served.

**What it updates:**  
The `rank` field in the `Soldier` table is updated according to thresholds:  
- Private → Sergeant (after 2 years 8 months)  
- Sergeant → Lieutenant (after 6 years)  
- Lieutenant → Major (after 8 years)  
- Major → Captain (after 10 years)

**How it works:**  
Uses a `CASE` expression to conditionally update each soldier’s rank based on their enlistment date and current rank.

**SQL:**
```sql
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
```

**To view the changes:**  
Run the command `SELECT * FROM Soldier` before and after the update.

📸 **Before Update:**

![UpdateQuery1_Before](Stage_2/Queries/Update_Queries/Images/UpdateQuery1_Before.png)

📸 **After Update:**

![UpdateQuery1_After](Stage_2/Queries/Update_Queries/Images/UpdateQuery1_After.png)

---

### 🔧 Update Query 2 – Redistribute Equipment from Overloaded Warehouses

**Purpose:**  
To fix warehouse overcapacity issues by moving excess equipment to available warehouses.

**What it updates:**  
The `warehouse_ID` field in the `Equipment` table, relocating items from overloaded warehouses.

**How it works:**  
The query identifies warehouses that exceeded their `capacity`, and reassigns items to under-utilized warehouses using subqueries and grouping.

**SQL:**
```sql
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
```

**To view the changes:**   
Here, to see the update it's a little tricky.
Run the following query **before** running the update query:

```sql
CREATE TEMP TABLE warehouse_snapshot AS
SELECT 
  W.warehouse_ID,
  COUNT(E.equipment_ID) AS pre_count
FROM Warehouse W
LEFT JOIN Equipment E ON W.warehouse_ID = E.warehouse_ID
GROUP BY W.warehouse_ID;

SELECT * FROM warehouse_snapshot;
```

And run this query **after** running the update query:

```sql
SELECT
  W.warehouse_ID,
  W.capacity,
  WS.pre_count AS equipment_before,
  COUNT(E.equipment_ID) AS equipment_after
FROM Warehouse W
JOIN warehouse_snapshot WS ON W.warehouse_ID = WS.warehouse_ID
LEFT JOIN Equipment E ON W.warehouse_ID = E.warehouse_ID
GROUP BY W.warehouse_ID, W.capacity, WS.pre_count
HAVING WS.pre_count <= W.capacity
   AND COUNT(E.equipment_ID) > WS.pre_count
ORDER BY W.warehouse_ID;
```

📸 **Before Update:**

![UpdateQuery2_Before](Stage_2/Queries/Update_Queries/Images/UpdateQuery2_Before.png)

📸 **After Update:**

![UpdateQuery2_After](Stage_2/Queries/Update_Queries/Images/UpdateQuery2_After.png)

---

### 🔧 Update Query 3 – Extend Warranty for Active Mission Equipment

**Purpose:**  
To ensure critical equipment that is still in use during missions is covered by warranty.

**What it updates:**  
The `warranty_expiration` field in the `Equipment` table is extended by 1 year for currently used equipment.

**How it works:**  
The query filters for expired equipment that is actively used by soldiers currently assigned to missions, and extends its warranty.

**SQL:**
```sql
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
```

**To view the changes:**  
Run the command `SELECT * FROM Equipment` before and after the update.

📸 **Before Update:**

![UpdateQuery3_Before](Stage_2/Queries/Update_Queries/Images/UpdateQuery3_Before.png)

📸 **After Update:**

![UpdateQuery3_After](Stage_2/Queries/Update_Queries/Images/UpdateQuery3_After.png)

---

## 🧾 Constraints (ALTER TABLE)

Each constraint includes:
- Type of constraint (CHECK / NOT NULL / DEFAULT)
- The table modified
- Explanation
- The `ALTER TABLE` command
- 📸 Screenshot of insert attempt violating the constraint and resulting error

---

### Constraint 1 – Minimum Warehouse Capacity

**Type:** CHECK  
**Table:** Warehouse  
**Explanation:** This constraint ensures that a warehouse must have a capacity greater than 10. It prevents inserting warehouses with too small or invalid capacity values.

```sql
ALTER TABLE Warehouse
ADD CONSTRAINT chk_capacity_positive
CHECK (capacity > 10);
```

🧪 **Violation Test:**  
To check the constraint, issue the following insert command and then run the constraint command to receive an error message:

```sql
INSERT INTO Warehouse (warehouse_ID, location, capacity, opened_date, last_inspection_date)
VALUES (101, 'DummyBase', 5, '2022-01-01', '2024-01-01');
```

![Constraint1](Stage_2/Constraints/Images/Constraint1.png)

---

### Constraint 2 – Mandatory Enlistment Date for Soldiers

**Type:** NOT NULL  
**Table:** Soldier  
**Explanation:** This constraint ensures that each soldier has an enlistment date. It prevents incomplete or invalid soldier records that are missing this required field.


```sql
ALTER TABLE Soldier
ALTER COLUMN enlistment_date SET NOT NULL;
```

🧪 **Violation Test:**  
To check the constraint, issue the following insert command and then run the constraint command to receive an error message:

```sql
INSERT INTO Personnel (personnel_ID, first_name, last_name, date_of_birth)
VALUES (3000, 'Test', 'User', '2000-01-01');
INSERT INTO Soldier (personnel_ID, rank, unit_ID)
VALUES (3000, 'Private', 1);
```

![Constraint2](Stage_2/Constraints/Images/Constraint2.png)

---

### Constraint 3 – Automatic Warranty Expiration for Equipment

**Type:** DEFAULT  
**Table:** Equipment  
**Explanation:** This default ensures that if no warranty expiration date is specified, the system assumes a standard 2-year warranty period from today.

```sql
ALTER TABLE Equipment
ALTER COLUMN warranty_expiration
SET DEFAULT (CURRENT_DATE + INTERVAL '2 years');
```

🧪 **Violation Screenshot:**  
To check the constraint, issue the following insert command and then run the constraint command to receive an error message:

```sql
INSERT INTO Equipment (equipment_ID, name, purchase_date, warehouse_ID, type_ID)
VALUES (502, 'Thermal Camera', '2024-06-01', 1, 3);
```

![Constraint3_1](Stage_2/Constraints/Images/Constraint3_1.png)

![Constraint3_2](Stage_2/Constraints/Images/Constraint3_2.png)

As we can see, we inserted a equipment without a warranty expiration date, so the constraint automatically sets it to two years from today.

---

## 🔄 Rollback & Commit

Each example shows:
- What was done
- The SQL changes made
- Screenshots before and after the update
- The final command: either `COMMIT` (save) or `ROLLBACK` (cancel)

---

### 📥 Commit – Saving a New Combat Deployment

**Purpose:**  
To show how a full military unit is added to the system and saved permanently using `COMMIT`.

**What was done:**
- A new unit called **Sayeret Matkal** was created with a senior commander.
- 12 soldiers were added and assigned to that unit.
- A mission called **Border Patrol Operation** was created and given to the unit and all soldiers.
- Each soldier received a weapon and equipment.
- 4 armored vehicles were added and assigned to the mission.
- Maintenance records were added for the vehicles.
- The changes were saved using `COMMIT`.

**How to Perform This Step**

1. **Check the Database Before the Update**  
Before making any changes, check that the relevant data does not already exist.  
Run the following SQL queries:

```sql
-- Check the commander and soliders details
SELECT * FROM Personnel WHERE personnel_ID >= 1001;

-- Check the new unit
SELECT * FROM Unit WHERE unit_ID = 269;

-- Check the mission
SELECT * FROM Mission WHERE mission_ID = 600;

-- Check equipment type and weapons
SELECT * FROM Equipment_Type WHERE type_ID = 550;
SELECT * FROM Equipment WHERE equipment_ID BETWEEN 501 AND 512;

-- Check armored vehicles
SELECT * FROM Armored_Vehicle WHERE vehicle_ID BETWEEN 651 AND 654;
```

If this is your first time running the update script, these queries should return no results.  
Of course, these are not all the changes we made - just a few examples. But they clearly show how the COMMIT command works and why it's important.

2. **Run the Update Script**  
Now, run the file [`DataToCommit.sql`](Stage_2/RollbackCommit/DataToCommit.sql).  
This script creates a new unit, adds personnel and mission data, assigns equipment, and more.

3. **Verify the Changes (Before COMMIT)**  
Re-run the same SELECT queries above. You should now see the newly added data in the database.

4. **Save the Changes**  
To make the changes permanent, execute:

```sql
COMMIT;
```

5. **Confirm the Commit Was Successful**  
Run the SELECT queries again to confirm that the data still exists after the commit.  
This means the data was successfully saved and will remain even after reconnecting to the database.

---

### 🔙 Rollback – Canceled Test Unit

**Purpose:**  
To test how `ROLLBACK` cancels changes by adding a temporary unit and undoing everything.

**What was done:**
- A temporary unit called **Recon Temp Unit** was created with 3 test soldiers.
- The unit and soldiers were assigned to a test mission: **Desert Navigation Test**.
- Experimental equipment was added and given to the soldiers.
- A test vehicle was added and got maintenance.
- Then the `ROLLBACK` command was used, and all changes were canceled.

**Important note** - To successfully run the Rollback update, you must first run the Commit update.

**How to Perform This Step**

1. **Check the Database Before the Update**  
Run the following SQL queries to check that the test personnel, unit, and mission data do not already exist:

```sql
-- Check the commander and soldiers details
SELECT * FROM Personnel WHERE personnel_ID BETWEEN 1002 AND 3003;

-- Check the new temporary unit
SELECT * FROM Unit WHERE unit_ID = 102;

-- Check the mock mission
SELECT * FROM Mission WHERE mission_ID = 700;

-- Check test equipment
SELECT * FROM Equipment WHERE equipment_ID BETWEEN 701 AND 703;
SELECT * FROM Soldier_Equipment_Use WHERE equipment_ID BETWEEN 701 AND 703;

-- Check temporary vehicle and maintenance
SELECT * FROM Armored_Vehicle WHERE vehicle_ID = 701;
```

You should see no results if the database is in its original state.  
Of course, these are not all the changes we made - just a few examples. But they clearly show how the ROLLBACK command works and why it's important.

2. **Run the Rollback Script**  
Now run the file [`DataToRollback.sql`](Stage_2/RollbackCommit/DataToRollback.sql).  
This file simulates the creation of a temporary recon unit, soldiers, equipment, vehicles, and a mission.

3. **Verify the Changes (Before ROLLBACK)**  
Run the same SELECT queries again. You should now see all the inserted data.

4. **Cancel the Changes with ROLLBACK**  
Now, to discard all the changes made by the script, execute:

```sql
ROLLBACK;
```

This will undo all inserts made since the `BEGIN` statement.

5. **Confirm that the Changes Were Discarded**  
Run the SELECT queries again. You should see that the inserted data is gone.  
This confirms the ROLLBACK successfully reverted all changes.

---

## 💾 Updated Backup

During this stage, we performed multiple updates and inserts into the database. To preserve the current state and ensure data consistency, we now create a full second backup.

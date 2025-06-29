## 📚 Table of Contents

1. [📘 Introduction](#-introduction)
2. [📊 Function: get_warehouses_status](#-function-get_warehouses_status)
3. [📊 Function: get_mission_preparedness](#-function-get_mission_preparedness)
4. [🔧 Procedure: transfer_warehouse_entity](#-procedure-transfer_warehouse_entity)
5. [🔧 Procedure: manage_mission_operations](#-procedure-manage_mission_operations)
6. [🔒 Trigger: log_warehouse_entity_transfer](#-trigger-log_warehouse_entity_transfer)
7. [🔒 Trigger: trg_prevent_assign_not_ready_vehicle](#-trigger-trg_prevent_assign_not_ready_vehicle)
8. [🔢 Main Program 1: Warehouse Management System](#-main-program-1-warehouse-management-system)
9. [🔢 Main Program 2: Mission Management System](#-main-program-2-mission-management-system)
10. [💾 Updated Backup](#-updated-backup)

---

## 📘 Introduction

In this stage of the project, we implemented several PL/pgSQL programs to extend the functionality of our integrated database system. This includes:

- 2 functions
- 2 procedures
- 2 triggers
- 2 main SQL programs

The goal was to cover advanced PL/pgSQL programming features such as cursors, exceptions, DML operations, and multi-entity logic.

---

## 📊 Function: get_warehouses_status

### **Description**

**Purpose:**  
Provides a dashboard report about all warehouses, showing their usage, remaining space, and alerts if they are full or almost full.

**Main Features:**  
- For each warehouse, the function calculates and displays:
  - Whether the warehouse is full or almost full, with clear alert messages
  - The name of the warehouse manager and the warehouse location
  - The total storage capacity, how much space is used, and how much space is left
  - The total number of vehicles, equipment items, and ammunition units stored
- The function gathers and combines information from several tables:
  (warehouse, locations, personnel, equipment, ammunition, and armored_vehicle)
- The results are returned as a refcursor, allowing you to easily use or display the report in different ways

### SQL Code:

```sql
CREATE OR REPLACE FUNCTION get_warehouses_status(INOUT cur refcursor)
RETURNS refcursor AS
$$
BEGIN
    -- Open a cursor for warehouse status with useful dashboard fields
    OPEN cur FOR
    SELECT
        -- Alert if warehouse is full or almost full
        CASE
            WHEN w.capacity - (COALESCE(eq.equip_count, 0) + COALESCE(am.ammo_count, 0) + COALESCE(av.vehicle_count, 0)) <= 0
                THEN 'NO SPACE LEFT'
            WHEN w.capacity - (COALESCE(eq.equip_count, 0) + COALESCE(am.ammo_count, 0) + COALESCE(av.vehicle_count, 0)) < 5
                THEN 'ALERT: Almost full'
            ELSE NULL
        END AS warehouse_alert,

        -- Basic warehouse info
        w.warehouse_ID,
        l.location_name,
        p.first_name || ' ' || p.last_name AS warehouse_manager,
        w.capacity,

        -- Usage stats
        COALESCE(eq.equip_count, 0) + COALESCE(am.ammo_count, 0) + COALESCE(av.vehicle_count, 0) AS used_space,
        w.capacity - (COALESCE(eq.equip_count, 0) + COALESCE(am.ammo_count, 0) + COALESCE(av.vehicle_count, 0)) AS remaining_space,
        COALESCE(av.vehicle_count, 0) AS total_vehicles,
        COALESCE(eq.equip_count, 0) AS total_equipment,
        COALESCE(am.ammo_count, 0) AS total_ammunition

    FROM warehouse w
    LEFT JOIN locations l ON w.location_ID = l.location_ID
    LEFT JOIN personnel p ON w.personnel_ID = p.personnel_ID

    -- Equipment count per warehouse
    LEFT JOIN (
        SELECT warehouse_ID, COUNT(*) AS equip_count
        FROM equipment
        GROUP BY warehouse_ID
    ) eq ON w.warehouse_ID = eq.warehouse_ID

    -- Ammunition quantity per warehouse
    LEFT JOIN (
        SELECT warehouse_ID, SUM(quantity) AS ammo_count
        FROM ammunition
        GROUP BY warehouse_ID
    ) am ON w.warehouse_ID = am.warehouse_ID

    -- Vehicle count per warehouse
    LEFT JOIN (
        SELECT warehouse_ID, COUNT(*) AS vehicle_count
        FROM armored_vehicle
        GROUP BY warehouse_ID
    ) av ON w.warehouse_ID = av.warehouse_ID

    ORDER BY w.warehouse_ID;

    RETURN;
END;
$$ LANGUAGE plpgsql;
```

### 📸 Execution Proof

Shows a clear report with values such as warehouse capacity, used space, remaining space, and total items:

![Warehouse Status Output](Images/F1.png)

---

## 📊 Function: get_mission_preparedness

### **Description**

**Purpose:**  
Generates a report about how prepared each mission/unit is, based on vehicles and soldiers.

**Main Features:**  
- For each mission and unit the function:
  - Counts assigned vehicles and soldiers
  - Checks how many vehicles are ready (maintenance is valid)
  - Returns mission status ("Ready" or "Not Ready") and a comment
- Allows setting a minimum number of ready vehicles for readiness
- Returns the result as a refcursor

### SQL Code:

```sql
CREATE OR REPLACE FUNCTION get_mission_preparedness(min_ready_vehicles INT DEFAULT 2)
RETURNS refcursor AS $$
DECLARE
    ref refcursor;
BEGIN
    -- Create temp table for the report
    CREATE TEMP TABLE tmp_mission_report AS
    WITH mission_units AS (
        SELECT 
            m.mission_ID,
            m.mission_name,
            u.unit_ID,
            u.unit_name
        FROM mission m
        JOIN unit_mission_assignment uma ON m.mission_ID = uma.mission_ID
        JOIN unit u ON uma.unit_ID = u.unit_ID
        WHERE m.mission_ID IS NOT NULL
    ),
    vehicle_counts AS (
        SELECT
            vma.mission_ID,
            COUNT(*) AS total_vehicles,
            SUM(CASE WHEN av.next_maintenance_date > CURRENT_DATE THEN 1 ELSE 0 END) AS ready_vehicles
        FROM vehicle_mission_assignment vma
        JOIN armored_vehicle av ON vma.vehicle_ID = av.vehicle_ID
        GROUP BY vma.mission_ID
    ),
    soldier_counts AS (
        SELECT
            unit_ID,
            COUNT(*) AS total_soldiers
        FROM soldier
        GROUP BY unit_ID
    )
    SELECT
        mu.mission_ID,
        mu.mission_name,
        mu.unit_ID,
        mu.unit_name,
        COALESCE(vc.total_vehicles, 0) AS total_vehicles,
        COALESCE(vc.ready_vehicles, 0) AS ready_vehicles,
        COALESCE(sc.total_soldiers, 0) AS total_soldiers,
        -- Mission status and comment
        CASE
            WHEN COALESCE(vc.total_vehicles, 0) = 0 THEN 'Not Ready'
            WHEN COALESCE(vc.ready_vehicles, 0) >= min_ready_vehicles THEN 'Ready'
            ELSE 'Not Ready'
        END AS mission_status,
        CASE
            WHEN COALESCE(vc.total_vehicles, 0) = 0 THEN 'No vehicles assigned'
            WHEN COALESCE(vc.ready_vehicles, 0) >= min_ready_vehicles THEN 'Sufficient ready vehicles'
            ELSE 'Not enough ready vehicles'
        END AS mission_comment
    FROM mission_units mu
    LEFT JOIN vehicle_counts vc ON mu.mission_ID = vc.mission_ID
    LEFT JOIN soldier_counts sc ON mu.unit_ID = sc.unit_ID;

    -- Open and return the report cursor
    OPEN ref FOR SELECT * FROM tmp_mission_report;
    RETURN ref;
END;
$$ LANGUAGE plpgsql;
```

### 📸 Execution Proof

Output shows mission names, units, readiness status and comments:

![Mission Preparedness Output](Images/F2.png)

---

## 🔧 Procedure: transfer_warehouse_entity

### **Description**

**Purpose:**  
Transfers an entity (equipment, ammunition, armored vehicle, or vehicle part) from one warehouse to another, with full validation.

**Main Features:**  
- Supports transferring different types of entities:
  - Equipment
  - Ammunition
  - Armored vehicle
  - Vehicle part (by moving its vehicle)
- Checks that the target warehouse has enough capacity
- Validates that the entity exists in the source warehouse
- Prevents duplicate ammunition in the target warehouse
- For vehicle parts, checks that the part and vehicle match and are in the source warehouse
- Raises clear error messages if something is wrong (no space, not found, etc.)
- Uses robust error handling for data safety

**Actions:**  
- `'equipment'` - Moves a specific equipment item.
- `'ammunition'` - Moves a specific ammunition item, but only if it does not already exist in the target warehouse.
- `'armored_vehicle'` - Moves a specific armored vehicle.
- `'vehicle_part'` - Moves the entire vehicle that contains the specified part.

### SQL Code:

```sql
CREATE OR REPLACE PROCEDURE transfer_warehouse_entity(
    IN p_entity_type TEXT,           -- 'equipment', 'ammunition', 'armored_vehicle', 'vehicle_part'
    IN p_entity_id INT,              -- equipment_id / ammunition_id / vehicle_id / part_id
    IN p_source_warehouse INT,
    IN p_target_warehouse INT,
    IN p_entity_vehicle_id INT DEFAULT NULL -- Only for vehicle_part
)
LANGUAGE plpgsql
AS $$
BEGIN
	PERFORM set_config('myapp.log_transfer', 'on', true);
    -- Check target warehouse has enough capacity
    IF NOT EXISTS (
        SELECT 1
        FROM warehouse
        WHERE warehouse_ID = p_target_warehouse
          AND capacity > (
              SELECT COUNT(*) FROM (
                  SELECT equipment_ID FROM equipment WHERE warehouse_ID = p_target_warehouse
                  UNION ALL
                  SELECT ammunition_ID FROM ammunition WHERE warehouse_ID = p_target_warehouse
                  UNION ALL
                  SELECT vehicle_ID FROM armored_vehicle WHERE warehouse_ID = p_target_warehouse
              ) AS all_items
          )
    ) THEN
        RAISE EXCEPTION 'Target warehouse % has no available capacity', p_target_warehouse;
    END IF;

    -- Transfer equipment
    IF p_entity_type = 'equipment' THEN
        IF NOT EXISTS (
            SELECT 1 FROM equipment
            WHERE equipment_ID = p_entity_id AND warehouse_ID = p_source_warehouse
        ) THEN
            RAISE EXCEPTION 'Equipment ID % not found in source warehouse %', p_entity_id, p_source_warehouse;
        END IF;

        UPDATE equipment
        SET warehouse_ID = p_target_warehouse
        WHERE equipment_ID = p_entity_id;

    -- Transfer ammunition (simple move)
    ELSIF p_entity_type = 'ammunition' THEN
        IF NOT EXISTS (
            SELECT 1 FROM ammunition
            WHERE ammunition_ID = p_entity_id AND warehouse_ID = p_source_warehouse
        ) THEN
            RAISE EXCEPTION 'Ammunition ID % not found in source warehouse %', p_entity_id, p_source_warehouse;
        END IF;

        IF EXISTS (
            SELECT 1 FROM ammunition
            WHERE ammunition_ID = p_entity_id AND warehouse_ID = p_target_warehouse
        ) THEN
            RAISE EXCEPTION 'Ammunition ID % already exists in target warehouse %', p_entity_id, p_target_warehouse;
        END IF;

        UPDATE ammunition
        SET warehouse_ID = p_target_warehouse
        WHERE ammunition_ID = p_entity_id AND warehouse_ID = p_source_warehouse;

    -- Transfer armored vehicle
    ELSIF p_entity_type = 'armored_vehicle' THEN
        IF NOT EXISTS (
            SELECT 1 FROM armored_vehicle
            WHERE vehicle_ID = p_entity_id AND warehouse_ID = p_source_warehouse
        ) THEN
            RAISE EXCEPTION 'Armored vehicle ID % not found in source warehouse %', p_entity_id, p_source_warehouse;
        END IF;

        UPDATE armored_vehicle
        SET warehouse_ID = p_target_warehouse
        WHERE vehicle_ID = p_entity_id;

    -- Transfer vehicle part (moves the specific vehicle)
    ELSIF p_entity_type = 'vehicle_part' THEN
        IF p_entity_vehicle_id IS NULL THEN
            RAISE EXCEPTION 'vehicle_id parameter is required for vehicle_part transfer';
        END IF;

        IF NOT EXISTS (
            SELECT 1 FROM vehicle_part vp
            JOIN armored_vehicle av ON vp.vehicle_ID = av.vehicle_ID
            WHERE vp.part_ID = p_entity_id
              AND vp.vehicle_ID = p_entity_vehicle_id
              AND av.warehouse_ID = p_source_warehouse
        ) THEN
            RAISE EXCEPTION 'Vehicle part ID % with vehicle ID % not found in source warehouse %',
                p_entity_id, p_entity_vehicle_id, p_source_warehouse;
        END IF;

        UPDATE armored_vehicle
        SET warehouse_ID = p_target_warehouse
        WHERE vehicle_ID = p_entity_vehicle_id;

        RAISE NOTICE 'Vehicle with part ID % with vehicle ID % transferred successfully',
            p_entity_id, p_entity_vehicle_id;

    ELSE
        RAISE EXCEPTION 'Unsupported entity type: %', p_entity_type;
    END IF;
	PERFORM set_config('myapp.log_transfer', '', true);
END;
$$;
```

### 📸 Execution Proof

**Before**:

![Before Transfer](Images/P1-Before.png)

**During (with NOTICE message)**:

![During Transfer](Images/P1-During.png)

**After (Updated locations)**:

![After Transfer 1](Images/P1-After1.png)

![After Transfer 2](Images/P1-After2.png)

---

## 🔧 Procedure: manage_mission_operations

### **Description**

**Purpose:**  
Handles different mission-related operations for vehicles and soldiers.

**Main Features:**  
- Multi-action procedure, controlled by the `p_action` parameter.
- Uses explicit and implicit cursors for advanced logic
- Handles unique constraint and other errors
- Gives user-friendly feedback with NOTICE and WARNING messages
- Uses a temporary table for summary reports

**Actions:**  
- `'assign_vehicle'` - Assigns a vehicle to a mission (if not already assigned).
- `'remove_vehicle'` - Removes a vehicle from a mission.
- `'replace_vehicle'` - Finds a not-ready vehicle in a mission and replaces it with an available, ready vehicle.
- `'move_soldier'` - Moves a soldier to a different unit (requires soldier ID and new unit ID).
- `'summary'` - Generates a summary report for a mission and unit, showing mission name, unit name, number of vehicles, ready vehicles, and soldiers.

### SQL Code:

```sql
CREATE OR REPLACE PROCEDURE manage_mission_operations(
    p_mission_id INT,
    p_action TEXT,
    p_vehicle_id INT DEFAULT NULL,
    p_unit_id INT DEFAULT NULL,
    p_soldier_id INT DEFAULT NULL,
    p_new_unit_id INT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    vehicle_in_use INT;
    available_vehicle_id INT;
    not_ready_vehicle_id INT;
    soldier_exists INT;
    summary_rec RECORD;
    vehicle_count INT;
    inserted_vehicle_id INT;
    cur CURSOR FOR
        SELECT vma.vehicle_ID, av.model, av.next_maintenance_date
        FROM vehicle_mission_assignment vma
        JOIN armored_vehicle av ON vma.vehicle_ID = av.vehicle_ID
        WHERE vma.mission_ID = p_mission_id;
BEGIN
	-- Explicit cursor: Check if vehicle is already assigned
    IF p_action = 'assign_vehicle' THEN
        OPEN cur;
        LOOP
            FETCH cur INTO summary_rec;
            EXIT WHEN NOT FOUND;
            IF summary_rec.vehicle_ID = p_vehicle_id THEN
                RAISE WARNING 'Vehicle % is already assigned to mission %', p_vehicle_id, p_mission_id;
                CLOSE cur;
                RETURN;
            END IF;
        END LOOP;
        CLOSE cur;

        -- Assign vehicle with RETURNING clause
        BEGIN
            INSERT INTO vehicle_mission_assignment (vehicle_ID, mission_ID)
            VALUES (p_vehicle_id, p_mission_id)
            RETURNING vehicle_ID INTO inserted_vehicle_id;

            -- Only print success if vehicle was actually inserted
            IF inserted_vehicle_id IS NOT NULL THEN
                RAISE NOTICE 'Vehicle % assigned to mission %', p_vehicle_id, p_mission_id;
            END IF;
        EXCEPTION
            WHEN unique_violation THEN
                RAISE WARNING 'Vehicle % already assigned (unique constraint)', p_vehicle_id;
            WHEN OTHERS THEN
                RAISE WARNING 'Error assigning vehicle: %', SQLERRM;
        END;

	-- Remove vehicle
    ELSIF p_action = 'remove_vehicle' THEN
        DELETE FROM vehicle_mission_assignment
        WHERE vehicle_ID = p_vehicle_id AND mission_ID = p_mission_id;
        GET DIAGNOSTICS vehicle_count = ROW_COUNT;
        IF vehicle_count > 0 THEN
            RAISE NOTICE 'Vehicle % removed from mission %', p_vehicle_id, p_mission_id;
        ELSE
            RAISE NOTICE 'Vehicle % not assigned to mission %', p_vehicle_id, p_mission_id;
        END IF;

	-- Find not-ready vehicle (implicit cursor)
    ELSIF p_action = 'replace_vehicle' THEN
        SELECT vma.vehicle_ID INTO not_ready_vehicle_id
        FROM vehicle_mission_assignment vma
        JOIN armored_vehicle av ON vma.vehicle_ID = av.vehicle_ID
        WHERE vma.mission_ID = p_mission_id
          AND av.next_maintenance_date <= CURRENT_DATE
        LIMIT 1;

        IF not_ready_vehicle_id IS NULL THEN
            RAISE WARNING 'No not-ready vehicle found for mission %', p_mission_id;
        ELSE
            -- Find available ready vehicle not assigned to any mission
            SELECT av.vehicle_ID INTO available_vehicle_id
            FROM armored_vehicle av
            WHERE av.next_maintenance_date > CURRENT_DATE
              AND av.vehicle_ID NOT IN (
                  SELECT vehicle_ID FROM vehicle_mission_assignment
              )
            LIMIT 1;

            IF available_vehicle_id IS NULL THEN
                RAISE WARNING 'No available ready vehicle to replace';
            ELSE
                DELETE FROM vehicle_mission_assignment
                WHERE vehicle_ID = not_ready_vehicle_id AND mission_ID = p_mission_id;
                INSERT INTO vehicle_mission_assignment (vehicle_ID, mission_ID)
                VALUES (available_vehicle_id, p_mission_id);
                RAISE NOTICE 'Vehicle % replaced by vehicle % in mission %',
                    not_ready_vehicle_id, available_vehicle_id, p_mission_id;
            END IF;
        END IF;

	-- Move a soldier from one unit to another
    ELSIF p_action = 'move_soldier' THEN
        IF p_soldier_id IS NULL OR p_new_unit_id IS NULL THEN
            RAISE WARNING 'Soldier ID and new unit ID must be provided for move_soldier action';
        ELSE
            SELECT COUNT(*) INTO soldier_exists FROM soldier WHERE personnel_ID = p_soldier_id;
            IF soldier_exists = 0 THEN
                RAISE WARNING 'Soldier % does not exist', p_soldier_id;
            ELSE
                UPDATE soldier SET unit_ID = p_new_unit_id WHERE personnel_ID = p_soldier_id;
                RAISE NOTICE 'Soldier % moved to unit %', p_soldier_id, p_new_unit_id;
            END IF;
        END IF;

	-- Use a temporary table for summary
    ELSIF p_action = 'summary' THEN
        CREATE TEMP TABLE tmp_summary AS
            SELECT 
                m.mission_ID, m.mission_name, u.unit_ID, u.unit_name,
                COUNT(DISTINCT vma.vehicle_ID) AS total_vehicles,
                SUM(CASE WHEN av.next_maintenance_date > CURRENT_DATE THEN 1 ELSE 0 END) AS ready_vehicles,
                COUNT(DISTINCT s.personnel_ID) AS total_soldiers
            FROM mission m
            JOIN unit_mission_assignment uma ON m.mission_ID = uma.mission_ID
            JOIN unit u ON uma.unit_ID = u.unit_ID
            LEFT JOIN vehicle_mission_assignment vma ON m.mission_ID = vma.mission_ID
            LEFT JOIN armored_vehicle av ON vma.vehicle_ID = av.vehicle_ID
            LEFT JOIN soldier s ON s.unit_ID = u.unit_ID
            WHERE m.mission_ID = p_mission_id AND u.unit_ID = p_unit_id
            GROUP BY m.mission_ID, m.mission_name, u.unit_ID, u.unit_name;

        FOR summary_rec IN SELECT * FROM tmp_summary
        LOOP
            RAISE NOTICE 'Mission: %, Unit: %, Vehicles: %, Ready: %, Soldiers: %',
                summary_rec.mission_ID, summary_rec.unit_ID, summary_rec.total_vehicles,
                summary_rec.ready_vehicles, summary_rec.total_soldiers;
        END LOOP;
        DROP TABLE IF EXISTS tmp_summary;

    ELSE
        RAISE WARNING 'Invalid action: %', p_action;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Error in manage_mission_operations: %', SQLERRM;
END;
$$;
```

### 📸 Execution Proof

**Assign Vehicle (Success)**:

![Assign Vehicle Output](Images/P2-assign_vehicle-During.png)

**Assign Vehicle - Before**:

![Before](Images/P2-assign_vehicle-Before.png)

**Assign Vehicle - After**:

![After](Images/P2-assign_vehicle-After.png)

**Duplicate Assignment Exception**:

![Duplicate Exception](Images/P2-exception-Before.png)

![Exception Output](Images/P2-exception-output.png)

---

## 🔒 Trigger: log_warehouse_entity_transfer

### **Description**

**Purpose:**  
Logs any transfer (warehouse change) of equipment, ammunition, or armored vehicles.

**Main Features:**  
- Works automatically after updating the warehouse ID in equipment, ammunition, or armored_vehicle tables
- Checks if logging is enabled (using a session variable)
- Prints a NOTICE message with details of the transfer (entity type, ID, source and target warehouse)
- Helps track and audit inventory movements

### SQL Code:

```sql
-- Trigger function: Log warehouse entity transfer (generic for all relevant tables)
CREATE OR REPLACE FUNCTION log_warehouse_entity_transfer() RETURNS trigger AS $$
DECLARE
    log_flag TEXT;
BEGIN
    BEGIN
        log_flag := current_setting('myapp.log_transfer', true);
    EXCEPTION WHEN OTHERS THEN
        log_flag := NULL;
    END;

    IF log_flag = 'on' AND NEW.warehouse_ID IS DISTINCT FROM OLD.warehouse_ID THEN
        RAISE NOTICE 'Entity of type % [entity: %] moved from warehouse % to warehouse %',
            TG_TABLE_NAME, NEW.*::record, OLD.warehouse_ID, NEW.warehouse_ID;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Attach the trigger to all relevant tables (example: equipment)
CREATE TRIGGER trg_log_equipment_transfer
AFTER UPDATE OF warehouse_ID ON equipment
FOR EACH ROW EXECUTE FUNCTION log_warehouse_entity_transfer();

CREATE TRIGGER trg_log_ammunition_transfer
AFTER UPDATE OF warehouse_ID ON ammunition
FOR EACH ROW EXECUTE FUNCTION log_warehouse_entity_transfer();

CREATE TRIGGER trg_log_armored_vehicle_transfer
AFTER UPDATE OF warehouse_ID ON armored_vehicle
FOR EACH ROW EXECUTE FUNCTION log_warehouse_entity_transfer();
```

### 📸 Execution Proof

![Trigger Transfer Log](Images/P2-Trigger-During.png)

---

## 🔒 Trigger: trg_prevent_assign_not_ready_vehicle

### **Description**

**Purpose:**  
Prevents assigning a vehicle to a mission if the vehicle is not ready (maintenance overdue).

**Main Features:**  
- Runs automatically before inserting a new vehicle-mission assignment
- Checks if the vehicle's next maintenance date is in the future
- If not ready, cancels the assignment and raises a WARNING message
- Ensures only ready vehicles are assigned to missions

### SQL Code:

```sql
-- Trigger function: Prevent assigning a not-ready vehicle to a mission
CREATE OR REPLACE FUNCTION trg_fn_prevent_assign_not_ready_vehicle()
RETURNS trigger AS $$
DECLARE
    is_ready BOOLEAN;
BEGIN
    -- Check if the vehicle is ready (maintenance is valid)
    SELECT (next_maintenance_date > CURRENT_DATE)
    INTO is_ready
    FROM armored_vehicle
    WHERE vehicle_ID = NEW.vehicle_ID;

    -- If not ready, cancel the assignment and raise a warning
    IF NOT is_ready THEN
        RAISE WARNING 'Assign canceled: Vehicle % is NOT ready (maintenance overdue)', NEW.vehicle_ID;
        RETURN NULL; -- Cancel the insert
    END IF;

    RETURN NEW; -- Allow the insert if ready
END;
$$ LANGUAGE plpgsql;


-- Trigger: Call the function before inserting a vehicle-mission assignment
CREATE TRIGGER trg_prevent_assign_not_ready_vehicle
BEFORE INSERT ON vehicle_mission_assignment
FOR EACH ROW
EXECUTE FUNCTION trg_fn_prevent_assign_not_ready_vehicle();
```

### 📸 Execution Proof

**Trigger Output**:

![Trigger Before](Images/P2-Trigger-Before.png)

![Trigger After](Images/P2-Trigger-After.png)

---

## 🔢 Main Program 1: Warehouse Management System

### **Description**

Demonstrates the use of warehouse status report and multiple transfer operations (equipment, ammunition, vehicle, and part). Printed results show before and after warehouse conditions.

### SQL Code:

```sql
-- Main Program: Warehouse Management System
DO $$
DECLARE
    cur refcursor;
    rec RECORD;
BEGIN
    -- === PHASE 1: Initial Warehouse Status Report ===
    cur := 'phase1_cursor';
    PERFORM get_warehouses_status(cur);
    RAISE NOTICE '=== PHASE 1: Initial Warehouse Status Report ===';
    LOOP
        FETCH cur INTO rec;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Warehouse % (%): %/% used, % vehicles, % equipment, % ammo | Alert: %',
            rec.warehouse_id, rec.location_name, rec.used_space, rec.capacity,
            rec.total_vehicles, rec.total_equipment, rec.total_ammunition, rec.warehouse_alert;
    END LOOP;
    CLOSE cur;
	
	RAISE NOTICE '';
	
    -- === PHASE 2: All Transfers (with resets to ensure success) ===
    RAISE NOTICE '=== PHASE 2: Transfer Operations ===';

    -- Equipment transfer
    CALL transfer_warehouse_entity('equipment', 2402, 2301, 2300);

    -- Ammunition transfer
    CALL transfer_warehouse_entity('ammunition', 2501, 2301, 2300);

    -- Armored vehicle transfer
    CALL transfer_warehouse_entity('armored_vehicle', 2601, 2301, 2300);

    -- Reset vehicle location before part transfer
    UPDATE armored_vehicle SET warehouse_ID = 2301 WHERE vehicle_ID = 2601;
    -- Vehicle part transfer
    CALL transfer_warehouse_entity('vehicle_part', 2701, 2301, 2300, 2601);
	
	RAISE NOTICE '';
    
	-- === PHASE 3: Updated Warehouse Status Report ===
    cur := 'phase3_cursor';
    PERFORM get_warehouses_status(cur);
    RAISE NOTICE '=== PHASE 3: Updated Warehouse Status Report ===';
    LOOP
        FETCH cur INTO rec;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Warehouse % (%): %/% used, % vehicles, % equipment, % ammo | Alert: %',
            rec.warehouse_id, rec.location_name, rec.used_space, rec.capacity,
            rec.total_vehicles, rec.total_equipment, rec.total_ammunition, rec.warehouse_alert;
    END LOOP;
    CLOSE cur;

      RAISE NOTICE '=======================================';
    RAISE NOTICE 'Program completed successfully';
END $$;
```

---

## 🔢 Main Program 2: Mission Management System

### **Description**

Executes full mission management flow: generate reports, assign/replace vehicles, move soldier, show summary, and handle exception with duplicate assignment.

### SQL Code:

```sql
-- Main Program: Mission Management System
DO $$
DECLARE
    mission_cursor REFCURSOR;
    mission_rec RECORD;
    test_mission_id INT := 1669;
    test_unit_id INT := 1082;
    test_vehicle_id INT := 1055;
    test_soldier_id INT := 1101;
	test_not_ready_vehicle INT := 9991;
BEGIN
    RAISE NOTICE '===== MISSION MANAGEMENT SYSTEM =====';
    RAISE NOTICE '=== PHASE 1: Initial Mission Report ===';
    
    -- Step 1: Get mission preparedness report
    mission_cursor := get_mission_preparedness(2);
    LOOP
        FETCH mission_cursor INTO mission_rec;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Mission: % (ID: %), Unit: % - Status: %',
            mission_rec.mission_name, mission_rec.mission_id,
            mission_rec.unit_name, mission_rec.mission_status;
        RAISE NOTICE '  - Vehicles: % (% ready), Soldiers: %',
            mission_rec.total_vehicles, mission_rec.ready_vehicles,
            mission_rec.total_soldiers;
        RAISE NOTICE '  - Assessment: %', mission_rec.mission_comment;
    END LOOP;
    CLOSE mission_cursor;
    
    RAISE NOTICE '';
    RAISE NOTICE '=== PHASE 2: Mission Operations ===';
    
    -- Step 2: Assign vehicle to mission
    RAISE NOTICE 'Operation 1: Assigning vehicle % to mission %', test_vehicle_id, test_mission_id;
    CALL manage_mission_operations(
        p_mission_id => test_mission_id,
        p_unit_id => test_unit_id,
        p_action => 'assign_vehicle',
        p_vehicle_id => test_vehicle_id
    );
    
    -- Step 3: Replace non-ready vehicle
    RAISE NOTICE 'Operation 2: Replacing non-ready vehicle in mission %', test_mission_id;
    CALL manage_mission_operations(
        p_mission_id => test_mission_id,
        p_unit_id => test_unit_id,
        p_action => 'replace_vehicle'
    );
    
    -- Step 4: Move soldier to new unit
    RAISE NOTICE 'Operation 3: Moving soldier % to new unit', test_soldier_id;
    CALL manage_mission_operations(
        p_mission_id => NULL,
        p_unit_id => NULL,
        p_action => 'move_soldier',
        p_soldier_id => test_soldier_id,
        p_new_unit_id => 1083
    );

	-- Step 5: Trigger Demo - Prevent Assign Not-Ready Vehicle
	RAISE NOTICE 'Operation 4: Trigger demo - assign NOT READY and READY vehicles';
	CALL manage_mission_operations(
        p_mission_id => test_mission_id,
        p_unit_id => test_unit_id,
        p_action => 'assign_vehicle',
        p_vehicle_id => 9991  -- Vehicle with next_maintenance_date <= CURRENT_DATE
    );
	
    -- Step 6: Get mission summary
    RAISE NOTICE 'Operation 5: Getting summary for mission %', test_mission_id;
    CALL manage_mission_operations(
        p_mission_id => test_mission_id,
        p_unit_id => test_unit_id,
        p_action => 'summary'
    );
    
    RAISE NOTICE '';
    RAISE NOTICE '=== PHASE 3: Updated Mission Report ===';
    
    -- Step 6: Get updated report
    DROP TABLE IF EXISTS tmp_mission_report;
    mission_cursor := get_mission_preparedness(2);
    LOOP
        FETCH mission_cursor INTO mission_rec;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Mission: % (ID: %), Unit: % - Status: %',
            mission_rec.mission_name, mission_rec.mission_id,
            mission_rec.unit_name, mission_rec.mission_status;
    END LOOP;
    CLOSE mission_cursor;
    
    RAISE NOTICE '';
    RAISE NOTICE '=== PHASE 4: Exception Handling Demo ===';
    
    -- Step 7: Demonstrate error handling (duplicate assignment)
    BEGIN
        RAISE NOTICE 'Operation 5: Attempting duplicate vehicle assignment...';
        CALL manage_mission_operations(
            p_mission_id => test_mission_id,
            p_unit_id => test_unit_id,
            p_action => 'assign_vehicle',
            p_vehicle_id => test_vehicle_id
        );
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Error handled: %', SQLERRM;
    END;
    
    RAISE NOTICE '=======================================';
    RAISE NOTICE 'Program completed successfully';
END $$;
```

---

## 💾 Updated Backup

A new backup named **ACLD_Backup_3** was created after successful testing of all programs.

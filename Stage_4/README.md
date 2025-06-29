\## 📚 Table of Contents



1\. \[📘 Introduction](#-introduction)

2\. \[📊 Function: get\_warehouses\_status](#-function-get\_warehouses\_status)

3\. \[📊 Function: get\_mission\_preparedness](#-function-get\_mission\_preparedness)

4\. \[🔧 Procedure: transfer\_warehouse\_entity](#-procedure-transfer\_warehouse\_entity)

5\. \[🔧 Procedure: manage\_mission\_operations](#-procedure-manage\_mission\_operations)

6\. \[🔒 Trigger: log\_warehouse\_entity\_transfer](#-trigger-log\_warehouse\_entity\_transfer)

7\. \[🔒 Trigger: trg\_prevent\_assign\_not\_ready\_vehicle](#-trigger-trg\_prevent\_assign\_not\_ready\_vehicle)

8\. \[🔢 Main Program 1: Warehouse Management System](#-main-program-1-warehouse-management-system)

9\. \[🔢 Main Program 2: Mission Management System](#-main-program-2-mission-management-system)

10\. \[💾 Updated Backup](#-updated-backup)



---



\## 📘 Introduction



In this stage of the project, we implemented several PL/pgSQL programs to extend the functionality of our integrated database system. This includes:



\- 2 functions

\- 2 procedures

\- 2 triggers

\- 2 main SQL programs



The goal was to cover advanced PL/pgSQL programming features such as cursors, exceptions, DML operations, and multi-entity logic.



---



\## 📊 Function: get\_warehouses\_status



\### \*\*Description\*\*



\*\*Purpose:\*\*  

Provides a dashboard report about all warehouses, showing their usage, remaining space, and alerts if they are full or almost full.



\*\*Main Features:\*\*  

\- For each warehouse, the function calculates and displays:

&nbsp; - Whether the warehouse is full or almost full, with clear alert messages

&nbsp; - The name of the warehouse manager and the warehouse location

&nbsp; - The total storage capacity, how much space is used, and how much space is left

&nbsp; - The total number of vehicles, equipment items, and ammunition units stored

\- The function gathers and combines information from several tables:

&nbsp; (warehouse, locations, personnel, equipment, ammunition, and armored\_vehicle)

\- The results are returned as a refcursor, allowing you to easily use or display the report in different ways



\### SQL Code:



```sql

-- Full code from get\_warehouses\_status.sql included here

```



\### 📸 Execution Proof



Shows a clear report with values such as warehouse capacity, used space, remaining space, and total items:



!\[Warehouse Status Output](Images/F1.png)



---



\## 📊 Function: get\_mission\_preparedness



\### \*\*Description\*\*



\*\*Purpose:\*\*  

Generates a report about how prepared each mission/unit is, based on vehicles and soldiers.



\*\*Main Features:\*\*  

\- For each mission and unit the function:

&nbsp; - Counts assigned vehicles and soldiers

&nbsp; - Checks how many vehicles are ready (maintenance is valid)

&nbsp; - Returns mission status ("Ready" or "Not Ready") and a comment

\- Allows setting a minimum number of ready vehicles for readiness

\- Returns the result as a refcursor



\### SQL Code:



```sql

-- Full code from get\_mission\_preparedness.sql included here

```



\### 📸 Execution Proof



Output shows mission names, units, readiness status and comments:



!\[Mission Preparedness Output](Images/F2.png)



---



\## 🔧 Procedure: transfer\_warehouse\_entity



\### \*\*Description\*\*



\*\*Purpose:\*\*  

Transfers an entity (equipment, ammunition, armored vehicle, or vehicle part) from one warehouse to another, with full validation.



\*\*Main Features:\*\*  

\- Supports transferring different types of entities:

&nbsp; - Equipment

&nbsp; - Ammunition

&nbsp; - Armored vehicle

&nbsp; - Vehicle part (by moving its vehicle)

\- Checks that the target warehouse has enough capacity

\- Validates that the entity exists in the source warehouse

\- Prevents duplicate ammunition in the target warehouse

\- For vehicle parts, checks that the part and vehicle match and are in the source warehouse

\- Raises clear error messages if something is wrong (no space, not found, etc.)

\- Uses robust error handling for data safety



\*\*Actions:\*\*  

\- `'equipment'` - Moves a specific equipment item.

\- `'ammunition'` - Moves a specific ammunition item, but only if it does not already exist in the target warehouse.

\- `'armored\_vehicle'` - Moves a specific armored vehicle.

\- `'vehicle\_part'` - Moves the entire vehicle that contains the specified part.



\### SQL Code:



```sql

-- Full code from transfer\_warehouse\_entity.sql included here

```



\### 📸 Execution Proof



\*\*Before\*\*:



!\[Before Transfer](Images/P1-Before.png)



\*\*During (with NOTICE message)\*\*:



!\[During Transfer](Images/P1-During.png)



\*\*After (Updated locations)\*\*:



!\[After Transfer 1](Images/P1-After1.png)



!\[After Transfer 2](Images/P1-After2.png)



---



\## 🔧 Procedure: manage\_mission\_operations



\### \*\*Description\*\*



\*\*Purpose:\*\*  

Handles different mission-related operations for vehicles and soldiers.



\*\*Main Features:\*\*  

\- Multi-action procedure, controlled by the `p\_action` parameter.

\- Uses explicit and implicit cursors for advanced logic

\- Handles unique constraint and other errors

\- Gives user-friendly feedback with NOTICE and WARNING messages

\- Uses a temporary table for summary reports



\*\*Actions:\*\*  

\- `'assign\_vehicle'` - Assigns a vehicle to a mission (if not already assigned).

\- `'remove\_vehicle'` - Removes a vehicle from a mission.

\- `'replace\_vehicle'` - Finds a not-ready vehicle in a mission and replaces it with an available, ready vehicle.

\- `'move\_soldier'` - Moves a soldier to a different unit (requires soldier ID and new unit ID).

\- `'summary'` - Generates a summary report for a mission and unit, showing mission name, unit name, number of vehicles, ready vehicles, and soldiers.



\### SQL Code:



```sql

-- Full code from manage\_mission\_operations.sql included here

```



\### 📸 Execution Proof



\*\*Assign Vehicle (Success)\*\*:



!\[Assign Vehicle Output](Images/P2-assign\_vehicle-During.png)



\*\*Assign Vehicle - Before\*\*:



!\[Before](Images/P2-assign\_vehicle-Before.png)



\*\*Assign Vehicle - After\*\*:



!\[After](Images/P2-assign\_vehicle-After.png)



\*\*Duplicate Assignment Exception\*\*:



!\[Duplicate Exception](Images/P2-exception-Before.png)



!\[Exception Output](Images/P2-exception-output.png)



---



\## 🔒 Trigger: log\_warehouse\_entity\_transfer



\### \*\*Description\*\*



\*\*Purpose:\*\*  

Logs any transfer (warehouse change) of equipment, ammunition, or armored vehicles.



\*\*Main Features:\*\*  

\- Works automatically after updating the warehouse ID in equipment, ammunition, or armored\_vehicle tables

\- Checks if logging is enabled (using a session variable)

\- Prints a NOTICE message with details of the transfer (entity type, ID, source and target warehouse)

\- Helps track and audit inventory movements



\### SQL Code:



```sql

-- Full code from Trigger1.sql included here

```



\### 📸 Execution Proof



!\[Trigger Transfer Log](Images/P2-Trigger-During.png)



---



\## 🔒 Trigger: trg\_prevent\_assign\_not\_ready\_vehicle



\### \*\*Description\*\*



\*\*Purpose:\*\*  

Prevents assigning a vehicle to a mission if the vehicle is not ready (maintenance overdue).



\*\*Main Features:\*\*  

\- Runs automatically before inserting a new vehicle-mission assignment

\- Checks if the vehicle's next maintenance date is in the future

\- If not ready, cancels the assignment and raises a WARNING message

\- Ensures only ready vehicles are assigned to missions



\### SQL Code:



```sql

-- Full code from Trigger2.sql included here

```



\### 📸 Execution Proof



\*\*Trigger Output\*\*:



!\[Trigger Before](Images/P2-Trigger-Before.png)



!\[Trigger After](Images/P2-Trigger-After.png)



---



\## 🔢 Main Program 1: Warehouse Management System



\### \*\*Description\*\*



Demonstrates the use of warehouse status report and multiple transfer operations (equipment, ammunition, vehicle, and part). Printed results show before and after warehouse conditions.



\### SQL Code:



```sql

-- Full code from MainFunction1.sql included here

```



---



\## 🔢 Main Program 2: Mission Management System



\### \*\*Description\*\*



Executes full mission management flow: generate reports, assign/replace vehicles, move soldier, show summary, and handle exception with duplicate assignment.



\### SQL Code:



```sql

-- Full code from MainFunction2.sql included here

```



---



\## 💾 Updated Backup



A new backup named \*\*ACLD\_Backup\_3\*\* was created after successful testing of all programs.




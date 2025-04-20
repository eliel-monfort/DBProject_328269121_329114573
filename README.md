# DBProject_328269121_329114573 

![SQL](https://img.shields.io/badge/SQL-RelationalDB-blue?style=flat-square)
![Status](https://img.shields.io/badge/Status-Stable-brightgreen?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)

# 🛡️ Armored Warehouse Management System

## 👤 Authors:
- Eliel Monfort - 328269121
- Yehoshua Steinitz - 329114573

---

## 📚 Table of Contents

1. [📘 Introduction](#-introduction)
2. [🗂️ Entities and Attributes](#-entities-and-attributes)
4. [🔗 Relationships](#-relationships)
5. [📈 ERD & DSD Diagrams](#-erd--dsd-diagrams)
6. [🧠 Design Decisions](#-design-decisions)
7. [📥 Data Insertion Methods](#-data-insertion-methods)
8. [💾 Backup and Restore](#-backup-and-restore)

---

## 📘 Introduction

This project is a **Database Management System** for the **Logistics Unit of the Armored Corps**.

The system is designed to manage all aspects related to **military equipment**, **armored vehicles**, **soldiers**, **commanders**, **missions**, and **vehicle maintenance**.

It stores important data and enables efficient tracking of:

- Equipment stored in warehouses  
- Which soldier or unit is using specific equipment  
- Armored vehicles and their maintenance history  
- Soldiers, commanders, and their assigned units  
- Missions and which units and soldiers are involved  

The goal is to build a smart and organized database that supports real military operations and provides accurate, real-time information for decision-making.

---

## 🗂️ Entities and Attributes

### 1. Warehouse
Represents a storage location for vehicles and equipment.
- `warehouse ID` (PK) : Unique warehouse identifier
- `location` : Physical location
- `capacity` : Storage capacity
- `opened date` : Date the warehouse was opened
- `last inspection_date` : Last inspection date

### 2. Equipment
Represents a piece of equipment.
- `equipment ID` (PK) : Unique equipment identifier
- `name` : Equipment name
- `purchase date` : Date of purchase
- `warranty expiration` : Warranty expiration date

### 3. Equipment Type
Defines categories of equipment.
- `type ID` (PK) : Unique type identifier
- `type name` : Type name
- `category` : General category of the equipment
- `description` : Detailed description

### 4. Armored Vehicle
Represents an armored vehicle.
- `vehicle ID` (PK) : Unique vehicle identifier
- `model` : Vehicle model
- `manufacture year` : Year of manufacture
- `last maintenance date` : Date of last maintenance
- `next maintenance date` : Planned date for next maintenance

### 5. Vehicle Part
Represents a part belonging to a specific vehicle (weak entity).
- `part ID` (Partial PK) : Part identifier
- `part name` : Part name

### 6. Maintenance
Represents maintenance actions.
- `maintenance ID` (PK) : Unique maintenance identifier
- `performed on` : Date maintenance was performed
- `next due` : Date of next scheduled maintenance
- `description` : Description of the maintenance

### 7. Personnel (Superclass)
Represents a person, either a soldier or a commander.
- `personnel ID` (PK) : Unique personnel identifier
- `first name` : First name
- `last name` : Last name
- `date of birth` : Date of birth

### 8. Commander (inherits from `Personnel`)
Subtype of Personnel – represents a commander.
- `command level` : Command level
- `years of experience` : Years of experience

### 9. Soldier (inherits from `Personnel`)
Subtype of Personnel – represents a soldier.
- `rank` : Military rank
- `enlistment date` : Enlistment date

### 10. Unit
Represents a military unit.
- `unit ID` (PK) : Unique unit identifier
- `unit name` : Unit name
- `base location` : Base location

### 11. Mission
Represents a military mission.
- `mission ID` (PK) : Unique mission identifier
- `mission name` : Name of the mission
- `location` : Mission location
- `objective` : Mission objective

---

## 🔗 Relationships

### 1. Contains Equipment
- **Linked Entities:** Equipment ⟷ Warehouse
- **Type:** Many-to-One
- **Attributes:**
  - `quantity` : Number of items of this equipment stored in the warehouse.
  - `stored since` : The date the equipment was first stored in the warehouse.
- **Explanation:** Equipment is stored in a specific warehouse.

### 2. Categorizes
- **Linked Entities:** Equipment ⟷ Equipment Type
- **Type:** Many-to-One
- **Explanation:** Each equipment item belongs to a defined type, such as weapon, communication device, etc.

### 3. Soldier Equipment Use
- **Linked Entities:** Equipment ⟷ Soldier
- **Type:** Optional Many-to-One
- **Attributes:**
  - `use start` : The date the soldier started using the equipment.
  - `use end` : The date the soldier stopped using the equipment.
- **Explanation:** Equipments may optionally be assigned to a soldier.

### 4. Houses Vehicle
- **Linked Entities:** Armored Vehicle ⟷ Warehouse
- **Type:** Many-to-One
- **Attributes:**
  - `arrival date` : The date the vehicle was brought into the warehouse.
  - `departure date` : The date the vehicle left the warehouse.
- **Explanation:** Each vehicle is stored in one warehouse, and a warehouse can store many vehicles.

### 5. Undergoes
- **Linked Entities:** Maintenance ⟷ Armored Vehicle
- **Type:** Many-to-Many
- **Attributes:**
  - `notes` : Notes about the maintenance.
  - `duration_hours` : Duration of the maintenance in hours.
- **Explanation:** A maintenance operation may involve several vehicles, each with specific notes and duration.

### 6. Part Of
- **Linked Entities:** Vehicle Part ⟷ Armored Vehicle
- **Type:** Weak Entity Relationship
- **Explanation:** A part belongs to a specific vehicle and cannot exist independently. There can be two identical parts but in two different vehicles.

### 7. Problem With
- **Linked Entities:** Maintenance ⟷ Vehicle Part
- **Type:** Many-to-Many
- - **Attributes:**
  - `Cost of repair` : Repair cost.
  - `replaced on` : Replacement date.
- **Explanation:** Each maintenance action can report issues with multiple parts in one or more vehicles.

### 8. Vehicle Mission Assignment
- **Linked Entities:** Armored Vehicle ⟷ Mission
- **Type:** Optional Many-to-One
- **Explanation:** A vehicle may be assigned to a mission, but it's not mandatory.

### 9. Commander Unit Assignment
- **Linked Entities:** Commander ⟷ Unit
- **Type:** One-to-One
- **Attributes:**
  - `assigned date` : The date the commander was officially assigned to lead the unit.
- **Explanation:** Each unit is led by one commander, and a commander leads only one unit.

### 10. Soldier Unit Assignment
- **Linked Entities:** Soldier ⟷ Unit
- **Type:** Many-to-One
- **Explanation:** Each soldier belongs to one unit, while a unit can have many soldiers.

### 11. Soldier Mission Assignment
- **Linked Entities:** Soldier ⟷ Mission
- **Type:** Many-to-Many
- **Attributes:**
  - `role` : Soldier's role during the mission
  - `join date` : Date the soldier joined the mission
  - `leave date` : Date the soldier left the mission
- **Explanation:** Soldiers can be assigned to multiple missions, with additional details such as role and dates.

### 12. Unit Mission Assignment
- **Linked Entities:** Unit ⟷ Mission
- **Type:** Many-to-Many
- **Attributes:**
  - `assigned date` : Date the unit was assigned to the mission
- **Explanation:** Units can participate in multiple missions; each assignment has a specific date.

---

## 📈 ERD & DSD Diagrams

- **ERD Diagram**:
![ERD](Stage_1/Images/ERD.png)

- **DSD Diagram**:
![DSD](Stage_1/Images/DSD.png)

---

# 📦 Data Insertion Documentation

## Method 1: Mockaroo Data Generation

I used [Mockaroo](https://mockaroo.com) to generate realistic mock data for the following tables:

- `Warehouse`
- `Mission`
- `Personnel`
- `Equipment Type`
- `Maintenance`

The generated data was downloaded as CSV files and then imported using PostgreSQL import tools.

📸 Screenshot of Mockaroo configuration:  
![Mockaroo Config](images/mockaroo_config.png) <!-- ### -->

📸 Screenshot of data upload/import:  
![Import Screenshot](images/mockaroo_import.png) <!-- ### -->

## Method 2: CSV File Insertion

I asked ChatGPT to generate 5 realistic CSV files with 500 rows each for the following tables:

- `Armored Vehicle`
- `Commander`
- `Soldier`
- `Unit`
- `Vehicle Part`

The CSV files were manually reviewed and then inserted into the database using PostgreSQL's CSV import functionality.

📸 Screenshot of the CSV files used:
![CSV Files](images/csv_files_screenshot.png) <!-- ### -->

## Method 2: Python Script

For the second method, I wrote a Python script using `pandas` and `psycopg2` to programmatically insert data into the following tables:

- `?????????`

📸 Screenshot of Python script execution:  
![Python Script Execution](images/python_script.png) <!-- ### -->

📸 Screenshot of data in pgAdmin:  
![pgAdmin Result](images/pgadmin_result.png) <!-- ### -->

## ✅ Summary

| Method   | Tables Covered                   | Status     |
|----------|----------------------------------|------------|
| Mockaroo | Warehouse, Mission, Personnel, Equipment Type, Maintenance | ✅ Completed |
| CSV      | Armored Vehicle, Commander, Soldier, Unit, Vehicle Part | ✅ Completed |
| Python   | ????, ????, ????, ????, ???? | ✅ Completed |

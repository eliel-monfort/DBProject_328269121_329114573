# DBProject_328269121_329114573 


![SQL](https://img.shields.io/badge/SQL-RelationalDB-blue?style=flat-square)
![Status](https://img.shields.io/badge/Status-Stable-brightgreen?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)

🪖 the armored corps Asset & Mission Management Database 🗂️
A complete schema for organizing the armored corps: warehouses, missions, personnel, equipment, and maintenance operations.


## 📚 Table of Contents

- [📦 Features](#-features)
- [🧱 Entity-Relationship Structure](#-entity-relationship-structure)
  - [🏢 Warehouse](#-warehouse)
  - [🪖 Soldier](#-soldier)
  - [🎯 Mission](#-mission)
  - [🧰 Equipment](#-equipment)
  - [🔧 Equipment_Type](#-equipment_type)
  - [🚗 Armored_Vehicle](#-armored_vehicle)
  - [🛠️ Maintenance](#-maintenance)
- [🔁 Relationship Tables](#-relationship-tables)
  - [`soldier_mission`](#-soldier_mission)
  - [`contains_equipment`](#-contains_equipment)
  - [`houses_vehicle`](#-houses_vehicle)
  - [`undergoes`](#-undergoes)
- [📚 ERD Suggestion](#-erd-suggestion)

---

## 📦 Features

- Store and track **warehouses** and their contents (equipment & vehicles)
- Manage **equipment** and its associated **types**
- Maintain records of **soldiers** and their assigned **missions**
- Associate **armored vehicles** with missions and maintenance logs
- Track **maintenance history** for vehicles
- Model complex many-to-many relationships via junction tables

---

## 🧱 Entity-Relationship Structure

### 🏢 Warehouse
- `warehouse_id` (PK)
- `location`
- `capacity`
- `opened_date`
- `last_inspection_date`

### 🪖 Soldier
- `soldier_id` (PK)
- `first_name`
- `last_name`
- `rank`
- `date_of_birth`
- `enlistment_date`

### 🎯 Mission
- `mission_id` (PK)
- `mission_name`
- `mission_date`
- `location`

### 🧰 Equipment
- `equipment_id` (PK)
- `name`
- `purchase_date`
- `warranty_expiration`
- `type_id` (FK → Equipment_Type)

### 🔧 Equipment_Type
- `type_id` (PK)
- `type_name` (Unique)
- `description`

### 🚗 Armored_Vehicle
- `vehicle_id` (PK)
- `model`
- `year_of_manufacture`
- `last_maintenance_date`
- `next_maintenance_date`
- `mission_id` (FK)

### 🛠️ Maintenance
- `maintenance_id` (PK)
- `performed_on`
- `next_due`
- `description`

---

## 🔁 Relationship Tables

### 👥 `soldier_mission`
Tracks soldier participation in missions.
- Composite PK: (`soldier_id`, `mission_id`)
- `role`, `join_date`, `leave_date`

### 🏗️ `contains_equipment`
Links equipment to the warehouse it is stored in.
- Composite PK: (`warehouse_id`, `equipment_id`)

### 🏠 `houses_vehicle`
Links vehicles to the warehouse they are stored in.
- Composite PK: (`warehouse_id`, `vehicle_id`)

### 🔄 `undergoes`
Logs maintenance activities for vehicles.
- Composite PK: (`vehicle_id`, `maintenance_id`)

---

## 📚 ERD Suggestion

To better visualize this schema, you can use any of the following tools to create an ERD:
- [dbdiagram.io](https://dbdiagram.io/)
- [drawSQL](https://drawsql.app/)
- [Lucidchart](https://www.lucidchart.com/)
- [MySQL Workbench](https://www.mysql.com/products/workbench/)



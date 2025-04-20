CREATE TABLE Warehouse
(
  warehouse_ID INT PRIMARY KEY,
  location VARCHAR(50),
  capacity INT,
  opened_date DATE,
  last_inspection_date DATE
);

CREATE TABLE Mission
(
  mission_ID INT PRIMARY KEY,
  mission_name VARCHAR(50),
  location VARCHAR(50),
  objective TEXT
);

CREATE TABLE Equipment_Type
(
  type_ID INT PRIMARY KEY,
  type_name VARCHAR(50),
  description TEXT,
  category VARCHAR(50)
);

CREATE TABLE Armored_Vehicle
(
  vehicle_ID INT PRIMARY KEY,
  model VARCHAR(50),
  manufacture_year INT,
  last_maintenance_date DATE,
  next_maintenance_date DATE,
  warehouse_ID INT,
  mission_ID INT,
  FOREIGN KEY (warehouse_ID) REFERENCES Warehouse(warehouse_ID),
  FOREIGN KEY (mission_ID) REFERENCES Mission(mission_ID)
);

CREATE TABLE Maintenance
(
  maintenance_ID INT PRIMARY KEY,
  performed_on DATE,
  next_due DATE,
  description TEXT
);

CREATE TABLE Personnel
(
  personnel_ID INT PRIMARY KEY,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  date_of_birth DATE
);

CREATE TABLE Commander
(
  personnel_ID INT PRIMARY KEY,
  command_level VARCHAR(50),
  years_of_experience INT,
  FOREIGN KEY (personnel_ID) REFERENCES Personnel(personnel_ID)
);

CREATE TABLE Vehicle_Part
(
  part_ID INT,
  part_name VARCHAR(50),
  vehicle_ID INT,
  PRIMARY KEY (part_ID, vehicle_ID),
  FOREIGN KEY (vehicle_ID) REFERENCES Armored_Vehicle(vehicle_ID)
);

CREATE TABLE Undergoes
(
  notes TEXT,
  duration_hours INT,
  maintenance_ID INT,
  vehicle_ID INT,
  PRIMARY KEY (maintenance_ID, vehicle_ID),
  FOREIGN KEY (maintenance_ID) REFERENCES Maintenance(maintenance_ID),
  FOREIGN KEY (vehicle_ID) REFERENCES Armored_Vehicle(vehicle_ID)
);

CREATE TABLE Problem_With
(
  replaced_on DATE,
  cost_of_repair DECIMAL(10,2),
  maintenance_ID INT,
  part_ID INT,
  vehicle_ID INT,
  PRIMARY KEY (maintenance_ID, part_ID, vehicle_ID),
  FOREIGN KEY (maintenance_ID) REFERENCES Maintenance(maintenance_ID),
  FOREIGN KEY (part_ID, vehicle_ID) REFERENCES Vehicle_Part(part_ID, vehicle_ID)
);

CREATE TABLE Unit
(
  unit_ID INT PRIMARY KEY,
  unit_name VARCHAR(50),
  base_location VARCHAR(50),
  personnel_ID INT,
  FOREIGN KEY (personnel_ID) REFERENCES Commander(personnel_ID)
);

CREATE TABLE Soldier
(
  personnel_ID INT PRIMARY KEY,
  rank VARCHAR(50),
  enlistment_date DATE,
  unit_ID INT,
  FOREIGN KEY (personnel_ID) REFERENCES Personnel(personnel_ID),
  FOREIGN KEY (unit_ID) REFERENCES Unit(unit_ID)
);

CREATE TABLE Soldier_Mission_Assignment
(
  role VARCHAR(100),
  join_date DATE,
  leave_date DATE,
  mission_ID INT,
  personnel_ID INT,
  PRIMARY KEY (mission_ID, personnel_ID),
  FOREIGN KEY (mission_ID) REFERENCES Mission(mission_ID),
  FOREIGN KEY (personnel_ID) REFERENCES Soldier(personnel_ID)
);

CREATE TABLE Unit_Mission_Assignment
(
  assigned_date DATE,
  mission_ID INT,
  unit_ID INT,
  PRIMARY KEY (mission_ID, unit_ID),
  FOREIGN KEY (mission_ID) REFERENCES Mission(mission_ID),
  FOREIGN KEY (unit_ID) REFERENCES Unit(unit_ID)
);

CREATE TABLE Equipment
(
  equipment_ID INT PRIMARY KEY,
  name VARCHAR(50),
  purchase_date DATE,
  warranty_expiration DATE,
  warehouse_ID INT,
  type_ID INT,
  FOREIGN KEY (warehouse_ID) REFERENCES Warehouse(warehouse_ID),
  FOREIGN KEY (type_ID) REFERENCES Equipment_Type(type_ID)
);

CREATE TABLE Soldier_Equipment_Use
(
  use_start DATE,
  use_end DATE,
  personnel_ID INT,
  equipment_ID INT,
  PRIMARY KEY (equipment_ID),
  FOREIGN KEY (equipment_ID) REFERENCES Equipment(equipment_ID),
  FOREIGN KEY (personnel_ID) REFERENCES Soldier(personnel_ID)
);
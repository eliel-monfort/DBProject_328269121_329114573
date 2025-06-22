-- Step 1
-- Add contact information and role to the existing Personnel table
ALTER TABLE Personnel
ADD COLUMN email VARCHAR(100),
ADD COLUMN phone_number VARCHAR(20),
ADD COLUMN role VARCHAR(50);



-- Step 2
-- Create the new Location table to normalize warehouse locations
CREATE TABLE Location (
  location_ID INT PRIMARY KEY,
  location_name VARCHAR(100) NOT NULL,
  location_type VARCHAR(50) NOT NULL
);

-- Remove the old 'location' column from Warehouse (replaced with foreign key)
ALTER TABLE Warehouse
DROP COLUMN location;

-- Add foreign key to link each warehouse to its location
ALTER TABLE Warehouse
ADD COLUMN location_ID INT,
ADD FOREIGN KEY (location_ID) REFERENCES Location(location_ID);

-- Add reference to the personnel responsible for each warehouse
ALTER TABLE Warehouse
ADD COLUMN personnel_ID INT,
ADD FOREIGN KEY (personnel_ID) REFERENCES Personnel(personnel_ID);



-- Step 3
-- Create Inspections table to track inspection events for warehouses
CREATE TABLE Inspections (
  inspection_ID INT PRIMARY KEY,
  inspection_date DATE NOT NULL,
  status VARCHAR(50) NOT NULL,
  warehouse_ID INT,
  FOREIGN KEY (warehouse_ID) REFERENCES Warehouse(warehouse_ID)
);

-- Remove 'last_inspection_date' column since we now have full inspection history
ALTER TABLE Warehouse
DROP COLUMN last_inspection_date;


-- Step 4
-- Create Orders table to record logistics movements from one place to another
CREATE TABLE Orders (
  orders_ID INT PRIMARY KEY,
  from_location VARCHAR(100) NOT NULL,
  to_movement VARCHAR(100) NOT NULL,
  order_time DATE NOT NULL,
  warehouse_ID INT,
  FOREIGN KEY (warehouse_ID) REFERENCES Warehouse(warehouse_ID)
);

-- Create a join table to link orders with missions (many-to-many)
CREATE TABLE Orders_Mission_Assignment (
  orders_ID INT REFERENCES Orders(orders_ID),
  mission_ID INT REFERENCES Mission(mission_ID),
  PRIMARY KEY (orders_ID, mission_ID)
);



-- Step 5
-- Create Ammunition table to track ammo stored in each warehouse
CREATE TABLE Ammunition (
  ammunition_ID INT PRIMARY KEY,
  date_added DATE NOT NULL,
  type VARCHAR(50) NOT NULL,
  quantity INT NOT NULL,
  warehouse_ID INT,
  FOREIGN KEY (warehouse_ID) REFERENCES Warehouse(warehouse_ID)
);
-- Attempted Temporary Deployment of Experimental Recon Unit (ROLLBACK Demonstration)

BEGIN;

-- Insert new experimental commander
INSERT INTO Personnel (personnel_ID, first_name, last_name, date_of_birth)
VALUES (1002, 'Erez', 'Shimoni', '1985-02-17');

INSERT INTO Commander (command_level, years_of_experience, personnel_ID)
VALUES ('Recon Specialist', 10, 1002);

-- Create new temporary unit (unit ID 102)
INSERT INTO Unit (unit_ID, unit_name, base_location, personnel_ID)
VALUES (102, 'Recon Temp Unit', 'Southern Field', 1002);

-- Insert 3 test soldiers into this unit
INSERT INTO Personnel (personnel_ID, first_name, last_name, date_of_birth) VALUES
(3001, 'Amit', 'Weiss', '2003-03-03'),
(3002, 'Roi', 'Katz', '2002-12-30'),
(3003, 'Nadav', 'Azoulay', '2003-06-16');

INSERT INTO Soldier (personnel_ID, rank, enlistment_date, unit_ID) VALUES
(3001, 'Private', '2023-02-01', 102),
(3002, 'Private', '2023-02-01', 102),
(3003, 'Private', '2023-02-01', 102);

-- Create a mock mission
INSERT INTO Mission (mission_ID, mission_name, location, objective)
VALUES (700, 'Desert Navigation Test', 'Southern Zone', 'Field-testing soldier movement tracking.');

INSERT INTO Unit_Mission_Assignment (assigned_date, mission_ID, unit_ID)
VALUES (CURRENT_DATE, 700, 102);

-- Assign soldiers to this mission
INSERT INTO Soldier_Mission_Assignment (role, join_date, leave_date, mission_ID, personnel_ID) VALUES
('Navigator', CURRENT_DATE, NULL, 700, 3001),
('Support', CURRENT_DATE, NULL, 700, 3002),
('Observer', CURRENT_DATE, NULL, 700, 3003);

-- Insert temporary test equipment
INSERT INTO Equipment (equipment_ID, name, purchase_date, warehouse_ID, type_ID) VALUES
(701, 'Experimental GPS', '2024-05-01', 1, 550),
(702, 'Thermal Binoculars', '2024-05-01', 1, 550),
(703, 'Drone Controller', '2024-05-01', 1, 550);

-- Assign equipment
INSERT INTO Soldier_Equipment_Use (use_start, use_end, personnel_ID, equipment_ID) VALUES
(CURRENT_DATE, CURRENT_DATE + INTERVAL '3 months', 3001, 701),
(CURRENT_DATE, CURRENT_DATE + INTERVAL '3 months', 3002, 702),
(CURRENT_DATE, CURRENT_DATE + INTERVAL '3 months', 3003, 703);

-- Insert unapproved test vehicle and assign it
INSERT INTO Armored_Vehicle (vehicle_ID, model, manufacture_year, last_maintenance_date, next_maintenance_date, warehouse_ID, mission_ID) VALUES
(701, 'Unmanned Recon Rover', 2023, '2025-05-01', '2025-05-01', 1, 700);

-- Register maintenance
INSERT INTO Maintenance (maintenance_ID, performed_on, next_due, description) VALUES
(701, '2024-05-01', '2025-05-01', 'Initial field test readiness check');

INSERT INTO Undergoes (notes, duration_hours, maintenance_ID, vehicle_ID) VALUES
('Test diagnostic complete', 2, 701, 701);

ROLLBACK;
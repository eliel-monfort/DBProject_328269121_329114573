-- Warehouse
INSERT INTO Warehouse VALUES (1, 'Base Alpha', 100, '2010-01-01', '2023-12-01');
INSERT INTO Warehouse VALUES (2, 'Base Bravo', 150, '2012-05-20', '2024-01-15');
INSERT INTO Warehouse VALUES (3, 'Outpost Zulu', 50, '2018-03-10', '2023-09-10');
INSERT INTO Warehouse VALUES (4, 'Depot Delta', 200, '2005-11-11', '2023-10-22');
INSERT INTO Warehouse VALUES (5, 'Storage Echo', 75, '2020-07-07', '2024-02-01');

-- Mission
INSERT INTO Mission VALUES (1, 'Rescue Dawn', 'Sector A', 'Recover hostages.');
INSERT INTO Mission VALUES (2, 'Storm Front', 'Sector B', 'Eliminate enemy units.');
INSERT INTO Mission VALUES (3, 'Iron Shield', 'Sector C', 'Defend critical area.');
INSERT INTO Mission VALUES (4, 'Blackout', 'Sector D', 'Disable enemy comms.');
INSERT INTO Mission VALUES (5, 'Eagle Eye', 'Sector E', 'Surveillance operation.');

-- Equipment_Type
INSERT INTO Equipment_Type VALUES (1, 'Rifle', 'Standard infantry weapon.', 'Weapon');
INSERT INTO Equipment_Type VALUES (2, 'Radio', 'Tactical communication device.', 'Communication');
INSERT INTO Equipment_Type VALUES (3, 'Binoculars', 'Long-range visual tool.', 'Surveillance');
INSERT INTO Equipment_Type VALUES (4, 'Helmet', 'Protective gear.', 'Defense');
INSERT INTO Equipment_Type VALUES (5, 'Drone', 'Remote recon unit.', 'Reconnaissance');

-- Personnel
INSERT INTO Personnel VALUES (1, 'John', 'Smith', '1980-01-01');
INSERT INTO Personnel VALUES (2, 'Alice', 'Johnson', '1985-05-15');
INSERT INTO Personnel VALUES (3, 'Bob', 'Brown', '1990-09-09');
INSERT INTO Personnel VALUES (4, 'David', 'Clark', '1992-12-12');
INSERT INTO Personnel VALUES (5, 'Eve', 'Davis', '1995-03-03');

-- Commander
INSERT INTO Commander VALUES ('Platoon', 10, 1);
INSERT INTO Commander VALUES ('Company', 15, 2);
INSERT INTO Commander VALUES ('Squad', 8, 3);
INSERT INTO Commander VALUES ('Division', 20, 4);
INSERT INTO Commander VALUES ('Battalion', 25, 5);

-- Unit
INSERT INTO Unit VALUES (1, 'Unit A', 'Camp Alpha', 1);
INSERT INTO Unit VALUES (2, 'Unit B', 'Camp Bravo', 2);
INSERT INTO Unit VALUES (3, 'Unit C', 'Camp Charlie', 3);
INSERT INTO Unit VALUES (4, 'Unit D', 'Camp Delta', 4);
INSERT INTO Unit VALUES (5, 'Unit E', 'Camp Echo', 5);

-- Soldier
INSERT INTO Soldier VALUES ('Private', '2020-01-01', 1, 1);
INSERT INTO Soldier VALUES ('Corporal', '2021-02-02', 2, 2);
INSERT INTO Soldier VALUES ('Sergeant', '2019-03-03', 3, 3);
INSERT INTO Soldier VALUES ('Lieutenant', '2018-04-04', 4, 4);
INSERT INTO Soldier VALUES ('Captain', '2017-05-05', 5, 5);

-- Equipment
INSERT INTO Equipment VALUES (1, 'M16 Rifle', '2021-01-01', '2025-01-01', 1, 1);
INSERT INTO Equipment VALUES (2, 'UHF Radio', '2020-02-02', '2024-02-02', 2, 2);
INSERT INTO Equipment VALUES (3, 'Night Binoculars', '2019-03-03', '2023-03-03', 3, 3);
INSERT INTO Equipment VALUES (4, 'Kevlar Helmet', '2022-04-04', '2026-04-04', 4, 4);
INSERT INTO Equipment VALUES (5, 'Recon Drone', '2023-05-05', '2027-05-05', 5, 5);

-- Soldier_Equipment_Use
INSERT INTO Soldier_Equipment_Use VALUES ('2024-01-01', '2024-01-10', 1, 1);
INSERT INTO Soldier_Equipment_Use VALUES ('2024-01-02', '2024-01-12', 2, 2);
INSERT INTO Soldier_Equipment_Use VALUES ('2024-01-03', '2024-01-13', 3, 3);
INSERT INTO Soldier_Equipment_Use VALUES ('2024-01-04', '2024-01-14', 4, 4);
INSERT INTO Soldier_Equipment_Use VALUES ('2024-01-05', '2024-01-15', 5, 5);

-- Armored_Vehicle
INSERT INTO Armored_Vehicle VALUES (1, 'Tank A1', 2010, '2023-12-01', '2024-06-01', 1, 1);
INSERT INTO Armored_Vehicle VALUES (2, 'Tank B2', 2012, '2023-11-15', '2024-05-15', 2, 2);
INSERT INTO Armored_Vehicle VALUES (3, 'APC C3', 2015, '2023-10-10', '2024-04-10', 3, 3);
INSERT INTO Armored_Vehicle VALUES (4, 'IFV D4', 2018, '2023-09-09', '2024-03-09', 4, 4);
INSERT INTO Armored_Vehicle VALUES (5, 'Jeep E5', 2020, '2023-08-08', '2024-02-08', 5, 5);

-- Maintenance
INSERT INTO Maintenance VALUES (1, '2023-01-01', '2024-01-01', 'Engine check');
INSERT INTO Maintenance VALUES (2, '2023-02-02', '2024-02-02', 'Oil change');
INSERT INTO Maintenance VALUES (3, '2023-03-03', '2024-03-03', 'Tire replacement');
INSERT INTO Maintenance VALUES (4, '2023-04-04', '2024-04-04', 'Armor inspection');
INSERT INTO Maintenance VALUES (5, '2023-05-05', '2024-05-05', 'Weapon system test');

-- Vehicle_Part
INSERT INTO Vehicle_Part VALUES (1, 'Engine', 1);
INSERT INTO Vehicle_Part VALUES (2, 'Tires', 2);
INSERT INTO Vehicle_Part VALUES (3, 'Gun', 3);
INSERT INTO Vehicle_Part VALUES (4, 'Sensor', 4);
INSERT INTO Vehicle_Part VALUES (5, 'Armor', 5);

-- Undergoes
INSERT INTO Undergoes VALUES ('Routine check', 4, 1, 1);
INSERT INTO Undergoes VALUES ('Oil & filter', 2, 2, 2);
INSERT INTO Undergoes VALUES ('Tire fix', 3, 3, 3);
INSERT INTO Undergoes VALUES ('System diagnostics', 5, 4, 4);
INSERT INTO Undergoes VALUES ('Heavy repair', 6, 5, 5);

-- Problem_With
INSERT INTO Problem_With VALUES ('2023-01-05', 1200.00, 1, 1, 1);
INSERT INTO Problem_With VALUES ('2023-02-10', 300.00, 2, 2, 2);
INSERT INTO Problem_With VALUES ('2023-03-15', 500.00, 3, 3, 3);
INSERT INTO Problem_With VALUES ('2023-04-20', 1500.00, 4, 4, 4);
INSERT INTO Problem_With VALUES ('2023-05-25', 2000.00, 5, 5, 5);

-- Soldier_Mission_Assignment
INSERT INTO Soldier_Mission_Assignment VALUES ('Scout', '2024-01-01', '2024-01-10', 1, 1);
INSERT INTO Soldier_Mission_Assignment VALUES ('Medic', '2024-01-02', '2024-01-12', 2, 2);
INSERT INTO Soldier_Mission_Assignment VALUES ('Sniper', '2024-01-03', '2024-01-13', 3, 3);
INSERT INTO Soldier_Mission_Assignment VALUES ('Engineer', '2024-01-04', '2024-01-14', 4, 4);
INSERT INTO Soldier_Mission_Assignment VALUES ('Support', '2024-01-05', '2024-01-15', 5, 5);

-- Unit_Mission_Assignment
INSERT INTO Unit_Mission_Assignment VALUES ('2024-01-01', 1, 1);
INSERT INTO Unit_Mission_Assignment VALUES ('2024-01-02', 2, 2);
INSERT INTO Unit_Mission_Assignment VALUES ('2024-01-03', 3, 3);
INSERT INTO Unit_Mission_Assignment VALUES ('2024-01-04', 4, 4);
INSERT INTO Unit_Mission_Assignment VALUES ('2024-01-05', 5, 5);

-- Vehicle_Mission_Assignment
INSERT INTO Vehicle_Mission_Assignment VALUES (1, 1);
INSERT INTO Vehicle_Mission_Assignment VALUES (2, 2);
INSERT INTO Vehicle_Mission_Assignment VALUES (3, 3);
INSERT INTO Vehicle_Mission_Assignment VALUES (4, 4);
INSERT INTO Vehicle_Mission_Assignment VALUES (5, 5);
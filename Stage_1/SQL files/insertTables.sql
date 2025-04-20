-- Warehouse
INSERT INTO Warehouse VALUES (1, 'North Base', 1000, '2010-06-01', '2023-05-01');
INSERT INTO Warehouse VALUES (2, 'East Depot', 800, '2012-08-15', '2023-06-20');
INSERT INTO Warehouse VALUES (3, 'South Bunker', 600, '2015-01-10', '2024-01-05');

-- Mission
INSERT INTO Mission VALUES (1, 'Desert Shield', 'South Zone', 'Secure the border.');
INSERT INTO Mission VALUES (2, 'Operation Storm', 'East Zone', 'Rescue hostages.');
INSERT INTO Mission VALUES (3, 'Night Watch', 'North Zone', 'Patrol and report.');

-- Equipment_Type
INSERT INTO Equipment_Type VALUES (1, 'Rifle', 'Standard issue assault rifle.', 'Weapon');
INSERT INTO Equipment_Type VALUES (2, 'Helmet', 'Protective combat helmet.', 'Gear');
INSERT INTO Equipment_Type VALUES (3, 'Radio', 'Tactical communication device.', 'Communication');

-- Armored_Vehicle
INSERT INTO Armored_Vehicle VALUES (1, 'TigerX', 2018, '2024-03-01', '2024-09-01', 1, 1);
INSERT INTO Armored_Vehicle VALUES (2, 'PantherZ', 2020, '2024-02-15', '2024-08-15', 2, 2);
INSERT INTO Armored_Vehicle VALUES (3, 'RhinoM', 2017, '2024-01-10', '2024-07-10', 3, 3);

-- Maintenance
INSERT INTO Maintenance VALUES (1, '2024-03-01', '2024-09-01', 'Oil change and diagnostics.');
INSERT INTO Maintenance VALUES (2, '2024-02-15', '2024-08-15', 'Brake replacement.');
INSERT INTO Maintenance VALUES (3, '2024-01-10', '2024-07-10', 'Engine tune-up.');

-- Personnel
INSERT INTO Personnel VALUES (1, 'John', 'Smith', '1980-07-12');
INSERT INTO Personnel VALUES (2, 'Alice', 'Brown', '1985-09-22');
INSERT INTO Personnel VALUES (3, 'Mike', 'Johnson', '1990-11-05');

-- Commander
INSERT INTO Commander VALUES (1, 'Senior Commander', 15);
INSERT INTO Commander VALUES (2, 'Field Leader', 10);
INSERT INTO Commander VALUES (3, 'Squad Leader', 8);

-- Vehicle_Part
INSERT INTO Vehicle_Part VALUES (101, 'Engine Block', 1);
INSERT INTO Vehicle_Part VALUES (102, 'Left Tread', 2);
INSERT INTO Vehicle_Part VALUES (103, 'Turret', 3);

-- Undergoes
INSERT INTO Undergoes VALUES ('Routine check', 5, 1, 1);
INSERT INTO Undergoes VALUES ('Brake system overhaul', 8, 2, 2);
INSERT INTO Undergoes VALUES ('Engine calibration', 6, 3, 3);

-- Problem_With
INSERT INTO Problem_With VALUES ('2024-03-01', 300.00, 1, 101, 1);
INSERT INTO Problem_With VALUES ('2024-02-15', 450.00, 2, 102, 2);
INSERT INTO Problem_With VALUES ('2024-01-10', 700.00, 3, 103, 3);

-- Unit
INSERT INTO Unit VALUES (1, 'Alpha Team', 'North Base', 1);
INSERT INTO Unit VALUES (2, 'Bravo Squad', 'East Depot', 2);
INSERT INTO Unit VALUES (3, 'Charlie Platoon', 'South Bunker', 3);

-- Soldier
INSERT INTO Soldier VALUES (1, 'Sergeant', '2010-01-15', 1);
INSERT INTO Soldier VALUES (2, 'Corporal', '2012-04-10', 2);
INSERT INTO Soldier VALUES (3, 'Private', '2015-06-22', 3);

-- Soldier_Mission_Assignment
INSERT INTO Soldier_Mission_Assignment VALUES ('Sniper', '2023-01-01', '2023-12-31', 1, 1);
INSERT INTO Soldier_Mission_Assignment VALUES ('Scout', '2023-02-01', '2023-12-31', 2, 2);
INSERT INTO Soldier_Mission_Assignment VALUES ('Medic', '2023-03-01', '2023-12-31', 3, 3);

-- Unit_Mission_Assignment
INSERT INTO Unit_Mission_Assignment VALUES ('2023-01-01', 1, 1);
INSERT INTO Unit_Mission_Assignment VALUES ('2023-02-01', 2, 2);
INSERT INTO Unit_Mission_Assignment VALUES ('2023-03-01', 3, 3);

-- Equipment
INSERT INTO Equipment VALUES (1, 'M16 Rifle', '2020-01-01', '2025-01-01', 1, 1);
INSERT INTO Equipment VALUES (2, 'Kevlar Helmet', '2021-02-10', '2026-02-10', 2, 2);
INSERT INTO Equipment VALUES (3, 'Motorola Radio', '2022-03-15', '2027-03-15', 3, 3);

-- Soldier_Equipment_Use
INSERT INTO Soldier_Equipment_Use VALUES ('2023-01-01', '2023-06-01', 1, 1);
INSERT INTO Soldier_Equipment_Use VALUES ('2023-01-15', '2023-07-15', 2, 2);
INSERT INTO Soldier_Equipment_Use VALUES ('2023-02-01', '2023-08-01', 3, 3);

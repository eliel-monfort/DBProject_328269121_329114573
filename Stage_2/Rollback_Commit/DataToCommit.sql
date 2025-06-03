-- Deployment of New Combat Unit named "Sayeret Matkal" with Full Operational Assignment

BEGIN;

-- Insert a new commander
INSERT INTO Personnel (personnel_ID, first_name, last_name, date_of_birth)
VALUES (1001, 'Daniel', 'Levi', '1980-05-15');

INSERT INTO Commander (command_level, years_of_experience, personnel_ID)
VALUES ('Company Commander', 15, 1001);

-- Create a new unit with the new commander (unit ID 269)
INSERT INTO Unit (unit_ID, unit_name, base_location, personnel_ID)
VALUES (269, 'Sayeret Matkal', 'Northern Base', 1001);

-- Insert 12 new soldiers assigned to unit
INSERT INTO Personnel (personnel_ID, first_name, last_name, date_of_birth) VALUES
(2001, 'Noam', 'Cohen', '2003-01-01'),
(2002, 'Yossi', 'Mizrahi', '2002-03-12'),
(2003, 'Avi', 'Shalom', '2001-07-24'),
(2004, 'Idan', 'Barak', '2002-11-30'),
(2005, 'Eli', 'Peretz', '2003-05-06'),
(2006, 'Ron', 'Biton', '2001-09-09'),
(2007, 'Tal', 'BenDavid', '2002-12-21'),
(2008, 'Lior', 'Sharabi', '2003-08-14'),
(2009, 'Omer', 'Avrahami', '2003-02-28'),
(2010, 'Shay', 'Mor', '2001-10-10'),
(2011, 'Tomer', 'Halevi', '2003-04-18'),
(2012, 'Gal', 'Dayan', '2002-06-22');

INSERT INTO Soldier (personnel_ID, rank, enlistment_date, unit_ID) VALUES
(2001, 'Private', '2022-01-10', 269),
(2002, 'Private', '2022-01-10', 269),
(2003, 'Private', '2022-01-10', 269),
(2004, 'Private', '2022-01-10', 269),
(2005, 'Private', '2022-01-10', 269),
(2006, 'Private', '2022-01-10', 269),
(2007, 'Private', '2022-01-10', 269),
(2008, 'Private', '2022-01-10', 269),
(2009, 'Private', '2022-01-10', 269),
(2010, 'Private', '2022-01-10', 269),
(2011, 'Private', '2022-01-10', 269),
(2012, 'Private', '2022-01-10', 269);

-- Assign the unit to a mission
INSERT INTO Mission (mission_ID, mission_name, location, objective)
VALUES (600, 'Border Patrol Operation', 'Northern Zone', 'Secure border perimeter and monitor activity.');

INSERT INTO Unit_Mission_Assignment (assigned_date, mission_ID, unit_ID)
VALUES (CURRENT_DATE, 600, 269);

-- Assign each soldier to the mission
INSERT INTO Soldier_Mission_Assignment (role, join_date, leave_date, mission_ID, personnel_ID) VALUES
('Patrol', CURRENT_DATE, NULL, 600, 2001),
('Patrol', CURRENT_DATE, NULL, 600, 2002),
('Patrol', CURRENT_DATE, NULL, 600, 2003),
('Patrol', CURRENT_DATE, NULL, 600, 2004),
('Patrol', CURRENT_DATE, NULL, 600, 2005),
('Patrol', CURRENT_DATE, NULL, 600, 2006),
('Patrol', CURRENT_DATE, NULL, 600, 2007),
('Patrol', CURRENT_DATE, NULL, 600, 2008),
('Patrol', CURRENT_DATE, NULL, 600, 2009),
('Patrol', CURRENT_DATE, NULL, 600, 2010),
('Patrol', CURRENT_DATE, NULL, 600, 2011),
('Patrol', CURRENT_DATE, NULL, 600, 2012);

-- Add new equipment type for weapons
INSERT INTO Equipment_Type (type_ID, type_name, description, category)
VALUES (550, 'Weapon', 'Standard IDF infantry weapons', 'Firearms');

-- Inserting new weapons
INSERT INTO Equipment (equipment_ID, name, purchase_date, warehouse_ID, type_ID) VALUES
(501, 'M16 Assault Rifle', '2023-01-10', 1, 550),
(502, 'Tavor X95', '2023-02-15', 1, 550),
(503, 'Negev LMG', '2023-03-05', 1, 550),
(504, 'MAG 58 Machine Gun', '2023-04-20', 1, 550),
(505, 'CornerShot', '2023-05-01', 1, 1),
(506, 'M24 Sniper Rifle', '2023-05-22', 1, 550),
(507, 'Mossberg 500 Shotgun', '2023-06-10', 1, 550),
(508, 'Uzi SMG', '2023-06-25', 1, 550),
(509, 'Jericho 941 Pistol', '2023-07-12', 1, 550),
(510, 'M203 Grenade Launcher', '2023-08-03', 1, 550),
(511, 'M4 Carbine', '2023-08-20', 1, 550),
(512, 'RPG-7', '2023-09-01', 1, 550);

-- Assign Weapons to each Soldier with use_end after 6 months
INSERT INTO Soldier_Equipment_Use (use_start, use_end, personnel_ID, equipment_ID) VALUES
(CURRENT_DATE, CURRENT_DATE + INTERVAL '6 months', 2001, 501),
(CURRENT_DATE, CURRENT_DATE + INTERVAL '6 months', 2002, 502),
(CURRENT_DATE, CURRENT_DATE + INTERVAL '6 months', 2003, 503),
(CURRENT_DATE, CURRENT_DATE + INTERVAL '6 months', 2004, 504),
(CURRENT_DATE, CURRENT_DATE + INTERVAL '6 months', 2005, 505),
(CURRENT_DATE, CURRENT_DATE + INTERVAL '6 months', 2006, 506),
(CURRENT_DATE, CURRENT_DATE + INTERVAL '6 months', 2007, 507),
(CURRENT_DATE, CURRENT_DATE + INTERVAL '6 months', 2008, 508),
(CURRENT_DATE, CURRENT_DATE + INTERVAL '6 months', 2009, 509),
(CURRENT_DATE, CURRENT_DATE + INTERVAL '6 months', 2010, 510),
(CURRENT_DATE, CURRENT_DATE + INTERVAL '6 months', 2011, 511),
(CURRENT_DATE, CURRENT_DATE + INTERVAL '6 months', 2012, 512);

-- Insert 4 new armored vehicles and assign them to the mission
INSERT INTO Armored_Vehicle (vehicle_ID, model, manufacture_year, last_maintenance_date, next_maintenance_date, warehouse_ID, mission_ID) VALUES
(651, 'Merkava Mk4', 2019, '2024-01-01', '2025-01-01', 1, 600),
(652, 'Namer APC', 2020, '2024-02-01', '2025-02-01', 1, 600),
(653, 'Eitan AFV', 2021, '2024-03-01', '2025-03-01', 1, 600),
(654, 'Puma CEV', 2018, '2024-04-01', '2025-04-01', 1, 600);

-- Assign the 4 armored vehicles to the mission
UPDATE Armored_Vehicle
SET mission_ID = 600
WHERE vehicle_ID IN (651, 652, 653, 654);

-- Register Basic Maintenance for Each Vehicle
INSERT INTO Maintenance (maintenance_ID, performed_on, next_due, description) VALUES
(501, '2024-01-01', '2025-01-01', 'Initial inspection for Merkava Mk4'),
(502, '2024-02-01', '2025-02-01', 'Initial inspection for Namer APC'),
(503, '2024-03-01', '2025-03-01', 'Initial inspection for Eitan AFV'),
(504, '2024-04-01', '2025-04-01', 'Initial inspection for Puma CEV');

INSERT INTO Undergoes (notes, duration_hours, maintenance_ID, vehicle_ID) VALUES
('Passed full inspection', 4, 501, 651),
('Passed full inspection', 4, 502, 652),
('Passed full inspection', 4, 503, 653),
('Passed full inspection', 4, 504, 654);

COMMIT;
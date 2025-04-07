-- Warehouse
INSERT INTO Warehouse VALUES (1, 'Base A', 200, '2015-03-01', '2023-12-15');
INSERT INTO Warehouse VALUES (2, 'Base B', 150, '2016-07-12', '2024-01-22');
INSERT INTO Warehouse VALUES (3, 'Base C', 300, '2018-10-20', '2023-11-01');

-- Mission
INSERT INTO Mission VALUES (101, 'Desert Storm', 'Southern Front', 'Secure the area');
INSERT INTO Mission VALUES (102, 'Iron Shield', 'Northern Border', 'Defend base');
INSERT INTO Mission VALUES (103, 'Mountain Watch', 'Eastern Hills', 'Surveillance');

-- Equipment_Type
INSERT INTO Equipment_Type VALUES (1, 'Radio', 'Communication device', 'Electronics');
INSERT INTO Equipment_Type VALUES (2, 'Rifle', 'Infantry weapon', 'Weapons');
INSERT INTO Equipment_Type VALUES (3, 'Helmet', 'Protective gear', 'Armor');

-- Armored_Vehicle
INSERT INTO Armored_Vehicle VALUES (201, 'Merkava IV', 2019, '2024-01-01', '2024-07-01', 1, 101);
INSERT INTO Armored_Vehicle VALUES (202, 'Namer', 2020, '2023-11-10', '2024-06-10', 2, NULL);
INSERT INTO Armored_Vehicle VALUES (203, 'Eitan', 2021, '2023-12-20', '2024-08-01', 3, 102);

-- Maintenance
INSERT INTO Maintenance VALUES (301, '2024-01-01', '2024-07-01', 'Routine check');
INSERT INTO Maintenance VALUES (302, '2023-12-20', '2024-06-20', 'Engine repair');
INSERT INTO Maintenance VALUES (303, '2023-11-10', '2024-05-10', 'Track replacement');

-- Personnel
INSERT INTO Personnel VALUES (401, 'Daniel', 'Levi', '1995-08-20');
INSERT INTO Personnel VALUES (402, 'Yael', 'Cohen', '1998-12-15');
INSERT INTO Personnel VALUES (403, 'Avi', 'Mizrahi', '1992-03-10');

-- Commander
INSERT INTO Commander VALUES (1, 15, 401);
INSERT INTO Commander VALUES (2, 12, 402);
INSERT INTO Commander VALUES (3, 18, 403);

-- Vehicle_Part
INSERT INTO Vehicle_Part VALUES (501, 'Engine', 5000, '2024-01-01', 201);
INSERT INTO Vehicle_Part VALUES (502, 'Track', 3000, '2023-11-10', 202);
INSERT INTO Vehicle_Part VALUES (503, 'Radio Unit', 1500, '2023-12-20', 203);

-- Undergoes
INSERT INTO Undergoes VALUES ('All OK', 5, 301, 201);
INSERT INTO Undergoes VALUES ('Fixed engine', 6, 302, 202);
INSERT INTO Undergoes VALUES ('Track replaced', 4, 303, 203);

-- Problem_With
INSERT INTO Problem_With VALUES (301, 501, 201);
INSERT INTO Problem_With VALUES (302, 502, 202);
INSERT INTO Problem_With VALUES (303, 503, 203);

-- Unit
INSERT INTO Unit VALUES (601, 'Bravo', 'Base A', 401);
INSERT INTO Unit VALUES (602, 'Alpha', 'Base B', 402);
INSERT INTO Unit VALUES (603, 'Echo', 'Base C', 403);

-- Soldier
INSERT INTO Soldier VALUES ('Lieutenant', '2015-07-01', 401, 601);
INSERT INTO Soldier VALUES ('Captain', '2016-09-15', 402, 602);
INSERT INTO Soldier VALUES ('Major', '2014-03-21', 403, 603);

-- Soldier_Mission_Assignment
INSERT INTO Soldier_Mission_Assignment VALUES ('Leader', '2024-01-01', '2024-02-01', 101, 401);
INSERT INTO Soldier_Mission_Assignment VALUES ('Scout', '2024-01-05', '2024-01-20', 102, 402);
INSERT INTO Soldier_Mission_Assignment VALUES ('Driver', '2024-02-01', '2024-03-01', 103, 403);

-- Unit_Mission_Assignment
INSERT INTO Unit_Mission_Assignment VALUES ('2024-01-01', 101, 601);
INSERT INTO Unit_Mission_Assignment VALUES ('2024-01-05', 102, 602);
INSERT INTO Unit_Mission_Assignment VALUES ('2024-02-01', 103, 603);

-- Equipment
INSERT INTO Equipment VALUES (701, 'Motorola XTS', '2021-01-01', '2026-01-01', 1, 401, 1);
INSERT INTO Equipment VALUES (702, 'Tavor X95', '2022-06-01', '2027-06-01', 2, 402, 2);
INSERT INTO Equipment VALUES (703, 'Advanced Helmet', '2020-03-15', '2025-03-15', 3, 403, 3);
from faker import Faker
from datetime import timedelta
import pandas as pd
import random
import os


# Helper function to create and write content to a file in the DataFiles directory
def file_creator(filename, content):
    os.makedirs("SQL_Insert_Files", exist_ok=True)
    full_path = os.path.join("SQL_Insert_Files", filename)
    with open(full_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"{filename} created successfully.")


# Generate SQL insert statements for the Equipment table with realistic data
def generate_equipment_sql(filename="Equipment.sql"):
    fake = Faker()
    random.seed(42)

    # Sample equipment names
    equipment_names = [
        "Night Vision Goggles", "Thermal Scope", "Ballistic Helmet", "Tactical Radio", "Body Armor",
        "Portable Generator", "Field Laptop", "Combat Drone", "Laser Rangefinder", "Satellite Phone",
        "Gas Mask", "Tactical Flashlight", "Weapon Sight", "Signal Jammer", "Ammunition Case",
        "First Aid Kit", "Combat Boots", "Hydration System", "Binoculars", "Tactical Backpack",
        "Drone Controller", "Kevlar Gloves", "Tactical Belt", "Range Card", "Combat Tent",
        "Field Rations Pack", "Modular Vest", "Portable Surveillance Kit", "Tactical Map Board",
        "Radio Encryption Device", "Camouflage Netting", "Breaching Tool Kit", "Explosive Detector",
        "Mine Detector", "Laser Target Designator", "Satellite Uplink Kit", "Power Bank", 
        "Field Repair Kit", "Climbing Rope", "Camouflage Uniform", "Thermal Blanket", 
        "Tactical Knee Pads", "Portable Medical Scanner", "Riot Shield", "Field Desk",
        "Advanced Weapon Optics", "Tactical Ear Protection", "Explosives Case"
    ]

    insert_commands = ""
    for i in range(1, 501):
        equipment_ID = i
        name = random.choice(equipment_names)
        purchase_date = fake.date_between(start_date='-10y', end_date='-1y')
        warranty_years = random.randint(1, 5)
        warranty_expiration = purchase_date + timedelta(days=365 * warranty_years)
        warehouse_ID = random.randint(1, 500)
        type_ID = random.randint(1, 500)

        insert_commands += (
            f"INSERT INTO Equipment (equipment_ID, name, purchase_date, warranty_expiration, warehouse_ID, type_ID)\n"
            f"VALUES ({equipment_ID}, '{name}', '{purchase_date}', '{warranty_expiration}', {warehouse_ID}, {type_ID});\n"
            "\n"
        )

    file_creator(filename, insert_commands)


# Generate SQL insert statements for the Undergoes table
def generate_undergoes_sql(filename="Undergoes.sql"):
    fake = Faker()
    random.seed(42)

    insert_commands = ""
    for _ in range(500):
        notes = fake.paragraph(nb_sentences=2)
        duration_hours = random.randint(1, 24)
        maintenance_ID = random.randint(1, 500)
        vehicle_ID = random.randint(1, 500)

        insert_commands += (
            f"INSERT INTO Undergoes (notes, duration_hours, maintenance_ID, vehicle_ID)\n"
            f"VALUES ('{notes}', {duration_hours}, {maintenance_ID}, {vehicle_ID});\n"
            "\n"
        )

    file_creator(filename, insert_commands)


# Generate SQL insert statements for the Problem_With table
def generate_problem_with_sql(filename="Problem_With.sql"):
    fake = Faker()
    random.seed(42)

    # Read valid part-vehicle pairs from Vehicle_Part.csv
    df = pd.read_csv("Vehicle_Part.csv")
    valid_pairs = list(zip(df["part_ID"], df["vehicle_ID"]))

    insert_commands = ""
    for _ in range(500):
        replaced_on = fake.date_between(start_date='-10y', end_date='today')
        cost_of_repair = round(random.uniform(100.00, 5000.00), 2)
        maintenance_ID = random.randint(1, 500)
        part_ID, vehicle_ID = random.choice(valid_pairs)

        insert_commands += (
            f"INSERT INTO Problem_With (replaced_on, cost_of_repair, maintenance_ID, part_ID, vehicle_ID)\n"
            f"VALUES ('{replaced_on}', {cost_of_repair}, {maintenance_ID}, {part_ID}, {vehicle_ID});\n\n"
        )

    file_creator(filename, insert_commands)


# Generate SQL insert statements for Soldier_Mission_Assignment using data from Soldier.csv
def generate_soldier_mission_assignment_sql(filename="Soldier_Mission_Assignment.sql"):
    fake = Faker()
    random.seed(42)

    """
    Generate an SQL file for the Soldier_Mission_Assignment table with realistic and randomized data.
    Reads valid personnel_IDs from an existing Soldier.csv file.
    """
    soldier_csv_path = "Soldier.csv"
    if not os.path.exists(soldier_csv_path):
        raise FileNotFoundError(f"Cannot find the file: {soldier_csv_path}")

    soldier_df = pd.read_csv(soldier_csv_path)
    if "personnel_ID" not in soldier_df.columns:
        raise ValueError("Soldier.csv must contain a 'personnel_ID' column.")

    personnel_ids = soldier_df["personnel_ID"].tolist()

    # Predefined list of realistic military roles
    roles = [
        "Sniper", "Medic", "Engineer", "Radio Operator", "Squad Leader", "Scout",
        "Heavy Weapons Specialist", "Recon Specialist", "Explosives Expert", "Rifleman",
        "Driver", "Tank Gunner", "Logistics Officer", "Drone Operator", "Field Technician"
    ]

    insert_commands = ""
    for _ in range(500):
        role = random.choice(roles)
        join_date = fake.date_between(start_date='-5y', end_date='-1y')
        leave_date = join_date + timedelta(days=random.randint(30, 730))
        mission_ID = random.randint(1, 500)
        personnel_ID = random.choice(personnel_ids)

        insert_commands += (
            "INSERT INTO Soldier_Mission_Assignment (role, join_date, leave_date, mission_ID, personnel_ID)\n"
            f"VALUES ('{role}', '{join_date}', '{leave_date}', {mission_ID}, {personnel_ID});\n"
            "\n"
        )

    file_creator(filename, insert_commands)


# Generate SQL insert statements for Unit_Mission_Assignment table
def generate_unit_mission_assignment_sql(filename="Unit_Mission_Assignment.sql"):
    fake = Faker()
    random.seed(42)

    insert_commands = ""
    for _ in range(500):
        assigned_date = fake.date_between(start_date='-5y', end_date='today')
        mission_ID = random.randint(1, 500)
        unit_ID = random.randint(1, 500)

        insert_commands += (
            "INSERT INTO Unit_Mission_Assignment (assigned_date, mission_ID, unit_ID)\n"
            f"VALUES ('{assigned_date}', {mission_ID}, {unit_ID});\n\n"
        )

    file_creator(filename, insert_commands)


# Generate SQL insert statements for Soldier_Equipment_Use with unique equipment_IDs
def generate_soldier_equipment_use_sql(filename="Soldier_Equipment_Use.sql"):
    fake = Faker()
    random.seed(42)

    # Load valid personnel_IDs from Soldier.csv
    soldier_csv_path = "Soldier.csv"
    if not os.path.exists(soldier_csv_path):
        raise FileNotFoundError(f"Cannot find the file: {soldier_csv_path}")
    
    soldier_df = pd.read_csv(soldier_csv_path)
    if "personnel_ID" not in soldier_df.columns:
        raise ValueError("Soldier.csv must contain a 'personnel_ID' column.")

    valid_personnel_ids = soldier_df["personnel_ID"].tolist()

    # Get 500 unique equipment IDs
    equipment_ids = random.sample(range(1, 501), 500)

    insert_commands = ""
    for i in range(500):
        use_start = fake.date_between(start_date='-3y', end_date='-30d')
        use_end = use_start + timedelta(days=random.randint(1, 180))
        personnel_ID = random.choice(valid_personnel_ids)  # Use only valid IDs
        equipment_ID = equipment_ids[i]

        insert_commands += (
            "INSERT INTO Soldier_Equipment_Use (use_start, use_end, personnel_ID, equipment_ID)\n"
            f"VALUES ('{use_start}', '{use_end}', {personnel_ID}, {equipment_ID});\n\n"
        )

    file_creator(filename, insert_commands)


# Generate SQL insert statements for Vehicle_Mission_Assignment with unique vehicle_IDs
def generate_vehicle_mission_assignment_sql(filename="Vehicle_Mission_Assignment.sql"):
    random.seed(42)

    vehicle_ids = random.sample(range(1, 501), 500)

    insert_commands = ""
    for i in range(500):
        vehicle_ID = vehicle_ids[i]
        mission_ID = random.randint(1, 500)

        insert_commands += (
            "INSERT INTO Vehicle_Mission_Assignment (vehicle_ID, mission_ID)\n"
            f"VALUES ({vehicle_ID}, {mission_ID});\n"
            "\n"
        )

    file_creator(filename, insert_commands)


# Call all generation functions to create the SQL files
generate_equipment_sql()
generate_undergoes_sql()
generate_problem_with_sql()
generate_soldier_mission_assignment_sql()
generate_unit_mission_assignment_sql()
generate_soldier_equipment_use_sql()
generate_vehicle_mission_assignment_sql()
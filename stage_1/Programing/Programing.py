import os
import pandas as pd
import random
from faker import Faker

# Create output directory
output_dir = "sql_inserts"
os.makedirs(output_dir, exist_ok=True)

fake = Faker()
num_records = 500

# Armored_Vehicle
def generate_armored_vehicle(i):
    return {
        "vehicle_id": i,
        "model": f"Model_{random.randint(100, 999)}",
        "year_of_manufacture": random.randint(1990, 2023),
        "last_maintenance_date": fake.date_between(start_date='-5y', end_date='-1y'),
        "next_maintenance_date": fake.date_between(start_date='today', end_date='+2y'),
        "mission_id": random.randint(1, 100)
    }

# Soldier
def generate_soldier(i):
    return {
        "soldier_id": i,
        "first_name": fake.first_name(),
        "last_name": fake.last_name(),
        "rank": random.choice(["Private", "Sergeant", "Lieutenant", "Captain"]),
        "date_of_birth": fake.date_of_birth(minimum_age=18, maximum_age=45),
        "enlistment_date": fake.date_between(start_date='-5y', end_date='today')
    }

# Soldier_Mission
def generate_soldier_mission(i):
    return {
        "soldier_id": random.randint(1, 500),
        "mission_id": random.randint(1, 100),
        "role": random.choice(["Scout", "Driver", "Gunner", "Commander"]),
        "join_date": fake.date_between(start_date='-3y', end_date='-1y'),
        "leave_date": fake.date_between(start_date='-1y', end_date='today')
    }

# Maintenance
def generate_maintenance(i):
    return {
        "maintenance_id": i,
        "performed_on": fake.date_between(start_date='-3y', end_date='-1y'),
        "next_due": fake.date_between(start_date='today', end_date='+2y'),
        "description": fake.sentence(nb_words=5)
    }

# Table mapping
tables = {
    "Armored_Vehicle": generate_armored_vehicle,
    "Soldier": generate_soldier,
    "Soldier_Mission": generate_soldier_mission,
    "Maintenance": generate_maintenance
}

# Generate INSERT statements and save to .sql files
for table_name, generator in tables.items():
    inserts = []
    for i in range(1, num_records + 1):
        row = generator(i)
        values = []
        for value in row.values():
            if isinstance(value, str):
                values.append(f"'{value}'")
            elif isinstance(value, pd.Timestamp):
                values.append(f"'{value.date()}'")
            elif isinstance(value, (int, float)):
                values.append(str(value))
            else:
                values.append(f"'{value}'")
        values_str = ", ".join(values)
        insert_stmt = f"INSERT INTO {table_name} VALUES ({values_str});"
        inserts.append(insert_stmt)

    output_path = os.path.join(output_dir, f"{table_name}.sql")
    with open(output_path, "w", encoding="utf-8") as f:
        f.write("\n".join(inserts))

print(f"INSERT scripts were successfully generated in the '{output_dir}' folder.")

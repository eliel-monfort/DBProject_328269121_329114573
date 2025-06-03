ALTER TABLE Warehouse
ADD CONSTRAINT chk_capacity_positive
CHECK (capacity > 10);
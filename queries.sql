-- Creating Tables

-- Users table
CREATE TABLE users (
  user_id serial primary key,
  customer_name varchar(50),
  email varchar(50) unique,
  password text,
  phone varchar(20),
  role varchar(10) check (role in ('Admin', 'Customer'))
)

-- Vehicles table
CREATE TABLE vehicles(
  vehicle_id SERIAL PRIMARY KEY,
  vehicle_name VARCHAR(50),
  type VARCHAR(6) CHECK (type IN ('car', 'bike', 'truck')),
  model VARCHAR(5),
  registration_number VARCHAR(8) UNIQUE,
  rental_price INT CHECK (rental_price > 0),
  status VARCHAR(15) CHECK (status IN ('available', 'rented', 'maintenance'))
)

-- Bookings table  
CREATE TABLE bookings(
  booking_id SERIAL PRIMARY KEY,
  user_id SERIAL,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  vehicle_id SERIAL,
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE CASCADE,
  start_date DATE NOT NULL,
  end_date DATE CHECK (end_date IS NULL OR end_date >= start_date),
  status VARCHAR(15) CHECK (status IN ('completed', 'pending', 'confirmed', 'cancelled')),
  total_cost INT CHECK (total_cost >= 0)
)

-- Inserting into tables

-- Users table
INSERT INTO users(customer_name, email, phone, role)
VALUES ('Alice', 'alice@example.com', '1234567890', 'Customer'),
('Bob', 'bob@example.com', '0987654321', 'Admin'),
('Charlie', 'charlie@example.com', '1122334455', 'Customer')

-- Vehicles table
INSERT INTO vehicles(vehicle_name, type, model, registration_number, rental_price, status)
VALUES
('Toyota Corolla', 'car', '2022', 'ABC-123', 50, 'available'),
('Honda Civic', 'car', '2021', 'DEF-456', 60, 'rented'),
('Yamaha R15', 'bike', '2023', 'GHI-789', 30, 'available'),
('Ford F-150', 'truck', '2020', 'JKL-012', 100, 'maintenance')

-- Bookings table
INSERT INTO bookings(user_id, vehicle_id, start_date, end_date, status, total_cost)
VALUES
(1, 2, '2023-10-01', '2023-10-05', 'completed', 240),
(1, 2, '2023-11-01', '2023-11-03', 'completed', 120),
(3, 2, '2023-12-01', '2023-12-02', 'confirmed', 60),
(1, 1, '2023-12-10', '2023-12-12', 'pending', 60)


-- JOIN: Retrieve booking information along with Customer name and Vehicle name.
SELECT
  b.booking_id,
  u.customer_name,
  v.vehicle_name,
  b.start_date,
  b.end_date,
  b.status
FROM
  bookings b
  JOIN users u ON b.user_id = u.user_id
  JOIN vehicles v ON b.vehicle_id = v.vehicle_id


-- EXISTS: Find all vehicles that have never been booked.
SELECT * FROM vehicles
WHERE 
  NOT EXISTS (
    SELECT * FROM bookings
    WHERE vehicle_id = vehicles.vehicle_id
  )



-- WHERE: Retrieve all available vehicles of a specific type (e.g. cars).
CREATE OR REPLACE FUNCTION find_vehicle_type (p_vehicle_type TEXT) RETURNS TABLE (
  vehicle_id INT,
  vehicle_name VARCHAR,
  vehicle_type VARCHAR,
  model VARCHAR,
  registration_number VARCHAR,
  rental_price INT,
  status VARCHAR
) LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY
  SELECT
    v.vehicle_id,
    v.vehicle_name,
    v.type,
    v.model,
    v.registration_number,
    v.rental_price,
    v.status
  FROM vehicles v
  WHERE v.type = p_vehicle_type;
END;
$$;

SELECT * FROM find_vehicle_type('truck');


-- GROUP BY and HAVING: Find the total number of bookings for each vehicle and display only those vehicles that have more than 2 bookings.
SELECT vehicle_name, COUNT(v.vehicle_id) AS total_bookings FROM bookings b
JOIN vehicles v ON b.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_name
HAVING COUNT(v.vehicle_id) > 2;

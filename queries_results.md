## Queries & Results

### Query 1: JOIN
**Requirement**: Retrieve booking information along with Customer name and Vehicle name.

**Code**:
```sql
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
  JOIN vehicles v ON b.vehicle_id = v.vehicle_id;
```

**Explanation**:
This query uses ```INNER JOIN``` to combine data from **bookings**, **users**, and **vehicles** tables.
It returns only records where matching ```user_id``` and ```vehicle_id``` exist, showing complete booking details including customer name and vehicle name.

**Output**:
| booking_id | customer_name | vehicle_name | start_date | end_date | status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | Alice | Honda Civic | 2023-10-01 | 2023-10-05 | completed |
| 2 | Alice | Honda Civic | 2023-11-01 | 2023-11-03 | completed |
| 3 | Charlie | Honda Civic | 2023-12-01 | 2023-12-02 | confirmed |
| 4 | Alice | Toyota Corolla | 2023-12-10 | 2023-12-12 | pending |

---

### Query 2: EXISTS
**Requirement**: Find all vehicles that have never been booked.

**Code**:
```sql
SELECT * FROM vehicles
WHERE 
  NOT EXISTS (
    SELECT * FROM bookings
    WHERE vehicle_id = vehicles.vehicle_id
  );
```

**Explanation**:
This query uses ```NOT EXISTS``` to find vehicles that do not have any matching record in the **bookings** table.
It returns vehicles that have never been booked. ```NOT EXISTS``` stops searching as soon as a match is found, making it efficient.


**Output**:
| vehicle_id | name | type | model | registration_number | rental_price | status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 3 | Yamaha R15 | bike | 2023 | GHI-789 | 30 | available |
| 4 | Ford F-150 | truck | 2020 | JKL-012 | 100 | maintenance |

---

### Query 3: WHERE
**Requirement**: Retrieve all available vehicles of a specific type (e.g. cars).

**Code**:
```sql
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
```

**Explanation**:
This **plpgSQL** function accepts a vehicle type as a parameter and returns a TABLE.
It uses **RETURN QUERY** to execute a ```SELECT``` statement that filters vehicles by type.
The function behaves like a table and can be queried using ```SELECT * FROM find_vehicle_type('truck');```.


**Output**:
| vehicle_id | name | type | model | registration_number | rental_price | status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | Toyota Corolla | car | 2022 | ABC-123 | 50 | available |

---

### Query 4: GROUP BY and HAVING
**Requirement**: Find the total number of bookings for each vehicle and display only those vehicles that have more than 2 bookings.

**Code**:
```sql
SELECT vehicle_name, COUNT(v.vehicle_id) AS total_bookings
FROM bookings b
JOIN vehicles v ON b.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_name
HAVING COUNT(v.vehicle_id) > 2;
```

**Explanation**:
This query uses ```GROUP BY``` to group bookings by vehicle name and ```COUNT``` to calculate total bookings per vehicle.
The ```HAVING``` clause filters the grouped results to return only vehicles with more than 2 bookings.

**Output**:
| vehicle_name | total_bookings |
| :--- | :--- |
| Honda Civic | 3 |

-- Train Schedule Lookup
DELIMITER $$
CREATE PROCEDURE TrainScheduleLookup(IN trainid INT)
BEGIN
    select * from Routes where tid = trainid;
END$$
DELIMITER ;

-- Check seat Availability
DROP FUNCTION IF EXISTS AvailableSeatQuery;
DELIMITER $$
CREATE FUNCTION AvailableSeatQuery(routeid INT, seat_num INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE ret INT DEFAULT 1;

    IF EXISTS (
        SELECT 1
        FROM Bookings
        NATURAL JOIN BookingsRoutes
        NATURAL JOIN Routes
        WHERE rid = routeid AND seat_number = seat_num
    ) THEN
        SET ret = 0;
    END IF;
    
    RETURN ret;
END$$
DELIMITER ;

-- List all passengers traveling on a specific train on a given date
DROP PROCEDURE IF EXISTS TrainDateQuery;
DELIMITER $$
CREATE PROCEDURE TrainDateQuery(IN train_id INT, IN d DATE)
BEGIN
    SELECT Customers.*
    FROM Customers
    NATURAL JOIN Bookings
    NATURAL JOIN BookingsRoutes
    NATURAL JOIN Routes
    WHERE tid = train_id
    AND DATE(departure) = d
    AND btype = 'normal';
END$$
DELIMITER ;

-- Total revenue generated from ticket bookings over a specified period (excluding RAC bookings)
DROP PROCEDURE IF EXISTS RevenuePeriod;
DELIMITER $$
CREATE PROCEDURE RevenuePeriod(IN s DATE, IN e DATE)
BEGIN
    SELECT SUM(amount) AS earning 
    FROM Bookings NATURAL JOIN Payments 
    WHERE time_of_booking BETWEEN s AND e
    AND btype = 'normal';
END$$
DELIMITER ;

-- Show all direct routes from city1 to city2
DROP PROCEDURE IF EXISTS FindDirectRoutes;
DELIMITER $$
CREATE PROCEDURE FindDirectRoutes(IN city1 varchar(40), IN city2 varchar(40))
BEGIN
    SELECT * FROM Routes WHERE origin = city1 AND dest = city2;
END$$
DELIMITER ;

-- Create a booking
DROP PROCEDURE IF EXISTS CreateBooking;
DELIMITER $$
CREATE PROCEDURE CreateBooking(
    IN _cid int,
    IN _pid INT,
    IN _ptype varchar(40),
    IN _amount INT,
    IN _btype varchar(40),
    IN _seat_class varchar(40),
    IN _seat_number varchar(40)
) BEGIN
    INSERT INTO Payments VALUES (_pid, _ptype, _amount);

    INSERT INTO
    Bookings    (cid, pid, btype, seat_class, seat_number, time_of_booking)
    VALUES      (_cid, _pid, _btype, _seat_class, _seat_number, now());
END$$
DELIMITER ;

-- Insert into BookingsRoutes
DROP PROCEDURE IF EXISTS InsertBookingRoute;
DELIMITER $$
CREATE PROCEDURE InsertBookingRoute(
    IN _pnr INT,
    IN _rid INT
) BEGIN
    INSERT INTO BookingsRoutes VALUES (_pnr, _rid);
END$$
DELIMITER ;

-- Insert into Trains
DROP PROCEDURE IF EXISTS InsertTrain;
DELIMITER $$
CREATE PROCEDURE InsertTrain(
    IN _first_class INT,
    IN _second_class INT
) BEGIN
    INSERT INTO
    Trains (
        first_class,
        second_class
    ) VALUES (
        _first_class,
        _second_class
    );
END$$
DELIMITER ;

-- Insert into Customers
DROP PROCEDURE IF EXISTS InsertCustomer;
DELIMITER $$
CREATE PROCEDURE InsertCustomer(IN _cname varchar(40), IN _concession_class varchar(40), IN _age INT)
BEGIN
    INSERT INTO Customers (cname, concession_class, age) VALUES (_cname, _concession_class, _age);
END$$
DELIMITER ;

-- Insert into Routes
DROP PROCEDURE IF EXISTS InsertRoute;
DELIMITER $$
CREATE PROCEDURE InsertRoute(
    IN _tid INT,
    IN _origin varchar(40), IN _dest varchar(40),
    IN _departure datetime, IN _arrival datetime
) BEGIN
    INSERT INTO
    Routes (
        tid,
        origin, dest,
        departure, arrival
    ) VALUES (
        _tid,
        _origin, _dest,
        _departure, _arrival
    );
END$$
DELIMITER ;

-- Cancellation
DROP PROCEDURE IF EXISTS CancelBooking;
DELIMITER $$
CREATE PROCEDURE CancelBooking(IN _pnr INT)
BEGIN
    INSERT INTO Cancellations
    SELECT * FROM Bookings
    WHERE pnr = _pnr;
    
    DELETE FROM Bookings
    WHERE pnr = _pnr;
END$$
DELIMITER ;

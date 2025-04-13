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
    SELECT IFNULL(SUM(amount),0) AS earning 
    FROM Bookings NATURAL JOIN Payments 
    WHERE time_of_booking BETWEEN s AND e
    AND btype = 'normal';
END$$
DELIMITER ;

-- Find Busiest Route based on passenger count excluding RAC
DROP FUNCTION IF EXISTS BusiestRoute;
DELIMITER $$
CREATE FUNCTION BusiestRoute()
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE ret INT;
    select rid into ret from 
    Routes NATURAL JOIN 
    BookingsRoutes NATURAL JOIN Bookings 
    where btype = 'normal' GROUP BY rid ORDER BY COUNT(pnr) DESC LIMIT 1;
    RETURN ret;
END $$
DELIMITER ;

-- Show all direct routes from city1 to city2
DROP PROCEDURE IF EXISTS FindDirectRoutes;
DELIMITER $$
CREATE PROCEDURE FindDirectRoutes(IN city1 varchar(40), IN city2 varchar(40))
BEGIN
    SELECT * FROM Routes WHERE origin = city1 AND dest = city2;
END$$
DELIMITER ;

-- Retrieve all waitlisted passengers for a particular train
DROP PROCEDURE IF EXISTS QueryRACCustomers;
DELIMITER $$
CREATE PROCEDURE QueryRACCustomers(IN _tid INT)
BEGIN
    SELECT Customers.*
    FROM Bookings
    NATURAL JOIN BookingsRoutes
    NATURAL JOIN Routes
    NATURAL JOIN Customers
    WHERE tid = _tid
    AND btype = 'rac';
END$$
DELIMITER ;

-- Find total amount that needs to be refunded for cancelling a train
DROP FUNCTION IF EXISTS GetTrainCancelTotalRefund;
DELIMITER $$
CREATE FUNCTION GetTrainCancelTotalRefund(_tid INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_refund INT;
    
    SELECT SUM(amount) INTO total_refund
    FROM Payments
    NATURAL JOIN Bookings
    NATURAL JOIN BookingsRoutes
    NATURAL JOIN Routes
    NATURAL JOIN Trains
    WHERE tid = _tid
    AND btype = 'normal';
    
    RETURN IFNULL(total_refund, 0);
END $$
DELIMITER ;

-- Cancellation records with refund status
DROP PROCEDURE IF EXISTS QueryCancellations;
DELIMITER $$
CREATE PROCEDURE QueryCancellations(IN refunded BOOL)
BEGIN
    SELECT * FROM Cancellations WHERE IF(refunded, refund_id IS NOT NULL, refund_id IS NULL);
END $$
DELIMITER ;

-- Generate an itemized bill for a ticket including all charges
DROP PROCEDURE IF EXISTS GenItemizedBill;
DELIMITER $$
CREATE PROCEDURE GenItemizedBill(IN _cid INT, IN _rid INT, IN _seat_class VARCHAR(40))
BEGIN
    DECLARE _concession_class VARCHAR(40);
    DECLARE _origin VARCHAR(40);
    DECLARE _dest VARCHAR(40);
    DECLARE _base_price INT;
    DECLARE concession_class_discount INT;
    DECLARE seat_class_discount INT;
    DECLARE final_price INT;

    SELECT concession_class INTO _concession_class FROM Customers WHERE cid = _cid;

    SELECT origin, dest, base_price INTO _origin, _dest, _base_price FROM Routes WHERE rid = _rid;

    SET concession_class_discount = CASE _concession_class
        WHEN 'general' THEN 0
        WHEN 'senior_citizen' THEN 10
        ELSE 0
    END;

    SET seat_class_discount = CASE _seat_class
        WHEN 'first_class' THEN 0
        WHEN 'second_class' THEN 10
        ELSE 0
    END;

    SET final_price = ROUND(((100 - (concession_class_discount + seat_class_discount)) * _base_price) / 100);

    SELECT
        _origin AS origin,
        _dest AS destination,
        _seat_class AS seat_class,
        _concession_class AS concession_class,
        _base_price AS base_price,
        seat_class_discount,
        concession_class_discount,
        final_price;
END$$
DELIMITER ;

-- Create a booking
DROP PROCEDURE IF EXISTS CreateBooking;
DELIMITER $$
CREATE PROCEDURE CreateBooking(
    IN _cid int,
    IN _pid VARCHAR(40),
    IN _ptype varchar(40),
    IN _amount INT,
    IN _btype varchar(40),
    IN _seat_class varchar(40),
    IN _seat_number varchar(40)
) BEGIN

    IF NOT EXISTS(select 1 from Payments where pid = _pid) THEN
        INSERT INTO Payments VALUES (_pid, _ptype, _amount);
    END IF;

    INSERT INTO
    Bookings    (cid, pid, btype, seat_class, seat_number, time_of_booking)
    VALUES      (_cid, _pid, _btype, _seat_class, _seat_number, now());

    SELECT LAST_INSERT_ID() AS pnr;
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
    IN _origin VARCHAR(40), IN _dest VARCHAR(40),
    IN _departure DATETIME, IN _arrival DATETIME,
    IN _base_price INT
) BEGIN
    INSERT INTO
    Routes (
        tid,
        origin, dest,
        departure, arrival,
        base_price
    ) VALUES (
        _tid,
        _origin, _dest,
        _departure, _arrival,
        _base_price
    );
END$$
DELIMITER ;

-- Bookings can be cancelled by simply deleting them from the table
DROP TRIGGER IF EXISTS AfterBookingsDelete;
DELIMITER $$
CREATE TRIGGER AfterBookingsDelete
BEFORE DELETE ON Bookings
FOR EACH ROW
BEGIN
    DECLARE earliest_departure DATETIME;
    
    SELECT MIN(departure)
    INTO earliest_departure
    FROM BookingsRoutes
    NATURAL JOIN Routes
    WHERE pnr = OLD.pnr;

    -- Eligible for refund
    IF TIMESTAMPDIFF(DAY, OLD.time_of_booking, earliest_departure) > 1 THEN
        INSERT INTO Cancellations SELECT OLD.*, NULL;
    END IF;

    DELETE FROM BookingsRoutes WHERE pnr = OLD.pnr;
END$$
DELIMITER ;

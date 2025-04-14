-- PNR status tracking for a given ticket
DROP PROCEDURE IF EXISTS QueryPNRStatus;
DELIMITER $$
CREATE PROCEDURE QueryPNRStatus(IN _pnr INT)
BEGIN
    DECLARE _cname VARCHAR(40);
    DECLARE _tname VARCHAR(40);

    SELECT cname INTO _cname
    FROM Bookings
    NATURAL JOIN Customers
    WHERE pnr = _pnr;

    SELECT tname INTO _tname
    FROM Bookings
    NATURAL JOIN BookingsRoutes
    NATURAL JOIN Routes
    NATURAL JOIN Trains
    WHERE pnr = _pnr LIMIT 1;

    SELECT
    pnr,
    _cname AS customer,
    _tname AS train,
    seat_class,
    seat_number,
    IF(btype = 'normal', 'booked', 'waitlisted') AS status
    FROM Bookings
    WHERE pnr = _pnr;
END$$
DELIMITER ;

-- Train schedule lookup for a given train
DROP PROCEDURE IF EXISTS QueryTrainSchedule;
DELIMITER $$
CREATE PROCEDURE QueryTrainSchedule(IN _tid INT)
BEGIN
    SELECT tname as train_name, origin, dest, departure, arrival
    FROM Routes
    NATURAL JOIN Trains
    WHERE tid = _tid;
END$$
DELIMITER ;

-- Available seats query for a specific route and seat number
DROP FUNCTION IF EXISTS GetRouteSeatAvailability;
DELIMITER $$
CREATE FUNCTION GetRouteSeatAvailability(_rid INT, _seat_number INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE ret INT DEFAULT 1;

    IF EXISTS (
        SELECT 1
        FROM Bookings
        NATURAL JOIN BookingsRoutes
        NATURAL JOIN Routes
        WHERE rid = _rid
        AND seat_number = _seat_number
    ) THEN
        SET ret = 0;
    END IF;

    RETURN ret;
END$$
DELIMITER ;

-- List all passengers traveling on a specific train on a given date
DROP PROCEDURE IF EXISTS QueryTrainDatePassengers;
DELIMITER $$
CREATE PROCEDURE QueryTrainDatePassengers(IN _tid INT, IN d DATE)
BEGIN
    SELECT Customers.*
    FROM Customers
    NATURAL JOIN Bookings
    NATURAL JOIN BookingsRoutes
    NATURAL JOIN Routes
    WHERE tid = _tid
    AND DATE(departure) = d
    AND btype = 'normal';
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
DROP FUNCTION IF EXISTS GetTrainCancellationTotalRefund;
DELIMITER $$
CREATE FUNCTION GetTrainCancellationTotalRefund(_tid INT)
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

-- Total revenue generated from ticket bookings over a specified period (excluding RAC bookings)
DROP FUNCTION IF EXISTS GetPeriodRevenue;
DELIMITER $$
CREATE FUNCTION GetPeriodRevenue(s DATE, e DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE revenue INT;

    SELECT SUM(amount) INTO revenue
    FROM Payments
    WHERE ptime BETWEEN s AND e;

    RETURN IFNULL(revenue, 0);
END$$
DELIMITER ;

-- Cancellation records with refund status
DROP PROCEDURE IF EXISTS QueryCancellations;
DELIMITER $$
CREATE PROCEDURE QueryCancellations(IN refunded BOOL)
BEGIN
    SELECT * FROM Cancellations WHERE IF(refunded, refund_id IS NOT NULL, refund_id IS NULL);
END $$
DELIMITER ;

-- Find Busiest Route based on passenger count
DROP FUNCTION IF EXISTS GetBusiestRoute;
DELIMITER $$
CREATE FUNCTION GetBusiestRoute()
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE ret INT;

    SELECT rid INTO ret
    FROM Routes
    NATURAL JOIN BookingsRoutes
    NATURAL JOIN Bookings
    WHERE btype = 'normal'
    GROUP BY rid
    ORDER BY COUNT(pnr)
    DESC LIMIT 1;

    RETURN ret;
END $$
DELIMITER ;

-- Generate an itemized bill for a ticket including all charges
DROP PROCEDURE IF EXISTS QueryItemizedBill;
DELIMITER $$
CREATE PROCEDURE QueryItemizedBill(IN _cid INT, IN _rid INT, IN _seat_class VARCHAR(40))
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



-- Check seat availability based on class
DROP FUNCTION IF EXISTS GetRouteClassNumAvailableSeats;
DELIMITER $$
CREATE FUNCTION GetRouteClassNumAvailableSeats(_rid INT, _seat_class VARCHAR(40))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE _first_class INT;
    DECLARE _second_class INT;

    DECLARE num_taken INT;

    SELECT first_class, second_class
    INTO _first_class, _second_class
    FROM Routes
    NATURAL JOIN Trains
    WHERE rid = _rid;

    SELECT COUNT(*) INTO num_taken
    FROM Bookings
    NATURAL JOIN BookingsRoutes
    WHERE rid = _rid
    AND btype = 'normal'
    AND seat_class = _seat_class;

    RETURN CASE _seat_class
        WHEN 'first_class' THEN _first_class - num_taken
        WHEN 'second_class' THEN _second_class - num_taken
        ELSE 0
    END;
END$$
DELIMITER ;

-- A trigger such that bookings can be cancelled by simply deleting them from the table
-- Refunds are associated with a negative entry in the Payments table
DROP TRIGGER IF EXISTS AfterBookingsDelete;
DELIMITER $$
CREATE TRIGGER AfterBookingsDelete
AFTER DELETE
ON Bookings FOR EACH ROW
BEGIN
    DECLARE refund_possible BOOL DEFAULT TRUE;
    DECLARE earliest_departure DATETIME;
    DECLARE done INT DEFAULT 0;
    DECLARE _pnr INT;

    DECLARE cur CURSOR FOR
    SELECT b.pnr
    FROM Bookings b
    JOIN BookingsRoutes br ON b.pnr = br.pnr
    WHERE b.btype = 'rac'
    AND b.seat_class = OLD.seat_class
    AND br.rid IN (SELECT rid FROM BookingsRoutes WHERE pnr = OLD.pnr)
    GROUP BY b.pnr
    ORDER BY MIN(b.time_of_booking);

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    IF OLD.btype = 'normal' THEN
        SELECT MIN(r.departure)
        INTO earliest_departure
        FROM BookingsRoutes br
        JOIN Routes r ON br.rid = r.rid
        WHERE br.pnr = OLD.pnr;

        IF TIMESTAMPDIFF(DAY, OLD.time_of_booking, earliest_departure) < 1 THEN
            SET refund_possible = FALSE;
        END IF;
    END IF;

    INSERT INTO Cancellations
    VALUES (
        OLD.pnr, OLD.cid, OLD.pid, OLD.btype, OLD.seat_class, OLD.seat_number, OLD.time_of_booking,
        IF(refund_possible, NULL, 'N/A')
    );

    -- Check for RAC openings
    IF OLD.btype = 'normal' THEN
        OPEN cur;

        rac_loop: LOOP
            FETCH cur INTO _pnr;

            IF done = 1 THEN
                LEAVE rac_loop;
            END IF;

            IF (
                SELECT MIN(GetRouteClassNumAvailableSeats(rid, OLD.seat_class))
                FROM BookingsRoutes
                WHERE pnr = _pnr
            ) > 0 THEN
                INSERT INTO RACPromotionQueue VALUES (_pnr, OLD.seat_number);
            END IF;
        END LOOP rac_loop;

        CLOSE cur;
    END IF;
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
    DECLARE _now DATETIME;
    SET _now = now();

    IF NOT EXISTS (
        SELECT 1 FROM Payments WHERE pid = _pid
    ) THEN
        INSERT INTO Payments VALUES (_pid, _ptype, _amount, _now);
    END IF;

    INSERT INTO
    Bookings    (cid, pid, btype, seat_class, seat_number, time_of_booking)
    VALUES      (_cid, _pid, _btype, _seat_class, _seat_number, _now);

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
    IN _tname VARCHAR(40),
    IN _first_class INT,
    IN _second_class INT
) BEGIN
    INSERT INTO
    Trains (
        tname,
        first_class,
        second_class
    ) VALUES (
        _tname,
        _first_class,
        _second_class
    );
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

-- Insert into Customers
DROP PROCEDURE IF EXISTS InsertCustomer;
DELIMITER $$
CREATE PROCEDURE InsertCustomer(IN _cname varchar(40), IN _concession_class varchar(40), IN _age INT)
BEGIN
    INSERT INTO Customers (cname, concession_class, age) VALUES (_cname, _concession_class, _age);
END$$
DELIMITER ;

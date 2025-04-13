-- Add Train
insert into Trains values(1,10,100),(2,15,150),(3,2,20);
-- Add Routes
insert into Routes values
(1,1,"Delhi","Agra","2025-03-03 11:11:11","2025-03-03 16:11:11"),
(2,1,"Agra","Delhi","2025-03-03 17:11:11","2025-03-03 22:11:11"),
(3,2,"Delhi","Kolkata","2025-03-03 10:20:20","2025-03-03 20:11:11");
-- Customers
insert into Customers values(1,"Ramesh","General",54),
(2,"Somu","General",14),
(3,"Grant","General",34);

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
CREATE FUNCTION AvailableSeatQuery(routeid INT,seat_num INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE ret INT DEFAULT 1;

    IF EXISTS (SELECT 1 FROM Bookings WHERE rid = routeid AND seat_number = seat_num) THEN
        SET ret = 0;
    END IF;
    
    RETURN ret;
END$$
DELIMITER ;

-- List all passengers traveling on a specific train on a given date
DROP PROCEDURE IF EXISTS TrainDateQuery;
DELIMITER $$
CREATE PROCEDURE TrainDateQuery(IN train_id INT,IN d DATE)
BEGIN
    select * from customers where cid in (select cid from Bookings where rid in (select rid from Routes where tid = train_id and DATEDIFF(departure,d) = 0));
END$$
DELIMITER ;

-- Total revenue generated from ticket bookings over a specified period
DROP PROCEDURE IF EXISTS RevenuePeriod;
DELIMITER $$
CREATE PROCEDURE RevenuePeriod(IN s DATE,IN e DATE)
BEGIN
    select sum(amount) as earning from Payments where pid in (select pid from Bookings where time_of_booking between s and e);
END$$
DELIMITER ;

-- Show all routes from city1 to city2
DROP PROCEDURE IF EXISTS FindRoutes;
DELIMITER $$
CREATE PROCEDURE FindRoutes(IN city1 varchar(40),IN city2 varchar(40))
BEGIN
    select * from routes where origin = city1 and dest = city2;
END$$
DELIMITER ;

-- ACTUALLY DO A BOOKING
DROP PROCEDURE IF EXISTS BookSeat;
DELIMITER $$
CREATE PROCEDURE BookSeat(  IN route_id INT,
                            IN seatnumber int,
                            IN cust_id INT,
                            IN payment_id varchar(40),
                            IN payment_type varchar(40),
                            IN payment_amount INT,
                            IN class varchar(40))
BEGIN
    IF AvailableSeatQuery(route_id,seatnumber) != 0
    THEN
        insert into Payments values (payment_id,payment_type,payment_amount);
        insert into Bookings(cid,rid,pid,seat_class,seat_number,time_of_booking) values(cust_id,route_id,payment_id,class,seatnumber,now());
    ELSE
        insert into Payments values (payment_id,payment_type,payment_amount);
        insert into WaitList(cid,rid,pid,seat_class,seat_number,time_of_booking) values(cust_id,route_id,payment_id,class,seatnumber,now());
    END IF;
END$$
DELIMITER ;

-- ADD A TRAIN
DROP PROCEDURE IF EXISTS AddTrain;
DELIMITER $$
CREATE PROCEDURE AddTrain(  IN train_id INT,IN first_class INT,IN second_class INT)
BEGIN
    insert into Trains values(train_id,first_class,second_class);
END$$
DELIMITER ;

-- ADD CUSTOMER
DROP PROCEDURE IF EXISTS AddCustomer;
DELIMITER $$
CREATE PROCEDURE AddCustomer(IN cname varchar(40),IN class varchar(40),IN cage INT)
BEGIN
    insert into Customers(name,consetion_class,age) values(cname,class,cage);
END$$
DELIMITER ;

-- ROUTE
DROP PROCEDURE IF EXISTS AddRoute;
DELIMITER $$
CREATE PROCEDURE AddRoute(  IN route_id INT,
                            IN tid INT,
                            IN origin varchar(40),IN dest varchar(40),
                            IN departure datetime,IN arrival datetime)
BEGIN
    insert into Routes values(route_id,tid,origin,dest,departure,arrival);
    insert into SeatsUsed values(route_id,0,0);
END$$
DELIMITER ;

-- Cancellation
CREATE PROCEDURE Cancel(IN PNR INT)
BEGIN
    DECLARE cid_copy INT;
    DECLARE rid_copy INT;
    DECLARE pid_copy VARCHAR(40);
    DECLARE seat_class_copy VARCHAR(40);
    DECLARE seat_number_copy VARCHAR(4);
    DECLARE time_of_booking_copy DATETIME;
    
    SELECT cid, rid, pid, seat_class, seat_number, time_of_booking
    INTO cid_copy, rid_copy, pid_copy, seat_class_copy, seat_number_copy, time_of_booking_copy
    FROM Bookings
    WHERE Bookings.PNR = PNR;
    INSERT INTO Cancelation (PNR, cid, rid, pid, seat_class, seat_number, time_of_booking)
    VALUES (PNR, cid_copy, rid_copy, pid_copy, seat_class_copy, seat_number_copy, time_of_booking_copy);
    DELETE FROM Bookings WHERE Bookings.PNR = PNR;
    DELETE FROM Payments where Payments.pid = pid_copy;
END$$

DELIMITER ;

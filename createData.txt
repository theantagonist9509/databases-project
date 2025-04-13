-- Trains
INSERT INTO Trains (tid, first_class, second_class) VALUES (101, 10, 50);
INSERT INTO Trains (tid, first_class, second_class) VALUES (102, 12, 60);
INSERT INTO Trains (tid, first_class, second_class) VALUES (103, 12, 45);
INSERT INTO Trains (tid, first_class, second_class) VALUES (104, 16, 70);
INSERT INTO Trains (tid, first_class, second_class) VALUES (105, 15, 55);

-- Routes
INSERT INTO Routes (rid, tid, origin, dest, departure, arrival) VALUES 
(200, 101, 'Mumbai', 'Delhi', '2025-04-15 08:30:00', '2025-04-16 10:45:00',400);
INSERT INTO Routes (rid, tid, origin, dest, departure, arrival) VALUES 
(201, 101, 'Delhi', 'Patna', '2025-04-16 10:55:00', '2025-04-16 22:55:00',500);

INSERT INTO Routes (rid, tid, origin, dest, departure, arrival) VALUES 
(210, 102, 'Chennai', 'Bangalore', '2025-04-16 15:00:00', '2025-04-16 19:30:00',400);
INSERT INTO Routes (rid, tid, origin, dest, departure, arrival) VALUES 
(211, 102,'Bangalore','Kolkata', '2025-04-16 19:40:00', '2025-04-17 01:10:00',200);
INSERT INTO Routes (rid, tid, origin, dest, departure, arrival) VALUES 
(212, 102,'Kolkata','Noida', '2025-04-17 01:10:00', '2025-04-17 10:40:00',200);
INSERT INTO Routes (rid, tid, origin, dest, departure, arrival) VALUES 
(213, 102,'Noida','Jaipur', '2025-04-17 10:55:00', '2025-04-17 19:10:00',100);


INSERT INTO Routes (rid, tid, origin, dest, departure, arrival) VALUES 
(223, 103, 'Kolkata', 'Hyderabad', '2025-04-17 22:15:00', '2025-04-18 12:45:00',500);

INSERT INTO Routes (rid, tid, origin, dest, departure, arrival) VALUES 
(234, 104, 'Delhi', 'Jaipur', '2025-04-18 07:00:00', '2025-04-18 12:30:00',900);

INSERT INTO Routes (rid, tid, origin, dest, departure, arrival) VALUES 
(245, 105, 'Bangalore', 'Mumbai', '2025-04-19 14:45:00', '2025-04-20 08:15:00',800);


-- Customers
INSERT INTO Customers (cid, name, consetion_class, age) VALUES (9,'Rahul Sharma', 'senior_citizen', 68);
INSERT INTO Customers (cid, name, consetion_class, age) VALUES (10,'Priya Singh', 'general', 22);
INSERT INTO Customers (cid, name, consetion_class, age) VALUES (11,'Amit Patel', 'general', 35);
INSERT INTO Customers (cid, name, consetion_class, age) VALUES (12,'Sunita Verma', 'senior_citizen', 72);
INSERT INTO Customers (cid, name, consetion_class, age) VALUES (13,'Karan Mehta', 'general', 45);

-- Payments
INSERT INTO Payments (pid, ptype, amount) VALUES ('PAY001', 'credit_card', 2500);
INSERT INTO Payments (pid, ptype, amount) VALUES ('PAY002', 'debit_card', 1200);
INSERT INTO Payments (pid, ptype, amount) VALUES ('PAY003', 'upi', 3600);
INSERT INTO Payments (pid, ptype, amount) VALUES ('PAY004', 'net_banking', 1850);
INSERT INTO Payments (pid, ptype, amount) VALUES ('PAY005', 'wallet', 950);

-- Bookings
INSERT INTO Bookings (pnr, cid, pid, btype, seat_class, seat_number, time_of_booking) VALUES 
(11,9, 'PAY001', 'normal', 'first_class', 5, '2025-04-10 09:15:22');
INSERT INTO Bookings (pnr,cid, pid, btype, seat_class, seat_number, time_of_booking) VALUES 
(12,10, 'PAY002', 'normal', 'second_class', 23, '2025-04-11 14:30:45');
INSERT INTO Bookings (pnr, cid, pid, btype, seat_class, seat_number, time_of_booking) VALUES 
(13,11, 'PAY003', 'rac', 'first_class', 8, '2025-04-12 18:20:33');
INSERT INTO Bookings (pnr, cid, pid, btype, seat_class, seat_number, time_of_booking) VALUES 
(14,12, 'PAY004', 'normal', 'second_class', 42, '2025-04-12 21:05:17');
INSERT INTO Bookings (pnr, cid, pid, btype, seat_class, seat_number, time_of_booking) VALUES 
(15,13, 'PAY005', 'normal', 'second_class', 45, '2025-04-13 11:45:50');

-- BookingsRoutes
INSERT INTO BookingsRoutes (pnr, rid) VALUES (11, 210);
INSERT INTO BookingsRoutes (pnr, rid) VALUES (11, 211);
INSERT INTO BookingsRoutes (pnr, rid) VALUES (11, 212);

INSERT INTO BookingsRoutes (pnr, rid) VALUES (12, 200);
INSERT INTO BookingsRoutes (pnr, rid) VALUES (12, 201);

INSERT INTO BookingsRoutes (pnr, rid) VALUES (13, 212);

INSERT INTO BookingsRoutes (pnr, rid) VALUES (14, 223);

INSERT INTO BookingsRoutes (pnr, rid) VALUES (15, 245);

-- Cancellations

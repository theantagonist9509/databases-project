-- Trains
INSERT INTO Trains (tname, first_class, second_class) VALUES ('Rajdhani Express', 10, 50);
INSERT INTO Trains (tname, first_class, second_class) VALUES ('Shatabdi Express', 12, 60);
INSERT INTO Trains (tname, first_class, second_class) VALUES ('Duronto Express', 12, 45);
INSERT INTO Trains (tname, first_class, second_class) VALUES ('Jan Shatabdi Express', 16, 70);

-- Small first class seat accomodation to test automatic RAC promotion
INSERT INTO Trains (tname, first_class, second_class) VALUES ('Vande Bharat Express', 2, 55);


-- Routes
INSERT INTO Routes (tid, origin, dest, departure, arrival, base_price) VALUES
(1, 'Mumbai', 'Delhi', '2025-04-15 08:30:00', '2025-04-16 10:45:00',400);
INSERT INTO Routes (tid, origin, dest, departure, arrival, base_price) VALUES
(1, 'Delhi', 'Patna', '2025-04-16 10:55:00', '2025-04-16 22:55:00',500);

INSERT INTO Routes (tid, origin, dest, departure, arrival, base_price) VALUES
(2, 'Chennai', 'Bangalore', '2025-04-16 15:00:00', '2025-04-16 19:30:00',400);
INSERT INTO Routes (tid, origin, dest, departure, arrival, base_price) VALUES
(2,'Bangalore','Kolkata', '2025-04-16 19:40:00', '2025-04-17 01:10:00',200);
INSERT INTO Routes (tid, origin, dest, departure, arrival, base_price) VALUES
(2,'Kolkata','Noida', '2025-04-17 01:10:00', '2025-04-17 10:40:00',200);
INSERT INTO Routes (tid, origin, dest, departure, arrival, base_price) VALUES
(2,'Noida','Jaipur', '2025-04-17 10:55:00', '2025-04-17 19:10:00',100);


INSERT INTO Routes (tid, origin, dest, departure, arrival, base_price) VALUES
(3, 'Kolkata', 'Hyderabad', '2025-04-17 22:15:00', '2025-04-18 12:45:00',500);

INSERT INTO Routes (tid, origin, dest, departure, arrival, base_price) VALUES
(4, 'Delhi', 'Jaipur', '2025-04-18 07:00:00', '2025-04-18 12:30:00',900);

INSERT INTO Routes (tid, origin, dest, departure, arrival, base_price) VALUES
(5, 'Bangalore', 'Mumbai', '2025-04-19 14:45:00', '2025-04-20 08:15:00',800);


-- Customers
INSERT INTO Customers (cname, concession_class, age) VALUES ('Rohit Sharma', 'senior_citizen', 68);
INSERT INTO Customers (cname, concession_class, age) VALUES ('Priya Singh', 'general', 22);
INSERT INTO Customers (cname, concession_class, age) VALUES ('Amit Patel', 'general', 35);
INSERT INTO Customers (cname, concession_class, age) VALUES ('Sunita Verma', 'senior_citizen', 72);
INSERT INTO Customers (cname, concession_class, age) VALUES ('Karan Mehta', 'general', 45);
INSERT INTO Customers (cname, concession_class, age) VALUES ('Rahul Mishra', 'general', 35);
INSERT INTO Customers (cname, concession_class, age) VALUES ('John Doe', 'general', 25);

-- Payments
INSERT INTO Payments (pid, ptype, amount, ptime) VALUES ('PAY001', 'credit_card', 2500, '2025-04-10 09:15:22');
INSERT INTO Payments (pid, ptype, amount, ptime) VALUES ('PAY002', 'debit_card', 1200, '2025-04-11 14:30:45');
INSERT INTO Payments (pid, ptype, amount, ptime) VALUES ('PAY003', 'upi', 3600, '2025-04-12 18:20:33');
INSERT INTO Payments (pid, ptype, amount, ptime) VALUES ('PAY004', 'net_banking', 1850, '2025-04-12 21:05:17');
INSERT INTO Payments (pid, ptype, amount, ptime) VALUES ('PAY005', 'wallet', 950, '2025-04-13 11:45:50');
INSERT INTO Payments (pid, ptype, amount, ptime) VALUES ('PAY006', 'wallet', 950, '2025-04-14 10:40:55');
INSERT INTO Payments (pid, ptype, amount, ptime) VALUES ('PAY007', 'credit_card', 950, '2025-04-15 09:41:30');

-- Bookings
INSERT INTO Bookings (cid, pid, btype, seat_class, seat_number, time_of_booking) VALUES
(1, 'PAY001', 'normal', 'first_class', 5, '2025-04-10 09:15:22');
INSERT INTO Bookings (cid, pid, btype, seat_class, seat_number, time_of_booking) VALUES
(2, 'PAY002', 'normal', 'second_class', 23, '2025-04-11 14:30:45');
INSERT INTO Bookings (cid, pid, btype, seat_class, seat_number, time_of_booking) VALUES
(3, 'PAY003', 'normal', 'first_class', 8, '2025-04-12 18:20:33');
INSERT INTO Bookings (cid, pid, btype, seat_class, seat_number, time_of_booking) VALUES
(4, 'PAY004', 'normal', 'second_class', 42, '2025-04-12 21:05:17');
INSERT INTO Bookings (cid, pid, btype, seat_class, seat_number, time_of_booking) VALUES
(5, 'PAY005', 'normal', 'second_class', 1, '2025-04-13 11:45:50');
INSERT INTO Bookings (cid, pid, btype, seat_class, seat_number, time_of_booking) VALUES
(6, 'PAY006', 'normal', 'second_class', 2, '2025-04-14 10:40:55');
INSERT INTO Bookings (cid, pid, btype, seat_class, seat_number, time_of_booking) VALUES
(7, 'PAY007', 'rac', 'second_class', NULL, '2025-04-14 09:41:30');

-- BookingsRoutes
INSERT INTO BookingsRoutes (pnr, rid) VALUES (1, 3);
INSERT INTO BookingsRoutes (pnr, rid) VALUES (1, 4);
INSERT INTO BookingsRoutes (pnr, rid) VALUES (1, 5);

INSERT INTO BookingsRoutes (pnr, rid) VALUES (2, 1);
INSERT INTO BookingsRoutes (pnr, rid) VALUES (2, 2);

INSERT INTO BookingsRoutes (pnr, rid) VALUES (3, 5);

INSERT INTO BookingsRoutes (pnr, rid) VALUES (4, 7);

INSERT INTO BookingsRoutes (pnr, rid) VALUES (5, 9);

INSERT INTO BookingsRoutes (pnr, rid) VALUES (6, 9);

INSERT INTO BookingsRoutes (pnr, rid) VALUES (7, 9);

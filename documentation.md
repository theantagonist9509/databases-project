# Train Reservation System Database Documentation

## ER Diagram

![ER Diagram](er-diagram.jpeg)

## Table Schema

### Trains
- **Attributes**: `tid` (PK, auto_increment), `tname`, `first_class`, `second_class`
- **Description**: Stores information about trains including their identifier, name, and the number of seats available in each class.

### Routes
- **Attributes**: `rid` (PK, auto_increment), `tid` (FK), `origin`, `dest`, `departure`, `arrival`, `base_price`
- **Description**: Contains route information including origin and destination stations, departure and arrival times, and the base ticket price.

### Customers
- **Attributes**: `cid` (PK, auto_increment), `cname`, `concession_class`, `age`
- **Description**: Stores customer information including their name, age, and concession category which determines discount eligibility.

### Payments
- **Attributes**: `pid` (PK), `ptype`, `amount`, `ptime`
- **Description**: Records payment transactions with unique payment ID, payment type, amount, and timestamp of the transaction.

### Bookings
- **Attributes**: `pnr` (PK, auto_increment), `cid` (FK), `pid` (FK), `btype`, `seat_class`, `seat_number`, `time_of_booking`
- **Description**: Tracks ticket bookings with PNR number, customer ID, payment ID, booking type (normal/RAC), seat information, and booking timestamp.

### BookingsRoutes
- **Attributes**: `pnr`, `rid` (FK)
- **Description**: Junction table linking bookings to routes, allowing a single booking to include multiple route segments.

### Cancellations
- **Attributes**: Same as Bookings plus `refund_id`
- **Description**: Records cancelled bookings with their original details and tracks refund status through `refund_id`.

### RACPromotionQueue
- **Attributes**: `pnr` (PK), `seat_number`
- **Description**: Queue for processing Reservation Against Cancellation (RAC) tickets that are eligible for promotion to confirmed status.

## Procedures, Functions, and Triggers

### Procedures

#### QueryPNRStatus
- **Signature**: `QueryPNRStatus(IN _pnr INT)`
- **Description**: Retrieves status information for a specific PNR number, showing customer name, train name, seat details, and booking status.

#### QueryTrainSchedule
- **Signature**: `QueryTrainSchedule(IN _tid INT)`
- **Description**: Lists the complete schedule for a specific train, showing all route segments with departure and arrival times.

#### QueryTrainDatePassengers
- **Signature**: `QueryTrainDatePassengers(IN _tid INT, IN d DATE)`
- **Description**: Lists all confirmed passengers traveling on a specific train on a given date.

#### QueryRACCustomers
- **Signature**: `QueryRACCustomers(IN _tid INT)`
- **Description**: Retrieves all waitlisted (RAC) passengers for a specific train.

#### QueryCancellations
- **Signature**: `QueryCancellations(IN refunded BOOL)`
- **Description**: Lists all cancellation records filtered by refund status (refunded or pending).

#### QueryItemizedBill
- **Signature**: `QueryItemizedBill(IN _cid INT, IN _rid INT, IN _seat_class VARCHAR(40))`
- **Description**: Generates a detailed bill for a ticket showing base price and all applicable discounts based on concession class and seat class.

#### CreateBooking
- **Signature**: `CreateBooking(IN _cid INT, IN _pid VARCHAR(40), IN _ptype VARCHAR(40), IN _amount INT, IN _btype VARCHAR(40), IN _seat_class VARCHAR(40), IN _seat_number VARCHAR(40))`
- **Description**: Creates a new booking record and associated payment entry, returning the generated PNR.

#### InsertBookingRoute
- **Signature**: `InsertBookingRoute(IN _pnr INT, IN _rid INT)`
- **Description**: Associates a booking with a specific route by adding an entry to the BookingsRoutes table.

#### InsertTrain
- **Signature**: `InsertTrain(IN _tname VARCHAR(40), IN _first_class INT, IN _second_class INT)`
- **Description**: Adds a new train to the system with the specified name and seating capacity by class.

#### InsertRoute
- **Signature**: `InsertRoute(IN _tid INT, IN _origin VARCHAR(40), IN _dest VARCHAR(40), IN _departure DATETIME, IN _arrival DATETIME, IN _base_price INT)`
- **Description**: Creates a new route entry for a specific train with origin, destination, schedule times, and pricing information.

#### InsertCustomer
- **Signature**: `InsertCustomer(IN _cname VARCHAR(40), IN _concession_class VARCHAR(40), IN _age INT)`
- **Description**: Registers a new customer in the system with their name, age, and concession eligibility details.

### Functions

#### GetRouteSeatAvailability
- **Signature**: `GetRouteSeatAvailability(_rid INT, _seat_number INT) RETURNS INT`
- **Description**: Checks if a specific seat is available on a given route, returning 1 if available and 0 if occupied.

#### GetTrainCancellationTotalRefund
- **Signature**: `GetTrainCancellationTotalRefund(_tid INT) RETURNS INT`
- **Description**: Calculates the total refund amount required if a specific train is cancelled.

#### GetPeriodRevenue
- **Signature**: `GetPeriodRevenue(s DATE, e DATE) RETURNS INT`
- **Description**: Calculates total revenue generated from ticket bookings over a specified date range.

#### GetBusiestRoute
- **Signature**: `GetBusiestRoute() RETURNS INT`
- **Description**: Identifies the route with the highest number of confirmed passengers based on booking counts.

#### GetRouteClassNumAvailableSeats
- **Signature**: `GetRouteClassNumAvailableSeats(_rid INT, _seat_class VARCHAR(40)) RETURNS INT`
- **Description**: Calculates the number of available seats for a specified route and seat class by comparing capacity with current bookings.

### Triggers

#### AfterBookingsDelete
- **Triggered**: After `DELETE` operation on Bookings table
- **Description**: Manages the booking cancellation process by recording cancellation details, determining refund eligibility, and processing RAC ticket promotions when seats become available.

## Normalization

### Trains
- **1NF**: ✅ All attributes are atomic and table has a primary key (`tid`).
- **2NF**: ✅ All non-key attributes (`tname`, `first_class`, `second_class`) are fully dependent on the primary key.
- **3NF**: ✅ No transitive dependencies exist; all attributes directly depend on the primary key.
- **BCNF**: ✅ Every determinant is a candidate key.

### Routes
- **1NF**: ✅ All attributes are atomic and table has a primary key (`rid`).
- **2NF**: ✅ All non-key attributes fully depend on the primary key.
- **3NF**: ✅ No obvious transitive dependencies.
- **BCNF**: ✅ Every determinant is a candidate key.

### Customers
- **1NF**: ✅ All attributes are atomic and table has a primary key (`cid`).
- **2NF**: ✅ All non-key attributes (`cname`, `concession_class`, `age`) fully depend on the primary key.
- **3NF**: ✅ No transitive dependencies exist.
- **BCNF**: ✅ Every determinant is a candidate key.

### Payments
- **1NF**: ✅ All attributes are atomic and table has a primary key (`pid`).
- **2NF**: ✅ All non-key attributes fully depend on the primary key.
- **3NF**: ✅ No transitive dependencies exist.
- **BCNF**: ✅ Every determinant is a candidate key.

### Bookings
- **1NF**: ✅ All attributes are atomic and table has a primary key (`pnr`).
- **2NF**: ✅ All non-key attributes fully depend on the primary key.
- **3NF**: ✅ No obvious transitive dependencies, as cid and pid are foreign keys representing relationships rather than transitive dependencies.
- **BCNF**: ✅ Every determinant is a candidate key.

### BookingsRoutes
- **1NF**: ✅ All attributes are atomic.
- **2NF**: ✅ This is a junction table linking bookings to routes with no non-key attributes.
- **3NF**: ✅ No non-key attributes means no transitive dependencies.
- **BCNF**: ✅ The combination of pnr and rid effectively forms the primary key.

### Cancellations
- **1NF**: ✅ All attributes are atomic and table has a primary key (`pnr`).
- **2NF**: ✅ All non-key attributes fully depend on the primary key.
- **3NF**: ✅ No transitive dependencies.
- **BCNF**: ✅ Every determinant is a candidate key.

### RACPromotionQueue
- **1NF**: ✅ All attributes are atomic and table has a primary key (`pnr`).
- **2NF**: ✅ This is a temporary queue table with just two fields where seat_number depends on pnr.
- **3NF**: ✅ No transitive dependencies.
- **BCNF**: ✅ Every determinant is a candidate key.

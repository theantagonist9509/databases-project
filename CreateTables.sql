create table Trains (
    tid int primary key auto_increment,
    first_class int,
    second_class int
);

create table Routes (
    rid int primary key auto_increment,
    tid int,
    origin varchar(40),
    dest varchar(40),
    departure datetime,
    arrival datetime,
    foreign key (tid) references Trains(tid)
);

create table Customers (
    cid int primary key auto_increment,
    cname varchar(40),
    consetion_class varchar(40),
    age int
);

create table Payments (
    pid varchar(40) primary key,
    ptype varchar(40),
    amount int
);

create table Bookings (
    pnr int primary key auto_increment,
    cid int,
    pid varchar(40),

    -- normal | rac
    btype varchar(40),

    seat_class varchar(40),
    seat_number int,
    time_of_booking datetime,
    foreign key (cid) references Customers(cid),
    foreign key (pid) references Payments(pid)
);

create table BookingsRoutes (
    pnr int,
    rid int,
    foreign key (pnr) references Bookings(pnr),
    foreign key (rid) references Routes(rid)
);

create table Cancellations like Bookings;

-- Remove auto_increment attribute
alter table Cancellations modify pnr varchar(40) not null;

-- Identifier for the refund transaction; NULL -> Not yet refunded
alter table Cancellations add column refund_id varchar(40);

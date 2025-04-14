create table Trains (
    tid int primary key auto_increment,
    tname VARCHAR(40),
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
    base_price int,
    foreign key (tid) references Trains(tid)
);

create table Customers (
    cid int primary key auto_increment,
    cname varchar(40),
    concession_class varchar(40),
    age int
);

create table Payments (
    pid varchar(40) primary key,
    ptype varchar(40),
    amount int,
    ptime datetime
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
    -- No FK contraint for this since it can be from Bookings or Cancellations
    pnr int,

    rid int,
    foreign key (rid) references Routes(rid)
);

-- Index for a common join operation
create index idx_bookingsroutes_pnr_rid on BookingsRoutes(pnr, rid);

create table Cancellations like Bookings;

-- Remove auto_increment attribute
alter table Cancellations modify pnr varchar(40) not null;

-- Identifier for the refund transaction; NULL -> Not yet refunded
alter table Cancellations add column refund_id varchar(40);

-- To circumvent same-table update restriction of triggers
create table RACPromotionQueue (
    pnr int primary key,
    seat_number int
);

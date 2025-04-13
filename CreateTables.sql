create table Trains(    tid int primary key,
                        first_class int,
                        second_class int);

create table Routes(    rid int primary key,
                        tid int,
                        origin varchar(40),
                        dest varchar(40),
                        departure datetime ,
                        arrival datetime,
                        foreign key (tid) references Trains(tid));

create table SeatsUsed( rid int,
                        first_class int,
                        second_class int,
                        foreign key (rid) references Routes(rid));


create table Customers( cid int primary key auto_increment,
                        name varchar(40),
                        consetion_class varchar(40),
                        age int );


create table Payments(  pid varchar(40) primary key,
                        type varchar(40),
                        amount int);

create table Bookings(  PNR int primary key auto_increment,
                        cid int,
                        rid int,
                        pid varchar(40),
                        seat_class varchar(40),
                        time_of_booking datetime,
                        foreign key (rid) references Routes(rid),
                        foreign key (cid) references Customers(cid),
                        foreign key (pid) references Payments(pid)
                        );

alter table Bookings add seat_number INT after seat_class;

create table Cancelation(   pid varchar(40) primary key,
                            type varchar(40),
                            amount int);

create table WaitList   (PNR int primary key auto_increment,
                        cid int,
                        rid int,
                        pid varchar(40),
                        seat_class varchar(40),
                        time_of_booking datetime,
                        foreign key (rid) references Routes(rid),
                        foreign key (cid) references Customers(cid),
                        foreign key (pid) references Payments(pid));

alter table WaitList add seat_number INT after seat_class;

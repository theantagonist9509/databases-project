-- Add Train
insert into Trains values(1,10,100),(2,15,150),(3,2,20);
-- Add Routes
insert into Routes values
(1,1,"Delhi","Agra","2025-03-03 11:11:11","2025-03-03 16:11:11"),
(2,1,"Agra","Delhi","2025-03-03 17:11:11","2025-03-03 22:11:11"),
(3,2,"Delhi","Kolkata","2025-03-03 10:20:20","2025-03-03 20:11:11");

-- SeatsUsed is going to be weak entity set so we aren't gonna make direct additions to that
-- Add SeatsUsed
insert into SeatsUsed values(1,2,12);

-- Train Schedule Lookup
DELIMITER $$
CREATE PROCEDURE TrainScheduleLookup(IN trainid INT)
BEGIN
    select * from Routes where tid = trainid;
END$$
DELIMITER ;

-- Available Seat Query
DROP PROCEDURE IF EXISTS AvailableSeatQuery;
DELIMITER $$
CREATE PROCEDURE AvailableSeatQuery(IN routeid INT)
BEGIN
    select tot.first_class - used.first_class as first_class,
    tot.second_class - used.second_class as second_class from
        (select first_class,second_class from Trains where 
        tid = (select tid from Routes where rid = routeid)) as tot,
        (select first_class,second_class from SeatsUsed where rid = routeid) as used;
END$$
DELIMITER ;
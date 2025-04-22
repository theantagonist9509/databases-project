CALL QueryPNRStatus(3);
CALL QueryTrainSchedule(2);
SELECT GetRouteSeatAvailability(9, 2);
CALL QueryTrainDatePassengers(5, '2025-04-19');
CALL QueryTrainRACCustomers(5);
SELECT GetTrainCancellationTotalRefund(2);
SELECT GetPeriodRevenue('2025-04-09', '2025-04-13');
SELECT GetBusiestRoute();
CALL QueryItemizedBill(1, 2, 'first_class');

CALL QueryCancellations(FALSE);
SELECT * FROM RACPromotionQueue;
DELETE FROM Bookings WHERE pnr = 6;

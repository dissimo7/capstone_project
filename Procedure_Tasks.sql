CREATE OR REPLACE VIEW OrdersView AS (SELECT OrderID, Quantity, Cost FROM Orders WHERE Quantity > 2);

SELECT Customers.CustomerID, CONCAT(FirstName, LastName) AS FullName, OrderID, Cost, MenuName, Course, Starter 
FROM Customers
INNER JOIN Bookings ON Customers.CustomerID = Bookings.CustomerID
INNER JOIN Orders ON Bookings.BookingID = Orders.BookingID
INNER JOIN Menu ON Orders.MenuID = Menu.MenuID
INNER JOIN MenuItems ON Menu.MenuItemID = MenuItems.MenuItemID;


SELECT MenuName FROM Menu WHERE MenuID=(SELECT MenuID FROM Orders WHERE Quantity > 2);


DROP PROCEDURE IF EXISTS GetMaxQuantity;
DELIMITER //
CREATE PROCEDURE GetMaxQuantity()
BEGIN
	SELECT Max(Quantity) AS MaxOrderedQuantity FROM Orders;
END//
DELIMITER ;
CALL GetMaxQuantity();


PREPARE GetOrderDetail FROM 'SELECT OrderID, Quantity, Cost FROM Orders, Bookings WHERE Bookings.BookingID=Orders.BookingID AND Bookings.CustomerID = ?';
SET @id = 1;
EXECUTE GetOrderDetail USING @id;


DROP PROCEDURE IF EXISTS CancelOrder;
DELIMITER //
CREATE PROCEDURE CancelOrder(IN InputOrderID INT)
BEGIN
	DELETE FROM Orders WHERE Orders.OrderID = InputOrderID;
END//
DELIMITER ;
CALL CancelOrder(1);


INSERT INTO Bookings (BookingID, Date, TableNo, CustomerID) 
VALUES 
	(1, "2022-10-10", 5, 1),
	(2, "2022-11-12", 3, 3),
	(3, "2022-10-11", 2, 2),
	(4, "2022-10-13", 2, 1);


DROP PROCEDURE IF EXISTS CheckBooking;
DELIMITER //
CREATE PROCEDURE CheckBooking(IN InputDate DATE, IN InputTableNo INT)
BEGIN
    SET @status := (SELECT BookingID FROM Bookings WHERE Bookings.Date = InputDate AND TableNo = InputTableNo);
	IF ISNULL(@status) THEN SELECT CONCAT("Table ", InputTableNo, " is not booked") AS "Booking status";
    ELSE SELECT CONCAT("Table ", InputTableNo, " is already booked") AS "Booking status";
    END IF;
END//
DELIMITER ;
CALL CheckBooking("2022-11-12", 3);


DROP PROCEDURE IF EXISTS AddValidBooking;
DELIMITER //
CREATE PROCEDURE AddValidBooking(IN InputDate DATE, IN InputTableNo INT, IN InputCustomerID INT)
BEGIN
	SET @status := (SELECT BookingID FROM Bookings WHERE Bookings.Date = InputDate AND TableNo = InputTableNo);
	START TRANSACTION;
    INSERT INTO Bookings (Bookings.Date, TableNo, CustomerID) VALUES (InputDate, InputTableNo, InputCustomerID);
    IF ISNULL(@status) THEN
	BEGIN
		ROLLBACK;
        SELECT CONCAT("Table ", InputTableNo, " is already booked - booking cancelled");
    END;
    ELSE
    BEGIN
		COMMIT;
        SELECT CONCAT("Table ", InputTableNo, " is not booked - booking placed");
    END;
    END IF;
END//
DELIMITER ;
CALL AddValidBooking("2022-12-17", 6, 1);


DROP PROCEDURE IF EXISTS AddBooking;
DELIMITER //
CREATE PROCEDURE AddBooking(IN InputBookingID INT, IN InputDate DATE, IN InputTableNo INT, IN InputCustomerID INT)
BEGIN
	INSERT INTO Bookings (BookingID, Bookings.Date, TableNo, CustomerID) VALUES (InputBookingID, InputDate, InputTableNo, InputCustomerID);
END//
DELIMITER ;
CALL AddBooking(9, "2022-12-30", 3, 4);


DROP PROCEDURE IF EXISTS UpdateBooking;
DELIMITER //
CREATE PROCEDURE UpdateBooking(IN InputBookingID INT, IN InputBookingDate DATE)
BEGIN
	UPDATE Bookings SET Bookings.Date = InputBookingDate WHERE BookingID = InputBookingID;
END//
DELIMITER ;
CALL UpdateBooking(1, "2023-6-22");


DROP PROCEDURE IF EXISTS CancelBooking;
DELIMITER //
CREATE PROCEDURE CancelBooking(IN InputBookingID INT)
BEGIN
	DELETE FROM Bookings WHERE BookingID = InputBookingID;
END//
DELIMITER ;
CALL CancelBooking(9);
/* 

DATA 1001: Assignment 2
Neel Iyer
z5165452

*/

/*1. Find the average room capacity in the building whose name is “Civil Engineering Building"*/
SELECT AVG(Capacity) AS Avg_Capacity FROM Rooms, Buildings WHERE Buildings.Name = 'Civil Engineering Building' AND Rooms.Building = Buildings.id;

/*2. Find all the people’s phone number whose room unswid is “K-K15-31”.*/
SELECT Staff.Phone FROM Staff,Rooms WHERE Rooms.Unswid = 'K-K15-31' AND Office = Rooms.id;

/*3. Find the number of rooms for each building.*/
SELECT COUNT(Rooms.Building) AS Number_of_Rooms, Buildings.Name AS Building_Name FROM Rooms, Buildings WHERE Rooms.Building = Buildings.id GROUP BY Rooms.Building;

/*4. Find the name of building where the staff with phone number “93855585” works.*/
SELECT Buildings.Name FROM Buildings, Staff, Rooms WHERE Rooms.Building = Buildings.id AND Staff.Phone = 93855585 AND Staff.Office = Rooms.id;

/*5. Find the name of the room which has the largest capacity.*/
SELECT @Max_capacity := MAX(capacity) FROM Rooms;
SELECT NAME FROM Rooms WHERE Capacity = @Max_capacity;

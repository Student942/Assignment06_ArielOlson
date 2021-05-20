--*************************************************************************--
-- Title: Assignment06
-- Author: Ariel Olson
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2021-05-16,Ariel Olson,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_ArielOlson')
	 Begin 
	  Alter Database [Assignment06DB_ArielOlson] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_ArielOlson;
	 End
	Create Database Assignment06DB_ArielOlson;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_ArielOlson;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers ********************************
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'
*/
-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
CREATE -- DROP 
  VIEW VCategories WITH SCHEMABINDING 
    AS
		SELECT 
			[CategoryID]
			, [CategoryName]
		FROM [dbo].[Categories];
GO

CREATE -- DROP 
  VIEW VEmployees WITH SCHEMABINDING 
    AS
		SELECT 
			[EmployeeID]
			, [EmployeeFirstName]
			, [EmployeeLastName]
			,[ManagerID]
		FROM [dbo].[Employees];
GO

CREATE -- DROP 
  VIEW VInventories WITH SCHEMABINDING 
    AS
		SELECT 
			[InventoryID]
			,[InventoryDate]
			,[EmployeeID]
			,[ProductID]
			,[Count]
		FROM [dbo].[Inventories];
GO

CREATE -- DROP 
  VIEW VProducts WITH SCHEMABINDING 
    AS
		SELECT 
			[ProductID]
			,[ProductName]
			,[CategoryID]
			,[UnitPrice]
		FROM [dbo].[Products];
GO

SELECT * FROM VCategories
SELECT * FROM VEmployees
SELECT * FROM VInventories
SELECT * FROM VProducts
SELECT * FROM [dbo].[Categories]
SELECT * FROM [dbo].[Employees]
SELECT * FROM [dbo].[Inventories]
SELECT * FROM [dbo].[Products]

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
DENY SELECT ON [dbo].[Categories] TO PUBLIC;
	GRANT SELECT ON VCategories TO PUBLIC;

DENY SELECT ON [dbo].[Employees] TO PUBLIC;
	GRANT SELECT ON VEmployees TO PUBLIC;

DENY SELECT ON [dbo].[Inventories] TO PUBLIC;
	GRANT SELECT ON VInventories TO PUBLIC;

DENY SELECT ON [dbo].[Products] TO PUBLIC;
	GRANT SELECT ON VProducts TO PUBLIC;

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

CREATE -- DROP
VIEW vProductsByCategories
AS
SELECT TOP 1000000 
	c.CategoryName
	, p.ProductName
	, p.UnitPrice
	FROM vProducts as p JOIN vCategories as c
		ON p.categoryID = c.CategoryID
	ORDER BY CategoryName, ProductName
;
GO

SELECT * FROM vProductsByCategories
GO

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

CREATE -- DROP
VIEW vInventoriesByProductsByDates
AS
SELECT TOP 1000000 
	p.ProductName
	, i.[Count]
	, i.InventoryDate
	FROM vProducts as p JOIN vInventories as i
		ON i.ProductID = p.ProductID
	ORDER BY ProductName, InventoryDate, [Count]
;
GO

SELECT * FROM vInventoriesByProductsByDates
GO

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

CREATE -- DROP
VIEW vInventoriesByEmployeesByDates
AS
SELECT DISTINCT TOP 1000000 
	i.InventoryDate
	, EmployeeName =  e.EmployeeFirstName + ' ' + e.EmployeeLastName
	FROM vInventories as i JOIN vEmployees as e
		On i.EmployeeID = e.EmployeeID
	ORDER BY [InventoryDate]
;
GO

SELECT * FROM vInventoriesByEmployeesByDates
GO

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

CREATE -- DROP
VIEW vInventoriesByProductsByCategories
AS
SELECT TOP 1000000 
	c.CategoryName
	, p.ProductName
	, i.InventoryDate
	, i.[Count]
	FROM vProducts as p
		JOIN vCategories as c
			ON C.CategoryID = P.CategoryID
		JOIN vInventories as i
			ON I.ProductID = P.ProductID
	ORDER BY CategoryName, ProductName, InventoryDate, [Count]
;
GO

SELECT * FROM vInventoriesByProductsByCategories
GO

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

CREATE -- DROP
VIEW vInventoriesByProductsByEmployees
AS
SELECT Top 1000000 
	c.CategoryName
	, p.ProductName
	, i.InventoryDate
	, i.[Count]
	, EmployeeName =  e.EmployeeFirstName + ' ' + e.EmployeeLastName
	FROM vProducts as p
		JOIN vCategories as c
			ON C.CategoryID = P.CategoryID
		JOIN vInventories as i
			ON I.ProductID = P.ProductID
		JOIN vEmployees as e
			ON E.EmployeeID = I.EmployeeID
	ORDER BY CategoryName, ProductName, InventoryDate, [Count], EmployeeName
;
GO

SELECT * FROM vInventoriesByProductsByEmployees
GO

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

CREATE -- DROP
VIEW vInventoriesForChaiAndChangByEmployees
AS
SELECT TOP 10000000 
	c.CategoryName
	, p.ProductName
	, i.InventoryDate
	, i.[Count]
	, EmployeeName =  e.EmployeeFirstName + ' ' + e.EmployeeLastName
	FROM vProducts as p
		JOIN vCategories as c
			ON C.CategoryID = P.CategoryID
		JOIN vInventories as i
			ON I.ProductID = P.ProductID
		JOIN vEmployees as e
			ON E.EmployeeID = I.EmployeeID
	WHERE p.ProductID IN 
			(
				SELECT ProductID
				FROM vProducts
				WHERE ProductName = 'Chai'
				OR ProductName = 'Chang'
			)
	ORDER BY InventoryDate, CategoryName, ProductName
;
GO

SELECT * FROM vInventoriesForChaiAndChangByEmployees
GO

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
CREATE -- DROP
VIEW vEmployeesByManager
AS
SELECT TOP 1000000 
	EmployeeName =  E.[EmployeeFirstName] + ' ' + E.[EmployeeLastName]
	, ManagerName = M.[EmployeeFirstName] + ' ' + M.[EmployeeLastName] 
	FROM vEmployees AS E
		INNER JOIN vEmployees AS M
			ON M.EmployeeID = E.ManagerID
	ORDER BY ManagerName
GO

SELECT * FROM vEmployeesByManager
GO

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views?
Create -- DROP
View vInventoriesByProductsByCategoriesByEmployees
AS
SELECT TOP 1000000 
	c.CategoryID
	, c.Categoryname
	, p.ProductID
	, p.Productname
	, p.UnitPrice
	, i.InventoryID
	, i.Inventorydate
	, i.[Count]
	, e.employeeID
	, EmployeeName =  E.[EmployeeFirstName] + ' ' + E.[EmployeeLastName]
	, ManagerName = M.[EmployeeFirstName] + ' ' + M.[EmployeeLastName] 
	FROM vProducts as p
		JOIN vCategories as c
			ON C.CategoryID = P.CategoryID
		JOIN vInventories as i
			ON I.ProductID = P.ProductID
		JOIN vEmployees as e
			ON E.EmployeeID = I.EmployeeID
		INNER JOIN vEmployees AS M
			ON M.EmployeeID = E.ManagerID
	ORDER BY Categoryname, Productname, [Count]

-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]
/***************************************************************************************/
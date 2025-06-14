-- 1. List employee names, hire date, and their years of service

SELECT p.FirstName, p.LastName, e.HireDate,
    DATEDIFF(YEAR, e.HireDate, GETDATE()) AS YearsOfService
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID;

-- 2. The most expensive product in each subcategory
SELECT p.Name, p.ListPrice, p.ProductSubcategoryID
FROM Production.Product p
WHERE p.ListPrice = (
    SELECT MAX(ListPrice) 
    FROM Production.Product 
    WHERE ProductSubcategoryID = p.ProductSubcategoryID
);


-- 3. List employees who have changed departments at least twice
SELECT e.BusinessEntityID, COUNT(DISTINCT edh.DepartmentID) AS DeptChanges
FROM HumanResources.Employee e
JOIN HumanResources.EmployeeDepartmentHistory edh ON e.BusinessEntityID = edh.BusinessEntityID
GROUP BY e.BusinessEntityID
HAVING COUNT(DISTINCT edh.DepartmentID) >= 2;

-- 4. Customer names who placed more than 3 orders
SELECT p.FirstName, p.LastName, COUNT(*) AS OrderCount
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader so ON c.CustomerID = so.CustomerID
GROUP BY p.FirstName, p.LastName
HAVING COUNT(*) > 3;

-- 5. Employees and the total number of orders they've handled as salespeople
SELECT p.FirstName, p.LastName, COUNT(so.SalesOrderID) AS OrdersHandled
FROM Sales.SalesOrderHeader so
JOIN Sales.SalesPerson sp ON so.SalesPersonID = sp.BusinessEntityID
JOIN Person.Person p ON sp.BusinessEntityID = p.BusinessEntityID
GROUP BY p.FirstName, p.LastName;

-- 6. Top 5 customers by total sales
SELECT TOP 5 c.CustomerID, SUM(so.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader so
JOIN Sales.Customer c ON so.CustomerID = c.CustomerID
GROUP BY c.CustomerID
ORDER BY TotalSales DESC;

-- 7. Orders that included ProductID 707
SELECT so.SalesOrderID
FROM Sales.SalesOrderHeader so
WHERE EXISTS (
    SELECT 1 
    FROM Sales.SalesOrderDetail sod 
    WHERE sod.SalesOrderID = so.SalesOrderID AND sod.ProductID = 707
);

-- 8. Employees hired after the average hire date
SELECT p.FirstName, p.LastName, e.HireDate
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE e.HireDate > (
    SELECT DATEADD(DAY, AVG(DATEDIFF(DAY, '2000-01-01', HireDate)), '2000-01-01')
    FROM HumanResources.Employee
);

-- 9. All orders with their total quantity
SELECT so.SalesOrderID, SUM(sod.OrderQty) AS TotalQuantity
FROM Sales.SalesOrderHeader so
JOIN Sales.SalesOrderDetail sod ON so.SalesOrderID = sod.SalesOrderID
GROUP BY so.SalesOrderID;

-- 10. Employees and the total number of orders they've handled as sa
SELECT 
  p.FirstName, 
  p.LastName, 
  COUNT(so.SalesOrderID) AS OrdersHandled
FROM Sales.SalesOrderHeader so
JOIN Sales.SalesPerson sp ON so.SalesPersonID = sp.BusinessEntityID
JOIN Person.Person p ON sp.BusinessEntityID = p.BusinessEntityID
GROUP BY p.FirstName, p.LastName;

-- 11. Customers who ordered the same product more than once
SELECT c.CustomerID, sod.ProductID, COUNT(*) AS RepeatCount
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader so ON c.CustomerID = so.CustomerID
JOIN Sales.SalesOrderDetail sod ON so.SalesOrderID = sod.SalesOrderID
GROUP BY c.CustomerID, sod.ProductID
HAVING COUNT(*) > 1;

-- 12. Products that are priced above the average price of their category
SELECT p.Name, p.ListPrice, c.Name AS Category
FROM Production.Product p
JOIN Production.ProductSubcategory sc ON p.ProductSubcategoryID = sc.ProductSubcategoryID
JOIN Production.ProductCategory c ON sc.ProductCategoryID = c.ProductCategoryID
WHERE p.ListPrice > (
    SELECT AVG(ListPrice)
    FROM Production.Product
    WHERE ProductSubcategoryID = p.ProductSubcategoryID
);

-- 13. Employees whose job titles contain 'Manager'
SELECT p.FirstName, p.LastName, e.JobTitle
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE e.JobTitle LIKE '%Manager%';

-- 14. Product names with the count of vendors supplying them
SELECT p.Name, COUNT(pv.BusinessEntityID) AS VendorCount
FROM Production.Product p
LEFT JOIN Purchasing.ProductVendor pv ON p.ProductID = pv.ProductID
GROUP BY p.Name;

-- 15. Employee names and their department names
SELECT p.FirstName, p.LastName, d.Name AS Department
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
JOIN HumanResources.EmployeeDepartmentHistory edh ON e.BusinessEntityID = edh.BusinessEntityID
JOIN HumanResources.Department d ON edh.DepartmentID = d.DepartmentID
WHERE edh.EndDate IS NULL;

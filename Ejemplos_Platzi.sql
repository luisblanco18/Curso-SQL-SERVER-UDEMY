USE Platzi

GO

CREATE OR ALTER PROCEDURE MerceUsuarioTarget
    @Codigo integer,
    @Nombre varchar(100),
    @Puntos integer
AS
BEGIN
    MERGE UsuarioTarget AS T
        USING (SELECT @Codigo, @Nombre, @Puntos) AS S 
					   (Codigo, Nombre, Puntos)
		ON (T.Codigo = S.Codigo)
    WHEN MATCHED THEN
        UPDATE SET T.Nombre = S.Nombre,
				   T.Puntos = S.Puntos
    WHEN NOT MATCHED THEN
        INSERT (Codigo, Nombre, Puntos)
        VALUES (S.Codigo, S.Nombre, S.Puntos) ;
END

GO 

select * from UsuarioTarget
exec MerceUsuarioTarget 3,'Roy Rojas', 9
select * from UsuarioTarget

/*TABLAS VERSIONADAS*/


GO
 
-------------------------------------
-- Creacion de tabla versionada desde el inicio

CREATE TABLE Usuario
(
  [UsuarioID] int NOT NULL PRIMARY KEY CLUSTERED
  , Nombre nvarchar(100) NOT NULL
  , Twitter varchar(100) NOT NULL
  , Web varchar(100) NOT NULL
  , ValidFrom datetime2 GENERATED ALWAYS AS ROW START
  , ValidTo datetime2 GENERATED ALWAYS AS ROW END
  , PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
 )
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.UsuarioHistory));

GO


-------------------------------------
-- Inserts de pruebas

INSERT INTO [dbo].[Usuario]
           ([UsuarioID]
           ,[Nombre]
           ,[Twitter]
           ,[Web])
     VALUES
           (1
           ,'Roy Rojas'
           ,'@royrojasdev'
           ,'www.dotnetcr.com')

INSERT INTO [dbo].[Usuario]
           ([UsuarioID]
           ,[Nombre]
           ,[Twitter]
           ,[Web])
     VALUES
           (2
           ,'Maria Ramirez'
           ,'@maria'
           ,'www.mariaramitez.com')

GO


-------------------------------------
-- Actualizar un registro

UPDATE Usuario
SET Nombre = 'Roy Rojas Rojas'
WHERE UsuarioID = 1

GO


-------------------------------------
-- Consultas a los datos historicos

-- Puedes hacer consultas directamente a la tabla histórita
SELECT * FROM UsuarioHistory WHERE UsuarioID = 1

-- Consulta todos los cambios por rango de fechas
SELECT * FROM Usuario
  FOR SYSTEM_TIME
    BETWEEN '2020-01-01 00:00:00.0000000' AND '2021-01-01 00:00:00.0000000'
  ORDER BY ValidFrom;

GO

-- Consulta un usuario por rango de fechas
SELECT * FROM Usuario
  FOR SYSTEM_TIME
    BETWEEN '2020-01-01 00:00:00.0000000' AND '2021-01-01 00:00:00.0000000'
      WHERE UsuarioID = 1 ORDER BY ValidFrom;

GO

-- Consulta un usuario por fecha pero solo en la tabla historial
SELECT * FROM Usuario FOR SYSTEM_TIME
    CONTAINED IN ('2020-01-01 00:00:00.0000000', '2021-01-01 00:00:00.0000000')
        WHERE UsuarioID = 1 ORDER BY ValidFrom;

GO

-- Consulta un usuario por ID
SELECT * FROM Usuario
    FOR SYSTEM_TIME ALL WHERE
        UsuarioID = 2 ORDER BY ValidFrom;


-------------------------------------
-- Para borrar las tablas versionadas

ALTER TABLE [dbo].[Usuario] SET ( SYSTEM_VERSIONING = OFF  )
GO

DROP TABLE [dbo].[Usuario]
GO

DROP TABLE [dbo].[UsuarioHistory]
GO


-------------------------------------
-- Crear tabla versionada para tablas ya existentes

CREATE TABLE Usuario2
(
  [UsuarioID] int NOT NULL PRIMARY KEY CLUSTERED
  , Nombre nvarchar(100) NOT NULL
  , Twitter varchar(100) NOT NULL
  , Web varchar(100) NOT NULL
 )

 GO

ALTER TABLE Usuario2
ADD
    ValidFrom datetime2 (2) GENERATED ALWAYS AS ROW START HIDDEN
        constraint DF_ValidFrom DEFAULT DATEADD(second, -1, SYSUTCDATETIME())  
    , ValidTo datetime2 (2) GENERATED ALWAYS AS ROW END HIDDEN
        constraint DF_ValidTo DEFAULT '9999.12.31 23:59:59.99'
    , PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo);

ALTER TABLE Usuario2
    SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Usuario2_History));


/*Full text search*/


CREATE TABLE [dbo].[Documentos](
	[id] [int] NOT NULL,
	[NombreArchivo] [nvarchar](40) NULL,
	[Contenido] [varbinary](max) NULL,
	[extension] [varchar](5) NULL,
 CONSTRAINT [PK_Documentos] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


INSERT INTO Documentos
SELECT 3,N'Prueba-01-2', BulkColumn,'.doc'
FROM OPENROWSET(BULK  N'C:\Temp\1.doc', SINGLE_BLOB) blob


INSERT INTO Documentos
SELECT 4,N'Prueba-02-2', BulkColumn,'.doc'
FROM OPENROWSET(BULK  N'C:\Temp\2.doc', SINGLE_BLOB) blob

select * from Documentos


--select * from Documentos where DocContent like '%Roy%'

SELECT *
FROM Documentos  
WHERE FREETEXT (DocContent, 'Roy')  
GO  


/*Funciones*/

USE WideWorldImporters

GO

SELECT I.StockItemID,
	   I.StockItemName,
	   SUM(O.Quantity * O.UnitPrice) as Vendido
  FROM Warehouse.StockItems I INNER JOIN	
	   Sales.OrderLines O ON I.StockItemID = O.StockItemID
 WHERE I.StockItemID = 45
 GROUP BY I.StockItemID,
	   I.StockItemName
GO
SELECT I.StockItemID,
	   I.StockItemName,
	   dbo.f_TotalVendidoXProducto(I.StockItemID) as Vendido
  FROM Warehouse.StockItems I
 WHERE I.StockItemID = 45

 GO
 
-- Funcion con retorno de un valor
CREATE FUNCTION f_TotalVendidoXProducto
(
	@StockItemID int
)
RETURNS decimal
AS
BEGIN

	DECLARE @total decimal

	SELECT @total = SUM(Quantity * UnitPrice)
	  FROM  Sales.OrderLines
	 WHERE StockItemID = @StockItemID

	RETURN @total

END

GO

SELECT dbo.f_TotalVendidoXProducto(45)

GO

/*Funciones tabla*/
GO

-- Funcion con retorno de una tabla

	SELECT s.StockItemID, s.StockItemName, SUM(l.Quantity) as Cantidad
	  FROM Warehouse.StockItems s INNER JOIN
		   Sales.InvoiceLines l ON s.StockItemID = l.StockItemID INNER JOIN
		   Sales.Invoices i ON l.InvoiceID = i.InvoiceID INNER JOIN
		   Sales.Customers c ON i.CustomerID = c.CustomerID
	 WHERE c.CustomerID = 832
	 GROUP BY s.StockItemID, s.StockItemName

GO
 

CREATE or ALTER FUNCTION f_TotalComprasXCliente
(	
	@CustomerID int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT s.StockItemID, s.StockItemName, SUM(l.Quantity) as Cantidad
	  FROM Warehouse.StockItems s INNER JOIN
		   Sales.InvoiceLines l ON s.StockItemID = l.StockItemID INNER JOIN
		   Sales.Invoices i ON l.InvoiceID = i.InvoiceID INNER JOIN
		   Sales.Customers c ON i.CustomerID = c.CustomerID
	 WHERE c.CustomerID = @CustomerID
	 GROUP BY s.StockItemID, s.StockItemName
)

GO

SELECT * FROM dbo.f_TotalComprasXCliente(832)

GO

/*vista indexada*/


-- Query que vamos a implementar en la vista
SELECT StockItemID, 
    COUNT_BIG(*) as TotalLineas, 
	SUM(Quantity) as CantidadProductos,
	SUM(Quantity * UnitPrice)
FROM  Sales.OrderLines
GROUP BY StockItemID

GO

-- Creación de la vista
CREATE VIEW v_VentasXProducto
AS
     SELECT StockItemID, 
		    Description,
            COUNT_BIG(*) as TotalLineas, 
			SUM(Quantity) as CantidadProductos,
			SUM(Quantity * UnitPrice) Total
      FROM  Sales.OrderLines	  
      GROUP BY StockItemID, Description

GO

-- Ejecutando la vista
SELECT * FROM v_VentasXProducto
WHERE StockItemID = 105

GO

-- Creación de la vista indexada

-- Indispensable en la configuracion
SET ANSI_NULLS ON 
GO 
SET ANSI_PADDING ON 
GO 
SET ANSI_WARNINGS ON 
GO 
SET CONCAT_NULL_YIELDS_NULL ON 
GO 
SET QUOTED_IDENTIFIER ON 
GO 
SET NUMERIC_ROUNDABORT OFF 
GO

-- Indexada
-- Creación vista con SCHEMABINDING
CREATE VIEW v_VentasXProducto_Indexada
WITH SCHEMABINDING 
AS
     SELECT StockItemID, 
            COUNT_BIG(*) as TotalLineas, 
			SUM(Quantity) as CantidadProductos,
			SUM(ISNULL(Quantity * UnitPrice,0)) Total
      FROM  Sales.OrderLines	  
      GROUP BY StockItemID 

GO

-- Creación del índice de la vista
CREATE UNIQUE CLUSTERED INDEX IX_v_VentasXProducto_Indexada
ON v_VentasXProducto_Indexada ([StockItemID])

-- Ejecutando la vista
SELECT * FROM v_VentasXProducto_Indexada


-- Comparando las dos vístas

SELECT * FROM v_VentasXProducto
WHERE StockItemID = 105

SELECT * FROM v_VentasXProducto_Indexada
WHERE StockItemID = 105

GO

-- Recomendación creación del índice para la tabla Sales
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [Sales].[OrderLines] ([StockItemID])
INCLUDE ([Description],[Quantity],[UnitPrice])

CREATE or ALTER PROCEDURE msp_retornaItem(
@StockItemID int,
@StockItemName NVARCHAR(100) output,
@Vendido decimal output
)
AS 
BEGIN

	SELECT @StockItemName = I.StockItemName,
		   @Vendido = dbo.f_TotalVendidoXProducto(I.StockItemID)
	  FROM Warehouse.StockItems I INNER JOIN	
		   Sales.OrderLines O ON I.StockItemID = O.StockItemID
	 WHERE I.StockItemID = @StockItemID
	 GROUP BY I.StockItemID,
		   I.StockItemName

END

GO

CREATE or ALTER PROCEDURE msp_retornaItem01(
@StockItemID int
)
AS 
	SET NOCOUNT ON
BEGIN

	SELECT I.StockItemID ,
		   I.StockItemName,
		   SUM(O.Quantity * O.UnitPrice) as Vendido
	  FROM Warehouse.StockItems I INNER JOIN	
		   Sales.OrderLines O ON I.StockItemID = O.StockItemID
	 WHERE I.StockItemID = @StockItemID
	 GROUP BY I.StockItemID,
		   I.StockItemName

END

exec msp_retornaItem01 45
GO
declare @StockItemName nvarchar(100)
declare @vendido decimal
exec msp_retornaItem 45, @StockItemName output, @vendido output
select @StockItemName, @vendido


-----------------------------------------------
--- Retorna Json or XML

USE Platzi

select * from UsuarioSource
FOR XML AUTO, ELEMENTS,  ROOT('Usuarios')

select * from UsuarioSource
FOR XML PATH('Usuario'), ELEMENTS, ROOT('UsuarioSource')


USE AdventureWorks2012
GO
SELECT Cust.CustomerID,
       OrderHeader.CustomerID,
       OrderHeader.SalesOrderID,
       OrderHeader.Status
FROM Sales.Customer Cust 
INNER JOIN Sales.SalesOrderHeader OrderHeader
ON Cust.CustomerID = OrderHeader.CustomerID
FOR XML PATH('Ordenes'), Root ('OrdenesCliente');



-------------------------
-- Retorna Json

USE AdventureWorks2019


SELECT BusinessEntityID,
		FirstName,
		LastName
		,
		(SELECT E.EmailAddress,
			    Ph.PhoneNumber
		   FROM Person.EmailAddress E INNER JOIN
			    Person.PersonPhone Ph ON E.BusinessEntityID = P.BusinessEntityID
									 AND E.BusinessEntityID = PH.BusinessEntityID
		  WHERE E.BusinessEntityID = P.BusinessEntityID
		 FOR JSON PATH) [DatosPersonales]
FROM Person.Person P
WHERE BusinessEntityID = 1
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

/*ULTIMO*/
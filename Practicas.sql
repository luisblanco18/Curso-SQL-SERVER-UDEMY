
/*CURSO SQL SERVER UDEMY-REP.GIT*/

/*CLAUSULA IN*/

SELECT *
FROM dbo.tblVentas AS TV
WHERE TV.COD_ID IN (
		'10422'
		,'10151'
		)

SELECT *
FROM dbo.tblVentas AS TV
WHERE TV.COD_ID IN (
		SELECT TC.COD_ID
		FROM dbo.tblClientes TC
		WHERE TC.COD_ID = '10422'
			OR TC.COD_ID = '10151'
		)

/*CLAUSULA WITH TIES (EJEMPLO)*/
DECLARE @Tabla TABLE (IDValor INT, Cantidad INT)

INSERT INTO @Tabla
VALUES (1, 5), (2, 8), (3, 8), (4, 9), (5, 10), (6, 10), (7, 11), (8, 11)

SELECT TOP 3 Cantidad, 'SIN WITH TIES'
FROM @Tabla
ORDER BY Cantidad DESC

SELECT TOP 3
WITH TIES Cantidad, 'CON WITH TIES'
FROM @Tabla
ORDER BY Cantidad DESC

/*AUMENTO EN PORCENTAJE POR SELECT*/

SELECT *
	  ,CAST(ROUND(PRECIO_VTA * 1.15, 2) AS NUMERIC(16, 2)) AS [PRECIO CON AUMENTO]
FROM dbo.tblProductos


/*Clientes que tienen alguna venta*/ --1102
SELECT DISTINCT COD_ID 
FROM dbo.tblVentas
WHERE COD_ID IN (SELECT COD_ID FROM dbo.tblClientes)
/*Clientes que NO tienen alguna venta*/ --22
SELECT *
FROM dbo.tblVentas
WHERE COD_ID NOT IN (SELECT COD_ID FROM dbo.tblClientes)


/*VALORES NULOS*/

SELECT *
FROM dbo.tblProductos
WHERE MARCA IS NULL

SELECT *
FROM dbo.tblProductos
WHERE MARCA IS NOT NULL

/*OFFSET EXCLUYE FILAS*/

SELECT *
FROM dbo.tblVendedores
ORDER BY COD_VEND DESC
OFFSET 10 ROWS

/*PAGINACION CON FETCH NEXT*/
SELECT *
FROM dbo.tblVendedores
ORDER BY COD_VEND DESC
OFFSET 10 ROWS
FETCH NEXT 5 ROWS ONLY

/*INNER JOIN*/
SELECT TV.COD_DIA,
	   TV.COD_SUC,
	   TV.FECHA,
	   TC.NOMBRE AS CLIENTE
FROM dbo.tblVentas TV
INNER JOIN dbo.tblClientes TC ON TV.COD_ID = TC.COD_ID

/*PRODUCTOS CON MAYOR UTILIDAD EN UN RANGO DE FECHAS*/

--SETEAR FORMATO DE FECHA
--SET DATEFORMAT ymd --EN
--SET DATEFORMAT dmy --ESP

SELECT TOP 10
	   TV.FECHA,
	   TP.COD_GRUP,
	   TP.NOM_PROD,
	   UTILIDAD = CAST((TVD.CANTIDAD * TVD.VALOR - TVD.CANTIDAD * TVD.COSTO) AS NUMERIC(16,2))
FROM dbo.tblVentas TV 
	INNER JOIN dbo.tblVentas_Detalle TVD ON TV.ID = TVD.ID
	INNER JOIN dbo.tblProductos TP ON TVD.COD_PROD = TP.COD_PROD
WHERE TV.FECHA BETWEEN '2014/01/01' AND '2014/12/31'
--WHERE TV.FECHA BETWEEN '01/01/2014' AND '31/12/2014'
ORDER BY UTILIDAD DESC 


/*TOP 10 VENTAS*/

SELECT TOP 10
	   TV.COD_SUC,
	   TV.FECHA,
	   TV.COD_ID,
	   TC.NOMBRE AS CLIENTE,
	   CAST(TVD.CANTIDAD * TVD.VALOR AS NUMERIC(16,2)) AS VENTA
FROM dbo.tblClientes TC 
	INNER JOIN dbo.tblVentas TV ON TC.COD_ID=TV.COD_ID
	INNER JOIN dbo.tblVentas_Detalle TVD ON TV.ID = TVD.ID
ORDER BY VENTA DESC


/*LEFT OUTER JOIN, CLIENTES QUE NO HAN REALIZADO NINGUNA COMPRA*/
SELECT *
FROM dbo.tblClientes TC
LEFT OUTER JOIN dbo.tblVentas TV ON TC.COD_ID = TV.COD_ID
WHERE TV.ID IS NULL
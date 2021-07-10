
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


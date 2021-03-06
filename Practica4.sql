/*Update con inner join*/

SELECT * --INTO dbo.tblProductos005
FROM dbo.tblProductos TP WHERE TP.COD_LIN = '005'

UPDATE TP
SET TP.cos_prom_c = 0,
	TP.precio_vta = 0
FROM dbo.tblProductos TP
WHERE TP.COD_LIN = '005'

UPDATE TP
SET TP.COS_PROM_C = TP5.COS_PROM_C,
	TP.PRECIO_VTA = TP5.PRECIO_VTA
FROM dbo.tblProductos TP 
	INNER JOIN dbo.tblProductos005 TP5 ON TP.COD_PROD = TP5.COD_PROD


/*Ejemplo 2*/
UPDATE TP
SET PRECIO_VTA = TA.NUEVO_PREC_VTA
FROM dbo.tblProductos TP
	INNER JOIN(
	SELECT TP.COD_PROD,
		   P_UTILIDAD = ROUND((TP.PRECIO_VTA - TP.COS_PROM_C) / TP.PRECIO_VTA * 100,0),
		   D_UTILIDAD = 35 - ROUND((TP.PRECIO_VTA - TP.COS_PROM_C) / TP.PRECIO_VTA * 100,0),
		   TP.PRECIO_VTA,
		   NUEVO_PREC_VTA = TP.PRECIO_VTA * (1+(35-(TP.PRECIO_VTA - TP.COS_PROM_C)/ TP.COS_PROM_C * 100)/100)
	FROM dbo.tblProductos TP
	WHERE TP.COS_PROM_C > 0 AND TP.PRECIO_VTA > 0 AND ROUND((TP.PRECIO_VTA - TP.COS_PROM_C) / TP.PRECIO_VTA * 100,0) < 35
	) TA ON TP.COD_PROD = TA.COD_PROD


/*VARIABLE DE TABLA*/

DECLARE @TBL_ACT AS TABLE(COD_PROD VARCHAR(25), NUEVO_PREC_VTA MONEY)

INSERT INTO @TBL_ACT
SELECT TP.COD_PROD,
	   NUEVO_PREC_VTA = TP.PRECIO_VTA * (1+(35-(TP.PRECIO_VTA - TP.COS_PROM_C)/ TP.COS_PROM_C * 100)/100)
FROM dbo.tblProductos TP
WHERE TP.COS_PROM_C > 0 AND TP.PRECIO_VTA > 0 AND ROUND((TP.PRECIO_VTA - TP.COS_PROM_C) / TP.PRECIO_VTA * 100,0) < 35

UPDATE TP
SET PRECIO_VTA = TA.NUEVO_PREC_VTA
FROM dbo.tblProductos TP
	INNER JOIN @TBL_ACT TA ON TP.COD_PROD = TA.COD_PROD


/*MERGE*/
MERGE dbo.tblproductos Destino
USING dbo.tblproductos005 Origen
ON Destino.COD_PROD = Origen.COD_PROD
WHEN MATCHED AND Destino.COS_PROM_C <> Origen.COS_PROM_C
			 AND Destino.PRECIO_VTA <> Origen.PRECIO_VTA THEN
	 UPDATE SET Destino.COS_PROM_c = Origen.COS_PROM_C, Destino.PRECIO_VTA = Origen.PRECIO_VTA
WHEN NOT MATCHED THEN
	INSERT(COD_PROD,NOM_PROD,COD_GRUP,COD_LIN,MARCA,COS_PROM_C,PRECIO_VTA)
	VALUES(Origen.COD_PROD,Origen.NOM_PROD,Origen.COD_GRUP,Origen.COD_LIN,Origen.MARCA,Origen.COS_PROM_C,Origen.PRECIO_VTA);

/*PIVOT*/
SELECT P.YEAR,P.[1-JANUARY],P.[2-FEBRUARY],P.[3-MARCH],P.[4-APRIL],P.[5-MAY],P.[6-JUNE],P.[7-JULY],P.[8-AUGUST],P.[9-SEPTEMBER]
	   ,P.[10-OCTOBER],P.[11-NOVEMBER],P.[12-DECEMBER]
FROM(
	SELECT YEAR(TV.FECHA) AS YEAR,
		   CAST(MONTH(TV.FECHA) AS varchar(10)) + '-'+ DATENAME(mm,TV.FECHA) AS MES,
		   SUM(TVD.CANTIDAD * TVD.VALOR) AS TOTAL_VENTAS
	FROM dbo.tblVentas TV
	INNER JOIN dbo.tblVentas_Detalle TVD ON TV.ID = TVD.ID
	GROUP BY YEAR(TV.FECHA), MONTH(TV.FECHA),DATENAME(mm,TV.FECHA)
	) S
	PIVOT
	(
		SUM(S.TOTAL_VENTAS) FOR S.MES IN([1-JANUARY],[2-FEBRUARY],[3-MARCH],[4-APRIL],[5-MAY],[6-JUNE],[7-JULY]
										,[8-AUGUST],[9-SEPTEMBER],[10-OCTOBER],[11-NOVEMBER],[12-DECEMBER])
	) AS P


/*CAST*/

SELECT 'LA SUCURSAL ES ' + TV.COD_SUC,
	   'LA VENTA MAXIMA ES '+ CAST(MAX(TVD.CANTIDAD * TVD.VALOR) AS varchar) AS VENTA_MAXIMA,
	   'LA VENTA MINIMA ES '+ CAST(MIN(TVD.CANTIDAD * TVD.VALOR) AS varchar) AS VENTA_MINIMA
FROM dbo.tblVentas TV
INNER JOIN dbo.tblVentas_Detalle TVD ON TV.ID = TVD.ID
GROUP BY TV.COD_SUC

/*CONVERT*/

SELECT 'LA SUCURSAL ES ' + TV.COD_SUC,
	   CONVERT(MONEY,MAX(TVD.CANTIDAD * TVD.VALOR)) AS VENTA_MAXIMA,
	   CONVERT(INT,MIN(TVD.CANTIDAD * TVD.VALOR)) AS VENTA_MINIMA,
	   CONVERT(VARCHAR,GETDATE(),103) AS FECHA_ACTUAL,
	   CONVERT(VARCHAR,GETDATE(),108) AS HORA_ACTUAL,
	   TRY_CONVERT(datetime,'29/02/2015') AS FECHA_PRUEBA
FROM dbo.tblVentas TV
INNER JOIN dbo.tblVentas_Detalle TVD ON TV.ID = TVD.ID
GROUP BY TV.COD_SUC

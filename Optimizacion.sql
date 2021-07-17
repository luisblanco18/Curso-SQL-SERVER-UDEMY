/*1.Optimizar La busqueda A través de indices del campo NOM_PROD de la tabla tblProductos,
 Plan de Ejecución,NON-SARGABLE esta palabra provienen de SARG  que significa Search Argument 
 y se refiere a una clausula WHERE que compara una columna con una constante).*/
--sp_help 'tblproductos'

SET STATISTICS IO ON
SET STATISTICS TIME ON
--DROP INDEX IX_TBLVENTAS_NOM_PROD ON tblProductos
--CREATE INDEX IX_TBLVENTAS_NOM_PROD ON tblProductos (NOM_PROD) WITH (DROP_EXISTING=ON)
--SELECT * FROM tblProductos tp WITH(INDEX(IX_TBLVENTAS_NOM_PROD)) WHERE tp.NOM_PROD LIKE '%carne%'
SELECT * FROM tblProductos tp  WHERE tp.NOM_PROD LIKE 'carne%'
SELECT * FROM tblProductos tp  WHERE SUBSTRING(tp.NOM_PROD,1,5)='carne'

SET STATISTICS IO OFF
SET STATISTICS TIME OFF


/*Comandos Importantes de tablas*/
sp_helpDB 'BDVENTAS'   --muestra info de la bd
SP_HELP 'tblventas'    --muestra info de la tabla
sp_columns 'tblventas' --muestra info de las columnas
sp_msforeachtable 'select * from ?' --hace un select de todas las tabla
sp_msforeachtable 'SP_HELP "?"'    --muestra informacion de todas las tablas
sp_msforeachtable 'SP_MSHELPCOLUMNS "?"' --muestra informacion de todas las tablas

/*DESABILITA RESTRICCIONES Y TRIGGER*/
EXEC sp_msforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'
GO
EXEC sp_msforeachtable 'ALTER TABLE ? DISABLE TRIGGER ALL'
GO
/*BORRADO MASIVO DE INFORMACION*/
EXEC sp_msforeachtable 'BEGIN TRY
							 TRUNCATE TABLE ?
						END TRY
						BEGIN CATCH
							  DELETE FROM ?
						END CATCH '
GO
/*HABILITAR RESTRICCIONES*/
EXEC sp_msforeachtable 'ALTER TABLE ? CHECK CONSTRAINT ALL'
GO
EXEC sp_msforeachtable 'ALTER TABLE ? ENABLE TRIGGER ALL'
GO
sp_msforeachtable 'sp_spaceused "?"' --VER TAMAÑO DE TABLAS




/*Consulta dinamica de indices*/

SELECT  
    'drop index [' + ind.name + '] ON [' + t.name +']' as Borrado,
	 TableName = t.name,
     IndexName = ind.name,
     IndexId = ind.index_id,
     ColumnId = ic.index_column_id,
     ColumnName = col.name,
     ind.*,
     ic.*,
     col.* 
FROM 
     sys.indexes ind 
INNER JOIN 
     sys.index_columns ic ON  ind.object_id = ic.object_id and ind.index_id = ic.index_id 
INNER JOIN 
     sys.columns col ON ic.object_id = col.object_id and ic.column_id = col.column_id 
INNER JOIN 
     sys.tables t ON ind.object_id = t.object_id 
WHERE 
     ind.is_primary_key = 0 
     AND ind.is_unique = 0 
     AND ind.is_unique_constraint = 0 
     AND t.is_ms_shipped = 0 
ORDER BY 
     t.name, ind.name, ind.index_id, ic.index_column_id;

--drop index [IX_Clientes_COD_VEND] ON [tblClientes]
--drop index [IX_Clientes_COD_ZON] ON [tblClientes]
--drop index [IX_Productos_COD_GRUP] ON [tblProductos]
--drop index [IX_Productos_COD_LIN] ON [tblProductos]
--drop index [IX_tblVentas] ON [tblVentas]
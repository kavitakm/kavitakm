CREATE proc [AppAdmin].[ti_analyze_Stats_Mode_sp]  
@schemaname VARCHAR(100),  
@tablename VARCHAR(100),  
@valuecolumn VARCHAR(100),  
@groupcolumns VARCHAR(200)  
AS  
BEGIN 
/**************************************************************************
**  Version                : 1.0       
**  Author                 : Srimathi
** Description             : Calculate Mode
** Date					   : 23-Aug-2019
 
*******************************************************************************/

DECLARE @str NVARCHAR(400);  
  
 IF (LEN(TRIM(@groupcolumns)) = 0 )  
  SET @str = 'SELECT TOP 1 '+ @valuecolumn +' AS mode_value FROM ' + @schemaname +'.' + @tablename + ' GROUP BY ' + @valuecolumn +' ORDER BY COUNT(*) DESC, ' + @valuecolumn + ' DESC';  
 ELSE  
  SET @str = 'SELECT ' + @groupcolumns + ', ' + @valuecolumn + ' AS mode_value FROM  
  (SELECT ' + @groupcolumns + ', ' + @valuecolumn + ', ROW_NUMBER() OVER(PARTITION BY ' + @groupcolumns + ' ORDER BY COUNT(*) DESC, ' + @valuecolumn + ' DESC) AS row_num  
   FROM ' + @schemaname + '.' + @tablename + ' GROUP BY ' + @groupcolumns + ', ' + @valuecolumn + '  ) a   
  WHERE a.row_num = 1';  
  
EXECUTE sp_executesql @str  
END
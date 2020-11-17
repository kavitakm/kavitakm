--exec appadmin.ti_analyze_pivot_sp 'sunitha','testdataload','Laptops IDS','Region'
CREATE PROCEDURE [AppAdmin].[ti_analyze_pivot_sp]  
@schemaname VARCHAR(100),  
@tablename VARCHAR(100),  
@valuecolumn nVARCHAR(100),  
@groupcolumns nVARCHAR(200)  
AS  
BEGIN  
  
/**************************************************************************  
**  Version                : 1.0         
**  Author                 : Srimathi  
** Description             : Pivot aggregated information to show group columns as column header  
** Date        : 23-Aug-2019  

06-Nov-2020		Srimathi		Handle column names with spaces
   
*******************************************************************************/  
DECLARE @cols NVARCHAR(MAX)  
DECLARE @query NVARCHAR(MAX)  

 --SET @query = 'SELECT @cols = STUFF((SELECT  '',''+'+ @groupcolumns +' from (Select Distinct  QUOTENAME(convert(varchar(1000),'  + @groupcolumns + ')) '+ @groupcolumns + ' FROM '  + @schemaname + '.'  + @tablename + ' group by ' + @groupcolumns + ') T order by ' + @groupcolumns  + ' FOR XML PATH(''''), TYPE).value(''.'', ''NVARCHAR(MAX)''),1,1,'''')';   
 
 SET @valuecolumn=QUOTENAME(REPLACE(REPLACE(@valuecolumn,'[',''),']',''));
 SET @groupcolumns=QUOTENAME(REPLACE(REPLACE(@groupcolumns,'[',''),']',''));

 SET @query = 'SELECT @cols = STUFF((SELECT  '','' + QUOTENAME(convert(varchar(1000),'  + @groupcolumns + ',2)) FROM '  + @schemaname + '.'  + @tablename + ' group by ' + @groupcolumns + ' order by ' + @groupcolumns  + ' FOR XML PATH(''''), TYPE).value(''.'', ''NVARCHAR(MAX)''),1,1,'''')';  
 print @query  
 execute sp_executesql @query, N'@cols NVARCHAR(MAX) OUTPUT', @cols OUTPUT;  
  
 SET @query = 'SELECT  ' + @cols + ' FROM (SELECT convert(varchar(1000),'  + @groupcolumns + ',2) ' + @groupcolumns + ', '  + @valuecolumn + ', ROW_NUMBER() OVER(PARTITION BY '  + @groupcolumns + ' ORDER BY '  + @valuecolumn + ') rn FROM '  + @schemaname + '.'  + @tablename + ') x PIVOT (MAX('  + @valuecolumn + ') FOR '  + @groupcolumns + ' IN (' + @cols + ')) p '  
  print @query
execute(@query)  
END
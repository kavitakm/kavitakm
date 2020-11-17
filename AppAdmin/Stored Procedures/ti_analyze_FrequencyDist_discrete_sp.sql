--exec [AppAdmin].[ti_analyze_FrequencyDist_discrete_sp] 'Sandbox','device10062020','Device Name'

CREATE PROCEDURE [AppAdmin].[ti_analyze_FrequencyDist_discrete_sp]
@schemaname VARCHAR(100),
@tablename VARCHAR(100),
@valuecolumn VARCHAR(100)
AS
BEGIN
/**************************************************************************
**  Version                : 1.0       
**  Author                 : Srimathi
** Description             : Data for frequency distribution in case of discrete data
** Date					   : 23-Aug-2019
**Modification History:
*Date		 Modified By    Modified Details
09-oct-2020  sunitha		Tablename and columnName parameters  enclosed with square 
							brackets  to allow space or any secial characters
 
*******************************************************************************/

	DECLARE @str NVARCHAR(2000);
	--Tablename and column name to enclose with square brackets
	SET @tablename=QUOTENAME(REPLACE(REPLACE(@tablename,'[',''),']',''));
	SET @valuecolumn=QUOTENAME(REPLACE(REPLACE(@valuecolumn,'[',''),']',''));

	SET @str = 'SELECT ' + @valuecolumn + ' , COUNT(*) Frequency FROM ' + @schemaname + '.' + @tablename + 
	' GROUP BY ' + @valuecolumn + ' ORDER BY ' + @valuecolumn;
	
	EXECUTE sp_executesql @str;
	

END
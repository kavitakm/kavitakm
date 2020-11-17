--Exec AppAdmin.ti_loadIncrementalData_SP 'Sandbox','Daily_Sales'

CREATE PROCEDURE [AppAdmin].[ti_loadIncrementalData_SP]
( @schema_name varchar(100),
  @table_name varchar(1000)
)
AS
BEGIN
 /* -----------------------------------------------------------------------------------------------   
* Version               1  
* Name                  AppAdmin.ti_loadIncrementalData_SP
* Modified Date			
* Last Modifier			
* Purpose               Created PROC for loading the incremental data using MERGE Statement
* Changes  
*   Ver    DATE           By                           Description  
*   1      13-08-2020  Sunitha Menni 			  Initial Script
* --------------------------------------------------------------------------------------------------  
*/ 
BEGIN TRY

DECLARE  @updatecondition	VARCHAR(MAX)
DECLARE @insertcondition	VARCHAR(MAX)
DECLARE @insert_columns		VARCHAR(MAX)
DECLARE @insertvalues		VARCHAR(MAX) 
DECLARE @merge_SQL			NVARCHAR(MAX)
DECLARE @pk_columncondition VARCHAR(MAX)
DECLARE @target				VARCHAR(1000)=@schema_name+'.'+@table_name
DECLARE @source				VARCHAR(1000)=@schema_name+'.'+@table_name+'_Stage'
DECLARE @ErrorMsg			VARCHAR(MAX)
DECLARE @dropstageSQL		NVARCHAR(MAX)
        --update condition to be used in merge statement
SET @updatecondition=STUFF(
							(
							 SELECT DISTINCT ',' + CAST(column_name+'=Source.'+column_name  AS VARCHAR(MAX))
							 FROM information_Schema.columns 
							 WHERE table_Schema=@schema_name and table_name=@table_name 
							 AND column_name NOT IN (
												SELECT Col.Column_Name from 
													INFORMATION_SCHEMA.TABLE_CONSTRAINTS Tab, 
													INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE Col 
												WHERE 
													Col.Constraint_Name = Tab.Constraint_Name
													AND Col.Table_Name = Tab.Table_Name
													AND Constraint_Type = 'PRIMARY KEY'
													AND Col.Table_Name = @table_name
													)
							 FOR XML PATH('')
							 ),1,1,'')

 SELECT @insert_columns=COALESCE(@insert_columns+',','')+column_name
		,@insertvalues=COALESCE(@insertvalues+',','')+'Source.'+column_name
 FROM information_Schema.columns 
 WHERE table_Schema=@schema_name AND table_name=@table_name

			 --get the primary key columns of a table and form a conditional statement  to be used in MERGE stmt
SELECT @pk_columncondition=COALESCE(@pk_columncondition+',','')+'Target.'+Col.Column_Name+'=Source.'+Col.Column_Name+' and '
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS Tab, 
    INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE Col 
WHERE   Col.Constraint_Name = Tab.Constraint_Name
    AND Col.Table_Name = Tab.Table_Name
    AND Constraint_Type = 'PRIMARY KEY'
    AND Col.Table_Name = @table_name

				--remove last  additional' and' operator appended in the above statement
SELECT @pk_columncondition=trim(left(@pk_columncondition,len(@pk_columncondition)-4))


--create the merge statement by passing the dynamic  input values
SET @merge_SQL='MERGE '+@target+' AS Target
	USING '+@source+' AS Source
	ON '+@pk_columncondition+ '
	
	WHEN MATCHED 
	THEN UPDATE SET 
			'+@updatecondition+'
	WHEN NOT MATCHED THEN 	
		INSERT ('+@insert_columns+'
				)
		VALUES('+@insertvalues+'
			);'

EXECUTE sp_executesql  @merge_SQL 

  --drop  the stage table 
SET @dropstageSQL='IF EXISTS (SELECT 1
           FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_SCHEMA = '''+@schema_name+'''
           AND TABLE_NAME = '''+@table_name+'_Stage'')
 BEGIN
     DROP TABLE '+@schema_name+'.'+@table_name+'_Stage;
	 
 END
;'
EXECUTE sp_executesql  @dropstageSQL 

END TRY 
BEGIN CATCH
		SET @ErrorMsg = Error_Message()
		 Raiserror(@ErrorMsg, 16,1);
END CATCH
  
END
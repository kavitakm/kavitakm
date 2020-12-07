--exec [AppAdmin].[ti_Analyze_Predict_sp] 'Sandbox' ,'RentData_trainingset',7,'dinesh@fivepointfivesolutions.com'  
CREATE   PROCEDURE [AppAdmin].[ti_Analyze_Predict_sp]      
@SchemaName varchar(100),        
@TableName varchar(100),  
@modelid int,  
@UserEmail varchar(300)  
AS      
BEGIN      
      
/**************************************************************************        
** Version                : 1.0          
** Author                 : Srimathi        
** Description            : Calculate and add predicted column to the table     
** Date					  : 04-Sep-2019        
  
Change History

Date		Author		Change
04/06/2020	Srimathi	Changed Prediction column - decimal precision 2 in place of 6
*******************************************************************************/
--SET NOCOUNT ON
BEGIN TRY
  BEGIN TRANSACTION  
DECLARE @str NVARCHAR(MAX);  
DECLARE @create_str NVARCHAR(MAX);  
DECLARE @alter_str NVARCHAR(MAX);  
DECLARE @depcol varchar(100);  
DECLARE @eqn varchar(1000); 
DECLARE @predictedtable VARCHAR(100);
DECLARE @tablenam varchar(100);
Declare @ErrMsg VARCHAR(1000);
Declare @ErrSeverity VARCHAR(100); 	
/*DECLARE @posnames int;  
DECLARE @poscoeff int;  
DECLARE @endofprevnames int;  
DECLARE @endofprevcoeff int;  
  
 /* Initialise position variables to locate comma in the parameters.  */  
 SET @endofprevnames = 0;  
 SET @endofprevcoeff = 0;  
 SET @str = '';  
  
 /* Extract first independent column name and its coefficient */  
 SET @posnames = CHARINDEX(',',@indcols,1);  
 SET @poscoeff = CHARINDEX(',',@indcoeffs, 1);  
  
 /* Keep extracting independent column names and corresponding coefficient and form the equation in the form m1x1 + m2x2 + .. */  
 WHILE @posnames > 0  
 BEGIN  
  SET @str = @str + '(CONVERT(decimal(18,6),' + SUBSTRING(@indcols, @endofprevnames +1 , @posnames - @endofprevnames-1) + ') * ' +  'CONVERT(decimal(18,6), ' + SUBSTRING(@indcoeffs, @endofprevcoeff +1, @poscoeff - @endofprevcoeff-1) + ')) + ';  
  SET @endofprevnames = @posnames;  
  SET @endofprevcoeff = @poscoeff;  
  SET @posnames = CHARINDEX(',',@indcols,@posnames + 1);  
  SET @poscoeff = CHARINDEX(',',@indcoeffs, @poscoeff + 1);  
 END  
  
 /* Last independent column name and corresponding coefficient */  
 SET @str = @str + '(CONVERT(decimal(18,6),' + SUBSTRING(@indcols, @endofprevnames +1 , len(@indcols) - @endofprevnames) + ') * ' +  'CONVERT(decimal(18,6), ' +  SUBSTRING(@indcoeffs, @endofprevcoeff +1, len(@indcoeffs) - @endofprevcoeff) + '))';  
*/  
 /*create _analyzed table if it doesnt exist */  
 /*
 IF @TableName like '%_analyzed'    
  SELECT @TableNam = SUBSTRING(@TableName,1,charindex('_analyzed',@TableName,1)-1)    
 ELSE    
  SET @TableNam = @TableName;    
    */
 set @predictedtable = @tablename;
 /*
 IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @SchemaName AND TABLE_NAME = @predictedtable)  
 BEGIN  
  SET @CREATE_str = 'SELECT * INTO ' + @SchemaName + '.' + @predictedtable +' FROM ' + @SchemaName + '.' + @TableName;      
  EXECUTE sp_executesql @CREATE_str;      
  INSERT INTO [AppAdmin].[ti_adm_ObjectOwner] (ObjectName, ObjectType, SchemaName, OwnerName, CreatedDate, CreatedBy, LastUpdatedDate, LastUpdatedBy, IsActive) values (@TableName + '_analyzed', 'Table', @SchemaName, @UserEmail, getdate(), @UserEmail, getdate(), @UserEmail, 1);   
  -- calling auto univariate SP for _analyzed table
  exec [AppAdmin].[ti_analyze_AutoUnivariate_sp] @Schemaname, @PREDICTEDTable, @userEmail
 END  
 */
 -- print 'analyzed exists now'
 /* Find Dep Col and equation from the model */  
  
 SELECT @depcol = replace(replace([D],'[',''),']',''), @eqn = [I] + '+' + replace([N],'intercept','')   
  FROM  
(SELECT isnull(dep_ind_flag,'N') dep_ind_flag, string_agg(isnull(cast(convert(float,coefficient) as varchar(24)),'')+ case when dep_ind_flag = 'I' then '*' + variable when dep_ind_flag='D' then variable else '' end ,'+') within group(order by variable) as
 eqn  
  FROM appadmin.ti_adm_regressionmodels where modelid = @modelid group by dep_ind_flag) AS SourceTable    
  PIVOT    
  (    
  max(eqn) FOR dep_ind_flag IN ([I], [D], [N])    
  ) AS PivotTable  
  --print @depcol
  --print @eqn
 /*create prediction column in _analyzed table if it doesnt exist */  
 IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @SchemaName AND TABLE_NAME = @predictedtable AND COLUMN_NAME = @depcol + '_prediction')  
 BEGIN  
  SET @alter_str = 'ALTER TABLE ' + @Schemaname + '.' + @predictedtable + ' ADD [' + @depcol + '_prediction] decimal(18,2)';  
  EXECUTE sp_executesql @alter_str;  
 END  
  
   
 /* Populate the prediction column */  
 SET @str = 'UPDATE ' + @SchemaName + '.' + @predictedtable + ' SET [' + @depcol + '_prediction] = CONVERT(FLOAT, ROUND(' + @eqn + ',2))';  
 --print @str  
 EXECUTE sp_executesql @str;  
 COMMIT TRANSACTION
END TRY 
  BEGIN CATCH
  IF @@trancount>0
	ROLLBACK TRANSACTION
  SET @ErrMsg = ISNULL(LEFT(RTRIM(ERROR_MESSAGE()),1000),'')             
  SET @ErrSeverity=ERROR_SEVERITY()
  RAISERROR(@ErrMsg,@Errseverity,1)
END CATCH    
END
--exec [AppAdmin].[ti_analyze_AutoBivariate_sp] 'Sunitha','TAI_CU','sunitha@tessersinsights.com'
CREATE  PROC [AppAdmin].[ti_analyze_AutoBivariate_sp]          
     @SchemaName VARCHAR(100)
	 ,@TableName VARCHAR(100)          
     ,@UserEmail VARCHAR(100)          
AS          
BEGIN          
/**************************************************************************        
**        
** Version Control Information        
** ---------------------------        
**        
**  Name                   : ti_analyze_AutoBivariate_sp        
**  Version                : 1               
**  Date Created		   : 12-16-2019           
**  Type                   : Stored Procedure        
**  Author                 : Srimathi        
***************************************************************************             
** Description             : <Purpose of SP>        
** Auto Bivariate Analysis stored procedure
**              
** Modification Hist:               
**                    
** Date                           Name                                     Modification
 23-oct-2020					Sunitha							Modified the logic to fix performance issue
 05-Nov-2020					Srimathi						added isNull check before updating TAI Enabled flag
 09-Nov-2020					Srimathi						DATEDIFF_BIG instead of DATEDIFF()
*******************************************************************************/   
 --SET NOCOUNT ON  
BEGIN TRY  
  BEGIN TRANSACTION   
DECLARE @id INT=1;  
DECLARE @columnName nVARCHAR(100),@ColumnAlias VARCHAR(100);  
DECLARE @col1 VARCHAR(100), @col2 VARCHAR(100);
DECLARE @col1_dt VARCHAR(100), @col2_dt VARCHAR(100);
DECLARE @swap VARCHAR(100);
DECLARE @col1_catorNum VARCHAR(1);
DECLARE @col2_catorNum VARCHAR(1);
Declare @ErrMsg VARCHAR(1000);  
Declare @ErrSeverity VARCHAR(100);  
DECLARE @UserID int
DECLARE @ObjectID int
DECLARE @sql_query NVARCHAR(MAX)
DECLARE @ct INT

  SELECT @UserID=AppAdmin.ti_adm_getUserID_fn(@UserEmail);
  SET @ColumnAlias=@ColumnName;
  SELECT @objectID=appadmin.ti_adm_getObjectID_fn(@TableName,'Table',@SchemaName,'','');

  --Update TAI_Enabled flag to 1 in Objectowner table for this table, if not already done
  UPDATE appadmin.ti_adm_ObjectOwner 
	SET TAI_Enabled = 1
	WHERE objectid = @ObjectID
		AND (TAI_Enabled != 1 or TAI_Enabled is null)
		
  --temp table to store all the columns list for the given table  
  IF OBJECT_ID('tempdb.dbo.#columnlisttemp') IS NOT NULL  
	DROP TABLE #columnlisttemp  
  CREATE TABLE #columnlisttemp
  (
   id INT IDENTITY(1,1)
   ,columnName nVARCHAR(100)
   , data_type nVARCHAR(50)
   ,col_cat varchar(10)
  )  
  
    INSERT INTO #columnlisttemp(columnName, data_type,col_cat)  
	SELECT DISTINCT '[' + trim(cols.COLUMN_NAME) + ']' column_name
		, cols.DATA_TYPE 
		, CASE WHEN cols.DATA_TYPE in ('NVARCHAR','VARCHAR','CHAR','NCHAR','DATETIME','SMALLDATETIME','DATE','BIT','DATETIME2') THEN 'C'
		      ELSE 'N'
		  END  
	FROM INFORMATION_SCHEMA.COLUMNS cols     
	INNER JOIN appadmin.ti_adm_objectowner o  
		ON 	o.SCHEMANAME = @SchemaName AND o.objectname = @tablename AND o.objecttype = 'Table' AND o.isactive = 1  
			AND cols.Table_Name = @TableName  AND cols.table_schema = @SchemaName  
			AND charindex('['+trim(cols.column_name)+']', ISNULL(o.maskedColumns,''))=0 
	INNER JOIN (select column1name,objectId,s.[count],s.NoOfUniqueValues  
				FROM AppAdmin.ti_adm_SummaryStatistics s
				WHERE s.objectId = @objectID 	AND s.[count]<>s.Missing AND s.NoOfUniqueValues <>1 AND s.IsActive=1
				)  a
		ON 	a.objectID = o.ObjectID AND a.Column1Name='[' + trim(cols.COLUMN_NAME) + ']' 		  
	WHERE ((cols.DATA_TYPE NOT IN ('NVARCHAR','VARCHAR','CHAR','NCHAR','BIT','INT')) 
			OR 
		   (cols.DATA_TYPE in('NVARCHAR','VARCHAR','CHAR','NCHAR','BIT','INT')  
			AND a.[count] <> a.NoOfUniqueValues
		   ))
	-- To restrict data on the TAI screen to just those with less than 20 categories
		AND ((cols.DATA_TYPE in('NVARCHAR','VARCHAR','CHAR','NCHAR') AND a.NoOfUniqueValues <= 20)  
				OR 	cols.DATA_TYPE NOT in('NVARCHAR','VARCHAR','CHAR','NCHAR'))
		AND NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS Tab         
							 INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE Cons  
								ON Cons.Constraint_Name = Tab.Constraint_Name AND cons.TABLE_SCHEMA = tab.TABLE_SCHEMA    
						WHERE Tab.Table_Name =@TableName  AND tab.table_schema = @SchemaName AND cons.column_name = cols.COLUMN_NAME 
							AND tab.Constraint_Type IN ('PRIMARY KEY', 'FOREIGN KEY')
						)
		AND cols.data_type NOT IN ('geography','varbinary','uniqueidentifier')  


----Check if column is a candidate for timeseries analysis - date column values are equally spaced
  DECLARE @Id_col int
  DECLARE bivariate_list CURSOR
  FOR   SELECT  t1.id,t1.columnName,t1.data_type FROM #columnlisttemp t1 WHERE data_type like '%date%'
  OPEN bivariate_list;
  FETCH NEXT FROM bivariate_list INTO @Id_col,@col1, @col1_dt
  WHILE @@fetch_status = 0
  BEGIN   
  		SET @sql_query = N'SELECT  @cnt = count(distinct DATEDIFF_BIG(second, pDataDate, ' + @col1 + ')) FROM  (SELECT  ' + @col1 + ', LAG(' + @col1 + ') 
		OVER (ORDER BY ' + @col1;
		SET @sql_query = @sql_query + ') pDataDate FROM ' + @SchemaName + '.' + @TableName + ' GROUP BY ' + @col1 + ') q WHERE pDataDate IS NOT NULL'
		EXEC sp_executesql @sql_query, N'@cnt int OUTPUT', @cnt = @ct OUTPUT		
		IF @ct = 1
		  UPDATE #columnlisttemp
		   SET col_cat='T'
		   WHERE id=@Id_col
	FETCH NEXT FROM bivariate_list INTO  @Id_col,@col1, @col1_dt
  END
  CLOSE bivariate_list;
  DEALLOCATE bivariate_list;

  -- Delete existing bivariate entries of the table
  DELETE FROM AppAdmin.ti_adm_bivariateTest_statisticDetails 
  WHERE objectid = @objectID;

-- get all the bivariate combinations to temp table
  IF OBJECT_ID('tempdb.dbo.#bivariate_combinations') IS NOT NULL  
		DROP TABLE #bivariate_combinations
	CREATE TABLE #bivariate_combinations
	(
	ID int identity(1,1),
	col1 nvarchar(100),
	col1_dt nvarchar(50),
	col1_catorNum nvarchar(10),
	col2 nvarchar(100), 
	col2_dt nvarchar(50),
	col2_catorNum nvarchar(10)
	)
  
  INSERT #bivariate_combinations(col1,col1_dt,col1_catorNum,col2,col2_dt,col2_catorNum)
  SELECT t1.columnName, t1.data_type,t1.col_cat, t2.columnName, t2.data_type,t2.col_cat
  FROM 	#columnlisttemp t1, #columnlisttemp t2
  WHERE t1.id < t2.id
  ORDER BY t1.id,t2.id;

--swap the categorical and Numerical combinations to Numeric and Categorical combinations 
	UPDATE #bivariate_combinations
	SET col1_catorNum=col2_catorNum,
		col2_catorNum=col1_catorNum,
		col1=col2,
		col2=col1,
		col1_dt=col2_dt,
		col2_dt=col1_dt
	WHERE col1_catorNum='C' AND col2_catorNum='N'


	INSERT INTO appadmin.ti_adm_bivariateTest_statisticDetails
		(
		  ObjectID
		  ,Column1Name
		  ,Column1Type
		  ,column1Category
		  ,Column2Name
		  ,Column2Type
		  ,column2Category
		  ,CreatedBy
		  ,CreatedDate
		  ,UpdatedBy
		  ,UpdatedDate
		  ,IsActive
		 )
	SELECT  DISTINCT 
		  @objectID
		  ,col1
		  ,col1_dt
		  ,col1_catorNum
		  ,col2
		  ,col2_dt
		  ,col2_catorNum
		  ,@UserID
		  ,getdate()
		 ,@userID,
		  getdate()
		  ,1
	FROM #bivariate_combinations

SELECT * FROM appadmin.ti_adm_bivariateTest_statisticDetails
  WHERE objectID = @ObjectID


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
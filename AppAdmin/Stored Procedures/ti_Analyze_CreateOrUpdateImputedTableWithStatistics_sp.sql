--Exec [AppAdmin].[ti_Analyze_CreateOrUpdateImputedTableWithStatistics_sp] 'sandbox','advertising','TV','','radio','','U','TV','230.5','srimathi@tesserinsights.com','230','231','37','38'      

--Exec [AppAdmin].[ti_Analyze_CreateOrUpdateImputedTableWithStatistics_sp] 'sandbox','advertising_test','TV','8.6','radio','17.2','D','','','sunitha@tesserinsights.com','','','',''      
 
      
CREATE PROCEDURE [AppAdmin].[ti_Analyze_CreateOrUpdateImputedTableWithStatistics_sp]         
@SchemaName varchar(100),            
@TableName varchar(100),            
@Column1Name nvarchar(200),          
@Column1Value varchar(max),          
@Column2Name nvarchar(200),          
@column2Value varchar(max),        
@DeleteOrUpdate varchar(2),  -- will take D or U          
@ImputedColumnName nvarchar(200),          
@ImputedValue varchar(max),          
@UserEmail varchar(300),
--outlier range params
@Column1minvalue varchar(max),
@column1maxvalue varchar(max),
@Column2minvalue varchar(max),
@column2maxvalue varchar(max)
AS          
BEGIN          
          
/**************************************************************************   
**        
** Version Control Information        
** ---------------------------        
**        
** Version                : 1.0               
** Author                 : Srimathi            
** Description            : Created Imputed Table - Entry in Object Owner table - Insert rows in ti_adm_SummaryStatistics table    
** Date       : 26-Aug-2019            
** Modification Hist:               
**                    
** Date          Name     Modification                      
18/2/2020	    Sunitha	 update sp to pass outlier range values

*******************************************************************************/  
--SET NOCOUNT ON  
BEGIN TRY  
BEGIN TRANSACTION           

DECLARE @str NVARCHAR(MAX);          
DECLARE @Imputedcol_dt VARCHAR(50);          
DECLARE @col1_dt VARCHAR(50);          
DECLARE @col2_dt VARCHAR(50);          
DECLARE @TableNam varchar(100);          
DECLARE @Object_id as int;          
DECLARE @ImputedObject_id as int;          
DECLARE @Col1Nm VARCHAR(200);          
DECLARE @Col2Nm VARCHAR(200);          
DECLARE @Col1Alias varchar(200);          
DECLARE @Col2Alias varchar(200);          
DECLARE @ImputedTableName varchar(200);          
DECLARE @NumorCat1 varchar(2);          
DECLARE @NumorCat2 varchar(2);       
DECLARE @cat1count int;      
DECLARE @cat2count int;      
DECLARE @totalcount int;    
DECLARE @SQLWhere_Col1 nvarchar(500);  
DECLARE @SQLWhere_Col2 nvarchar(500);  
DECLARE @num_prec1 int;    
DECLARE @num_scale1 INT;    
DECLARE @num_prec2 int;    
DECLARE @num_scale2 INT;   
DECLARE @num_scale_imputed INT;
DECLARE @num_prec_imputed int;
Declare @ErrMsg VARCHAR(1000);  
Declare @ErrSeverity VARCHAR(100); 

SET @ImputedTableName = @TableName      
      
/*Find Datatypes of all columns and identify where Numerical or Categorical */          
SELECT @Imputedcol_DT = DATA_TYPE, @num_prec_imputed = NUMERIC_PRECISION, @num_scale_imputed = numeric_scale 
	FROM INFORMATION_SCHEMA.COLUMNS 
	WHERE TABLE_SCHEMA = @SchemaName 
		AND TABLE_NAME = @TableName 
		AND COLUMN_NAME = replace(replace(@ImputedColumnName,'[',''),']','');          

SELECT @col1_DT = DATA_TYPE, @num_prec1 = NUMERIC_PRECISION,		@num_scale1 = numeric_scale 
	FROM INFORMATION_SCHEMA.COLUMNS 
	WHERE TABLE_SCHEMA = @SchemaName 
		AND TABLE_NAME = @TableName 
		AND COLUMN_NAME = replace(replace(@Column1Name,'[',''),']','');
    
SELECT @col2_DT = DATA_TYPE, @num_prec2 = NUMERIC_PRECISION,		@num_scale2 = numeric_scale  
	FROM INFORMATION_SCHEMA.COLUMNS 
	WHERE TABLE_SCHEMA = @SchemaName 
		AND TABLE_NAME = @TableName 
		AND COLUMN_NAME = replace(replace(@Column2Name,'[',''),']','');       

SELECT @Object_id = [AppAdmin].[ti_adm_getObjectID_fn](@TableName,'TABLE',@SchemaName,'','')
	      
/* If column datatype is int, but the statistics values used for imputation is float, do the required conversion */      
      
if @Imputedcol_dt = 'int'       
	SET @ImputedValue = CONVERT(INT,CONVERT(FLOAT,@imputedvalue))      
if @Imputedcol_dt = 'smallint'       
	SET @ImputedValue = CONVERT(smallint,CONVERT(FLOAT,@imputedvalue))     
if @Imputedcol_dt = 'tinyint'       
	SET @ImputedValue = CONVERT(tinyint,CONVERT(FLOAT,@imputedvalue))      

/*single outlier value*/   
IF (@Column1minvalue='' AND @Column1maxvalue='')
BEGIN
/* Impute the column with new value or delete the records */          
	IF(@col1_dt in ('NVARCHAR','VARCHAR','CHAR','NCHAR','DATETIME','SMALLDATETIME','DATE','BIT','DATETIME2')) 
		SET @SQLWhere_col1=' ISNULL(' + @column1name + ','''') = ISNULL(CONVERT(' + @col1_dt + ', ''' + @Column1Value + '''),'''') ' 
	ELSE 
		if @col1_dt in ('decimal','numeric')  
			SET @sqlwhere_col1 = @column1name + ' = CONVERT(' + @col1_dt + '(' + str(@num_prec1) + ',' + str(@num_scale1) + '), ''' + @Column1Value + ''') ' ; 
		ELSE  
			SET @SQLWhere_col1= @column1name + ' = CONVERT(' + @col1_dt + ', ''' + @Column1Value + ''') ';   

		--SET @str = @str + ' = CONVERT(' + @col1_dt + ', ''' + @Column1Value + ''') ' ;    
	IF ISNULL(@COLUMN1VALUE,'') =''  
		SET @SQLWhere_col1 = @Column1Name + ' IS NULL '  
	
	IF(@col2_dt in ('NVARCHAR','VARCHAR','CHAR','NCHAR','DATETIME','SMALLDATETIME','DATE','BIT','DATETIME2'))  
		SET @SQLWhere_col2=' ISNULL(' + @column2name + ','''') = ISNULL(CONVERT(' + @col2_dt + ', ''' + @Column2Value + '''),'''') ';  
	ELSE 
		if @col2_dt in ('decimal','numeric')
			SET @sqlwhere_col2 = @column2name + ' = CONVERT(' + @col2_dt + '(' + str(@num_prec2) + ',' + str(@num_scale2) + '), ''' + @Column2Value + ''') ' ;  
		ELSE  
			SET @SQLWhere_col2= @column2name + ' = CONVERT(' + @col2_dt + ', ''' + @Column2Value + ''') ';
 	IF ISNULL(@column2Value,'') =''  
		SET @SQLWhere_col2 = @Column2Name + ' IS NULL '  
	
END
------------
/*range outlier values*/  
ELSE 
BEGIN
/* Impute the column with new value or delete the records */          
	IF(@col1_dt in ('NVARCHAR','VARCHAR','CHAR','NCHAR','DATETIME','SMALLDATETIME','DATE','BIT')) 
		SET @SQLWhere_col1=' ISNULL(' + @column1name + ','''') BETWEEN ISNULL(CONVERT(' + @col1_dt + ', ''' + @Column1minValue + '''),'''')  AND ISNULL(CONVERT(' + @col1_dt + ', ''' + @Column1maxValue + '''),'''') '
	ELSE 
		if @col1_dt in ('decimal','numeric')  
			SET @sqlwhere_col1 = @column1name + ' BETWEEN CONVERT(' + @col1_dt + '(' + str(@num_prec1) + ',' + str(@num_scale1) + '), ''' + @Column1minValue + ''') AND CONVERT(' + @col1_dt + '(' + str(@num_prec1) + ',' + str(@num_scale1) + '), ''' + @Column1maxValue + ''') ' 
		else    
			SET @SQLWhere_col1= @column1name + ' BETWEEN CONVERT(' + @col1_dt + ', ''' + @Column1minValue + ''') AND CONVERT(' + @col1_dt + ', ''' + @Column1maxValue + ''')';   
	IF(@col2_dt in ('NVARCHAR','VARCHAR','CHAR','NCHAR','DATETIME','SMALLDATETIME','DATE','BIT'))  
		SET @SQLWhere_col2=' ISNULL(' + @column2name + ','''') BETWEEN ISNULL(CONVERT(' + @col2_dt + ', ''' + @Column2minValue + '''),'''') AND ISNULL(CONVERT(' + @col2_dt + ', ''' + @Column2maxValue + '''),'''') ';  
	ELSE 
		if @col2_dt in ('decimal','numeric')
			SET @sqlwhere_col2 = @column2name + ' BETWEEN CONVERT(' + @col2_dt + '(' + str(@num_prec2) + ',' + str(@num_scale2) + '), ''' + @Column2minValue + ''') AND CONVERT(' + @col2_dt + '(' + str(@num_prec2) + ',' + str(@num_scale2) + '), ''' + @Column2maxValue + ''') ' ;  
		else    
			SET @SQLWhere_col2= @column2name + ' BETWEEN CONVERT(' + @col2_dt + ', ''' + @Column2minValue + ''') AND CONVERT(' + @col2_dt + ', ''' + @Column2maxValue + ''') ';
END

print @sqlwhere_col1
print @sqlwhere_col2
IF @DeleteOrUpdate = 'U'          
BEGIN    
	SET @str = 'UPDATE ' + @SchemaName + '.' + @TableName  + ' SET ' + @ImputedColumnName
	IF @Imputedcol_dt in ('decimal','numeric')
		SET @str = @str + ' = CONVERT(' + @imputedcol_dt + '(' + str(@num_prec_imputed) + ',' + str(@num_scale_imputed) + '), ''' + @ImputedValue + ''')'
	ELSE 
		SET @str = @str + ' = CONVERT(' + @Imputedcol_dt + ', ''' + @ImputedValue + ''')'
	SET @str = @str + ' WHERE '+@SQLWhere_col1 ;  
	IF ISNULL(@Column2name,'') <> ''          
		SET @str = @str + ' AND '+@SQLWhere_col2;  
	print 'UPDATE STRING: ' + @str;      
	EXECUTE sp_executesql @str;       
END          
ELSE          
BEGIN     
	SET @str = 'DELETE FROM ' + @SchemaName + '.' + @imputedtablename + ' WHERE '+@SQLWhere_col1;  
	--print @str;  
	IF ISNULL(@Column2name,'') <> ''          
		SET @str = @str + ' AND ' +@SQLWhere_col2;   
	EXECUTE sp_executesql @str;    
END          
          
           

--------------------------
 
/* Cursor to create copy of existing analysis with imputed table */          
-- print @object_id;      
--print @imputedcolumnname;      
DECLARE imp_cursor CURSOR FOR SELECT COLUMN1NAME, COLUMN2NAME, COLUMN1ALIAS, COLUMN2ALIAS, case when COLUMN1VALUE is null then -1 else 1 end, case when COLUMN2VALUE is null then -1 else 1 end FROM  [AppAdmin].[ti_adm_SummaryStatistics]           
WHERE OBJECTID = @Object_id AND       
(      
(@DeleteOrUpdate = 'U' AND (COLUMN1NAME = @ImputedColumnName OR COLUMN2NAME = @ImputedColumnName))      
OR      
(@DeleteOrUpdate = 'D' -- AND (COLUMN1NAME IN (@Column1Name, @Column2Name) OR COLUMN2NAME IN (@Column1Name, @Column2Name))      
)      
)      
AND ISACTIVE = 1 GROUP BY COLUMN1NAME, COLUMN2NAME, COLUMN1ALIAS, COLUMN2ALIAS, case when COLUMN1VALUE is null then -1 else 1 end, case when COLUMN2VALUE is null then -1 else 1 end;         
      
OPEN imp_cursor;          
FETCH NEXT FROM imp_cursor into @Col1Nm, @Col2Nm, @Col1Alias, @Col2Alias, @cat1count, @cat2count;          
WHILE @@FETCH_STATUS = 0          
BEGIN        
	print @col1nm + ' 2: ' + @col2nm  
	IF @Col2Nm IS NULL AND (@Col1Nm = @ImputedColumnName or @DeleteorUpdate='D')      
	begin      
		DELETE FROM  [AppAdmin].[ti_adm_SummaryStatistics]  WHERE OBJECTID = @Object_id AND column1name = @col1nm and column2name is null and isactive = 1 ;      
		EXEC AppAdmin.ti_adm_analyze_loadSummaryStatistics_Univariate_sp @SchemaName, @TableName, @Col1Nm, @Col1Alias, @UserEmail ;          
	end      
	IF @Col2Nm is not NULL          
	begin      
		SELECT @col1_DT = DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @SchemaName AND TABLE_NAME = @TableNam AND COLUMN_NAME = @Col1Nm;          
		SELECT @col2_DT = DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @SchemaName AND TABLE_NAME = @TableNam AND COLUMN_NAME = @Col2Nm;          
/*      
IF @COL1_DT IN ('Money','Int','TinyInt','bigint','smallint','bit','numeric','small money','float','real','decimal') AND @cat1count=0          
SET @NumorCat1 = 'N'          
ELSE          
SET @NumorCat1 = 'C'          
          
IF @COL2_DT IN ('Money','Int','TinyInt','bigint','smallint','bit','numeric','small money','float','real','decimal')  AND @cat2count = 0       
SET @NumorCat2 = 'N'          
ELSE          
SET @NumorCat2 = 'C'        
--print @Col1Nm; print @NumorCat1; print @Col2Nm; print @NumorCat2  ;*/      
      
		DELETE FROM  [AppAdmin].[ti_adm_SummaryStatistics]  WHERE OBJECTID = @Object_id AND column1name = @col1nm and column2name = @col2nm and isactive = 1 and case when COLUMN1VALUE is null then -1 else 1 end = @cat1count and case when COLUMN2VALUE is null then -1 else 1 end = @cat2count;      
		if @cat1count = -1 and @cat2count = -1      
			EXEC [AppAdmin].[ti_adm_analyze_loadSummaryStatistics_Bivariate_sp] @SchemaName, @TableName , @Col1Nm, 'N', @Col1Alias, @Col2Nm, 'N', @Col2Alias, @UserEmail, 'Yes'          
		if @cat1count = -1 and @cat2count = 1      
			EXEC [AppAdmin].[ti_adm_analyze_loadSummaryStatistics_Bivariate_sp] @SchemaName, @TableName , @Col1Nm, 'N', @Col1Alias, @Col2Nm, 'C', @Col2Alias, @UserEmail, 'Yes'          
		if @cat1count = 1 and @cat2count = -1      
			EXEC [AppAdmin].[ti_adm_analyze_loadSummaryStatistics_Bivariate_sp] @SchemaName, @TableName , @Col1Nm, 'C', @Col1Alias, @Col2Nm, 'N', @Col2Alias, @UserEmail, 'Yes'          
		if @cat1count = 1 and @cat2count = 1      
			EXEC [AppAdmin].[ti_adm_analyze_loadSummaryStatistics_Bivariate_sp] @SchemaName, @TableName , @Col1Nm, 'C', @Col1Alias, @Col2Nm, 'C', @Col2Alias, @UserEmail, 'Yes'          
	End      
	FETCH NEXT FROM imp_cursor into @Col1Nm, @Col2Nm, @Col1Alias, @Col2Alias, @cat1count, @cat2count;          
END          
          
CLOSE imp_cursor;          
DEALLOCATE imp_cursor;  
 
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
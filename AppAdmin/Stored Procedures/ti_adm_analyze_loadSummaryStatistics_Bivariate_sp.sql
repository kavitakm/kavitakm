CREATE   PROC [AppAdmin].[ti_adm_analyze_loadSummaryStatistics_Bivariate_sp]    
     @SchemaName VARCHAR(100),@TableName VARCHAR(100)    
     ,@Column1Name nVARCHAR(100),@Col1NumOrCat VARCHAR(1), @Alias1Name VARCHAR(100),@Column2Name nVARCHAR(100), @Col2NumOrCat VARCHAR(1), @Alias2Name VARCHAR(100),@UserEmail VARCHAR(100), @save VARCHAR(5)    
AS    
BEGIN    
    
/**************************************************************************  
**  Version                : 1.0       
**  Author                 : Srimathi  
** Description             : Calculate statistics for bivariate analysis and load ti_adm_SummaryStatistics table  
** Date                    : 23-Aug-2019  

Date		Change Description							Author
3/10/2020	allowed @save flag to take True/False		Dinesh
3/6/2020	round to 2 decimal places instead of 5		Srimathi
07-oct-2020	 Enclose columnname  and AliasName with 
		square brackets to allow column names with space Sunitha				
05-Nov-2020	Increase precision to 20 to handle bigint	Srimathi
*******************************************************************************/  
--SET NOCOUNT ON  
BEGIN TRY  
  BEGIN TRANSACTION     
DECLARE @query NVARCHAR(MAX);    
DECLARE @Col1_DT VARCHAR(50);    
DECLARE @Col2_DT VARCHAR(50);    
DECLARE @str NVarchar(MAX);  
DECLARE @object_id int;  
Declare @ErrMsg VARCHAR(1000);  
Declare @ErrSeverity VARCHAR(100);  
--Enclose Column and Alias Name to enclose with square brackets
SET @Column1Name=QUOTENAME(REPLACE(REPLACE(@Column1Name,'[',''),']',''));
SET @Alias1Name=QUOTENAME(REPLACE(REPLACE(@Alias1Name,'[',''),']',''));
SET @Column2Name=QUOTENAME(REPLACE(REPLACE(@Column2Name,'[',''),']',''));
SET @Alias2Name=QUOTENAME(REPLACE(REPLACE(@Alias2Name,'[',''),']',''));

EXEC AppAdmin.ti_adm_analyze_loadSummaryStatistics_Univariate_sp @SchemaName, @TableName, @Column1Name, @Alias1Name, @UserEmail    
EXEC AppAdmin.ti_adm_analyze_loadSummaryStatistics_Univariate_sp @SchemaName, @TableName, @Column2Name, @Alias2Name, @UserEmail    
  SELECT @object_id= objectID FROM appAdmin.ti_adm_objectowner   WHERE objectname=@tablename and SchemaName=@schemaName and objectType='Table' and isActive=1  
--Temp table to populate univariate data    
  
IF object_id('tempdb.dbo.#ti_adm_SummaryStatistics') IS NOT NULL    
 DROP TABLE #ti_adm_SummaryStatistics    
SELECT * INTO #ti_adm_SummaryStatistics FROM appadmin.ti_adm_SummaryStatistics WHERE 1=2    
  
  
SELECT @Col1_DT = DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @SchemaName AND TABLE_NAME = @tableName AND COLUMN_NAME = replace(replace(@Column1Name,'[',''),']','')    
SELECT @Col2_DT = DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @SchemaName AND TABLE_NAME = @tableName AND COLUMN_NAME = replace(replace(@Column2Name,'[',''),']','')    
  
SET @query = 'SELECT DISTINCT ''' + isnull(STR(@Object_id),'') + ''' AS ObjectId, ''' + @Column1Name + ''', case when ''' + @Col1_DT + ''' in (''NVARCHAR'',''VARCHAR'',''CHAR'',''NCHAR'',''DATE'',''DATETIME'',''SMALLDATETIME'') OR ''' + @col1NumorCat + ''' = ''C''  THEN isnull(CONVERT(NVARCHAR(4000),' + @Column1Name + '),''Null'') ELSE NULL END,  ''' + @Alias1Name + ''',  ''' + @Column2Name + ''', case when ''' + @Col2_DT + ''' in (''NVARCHAR'',''VARCHAR'',''CHAR'',''NCHAR'',''DATE'',''DATETIME'',''SMALLDATETIME'') OR ''' + @Col2NumOrCat + '''= ''C'' THEN isnull(CONVERT(NVARCHAR(4000),' + @Column2Name + '),''Null'') ELSE NULL END,  ''' +  @Alias2Name + ''', NULL AS CreatedDate, (SELECT userID FROM appadmin.ti_Adm_user_lu WHERE USerEMail=''' +@useremail + ''') AS CreatedBy, NULL as LastUpdatedDate,  (SELECT userID FROM appadmin.ti_Adm_user_lu WHERE USerEMail=''' + @useremail + ''') AS LastUpdatedBy,  1 AS IsActive  FROM ' + @SchemaName + '.' + @TableName;  
--print @object_id  
  
  print @query
  
 IF NOT EXISTS(SELECT * FROM AppAdmin.ti_adm_SummaryStatistics a   
    WHERE ISNULL(a.ObjectID,'')=ISNULL(@object_id,'')   
    and ISNULL(a.Column1Name,'') = ISNULL(@column1Name ,'')   
    AND ISNULL(a.Column2Name,'') = ISNULL(@Column2Name,'')  
    AND ((@Col1NumOrCat = 'N' AND a.column1Value is NULL) OR (@Col1NumOrCat = 'C' AND a.Column1Value is not NULL))  
    AND ((@Col2NumOrCat = 'N' AND a.column2Value is NULL) OR (@Col2NumOrCat = 'C' AND a.Column2Value is not NULL))  )  
BEGIN    
--print 'Row doesnt exist'  
  
INSERT INTO #ti_adm_SummaryStatistics(ObjectID, Column1Name, Column1Value, Column1Alias, Column2Name, Column2Value, Column2Alias, createdDate, createdBy, LastUpdatedDate, LastUpdatedBy, IsActive)     
 EXECUTE sp_executesql @query   
 --print 'Base row inserted'  
   
/* Numerical - Numerical Combination */    
IF (@Col1_Dt in ('Money','Int','TinyInt','bigint','smallint','bit','numeric','small money','float','real','decimal') AND @Col1NumOrCat = 'N' AND @Col2_Dt in ('Money','Int','TinyInt','bigint','smallint','bit','numeric','small money','float','real','decimal') and @Col2NumOrCat = 'N')    
BEGIN    
--PRINT 'N-N'  
 IF OBJECT_ID('tempdb.dbo.#Temp') Is Not Null    
  DROP TABLE #Temp    
 CREATE TABLE #Temp(Correlation Decimal(20,2));    
 INSERT INTO #Temp     
  exec [AppAdmin].[ti_analyze_Stats_correlation_sp] @SchemaName, @TableName, @Column1Name, @Column2Name    
 --select * from #temp;  
 UPDATE #ti_adm_SummaryStatistics    
  
  SET Correlation = tmp.Correlation     
  FROM (SELECT * FROM #temp) tmp    
    
 DROP TABLE #Temp  
END    
ELSE    
/*Numerical - categorical Combination */    
    
IF (  
 @Col1_Dt in ('Money','Int','TinyInt','bigint','smallint','bit','numeric','small money','float','real','decimal')   
 AND @Col1NumOrCat ='N' )  
 AND (  
  @Col2_DT in ('NVARCHAR','VARCHAR','CHAR','NCHAR','DATE','DATETIME','SMALLDATETIME') OR   
  (@Col2_Dt in ('Money','Int','TinyInt','bigint','smallint','bit','numeric','small money','float','real','decimal') AND @Col2NumOrCat = 'C')  
  )    
BEGIN    
-- PRINT 'N-C'  
 IF OBJECT_ID('tempdb.dbo.#Temp1') Is Not Null    
  DROP TABLE #Temp1    
  
CREATE TABLE #Temp1(category NVARCHAR(4000)    
      ,cnt  int    
      ,Complete int    
      ,Missing int    
      ,Noofuniquevalues int    
      ,Mean decimal(20,2)    
      ,HarmonicMean decimal(20,2)    
      ,QuadraticMean decimal(20,2)    
      ,[Sum] decimal(20,2)    
      ,[Min]  decimal(20,2)    
      ,[Max]  decimal(20,2)    
      ,SD  DEcimal(20,2)    
      ,Variance decimal(20,1)    
      )    
    
SET @query = 'SELECT ' + @column2name + ', COUNT(*) Totalcount, COUNT(' + @Column1Name + ') AS non_nullcount, COUNT(*) - COUNT(' + @Column1Name + ') nullcount,  COUNT(DISTINCT ' + @Column1Name +') distinctcount, CONVERT(FLOAT, ROUND(AVG(CONVERT(FLOAT,'+@Column1Name+')), 2)) Mean, CASE WHEN MIN(' +     @Column1Name + ') > 0 THEN CONVERT(FLOAT, ROUND(1 / AVG(1 / (CASE ' + @Column1Name + ' WHEN 0 THEN NULL ELSE CONVERT(FLOAT,' + @Column1Name + ') END)),2)) ELSE NULL END  AS Harmonic_Mean, CONVERT(FLOAT, ROUND(POWER(AVG(POWER(CONVERT(FLOAT,' + @Column1Name+ '    ), 2)), 0.5),2)) AS Quadratic_Mean,  CONVERT(FLOAT, ROUND(SUM(CONVERT(FLOAT,' + @Column1Name + ')),2)) as [Sum], CONVERT(FLOAT, ROUND(MIN(CONVERT(FLOAT,' + @Column1Name + ')),2)) as [Min], CONVERT(FLOAT, ROUND(MAX(CONVERT(FLOAT,' + @Column1Name + ')),2))   as     [Max], CONVERT(FLOAT, ROUND(STDEV(CONVERT(FLOAT,' + @Column1Name + ')),2)) as SD, CONVERT(FLOAT, ROUND(VAR(CONVERT(FLOAT,' + @Column1Name + ')),2)) as Variance   FROM ' + @schemaname + '.' + @tablename + ' GROUP BY ' + @column2name;    
    
--  PRINT @QUERY  
 INSERT INTO #Temp1    
  EXECUTE sp_executesql @query    
--print 'success'  
    
 IF OBJECT_ID('tempdb.dbo.#TempMode') Is Not Null    
  DROP TABLE #TempMode    
 CREATE TABLE #TempMode(Category NVARCHAR(4000), Mode Decimal(20,6))    
    
 INSERT INTO #TempMode EXEC [AppAdmin].[ti_analyze_Stats_Mode_sp] @SchemaName, @TableName, @Column1Name, @column2Name    
    
 UPDATE #ti_adm_SummaryStatistics    
  SET     
   [Count]=tmp.cnt    
  , complete=tmp.Complete    
  , missing = tmp.Missing    
  , noofuniquevalues=tmp.Noofuniquevalues    
  , mean = tmp.Mean    
  , P0=tmp.[Min]    
  , p100 = tmp.[Max]     
  , harmonicmean = tmp.HarmonicMean     
  , QuadraticMean = tmp.QuadraticMean    
  , sum = tmp.[Sum]    
  , min = tmp.[Min]    
  , max=tmp.[Max]    
  , sd = tmp.SD     
  , variance = tmp.Variance    
  , mode = tmode.mode    
  FROM (SELECT * FROM #temp1) tmp, (select * from #TempMode ) tmode WHERE tmp.category = tmode.category  AND COLUMN2VALUE = isnull(tmp.category,'Null')  
    
 DROP TABLE #Temp1  
--percentile Values    
    
    
 IF object_id('tempdb.dbo.#TempPercentile') Is Not Null    
  DROP TABLE #TempPercentile    
    
 CREATE TABLE #TempPercentile(category NVARCHAR(4000)    
       ,P50 Decimal(20,2)    
       ,P25 Decimal(20,2)    
       ,P75 Decimal(20,2)    
       )    
    
SET @str = 'SELECT DISTINCT  ' + @Column2Name + ', CONVERT(FLOAT, ROUND(PERCENTILE_cont(0.5) WITHIN GROUP (ORDER BY ' + @Column1Name + ') OVER (PARTITION BY ' + @Column2Name + '),2)) AS P50    , CONVERT(FLOAT, ROUND(PERCENTILE_cont(0.25) WITHIN GROUP (ORDER BY ' + @Column1Name + ') OVER (PARTITION BY ' + @Column2Name + '),2)) AS P25    , CONVERT(FLOAT, ROUND(PERCENTILE_cont(0.75) WITHIN GROUP (ORDER BY ' + @Column1Name + ') OVER (PARTITION BY ' + @Column2Name + '),2)) AS P75    FROM ' + @schemaname +'.' + @tablename;    
    
  print @str  
    
 INSERT INTO #TempPercentile EXECUTE sp_executesql @str    
    
 UPDATE #ti_adm_SummaryStatistics SET Median = tmp.P50, P50=tmp.P50, P25=tmp.P25, P75=tmp.p75 FROM (SELECT * FROM #TempPercentile) tmp WHERE COLUMN2VALUE = isnull(tmp.category,'Null')  
 DROP TABLE #TempPercentile     
--- select * from #ti_adm_SummaryStatistics  
END    
ELSE    
/*Categorical - Categorical Combination */    
    
--  PRINT 'ELSE'  
IF (  
 @Col1_DT in ('NVARCHAR','VARCHAR','CHAR','NCHAR','DATE','DATETIME','SMALLDATETIME')   
 OR (@Col1_Dt in ('Money','Int','TinyInt','bigint','smallint','bit','numeric','small money','float','real','decimal') AND @Col1NumOrCat = 'C')  
 )   
 AND   
 (  
 @Col2_DT in ('NVARCHAR','VARCHAR','CHAR','NCHAR','DATE','DATETIME','SMALLDATETIME')   
 OR (@Col2_Dt in ('Money','Int','TinyInt','bigint','smallint','bit','numeric','small money','float','real','decimal') AND @Col2NumOrCat = 'C')  
 )     
BEGIN    
  --PRINT 'C-C'  
 IF OBJECT_ID('tempdb.dbo.#Temp2') Is Not Null    
  DROP TABLE #Temp2    
 CREATE TABLE #Temp2(category1 NVARCHAR(4000) , category2 NVARCHAR(4000)  
      ,cnt  int    
      ,Complete int    
      ,Missing int    
      ,Noofuniquevalues int    
    )    
    
SET @query = 'SELECT  ' + @column1name + ', ' + @Column2name + ', COUNT(*) Totalcount, COUNT(' + @Column1Name + ') AS non_nullcount, COUNT(*) - COUNT(' + @Column1Name + ') nullcount,  COUNT(DISTINCT ' + @Column1Name +') distinctcount FROM ' + @schemaname + '.' + @tablename + '   GROUP BY ' + @column1name + ', ' + @column2name;    
--print @query  
 INSERT INTO #Temp2    
  EXECUTE sp_executesql @query    
  
    
 UPDATE #ti_adm_SummaryStatistics    
  SET [count] = tmp.cnt  
  , complete=tmp.Complete    
  , missing = tmp.Missing    
  , noofuniquevalues=tmp.Noofuniquevalues    
  FROM (SELECT * FROM #temp2) tmp WHERE column1value = isnull(tmp.category1,'Null') and column2value = isnull(tmp.category2,'Null')  
   DROP TABLE #Temp2    
END    
    
IF lower(@save) in ('true' ,'Yes')
INSERT INTO AppAdmin.ti_adm_SummaryStatistics(ObjectID,Column1Name,Column1Value,Column2Name,Column2Value,Column3Name,Column3Value,Column4Name,Column4Value,column1Alias,column2Alias, column3Alias, column4Alias,[Count],Complete,Missing,NoOfUniqueValues,Mean
,Median,Mode,P0,P25,P50,P75,P100,WeightedMean,HarmonicMean,QuadraticMean,  [Sum],[Min],[Max],SD,Variance,Correlation,CreatedDate,CreatedBy,LastUpdatedDate,LastUpdatedBy,IsActive)    
 SELECT ObjectID,Column1Name,Column1Value,Column2Name,Column2Value,Column3Name,Column3Value,Column4Name,Column4Value,column1Alias,column2Alias, column3Alias, column4Alias,[Count],Complete,Missing,NoOfUniqueValues,Mean, Median,Mode,P0,P25,P50,P75,P100,WeightedMean, HarmonicMean,QuadraticMean, [Sum],[Min],[Max],SD,Variance,Correlation,getdate(),CreatedBy,getdate(),LastUpdatedBy,IsActive    
 FROM #ti_adm_SummaryStatistics a    
  
 SELECT * FROM #ti_adm_SummaryStatistics  
END    
ELSE  
SELECT * FROM AppAdmin.ti_adm_SummaryStatistics WHERE ObjectID = @object_id AND COLUMN1NAME=@Column1Name AND Column2Name = @Column2Name  
    AND ((@Col1NumOrCat = 'N' AND column1Value is NULL) OR (@Col1NumOrCat = 'C' AND Column1Value is not NULL))  
    AND ((@Col2NumOrCat = 'N' AND column2Value is NULL) OR (@Col2NumOrCat = 'C' AND Column2Value is not NULL))  
  
drop table #ti_adm_summarystatistics  
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

--Exec [AppAdmin].[ti_adm_analyze_loadSummaryStatistics_Univariate_sp] 'Sandbox','tst_convert','cumulative','srimathi@tesserinsights.com'  
    
--EXEC AppAdmin.ti_adm_analyze_loadSummaryStatistics_Univariate_sp 'Sandbox','DimProduct_test','safetystocklevel','stock','sunitha.menni@fivepointfivesolutions.com'            
--select * from appadmin.ti_adm_SummaryStatistics            
CREATE  PROC [AppAdmin].[ti_adm_analyze_loadSummaryStatistics_Univariate_sp]            
     @SchemaName VARCHAR(100)  
  ,@TableName VARCHAR(100)            
     ,@ColumnName nVARCHAR(100)  
  ,@AliasName VARCHAR(100)  
  ,@UserEmail VARCHAR(100)            
AS            
BEGIN            
/**************************************************************************          
**          
** Version Control Information          
** ---------------------------          
**          
**  Name                   : ti_adm_analyze_loadSummaryStatistics_Univariate_sp          
**  Version                : 1                 
**  Date Created     : 19-08-2019             
**  Type                   : Stored Procedure          
**  Author                 : Sunitha          
***************************************************************************           
** Description             : <Purpose of SP>          
** Load ti_adm_SummaryStatistics table                                      
**                 
** Modification Hist:                 
**                      
** Date                           Name                        Modification   
   03-06-2020       Srimathi       Round to 2 decimal instead of 5      
   08-Sep-2020       Srimathi       Enclose tablename within square brackets to allow table names starting with numbers and special characters  
  07-oct-2020      Sunitha       Enclose columnname  and AliasName with square brackets to allow column names with space  
  05-Nov-2020      Srimathi      Increase precision of decimal from 18 to 20 to handle bigint  
  27-Nov-2020       Srimathi       Replaced temp1 to use column datatypes of ti_adm_SummaryStatistics  
  04-Jan-2021       Srimathi       Added isactive = 1 check in select from summarystatistics table (in if condition and in the final select statement)  
  *******************************************************************************/          
 --SET NOCOUNT ON    
BEGIN TRY    
 BEGIN TRANSACTION         
            
 DECLARE @query NVARCHAR(MAX);            
 DECLARE @Col_DT VARCHAR(50);            
 DECLARE @ObjectID int;    
 Declare @ErrMsg VARCHAR(1000);    
 Declare @ErrSeverity VARCHAR(100);    
  
  
 SET @ColumnName=QUOTENAME(REPLACE(REPLACE(@ColumnName,'[',''),']',''));  
 SET @AliasName=QUOTENAME(REPLACE(REPLACE(@AliasName,'[',''),']',''));  
 --Enclose table name within square brackets  
 --SET @TableName = '[' + replace(replace(@TableName,'[',''),']','') + ']'  
  
 --Temp table to populate univariate data            
 IF object_id('tempdb.dbo.#ti_adm_SummaryStatistics') IS NOT NULL            
  DROP TABLE #ti_adm_SummaryStatistics            
 SELECT * INTO #ti_adm_SummaryStatistics FROM appadmin.ti_adm_SummaryStatistics WHERE 1=2            
 SET @ObjectID=(  
     SELECT objectID   
     FROM appAdmin.ti_adm_objectowner              
     WHERE   
      objectname=@tablename   
      and SchemaName=@schemaName   
      and objectType='Table'   
      and isActive=1  
    )            
 INSERT INTO #ti_adm_SummaryStatistics(ObjectID, Column1Name, Column1Alias, createdDate, createdBy, LastUpdatedDate, LastUpdatedBy, IsActive)             
  SELECT   
   @ObjectID AS ObjectId,            
   @ColumnName,            
   @AliasName,            
   NULL AS CreatedDate,            
   (SELECT userID FROM appadmin.ti_Adm_user_lu WHERE USerEMail=@useremail) AS CreatedBy,            
   NULL as LastUpdatedDate,            
   (SELECT userID FROM appadmin.ti_Adm_user_lu WHERE USerEMail=@useremail) AS LastUpdatedBy,            
   1 AS IsActive            
           
 --checks the existence of objectId and Column1Name          
 IF NOT EXISTS(  
     SELECT *   
     FROM AppAdmin.ti_adm_SummaryStatistics a, #ti_adm_SummaryStatistics tmp           
     WHERE   
      ISNULL(a.ObjectID,'')=ISNULL(tmp.ObjectID,'')   
      and ISNULL(a.Column1Name,'') = ISNULL(tmp.Column1Name,'')   
      AND a.ISACTIVE = 1  
     )            
 BEGIN            
  IF OBJECT_ID('tempdb.dbo.#Temp') Is Not Null            
   DROP TABLE #Temp            
  --get the datatype for the input column name           
  SELECT   
   @Col_DT = DATA_TYPE   
   FROM INFORMATION_SCHEMA.COLUMNS   
   WHERE   
    TABLE_SCHEMA = @SchemaName   
    AND TABLE_NAME = @tableName             
    AND COLUMN_NAME = replace(replace(@ColumnName,'[',''),']','')    
  print @col_dt + 'univariate'    
  --Datatype for the given input is non-numeric then populate only count,complete,missing and noofUniqueValues            
  
  --Enclose table name within square brackets -- 8-sep-2020  
  SET @TableName = '[' + replace(replace(@TableName,'[',''),']','') + ']'  
  print @TableNAme;
  IF (@Col_DT in ('NVARCHAR','VARCHAR','CHAR','NCHAR','DATETIME','SMALLDATETIME','DATE','BIT'))            
  BEGIN            
   CREATE TABLE #Temp(  
    cnt  int            
    ,Complete int            
    ,Missing int            
    ,Noofuniquevalues int            
    )            
   SET @query = 'SELECT COUNT(*) Totalcount, COUNT(' + @ColumnName + ') AS non_nullcount, COUNT(*) - COUNT(' + @ColumnName + ') nullcount,  COUNT(DISTINCT ' + @ColumnName +') distinctcount FROM [' + @schemaname + '].' + @tablename + '';              
   print @query          
   INSERT INTO #Temp            
    EXECUTE sp_executesql @query            
             
   UPDATE #ti_adm_SummaryStatistics            
    SET   
     [Count]=tmp.cnt            
     , complete=tmp.Complete            
     , missing = tmp.Missing            
     , noofuniquevalues=tmp.Noofuniquevalues            
    FROM (SELECT * FROM #temp) tmp            
  END            
  ELSE            
  BEGIN            
   --For the numerical datatype we populate all mean,median,mode etc ..          
   IF OBJECT_ID('tempdb.dbo.#Temp1') Is Not Null            
    DROP TABLE #Temp1            
   SELECT   
    [COUNT] as cnt  
    ,Complete  
    ,Missing  
    ,NoOfUniqueValues  
    ,Mean  
    ,HarmonicMean  
    ,QuadraticMean  
    ,[Sum]  
    ,[Min]  
    ,[Max]  
    ,SD  
    ,Variance  
   INTO #Temp1  
   FROM [Appadmin].[ti_adm_SummaryStatistics]  
   where 1=2  
   --Replaced the below create table statement with select * into above  
   /*CREATE TABLE #Temp1( cnt  int            
   ,Complete int            
   ,Missing int            
   ,Noofuniquevalues int            
   ,Mean decimal(20,2)            
   ,HarmonicMean decimal(20,2)            
   ,QuadraticMean decimal(20,2)            
   ,[Sum] decimal(34,2)            
   ,[Min]  decimal(20,2)            
   ,[Max]  decimal(20,2)            
   ,SD  DEcimal(20,2)            
   ,Variance decimal(20,1)            
   )            
   */          
   SET @query = 'SELECT COUNT(*) Totalcount, COUNT(' + @ColumnName + ') AS non_nullcount, COUNT(*) - COUNT(' + @ColumnName + ') nullcount,  COUNT(DISTINCT ' + @ColumnName +') distinctcount, CONVERT(FLOAT, ROUND(AVG(CONVERT(FLOAT,'+@ColumnName+')),2)) Mean
, CASE WHEN MIN(' + @ColumnName + ') > 0 THEN CONVERT(FLOAT, ROUND(1 / AVG(1 / (CASE ' + @ColumnName + ' WHEN 0 THEN NULL ELSE CONVERT(FLOAT,' + @ColumnName + ') END)),2)) ELSE NULL END  AS Harmonic_Mean, CONVERT(FLOAT, ROUND(POWER(AVG(POWER(CONVERT(FLOAT,' + @ColumnName  + '), 2)), 0.5),2)) AS Quadratic_Mean,  CONVERT(FLOAT, ROUND(SUM(CONVERT(FLOAT,' + @ColumnName + ')),2)) as [Sum], CONVERT(FLOAT, ROUND(MIN(CONVERT(FLOAT,' + @ColumnName + ')),2)) as [Min], CONVERT(FLOAT, ROUND(MAX(CONVERT(FLOAT,' + @ColumnName + ')),2)) as [Max], CONVERT(FLOAT, ROUND(STDEV(CONVERT(FLOAT,' + @ColumnName + ')),2)) as SD, CONVERT(FLOAT, ROUND(VAR(CONVERT(FLOAT,' + @ColumnName + ')),2)) as Variance   FROM [' + @schemaname + '].' + @tablename +'';              
   --print  @query;          
   INSERT INTO #Temp1            
    EXECUTE sp_executesql @query            
   --Mode value           
   IF OBJECT_ID('tempdb.dbo.#TempMode') Is Not Null            
    DROP TABLE #TempMode            
   CREATE TABLE #TempMode(Mode Decimal(20,6))            
   INSERT INTO #TempMode   
    EXEC [AppAdmin].[ti_analyze_Stats_Mode_sp] @SchemaName, @TableName, @ColumnName, ''            
            
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
    , mode = (select mode from #TempMode )            
   FROM (SELECT * FROM #temp1) tmp            
            
            
   --percentile Values            
   DECLARE @str NVarchar(MAX);              
   IF object_id('tempdb.dbo.#TempPercentile') Is Not Null            
    DROP TABLE #TempPercentile              
   CREATE TABLE #TempPercentile(  
    P50 Decimal(20,2)            
    ,P25 Decimal(20,2)            
    ,P75 Decimal(20,2)            
    )            
            
   SET @str = 'SELECT CONVERT(FLOAT, ROUND(PERCENTILE_cont(0.5) WITHIN GROUP (ORDER BY ' + @ColumnName + ') OVER (),2)) as P50,  CONVERT(FLOAT, ROUND(PERCENTILE_cont(0.25) WITHIN GROUP (ORDER BY ' + @ColumnName + ') OVER (),2)) as P25,   CONVERT(FLOAT, ROUND(PERCENTILE_cont(0.75) WITHIN GROUP (ORDER BY ' + @ColumnName + ') OVER (),2)) as P75 FROM [' + @schemaname +'].' + @tablename + '';              
  -- print @str;      
   INSERT INTO #TempPercentile            
    EXECUTE sp_executesql @str            
            
   UPDATE #ti_adm_SummaryStatistics             
   SET   
    Median = tmp.P50  
    , P50=tmp.P50  
    , P25=tmp.P25  
    , P75=tmp.p75            
   FROM   
    (SELECT * FROM #TempPercentile) tmp            
          
  END            
            
  INSERT INTO AppAdmin.ti_adm_SummaryStatistics  
   (ObjectID,Column1Name,Column1Value,Column2Name,Column2Value,Column3Name,Column3Value,Column4Name, Column4Value        
   ,column1Alias,[Count],Complete,Missing,NoOfUniqueValues,Mean,Median,Mode,P0,P25,P50,P75,P100,WeightedMean,HarmonicMean        
   ,QuadraticMean,[Sum],[Min],[Max],SD,Variance,Correlation,CreatedDate,CreatedBy,LastUpdatedDate,LastUpdatedBy,IsActive)            
  SELECT ObjectID,Column1Name,Column1Value,Column2Name,Column2Value,Column3Name,Column3Value,Column4Name,Column4Value,        
   column1Alias,[Count],Complete,Missing,NoOfUniqueValues,Mean,Median,Mode,P0,P25,P50,P75,P100,WeightedMean,HarmonicMean,QuadraticMean,            
   [Sum],[Min],[Max],SD,Variance,Correlation,getdate(),CreatedBy,getdate(),LastUpdatedBy,IsActive            
  FROM #ti_adm_SummaryStatistics a            
            
 END         
 drop table #ti_adm_SummaryStatistics      
 print 'univariate ended'    
 SELECT *   
  FROM AppAdmin.ti_adm_SummaryStatistics   
  WHERE   
   ObjectID = @ObjectID     
   and Column1Name=@ColumnName   
   and Column2Name IS NULL    
   AND ISACTIVE = 1  
            
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

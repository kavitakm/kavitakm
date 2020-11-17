--exec [AppAdmin].[ti_analyze_listRegressionModels_sp]  'Sandbox','AdvertisingFinal' 
CREATE    PROC [AppAdmin].[ti_analyze_listRegressionModels_sp]        
@SchemaName VARCHAR(100),        
@TableName VARCHAR(100)   
AS        
BEGIN

/**************************************************************************  
** Version                : 1.0     
** Author                 : Srimathi  
** Description            : List Regression Models that are applicable to a table (input)
** Date					  : 13-Sep-2019  
  
*******************************************************************************/ 
BEGIN TRY
  BEGIN TRANSACTION
	DECLARE @Object_id int;
	DECLARE @ct int;
	DECLARE @ctr int;
	DECLARE @ErrMsg VARCHAR(1000);
	DECLARE @ErrSeverity VARCHAR(100); 
	/* Find Objectid of the table */
	SELECT @Object_id = OBJECTID FROM [AppAdmin].[ti_adm_ObjectOwner] WHERE SCHEMANAME = @SchemaName AND ObjectName = @TableName AND ObjectType = 'Table' and IsActive = 1    
	
	/* Temp table to store all numeric columns of the input table */
	IF OBJECT_ID('tempdb.dbo.#NumColumns') IS NOT NULL
		DROP TABLE #NumColumns
	CREATE TABLE #NumColumns (id INT IDENTITY, col VARCHAR(1000), cols NVARCHAR(1000), dt VARCHAR(100));
	SELECT TOP 1 @ct = count(*) from appadmin.ti_adm_regressionModels group by modelid order by count(*) desc
	INSERT INTO #NumColumns (col,cols,dt)
		EXEC appadmin.ti_analyze_getnumericcolumns_sp @schemaname,@tablename

	/*Delete non-numeric columns from the temp table */

	delete from #NumColumns where dt not in ('Money','Int','TinyInt','bigint','smallint','bit','numeric','small money','float','real','decimal');     
--select * from #NumColumns;

	/* using Recursive CTE to find all possible combinations of numeric columns in the table */

	IF OBJECT_ID('tempdb.dbo.#AllColCombination') IS NOT NULL
		DROP TABLE #AllColCombination;
	WITH Recur(N,Combination) AS 
	(
		SELECT id, CAST(cols AS VARCHAR(1000)) FROM #NumColumns
			UNION ALL
		SELECT n.id,CAST(r.Combination + ',' + n.cols AS VARCHAR(1000)) FROM Recur r INNER JOIN #NumColumns n ON n.id > r.N
	)
	SELECT N, Combination into #AllColCombination FROM Recur; 

--INTERSECT
	
	/* Generate list of all existing models with their equations  */
	
	IF OBJECT_ID('tempdb.dbo.#ExistingModels') IS NOT NULL
		DROP TABLE #ExistingModels
	CREATE TABLE #ExistingModels (modelid INT, objectid INT, modelname VARCHAR(200), ind VARCHAR(1000), dep VARCHAR(100), eqn VARCHAR(1000));
	INSERT INTO #ExistingModels
		SELECT modelid, objectid, modelname, substring([I],1,charindex('|',[I])-1) AS ind , [D], substring([I],charindex('|',[I])+1,len([I])) + '+' + replace([N],'intercept','')  eqn
		FROM
		(
			SELECT modelid, objectid, modelname, isnull(dep_ind_flag,'N') dep_ind_flag, case when dep_ind_flag='I' then string_agg(variable,',') within group(order by variable) + '|' else '' end + string_agg(isnull(cast(convert(float,coefficient) as varchar(24)),'')+variable,'+') within group(order by variable) as eqn
			FROM appadmin.ti_adm_regressionmodels  group by modelid,objectid, modelname, dep_ind_flag
		) AS SourceTable  
		PIVOT  
		(  
			max(eqn) FOR dep_ind_flag IN ([I], [D], [N])  
		) AS PivotTable

	/* Join #NumColumns and #ExistingModels to list the models applicable to the table */

	SELECT m.modelid, m.modelname ModelName, o.SchemaName, o.ObjectName AS TableName , m.ind AS IndCols, m.dep DepCol, 
		m.dep + ' = ' + replace(m.eqn,'+-','-') Equation 
		FROM #AllColCombination t, #ExistingModels m, appadmin.ti_adm_ObjectOwner o 
		WHERE replace(replace(t.combination,'[',''),']','') = m.ind and m.objectid = o.objectid
		--and o.ObjectID=@Object_id

	DROP TABLE #NumColumns;
	DROP TABLE #AllColCombination;
	DROP TABLE #ExistingModels;

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
CREATE   PROCEDURE [AppAdmin].[ti_Analyze_loadRegressionModels_sp]    
@SchemaName varchar(100),      
@TableName varchar(100),
@ModelName varchar(100),
@indcols VARCHAR(1000), --comma separated
@indcoeffs VARCHAR(1000), -- comma separated
@depcol	VARCHAR(100),
@intercept DECIMAL(18,6),
@rsquare decimal(18,5),
@UserEmail varchar(300)
AS    
BEGIN    
    
/**************************************************************************      
** Version                : 1.0         
** Author                 : Srimathi      
** Description            : Load Regression Models  
** Date					  : 13-Sep-2019      
   History:
   17/12/2019-  sunitha -insert an entry into objectowner table and update the regression table with 
   30/1/2020	Srimathi	Added rsquare parameter
   2/3/2020		Srimathi	Changed functionality to make column combination unique - 
							if column combination exists, the coefficients, objectid, modelname will get overwritten
*******************************************************************************/ 
--SET NOCOUNT ON
BEGIN TRY
  BEGIN TRANSACTION

DECLARE @str NVARCHAR(MAX);
DECLARE @create_str NVARCHAR(MAX);
DECLARE @alter_str NVARCHAR(MAX);
DECLARE @posnames int;
DECLARE @poscoeff int;
DECLARE @endofprevnames int;
DECLARE @endofprevcoeff int;
DECLARE @modelid int;
DECLARE @indcolname varchar(100);
DECLARE @indcoeffvalue decimal(18,6);
DECLARE @object_id int;
DECLARE @table_indcols varchar(1000);
DECLARE @table_indcoeffs varchar(1000);
DECLARE @table_depcols VARCHAR(100);
DECLARE @table_intercept DECIMAL(18,6);
DECLARE @ct_tbl int;
DECLARE @ct_temp int;
DECLARE @modelid_tbl int;
DECLARE @ErrMsg VARCHAR(1000);
DECLARE @ErrSeverity VARCHAR(100); 
DECLARE @UserID INT;
DECLARE @ObjectID_new INT;

	/* Initialise position variables to locate comma in the parameters.  */
	SET @endofprevnames = 0;
	SET @endofprevcoeff = 0;
	SET @str = '';

	/* Extract first independent column name and its coefficient */
	SET @posnames = CHARINDEX(',',@indcols,1);
	SET @poscoeff = CHARINDEX(',',@indcoeffs, 1);

	/* Find max model id from table */
	SELECT @modelid = max(modelid) from appadmin.ti_adm_RegressionModels;
	SET @modelid = isnull(@modelid,0) + 1;

	/* Find Objectid of the table */
	SELECT @Object_id = [AppAdmin].[ti_adm_getObjectID_fn](@TableName,'Table',@SchemaName,'','') 
	
	SELECT @UserId = [AppAdmin].[ti_adm_getUserID_fn](@userEmail)
	
	/* create temp table */
	IF OBJECT_ID('tempdb.dbo.#temp') IS NOT NULL
		DROP TABLE #temp
	CREATE TABLE #temp 
		(
			Objectid int
			, Dep_flag char(1)
			, cols varchar(100)
			, coefficient decimal(18,6)
		);

	/* Keep extracting independent column names and corresponding coefficient and form the equation in the form m1x1 + m2x2 + .. */
	WHILE @posnames > 0
	BEGIN
		SET @indcolname = SUBSTRING(@indcols, @endofprevnames +1 , @posnames - @endofprevnames-1);
		SET @indcoeffvalue = CONVERT(decimal(18,6),CONVERT(float,SUBSTRING(@indcoeffs, @endofprevcoeff +1, @poscoeff - @endofprevcoeff-1)));
		insert into #temp values(@object_id, 'I', @indcolname, @indcoeffvalue);
		SET @endofprevnames = @posnames;
		SET @endofprevcoeff = @poscoeff;
		SET @posnames = CHARINDEX(',',@indcols,@posnames + 1);
		SET @poscoeff = CHARINDEX(',',@indcoeffs, @poscoeff + 1);
	END

	/* Last independent column name and corresponding coefficient */
	SET @indcolname = SUBSTRING(@indcols, @endofprevnames +1 , len(@indcols) - @endofprevnames);
	SET @indcoeffvalue = CONVERT(decimal(18,6),CONVERT(float,SUBSTRING(@indcoeffs, @endofprevcoeff +1, len(@indcoeffs) - @endofprevcoeff)));
	insert into #temp values(@object_id, 'I', @indcolname, @indcoeffvalue);

	/* Insert Dependent value */
	insert into #temp values(@object_id, 'D', @depcol, null);

	/*check if model already exists */
		
	SELECT @modelid_tbl = a.modelid 
	FROM
		(
			SELECT modelid, [I],[D]  
			FROM  
				(SELECT modelid,dep_ind_flag, string_agg(variable,',') within group(order by variable) as v   
				FROM appadmin.ti_adm_regressionmodels 
				--where objectid=@object_id   Commented by Srimathi on 2-Mar-2020
				group by modelid, dep_ind_flag) AS SourceTable  
				PIVOT  
				(  
					max(v) FOR dep_ind_flag IN ([I], [D])  
				) AS PivotTable) a,
			(SELECT [I],[D]  
			FROM  
				(SELECT dep_flag, string_agg(cols,',') within group(order by cols) as v   
				FROM #temp group by dep_flag) AS SourceTable  
				PIVOT  
				(  
				max(v) FOR dep_flag IN ([I], [D])  
				) AS PivotTable) b
			WHERE a.[I] = b.[I] and a.[D]=b.[D];
	
	IF @modelid_tbl IS NULL
	BEGIN
		--load objectowner table with the modelname
		INSERT INTO AppAdmin.ti_adm_ObjectOwner(ObjectName,ObjectType,CreatedDate,LastUpdatedDate,IsActive,CreatedBy,LastUpdatedBy)
			SELECT @ModelName,'Linear Regression Model',getdate(),getdate(),1,@UserID,@UserID

		--objectID_new for modelID
		SELECT @ObjectID_new=objectID 
			FROM AppAdmin.ti_adm_ObjectOwner
			WHERE 
				ObjectName=@ModelName 
				AND IsActive=1
				AND ObjectType='Linear Regression Model'

		INSERT INTO appadmin.ti_adm_regressionModels 
			SELECT @ObjectID_new, @modelname, @object_id, cols, dep_flag, coefficient, 'v1', @rsquare FROM #temp
		INSERT INTO appadmin.ti_adm_regressionModels 
			VALUES(@ObjectID_new, @modelname, @object_id, 'intercept',null,@intercept,'v1', @rsquare);
	END
	ELSE
	BEGIN
			UPDATE appadmin.ti_adm_regressionModels 
				SET coefficient = a.coefficient, modelname = @modelname, rsquare = @rsquare 
				,objectid = @object_id --Added by Srimathi on 2-MAR-2020
				FROM appadmin.ti_adm_regressionModels t, #temp a 
				WHERE 
					t.modelid=@modelid_tbl 
					--AND t.objectid = @object_id  Commented by Srimathi on 2-Mar-2020
					AND t.variable = a.cols;
			UPDATE appadmin.ti_adm_regressionModels 
				SET coefficient = @intercept, modelname = @modelname, rsquare = @rsquare 
				,objectid = @object_id --Added by Srimathi on 2-MAR-2020
				WHERE 
					modelid = @modelid_tbl 
					--AND objectid=@object_id  Commented by Srimathi on 2-Mar-2020
					AND variable ='intercept';
			UPDATE appadmin.ti_adm_objectowner
				SET 
					OBJECTNAME = @modelname
					, lastupdatedBy = @UserID
					, lastupdatedDate = getdate()
				WHERE objectid = @modelid_tbl
		END
		DROP TABLE #temp;
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
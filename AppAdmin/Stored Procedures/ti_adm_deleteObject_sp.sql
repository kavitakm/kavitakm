CREATE PROCEDURE  [AppAdmin].[ti_adm_deleteObject_sp]                     
@ObjectName Varchar(200),              
@ObjectType Varchar(50),              
@SchemaName Varchar(50),              
@ObjectLocation VARCHAR(200),  
@FileExt Varchar(10),  
@UserEmail Varchar(150)                 
               
AS                  
BEGIN     
  
/**************************************************************************    
** Version                : 1.0     
** Author                 : Srimathi    
** Description            : Delete an object from Object Owner, Grant Access table, Summary Statistics and Integrate
** Date					  : 21-Oct-2019    
 **Modification History
 **28/2/2020 Sunitha  Added delete logic to remove auto			                    bivariate statistics from                                ti_adm_bivariateTest_statisticDetails                     table
 31/3/2021	 Srimathi Drop table only if it exists - to handle backend deletes (enterprise data)

*******************************************************************************/    
DECLARE @userid int;  
Declare @ObjectID int;
DECLARE @tblname VARCHAR(100);
DECLARE @log VARCHAR(200);
DECLARE @str NVARCHAR(500);
 
	SET @tblname = '[' + @SchemaName + '].[' + @objectname + ']';
	SELECT @userid = userid from appadmin.ti_adm_user_lu where useremail = @useremail and isactive=1;  
	SELECT @ObjectID = ObjectID FROM [AppAdmin].[ti_adm_ObjectOwner] WHERE ISNULL(SchemaName,'') = @SchemaName AND ISNULL(ObjectLocation,'') = @ObjectLocation AND ObjectName = @ObjectName AND ISNULL(fileext,'') = @FileExt and objectType = @ObjectType AND IsActive = 1  ;

	BEGIN TRANSACTION DeleteObject WITH MARK N'Deleting an object';
	BEGIN TRY
		IF @ObjectType = 'TABLE'
		BEGIN
		--IF EXISTS (SELECT 1 FROM [AppAdmin].[ti_adm_ObjectOwner] WHERE SchemaName = @SchemaName AND ObjectLocation = @ObjectLocation AND ObjectName = @ObjectName AND fileext = @FileExt AND objectType = @ObjectType AND IsActive = 1)  
			IF @ObjectID IS NOT NULL
			BEGIN  
			print @objectid
				SET @log = 'updating active Transform that refer to table ' + @tblname;
				UPDATE APPADMIN.TI_ADM_TRANSFORM SET to_be_validated = 1 FROM appadmin.ti_adm_ObjectOwner o WHERE TI_ADM_TRANSFORM.ObjectId = o.ObjectID AND o.isactive = 1 AND CHARINDEX(@tblname, transformquery) > 0;
				
				SET @log = 'deleting grant entries of all versions of the table ' + @tblname;
				DELETE APPADMIN.ti_adm_ObjectAccessGrant WHERE ObjectID in (select objectid from appadmin.ti_adm_ObjectOwner where schemaname = @schemaname and objectname = @objectname and objecttype ='TABLE') ;
				
				SET @log = 'deleting integrate entries using the table ' + @tblname;
				DELETE APPADMIN.ti_adm_integrate WHERE OBJECTID in (select objectid from appadmin.ti_adm_ObjectOwner where schemaname = @schemaname and objectname = @objectname and objecttype ='TABLE') ;

				SET @log = 'deleting statistics associated with table ' + @tblname;
				DELETE APPADMIN.ti_adm_SummaryStatistics WHERE OBJECTID in (select objectid from appadmin.ti_adm_ObjectOwner where schemaname = @schemaname and objectname = @objectname and objecttype ='TABLE') ;

				SET @log = 'deleting auto bivariate statistics associated with table ' + @tblname;
			    DELETE APPADMIN.ti_adm_bivariateTest_statisticDetails WHERE OBJECTID in (select objectid from appadmin.ti_adm_ObjectOwner where schemaname = @schemaname and objectname = @objectname and objecttype ='TABLE') ;
				
				SET @log = 'pointing models associated with the table ' + @tblname + ' to NULL';
				UPDATE appadmin.ti_adm_RegressionModels SET objectid = NULL WHERE OBJECTID = @ObjectID;

				SET @log = 'deleting object owner entry of the table ' + @tblname;
				DELETE APPADMIN.ti_adm_ObjectOwner WHERE SChemaname = @schemaname and objectname = @objectname and objecttype ='TABLE';

				SET @log = 'dropping the table ' + @tblname;
				SET @str = 'DROP TABLE IF EXISTS ' + @tblname;
				EXECUTE sp_executesql @str;
			END
		END
		IF @ObjectType = 'FILE'
		BEGIN
			SET @log = 'deleting grant entries for all versions of the file ' + @objectname + '.' + @fileext;
				DELETE APPADMIN.ti_adm_ObjectAccessGrant WHERE ObjectID in (select objectid from appadmin.ti_adm_ObjectOwner where ObjectLocation = @ObjectLocation AND FileExt = @FileExt and objectname = @objectname and objecttype ='FILE') ;
			SET @log = 'deleting object owner entries for all versions of the file ' + @objectname + '.' + @fileext
				DELETE APPADMIN.ti_adm_ObjectOwner WHERE OBJECTID in (select objectid from appadmin.ti_adm_ObjectOwner where ObjectLocation = @ObjectLocation AND FileExt = @FileExt and objectname = @objectname and objecttype ='FILE') ;
		END
		IF @ObjectType IN('TRANSFORM','CLEANSE')
		BEGIN
			SET @log = 'deleting grant entries for the transform ' + @ObjectName ;
				DELETE APPADMIN.ti_adm_ObjectAccessGrant WHERE ObjectID in (select objectid from appadmin.ti_adm_ObjectOwner where objectname = @objectname and objecttype =@objecttype)  ;
			SET @log = 'deleting all entries of the transform ' + @ObjectName ;
				DELETE APPADMIN.ti_adm_transform WHERE ObjectID in (select objectid from appadmin.ti_adm_ObjectOwner where objectname = @objectname and objecttype =@objecttype)  ;
			SET @log = 'deleting object owner entries of all versions of the transform ' + @objectname;
				DELETE APPADMIN.ti_adm_ObjectOwner WHERE objecttype  = @ObjectType AND OBJECTNAME = @objectname;
		END
		IF @ObjectType = 'INTEGRATE'
		BEGIN
			SET @log = 'deleting integrate ' + @objectname;
				DELETE APPADMIN.ti_adm_integrate WHERE APINAME = @ObjectName 
		END
	END TRY
	BEGIN CATCH
		SELECT 'Error while ' + @log custom_error, ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE();
		ROLLBACK TRANSACTION;
	END CATCH
	IF @@TRANCOUNT > 0  -- No errors caught
		COMMIT TRANSACTION;

END  
GO



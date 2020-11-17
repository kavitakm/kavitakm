CREATE  PROCEDURE [AppAdmin].[ti_catalog_copytblTotbl_sp]    
@ToSchemaName VARCHAR (50), @ToTableName VARCHAR (50), @FromSchemaName VARCHAR (50), @FromTableName VARCHAR (50), @UserEmail VARCHAR (150)    
AS    
BEGIN    
    DECLARE @str AS NVARCHAR (MAX);    
    DECLARE @maskedCols AS VARCHAR (MAX);    
    DECLARE @ErrMsg AS VARCHAR (1000);    
    DECLARE @ErrSeverity AS VARCHAR (100);    
    BEGIN TRY    
        BEGIN TRANSACTION;    
        SELECT @maskedCols = maskedColumns    
        FROM   APPADMIN.ti_adm_ObjectOwner    
        WHERE  OBJECTNAME = @FromTableName    
               AND SCHEMANAME = @FromSchemaName    
               AND OBJECTTYPE = 'Table'    
               AND ISACTIVE = 1;    
        SET @str = ' DROP TABLE IF EXISTS [' + @ToSchemaName + '].[' + @ToTableName + ']; SELECT * INTO [' + @ToSchemaName + '].[' + @ToTableName + '] FROM [' + @FromSchemaName + '].[' + @FromTableName + ']';    
        
		EXECUTE sp_executesql @str;    
        EXECUTE appadmin.ti_adm_CreateOrUpdateObjectOwner_sp 0, @ToTableName, 'Table', @ToSchemaName, '', '', 0, @maskedCols, @UserEmail;    
        EXECUTE appadmin.ti_analyze_AutoUnivariate_sp @ToSchemaName, @ToTableName, @UserEmail;    
        COMMIT TRANSACTION;    
    END TRY    
    BEGIN CATCH    
        IF @@trancount > 0    
            ROLLBACK;    
        SET @ErrMsg = ISNULL(LEFT(RTRIM(ERROR_MESSAGE()), 1000), '');    
        SET @ErrSeverity = ERROR_SEVERITY();    
        RAISERROR (@ErrMsg, @Errseverity, 1);    
    END CATCH    
END
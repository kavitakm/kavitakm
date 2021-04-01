-- exec [AppAdmin].[ti_adm_GetAllObjectOwnerIntermediateDetails]
CREATE PROCEDURE [AppAdmin].[ti_adm_GetAllObjectOwnerIntermediateDetails]
As
Begin

 
/**************************************************************************    
** Version                : 1.0     
** Author                 : Dinesh    
** Description            : Send details of tables created/deleted after the previous run of timer trigger (isactive = 1)
** Date					  : 21-Mar-2021
 **Modification History
 **
 31/3/2021	 Srimathi Send only those that are existing - to handle deletes that happen within a single run window

*******************************************************************************/    
        DECLARE @ErrMsg AS VARCHAR (1000);
        DECLARE @ErrSeverity AS VARCHAR (100);

BEGIN TRY
		--the below update doesnt work as expected when SP is called from API.  So, this 
	--check will be handled in API

	/*
	UPDATE [AppAdmin].[ti_adm_ObjectOwner_Intermediate] 
	SET ISACTIVE = 0
	WHERE --OBJECT_ID(SchemaName+'.['+objectname+']', 'U') IS NULL
	NOT EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = schemaname
                 AND  TABLE_NAME = objectname)
				 
	ISACTIVE = 1
	and delete_flag = 1
	*/

	Select ObjectID,
	ObjectName,
	ObjectType,
	SchemaName,
	SCHEMA_ID(SchemaName) as SchemaID,
	CreatedDate,
	CreatedBy,
	UserEmail,
	delete_flag
	FROM [AppAdmin].[ti_adm_ObjectOwner_Intermediate]
	Where IsActive =1
	END TRY
    BEGIN CATCH
        IF @@trancount > 0
            ROLLBACK;
        SET @ErrMsg = ISNULL(LEFT(RTRIM(ERROR_MESSAGE()), 1000), '');
        SET @ErrSeverity = ERROR_SEVERITY();
        RAISERROR (@ErrMsg, @Errseverity, 1);
    END CATCH
End
GO

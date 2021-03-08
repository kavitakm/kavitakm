ALTER PROCEDURE [AppAdmin].[ti_adm_CreateOrUpdateObjectOwner_sp]
	@ID INT
	, @ObjectName VARCHAR (200)
	, @ObjectType VARCHAR (50)
	, @SchemaName VARCHAR (50)
	, @ObjectLocation VARCHAR (200)
	, @FileExt VARCHAR (10)
	, @FileSize INT
	, @MaskedColumns VARCHAR (MAX)
	, @UserEmail VARCHAR (150)
	, @LoadType INT = 1
	, @FileDelimiter INT = null
AS
BEGIN

/******************************************************
** Version               : 1.0               
** Author                : 
** Description           : Create or Update Object Owner entries
** Date					 : 19-12-2019  
**Modification History
19-02-2020	Srimathi	Modified to return Object ID
22-01-2020	Srimathi	Modified code to handle just Save scenario - target object id = 0
19-12-2019	Sunitha		Added default Favourite flag column value to zero  in ti_Adm_objectowner and objectAccessGrant table
28-02-2020	Srimathi	Favourite flag and TAIEnabled flag taken from existing Objectowner entry of the object (if exists) and moved to new entry
26-08-2020	Srimathi	Added LoadType parameter
14-12-2020	Srimathi	Owner id modified to be taken from previous entry of object
04-01-2021	Srimathi	In case of updating object owner info, update status of active Summary statistics records to inactive (set isactive = 0)
18-02-2021  Dinesh      File Delimiter Param added.
*******************************************************/ 

    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @tblname AS VARCHAR (100);
        DECLARE @userid AS INT;
        DECLARE @flag AS INT;
        DECLARE @ErrMsg AS VARCHAR (1000);
        DECLARE @ErrSeverity AS VARCHAR (100);
		DECLARE @TAI_Enabled INT = 0;
		DECLARE @fav_flag INT = 0;
		DECLARE @owner INT;

        SET @flag = 0;

        SELECT @userid = userid
        FROM   appadmin.ti_adm_user_lu
        WHERE  useremail = @useremail
               AND isactive = 1;

		--By default, user is the owner of object
		SET @owner = @userid;

        IF (@ID = 0)
        BEGIN
			DECLARE @ObjectID AS INT;
            DECLARE @objectid_new AS INT;
            IF EXISTS (SELECT 1
				FROM   [AppAdmin].[ti_adm_ObjectOwner]
                WHERE  SchemaName = @SchemaName
					AND ObjectLocation = @ObjectLocation
					AND ObjectName = @ObjectName
                    AND FileExt = @FileExt
                    AND objectType = @ObjectType
                    AND IsActive = 1)
            BEGIN
				SET @flag = 1;
                SELECT @ObjectID = ObjectID
						,@TAI_Enabled = TAI_Enabled 
						,@fav_flag = Favourite
						,@owner = CreatedBy
					FROM   [AppAdmin].[ti_adm_ObjectOwner]
                    WHERE  SchemaName = @SchemaName
						AND ObjectLocation = @ObjectLocation
                        AND ObjectName = @ObjectName
                        AND FileExt = @FileExt
                        AND objectType = @ObjectType
                        AND IsActive = 1;
                IF Upper(@ObjectType) IN ('TRANSFORM', 'CLEANSE')
					SELECT *
						INTO   #transform_tmp
						FROM   appadmin.ti_adm_transform
                        WHERE  OBJECTID = @ObjectID;
                ELSE
					SELECT *
					INTO   #transformtarget_tmp
					FROM   appadmin.ti_adm_transform
					WHERE  targetobjectid = @ObjectID;
				SELECT *
                INTO   #grant_tmp
                FROM   appadmin.ti_adm_ObjectAccessGrant
                WHERE  ObjectID = @ObjectID
                        AND isactive = 1;
                UPDATE [AppAdmin].[ti_adm_ObjectOwner]
                    SET    ISACTIVE        = 0,
                            LastUpdatedDate = GETDATE(),
                            LastUpdatedBy   = @userid
                    WHERE  ObjectID = @ObjectID;
                IF (Upper(@ObjectType) = 'TABLE')
                BEGIN
                    UPDATE [AppAdmin].[ti_adm_SummaryStatistics]
                    SET
						ISACTIVE        = 0,
                        lastupdatedby   = @userid,
						LastUpdatedDate = getdate()
                    WHERE  
						ObjectID = @ObjectID
						AND ISACTIVE = 1;
                END
                UPDATE [AppAdmin].[ti_adm_ObjectAccessGrant]
                    SET    ISACTIVE        = 0,
                            lastupdatedby   = @userid,
                            LastUpdatedDate = getdate()
                    WHERE  ObjectID = @ObjectID;
            END
            INSERT  INTO [AppAdmin].[ti_adm_ObjectOwner] (ObjectName, ObjectType, SchemaName, ObjectLocation, FileExt, FileSize, maskedColumns,CreatedDate, CreatedBy, LastUpdatedDate, LastUpdatedBy, IsActive, Favourite, TAI_Enabled, LoadType, FileDelimiterID )
            VALUES                                      (@ObjectName, @ObjectType, @SchemaName, @ObjectLocation, @FileExt, @FileSize, @MaskedColumns,GetDate(), @owner, GetDate(), @userid, 1,@fav_flag, @TAI_Enabled, @LoadType,@FileDelimiter);
			SET @ObjectID_new = SCOPE_IDENTITY()
            IF @flag = 1
            BEGIN
                /* Commented on 2/19/2020 by Srimathi to return new objectid outside IF.  Replaced with SCOPE_IDENTITY()
				SELECT @ObjectID_new = ObjectID
                FROM   [AppAdmin].[ti_adm_ObjectOwner]
                WHERE  SchemaName = @SchemaName
                        AND ObjectLocation = @ObjectLocation
                        AND FileExt = @FileExt
                        AND ObjectName = @ObjectName
                        AND objectType = @ObjectType
                        AND IsActive = 1; */
                UPDATE #grant_tmp
                SET    objectid        = @objectid_new,
                        createdby       = @userid,
                        createddate     = getdate(),
                        lastupdatedby   = @userid,
                        lastupdateddate = getdate();
                IF UPPER(@ObjectType) IN ('TRANSFORM', 'CLEANSE')
                    UPDATE #transform_tmp
                    SET    objectid = @objectid_new;
                ELSE
                    UPDATE #transformtarget_tmp
                    SET    TargetObjectId = @objectid_new;
                INSERT INTO appadmin.ti_adm_ObjectAccessGrant
                SELECT *
                FROM   #grant_tmp;
                UPDATE [AppAdmin].[ti_adm_INTEGRATE]
                SET    objectid        = @objectid_new,
                        lastupdatedby   = @userid,
                        LastUpdatedDate = getdate()
                WHERE  ObjectID = @ObjectID;
                IF UPPER(@ObjectType) IN ('TRANSFORM', 'CLEANSE')
                    UPDATE appadmin.ti_adm_transform
						SET    OBJECTID = @Objectid_new
						FROM   APPADMIN.TI_ADM_OBJECTOWNER AS o
						WHERE appadmin.ti_adm_transform.objectid = @objectid
                            AND (
								(
								appadmin.ti_adm_transform.targetobjectid = o.objectid
                                AND o.isactive = 1
								)
								OR appadmin.ti_adm_transform.targetobjectid = 0
								);
					-- Commented on 1/22/2020 by Srimathi to handle just Save scenario - with target object id = 0 
                    /*WHERE  appadmin.ti_adm_transform.objectid = @objectid
                            AND appadmin.ti_adm_transform.targetobjectid = o.objectid
                            AND o.isactive = 1; */
						
                ELSE
                    INSERT INTO appadmin.ti_adm_transform
                    SELECT *
                    FROM   #transformtarget_tmp;
                IF @ObjectType = 'TABLE'
                BEGIN
					SET @tblname = '[' + @SchemaName + '].[' + @ObjectName + ']';
                    UPDATE appadmin.ti_adm_transform
                    SET    to_be_validated = 1
                    FROM   APPADMIN.TI_ADM_OBJECTOWNER AS o
                    WHERE  appadmin.ti_adm_transform.objectid = o.objectid
						AND o.isactive = 1
                        AND CHARINDEX(@tblname, transformquery) > 0;
                END
			END
            
			-- Added on 2/19/2020 to return objectid
			SELECT @objectid_new;
		END
        ELSE
        BEGIN
            UPDATE [AppAdmin].[ti_adm_ObjectOwner]
            SET    ObjectName      = @ObjectName,
                    ObjectType      = @ObjectType,
                    SchemaName      = @SchemaName,
                    ObjectLocation  = @ObjectLocation,
                    FileExt         = @FileExt,
                    FileSize        = @FileSize,
                    maskedColumns   = @maskedColumns,
                    LastUpdatedBy   = @userid,
                    LastUpdatedDate = getdate()
            WHERE  ObjectId = @ID;

			UPDATE [AppAdmin].[ti_adm_SummaryStatistics]
                    SET    ISACTIVE        = 0,
                            lastupdatedby   = @userid,
                            LastUpdatedDate = getdate()
                    WHERE  
						ObjectID = @ID
						AND ISACTIVE = 1
			-- Added on 2/19/2020 to return objectid
			SELECT @ID;
		END
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

GO



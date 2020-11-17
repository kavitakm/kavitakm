CREATE PROCEDURE [AppAdmin].[ti_transform_getColumnList_sp]
@SchemaID INT, @TableName VARCHAR (50)
AS
BEGIN
    SELECT COLUMN_NAME,
           DATA_TYPE
    FROM   INFORMATION_SCHEMA.COLUMNS AS I
           INNER JOIN
           sys.tables AS T
           ON T.name = I.TABLE_NAME
           INNER JOIN
           sys.schemas AS s
           ON T.schema_id = s.schema_id
              AND T.type = 'U'
              AND I.TABLE_SCHEMA = s.name
           INNER JOIN
           appadmin.ti_adm_objectowner AS o
           ON o.SCHEMANAME = schema_name(@schemaid)
              AND o.objectname = @tablename
              AND o.objecttype = 'Table'
              AND o.isactive = 1
    WHERE  s.schema_id = @SchemaID
           AND T.name = @TableName
           AND I.DATA_TYPE != 'uniqueidentifier'
           AND charindex(column_name, ISNULL(o.maskedColumns, '')) = 0;
END
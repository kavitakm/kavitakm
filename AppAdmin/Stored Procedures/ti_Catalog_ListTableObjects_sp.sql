--exec [AppAdmin].[ti_Catalog_ListTableObjects_sp_old] '','','ALL','dinesh@tesserinsights.com'        
--exec [AppAdmin].[ti_Catalog_ListTableObjects_sp] '','','ALL','dinesh@tesserinsights.com'        
    
     
CREATE PROC [AppAdmin].[ti_Catalog_ListTableObjects_sp]                
@SearchText varchar(100),      
@InnerSearchText varchar(100),      
@SchemaName varchar(30),      
@UserEmail varchar(100)          
As                 
BEGIN            
/**************************************************************************            
** Version               : 1.0                   
** Author                : Dinesh            
** Description           : Generate list of Tables stored in SQL Server - used in Catalog list page            
** Date      : 23-Aug-2019            
 Modification History:    
 Sunitha 18-12-2019 Added createdby and lastupdatedby  columns     
 Srimathi 09-01-2020 Changed Row count logic to fetch from system table    
 Srimathi 28-02-2020 added TAI_Enabled flag in select list  
 Srimathi 10-03-2020 Added masked columns count, removed union all to improve performance
*******************************************************************************/            
            
DECLARE @userid int;          
 SELECT @userid = userid from appadmin.ti_adm_user_lu where useremail = @UserEmail and isactive=1;          
--print @userid;           
  
  WITH tableinfo (SchemaN, TableN, RCount,CCount) AS (
   select     
     [Schemas].NAME AS [SchemaN]       
     ,[Objects].name AS [TableN]      
     ,sum([Partitions].[rows])/COUNT(column_name) AS [RCount]       
     ,COUNT(column_name) AS [CCount]       
    FROM sys.objects AS [Objects]       
     JOIN sys.schemas  AS [Schemas]      
      ON [Objects].schema_id = [Schemas].schema_id     
      AND [Schemas].name not in ('AppTable','AppAdmin','dbo')       
     JOIN sys.partitions AS [Partitions]     
      ON [Objects].[object_id] = [Partitions].[object_id]     
      AND [Partitions].index_id IN ( 0, 1 )       
     JOIN information_schema.columns c     
      ON [Objects].name = c.TABLE_NAME       
      AND [Schemas].name = c.table_schema      
      AND [Objects].type='U'       
     group by [Schemas].NAME, [Objects].name 
)

   SELECT           
   OBJ.SchemaName AS [Schema]          
  ,'SQL Server' AS [Source]                
  ,'Public' AS [Public]  
  , OBJ.ObjectID AS [TableID]  
  , OBJ.ObjectName AS [Table]          
  , S.[RCount] AS [#Rows]                
  , S.[CCount] AS [#Columns]                
  , OBJ.CreatedDate AS [Create Date]               
  , OBJ.LastUpdatedDate AS [Modify Date]                
  , '' As [Download]               
  , SCHEMA_ID(SchemaName) AS [SchemaID]     
  , case when obj.createdby = @userid then 'True' else 'False' end as [IsOwnObject]    
  , CBy.UserEmail AS CreatedBy    
  , UBy.UserEmail AS UpdatedBy    
  , OBJ.Favourite AS Favourite  
  , (Select Count(*) from [AppAdmin].[ti_adm_ObjectAccessGrant] where isActive =1 And ObjectID = OBJ.ObjectID) as [GrantCount]  
  , OBJ.TAI_Enabled AS TAI_Enabled  
  , CASE WHEN TRIM(OBJ.maskedColumns) in('','[]') THEN 0 ELSE (SELECT COUNT(value) ct FROM STRING_SPLIT(OBJ.maskedColumns,',')) END maskedCount
  ,CASE WHEN lt.LoadTypeName IS NULL THEN '' ELSE lt.LoadTypeName END AS LoadType

  FROM      
 [AppAdmin].[ti_adm_ObjectOwner] OBJ          
 /*INNER JOIN ( SELECT ObjectID, Max([count]) as [RCount] , Count(ObjectID) As [CCount]            
     FROM  [AppAdmin].[ti_adm_SummaryStatistics]           
     WHERE  Column2Name IS NULL AND Column3NAme IS NULL AND Column4Name IS NULL          
     GROUP BY ObjectID) S on S.ObjectID = OBJ.ObjectID   */    
     
 INNER JOIN  tableinfo S   on S.scheman= obj.SchemaName and s.tablen=obj.objectname and obj.isactive = 1 and OBJ.objectType ='Table'
 LEFT JOIN [AppAdmin].[ti_adm_User_lu] CBy ON CBy.UserID = OBJ.CreatedBy      
 LEFT JOIN [AppAdmin].[ti_adm_User_lu] UBy ON UBy.UserID=OBJ.LastUpdatedBy  
 LEFT JOIN [AppAdmin].ti_adm_load_type_lu lt ON obj.LoadType=lt.LoadTypeID           
     
 WHERE     

 (obj.objectid in (select objectid from appadmin.ti_adm_ObjectAccessGrant where GrantToUser = @userid and isactive = 1)
 or
 obj.createdby = @userid) 
 and ((Len(@SearchText) = 0 ) OR (Len(@SearchText) > 0 and ( OBJ.ObjectName like '%' + @SearchText +'%' )))      
  AND ((Len(@InnerSearchText) =0 )  OR (Len(@InnerSearchText) >0 and ( OBJ.ObjectName like '%' + @InnerSearchText +'%')))      
  AND (((Upper(@SchemaName) = 'ALL') or ( Upper(@SchemaName) <> 'ALL' and  OBJ.SchemaName = @SchemaName )))      
       
                       
End
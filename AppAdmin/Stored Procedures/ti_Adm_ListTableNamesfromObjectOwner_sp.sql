CREATE Proc [AppAdmin].[ti_Adm_ListTableNamesfromObjectOwner_sp]                
@SchemaID int,          
@UserEmail varchar(100)          
As                 
BEGIN            
/**************************************************************************            
** Version               : 1.0                   
** Author                : Dinesh            
** Description           : Generate list of Table Names from ObjectOwner table by Schema ID.            
** Date      : 03-Oct-2019            
             
20-Oct-2020	Srimathi	Added LoadType in output
*******************************************************************************/            
            
DECLARE @userid int;          
SELECT @userid = userid from appadmin.ti_adm_user_lu where useremail = @UserEmail and isactive=1;          
 print @userid;           
                         
 BEGIN      
     
 Select obj.ObjectID [TableID], obj.Objectname as [Table] , Isnull(OBJ.TAI_Enabled,0 ) As TAI_Enabled, ldtyp.LoadTypeName AS LoadType, ldtyp.LoadTypeID AS LoadTypeId
 from [AppAdmin].[ti_adm_ObjectOwner] OBJ  
 INNER JOIN [AppAdmin].[ti_adm_load_type_lu] ldtyp ON OBJ.LoadType=ldtyp.LoadTypeID AND ldtyp.IsActive=1   
 where ObjectType ='Table' AND OBJ.ISactive = 1 AND obj.CreatedBy = @userid AND schemaname = SCHEMA_NAME(@SchemaID)     
                       
 Union all      
     
 Select obj.ObjectID [TableID],OBJ.Objectname as [Table], Isnull(OBJ.TAI_Enabled,0 ) As TAI_Enabled, ldtyp.LoadTypeName AS LoadType, ldtyp.LoadTypeID AS LoadTypeId  
 from [AppAdmin].[ti_adm_ObjectOwner] OBJ    
 INNER JOIN  [AppAdmin].[ti_adm_ObjectAccessGrant] GT on GT.ObjectID = obj.objectID and GT.Isactive=1 and GT.GrantToUser = @userid
 INNER JOIN [AppAdmin].[ti_adm_load_type_lu] ldtyp ON OBJ.LoadType=ldtyp.LoadTypeID AND ldtyp.IsActive=1 
 where OBJ.ObjectType ='Table' AND OBJ.ISactive = 1 AND schemaname = SCHEMA_NAME(@SchemaID)      
            
 Order By Objectname ASC                
 END                
                 
                 
End
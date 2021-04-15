-- [AppAdmin].[ti_Adm_ListTableNamesfromObjectOwner_sp] 8,'dinesh@tesserinsights.com'

  
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
               
20-Oct-2020 Srimathi Added LoadType in output  
*******************************************************************************/              
              
DECLARE @userid int;            
SELECT @userid = userid from appadmin.ti_adm_user_lu where useremail = @UserEmail and isactive=1;            
 print @userid;             
                           
 BEGIN        
       
 Select obj.ObjectID [TableID], obj.Objectname as [Table] , Isnull(OBJ.TAI_Enabled,0 ) As TAI_Enabled, ldtyp.LoadTypeName AS LoadType, ldtyp.LoadTypeID AS LoadTypeId, VIDataSet.Object_GUID as AnalyticsPBIDataSet
 from [AppAdmin].[ti_adm_ObjectOwner] OBJ    
 INNER JOIN [AppAdmin].[ti_adm_load_type_lu] ldtyp ON OBJ.LoadType=ldtyp.LoadTypeID AND ldtyp.IsActive=1
 LEFT Join (
		Select Vi.Predecessorid as TableID,obj1.objectid,obj1.Object_GUID from [AppAdmin].[ti_adm_ObjectOwner] obj1
		INNER JOIN [AppAdmin].[ti_adm_visualize] vi on obj1.objectID = vi.objectID and obj1.ObjectType ='Dataset'  and OBJ1.isActive = 1
		Inner join [AppAdmin].[ti_adm_User_lu] ul on ul.UserID = obj1.createdBy and ul.userEmail ='TesserPlatformSignIn@tesserinsights.com') VIDataSet on Obj.ObjectID = VIDataSet.TableID 
 where ObjectType ='Table' AND OBJ.ISactive = 1 AND obj.CreatedBy = @userid AND schemaname = SCHEMA_NAME(@SchemaID)       
                         
 Union all        
       
 Select obj.ObjectID [TableID],OBJ.Objectname as [Table], Isnull(OBJ.TAI_Enabled,0 ) As TAI_Enabled, ldtyp.LoadTypeName AS LoadType, ldtyp.LoadTypeID AS LoadTypeId,VIDataSet.Object_GUID as AnalyticsPBIDataSet    
 from [AppAdmin].[ti_adm_ObjectOwner] OBJ      
 INNER JOIN  [AppAdmin].[ti_adm_ObjectAccessGrant] GT on GT.ObjectID = obj.objectID and GT.Isactive=1 and GT.GrantToUser = @userid  
 INNER JOIN [AppAdmin].[ti_adm_load_type_lu] ldtyp ON OBJ.LoadType=ldtyp.LoadTypeID AND ldtyp.IsActive=1
 LEFT JOIN (
		Select Vi.Predecessorid as TableID,obj1.objectid,obj1.Object_GUID from [AppAdmin].[ti_adm_ObjectOwner] obj1
		INNER JOIN [AppAdmin].[ti_adm_visualize] vi on obj1.objectID = vi.objectID and obj1.ObjectType ='Dataset'  and OBJ1.isActive = 1
		INNER JOIN [AppAdmin].[ti_adm_User_lu] ul on ul.UserID = obj1.createdBy and ul.userEmail ='TesserPlatformSignIn@tesserinsights.com') VIDataSet on Obj.ObjectID = VIDataSet.TableID    
 where OBJ.ObjectType ='Table' AND OBJ.ISactive = 1 AND schemaname = SCHEMA_NAME(@SchemaID)        
              
 Order By Objectname ASC                  
 END                  
                   
                   
End   
  
   
GO

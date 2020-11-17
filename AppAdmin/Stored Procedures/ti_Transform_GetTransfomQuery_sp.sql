CREATE proc [AppAdmin].[ti_Transform_GetTransfomQuery_sp]      
@TransformID int      
as       
Begin      
Select       T.TransformName as [TransformName],
    T.TransformQuery as [TransformQuery]      
 ,OBj.ObjectType as [OutputType]      
 ,OBJ.ObjectName as [OutputName]     
 ,obj.SchemaName as [SchemaName]      
 ,U.userEmail as UserName     
 ,T.Notes as [Notes]  
 ,T.RequestObject as [RequestObject]
 , obj.TAI_Enabled as [IsTaiEnabled]
 from [AppAdmin].[ti_adm_transform] T      
 INNER JOIN [AppAdmin].[ti_adm_ObjectOwner] Tobj on Tobj.Objectid = t.ObjectID and Tobj.ISActive =1        
 INNER JOIN [AppAdmin].[ti_adm_User_lu] U on TObj.CreatedBy = U.UserID and U.isactive =1      
 LEFT JOIN [AppAdmin].[ti_adm_ObjectOwner] obj on obj.Objectid = t.TargetObjectID       
 where t.ObjectId = @TransformID      
      
 End
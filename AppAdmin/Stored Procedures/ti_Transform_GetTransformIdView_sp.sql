CREATE proc [AppAdmin].[ti_Transform_GetTransformIdView_sp]      
@TransformID int      
as       
Begin      
Select       

    T.RequestObject  as [RequestObject]      
        , Tobj.ObjectType as [ObjectType]
 from [AppAdmin].[ti_adm_transform] T      
 INNER JOIN [AppAdmin].[ti_adm_ObjectOwner] Tobj on Tobj.Objectid = t.ObjectID and Tobj.ISActive =1        
 INNER JOIN [AppAdmin].[ti_adm_User_lu] U on TObj.CreatedBy = U.UserID and U.isactive =1      
 LEFT JOIN [AppAdmin].[ti_adm_ObjectOwner] obj on obj.Objectid = t.TargetObjectID       
 where t.ObjectId = @TransformID    
 End
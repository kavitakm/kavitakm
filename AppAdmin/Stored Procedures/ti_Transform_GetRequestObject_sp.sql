CREATE proc [AppAdmin].[ti_Transform_GetRequestObject_sp]      
@TransformID int      
AS       
BEGIN      

SELECT       DISTINCT
   RequestObject
FROM [AppAdmin].[ti_adm_transform] 
WHERE ObjectId = @TransformID      
      
 END
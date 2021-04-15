CREATE PROC [AppAdmin].[ti_Transform_GetTaiFlag_sp]              
@ObjectID int     
, @ObjectType VARCHAR (20) = 'Transform'           
as               
BEGIN        
/**************************************************************************                            
** Version               : 1.0                                   
** Author                : Harini                            
** Description           : Get the TAI_Enabled flag from ti_adm_ObjectOwner table                         
** Date      : 29-March-2021                            
                             
*******************************************************************************/      
IF (@ObjectType = 'Transform')  
 BEGIN  
  SELECT   obj.TAI_Enabled        
  FROM [AppAdmin].[ti_adm_ObjectOwner] obj      
  INNER JOIN [AppAdmin].[ti_adm_transform] T on obj.Objectid = T.TargetObjectID                            
  WHERE T.ObjectId = @ObjectID    
 END  
ELSE  
 BEGIN                              
  SELECT   obj.TAI_Enabled        
  FROM [AppAdmin].[ti_adm_ObjectOwner] obj   
  WHERE obj.Objectid = @ObjectID  
 END           
END 
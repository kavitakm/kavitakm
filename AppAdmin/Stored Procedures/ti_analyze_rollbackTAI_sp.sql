CREATE PROC [AppAdmin].[ti_analyze_rollbackTAI_sp]          
     @SchemaName VARCHAR(100)
	 ,@TableName VARCHAR(100)          
     ,@UserEmail VARCHAR(100)          
AS          
BEGIN           
/**************************************************************************        
**        
** Version Control Information        
** ---------------------------        
**        
**  Name                   : ti_analyze_rollbackTAI_sp        
**  Version                : 1               
**  Date Created		   : 28-10-2020           
**  Type                   : Stored Procedure        
**  Author                 : Sunitha        
            
** Description             : <Purpose of SP>        
**  To update the TAIEnabled flag to 0 
**              
** Modification Hist:               
**                    
** Date                           Name                                     Modification
 
*******************************************************************************/ 
DECLARE @ObjectID int
 SELECT @objectID=appadmin.ti_adm_getObjectID_fn(@TableName,'Table',@SchemaName,'','');

 UPDATE appadmin.ti_adm_ObjectOwner 
	SET TAI_Enabled = 0
 WHERE objectid = @ObjectID

 END
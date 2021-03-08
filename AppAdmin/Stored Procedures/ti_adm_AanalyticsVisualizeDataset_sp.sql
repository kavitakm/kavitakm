GO

-- exec [AppAdmin].[ti_adm_AanalyticsVisualizeDataset_sp] '','Sandbox'  
CREATE PROCEDURE  [AppAdmin].[ti_adm_AanalyticsVisualizeDataset_sp]                       
@ObjectName Varchar(200),                
@SchemaName Varchar(50)                   
                 
AS                    
BEGIN   
SELECT Visualobj.* FROM [AppAdmin].[ti_adm_ObjectOwner] obj    
     INNER JOIN [AppAdmin].[ti_adm_visualize] v on v.predecessorid = obj.objectid and obj.objectname =@ObjectName   
                 AND obj.SchemaName =@SchemaName and obj.isactive =1  
     INNER JOIN [AppAdmin].[ti_adm_ObjectOwner] Visualobj on v.objectid = Visualobj.objectid   
     INNER JOIN [AppAdmin].[ti_adm_User_lu] u on u.userid  = Visualobj.createdby and u.UserEmail ='TesserPlatformSignIn@tesserinsights.com'  
   
END 
GO
--passing API Id : exec [AppAdmin].[ti_Integrate_GetApiByIdOrName_sp] 1,null,'harini@fivepointfivesolutions.com'
 --passing API name : exec [AppAdmin].[ti_Integrate_GetApiByIdOrName_sp] 0, 'HariniAPITest2','harini@fivepointfivesolutions.com'
CREATE Proc [AppAdmin].[ti_Integrate_GetApiByIdOrName_sp]        
@TemplateID int,  
@APIname varchar(100),
@UserEmail varchar(100)  

As         
BEGIN    
/**************************************************************************    
** Version               : 1.0           
** Author                : Harini    
** Description           : Get the API based on API ID/API name from SQL Server - used in Integrate screen    
** Date					 : 24-Sep-2019    
     
*******************************************************************************/    
 DECLARE @userid int;  
SELECT @userid = userid from appadmin.ti_adm_user_lu where useremail = @UserEmail and isactive=1;  

 IF (@TemplateID > 0)                
 BEGIN    
	SELECT
	 obj.SchemaName
	 ,obj.[ObjectName]  as TableName
	 ,i.InputColumns
	 ,i.OutputColumns 
	 FROM [AppAdmin].[ti_adm_integrate] as i 
	 INNER JOIN [AppAdmin].[ti_adm_ObjectOwner] as obj
		ON i.[ObjectID] = obj.[ObjectID]
	WHERE i.APIID = @TemplateID  
	AND i.IsActive = 1             
 END     
 ELSE
 BEGIN
	SELECT count(*) 
	FROM [AppAdmin].[ti_adm_integrate]
	WHERE IsActive = 1 
	AND APIName = @APIname
	AND CreatedBy = @userid
 END    
         
End
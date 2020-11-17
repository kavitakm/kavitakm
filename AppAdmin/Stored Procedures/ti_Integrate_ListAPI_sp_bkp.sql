--exec [AppAdmin].[ti_Integrate_ListAPI_sp] 'test','harini@fivepointfivesolutions.com'
CREATE Proc [AppAdmin].[ti_Integrate_ListAPI_sp_bkp]        
@SearchText varchar(100), 
@InnerSearchText varchar(100),  
@UserEmail varchar(100)  
As         
BEGIN    
/**************************************************************************    
** Version               : 1.0           
** Author                : Harini    
** Description           : Fetch list of API stored in SQL Server - used in Integrate list page    
** Date					 : 24-Sep-2019    
     
*******************************************************************************/    
    
DECLARE @userid int;  
SELECT @userid = userid from appadmin.ti_adm_user_lu where useremail = @UserEmail and isactive=1;  
 --print @userid; 
   
 IF (Len(@SearchText) =0)                
 BEGIN         
	 SELECT
	  i.APIID
	 ,i.APIName
	 ,i.APIDescription
	 ,obj.SchemaName
	 ,obj.[ObjectName]  as TableName
	 ,i.InputColumns
	 ,i.OutputColumns
	 ,u.useremail     as UserName
	 ,i.CreatedDate 
	 FROM [AppAdmin].[ti_adm_integrate] as i 
	 INNER JOIN [AppAdmin].[ti_adm_ObjectOwner] as obj
		ON i.[ObjectID] = obj.[ObjectID]
	 INNER JOIN [AppAdmin].ti_adm_user_lu as u
		ON i.CreatedBy = u.userid
	 WHERE i.IsActive = 1 
	 AND i.CreatedBy = @userid
	 ORDER BY i.APIID DESC       
 END        
 ELSE         
 BEGIN   
 	 SELECT
	  i.APIID
	 ,i.APIName
	 ,i.APIDescription
	 ,obj.SchemaName
	 ,obj.[ObjectName]  as TableName
	 ,i.InputColumns
	 ,i.OutputColumns
	 ,u.useremail     as UserName
	 ,i.CreatedDate 
	 FROM [AppAdmin].[ti_adm_integrate] as i 
	 INNER JOIN [AppAdmin].[ti_adm_ObjectOwner] as obj
		ON i.[ObjectID] = obj.[ObjectID]
	 INNER JOIN [AppAdmin].ti_adm_user_lu as u
		ON i.CreatedBy = u.userid
	 WHERE i.IsActive = 1 
	 AND i.CreatedBy = @userid
	 AND (i.APIName LIKE '%' + @SearchText +'%' 
			OR i.APIDescription like '%' + @SearchText +'%' 
			OR i.CreatedDate like '%' + @SearchText +'%' )
	 ORDER BY i.APIID DESC              
 END         
         
End
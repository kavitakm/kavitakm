--exec [AppAdmin].[ti_Integrate_ListAPI_sp] 'test','','dinesh@tesserinsights.com'  
CREATE Proc [AppAdmin].[ti_Integrate_ListAPI_sp]          
@SearchText varchar(100),   
@InnerSearchText varchar(100),    
@UserEmail varchar(100)    
As           
BEGIN      
/**************************************************************************      
** Version               : 1.0             
** Author                : Harini      
** Description           : Fetch list of API stored in SQL Server - used in Integrate list page      
** Date      : 24-Sep-2019      
       
*******************************************************************************/      
      
DECLARE @userid int;    
SELECT @userid = userid from appadmin.ti_adm_user_lu where useremail = @UserEmail and isactive=1;    
 --print @userid;   
   SELECT  
   i.APIID  
  ,i.APIName  
  ,i.APIDescription  
  ,obj.SchemaName  
  ,obj.[ObjectName]  as TableName  
  ,i.InputColumns  
  ,i.OutputColumns  
  ,u.useremail     as UserName
  ,u.UserEmail AS CreatedBy 
  ,i.CreatedDate
 , UBy.UserEmail AS UpdatedBy 
 , i.LastUpdatedDate AS [UpdatedDate] 
  FROM [AppAdmin].[ti_adm_integrate] as i   
  INNER JOIN [AppAdmin].[ti_adm_ObjectOwner] as obj  
  ON i.[ObjectID] = obj.[ObjectID]  
  INNER JOIN [AppAdmin].ti_adm_user_lu as u  
  ON i.CreatedBy = u.userid
  LEFT JOIN [AppAdmin].[ti_adm_User_lu] UBy   
	ON UBy.UserID=i.LastUpdatedBy       
  WHERE i.IsActive = 1   
  AND i.CreatedBy = @userid  
  AND ((Len(@SearchText) = 0 ) OR (Len(@SearchText) > 0 and ( i.APIName like '%' + @SearchText +'%' OR i.APIDescription like '%' + @SearchText +'%'   
   OR i.CreatedDate like '%' + @SearchText +'%' )))    
  AND ((Len(@InnerSearchText) =0 )  OR (Len(@InnerSearchText) >0 and ( i.APIName like '%' + @InnerSearchText +'%' OR i.APIDescription like '%' + @InnerSearchText +'%'   
   OR i.CreatedDate like '%' + @InnerSearchText +'%')))    
 -- AND (i.APIName LIKE '%' + @SearchText +'%'   
 --  OR i.APIDescription like '%' + @SearchText +'%'   
 --  OR i.CreatedDate like '%' + @SearchText +'%' )  
  ORDER BY i.APIID DESC                
  
  
       
End
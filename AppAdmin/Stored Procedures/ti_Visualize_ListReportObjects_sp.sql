--exec [AppAdmin].[ti_Visualize_ListReportObjects_sp] '','','dinesh@tesserinsights.com'    

 
CREATE PROC [AppAdmin].[ti_Visualize_ListReportObjects_sp]            
@SearchText varchar(100),  
@InnerSearchText varchar(100),  
@UserEmail varchar(100)      
As             
BEGIN        
/**************************************************************************        
** Version               : 1.0               
** Author                : Srimathi     
** Description           : Generate list of Reports - used in Reports Datalake page        
** Date					 : 09-Jan-2020
 ******************************************************************************/        
        
DECLARE @userid int;      

   SELECT @userid = [AppAdmin].[ti_adm_getUserID_fn](@UserEmail);      
            
   SELECT       
   OBJ.ObjectName AS [Report]      
  , OBJ.ObjectLocation AS [Workspace]
  , OBJ.CreatedDate AS [Create Date]           
  , OBJ.LastUpdatedDate AS [Modify Date]            
  , 'True' as [IsOwnObject]
  , CBy.UserEmail AS CreatedBy
  , UBy.UserEmail AS UpdatedBy
	FROM  
		[AppAdmin].[ti_adm_ObjectOwner] OBJ      
		LEFT JOIN [AppAdmin].[ti_adm_User_lu] CBy 
			ON CBy.UserID = OBJ.CreatedBy  
		LEFT JOIN [AppAdmin].[ti_adm_User_lu] UBy 
			ON UBy.UserID=OBJ.LastUpdatedBy     
	WHERE 
		OBJ.objectType ='Report' 
		AND OBJ.ISactive = 1 
		AND obj.CreatedBy = @userid       
 		AND ((Len(@SearchText) = 0 ) OR (Len(@SearchText) > 0 and ( OBJ.ObjectName like '%' + @SearchText +'%' )))  
		AND ((Len(@InnerSearchText) =0 )  OR (Len(@InnerSearchText) >0 and ( OBJ.ObjectName like '%' + @InnerSearchText +'%')))  
   
  Union all  
  
  SELECT       
  OBJ.ObjectName AS [Table]      
  , OBJ.ObjectLocation AS [Workspace]
  , OBJ.CreatedDate AS [Create Date]            
  , OBJ.LastUpdatedDate AS [Modify Date]            
  , 'False' as [IsOwnObject] 
  , CBy.UserEmail AS CreatedBy
 , UBy.UserEmail AS UpdatedBy
 FROM  
	[AppAdmin].[ti_adm_ObjectOwner] OBJ      
 	INNER JOIN  [AppAdmin].[ti_adm_ObjectAccessGrant] GT 
		on GT.ObjectID = obj.objectID and GT.Isactive=1 and GT.GrantToUser = @userid 
	LEFT JOIN [AppAdmin].[ti_adm_User_lu] CBy 
		ON CBy.UserID = OBJ.CreatedBy  
	LEFT JOIN [AppAdmin].[ti_adm_User_lu] UBy 
		ON UBy.UserID=OBJ.LastUpdatedBy     
  WHERE   
	OBJ.objectType ='Report' 
	AND OBJ.ISactive = 1        
	AND ((Len(@SearchText) = 0 ) OR (Len(@SearchText) > 0 and ( OBJ.ObjectName like '%' + @SearchText +'%' )))  
	AND ((Len(@InnerSearchText) =0 )  OR (Len(@InnerSearchText) >0 and ( OBJ.ObjectName like '%' + @InnerSearchText +'%')))  
             
End
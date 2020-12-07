
--exec [AppAdmin].[ti_Visualize_ListObjects_sp] 'Report','','','dinesh@tesserinsights.com'    

 
CREATE PROC [AppAdmin].[ti_Visualize_ListObjects_sp]            
@ObjectType VARCHAR(20),  -- Report or Dashboard
@SearchText varchar(100),  
@InnerSearchText varchar(100),  
@UserEmail varchar(100)      
As             
BEGIN        
/**************************************************************************        
** Version               : 1.0               
** Author                : Srimathi     
** Description           : Generate list of Reports/Dashboards - used in Report/Dashboard Datalake page        
** Date					 : 09-Jan-2020

10-AUG-2020 - Added GUID of report and workspace in SELECT
21-Sep-2020	Srimathi	Added EditAccess column in output
02-12-2020	 Sunitha   Added Search Filters in where clause Bug#552

 ******************************************************************************/        
        
DECLARE @userid int;      

   SELECT @userid = [AppAdmin].[ti_adm_getUserID_fn](@UserEmail);      
            
   SELECT       
   OBJ.ObjectName AS [Report] 
  , OBJ.Object_GUID AS [GUID]
  , OBJ.ObjectLocation AS [Workspace]
  , OBJ.Workspace_GUID AS [Workspace_GUID]
  , OBJ.CreatedDate AS [Create Date]           
  , OBJ.LastUpdatedDate AS [Modify Date]            
  , 'True' as [IsOwnObject]
  , CBy.UserEmail AS CreatedBy
  , UBy.UserEmail AS UpdatedBy
  , OBJ.Favourite AS Favourite
  , 1 as EditAccess
	FROM  
		[AppAdmin].[ti_adm_ObjectOwner] OBJ      
		LEFT JOIN [AppAdmin].[ti_adm_User_lu] CBy 
			ON CBy.UserID = OBJ.CreatedBy  
		LEFT JOIN [AppAdmin].[ti_adm_User_lu] UBy 
			ON UBy.UserID=OBJ.LastUpdatedBy     
	WHERE 
		OBJ.objectType = @ObjectType
		AND OBJ.ISactive = 1 
		AND obj.CreatedBy = @userid       
 		AND ((Len(@SearchText) = 0 ) OR (Len(@SearchText) > 0 and ( OBJ.ObjectName like '%' + @SearchText +'%' 
		or OBJ.ObjectLocation like '%' + @SearchText +'%' 
		or CBy.UserEmail like '%' + @SearchText +'%' 
		or OBJ.LastUpdatedDate like '%' + @SearchText +'%' 

		)))  
		AND ((Len(@InnerSearchText) =0 )  OR (Len(@InnerSearchText) >0 and ( OBJ.ObjectName like '%' + @InnerSearchText +'%'
		or OBJ.ObjectLocation like '%' + @InnerSearchText +'%' 
		or CBy.UserEmail like '%' + @InnerSearchText +'%' 
		or OBJ.LastUpdatedDate like '%' + @InnerSearchText +'%' 
		)))  
   
  Union all  
  
  SELECT       
  OBJ.ObjectName AS [Report] 
  , OBJ.Object_GUID AS [GUID]
  , OBJ.ObjectLocation AS [Workspace]
  , OBJ.Workspace_GUID AS [Workspace_GUID]
  , OBJ.CreatedDate AS [Create Date]            
  , OBJ.LastUpdatedDate AS [Modify Date]            
  , 'False' as [IsOwnObject] 
  , CBy.UserEmail AS CreatedBy
 , UBy.UserEmail AS UpdatedBy
 , GT.Favourite AS Favourite
 , GT.EditAccess AS EditAccess
 FROM  
	[AppAdmin].[ti_adm_ObjectOwner] OBJ      
 	INNER JOIN  [AppAdmin].[ti_adm_ObjectAccessGrant] GT 
		on GT.ObjectID = obj.objectID and GT.Isactive=1 and GT.GrantToUser = @userid 
	LEFT JOIN [AppAdmin].[ti_adm_User_lu] CBy 
		ON CBy.UserID = OBJ.CreatedBy  
	LEFT JOIN [AppAdmin].[ti_adm_User_lu] UBy 
		ON UBy.UserID=OBJ.LastUpdatedBy     
  WHERE   
	OBJ.objectType = @ObjectType 
	AND OBJ.ISactive = 1        
	AND ((Len(@SearchText) = 0 ) OR (Len(@SearchText) > 0 and ( OBJ.ObjectName like '%' + @SearchText +'%'
	or OBJ.ObjectLocation like '%' + @SearchText +'%' 
		or CBy.UserEmail like '%' + @SearchText +'%' 
		or OBJ.LastUpdatedDate like '%' + @SearchText +'%' 
	)))  
	AND ((Len(@InnerSearchText) =0 )  OR (Len(@InnerSearchText) >0 and ( OBJ.ObjectName like '%' + @InnerSearchText +'%'
	or OBJ.ObjectLocation like '%' + @InnerSearchText +'%' 
		or CBy.UserEmail like '%' + @InnerSearchText +'%' 
		or OBJ.LastUpdatedDate like '%' + @InnerSearchText +'%' 
	)))  
             
End   
   
GO



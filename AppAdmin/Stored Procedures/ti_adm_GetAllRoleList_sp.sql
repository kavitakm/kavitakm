CREATE PROCEDURE  [AppAdmin].[ti_adm_GetAllRoleList_sp]     
@SearchText as varchar(200)          
AS          
BEGIN       
	if (Len(@SearchText) =0)        
	BEGIN      
       
		Select         
				R.RoleID        
				,R.RoleName  
				,U.FirstNAme + U.LastName  
				,R.CreatedDate      
		from [AppAdmin].[ti_adm_Roles_lu] R  
		Left Join [AppAdmin].[ti_adm_User_lu] U on R.CreatedBy = U.UserID        
		where R.IsActive = 1
		order by R.RoleID desc    
      
	End    
	else     
	Begin     
		Select         
				R.RoleID        
				,R.RoleName  
				,U.FirstNAme + U.LastName  
				,R.CreatedDate     
		from [AppAdmin].[ti_adm_Roles_lu] R  
		Left Join [AppAdmin].[ti_adm_User_lu] U on R.CreatedBy = U.UserID        
		where R.IsActive = 1  
		and (R.RoleName like '%' + @SearchText +'%'        
			  or U.FirstNAme like '%' +@SearchText +'%'        
			  or U.LastName like '%' +@SearchText +'%'        
			  or U.Department like '%' +@SearchText +'%'        
			  or R.CreatedDate like '%' +@SearchText +'%'        
			)   
		order by R.RoleID desc   
	end     
        
End
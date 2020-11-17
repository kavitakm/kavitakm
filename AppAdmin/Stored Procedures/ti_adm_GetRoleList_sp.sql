-- Sp_helptext '[AppAdmin].[ti_adm_GetRoleList_sb]'

CREATE PROCEDURE  [AppAdmin].[ti_adm_GetRoleList_sp]   
@BaseRoleOnly as BIT        
AS        
BEGIN     
  if (@BaseRoleOnly = 1)  
  Begin     
   Select       
     R.RoleID      
    ,R.RoleName
	,U.FirstNAme + U.LastName
	,R.CreatedDate    
   from [AppAdmin].[ti_adm_Roles_lu] R
   Left Join [AppAdmin].[ti_adm_User_lu] U on R.CreatedBy = U.UserID      
   where R.IsActive = 1   
   and IsBaseRole = 1  
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
 end   
      
End
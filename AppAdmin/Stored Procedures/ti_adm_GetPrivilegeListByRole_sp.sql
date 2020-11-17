CREATE procedure [AppAdmin].[ti_adm_GetPrivilegeListByRole_sp]    
@RoleID int          
As     
Begin     
     
Select R.RoleID     
   , R.RoleName    
   , mc.ModuleComponentID    
   , mc.ModuleName     
   , mc.ModuleComponentName    
   , p.PrivilegeID     
   , p.PrivilegeName    
   --, IsEditable = Case when pr.PrivilegeName is null then 1 else 0 end    
from [APPAdmin].[ti_adm_Roles_lu] R    
Inner join [AppAdmin].[ti_adm_RolePrivModule_lu] RP on R.RoleID = RP.RoleID and (RP.IsActive =  1) and R.isActive =1    
Inner join [AppAdmin].[ti_adm_ModuleComponent_lu] mc on mc.ModuleComponentID = RP.ModuleComponentID and mc.IsActive =1    
Inner Join [AppAdmin].[ti_adm_Privilege_lu] P on p.PrivilegeID = rp.PrivilegeID and p.IsActive =1     
-- Left join #PreviousRole PR on   PR.ModuleComponentID = mc.ModuleComponentID and pr.PrivilegeID = p.PrivilegeID    
where R. RoleID = isnull(@RoleID , r.RoleID)--and mc.ModuleName ='Catalog'    
order by mc.ModuleComponentID, p.PrivilegeID    
    
    
End
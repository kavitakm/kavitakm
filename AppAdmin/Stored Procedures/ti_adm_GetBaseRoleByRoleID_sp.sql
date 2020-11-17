CREATE Proc [AppAdmin].[ti_adm_GetBaseRoleByRoleID_sp]
@RoleID int
as 
Begin

SELECT  BRole.RoleName As BaseRoleName
FROM
    [AppAdmin].[ti_adm_Roles_lu] BRole
    Right OUTER JOIN [AppAdmin].[ti_adm_Roles_lu] DRole
        ON BRole.RoleID = isnull(DRole.BaseRoleID,Drole.RoleID)  
  where DRole.RoleID = @RoleID
End
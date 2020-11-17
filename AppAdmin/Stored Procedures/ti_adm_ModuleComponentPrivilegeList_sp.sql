CREATE Proc [AppAdmin].[ti_adm_ModuleComponentPrivilegeList_sp]  
 -- @RoleID int  
 AS  
 BEGIN   
  --Select MC.ModuleComponentID  
  --  , MC.ModuleName  
  --  , MC.ModuleComponentName  
  --  , p.PrivilegeID  
  --  , p.PrivilegeName   
  --  , R.RoleID  
  --  , R.RoleName  
  -- from [AppAdmin].[lutModuleComponent] MC  
  -- Inner Join [AppAdmin].[tblRolePrivModule] RPM On MC.ModuleComponentID = RPM.ModuleComponentID and RPM.IsActive =1 and MC.IsActive = 1  
  -- Inner join [AppAdmin].[lutPrivilege] P on P.PrivilegeID = RPM.PrivilegeID and p.IsActive = 1  
  -- Inner Join [AppAdmin].[lutRoles] R on R.RoleID = RPM.RoleID and R.IsActive = 1   
  -- -- where R.RoleID = @RoleID  
  -- Order by R.RoleID  
  
   /*Declare Variable*/    
   DECLARE @Pivot_Column [nvarchar](max);    
   DECLARE @Query [nvarchar](max);    
    
     
   /*Select Pivot Column*/    
   SELECT @Pivot_Column= COALESCE(@Pivot_Column+',','')+ QUOTENAME(PrivilegeName) FROM    
   (Select Distinct PrivilegeID,PrivilegeName from [AppAdmin].[ti_adm_Privilege_lu] where isActive =1  )Tab    
    
   /*Create Dynamic Query*/    
   SELECT @Query='SELECT RoleID,RoleName, ModuleName,ModuleComponentName, '+ @Pivot_Column +'FROM     
   ( Select MC.ModuleComponentID  
     , MC.ModuleName  
     , MC.ModuleComponentName  
     , p.PrivilegeID  
     , p.PrivilegeName   
     , R.RoleID  
     , R.RoleName  
    from [AppAdmin].[ti_adm_ModuleComponent_lu] MC  
    Inner Join [AppAdmin].[ti_adm_RolePrivModule_lu] RPM On MC.ModuleComponentID = RPM.ModuleComponentID and RPM.IsActive =1 and MC.IsActive = 1  
    Inner join [AppAdmin].[ti_adm_Privilege_lu] P on P.PrivilegeID = RPM.PrivilegeID and p.IsActive = 1  
    Inner Join [AppAdmin].[ti_adm_Roles_lu] R on R.RoleID = RPM.RoleID and R.IsActive = 1   
    
     )Tab1    
   PIVOT    
   (    
   Count(PrivilegeID) FOR [PrivilegeName] IN ('+@Pivot_Column+')) AS Tab2 order By RoleID  '    
  
   /*Execute Query*/    
   EXEC  sp_executesql  @Query   
  End
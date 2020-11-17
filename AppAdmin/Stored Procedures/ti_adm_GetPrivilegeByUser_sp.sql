CREATE Proc [AppAdmin].[ti_adm_GetPrivilegeByUser_sp]      
  @UserEmail Varchar(100)      
 AS      
 BEGIN       
   Declare @EnableTAI bit;       
   Declare @RoleID Varchar(10);     
   Set @RoleID = 0 ;  
   Set @EnableTAI = 0; 
   Select @RoleID = RoleId, @EnableTAI = TAI_Enabled  from [AppAdmin].[ti_adm_User_lu] where UserEmail  = @UserEmail and IsActive =1 ;     
        
   /*Declare Variable*/        
   DECLARE @Pivot_Column [nvarchar](max);        
   DECLARE @Query [nvarchar](max);        
        
         
   /*Select Pivot Column*/        
   SELECT @Pivot_Column= COALESCE(@Pivot_Column+',','')+ QUOTENAME(PrivilegeName) FROM        
   (Select Distinct PrivilegeID,PrivilegeName from [AppAdmin].[ti_adm_Privilege_lu] where isActive =1  )Tab        
        
   /*Create Dynamic Query*/        
   /*SELECT @Query='SELECT RoleID,RoleName, ModuleName,ModuleComponentName, '+ @Pivot_Column +'FROM         
   ( Select MC.ModuleComponentID      
     , MC.ModuleName      
     , MC.ModuleComponentName      
     , p.PrivilegeID      
     , p.PrivilegeName       
     , R.RoleID      
     , R.RoleName      
    from  ( appadmin.[lutModuleComponent] mc   
 Full join [AppAdmin].[lutRoles] R on (1=1 and MC.IsActive = 1 and R.IsActive = 1 )  
 Left Join [AppAdmin].[tblRolePrivModule] rpm on MC.ModuleComponentID = RPM.ModuleComponentID )   
 Left join [AppAdmin].[lutPrivilege] P on (P.PrivilegeID = RPM.PrivilegeID and p.IsActive = 1  and RPM.IsActive =1   ) where R.RoleID ='+ @RoleID +'     
     )Tab1        
   PIVOT        
   (        
   Count(PrivilegeID) FOR [PrivilegeName] IN ('+@Pivot_Column+')) AS Tab2 order By RoleID  '        
      
       
   /*Execute Query*/        
   EXEC  sp_executesql  @Query       
   */  
  
   --select * from AppAdmin.testview  
  
  
  
select *   
  from (select Roleid, @EnableTAI as [EnableTAI], 
      Rolename,  
      modulename,      
      modulecomponentname,   
      privilegename,   
      privexist   
    from (select a.*,  
         case when b.privilegeid is null then 0 else 1 end as privexist  
         from (select roleid,   
        rolename,   
        modulename,  
        modulecomponentid,   
        modulecomponentname,   
        privilegeid,  
        privilegename  
         from appadmin.ti_adm_Roles_lu ,   
        appadmin.ti_adm_ModuleComponent_lu ,   
        aPPadmin.ti_adm_Privilege_lu   
        where roleid = @RoleID  
         and appadmin.ti_adm_Roles_lu.isactive=1  
         and appadmin.ti_adm_ModuleComponent_lu.isactive=1  
         and appadmin.ti_adm_Privilege_lu.isactive=1  
    ) a  
    left join   
    (select rpm.roleid,  
      rpm.privilegeid,  
      rpm.ModuleComponentID   
       from appadmin.ti_adm_RolePrivModule_lu rpm   
       where IsActive=1  
    ) b   
    on (a.roleid = b.roleid and a.ModuleComponentID =b.modulecomponentid and a.privilegeid =b.PrivilegeID )) as rawdata  
    ) as sourcetable   
pivot (sum(privexist)   
  for privilegename in ([View],
[Convert to Table],
[Copy / Clone],
[Download],
[Delete],
[Edit],
[New],
[Run],
[Test],
[Mask Data],
[View Masked Data],
[Data Prep],
[Build Model],
[Deploy Model],
[Grant Access],
[Revoke Access])) as pivottable  
   -- Select Distinct PrivilegeID,PrivilegeName from [AppAdmin].[lutPrivilege] where isActive =1;  
  End
-- Exec [AppAdmin].[ti_adm_SP_GetUserList] 1 , 'vana'      
-- =============================================        
-- Author:      Dinesh        
-- Create date: 13-May-2019        
-- Description: Return all users list records based on subscription id         
-- =============================================        
CREATE PROCEDURE  [AppAdmin].[ti_adm_GetUserList_sp]        
@SubscripID int,       
@SearchText varchar(100)      
AS        
BEGIN        
 if (Len(@SearchText) =0)      
 BEGIN      
      
    Select       
      U.UserID       
     ,U.FirstName      
     ,U.LastName      
     ,U.UserEmail      
     ,U.Department      
     ,u.RoleID      
     ,R.RoleName      
     ,U.SupervisorID      
     ,S.FirstName + ' ' +s.LastName as Supervisor      
     ,U.Field1       
     ,U.CreatedDate      
    from [AppAdmin].[ti_adm_User_lu] U      
    Inner Join [AppAdmin].[ti_adm_Roles_lu] R On R.RoleID = U.RoleID      
    Left Join [AppAdmin].[ti_adm_User_lu] S on U.SupervisorID = S.UserID      
    where U.IsActive = 1       
    and  U.SubscriptionID =@subscripID   
 order by U.UserID desc      
 END      
    
 ELSE      
    
  BEGIN      
       
    Select       
       U.UserID       
      ,U.FirstName      
      ,U.LastName      
      ,U.UserEmail      
      ,U.Department      
      ,u.RoleID      
      ,R.RoleName      
      ,U.SupervisorID      
      ,S.FirstName + ' ' +s.LastName as Supervisor      
      ,U.Field1       
      ,U.CreatedDate      
     from [AppAdmin].[ti_adm_User_lu] U      
     Inner Join [AppAdmin].[ti_adm_Roles_lu] R On R.RoleID = U.RoleID      
     Left Join [AppAdmin].[ti_adm_User_lu] S on U.SupervisorID = S.UserID      
     where U.IsActive = 1       
     and  U.SubscriptionID =@subscripID       
     and (U.FirstName like '%' + @SearchText +'%'      
      or U.LastName like '%' +@SearchText +'%'      
      or U.UserEmail like '%' +@SearchText +'%'      
      or U.Department like '%' +@SearchText +'%'      
      or R.RoleName like '%' +@SearchText +'%'      
      
      )  
   order by U.UserID desc       
 END       
      
End
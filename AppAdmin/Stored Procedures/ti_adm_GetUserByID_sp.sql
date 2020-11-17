CREATE PROCEDURE [AppAdmin].[ti_adm_GetUserByID_sp]      
@UserID int     
AS      
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
    and  U.UserID =@UserID     
END
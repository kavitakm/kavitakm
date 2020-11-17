CREATE PROCEDURE  [AppAdmin].[ti_adm_GetSupervisorList_sp]         
AS        
BEGIN      
  Select       
   U.UserID       
  ,U.FirstName  + ' ' +  U.LastName as Supervisor    
  from [AppAdmin].[ti_adm_User_lu] U      
  where U.IsActive = 1       
       
END
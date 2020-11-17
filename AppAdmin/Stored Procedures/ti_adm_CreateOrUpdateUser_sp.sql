--exec [AppAdmin].[ti_adm_CreateOrUpdateUser_sp]  0,'sample','user','sampleuser@tesserinsights.com','IT',4,1,'','sampleuser@tesserinsights.com','sampleuser'

CREATE   PROCEDURE  [AppAdmin].[ti_adm_CreateOrUpdateUser_sp]                   
@ID int,            
@FirstName Varchar(100),            
@LastName Varchar(100),            
@Email Varchar(100),            
@Department Varchar(100),            
@RoleID int,            
@SupervisorID int,            
@Field1 Varchar(100),      
@UserEmail Varchar(150),      
@UserName Varchar(150),
@TAI_Enabled bit
AS                
BEGIN              
       
/**************************************************************************        
** Version                : 1.0           
** Author                 :         
** Description            : 
** Date					  : 
  Modification			  :
  DAte		Name	  Modification
03/03/2020  Sunitha  Added User  Schema creation logic *******************************************************************************/ 
--SET NOCOUNT ON
BEGIN TRY
  BEGIN TRANSACTION 
  Declare @UserID int;
  Declare @ErrMsg VARCHAR(1000);
  Declare @ErrSeverity VARCHAR(100);
  set @UserID = 0;      
  Select @UserID = UserID from [AppAdmin].[ti_adm_User_lu] where IsActive =1  and UserEmail =@UserEmail      
  if ( @ID = 0 )             
  Begin            
        
     
	 -- This code comment Don't allow user to use sql server using their email 
/*    Set @query1 =N'CREATE USER [' + @Email + '] FROM EXTERNAL PROVIDER;'        
      
    Execute sp_executesql @query1;    
    
   Set @query1 ='CREATE SCHEMA ' + @UserName + '  AUTHORIZATION [' + @Email + '] ;'        
   Execute sp_executesql @query1;        
        
	Set @query1 = 'GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE  ON  SCHEMA::[AppAdmin] TO [' + @Email +'];'        
   Execute sp_executesql @query1;        

   Set @query1 = 'GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE  ON  SCHEMA::[Sandbox] TO [' + @Email +'];'        
   Execute sp_executesql @query1;        
  */
  
   --Set @query1 = 'GRANT SELECT, INSERT, UPDATE  ON  [AppAdmin].[ti_adm_ModuleComponent_lu] TO [' + @Email +'];'        
   --Execute sp_executesql @query1;        
        
   --Set @query1 =  'GRANT SELECT, INSERT, UPDATE ON  [AppAdmin].[ti_adm_Privilege_lu] TO [' + @Email +'];'        
   --Execute sp_executesql @query1;        
        
   --Set @query1 =  'GRANT SELECT, INSERT, UPDATE ON [AppAdmin].[ti_adm_RolePrivModule_lu] TO [' + @Email +'];'        
   --Execute sp_executesql @query1;        
        
   --Set @query1 =  'GRANT SELECT, INSERT, UPDATE  ON [AppAdmin].[ti_adm_Roles_lu] TO [' + @Email +'];'        
   --Execute sp_executesql @query1;        
        
   --Set @query1 =  'GRANT SELECT, INSERT, UPDATE ON [AppAdmin].[ti_adm_User_lu] TO [' + @Email +'];'        
   --Execute sp_executesql @query1;        
        
   --Set @query1 =  'GRANT SELECT, INSERT, UPDATE ON  [AppAdmin].[ti_adm_UserRole_lu] TO [' + @Email +'];'        
   --Execute sp_executesql @query1;        
        
   --Set @query1 =  'GRANT SELECT, INSERT, UPDATE ON [AppAdmin].[ti_integration_DynamicAPI] TO [' + @Email +'];'        
   --Execute sp_executesql @query1;        
        
   --Set @query1 =  'GRANT Select, insert, update ON [AppAdmin].[ti_transform_TransformDetails] TO [' + @Email +'];'        
   --Execute sp_executesql @query1;        
    
  --check for schema and create if not exists
	DECLARE @createschema nvarchar(200)
	SET @createschema='CREATE SCHEMA ' + @UserName  
	IF NOT EXISTS (
		SELECT  schema_name
		FROM    information_schema.schemata
		WHERE   schema_name = @UserName )  
	BEGIN
		EXEC sp_executesql @createschema  
	END   
	
   Insert into [AppAdmin].[ti_adm_User_lu]            
   (             
    FirstName            
   , LastName            
   , UserEmail            
   , Department            
   , RoleID            
   , SupervisorID            
   , SubscriptionID            
   , Field1
   , TAI_Enabled
   , CreatedBy            
   , CreatedDate            
   , UpdatedBy            
   , UpdatedDate            
   , IsActive)            
  Values             
  (            
  @FirstName            
   , @LastName            
   , @Email            
   , @Department            
   , @RoleID            
   , @SupervisorID            
   , 1             
   , @Field1 
   , @TAI_Enabled
   , @UserID            
   , GetDate()            
   , null             
   , null             
   , 1            
  );          
      
  Declare @uID int ;      
      
  Select @uID =SCOPE_IDENTITY();      
      
   Insert into [AppAdmin].[ti_adm_UserRole_lu] ( RoleID , UserID, CreatedBy, CreatedDate,IsActive )       
   Values ( @RoleID , @uID, @UserID, GetDate(),1);      
          
  End            
  Else             
  Begin            
     Update [AppAdmin].[ti_adm_User_lu]            
   Set FirstName = @FirstName            
  , LastName = @LastName            
  --, UserEmail = @Email            
  , Department = @Department            
  , RoleID = @RoleID             
  , SupervisorID = @SupervisorID            
  , SubscriptionID = 1             
  , Field1 = @Field1   
  , TAI_Enabled= @TAI_Enabled
  , UpdatedBy = @UserID            
  , UpdatedDate = getdate()            
 where UserID = @ID      ;      
       
   Update [AppAdmin].[ti_adm_UserRole_lu]       
   set RoleID = @RoleID       
   , UpdatedBy = @UserID            
  , UpdatedDate = getdate()      
   where UserID = @ID ;      
          
  End            
 COMMIT TRANSACTION
END TRY 
  BEGIN CATCH
  IF @@trancount>0
	ROLLBACK TRANSACTION
  SET @ErrMsg = ISNULL(LEFT(RTRIM(ERROR_MESSAGE()),1000),'')             
  SET @ErrSeverity=ERROR_SEVERITY()
  RAISERROR(@ErrMsg,@Errseverity,1)
END CATCH             
End
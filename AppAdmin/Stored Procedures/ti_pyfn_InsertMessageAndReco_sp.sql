create procedure [AppAdmin].[ti_pyfn_InsertMessageAndReco_sp]
(@UserID varchar(50),
@UserEmail varchar(100),
@Event varchar(50),
@Outcome varchar(100),
@Notify bit,
@ImpForMyActivity bit,
@MessageSent bit=0,
@MessageRead bit=0,
@MessageJSON varchar(max)
)

as
 /**************************************************************************  
**  
** Version Control Information  
** ---------------------------  
**  
**  Name                   : [AppAdmin].[ti_pyfn_InsertMessageAndReco_sp]   
**  Version                : 1         
**  Date Created     :    
**  Type                   : Stored Procedure  
**  Author                 : Gayatri  
** Description             : To insert events and recommendations for notification and messaging  
**                
*******************************************************************************/  
Begin
Insert into AppAdmin.ti_adm_EventMessage(UserID,
										UserEmail,
										Event,
										Outcome,
										Notify,
										ImpForMyActivity,
                                        MessageSent,
										MessageRead,
										MessageJSON,
                                        CreatedBy,
										CreatedDate,
										LastUpdatedBy,
										LastUpdatedDate
										)
								values (@UserID,
										@UserEmail,
										@Event,
										@Outcome,
										@Notify,
										@ImpForMyActivity,
                                        @MessageSent,
										@MessageRead,
										@MessageJSON,
                                        appadmin.ti_adm_getUserID_fn(@UserEmail),
										getdate(),
										appadmin.ti_adm_getUserID_fn(@UserEmail),
										getdate()
										)

end
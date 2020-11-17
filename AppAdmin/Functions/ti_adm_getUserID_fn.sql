--select [AppAdmin].[ti_adm_getUserID_fn]('sunitha@tesserinsights.com')
CREATE FUNCTION [AppAdmin].[ti_adm_getUserID_fn]
( 
	@userEmail		 VARCHAR(100)
)  
RETURNS INT  
/******************************************************
** Version               : 1.0               
** Author                : Sunitha        
** Description           : get the userID for the given UserEmail        
** Date					 : 03-01-2019           
*******************************************************/
BEGIN   
	RETURN 
	(SELECT  UserID 
	FROM appadmin.ti_adm_User_lu 
	WHERE 
		UserEmail=@userEmail
		AND IsActive = 1
	)	   

END
CREATE FUNCTION [AppAdmin].[ti_adm_Transform_IsInteger](@Value VarChar(18))  
RETURNS BIT  
AS   
BEGIN  
  
/**************************************************************************
**
** Version Control Information
** ---------------------------
**
**  Name                   : ti_adm_Transform_IsInteger
**  Version                : 1.0      
**  Date Created		   :   
**  Type                   : User DEfined Function
**  Author                 : Dinesh
***************************************************************************     
** FileName                : 
** Description             : <Purpose of SP>
** 
**      
** Input Parameters  : <List of Input Parameters>
@Value VarChar(18)
** Modification Hist:       
**            
** Date                           Name                                     Modification     

*******************************************************************************/
  RETURN IsNull(  
     (SELECT CASE WHEN CharIndex('.', @Value) > 0   
                  THEN CASE WHEN Convert(int, ParseName(@Value, 1)) <> 0  
                            THEN 0  
                            ELSE 1  
                         END  
                  ELSE 1  
                  END  
      WHERE IsNumeric(@Value + 'e0') = 1), 0)  
  
END
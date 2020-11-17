CREATE PROCEDURE [AppAdmin].[ti_adm_GetAllLoadType_sp]
AS
BEGIN

/**************************************************************************        
**        
** Version Control Information        
** ---------------------------        
**        
**  Name                   : ti_adm_GetLoadTypeByID_sp       
**  Version                : 1               
**  Date Created		   : 10-12-2020           
**  Type                   : Stored Procedure        
**  Author                 : Guru Kiran       
***************************************************************************         
** Description             : To fetch the Load Type based on the ID of the load type.                                
**               
** Modification Hist:               
**                    
** Date                           Name                                     Modification 



********************************************************************************/

SELECT
LoadTypeID,
LoadTypeName
FROM
AppAdmin.ti_adm_load_type_lu
WHERE
IsActive=1;

END
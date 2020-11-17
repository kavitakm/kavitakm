CREATE PROCEDURE [AppAdmin].[ti_Analyze_deleteModel_sp]        
@ModelName VARCHAR(100)
AS
BEGIN
/**************************************************************************   
**        
** Version Control Information        
** ---------------------------        
**        
** Version                : 1.0               
** Author                 : Srimathi            
** Description            : Delete model        
** Date					  : 2/26/2020
*/

DECLARE @objectid INT;
SELECT @objectid = appadmin.ti_adm_getObjectID_fn(@ModelName,'Linear Regression Model','','','')
delete from appadmin.ti_adm_regressionModels where modelid = @objectid
delete from appadmin.ti_adm_objectowner where objectid = @objectid

END
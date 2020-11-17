CREATE   PROC [AppAdmin].[ti_transform_CheckifTransformExists_sp]
					@TransformName Varchar(50)
AS
BEGIN
/**************************************************************************
**
** Version Control Information
** ---------------------------
**
**  Name                   : AppAdmin.ti_transform_CheckifTransformExists_sp
**  Version                : 1.0      
**  Date Created		   : 30-10-2019   
**  Type                   : Stored Procedure
**  Author                 : Sunitha
***************************************************************************     
** FileName                : ti_transform_CheckifTransformExists_sp.sql 
** Description             : <Purpose of SP>
** checks whether the given transform exists
** 
** Input Parameters  : <List of Input Parameters>

@TransformName Varchar(50)

** Modification Hist:       
**            
** Date                           Name                                     Modification 

*******************************************************************************/

SELECT *  FROM [AppAdmin].[ti_adm_transform] T 
INNER JOIN [AppAdmin].[ti_adm_ObjectOwner] Tobj 
	ON Tobj.Objectid = t.TargetObjectID and Tobj.ISActive =1   
WHERE T.TransformName =@TransformName

END
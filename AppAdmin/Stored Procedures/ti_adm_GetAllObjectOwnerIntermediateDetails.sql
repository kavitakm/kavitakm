-- exec [AppAdmin].[ti_adm_GetAllObjectOwnerIntermediateDetails]
Create PROCEDURE [AppAdmin].[ti_adm_GetAllObjectOwnerIntermediateDetails]
As
Begin
	Select ObjectID,
	ObjectName,
	ObjectType,
	SchemaName,
	CreatedDate,
	CreatedBy,
	UserEmail
	FROM [AppAdmin].[ti_adm_ObjectOwner_Intermediate]
	Where IsActive =1
End
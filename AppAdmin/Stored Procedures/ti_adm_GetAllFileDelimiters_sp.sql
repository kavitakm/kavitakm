CREATE PROCEDURE [AppAdmin].[ti_adm_GetAllFileDelimiters_sp]
AS
BEGIN

	SELECT
	[DelimiterID],
	[DelimiterName],
	[DelimiterDisplayName]
	FROM
	[AppAdmin].[ti_adm_FileDelimiters_lu]
	WHERE
	[IsActive]=1;

END
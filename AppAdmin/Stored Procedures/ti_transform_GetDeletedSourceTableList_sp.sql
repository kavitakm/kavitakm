--exec [AppAdmin].[ti_Transform_GetDeletedSourceTableList_sp] '7154, 7137,4,5,7001'
CREATE PROCEDURE  [AppAdmin].[ti_Transform_GetDeletedSourceTableList_sp]                     
@ObjectIDs varchar(max)                
               
AS                  
BEGIN     
  
/**************************************************************************    
** Version                : 1.0     
** Author                 : Srimathi    
** Description            : Return a comma separated list of invalid table objects
** Date					  : 09-12-2020

*******************************************************************************/    
select stuff((
select ',' + del from (
	SELECT cast(objectid as varchar(max)) as del
	FROM appadmin.ti_adm_objectowner 
	where objectid in (
		SELECT trim(VALUE) FROM string_split(@ObjectIDs,',') )
	and isactive = 0
	union
	SELECT trim(VALUE) as del FROM string_split(@ObjectIDs,',') 
	where value not in (select objectid from appadmin.ti_adm_objectowner)
	) a
	for xml path('')),1,1,'');

END     
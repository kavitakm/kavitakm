
--exec [AppAdmin].[ti_Analyze_StatisticsList_sp] '','','All','sunitha@tesserinsights.com'  
CREATE Proc [AppAdmin].[ti_Analyze_StatisticsList_sp]                    
@SearchText varchar(100),  
@InnerSearchText varchar(100),  
@SchemaName varchar(30),  
@UserEmail varchar(100)                            
As                     
BEGIN     
/**************************************************************************    
** Version                : 1.0           
** Author                 : Dinesh    
** Description            : Generate list of Tables with schema name for which analysis has been done and saved    
** Date       : 23-Aug-2019    
  **Modification History  
   19-12-2019  Sunitha   Added Audit Columns  
   28-02-2020  Srimathi  Added TAI_Enabled flag in select list  
   23-03-2020  Srimathi  Removed union and alternatively added a filter, added shared count in select list
   02-12-2020   Sunitha  Added UserEmail in the where caluse to include ownername in searchText(Bug#552)
*******************************************************************************/    
    
 DECLARE @UserID int  
 SELECT @UserID=[AppAdmin].[ti_adm_getUserID_fn](@UserEmail)  
 SELECT Distinct     
    O.ObjectName as TableName
   ,O.ObjectID As TableID
   ,O.SchemaName  
   , SCHEMA_ID(O.SchemaName) as SchemaID    
   ,MIN(S.CreatedDate) CreatedDate                  
   ,U.userEmail as CreatedBy   
   ,LU.UserEmail as ModifiedBy  
   ,MAX(S.LastUpdatedDate) as ModifiedDate  
   ,O.TAI_Enabled as TAI_Enabled  
   --Added on 3/23/2020 to display shared count - Srimathi
   , case when max(o.createdby) = @userid then 'True' else 'False' end as [IsOwnObject]    
   , (Select Count(*) from [AppAdmin].[ti_adm_ObjectAccessGrant] where isActive =1 And ObjectID = O.ObjectID) as [GrantCount]  
 FROM  [AppAdmin].[ti_adm_SummaryStatistics] S    
 INNER JOIN [AppAdmin].[ti_adm_ObjectOwner] O   
 ON S.ObjectID = O.ObjectID AND S.isActive = 1   
  AND O.IsActive=1
 INNER  JOIN [AppAdmin].[ti_adm_User_lu] U   
 ON O.CreatedBy = U.UserID and U.isactive =1   
 INNER JOIN [AppAdmin].[ti_adm_User_lu] LU   
 ON O.LastUpdatedBy = LU.UserID and LU.isactive =1   
  
 WHERE   
 --Added on 3/23/2020 and removed union - Srimathi
 (o.objectid in (select objectid from appadmin.ti_adm_ObjectAccessGrant where GrantToUser = @userid and isactive = 1)
 or
 o.createdby = @userid) 
 and 
   ((Len(@SearchText) = 0 ) OR  
   (Len(@SearchText) > 0 and ( O.SchemaName like '%' + @SearchText +'%'   
    or O.ObjectName like '%' + @SearchText +'%'                  
    or S.Column1Name like '%' + @SearchText +'%'                  
    or S.Column2Name like '%' + @SearchText +'%'                  
    or S.Column3Name like '%' + @SearchText +'%'                  
    or S.Column4Name like '%' + @SearchText +'%'                  
    --or S.CreatedDate like '%' + @SearchText +'%'  
	or S.LastUpdatedDate like '%' + @SearchText +'%'  
	or U.userEmail like '%' + @SearchText +'%'  
    )))  
     
   AND ((Len(@InnerSearchText) =0 )   
  OR (Len(@InnerSearchText) >0 and (O.SchemaName like '%' + @InnerSearchText +'%'   
   or O.ObjectName like '%' + @InnerSearchText +'%'                  
   or S.Column1Name like '%' + @InnerSearchText +'%'                  
   or S.Column2Name like '%' + @InnerSearchText +'%'                  
   or S.Column3Name like '%' + @InnerSearchText +'%'                  
   or S.Column4Name like '%' + @InnerSearchText +'%'                  
   --or S.CreatedDate like '%' + @InnerSearchText +'%'   
   or S.LastUpdatedDate like '%' + @InnerSearchText +'%'   
    or U.userEmail like '%' + @InnerSearchText +'%'  
   )))  
  
   And (((Upper(@SchemaName) = 'ALL' AND 1=1 ) or ( Upper(@SchemaName) <> 'ALL' and  O.SchemaName = @SchemaName )))  
  
   GROUP BY   O.ObjectName, O.ObjectID,O.SchemaName  
  , SCHEMA_ID(O.SchemaName)                    
  ,U.userEmail  
  ,LU.UserEmail  
  ,O.TAI_Enabled   
  
  /*
  UNION ALL  
  
  SELECT Distinct     
     O.ObjectName as TableName 
    ,O.ObjectID As TableID
    ,O.SchemaName  
   , SCHEMA_ID(O.SchemaName) as SchemaID    
   ,MIN(S.CreatedDate) CreatedDate                  
   ,U.userEmail as CreatedBy   
   ,LU.UserEmail as ModifiedBy  
   ,MAX(S.LastUpdatedDate) as ModifiedDate  
   ,O.TAI_Enabled as TAI_Enabled  
   
 FROM  [AppAdmin].[ti_adm_SummaryStatistics] S    
 INNER JOIN [AppAdmin].[ti_adm_ObjectOwner] O   
 ON S.ObjectID = O.ObjectID AND S.isActive = 1   
  AND O.IsActive=1   
 INNER  JOIN [AppAdmin].[ti_adm_User_lu] U   
 ON O.CreatedBy = U.UserID and U.isactive =1   
 INNER JOIN [AppAdmin].[ti_adm_User_lu] LU   
 ON O.LastUpdatedBy = LU.UserID and LU.isactive =1   
 INNER JOIN  [AppAdmin].[ti_adm_ObjectAccessGrant] GT on GT.ObjectID = O.objectID and GT.Isactive=1 and GT.GrantToUser = @userid    
 WHERE   
   
   ((Len(@SearchText) = 0 ) OR  
   (Len(@SearchText) > 0 and ( O.SchemaName like '%' + @SearchText +'%'   
    or O.ObjectName like '%' + @SearchText +'%'                  
    or S.Column1Name like '%' + @SearchText +'%'                  
    or S.Column2Name like '%' + @SearchText +'%'                  
    or S.Column3Name like '%' + @SearchText +'%'                  
    or S.Column4Name like '%' + @SearchText +'%'                  
    or S.CreatedDate like '%' + @SearchText +'%'              
    )))  
     
   AND ((Len(@InnerSearchText) =0 )   
  OR (Len(@InnerSearchText) >0 and (O.SchemaName like '%' + @InnerSearchText +'%'   
   or O.ObjectName like '%' + @InnerSearchText +'%'                  
   or S.Column1Name like '%' + @InnerSearchText +'%'                  
   or S.Column2Name like '%' + @InnerSearchText +'%'                  
   or S.Column3Name like '%' + @InnerSearchText +'%'                  
   or S.Column4Name like '%' + @InnerSearchText +'%'                  
   or S.CreatedDate like '%' + @InnerSearchText +'%'                
   )))  
  
   And (((Upper(@SchemaName) = 'ALL' AND 1=1 ) or ( Upper(@SchemaName) <> 'ALL' and  O.SchemaName = @SchemaName )))  
  
   GROUP BY   O.ObjectName, O.ObjectID ,O.SchemaName  
  , SCHEMA_ID(O.SchemaName)                    
  ,U.userEmail  
  ,LU.UserEmail  
  ,O.TAI_Enabled   
                   
 */                 
End 
GO



--exec [AppAdmin].[ti_catalog_univariateAnalysis_sp] 'sandbox','bug930'      
      
CREATE   PROC [AppAdmin].[ti_catalog_univariateAnalysis_sp]       
@SchemaName   VARCHAR(50),      
@TableName    VARCHAR(200)      
AS                   
BEGIN              
      
/******************************************************      
** Version               : 1.0                     
** Author                : Sunitha              
** Description           : to get the list of univariate analysis columns of specified table for catalog page profile tab              
** Date      : 19-12-2019                 
*******************************************************/      
      
 SELECT       
 replace(replace(Column1Name, '[', ''),']','')  AS ColumnName      
 ,[Count]      
 ,Complete      
 ,Missing      
 ,Mean      
 ,Median      
 ,Mode      
 ,P0      
 ,p25      
 ,P50      
 ,P75      
 ,P100      
 ,WeightedMean      
 ,HarmonicMean      
 ,QuadraticMean      
 ,[Sum]      
 ,[Min]      
 ,[Max]      
 ,SD       
 ,cast(Variance as varchar) as Variance     
 ,Cby.UserEmail      
 ,LBy.UserEmail      
 ,S.CreatedDate      
 ,s.LastUpdatedDate      
 FROM       
 AppAdmin.ti_adm_summaryStatistics S    
 inner join appadmin.ti_adm_objectowner O  ON O.ObjectID = S.ObjectID and O.ObjectType ='Table' AND o.IsActive=1 and ObjectName = @TableName AND ISNULL(SchemaName,'') = @SchemaName  AND ISNULL(o.ObjectLocation,'') ='' AND ISNULL(FileExt,'') = ''    
 JOIN AppAdmin.ti_adm_User_lu CBy  ON S.CreatedBy = CBy.UserID      
 JOIN AppAdmin.ti_adm_User_lu LBy  ON S.LastUpdatedBy = LBy.UserID     
    
 WHERE       
 --objectId = 78 --[AppAdmin].[ti_adm_getObjectID_fn](@TableName, 'Table', @SchemaName, '', '')       
 -- AND    
    
 Column2Name IS NULL AND S.ISActive = 1      
      
END 
GO




--exec [AppAdmin].[ti_Datalake_getObjectsCount_sp] '','','ALL','Dinesh@tesserinsights.com'       
CREATE PROC [AppAdmin].[ti_Datalake_getObjectsCount_sp]                  
@SearchText VARCHAR(100),        
@InnerSearchText VARCHAR(100),        
@SchemaName VARCHAR(30),        
@UserEmail VARCHAR(100)            
As                   
BEGIN   
--declare @SearchText varchar(100),        
--@InnerSearchText varchar(100),        
--@SchemaName varchar(30),        
--@UserEmail varchar(100)            
--set @SearchText =''   
--set @InnerSearchText=''  
--set @SchemaName='ALL'  
--set @UserEmail='dinesh@tesserinsights.com'  
DECLARE @userid int;     
DECLARE @objecttype varchar(10)='Table'  
  
SELECT @userid = userid from appadmin.ti_adm_user_lu where useremail = @UserEmail and isactive=1;    
  
WITH cte_objectype  
AS  
(  
-- get objects of Reports,tables,files,transform   
SELECT obj.objectId,obj.Objecttype,obj.objectname,obj.schemaname ,'' as AnalyticsPBIDataSet 
FROM        
[AppAdmin].[ti_adm_ObjectOwner] OBJ         
WHERE  OBJ.ISACtive=1 AND OBJ.Createdby=@userID AND obj.ObjectType NOT IN ( 'Table', 'Cleanse','Transform') 
 AND  ((Len(@SearchText) = 0 ) OR (Len(@SearchText) > 0   
 AND ( OBJ.ObjectName like '%' + @SearchText +'%' )))        
 AND ((Len(@InnerSearchText) =0 )OR(Len(@InnerSearchText) >0   
 AND ( OBJ.ObjectName like '%' + @InnerSearchText +'%')))        
 AND (((Upper(@SchemaName) = 'ALL' AND 1=1 )   
   OR ( Upper(@SchemaName) <> 'ALL'   
   AND  OBJ.SchemaName = @SchemaName )))   

UNION ALL 
   
SELECT obj.objectId,obj.Objecttype,obj.objectname,obj.schemaname,VIDataSet.Object_GUID as AnalyticsPBIDataSet  
FROM        
[AppAdmin].[ti_adm_ObjectOwner] OBJ
INNER Join (
		Select Vi.Predecessorid as TableID,obj1.objectid,obj1.Object_GUID from [AppAdmin].[ti_adm_ObjectOwner] obj1
		INNER JOIN [AppAdmin].[ti_adm_visualize] vi on obj1.objectID = vi.objectID and obj1.ObjectType ='Dataset'  and OBJ1.isActive = 1
		Inner join [AppAdmin].[ti_adm_User_lu] ul on ul.UserID = obj1.createdBy and ul.userEmail ='TesserPlatformSignIn@tesserinsights.com') VIDataSet on Obj.ObjectID = VIDataSet.TableID        
          
WHERE  OBJ.ISACtive=1 AND OBJ.Createdby=@userID And obj.objectType ='Table'  
 AND  ((Len(@SearchText) = 0 ) OR (Len(@SearchText) > 0   
 AND ( OBJ.ObjectName like '%' + @SearchText +'%' )))        
 AND ((Len(@InnerSearchText) =0 )OR(Len(@InnerSearchText) >0   
 AND ( OBJ.ObjectName like '%' + @InnerSearchText +'%')))        
 AND (((Upper(@SchemaName) = 'ALL' AND 1=1 )   
   OR ( Upper(@SchemaName) <> 'ALL'   
   AND  OBJ.SchemaName = @SchemaName )))   

Union ALL

SELECT obj.objectId,obj.Objecttype,obj.objectname,obj.schemaname,VIDataSet.Object_GUID as AnalyticsPBIDataSet  
FROM        
[AppAdmin].[ti_adm_ObjectOwner] OBJ
inner join [AppAdmin].[ti_adm_transform] T on obj.Objectid = t.ObjectID and obj.ISActive =1 And obj.CreatedBy = @userID and obj.objectType in ('Cleanse','Transform')
INNER JOIN (  
  Select Vi.Predecessorid as TableID,obj1.objectid,obj1.Object_GUID from [AppAdmin].[ti_adm_ObjectOwner] obj1  
  INNER JOIN [AppAdmin].[ti_adm_visualize] vi on obj1.objectID = vi.objectID and obj1.ObjectType ='Dataset'  and OBJ1.isActive = 1  
  INNER JOIN [AppAdmin].[ti_adm_User_lu] ul on ul.UserID = obj1.createdBy and ul.userEmail ='TesserPlatformSignIn@tesserinsights.com') VIDataSet on t.TargetObjectID = VIDataSet.TableID 
         
WHERE  ((Len(@SearchText) = 0 ) OR (Len(@SearchText) > 0   
 AND ( OBJ.ObjectName like '%' + @SearchText +'%' )))        
 AND ((Len(@InnerSearchText) =0 )OR(Len(@InnerSearchText) >0   
 AND ( OBJ.ObjectName like '%' + @InnerSearchText +'%')))        
 AND (((Upper(@SchemaName) = 'ALL' AND 1=1 )   
   OR ( Upper(@SchemaName) <> 'ALL'   
   AND  OBJ.SchemaName = @SchemaName ))) 
Union ALL
---- get granted objects of Reports,tables,files,transform   
SELECT obj.objectID,obj.objectType,obj.objectname,obj.schemaname ,'' as AnalyticsPBIDataSet 
FROM        
[AppAdmin].[ti_adm_ObjectOwner] OBJ            
INNER JOIN  [AppAdmin].[ti_adm_ObjectAccessGrant] GT       
ON GT.ObjectID = obj.objectID   
 AND GT.Isactive=1 AND  OBJ.ISACtive=1  
 AND GT.GrantToUser = @userid   
--INNER JOIN information_Schema.Columns isc  
-- ON  @objecttype ='Table' and isc.table_name=obj.objectname and isc.table_schema=obj.schemaname  
WHERE  ((Len(@SearchText) = 0 )   
   OR (Len(@SearchText) > 0   
   AND ( OBJ.ObjectName like '%' + @SearchText +'%' )))     
 AND ((Len(@InnerSearchText) =0 )    
   OR (Len(@InnerSearchText) >0   
   AND ( OBJ.ObjectName like '%' + @InnerSearchText +'%')))        
 AND (((Upper(@SchemaName) = 'ALL' AND 1=1 )   
   OR ( Upper(@SchemaName) <> 'ALL'  
   AND  OBJ.SchemaName = @SchemaName )))   
UNION ALL   
--get integrate objects  
SELECT  obj.objectID,'Integrate' as ObjectType,obj.objectname,obj.schemaname,'' as AnalyticsPBIDataSet  
FROM [AppAdmin].[ti_adm_integrate] as i     
INNER JOIN [AppAdmin].[ti_adm_ObjectOwner] as obj    
 ON i.[ObjectID] = obj.[ObjectID]    
WHERE i.IsActive = 1     
 AND i.CreatedBy = @userid    
 AND ((Len(@SearchText) = 0 ) OR (Len(@SearchText) > 0 and ( i.APIName like '%' + @SearchText +'%' OR i.APIDescription like '%' + @SearchText +'%'     
  OR i.CreatedDate like '%' + @SearchText +'%' )))      
 AND ((Len(@InnerSearchText) =0 ) OR (Len(@InnerSearchText) >0 AND ( i.APIName like '%' + @InnerSearchText +'%' OR i.APIDescription like '%' + @InnerSearchText +'%'     
  OR i.CreatedDate like '%' + @InnerSearchText +'%')))   
-----------------------------------  
UNION ALL  
--get Analyze objects  
SELECT DISTINCT  O.ObjectID  
 ,'Analyze' as ObjectType,o.objectname,o.schemaname,VIDataSet.Object_GUID as AnalyticsPBIDataSet 
FROM  [AppAdmin].[ti_adm_SummaryStatistics] S    
INNER JOIN [AppAdmin].[ti_adm_ObjectOwner] O   
 ON S.ObjectID = O.ObjectID   
  AND S.isActive = 1   
  AND O.IsActive=1   
  AND  O.CreatedBy = @UserID    
INNER  JOIN [AppAdmin].[ti_adm_User_lu] U   
 ON O.CreatedBy = U.UserID and U.isactive =1   
INNER JOIN [AppAdmin].[ti_adm_User_lu] LU   
 ON O.LastUpdatedBy = LU.UserID and LU.isactive =1   
INNER JOIN (
		Select Vi.Predecessorid as TableID,obj1.objectid,obj1.Object_GUID from [AppAdmin].[ti_adm_ObjectOwner] obj1
		INNER JOIN [AppAdmin].[ti_adm_visualize] vi on obj1.objectID = vi.objectID and ObjectType ='Dataset' 
		Inner join [AppAdmin].[ti_adm_User_lu] ul on ul.UserID = obj1.createdBy and ul.userEmail ='TesserPlatformSignIn@tesserinsights.com') VIDataSet on  VIDataSet.TableID = O.ObjectID   
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
  
UNION ALL   
SELECT DISTINCT   O.ObjectID ,'Analyze' as ObjectType,o.objectname,o.schemaname ,VIDataSet.Object_GUID as AnalyticsPBIDataSet  
FROM  [AppAdmin].[ti_adm_SummaryStatistics] S    
INNER JOIN [AppAdmin].[ti_adm_ObjectOwner] O   
 ON S.ObjectID = O.ObjectID AND S.isActive = 1   
  AND O.IsActive=1   
INNER JOIN  [AppAdmin].[ti_adm_ObjectAccessGrant] GT   
 on GT.ObjectID = O.objectID and GT.Isactive=1 AND GT.GrantToUser = @userid    
INNER JOIN (
		Select Vi.Predecessorid as TableID,obj1.objectid,obj1.Object_GUID from [AppAdmin].[ti_adm_ObjectOwner] obj1
		INNER JOIN [AppAdmin].[ti_adm_visualize] vi on obj1.objectID = vi.objectID and ObjectType ='Dataset' 
		Inner join [AppAdmin].[ti_adm_User_lu] ul on ul.UserID = obj1.createdBy and ul.userEmail ='TesserPlatformSignIn@tesserinsights.com') VIDataSet on  VIDataSet.TableID = O.ObjectID   

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
  
)  
SELECT 
objecttype,count(*) cnt  
FROM cte_objectype obj   
WHERE objecttype<>'table'  
GROUP BY objecttype  
UNION   
 Select o.objecttype,count(*) cnt  
FROM cte_objectype o  
INNER JOIN (SELECT DISTINCT table_name,table_schema  
  FROM INFORMATION_SCHEMA.COLUMNS) isc  
 ON  isc.table_name=o.objectname   
  AND isc.table_schema=o.schemaname  
WHERE o.objecttype='table'   
GROUP BY o.objecttype   
  
  -- select  distinct table_name,table_schema from INFORMATION_SCHEMA.COLUMNs where table_name in ('SO_DTL_RPT_F','LZ_SO','LZ_SO_DTL','Dim_Customer1')  
  --select distinct SchemaName,ObjectName,ObjectType,isactive,* from AppAdmin.ti_adm_ObjectOwner where ObjectName in ('SO_DTL_RPT_F','LZ_SO','LZ_SO_DTL','Dim_Customer1') 
  
  
END  
GO



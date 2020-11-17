--Exec [AppAdmin].[ti_Analyze_StatisticsDetailList_sp] 'Sandbox','QI_credit_union','dinesh@tesserinsights.com'
 
 
CREATE Proc [AppAdmin].[ti_Analyze_StatisticsDetailList_sp]                      
@SchemaName varchar(100),      
@TableName varchar(100),      
@UserEmail varchar(100)                              
As                       
BEGIN        
/**************************************************************************      
** Version                : 1.1            
** Author                 : Dinesh      
** Description            : Generate detailed list of univariate / bivariate analysis done on a particular table      
** Date       : 23-Aug-2019      
    
** Date   Version   Changes    
**  Modification History
**27-oct-2020   sunitha    Modified the column1 and column2 swapping logic       
*******************************************************************************/      
      
  SELECT * FROM (  
 SELECT 
 O.ObjectID AS TableID
  ,O.ObjectName as TableName    
 , O.SchemaName    
 ---code changes to remove swapping 
 /**************************************/
 ,S.Column1Name AS Column1Name 
 ,CASE WHEN S.Column2Name IS NOT  NULL AND col1.DATA_TYPE in ('NVARCHAR','VARCHAR','CHAR','NCHAR','DATETIME','SMALLDATETIME','DATE','BIT','DATETIME2')  THEN 'C'
		 WHEN S.Column2Name IS NULL THEN ''
		 ELSE 'N'
		  END AS col1_catorNum
,ISNULL(S.Column2Name,'') AS Column2Name
,CASE WHEN S.Column2Name IS NOT  NULL  AND col2.DATA_TYPE in ('NVARCHAR','VARCHAR','CHAR','NCHAR','DATETIME','SMALLDATETIME','DATE','BIT','DATETIME2') THEN 'C'
	  WHEN S.Column2Name IS NULL THEN ''
		 ELSE 'N'			
		  END AS col2_catorNum

 /**************************************/

 
 --,CASE WHEN Isnull(S.Column2Name ,'') = '' OR S.Column1Name  < Isnull(S.Column2Name ,'') THEN S.Column1Name ELSE Isnull(S.Column2Name ,'') END Column1Name  
 --,CASE   
 --WHEN Isnull(S.Column2Name ,'') = '' OR S.Column1Name  < Isnull(S.Column2Name ,'')   
 -- THEN   
 -- CASE   
 --  WHEN S.Column2Name is NULL  
 --  THEN ''  
 --  WHEN S.Column2Name is NOT NULL AND S.Column1Value is NULL  
 --  THEN 'N'  
 --  ELSE 'C'  
 -- END  
 -- ELSE  
 -- CASE  
 --  WHEN S.Column2Value is NULL   
 --  THEN 'N'  
 --  ELSE 'C'  
 -- END  
 --END AS col1_catorNum  
 -- ,CASE WHEN Isnull(S.Column2Name ,'') = '' OR S.Column1Name  < Isnull(S.Column2Name ,'') THEN Isnull(S.Column2Name ,'') ELSE S.Column1Name END as Column2Name   
 -- ,CASE   
 --WHEN Isnull(S.Column2Name ,'') = '' OR S.Column1Name  < Isnull(S.Column2Name ,'')   
 -- THEN   
 -- CASE   
 --  WHEN S.Column2Name is NULL  
 --  THEN ''  
 --  WHEN S.Column2Name is NOT NULL AND S.Column2Value is NULL  
 --  THEN 'N'  
 --  ELSE 'C'  
 -- END  
 -- ELSE  
 -- CASE   
 --  WHEN S.Column1Value is NULL   
 --  THEN 'N'  
 --  ELSE 'C'  
 -- END  
 --END AS col2_catorNum  
  
 ,Isnull(S.Column3Name ,'')  as Column3Name  
 ,Isnull(S.Column4Name , '') as Column4Name  
 ,Isnull(col1.DATA_TYPE,'') as Column1Type    
 ,Isnull(col2.DATA_TYPE,'') as Column2Type    
 ,Isnull(col3.DATA_TYPE,'') as Column3Type    
 ,Isnull(col4.DATA_TYPE,'') as Column4Type    
 ,[Schemas].schema_id     
 ,CBy.FirstName as CreatedByFirstName    
 ,CBy.LastName as  CreatedByLastName    
 ,CBy.UserEmail as  CreatedByUserEmail    
 ,S.CreatedDate    
 ,UBy.FirstName as UpdatedByFirstName    
 ,UBy.LastName as  UpdatedByLastName    
 ,UBy.UserEmail as  UpdatedByUserEmail    
 ,S.LastUpdatedDate  
 , ROW_NUMBER() OVER(PARTITION BY  O.ObjectName , O.SchemaName    
 ,CASE WHEN Isnull(S.Column2Name ,'') = '' OR S.Column1Name  < Isnull(S.Column2Name ,'') THEN S.Column1Name ELSE Isnull(S.Column2Name ,'') END   
 ,CASE WHEN Isnull(S.Column2Name ,'') = '' OR S.Column1Name  < Isnull(S.Column2Name ,'') THEN Isnull(S.Column2Name ,'') ELSE S.Column1Name END   
 ,Isnull(S.Column3Name ,'')    
 ,Isnull(S.Column4Name , '') ORDER BY S.CREATEDBY DESC) ROW_NBR  
   
 FROM  [AppAdmin].[ti_adm_SummaryStatistics] S    
 INNER JOIN [AppAdmin].[ti_adm_ObjectOwner] O on S.ObjectID = O.ObjectID and S.isActive = 1 and O.IsActive=1    
 INNER JOIN INFORMATION_SCHEMA.columns col1 on col1.table_schema = @SchemaName and col1.table_name = @TableName and col1.column_name=replace(replace(S.Column1Name,'[',''),']','')    
 LEFT OUTER JOIN INFORMATION_SCHEMA.columns col2 on col2.table_schema = @SchemaName and col2.table_name = @TableName and col2.column_name=replace(replace(S.Column2Name,'[',''),']','')    
 LEFT OUTER JOIN INFORMATION_SCHEMA.columns col3 on col3.table_schema = @SchemaName and col3.table_name = @TableName and col3.column_name=replace(replace(S.Column3Name,'[',''),']','')    
 LEFT OUTER JOIN INFORMATION_SCHEMA.columns col4 on col4.table_schema = @SchemaName and col4.table_name = @TableName and col4.column_name=replace(replace(S.Column4Name,'[',''),']','')    
 INNER JOIN sys.schemas  AS [Schemas]  ON [Schemas].name = @SchemaName    
      
 Left Join [AppAdmin].[ti_adm_User_lu] CBy on CBy.UserID = S.CreatedBy    
 Left Join [AppAdmin].[ti_adm_User_lu] UBy on UBy.UserID = S.LastUpdatedBy    
 where O.SchemaName = @SchemaName     
 and O.ObjectName = @TableName  ) a   
   
 WHERE a.ROW_NBR=1  
 Order By a.CreatedDate desc           
               
                
                    
End
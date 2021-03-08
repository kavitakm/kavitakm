-- exec [AppAdmin].[ti_Catalog_ListFileObjects_sp]  '' ,'','sunitha@tesserinsights.com'      
ALTER PROC [AppAdmin].[ti_Catalog_ListFileObjects_sp]              
@SearchText varchar(100),      
@InnerSearchText varchar(100),      
@UserEmail varchar(100)      
As               
BEGIN          
/**************************************************************************          
** Version               : 1.0                 
** Author                : Dinesh          
** Description           : Generate list of Tables stored in SQL Server - used in Catalog list page          
** Date                  : 23-Aug-2019          
 Modification History:    
 18-12-2019   Sunitha   Added Audit Columns    
 02-12-2020   Sunitha   Added Search Filters in where clause Bug#552
 19-02-2021   Dinesh    Added File DelimiterID, DelimiterName,DelimiterDisplayname  
*******************************************************************************/          
DECLARE @userid int;      
SELECT @userid = userid from appadmin.ti_adm_user_lu where useremail = @UserEmail and isactive=1;      
      
   SELECT  
    OBJ.ObjectID AS [ObjectID]  
   ,OBJ.ObjectName AS [Name]          
   ,OBJ.FileExt AS [FileType]        
   ,Convert(varchar,OBJ.FileSize) as [Size]      
   ,OBJ.CreatedDate AS [CreatedDate]      
   ,U.UserEMail As [CreatedBy]      
   ,OBJ.LastUpDatedDate AS [LastModified]      
   ,'' AS Download      
   ,OBJ.ObjectLocation AS [Location]     
    , 'True' as [IsOwnObject]     
   ,lu.UserEmail AS ModifiedBy    
   , OBJ.Favourite AS Favourite    
   , (Select Count(*) from [AppAdmin].[ti_adm_ObjectAccessGrant] where isActive =1 And ObjectID = OBJ.ObjectID) as [GrantCount]    
   , CASE WHEN TRIM(OBJ.maskedColumns) in('','[]') THEN 0 ELSE (SELECT COUNT(value) ct FROM STRING_SPLIT(OBJ.maskedColumns,',')) END maskedCount 
   ,D.DelimiterID
   ,D.DelimiterName
   ,D.DelimiterDisplayName 
 FROM  [AppAdmin].[ti_adm_ObjectOwner] OBJ  INNER JOIN [Appadmin].[ti_adm_User_lu] u      
 ON obj.createdby = u.userid       
 INNER JOIN [Appadmin].[ti_adm_User_lu] lu ON obj.LastUpdatedBy = lu.userid
 LEFT JOIN [AppAdmin].[ti_adm_FileDelimiters_lu] D ON D.DelimiterID = obj.FileDelimiterID     
 WHERE OBJ.objectType ='File' AND OBJ.ISactive = 1   AND obj.CreatedBy = @userid       
 --and OBJ.ObjectName LIKE '%' + @SearchText +'%'      
 AND ((Len(@SearchText) = 0 ) OR  (Len(@SearchText) > 0 and ( OBJ.ObjectName like '%' + @SearchText +'%'  
  or OBJ.FileExt like '%' + @SearchText +'%'                        
   or OBJ.FileSize like '%' + @SearchText +'%'                        
   or U.UserEmail like '%' + @SearchText +'%'                      
   or OBJ.CreatedDate like '%' + @SearchText +'%'   
   or OBJ.LastUpDatedDate like '%' + @SearchText +'%'   
   or OBJ.ObjectLocation like '%' + @SearchText +'%'   
     
 )))      
 AND ((Len(@InnerSearchText) =0 ) OR (Len(@InnerSearchText) >0 and (OBJ.ObjectName like '%' + @InnerSearchText +'%'   
 or OBJ.FileExt like '%' + @InnerSearchText +'%'                        
   or OBJ.FileSize like '%' + @InnerSearchText +'%'                        
   or U.UserEmail like '%' + @InnerSearchText +'%'                      
   or OBJ.CreatedDate like '%' + @InnerSearchText +'%'   
   or OBJ.LastUpDatedDate like '%' + @InnerSearchText +'%'   
   or OBJ.ObjectLocation like '%' + @InnerSearchText +'%'   
     
   )))      
 Union ALL      
      
 SELECT  
 OBJ.ObjectID AS [ObjectID]  
   ,OBJ.ObjectName AS [Name]          
   ,OBJ.FileExt AS [FileType]        
   ,Convert(varchar,OBJ.FileSize) as [Size]      
   ,OBJ.CreatedDate AS [CreatedDate]      
   ,U.UserEmail As [CreatedBy]      
   ,OBJ.LastUpDatedDate AS [LastModified]      
   ,'' AS Download      
   ,OBJ.ObjectLocation AS [Location]    
   ,'False' as [IsOwnObject]    
   ,lu.UserEmail AS [ModifiedBy]    
   , GT.Favourite AS Favourite  
   , (Select Count(*) from [AppAdmin].[ti_adm_ObjectAccessGrant] where isActive =1 And ObjectID = OBJ.ObjectID) as [GrantCount]   
   , CASE WHEN TRIM(OBJ.maskedColumns) in('','[]') THEN 0 ELSE (SELECT COUNT(value) ct FROM STRING_SPLIT(OBJ.maskedColumns,',')) END maskedCount
   ,D.DelimiterID
   ,D.DelimiterName
   ,D.DelimiterDisplayName   
 FROM  [AppAdmin].[ti_adm_ObjectOwner] OBJ        
 INNER JOIN [Appadmin].[ti_adm_User_lu] u  ON obj.createdby = u.userid      
  INNER JOIN [Appadmin].[ti_adm_User_lu] lu      
 ON obj.LastUpdatedBy = lu.userid       
 INNER JOIN  [AppAdmin].[ti_adm_ObjectAccessGrant] GT on GT.ObjectID = obj.objectID and GT.Isactive=1 and GT.GrantToUser = @userid       
 LEFT JOIN [AppAdmin].[ti_adm_FileDelimiters_lu] D on D.DelimiterID = obj.FileDelimiterID 
 WHERE OBJ.objectType ='File' AND OBJ.ISactive = 1         
     
 AND ((Len(@SearchText) = 0 ) OR      
   (Len(@SearchText) > 0 and ( OBJ.ObjectName like '%' + @SearchText +'%'   
   or OBJ.FileExt like '%' + @SearchText +'%'                        
   or OBJ.FileSize like '%' + @SearchText +'%'                        
   or U.UserEmail like '%' + @SearchText +'%'                      
   or OBJ.CreatedDate like '%' + @SearchText +'%'   
   or OBJ.LastUpDatedDate like '%' + @SearchText +'%'  
   or OBJ.ObjectLocation like '%' + @SearchText +'%'   
     
     )))      
 AND ((Len(@InnerSearchText) =0 ) OR (Len(@InnerSearchText) >0 and (OBJ.ObjectName like '%' + @InnerSearchText +'%'   
 or OBJ.FileExt like '%' + @InnerSearchText +'%'                        
   or OBJ.FileSize like '%' + @InnerSearchText +'%'                        
   or U.UserEmail like '%' + @InnerSearchText +'%'                      
   or OBJ.CreatedDate like '%' + @InnerSearchText +'%'  
   or OBJ.LastUpDatedDate like '%' + @InnerSearchText +'%'  
   or OBJ.ObjectLocation like '%' + @InnerSearchText +'%'  
     
   )))        
 Order By OBJ.CreatedDate Desc              
                 
 --END               
               
End
GO




--exec [AppAdmin].[ti_Transform_TransformList_sp] '','','harini@TesserInsights.com'      
CREATE Proc [AppAdmin].[ti_Transform_TransformList_sp]                            
 @SearchText varchar(100)      
,@InnerSearchText varchar(100)      
--,@SchemaName varchar(30)      
,@UserEmail Varchar(150)                                    
As                             
BEGIN               
/**************************************************************************              
** Version                : 1.0                     
** Author                 : Dinesh              
** Description            : Generate list of Transform/Cleanse objects - used in Transform list page              
** Date                   : 23-Aug-2019              
  Modification History:      
  19-12-2019	sunitha		Added Audit Columns 
  02/19/2020	Dinesh		Added GrantCount in Select list
  11/06/2020	Srimathi	Duplicate transform entries fix - only the row corresponding to active target
  11/30/2020	Srimathi	Added TargetObjectID in select clause
  12/2/2020     Sunitha     modified the created Date column with LastUpdatedDate in the Where Clause  filter(Bug#552)
*******************************************************************************/              
 Declare @UserID int;                  
  set @UserID = 0;                  
  Select @UserID = UserID from [AppAdmin].[ti_adm_User_lu] where IsActive =1  and UserEmail =@UserEmail            
               
 --if (Len(@SearchText) =0)                                    
 --BEGIN                       
                
             
 --Select             
 --  TObj.ObjectID as TransformId                      
 -- ,T.TransformName                      
 -- ,Obj.ObjectType as OutputType                      
 -- ,obj.ObjectNAme as OutputName                      
 -- ,obj.SchemaName                       
 -- ,tObj.createddate CreatedDate                      
 -- ,U.userEmail as UserName                      
 -- ,T.Notes                      
 -- ,obj.ObjectLocation as 'Location'                       
 -- ,schema_ID( obj.SchemaName)  as 'schema_ID'                 
 -- ,Tobj.ObjectType As 'TransactionType'        
 -- ,T.to_be_validated as 'To be Validated'      
 --from [AppAdmin].[ti_adm_transform] T            
 --INNER JOIN [AppAdmin].[ti_adm_ObjectOwner] Tobj on Tobj.Objectid = t.ObjectID AND Tobj.ISActive =1 And Tobj.CreatedBy = @UserID            
 --INNER JOIN [AppAdmin].[ti_adm_User_lu] U on TObj.CreatedBy = U.UserID and U.isactive =1            
 --INNER JOIN [AppAdmin].[ti_adm_ObjectOwner] obj on obj.Objectid = t.TargetObjectID  AND obj.IsActive =1           
 --WHERE (((Upper(@SchemaName) = 'ALL' AND 1=1 ) or ( Upper(@SchemaName) <> 'ALL' and  obj.SchemaName = @SchemaName )))      
       
 --Union all          
         
 --Select             
 --  TObj.ObjectID as TransformId                      
 -- ,T.TransformName                      
 -- ,Obj.ObjectType as OutputType                      
 -- ,obj.ObjectNAme as OutputName                      
 -- ,obj.SchemaName                       
 -- ,tObj.createddate CreatedDate                      
 -- ,U.userEmail as UserName                      
 -- ,T.Notes                      
 -- ,obj.ObjectLocation as 'Location'                       
 -- ,schema_ID( obj.SchemaName)  as 'schema_ID'                 
 -- ,Tobj.ObjectType As 'TransactionType'        
 -- ,T.to_be_validated as 'TobeValidated'      
 --from [AppAdmin].[ti_adm_transform] T            
 --INNER JOIN [AppAdmin].[ti_adm_ObjectOwner] Tobj on Tobj.Objectid = t.ObjectID and Tobj.ISActive =1 --And Tobj.CreatedBy = @UserID         
 --INNER JOIN  [AppAdmin].[ti_adm_ObjectAccessGrant] GT on GT.ObjectID = Tobj.objectID and GT.Isactive=1 and GT.GrantToUser = @userid             
 --INNER JOIN [AppAdmin].[ti_adm_User_lu] U on TObj.CreatedBy = U.UserID and U.isactive =1            
 --INNER JOIN [AppAdmin].[ti_adm_ObjectOwner] obj on obj.Objectid = t.TargetObjectID  AND obj.IsActive =1         
 --WHERE (((Upper(@SchemaName) = 'ALL' AND 1=1 ) or ( Upper(@SchemaName) <> 'ALL' and  obj.SchemaName = @SchemaName )))      
      
 --ORDER BY TransformId desc                 
                      
 --END                        
 --ELSE                       
 --BEGIN    
 
 SELECT a.TransformId, a.TransformName, a.OutputType, a.OutputName, a.SchemaName, a.CreatedDate, a.UserName, a.Notes,
 a.Location, a.[schema_ID], a.TransactionType, a.TobeValidated, a.CreatedBy, a.ModifiedBy, a.ModifiedDate, a.Favourite,
 a.IsOwnObject, a.[GrantCount], a.TAI_Enabled, a.Target_ObjectID
 FROM
 (
 Select             
  ROW_NUMBER() over(partition by TObj.ObjectID order by TObj.Objectid, obj.isactive desc) rn,

   TObj.ObjectID as TransformId                      
,T.TransformName                      
  ,Obj.ObjectType as OutputType                      
  ,obj.ObjectNAme as OutputName                      
  ,obj.SchemaName                       
  ,tObj.createddate CreatedDate                      
  ,U.userEmail as UserName                      
  ,T.Notes                      

  
 ,obj.ObjectLocation as 'Location'                       
  ,schema_ID( obj.SchemaName)  as 'schema_ID'                 
  ,Tobj.ObjectType As 'TransactionType'       
  ,T.to_be_validated as 'TobeValidated'      
  ,U.UserEmail as CreatedBy      
  ,LU.UserEmail as ModifiedBy      
  ,Tobj.LastUpdatedDate ModifiedDate      
  ,isnull(Tobj.Favourite,0) AS Favourite  
  , 'True' as [IsOwnObject] 
  , (Select Count(*) from [AppAdmin].[ti_adm_ObjectAccessGrant] where isActive =1 And ObjectID = TOBJ.ObjectID) as [GrantCount]
  , obj.TAI_Enabled as TAI_Enabled
  , obj.ObjectID as Target_ObjectID

 from [AppAdmin].[ti_adm_transform] T            
 INNER JOIN [AppAdmin].[ti_adm_ObjectOwner] Tobj on Tobj.Objectid = t.ObjectID and Tobj.ISActive =1 And Tobj.CreatedBy = @UserID            
 INNER JOIN [AppAdmin].[ti_adm_User_lu] U on TObj.CreatedBy = U.UserID and U.isactive =1            
 INNER JOIN [AppAdmin].[ti_adm_User_lu] LU on TObj.LastUpdatedBy = LU.UserID and LU.isactive =1        
 LEFT JOIN (select * from [AppAdmin].[ti_adm_ObjectOwner] where objecttype in('Table','File') and isactive = 1) obj on obj.Objectid = t.TargetObjectID  AND obj.IsActive =1             
                         
  where ((Len(@SearchText) =0  ) OR (Len(@SearchText) >0 and ( T.TransformName like '%' + @SearchText +'%' or Obj.ObjectType like '%' + @SearchText +'%'                      
   or obj.ObjectNAme like '%' + @SearchText +'%'                      
   or obj.SchemaName like '%' + @SearchText +'%'                      
   or T.Notes like '%' + @SearchText +'%'                      
   or U.userEmail like '%' + @SearchText +'%'                      
   --or tObj.createddate like '%' + @SearchText +'%'                    
   or tObj.LastUpdatedDate like '%' + @SearchText +'%'    
   or Tobj.ObjectType like '%' + @SearchText +'%')))      
         
   AND ((Len(@InnerSearchText) =0   ) OR (Len(@InnerSearchText) >0 and ( T.TransformName like '%' + @InnerSearchText +'%' or Obj.ObjectType like '%' + @InnerSearchText +'%'                      
   or obj.ObjectNAme like '%' + @InnerSearchText +'%'                      
   or obj.SchemaName like '%' + @InnerSearchText +'%'                      
   or T.Notes like '%' + @InnerSearchText +'%'                      
   or U.userEmail like '%' + @InnerSearchText +'%'                      
   --or tObj.createddate like '%' + @InnerSearchText +'%'                    
   or tObj.LastUpdatedDate like '%' + @InnerSearchText +'%'    
   or Tobj.ObjectType like '%' + @InnerSearchText +'%')))      
      
   --AND ((Upper(@SchemaName) = 'ALL' ) OR ( Upper(@SchemaName) <> 'ALL' AND  obj.SchemaName = @SchemaName ))      
         
   Union All        
        
   Select             
   ROW_NUMBER() over(partition by TObj.ObjectID order by TObj.Objectid, obj.isactive desc) rn,
   TObj.ObjectID as TransformId                      
  ,T.TransformName                      
  ,Obj.ObjectType as OutputType                      
  ,obj.ObjectNAme as OutputName                      
  ,obj.SchemaName                       
  ,tObj.createddate CreatedDate                      
  ,U.userEmail as UserName                      
  ,T.Notes                      
  ,obj.ObjectLocation as 'Location'                       
  ,schema_ID( obj.SchemaName)  as 'schema_ID'                 
  ,Tobj.ObjectType As 'TransactionType'      
  ,T.to_be_validated as 'TobeValidated'      
  ,U.UserEmail  CreatedBy      
  ,LU.UserEmail as ModifiedBy      
  ,Tobj.LastUpdatedDate ModifiedDate     
  , isnull(GT.Favourite,0) AS Favourite  
  , 'False' as [IsOwnObject] 
  , (Select Count(*) from [AppAdmin].[ti_adm_ObjectAccessGrant] where isActive =1 And ObjectID = TOBJ.ObjectID) as [GrantCount]
  , obj.TAI_Enabled as TAI_Enabled
  , obj.ObjectID as Target_ObjectID
 from [AppAdmin].[ti_adm_transform] T            
 INNER JOIN [AppAdmin].[ti_adm_ObjectOwner] Tobj on Tobj.Objectid = t.ObjectID and Tobj.ISActive =1 --And Tobj.CreatedBy = @UserID        
 INNER JOIN  [AppAdmin].[ti_adm_ObjectAccessGrant] GT on GT.ObjectID = Tobj.objectID and GT.Isactive=1 and GT.GrantToUser = @userid              
 INNER JOIN [AppAdmin].[ti_adm_User_lu] U on TObj.CreatedBy = U.UserID and U.isactive =1        
  INNER JOIN [AppAdmin].[ti_adm_User_lu] LU on TObj.LastUpdatedBy = LU.UserID and LU.isactive =1          
 LEFT JOIN (select * from [AppAdmin].[ti_adm_ObjectOwner] where objecttype in('Table','File') and isactive = 1) obj on obj.Objectid = t.TargetObjectID  AND obj.IsActive =1             
                         
  where ((Len(@SearchText) =0 ) OR (Len(@SearchText) >0 and ( T.TransformName like '%' + @SearchText +'%' or Obj.ObjectType like '%' + @SearchText +'%'                      
   or obj.ObjectName like '%' + @SearchText +'%'                      
   or obj.SchemaName like '%' + @SearchText +'%'                    
   or T.Notes like '%' + @SearchText +'%'                      
   or U.userEmail like '%' + @SearchText +'%'                      
   --or tObj.createddate like '%' + @SearchText +'%'                    
   or tObj.LastUpdatedDate like '%' + @SearchText +'%'    
   or Tobj.ObjectType like '%' + @SearchText +'%')))      
         
   AND ((Len(@InnerSearchText) =0  ) OR (Len(@InnerSearchText) >0 and ( T.TransformName like '%' + @InnerSearchText +'%' or Obj.ObjectType like '%' + @InnerSearchText +'%'                      
   or obj.ObjectNAme like '%' + @InnerSearchText +'%'                      
   or obj.SchemaName like '%' + @InnerSearchText +'%'                      
   or T.Notes like '%' + @InnerSearchText +'%'                      
   or U.userEmail like '%' + @InnerSearchText +'%'                      
   --or tObj.createddate like '%' + @InnerSearchText +'%'                    
   or tObj.LastUpdatedDate like '%' + @InnerSearchText +'%'    
   or Tobj.ObjectType like '%' + @InnerSearchText +'%')))      
        
   --and ((Upper(@SchemaName) = 'ALL'  ) or ( Upper(@SchemaName) <> 'ALL' and  obj.SchemaName = @SchemaName ))      
                      
  
  
  
) a
where 
rn=1  

Order by a.TransformId desc                             
                             
End   
GO



--declare @Objectlist  AppAdmin.ObjectList  
--insert into @Objectlist values('ITA_Accounting_Report','Report','IncorpTaxAct','76e37324-bb24-4605-bcd6-c4ef5cfcbb5b','f83cbbb0-5428-40c8-86b7-f55be8c0350b','','','','ITA_Accounting_Report','7971027b-c297-4e21-be8e-721a0126e90b')
--insert into @objectlist values('Advertising','Dataset','Tesser Insights','277daea8-af46-410d-a56e-c0c3b689036e','b8fc4be4-b782-4044-bf85-21f4050f4264','','','dinesh@tesserinsights.com','Advertising','277daea8-af46-410d-a56e-c0c3b689036e')
--insert into @objectlist values('ITA_Accounting_Report','Report','IncorpTaxAct','76e37324-bb24-4605-bcd6-c4ef5cfcbb5b','f83cbbb0-5428-40c8-86b7-f55be8c0350b','','','','ITA_Accounting_Report','7971027b-c297-4e21-be8e-721a0126e90b')
--insert into @objectlist values('Revenue','Dashboard','CPA','2e76099c-8a8b-486a-8c1e-4d70876914d7','dce0b5e3-5763-4350-966b-f1c656c2e9d2','','','','',)
/*('Advertising','dataset','Tesser Insights Inc',NULL,NULl,'sunitha@tesserinsights.com',''),
('CPA_Accounting_Report','dataset','CPA',NULL,NULl,'dinesh@tesserinsights.com','table1,table2'),  
('CPA_Accounting_Report','Report','CPA',NULL,NULl,'dinesh@tesserinsights.com','CPA_Accounting_Report'),  
('TestData','dataset','tesserdev',NULL,NULl,'sunitha@tesserinsights.com','test1,test2'),  
('SampleTestReport','Report','TesserDev',NULL,NULl,'dinesh@tesserinsights.com','testData'),  
('TestReport','Report','TesserDev',NULL,NULl,'dinesh@tesserinsights.com','testData')  */
--EXec Appadmin.ti_adm_SyncPBI_ObjectOwner_sp @ObjectList  
--select * from appadmin.test  
--delete from appadmin.ti_adm_visualize

CREATE    PROC [AppAdmin].[ti_adm_SyncPBI_ObjectOwner_sp]  
@ObjectList AppAdmin.ObjectList READONLY,
@newEditSyncReport int = 0 -- 0-Sync, 1-CreateReport, 2-EditReport
 AS  
 BEGIN  
 /******************************************************
** Version               : 1.0               
** Author                : Sunitha        
** Description           : To enter Power BI objects into ObjectOwner Table
** Date					 : 3-12-2019  
Modification History
19-12-2019  Sunitha		Added default Favourite column value to zero in objectowner table
13-Aug-2020	Srimathi	Modified to store Dataset information, Report-Dataset relationship and deactivate deleted objects
19-aug-2020	Srimathi	Added new parameter to indicate call made from createReport API
16-Sep-2020	Srimathi	Modified @newReport to @newEditSyncReport to handle EditReport Scenario - changed bit to int to support values 0,1,2.  Also, included object_GUID in the join conditions to uniquely identify a PowerBI object
24-Sep-2020	Srimathi	ti_adm_visualize insert to happen only in sync and createreport scenarios.  added if condition on @newEditSyncReport flag, and filter to check if row already exists
21-oct-2020 Sunitha     Added Transaction to the Stored Proc

*******************************************************/ 
BEGIN TRY  
  BEGIN TRANSACTION   
 DECLARE @ObjectID INT;  
 DECLARE @Predecessorid INT;  
 DECLARE @ErrMsg VARCHAR(1000);  
 DECLARE @ErrSeverity VARCHAR(100); 

 IF OBJECT_ID('TempDB..#ObjectList') IS NOT NULL  
 DROP TABLE #ObjectList  
 SELECT * INTO #ObjectList  
 FROM @ObjectList  
    
 --Insert new visualize records to ObjectOwner table  
INSERT INTO AppAdmin.ti_adm_ObjectOwner  
   (objectName  
   , ObjectType  
   , ObjectLocation  
   , CreatedDate  
   , LastUpdatedDate  
   , IsActive  
   , CreatedBy  
   , LastUpdatedBy  
   ,Favourite
   ,Object_GUID
   ,Workspace_GUID
   )  
SELECT t.objectName  
 , t.ObjectType  
 , t.ObjectLocation  
 , ISNULL(t.CreatedDate,getdate())  
 , ISNULL(t.LastupdatedDate,getdate())  
 , 1  
 , (SELECT UserID FROM AppAdmin.ti_adm_User_lu WHERE userEmail=t.UserEmail)  
 , (SELECT UserID FROM AppAdmin.ti_adm_User_lu WHERE userEmail=t.UserEmail)  
 ,0
 ,t.Object_GUID
 ,t.Workspace_GUID
FROM #ObjectList t  
LEFT JOIN appadmin.ti_adm_ObjectOwner o  
ON t.objectName=o.objectName   
 AND t.ObjectType=o.ObjectType   
 AND t.ObjectLocation=o.ObjectLocation   
 AND t.Object_GUID = o.Object_GUID
 AND o.IsActive=1  
 WHERE o.ObjectID is NULL  

 
--Insert new dataset records into ObjectOwner Table.  Does not handle multiple dataset names in parameter. 
--Will be taken up during dashboard entries

/*
INSERT INTO AppAdmin.ti_adm_ObjectOwner  
   (objectName  
   , ObjectType  
   , ObjectLocation  
   , CreatedDate  
   , LastUpdatedDate  
   , IsActive  
   , CreatedBy  
   , LastUpdatedBy  
   ,Favourite
   )  
SELECT t.ObjectName  
 , t.ObjectType
 , t.ObjectLocation  
 , ISNULL(t.CreatedDate,getdate())  
 , ISNULL(t.LastupdatedDate,getdate())  
 , 1  
 , (SELECT UserID FROM AppAdmin.ti_adm_User_lu WHERE userEmail=t.UserEmail)  
 , (SELECT UserID FROM AppAdmin.ti_adm_User_lu WHERE userEmail=t.UserEmail)  
 ,0
FROM #ObjectList t  
LEFT JOIN appadmin.ti_adm_ObjectOwner o  
ON t.ObjectName = o.objectName   
 AND t.ObjectType = o.ObjectType   
 AND t.ObjectLocation=t.ObjectLocation   
 AND o.IsActive=1  
 WHERE o.ObjectID is NULL    

 */

-- Insert dataset information if not sent as separate row - not inserted during editReport scenario

IF @newEditSyncReport <> 2
BEGIN
	INSERT INTO AppAdmin.ti_adm_ObjectOwner  
	(objectName  
	, ObjectType  
	, ObjectLocation  
	, CreatedDate  
	, LastUpdatedDate  
	, IsActive  
	, CreatedBy  
	, LastUpdatedBy  
	,Favourite
	,Object_GUID
	,Workspace_GUID
	)  
	SELECT t.DatasetName  
	 , 'Dataset'
	 , t.ObjectLocation  
	 , ISNULL(t.CreatedDate,getdate())  
	 , ISNULL(t.LastupdatedDate,getdate())  
	 , 1  
	 , (SELECT UserID FROM AppAdmin.ti_adm_User_lu WHERE userEmail=t.UserEmail)  
	 , (SELECT UserID FROM AppAdmin.ti_adm_User_lu WHERE userEmail=t.UserEmail)  
	 ,0
	 ,t.DatasetGUID
	 ,t.Workspace_GUID
		FROM #ObjectList t  
	LEFT JOIN appadmin.ti_adm_ObjectOwner o  
	ON t.DatasetName = o.objectName   
	AND t.DatasetGUID = o.Object_GUID
	AND t.ObjectLocation=o.ObjectLocation   
	AND t.Workspace_GUID = o.Workspace_GUID
	 AND o.IsActive=1  
	 AND o.ObjectType  = 'Dataset'
	 WHERE o.ObjectID is NULL    
	 AND t.ObjectType  = 'Dataset'
 END

--update date and user in case of Edit and Save from application @newEditSyncReport = 2

IF @newEditSyncReport = 2
BEGIN
UPDATE O
SET 
	LastUpdatedBy = u.userid,
	LastUpdatedDate = getdate()
FROM 
	#ObjectList t
	INNER JOIN AppAdmin.ti_adm_ObjectOwner O
	ON 
		t.objectName=o.objectName   
		AND t.ObjectType=o.ObjectType   
		AND t.ObjectLocation=o.ObjectLocation   
		AND t.Object_GUID = o.Object_GUID
		AND o.IsActive=1  
	INNER JOIN AppAdmin.ti_adm_User_lu u
	ON
		t.UserEmail = u.UserEmail
		AND u.IsActive = 1

END  --End of IF - Edit and Save - @newEditSyncReport = 2


/*

UPDATE o  
SET o.LastUpdatedDate =ISNULL(t.LastUpdatedDate,getdate())  ,o.LastUpdatedBy=(SELECT UserID   
       FROM AppAdmin.ti_adm_User_lu      WHERE userEmail=t.UserEmail)  
FROM #ObjectList t  
LEFT JOIN appadmin.ti_adm_ObjectOwner o  
ON t.objectName=o.objectName AND  
t.ObjectType=o.ObjectType AND   
t.ObjectLocation=t.ObjectLocation AND o.IsActive=1  
WHERE o.ObjectID IS NOT NULL   

--populate ti_Adm_visualize  
-- Will be taken up for Dashboard entries
WITH cte  
AS  
(  
SELECT o.ObjectID,o.ObjectName,o.ObjectType,o.ObjectLocation,  
value DatasetName  
FROM #ObjectList t 
 INNER JOIN appadmin.ti_adm_ObjectOwner o  
ON t.objectName=o.objectName   
 AND t.ObjectType=o.ObjectType   
 AND t.ObjectLocation=t.ObjectLocation   
 AND o.IsActive=1  
 CROSS APPLY string_split(DatasetName,',')
),  
CTE1  
AS  
(  
SELECT c1.objectID as ObjectID,c2.objectID as PredecessorID  
FROM cte c1    
INNER JOIN cte c2   
 ON c1.datasetName=c2.objectname  
where c2.objectID IS NOT NULL  
)  
--check for existence and insert   
INSERT INTO AppAdmin.ti_adm_visualize(ObjectID,PredecessorID)  
SELECT c.objectID,c.PredecessorID  
FROM Cte1 c  
LEFT JOIN AppAdmin.ti_adm_visualize v  
ON c.objectID=v.objectID   
 AND c.PredecessorID=v.PredecessorID  
WHERE v.objectID IS NULL  
*/   


-- Report - Dataset relationship in ti_adm_Visualize

--in case of edit report scenario, dataset information wont change for a report. hence, the below INSERT will happen only for sync and new report scenarios
IF @newEditSyncReport <> 2
BEGIN
	INSERT INTO APPADMIN.ti_adm_visualize

	SELECT r.objectid, d.objectid
	FROM 
		#ObjectList t  
		INNER JOIN appadmin.ti_adm_ObjectOwner r
		ON 
			t.ObjectName = r.objectName   
			AND t.Object_GUID = r.Object_GUID
			AND r.ObjectType = 'Report'
			AND r.ObjectLocation = t.ObjectLocation   
			AND r.IsActive = 1  
		INNER JOIN appadmin.ti_adm_ObjectOwner d
		ON
			t.DatasetName = d.objectName   
			AND t.datasetGUID = d.Object_GUID
			AND d.ObjectType = 'Dataset'
			AND d.ObjectLocation = t.ObjectLocation   
			AND d.IsActive = 1  
		LEFT JOIN AppAdmin.ti_adm_visualize v  
			ON r.objectID=v.objectID   
			AND d.objectID=v.PredecessorID  
	WHERE 
		t.ObjectType = 'Report'
		AND v.objectID IS NULL 
END

--Mark deleted objects as inactive
--19-Aug-2020 - condition added - below statements to be executed only for complete sync, not new report creation

IF @newEditSyncReport = 0
BEGIN
UPDATE appadmin.ti_adm_objectowner 
SET 
	isactive = 0,
	LastUpdatedDate = getdate()

WHERE objectid in 
(SELECT objectid 
	FROM 
		#ObjectList t  
		RIGHT JOIN appadmin.ti_adm_ObjectOwner o  
		ON t.objectName=o.objectName   
			AND t.ObjectType=o.ObjectType   
			AND t.ObjectLocation=t.ObjectLocation 
			AND t.Object_GUID = o.Object_GUID

			
	WHERE t.ObjectName is NULL  
	AND o.objecttype in ('Report','Dataset','Dashboard')
	AND o.IsActive=1  
)

--Deactivate access rows for deleted/inactive report objects
UPDATE appadmin.ti_adm_ObjectAccessGrant
SET 
	isactive = 0,
	LastUpdatedDate = getdate()

WHERE objectid in 
	(
		SELECT objectid 
		FROM appadmin.ti_adm_objectowner 
		WHERE 
			objecttype in ('Report','Dataset','Dashboard')
			AND isactive = 0
	)

-- Delete relationships for deactivated report objects

DELETE FROM appadmin.ti_adm_visualize
WHERE
OBJECTID IN
	(
		SELECT objectid 
		FROM appadmin.ti_adm_objectowner 
		WHERE 
			objecttype in ('Report','Dataset','Dashboard')
			AND isactive = 0
	)
OR
Predecessorid IN

	(
		SELECT objectid 
		FROM appadmin.ti_adm_objectowner 
		WHERE 
			objecttype in ('Report','Dataset','Dashboard')
			AND isactive = 0
	)

END ---end of IF - complete sync of PBI objects - @newEditSyncReport = 0
COMMIT TRANSACTION  
END TRY   
  BEGIN CATCH  
  IF @@trancount>0  
	ROLLBACK TRANSACTION  
  SET @ErrMsg = ISNULL(LEFT(RTRIM(ERROR_MESSAGE()),1000),'')               
  SET @ErrSeverity=ERROR_SEVERITY()  
  RAISERROR(@ErrMsg,@Errseverity,1)  
END CATCH 

END
/*
 Pre-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be executed before the build script.	
 Use SQLCMD syntax to include a file in the pre-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the pre-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

Create Table [AppAdmin].[ti_adm_ObjectOwner_Intermediate](ObjectID bigint identity(1,1) not null, ObjectName varchar(50), ObjectType varchar(50),
SchemaName varchar(50),CareatedDate datetime, CreatedBy int,UserEmail varchar(50),IsActive bit)
GO
IF ((SELECT count(*)
          FROM   INFORMATION_SCHEMA.COLUMNS
          WHERE  TABLE_NAME = 'ti_adm_ObjectOwner' AND Table_Schema ='AppAdmin'
                 AND COLUMN_NAME = 'FileDelimiterID') =0)
BEGIN
     Alter table [AppAdmin].[ti_adm_ObjectOwner] add FileDelimiterID int null;
	 
END 
UPDATE [AppAdmin].[ti_adm_ObjectOwner] set FileDelimiterID =1 where ObjectType ='File';
Go

if (Select Count(*) from [AppAdmin].[ti_adm_User_lu] where UserEmail ='TesserPlatformSignIn@tesserinsights.com')=0
Begin
Insert into [AppAdmin].[ti_adm_User_lu](FirstName, LastName,UserEmail,Department,RoleId,SupervisorID,SubscriptionID,Field1,CreatedBy,CreatedDate,UpdatedBy,UpdatedDate,IsActive,TAI_Enabled)
Values('Tesser','Application','TesserPlatformSignIn@tesserinsights.com','APP',4,1,1,'',0,getdate(),0,getdate(),1,1)
End

Go


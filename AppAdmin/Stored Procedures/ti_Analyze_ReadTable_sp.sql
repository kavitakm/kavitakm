 --exec appadmin.ti_Analyze_ReadTable_sp 'Sandbox','EduTN','Area_Name','Ambattur (M)','Total_Population_Females',null,'','','1500','2500' 
CREATE PROCEDURE [AppAdmin].[ti_Analyze_ReadTable_sp]          
@SchemaName varchar(100),            
@TableName varchar(100),            
@Column1Name varchar(200),          
@Column1Value varchar(max),          
@Column2Name varchar(200),          
@column2Value varchar(max),  
@Column1minvalue varchar(max),  
@column1maxvalue varchar(max),  
@Column2minvalue varchar(max),  
@column2maxvalue varchar(max)         
--@Column3Name varchar(200),          
--@Column4Name varchar(200),          
          
AS          
BEGIN  
/**************************************************************************     
**          
** Version Control Information          
** ---------------------------          
**          
** Version                : 1.0                 
** Author                 : Srimathi              
** Description            :             
** Date       :          
 ** Modification Hist:                 
**                      
** Date          Name     Modification                        
18/2/2020     Sunitha  update sp to pass outlier range values  
05/11/2020  Srimathi handled column names with spaces  
  
*******************************************************************************/  
DECLARE @col1_dt VARCHAR(50);          
DECLARE @col2_dt VARCHAR(50);    
Declare @SQLWhere VarChar(500);          
DECLARE @str NVARCHAR(MAX);       
DECLARE @num_prec1 int;    
DECLARE @num_scale1 INT;    
DECLARE @num_prec2 int;    
DECLARE @num_scale2 INT;    
 SELECT @col1_DT = DATA_TYPE, @num_prec1 = NUMERIC_PRECISION, @num_scale1 = numeric_scale FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @SchemaName AND TABLE_NAME = @TableName AND COLUMN_NAME = replace(replace(@Column1Name,'[',''),']','');         
 
 SELECT @col2_DT = DATA_TYPE, @num_prec2 = NUMERIC_PRECISION, @num_scale2 = numeric_scale FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @SchemaName AND TABLE_NAME = @TableName AND COLUMN_NAME = replace(replace(@Column2Name,'[',''),']','');         
 
   
 IF @Column1Name != ''  
 SET @Column1Name = QUOTENAME(replace(replace(@Column1Name,'[',''),']',''));            
 IF @Column2Name != ''  
 SET @Column2Name = QUOTENAME(replace(replace(@Column2Name,'[',''),']',''));            
   
 Set @SQLWhere ='';    
 SET @str ='';     
  
 IF (@Column1Name !='') 
 Begin
	IF (Len(@SQLWhere) >0 )    
		SET @SQLWhere = @SQLWhere + ' AND ';    
     
	SET @SQLWhere = @SQLWhere +  @column1name;   
	IF ISNULL(@Column1Value,'') =''  and @Column1minvalue='' AND @Column1maxvalue=''
		SET @str = ' IS NULL ';
	Else IF ISNULL(@Column1Value,'') <>''  and @Column1minvalue='' AND @Column1maxvalue=''
	begin
		if @col1_dt in ('decimal','numeric')    
			SET @str = ' = CONVERT(' + @col1_dt + '(' + str(@num_prec1) + ',' + str(@num_scale1) + '), ''' + @Column1Value + ''') ' ;    
		else    
			SET @str = ' = CONVERT(' + @col1_dt + ', ''' + @Column1Value + ''') ' ; 
	end
	Else IF ISNULL(@Column1Value,'') =''  and @Column1minvalue<>'' AND @Column1maxvalue<>''
	begin
		if @col1_dt in ('decimal','numeric')     
			SET @str = ' BETWEEN CONVERT(' + @col1_dt + '(' + str(@num_prec1) + ',' + str(@num_scale1) + '), ''' + @Column1minvalue + ''') and CONVERT(' + @col1_dt + '(' + str(@num_prec1) + ',' + str(@num_scale1) + '), ''' + @column1maxvalue + ''')  '   
		ELSE    
			SET @str = ' BETWEEN  CONVERT(' + @col1_dt + ', ''' + @Column1minvalue + ''') and CONVERT(' + @col1_dt + ', ''' + @Column1maxvalue + ''')'  ;       
	end
	Set @SQLWhere = @SQLWhere + @str ; 
 End 
 
 IF (@Column2Name !='') 
 Begin
	IF (Len(@SQLWhere) >0 )    
		SET @SQLWhere = @SQLWhere + ' AND ';    
     
	SET @SQLWhere = @SQLWhere +  @column2name;   
	IF ISNULL(@Column2Value,'') =''  and @Column2minvalue='' AND @Column2maxvalue=''
		SET @str = ' IS NULL ';
	Else IF ISNULL(@Column2Value,'') <>''  and @Column2minvalue='' AND @Column2maxvalue=''
	begin
		if @col2_dt in ('decimal','numeric')    
			SET @str = ' = CONVERT(' + @col2_dt + '(' + str(@num_prec2) + ',' + str(@num_scale2) + '), ''' + @Column2Value + ''') ' ;    
		else    
			SET @str = ' = CONVERT(' + @col2_dt + ', ''' + @Column2Value + ''') ' ; 
	end
	Else IF ISNULL(@Column2Value,'') =''  and @Column2minvalue<>'' AND @Column2maxvalue<>''
	begin
		if @col2_dt in ('decimal','numeric')     
			SET @str = ' BETWEEN CONVERT(' + @col2_dt + '(' + str(@num_prec2) + ',' + str(@num_scale2) + '), ''' + @Column2minvalue + ''') and CONVERT(' + @col2_dt + '(' + str(@num_prec2) + ',' + str(@num_scale2) + '), ''' + @column2maxvalue + ''')  '   
		ELSE    
			SET @str = ' BETWEEN  CONVERT(' + @col2_dt + ', ''' + @Column2minvalue + ''') and CONVERT(' + @col2_dt + ', ''' + @Column2maxvalue + ''')'  ;       
	end
	Set @SQLWhere = @SQLWhere + @str ; 
 End 
        
 SET @str = 'SELECT * FROM ' + @SchemaName + '.' + @TableName ;      
 if (Len(@SQLWhere) >0 )    
  SET @str = @str + ' WHERE ' + @SQLWhere ;    
  PRINT @STR  
 EXECUTE sp_executesql @str;          
END   
GO



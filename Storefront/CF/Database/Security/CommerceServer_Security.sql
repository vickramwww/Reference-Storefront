IF OBJECT_ID('tempdb..#CSSecurity') IS NOT NULL
BEGIN
	DROP TABLE #CSSecurity
END

SET NOCOUNT ON

CREATE TABLE #CSSecurity (
	UserName varchar(100)
)

/* MSCS Catalog Scratch Database */
INSERT INTO #CSSecurity VALUES ('$(CS_USER_CATALOG)')
INSERT INTO #CSSecurity VALUES ('$(CS_USER_ORDERS)')
INSERT INTO #CSSecurity VALUES ('$(CS_USER_FOUNDATION)')
INSERT INTO #CSSecurity VALUES ('$(CS_USER_MARKETING)')
INSERT INTO #CSSecurity VALUES ('$(CS_USER_PROFILES)')

GO

DECLARE @userName VARCHAR(100)

DECLARE db_cursor CURSOR FOR  
SELECT UserName
FROM #CSSecurity

OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @userName

WHILE @@FETCH_STATUS = 0   
BEGIN   
	USE [master]
	
	/* If the user does not exist as a login, add it to the system security */	
	IF NOT EXISTS(SELECT name FROM master.dbo.syslogins WHERE name = @userName)
	BEGIN
		PRINT 'Creating login ' + @userName
		EXEC( 'CREATE LOGIN [' + @userName + '] FROM WINDOWS' )
	END
	
	FETCH NEXT FROM db_cursor INTO @userName
END

CLOSE db_cursor   
DEALLOCATE db_cursor

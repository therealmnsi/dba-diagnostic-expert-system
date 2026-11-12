USE DBADiag;
GO

CREATE OR ALTER PROCEDURE usp_check_backup_path
    @path NVARCHAR(260),
    @passed BIT OUTPUT,
    @evidence NVARCHAR(500) OUTPUT
AS
BEGIN
    CREATE TABLE #f (
        file_exists INT,
        is_directory INT,
        parent_exists INT
    );

    INSERT INTO #f EXEC master.dbo.xp_fileexist @path;

    DECLARE @isdir INT;
    SELECT @isdir = is_directory FROM #f;

    IF @isdir = 1
        SET @passed = 1;
    ELSE
        SET @passed = 0;

    SET @evidence = 'Folder ' + @path + ' exists: ' +
        CASE WHEN @isdir = 1 THEN 'yes' ELSE 'no' END;
END
GO
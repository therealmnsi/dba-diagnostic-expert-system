USE DBADiag;
GO

CREATE OR ALTER PROCEDURE usp_check_disk_space
    @drive CHAR(1),
    @min_mb INT,
    @passed BIT OUTPUT,
    @evidence NVARCHAR(500) OUTPUT
AS
BEGIN
    CREATE TABLE #d (
        drive CHAR(1),
        free_mb INT
    );

    INSERT INTO #d EXEC master.dbo.xp_fixeddrives;

    DECLARE @free INT;
    SELECT @free = free_mb FROM #d WHERE drive = @drive;

    IF @free IS NULL
    BEGIN
        SET @passed = 0;
        SET @evidence = 'Drive ' + @drive + ': not found';
    END
    ELSE
    BEGIN
        IF @free >= @min_mb
            SET @passed = 1;
        ELSE
            SET @passed = 0;

        SET @evidence = @drive + ': has ' + CAST(@free AS NVARCHAR(20)) +
            ' MB free (minimum ' + CAST(@min_mb AS NVARCHAR(20)) + ')';
    END
END
GO
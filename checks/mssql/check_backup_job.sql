USE DBADiag;
GO

CREATE OR ALTER PROCEDURE usp_check_backup_job
    @job_name NVARCHAR(128),
    @passed BIT OUTPUT,
    @evidence NVARCHAR(500) OUTPUT
AS
BEGIN
    DECLARE @job_id UNIQUEIDENTIFIER;
    DECLARE @enabled TINYINT;
    DECLARE @status INT;
    DECLARE @msg NVARCHAR(500);

    SELECT @job_id = job_id, @enabled = enabled
    FROM msdb.dbo.sysjobs
    WHERE name = @job_name;

    IF @job_id IS NULL
    BEGIN
        SET @passed = 0;
        SET @evidence = 'Job ' + @job_name + ' not found';
        RETURN;
    END

    IF @enabled = 0
    BEGIN
        SET @passed = 0;
        SET @evidence = 'Job ' + @job_name + ' is disabled';
        RETURN;
    END

    SELECT TOP 1 @status = run_status, @msg = message
    FROM msdb.dbo.sysjobhistory
    WHERE job_id = @job_id AND step_id = 0
    ORDER BY instance_id DESC;

    IF @status IS NULL
    BEGIN
        SET @passed = 0;
        SET @evidence = 'Job ' + @job_name + ' has never run';
    END
    ELSE IF @status = 1
    BEGIN
        SET @passed = 1;
        SET @evidence = 'Job ' + @job_name + ' last run succeeded';
    END
    ELSE
    BEGIN
        SET @passed = 0;
        SET @evidence = 'Job ' + @job_name + ' last run failed: ' + @msg;
    END
END
GO
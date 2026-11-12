USE DBADiag;
GO

CREATE OR ALTER PROCEDURE usp_diagnose
    @problem  NVARCHAR(100),
    @platform NVARCHAR(20) = 'SQL Server'
AS
BEGIN
    SET NOCOUNT ON;

    -- Settings used by the checks (change if your values differ)
    DECLARE @backup_path NVARCHAR(260) = N'E:\dba-test\backups';
    DECLARE @drive       CHAR(1)       = 'E';
    DECLARE @min_mb      INT           = 500;
    DECLARE @job_name    NVARCHAR(128) = N'TestBackup';

    -- 1) find the problem and make a new run number
    DECLARE @problem_id INT;
    SELECT @problem_id = problem_id FROM problem WHERE name = @problem;
    IF @problem_id IS NULL
    BEGIN
        SELECT 'Unknown problem' AS message;
        RETURN;
    END

    DECLARE @run_id INT;
    SELECT @run_id = ISNULL(MAX(run_id), 0) + 1 FROM check_result;

    -- 2) loop over the checks of this problem, in step order
    DECLARE @check_id INT, @proc NVARCHAR(100);
    DECLARE @passed BIT, @evidence NVARCHAR(500);

    DECLARE c CURSOR FOR
        SELECT check_id, proc_name FROM check_def
        WHERE problem_id = @problem_id ORDER BY step_no;
    OPEN c;
    FETCH NEXT FROM c INTO @check_id, @proc;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @passed = NULL;
        SET @evidence = NULL;

        -- 3) run the check
        IF @proc = 'usp_check_service'
            EXEC usp_check_service @passed OUTPUT, @evidence OUTPUT;
        ELSE IF @proc = 'usp_check_backup_path'
            EXEC usp_check_backup_path @backup_path, @passed OUTPUT, @evidence OUTPUT;
        ELSE IF @proc = 'usp_check_disk_space'
            EXEC usp_check_disk_space @drive, @min_mb, @passed OUTPUT, @evidence OUTPUT;
        ELSE IF @proc = 'usp_check_backup_job'
            EXEC usp_check_backup_job @job_name, @passed OUTPUT, @evidence OUTPUT;

        -- checks 4 and 5 share one procedure: split its answer
        IF @proc = 'usp_check_backup_job' AND @passed = 0
        BEGIN
            IF @check_id = 4 AND @evidence LIKE '%last run failed%' SET @passed = 1;
            IF @check_id = 5 AND @evidence NOT LIKE '%last run failed%' SET @passed = 1;
        END

        -- save the result
        INSERT INTO check_result (run_id, check_id, passed, evidence, run_time)
        VALUES (@run_id, @check_id, @passed, @evidence, SYSDATETIME());

        FETCH NEXT FROM c INTO @check_id, @proc;
    END
    CLOSE c;
    DEALLOCATE c;

    -- 4) add the weights of the FAILED checks per cause
    SELECT d.cause_if_fail AS cause,
           SUM(d.weight)   AS score,
           MAX(r.evidence) AS evidence
    INTO #ranked
    FROM check_result r
    JOIN check_def d ON d.check_id = r.check_id
    WHERE r.run_id = @run_id AND r.passed = 0
    GROUP BY d.cause_if_fail;

    -- 5) save the top cause as an OPEN diagnosis
    DECLARE @top_cause NVARCHAR(200), @top_score INT, @top_evidence NVARCHAR(500);
    SELECT TOP 1 @top_cause = cause, @top_score = score, @top_evidence = evidence
    FROM #ranked ORDER BY score DESC;

    IF @top_cause IS NOT NULL
        INSERT INTO diagnosis (platform, problem, top_cause, score, status, opened_at, evidence)
        VALUES (@platform, @problem, @top_cause, @top_score, 'OPEN', SYSDATETIME(), @top_evidence);

    -- Step 3.4: ranked list and one line of text for alerts
    SELECT cause, score, evidence FROM #ranked ORDER BY score DESC;

    SELECT CASE
        WHEN @top_cause IS NULL
            THEN @problem + ' on ' + @platform + ': no problem found (all checks passed).'
        ELSE @problem + ' on ' + @platform + '. Likely cause: ' + @top_cause +
             ' (score ' + CAST(@top_score AS NVARCHAR(10)) + ').'
    END AS alert_text;
END
GO
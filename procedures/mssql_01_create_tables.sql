CREATE DATABASE DBADiag;
GO
USE DBADiag;
GO

CREATE TABLE problem (
    problem_id INT PRIMARY KEY,
    name NVARCHAR(100)
);
GO

INSERT INTO problem VALUES (1, 'Backup Failure');
INSERT INTO problem VALUES (2, 'Cannot Connect');
GO

SELECT * FROM problem;

CREATE TABLE check_def (
    check_id INT PRIMARY KEY,
    problem_id INT,
    step_no INT,
    name NVARCHAR(100),
    cause_if_fail NVARCHAR(200),
    weight INT,
    proc_name NVARCHAR(100)
);
GO

CREATE TABLE check_result (
    result_id INT IDENTITY(1,1) PRIMARY KEY,
    run_id INT,
    check_id INT,
    passed BIT,
    evidence NVARCHAR(500),
    run_time DATETIME2
);
GO

CREATE TABLE diagnosis (
    diag_id INT IDENTITY(1,1) PRIMARY KEY,
    platform NVARCHAR(20),
    problem NVARCHAR(100),
    top_cause NVARCHAR(200),
    score INT,
    status NVARCHAR(10),
    opened_at DATETIME2,
    resolved_at DATETIME2 NULL,
    evidence NVARCHAR(MAX)
);
GO


CREATE TABLE current_status (
    platform NVARCHAR(20),
    problem NVARCHAR(100),
    state NVARCHAR(10),
    top_cause NVARCHAR(200),
    last_checked DATETIME2
);
GO

INSERT INTO current_status (platform, problem, state) VALUES ('SQL Server', 'Backup Failure', 'OK');
INSERT INTO current_status (platform, problem, state) VALUES ('SQL Server', 'Cannot Connect', 'OK');
GO

SELECT * FROM current_status;


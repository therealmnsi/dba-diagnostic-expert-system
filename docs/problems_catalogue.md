# Problem Catalogue

## Problem 1: Backup Failure
A scheduled database backup did not complete. Questions are asked cheapest check first.

1. Is the database service running?
   How to check: Services app, SQL Server (MSSQLSERVER) and SQL Server Agent show Running.
   If this fails, the cause is: the service or the Agent is stopped.

2. Does the backup folder exist and is it reachable?
   How to check: open the folder path in File Explorer and confirm the account can write to it.
   If this fails, the cause is: the backup path is missing or there is no permission.

3. Is there enough free disk space on the backup drive?
   How to check: look at the drive's free space, or run EXEC xp_fixeddrives.
   If this fails, the cause is: the backup disk is full.

4. Did the scheduled backup job start?
   How to check: SSMS > SQL Server Agent > Jobs. Is the job enabled, and what is its Last Run?
   If this fails, the cause is: the job is disabled or not scheduled.

5. If it ran, did it fail, and what error did it give?
   How to check: right-click the job > View History and read the error text.
   If this fails, the cause is: the error shown in the job history (copy the message).

6. Is the database online and is the log not full?
   How to check: SELECT name, state_desc FROM sys.databases; and check the log space.
   If this fails, the cause is: the database is offline, or the transaction log is full.



   ## Problem 2: Cannot Connect
A user or application cannot connect to the database. Questions are asked cheapest check first.

1. Is the database service running?
   How to check: Services app, SQL Server (MSSQLSERVER) shows Running.
   If this fails, the cause is: the service is stopped.

2. Is the port open and listening?
   How to check: run Test-NetConnection localhost -Port 1433 in PowerShell (use 5432 for PostgreSQL).
   If this fails, the cause is: the port is closed, blocked, or the instance listens on a different port.

3. Has the maximum number of connections been reached?
   How to check: SELECT COUNT(*) FROM sys.dm_exec_sessions; and compare it with the connection limit.
   If this fails, the cause is: too many connections.

4. Are there recent "login failed" entries in the log, and what reason do they give?
   How to check: SSMS > Management > SQL Server Logs, or EXEC xp_readerrorlog; and look for "Login failed".
   If this fails, the cause is: the reason given in the log entry (wrong password, disabled login, and so on).

5. Is the login disabled, locked or expired?
   How to check: SELECT name, is_disabled FROM sys.server_principals; and check LOGINPROPERTY for locked or expired.
   If this fails, the cause is: the login is disabled, locked out, or its password has expired.

6. Is the target database online?
   How to check: SELECT name, state_desc FROM sys.databases;
   If this fails, the cause is: the database is offline or restoring.
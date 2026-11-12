CREATE DATABASE TestDB;
GO

USE msdb;
GO

EXEC sp_add_job @job_name = 'TestBackup';

EXEC sp_add_jobstep
    @job_name = 'TestBackup',
    @step_name = 'Backup TestDB',
    @subsystem = 'TSQL',
    @database_name = 'master',
    @command = 'BACKUP DATABASE TestDB TO DISK = ''E:\project\backups\TestDB.bak'' WITH INIT;';

EXEC sp_add_jobserver @job_name = 'TestBackup';
GO
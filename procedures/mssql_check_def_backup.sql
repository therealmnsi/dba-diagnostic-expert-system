USE DBADiag;
GO

DELETE FROM check_def WHERE problem_id = 1;
GO

INSERT INTO check_def (check_id, problem_id, step_no, name, cause_if_fail, weight, proc_name) VALUES
(1, 1, 1, 'Service running',        'Database service is not running',           100, 'usp_check_service'),
(2, 1, 2, 'Backup folder exists',   'Backup folder is missing or not reachable',  90, 'usp_check_backup_path'),
(3, 1, 3, 'Free disk space',        'Backup disk is almost full',                 85, 'usp_check_disk_space'),
(4, 1, 4, 'Backup job enabled',     'Backup job is disabled or has not run',      70, 'usp_check_backup_job'),
(5, 1, 5, 'Backup job succeeded',   'Backup job ran and failed',                  60, 'usp_check_backup_job');
GO

SELECT * FROM check_def;
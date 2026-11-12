USE DBADiag;
GO

CREATE PROCEDURE usp_check_service
    @passed BIT OUTPUT,
    @evidence NVARCHAR(500) OUTPUT
AS
BEGIN
    DECLARE @state NVARCHAR(50);

    SELECT @state = status_desc
    FROM sys.dm_server_services
    WHERE servicename LIKE 'SQL Server (%';

    IF @state = 'Running'
        SET @passed = 1;
    ELSE
        SET @passed = 0;

    SET @evidence = 'Service state: ' + ISNULL(@state, 'Not found');
END
GO
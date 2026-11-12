# DBA Diagnostic Expert System

A read-only, rule-based SQL tool that runs a DBA's troubleshooting checks automatically and returns ranked likely root causes with evidence, with Teams and email alerts. Covers SQL Server and PostgreSQL.

Folder map:
- checks/mssql, checks/postgres : one file per check
- procedures : table scripts, diagnose and watch procedures (mssql_* and pg_*)
- scripts/batch : Windows .bat scripts (watcher, Teams, email)
- docs : checklists, test log, results, report
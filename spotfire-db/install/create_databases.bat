@echo off
setlocal

rem ---------------------------------------------------------------------------
rem
rem This script will create all database schemas and fill them with all the initial data.
rem
rem Before using this script you need to set or change the following variables below:
rem         * SERVER
rem         * MSSQL_INSTANCENAME
rem         * ADMINPASSWORD
rem         * SERVERDB_USER
rem         * SERVERDB_PASSWORD
rem
rem     replace <SERVER> with the name of the server running the SQL Server instance.
rem     replace <MSSQL_INSTANCENAME> with the name of the SQL Server instance.
rem
rem     if running the script against a SQL Server instance with a case sensitive server 
rem     collation, explicitly set a (case insensitive) collation to be used by the 
rem     database in the create_server_db.sql file.
rem
rem ---------------------------------------------------------------------------

rem Set these variable to reflect the local environment:
rem ### Reading from Docker environment.
rem set ADMINNAME=sa
rem set ADMINPASSWORD=saPassword123
rem set SERVERDB_NAME=spotfire_server
rem set SERVERDB_USER=spotfire_server
rem set SERVERDB_PASSWORD=SpotfireServer123

rem Demo data parameters
set INSTALL_DEMODATA=no
set DEMODB_NAME=spotfire_demodata
set DEMODB_USER=spotfire_demodata
set DEMODB_PASSWORD=spotfire_demodata

rem Create the server tables
@echo Creating Spotfire Server tables
sqlcmd -S%COMPUTERNAME% -U%ADMINNAME% -P%ADMINPASSWORD% -i create_server_db.sql -v SERVERDB_NAME="%SERVERDB_NAME%" > log.txt
if %errorlevel% neq 0 (
  @echo Error while running SQL script 'create_server_db.sql'
  @echo For more information consult the log.txt file
  exit /B 1
)

rem Fill server tables with data
@echo Populating Spotfire Server tables
sqlcmd -S%COMPUTERNAME% -U%ADMINNAME% -P%ADMINPASSWORD% -i populate_server_db.sql -v SERVERDB_NAME="%SERVERDB_NAME%" >> log.txt
if %errorlevel% neq 0 (
  @echo Error while running SQL script 'populate_server_db.sql'
  @echo For more information consult the log.txt file
  exit /B 1
)

rem Create the Spotfire Server database user
@echo Creating Spotfire Server database user
sqlcmd -S%COMPUTERNAME% -U%ADMINNAME% -P%ADMINPASSWORD% -i create_server_user.sql -v SERVERDB_NAME="%SERVERDB_NAME%" SERVERDB_USER="%SERVERDB_USER%" SERVERDB_PASSWORD="%SERVERDB_PASSWORD%" >> log.txt 
if %errorlevel% neq 0 (
  @echo Error while running SQL script 'create_server_user.sql'
  @echo For more information consult the log.txt file
  exit /B 1
)

rem Check if demo data should be installed
if not "%INSTALL_DEMODATA%"=="yes" goto noDemoData

rem Create the demo data tables
set NLS_LANG=SWEDISH
@echo Creating Spotfire Server demo data tables
sqlcmd -S%COMPUTERNAME% -U%ADMINNAME% -P%ADMINPASSWORD% -i create_demotables.sql -v DEMODB_NAME="%DEMODB_NAME%" >> log.txt
if %errorlevel% neq 0 (
  @echo Error while running SQL script 'create_demotables.sql'
  @echo For more information consult the log.txt file
  exit /B 1
)

rem Create demo data user
@echo Creating Spotfire Server demo data database user
sqlcmd -S%COMPUTERNAME% -U%ADMINNAME% -P%ADMINPASSWORD% -i create_demo_user.sql -v DEMODB_NAME="%DEMODB_NAME%" DEMODB_USER="%DEMODB_USER%" DEMODB_PASSWORD="%DEMODB_PASSWORD%" >> log.txt
if %errorlevel% neq 0 (
  @echo   - Error while running SQL script 'create_demo_user.sql'
  exit /B 1
)

@echo Populating Spotfire Server demo data tables
for /f %%v IN ('dir /b demodata\*.bcp') do call :populate %%v
goto exit

:populate
bcp %DEMODB_NAME%.dbo.%~n1 in demodata\%1 -S%COMPUTERNAME% -U%ADMINNAME% -P%ADMINPASSWORD% -n -e %~n1_invalid_rows.log >> log.txt
if %errorlevel% neq 0 (
  @echo   Warning: Failed to load demo data file %1
) 
goto:eof

goto exit

:noDemoData
@echo Spotfire Server demo database user and data will not be created

:exit

@echo -----------------------------------------------------------------
@echo Please review the log file (log.txt) for any errors or warnings!
endlocal



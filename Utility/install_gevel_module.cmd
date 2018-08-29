CALL config.cmd

@ECHO OFF
SET PROJ_PATH=%SOLUTION_PATH%\
SET EXT_DIR=%POSTGRESQL_PATH%\share\extension\
SET LIB_DIR=%POSTGRESQL_PATH%\lib\

xcopy "%PROJ_PATH%gevel_ext.sql" "%EXT_DIR%gevel_ext--1.0.*" /s /y /i
xcopy "%PROJ_PATH%gevel_ext.control" "%EXT_DIR%" /s /y /i

IF "%POSTGRESQL_ARCH%"=="x64" (
	SET ARCH_DIR=x64
) ELSE (
	SET ARCH_DIR=Win32
)
xcopy "%PROJ_PATH%\Release\%ARCH_DIR%\gevel_ext.dll" "%LIB_DIR%" /s /y /i
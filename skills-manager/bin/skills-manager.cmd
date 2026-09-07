@echo off
setlocal
set "PYTHON=python"
where py >nul 2>nul && set "PYTHON=py -3"
%PYTHON% "%~dp0skills-manager" %*
exit /b %ERRORLEVEL%

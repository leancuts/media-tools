@echo off
setlocal
set SCRIPT_DIR=%~dp0
perl "%SCRIPT_DIR%exiftool-dir\exiftool" %*
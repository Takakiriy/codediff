@echo off
setlocal
set this_folder=%~dp0
"C:\Program Files\Git\bin\bash" "%this_folder:\=/%codediff" %*
endlocal

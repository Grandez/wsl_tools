if "%~1" neq "" (call :%~1 %*&exit /b)
echo No argument passed.
exit /b

:hello
echo Hello World! %*
exit /b

:test
echo This is a test. %*
exit /b

@echo off
REM Guarda o diretório atual
set "ORIG_DIR=%cd%"
cd /d "%~dp0"


REM ----------------------------------------
REM Simulação Verilog do contador 0x00 a 0xFF
REM Usando Icarus Verilog no Windows
REM ----------------------------------------

REM Caminho para os arquivos Verilog
set CONTADOR=counter.v
set TB=tb.v

REM Nome do arquivo compilado
set OUT=sim_contador.exe

REM Compilar os arquivos Verilog
iverilog -o %OUT% %CONTADOR% %TB%
IF ERRORLEVEL 1 (
    echo Erro na compilacao!
    pause
    exit /b 1
)

REM Rodar a simulação
C:\iverilog\bin\vvp.exe %OUT%
IF ERRORLEVEL 1 (
    echo Erro na simulacao!
    pause
    exit /b 1
)

echo Simulacao finalizada!
pause
cd /d "%ORIG_DIR%"
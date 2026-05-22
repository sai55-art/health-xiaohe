@echo off
REM ========================================================
REM   xiaohe-web dev launcher (Windows)
REM
REM   Starts:
REM     1) backend uvicorn on :8002  (new window, --reload)
REM     2) xiaohe-web vite  on :5180 (new window, opens chrome)
REM
REM   Close the two popup windows to stop the services.
REM
REM   Note: this script is plain ASCII on purpose. cmd parses the whole
REM   file using its startup codepage (usually GBK on zh-CN Windows); any
REM   non-ASCII chars in REM lines or echo strings get mangled into
REM   "command not recognized" errors before chcp 65001 takes effect.
REM ========================================================

setlocal enabledelayedexpansion
chcp 65001 > nul
title xiaohe-web launcher

echo.
echo  =========================================
echo   xiaohe-web  -  dev launcher
echo  =========================================
echo.

set "ROOT=%~dp0"
set "BACKEND_DIR=%ROOT%backend"
set "WEB_DIR=%ROOT%xiaohe-web"

REM ---- 1. environment checks --------------------------
echo [1/4] checking environment...

where python >nul 2>nul
if errorlevel 1 (
    echo   [x] python not found ^(need Python ^>= 3.10 on PATH^)
    pause
    exit /b 1
)
echo   [ok] python ready

where npm >nul 2>nul
if errorlevel 1 (
    echo   [x] npm not found ^(need Node.js ^>= 20 on PATH^)
    pause
    exit /b 1
)
echo   [ok] npm ready

if not exist "%BACKEND_DIR%\.env" (
    echo.
    echo   [x] backend\.env missing
    echo       cd backend ^&^& copy .env.example .env
    echo       then fill in DASHSCOPE_API_KEY etc.
    pause
    exit /b 1
)
echo   [ok] backend\.env exists

if not exist "%WEB_DIR%\node_modules" (
    echo.
    echo   xiaohe-web\node_modules missing, running npm install...
    pushd "%WEB_DIR%"
    call npm install
    if errorlevel 1 (
        echo   [x] npm install failed
        popd
        pause
        exit /b 1
    )
    popd
    echo   [ok] deps installed
) else (
    echo   [ok] xiaohe-web deps ready
)

REM ---- 2. port checks ---------------------------------
echo.
echo [2/4] checking ports...
call :CHECK_PORT 8002 backend
call :CHECK_PORT 5180 vite

REM ---- 3. start backend -------------------------------
echo.
echo [3/4] starting backend (uvicorn :8002, --reload)...
REM pushd lets the new "start" window inherit cwd, avoiding cmd /k nested-quote pitfalls
pushd "%BACKEND_DIR%"
start "xiaohe backend (uvicorn :8002)" cmd /k "chcp 65001 > nul && python -m uvicorn main:app --reload --host 0.0.0.0 --port 8002"
popd

echo    waiting for /health to respond...
set "READY=0"
for /l %%i in (1,1,30) do (
    if !READY!==0 (
        timeout /t 1 /nobreak > nul
        curl -s -o nul -w "%%{http_code}" http://localhost:8002/health 2>nul | findstr "200" > nul
        if !errorlevel!==0 (
            set "READY=1"
            echo    [ok] backend up
        )
    )
)
if !READY!==0 (
    echo    [!] backend did not respond within 30s ^(see the backend window for errors^)
)

REM ---- 4. start vite ----------------------------------
echo.
echo [4/4] starting vite (xiaohe-web :5180)...
pushd "%WEB_DIR%"
start "xiaohe-web (vite :5180)" cmd /k "chcp 65001 > nul && npm run dev"
popd

REM ---- done -------------------------------------------
echo.
echo  =========================================
echo   started
echo  =========================================
echo.
echo    backend API:   http://localhost:8002
echo    health:        http://localhost:8002/health
echo    API docs:      http://localhost:8002/docs
echo    web frontend:  http://localhost:5180   ^(chrome opens automatically^)
echo.
echo    stop services: just close the two popup windows
echo.
echo    you can close THIS window now; the services keep running.
pause
endlocal
exit /b 0

REM ============================================================
REM helper: CHECK_PORT <port> <label>
REM warns if the port is already bound; does NOT block startup
REM ============================================================
:CHECK_PORT
netstat -ano | findstr ":%~1 " | findstr "LISTENING" > nul
if !errorlevel!==0 (
    echo   [!] port %~1 already in use ^(%~2 may already be running^)
) else (
    echo   [ok] port %~1 free
)
goto :eof

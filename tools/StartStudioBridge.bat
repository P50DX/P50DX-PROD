@echo off
title Roblox Studio bridge for Claude
REM Lets a Claude cloud session use Roblox Studio through your claude.ai custom connector.
REM Keep Roblox Studio open (with your place loaded) and keep BOTH windows open while Claude works.
REM Close both windows when you are done: anyone with the tunnel link can control Studio while they run.

where npx >nul 2>nul || (echo Node.js not found. Install it from https://nodejs.org and run this again. & pause & exit /b 1)
set "CF=cloudflared"
where cloudflared >nul 2>nul || set "CF="
if not defined CF if exist "%ProgramFiles(x86)%\cloudflared\cloudflared.exe" set "CF=%ProgramFiles(x86)%\cloudflared\cloudflared.exe"
if not defined CF if exist "%ProgramFiles%\cloudflared\cloudflared.exe" set "CF=%ProgramFiles%\cloudflared\cloudflared.exe"
if not defined CF (echo cloudflared not found. Install it: winget install --id Cloudflare.cloudflared & pause & exit /b 1)
if not exist "%LOCALAPPDATA%\Roblox\mcp.bat" (echo Roblox Studio MCP not found at %LOCALAPPDATA%\Roblox\mcp.bat & pause & exit /b 1)

REM Window 2: the tunnel. Its window shows a link like https://something.trycloudflare.com
start "Tunnel - copy the trycloudflare.com link" cmd /k ""%CF%" tunnel --url http://localhost:8000"

REM This window: the bridge. Runs the Studio MCP and serves it on http://localhost:8000/sse
cd /d "%LOCALAPPDATA%\Roblox"
echo.
echo  Bridge starting on port 8000.
echo  In the OTHER window, find the https://....trycloudflare.com link.
echo  Add it at https://claude.ai/customize/connectors (Add custom connector) as:
echo      https://YOUR-LINK.trycloudflare.com/sse
echo  then start a NEW Claude session.
echo.
npx -y supergateway --stdio "mcp.bat" --port 8000
pause

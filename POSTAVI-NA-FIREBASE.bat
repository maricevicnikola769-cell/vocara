@echo off
chcp 65001 >nul
title Vocara - postavljanje na Firebase (vocara39@gmail.com)
setlocal
set "NALOG=vocara39@gmail.com"
set "PROJ=vocara-voce"

rem --- pronadji folder aplikacije ---
set "APP=%~dp0"
if not exist "%APP%firebase.json" set "APP=D:\vocara\New folder\vocara-app\"
if not exist "%APP%firebase.json" (
  echo Ne mogu da nadjem folder vocara-app sa datotekom firebase.json.
  echo Stavite ovu datoteku u folder vocara-app i pokrenite je ponovo.
  pause
  exit /b
)
cd /d "%APP%"
echo.
echo === Vocara: postavljanje na Google Firebase ===
echo Folder:  %CD%
echo Projekat: %PROJ%
echo Nalog:    %NALOG%
echo.

where node >nul 2>nul
if errorlevel 1 (
  echo Node.js nije instaliran. Preuzmite LTS sa https://nodejs.org i ponovo pokrenite.
  start https://nodejs.org
  pause
  exit /b
)
where firebase >nul 2>nul
if errorlevel 1 (
  echo Instaliram Firebase alat...
  call npm install -g firebase-tools
)

:PROVERA
call firebase login:list 2>nul | findstr /i /c:"%NALOG%" >nul
if not errorlevel 1 goto DEPLOY

echo.
echo ------------------------------------------------------------
echo  Prijava: u pregledacu izaberite nalog  %NALOG%
echo  Ako ga nema na listi, kliknite "Use another account".
echo  Zatim kliknite "Allow". Ako ovde pita Y/n, upisite n i Enter.
echo ------------------------------------------------------------
call firebase logout >nul 2>nul
call firebase login
call firebase login:list 2>nul | findstr /i /c:"%NALOG%" >nul
if not errorlevel 1 goto DEPLOY

echo.
echo Prijavljen je pogresan nalog. Pokusavam nacin sa kodom:
echo 1. Otvorite link koji se pojavi ispod (Ctrl+klik ili kopirajte u pregledac)
echo 2. Prijavite se nalogom %NALOG%
echo 3. Kopirajte dobijeni kod, nalepite ga ovde desnim klikom i pritisnite Enter
call firebase logout >nul 2>nul
call firebase login --no-localhost
call firebase login:list 2>nul | findstr /i /c:"%NALOG%" >nul
if errorlevel 1 (
  echo.
  echo *** I dalje nije prijavljen nalog %NALOG%. ***
  call firebase login:list
  echo Fotografisite ovaj prozor i posaljite ga.
  pause
  exit /b
)

:DEPLOY
echo.
echo Prijavljen nalog %NALOG%.
echo Pravim bazu podataka, ako vec postoji preskacem...
call firebase firestore:databases:create "(default)" --location=eur3 --project %PROJ% >nul 2>nul
echo Postavljam aplikaciju i pravila baze...
call firebase deploy --only hosting,firestore:rules --project %PROJ%
if errorlevel 1 (
  echo.
  echo *** Postavljanje baze NIJE uspelo, postavljam samo aplikaciju... ***
  call firebase deploy --only hosting --project %PROJ%
  echo.
  echo Napravite bazu u konzoli: Build ^> Firestore Database ^> Create database
  echo lokacija eur3 Europe, "Start in production mode", pa pokrenite ovu datoteku ponovo.
  start https://console.firebase.google.com/project/%PROJ%/firestore
  pause
  exit /b
)
echo.
echo ============================================================
echo  GOTOVO! Aplikacija je na adresi: https://%PROJ%.web.app
echo ============================================================
start https://%PROJ%.web.app
pause

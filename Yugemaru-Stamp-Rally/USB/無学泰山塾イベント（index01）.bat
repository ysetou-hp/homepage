@echo off
setlocal

rem ===== バッチファイルと同じ場所にある index.html を指定 =====
set "HTML_FILE=%~dp0index01.html"

rem ===== Chrome の場所 =====
set "CHROME_EXE=C:\Program Files\Google\Chrome\Application\chrome.exe"

rem ===== Chrome が見つからない場合の予備パス =====
if not exist "%CHROME_EXE%" (
    set "CHROME_EXE=C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
)

rem ===== index.html の存在確認 =====
if not exist "%HTML_FILE%" (
    echo index.html が見つかりません。
    echo このバッチファイルと同じフォルダに index.html を置いてください。
    echo.
    echo 探した場所:
    echo %HTML_FILE%
    pause
    exit /b
)

rem ===== Chrome の存在確認 =====
if not exist "%CHROME_EXE%" (
    echo Google Chrome が見つかりません。
    echo Chrome をインストールするか、CHROME_EXE のパスを修正してください。
    pause
    exit /b
)

rem ===== Windowsパスを file:/// 形式に変換 =====
set "FILE_URL=file:///%HTML_FILE:\=/%"

rem ===== Chrome キオスクモードで起動し、カメラ許可を自動化 =====
start "" "%CHROME_EXE%" --kiosk --use-fake-ui-for-media-stream "%FILE_URL%"

endlocal
@echo off
echo Configurando ADB para Flutter...

REM Definir caminho do Android SDK
set ANDROID_SDK_ROOT=D:\AndroidWorkFolder\Android\Sdk
set ADB_PATH=%ANDROID_SDK_ROOT%\platform-tools

REM Adicionar ADB ao PATH temporariamente
set PATH=%ADB_PATH%;%PATH%

echo Verificando dispositivos conectados...
"%ADB_PATH%\adb.exe" devices

echo.
echo Reiniciando servidor ADB...
"%ADB_PATH%\adb.exe" kill-server
"%ADB_PATH%\adb.exe" start-server

echo.
echo Verificando dispositivos novamente...
"%ADB_PATH%\adb.exe" devices

echo.
echo Instalando aplicativo Flutter...
flutter install

echo.
echo Script concluído!
pause
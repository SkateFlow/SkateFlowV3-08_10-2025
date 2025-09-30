@echo off
echo ========================================
echo RESOLVENDO PROBLEMAS DE ADB - FLUTTER
echo ========================================

REM Configurar variáveis de ambiente
set ANDROID_SDK_ROOT=D:\AndroidWorkFolder\Android\Sdk
set ADB_PATH=%ANDROID_SDK_ROOT%\platform-tools
set PATH=%ADB_PATH%;%PATH%

echo 1. Verificando dispositivos conectados...
"%ADB_PATH%\adb.exe" devices -l

echo.
echo 2. Reiniciando servidor ADB...
"%ADB_PATH%\adb.exe" kill-server
timeout /t 2 /nobreak >nul
"%ADB_PATH%\adb.exe" start-server

echo.
echo 3. Verificando dispositivos novamente...
"%ADB_PATH%\adb.exe" devices -l

echo.
echo 4. Verificando se depuração USB está habilitada...
"%ADB_PATH%\adb.exe" shell getprop ro.debuggable

echo.
echo ========================================
echo INSTRUÇÕES PARA O CELULAR:
echo ========================================
echo 1. Vá em Configurações > Opções do desenvolvedor
echo 2. Ative "Depuração USB" se não estiver ativo
echo 3. Ative "Instalar via USB" 
echo 4. Ative "Verificação de apps via USB" (desativar)
echo 5. Quando aparecer popup no celular, clique em "Permitir"
echo ========================================

echo.
echo 5. Tentando instalar o APK...
"%ADB_PATH%\adb.exe" install -r "build\app\outputs\flutter-apk\app-release.apk"

echo.
echo 6. Se ainda não funcionar, tente instalar via Flutter...
flutter install --device-id=bbbd37ad

echo.
echo Script concluído!
pause
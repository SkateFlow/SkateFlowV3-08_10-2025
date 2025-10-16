@echo off
echo ========================================
echo    SKATEFLOW - OTIMIZACAO DE PROJETO
echo ========================================
echo.

echo [1/6] Limpando cache do Flutter...
flutter clean
echo.

echo [2/6] Baixando dependencias...
flutter pub get
echo.

echo [3/6] Analisando codigo...
flutter analyze
echo.

echo [4/6] Verificando dependencias desatualizadas...
flutter pub outdated
echo.

echo [5/6] Compilando para profile (teste de performance)...
flutter build apk --profile --analyze-size
echo.

echo [6/6] Executando em modo profile...
echo Para testar performance, execute:
echo flutter run --profile --enable-software-rendering
echo.

echo ========================================
echo    OTIMIZACAO CONCLUIDA!
echo ========================================
echo.
echo PROXIMOS PASSOS:
echo 1. Execute: flutter run --profile
echo 2. Teste a navegacao entre telas
echo 3. Verifique o uso de memoria no Android Studio
echo.
pause
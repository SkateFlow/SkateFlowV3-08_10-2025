# Otimização para Emulador - SkateFlow

## 🚀 Configurações do Emulador

### 1. **Configurações Recomendadas**
```bash
# Criar AVD otimizado
flutter emulators --create --name skateflow_optimized

# Configurações AVD:
- RAM: 4GB (mínimo) / 8GB (recomendado)
- VM Heap: 512MB
- Internal Storage: 8GB
- Graphics: Hardware - GLES 2.0
- Multi-Core CPU: 4 cores
```

### 2. **Flags de Compilação Otimizada**
```bash
# Para desenvolvimento
flutter run --debug --enable-software-rendering

# Para testes de performance
flutter run --profile --enable-software-rendering

# Para release
flutter run --release
```

### 3. **Configurações do Android Studio**
```
# VM Options (Help > Edit Custom VM Options)
-Xmx8g
-XX:ReservedCodeCacheSize=512m
-XX:+UseConcMarkSweepGC
-XX:SoftRefLRUPolicyMSPerMB=50
```

## 🔧 Otimizações Implementadas

### 1. **MainScreen**
- ✅ Lazy loading de telas
- ✅ Remoção do IndexedStack
- ✅ Cache inteligente de widgets

### 2. **MapScreen**
- ✅ Cache de skateparks
- ✅ Debounce em filtros
- ✅ Marcadores menores
- ✅ Lazy loading de detalhes

### 3. **Fontes**
- ✅ Fallback para Roboto
- ✅ Cache de Google Fonts
- ✅ Redução de chamadas de rede

### 4. **Services**
- ✅ Debounce em listeners
- ✅ Tratamento de erros
- ✅ Cleanup automático

## 📱 Comandos Úteis

```bash
# Limpar cache do Flutter
flutter clean && flutter pub get

# Verificar performance
flutter run --profile --trace-startup

# Analisar tamanho do app
flutter build apk --analyze-size

# Debug de memória
flutter run --debug --enable-software-rendering --verbose
```

## 🎯 Resultados Esperados

- **Tempo de inicialização**: 3-5 segundos (vs 10-15s anterior)
- **Navegação entre telas**: < 500ms
- **Carregamento do mapa**: 2-3 segundos
- **Uso de memória**: ~200MB (vs 400MB+ anterior)
- **CPU**: 15-25% (vs 50%+ anterior)
# Análise: Comunicação Backend vs Armazenamento Local

## 🔍 **PROBLEMA IDENTIFICADO**

### **Situação Atual:**
- **Tabela SQL**: Imagens aparecem como `NULL` no backend
- **Tela do App**: Imagens aparecem normalmente para o usuário
- **Causa**: Sistema está usando **armazenamento local** em vez do **backend**

## 📊 **Análise dos Serviços**

### 1. **UsuarioService** (Comunicação com Backend)
```dart
// ✅ CONECTA COM BACKEND
static String get baseUrl {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8080/usuario';  // Backend real
  } else {
    return 'http://localhost:8080/usuario';
  }
}

// ✅ Métodos que ENVIAM para backend:
- login(email, senha) → POST /usuario/login
- cadastrar(nome, email, senha) → POST /usuario/save
- fetchUsuarios() → GET /usuario/listar
```

### 2. **AuthService** (Gerenciamento Local)
```dart
// ❌ NÃO CONECTA COM BACKEND - Apenas simula
- login() → "Simula chamada para API"
- register() → "Simula registro" 
- updateUserImage() → Salva apenas localmente
- updateUserName() → Salva apenas localmente
```

### 3. **DatabaseService** (Armazenamento Local)
```dart
// ❌ APENAS LOCAL - SharedPreferences
- saveUserImage() → Salva no dispositivo
- getUserImage() → Carrega do dispositivo
- saveUserName() → Salva no dispositivo
- getUserName() → Carrega do dispositivo
```

## 🔄 **Fluxo Atual vs Esperado**

### **FLUXO ATUAL (Problemático):**
```
Login/Cadastro → AuthService (simula) → DatabaseService (local) → Tela mostra dados
                     ↓
                Backend SQL fica com NULL (não recebe dados)
```

### **FLUXO ESPERADO (Correto):**
```
Login/Cadastro → UsuarioService → Backend SQL → Retorna dados → Tela mostra
```

## 🚨 **Problemas Identificados**

### 1. **Login/Register não usa Backend:**
- `login_screen.dart` chama `AuthService().login()` 
- `register_screen.dart` chama `AuthService().register()`
- **Deveria chamar**: `UsuarioService.login()` e `UsuarioService.cadastrar()`

### 2. **Imagens não são enviadas ao Backend:**
- `updateUserImage()` salva apenas no `SharedPreferences`
- Backend nunca recebe as imagens
- Tabela SQL fica com campo `imagem = NULL`

### 3. **Dados ficam apenas no dispositivo:**
- Nome e imagem salvos em `SharedPreferences`
- Se trocar de dispositivo, dados são perdidos
- Backend não tem informações atualizadas

## ✅ **Soluções Necessárias**

### 1. **Integrar Login/Register com Backend:**
```dart
// Em login_screen.dart e register_screen.dart
final success = await UsuarioService.login(email, password);
final success = await UsuarioService.cadastrar(nome, email, senha);
```

### 2. **Criar endpoint para upload de imagem:**
```dart
// Novo método no UsuarioService
static Future<bool> updateUserImage(int userId, String imagePath) async {
  // Enviar imagem para backend via multipart/form-data
}
```

### 3. **Sincronizar dados com Backend:**
```dart
// AuthService deve buscar dados do backend, não do local
Future<Usuario?> getCurrentUser() async {
  return await UsuarioService.getUserById(currentUserId);
}
```

## 🎯 **Resumo da Situação**

| Componente | Status Atual | Deveria Ser |
|------------|--------------|-------------|
| **Login** | AuthService (simula) | UsuarioService (backend) |
| **Cadastro** | AuthService (simula) | UsuarioService (backend) |
| **Imagens** | SharedPreferences (local) | Backend SQL + local cache |
| **Nomes** | SharedPreferences (local) | Backend SQL + local cache |

## 🔧 **Ação Imediata Necessária**

Para que as imagens apareçam na tabela SQL do backend:

1. **Modificar telas de login/register** para usar `UsuarioService`
2. **Criar endpoint de upload** de imagem no backend
3. **Integrar AuthService** com UsuarioService
4. **Implementar sincronização** entre local e backend

**Conclusão**: O app está funcionando 100% offline/local. Os dados nunca chegam ao backend SQL, por isso aparecem como `NULL` na tabela.
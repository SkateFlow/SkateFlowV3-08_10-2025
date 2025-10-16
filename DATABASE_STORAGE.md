# Sistema de Armazenamento - SkateFlow

## 📁 Estrutura de Dados

### 1. **Armazenamento Local**
- **SharedPreferences**: Metadados do usuário
- **Diretório do App**: Imagens do perfil
- **Persistência**: Dados mantidos entre sessões

### 2. **Dados Armazenados**

#### **Perfil do Usuário:**
```
user_profile_name: String (Nome do usuário)
user_profile_image: String (Caminho da imagem)
```

#### **Imagens:**
```
Localização: /data/data/com.example.skateflow/documents/
Formato: profile_[timestamp].jpg
Compressão: 80% qualidade, 512x512 max
```

## 🔧 Funcionalidades Implementadas

### 1. **ProfileScreen**
- ✅ Clique na imagem para editar
- ✅ Modal com opções (Câmera/Galeria/Remover)
- ✅ Feedback visual (SnackBar)
- ✅ Atualização automática da UI

### 2. **DatabaseService**
- ✅ Salvar imagem no armazenamento local
- ✅ Recuperar imagem persistida
- ✅ Remover imagem e limpar cache
- ✅ Gerenciar nome do usuário
- ✅ Verificação de integridade dos arquivos

### 3. **AuthService**
- ✅ Integração com DatabaseService
- ✅ Cache de dados em memória
- ✅ Notificação de mudanças (Listeners)
- ✅ Carregamento automático na inicialização

## 📱 Fluxo de Uso

### **Editar Imagem:**
1. **Usuário** clica na imagem do perfil
2. **Modal** aparece com opções
3. **Seleção** da fonte (Câmera/Galeria)
4. **Compressão** automática da imagem
5. **Salvamento** no armazenamento local
6. **Atualização** da UI em tempo real

### **Persistência:**
1. **Imagem** copiada para diretório do app
2. **Caminho** salvo no SharedPreferences
3. **Carregamento** automático na próxima sessão
4. **Verificação** de integridade do arquivo

## 🚀 Vantagens

- **Performance**: Imagens locais carregam instantaneamente
- **Offline**: Funciona sem conexão com internet
- **Segurança**: Dados ficam no dispositivo do usuário
- **Simplicidade**: Implementação leve e eficiente
- **Qualidade**: Compressão otimizada para mobile

## 🔄 Próximos Passos

Para integração com banco real:
1. Substituir SharedPreferences por SQLite/Firebase
2. Implementar upload de imagens para servidor
3. Adicionar sincronização online/offline
4. Implementar backup automático
# Funcionalidade: Adicionar Pistas

## Visão Geral
Esta funcionalidade permite que usuários logados solicitem a adição de novas pistas de skate no mapa. A implementação segue o padrão do projeto React e está preparada para integração com banco de dados.

## Arquivos Criados/Modificados

### Novos Arquivos:
1. **`lib/models/pista_request.dart`** - Modelo para solicitações de pistas
2. **`lib/services/pista_request_service.dart`** - Serviço para gerenciar solicitações
3. **`lib/services/auth_service.dart`** - Serviço de autenticação simples
4. **`lib/widgets/create_pista_modal.dart`** - Modal para criar solicitação de pista
5. **`lib/screens/pista_requests_screen.dart`** - Tela para visualizar solicitações

### Arquivos Modificados:
1. **`lib/screens/map_screen.dart`** - Adicionado botão flutuante para solicitar pistas
2. **`lib/screens/login_screen.dart`** - Integrado com serviço de autenticação
3. **`pubspec.yaml`** - Adicionada dependência `image_picker`

## Como Usar

### 1. No Mapa
- O botão "Solicitar Pista" aparece como FloatingActionButton no mapa
- Apenas usuários logados podem solicitar pistas
- Usuários não logados veem um diálogo pedindo para fazer login

### 2. Modal de Solicitação
O modal inclui:
- **Fotos**: Até 3 fotos da pista (opcional)
- **Nome**: Nome da pista (obrigatório)
- **Descrição**: Descrição detalhada (obrigatório, máx. 250 caracteres)
- **Categoria**: Bowl, Street ou Park (obrigatório)
- **CEP**: Busca automática de endereço via ViaCEP (obrigatório)
- **Endereço**: Preenchido automaticamente
- **Número**: Número do local (obrigatório)
- **Coordenadas**: Obtidas automaticamente via Nominatim
- **Tipo**: Pública ou Privada

### 3. Validações
- Todos os campos obrigatórios são validados
- CEP deve ter 8 dígitos
- Fotos são convertidas para base64
- Coordenadas são obtidas automaticamente

## Integração com Banco de Dados

### Preparação para BD
A estrutura está preparada para integração:

1. **PistaRequest Model**: Contém todos os campos necessários com serialização JSON
2. **PistaRequestService**: Métodos async prontos para substituir por chamadas de API
3. **Listeners**: Sistema de notificação para atualizações em tempo real

### Campos do Banco
```sql
CREATE TABLE pista_requests (
  id VARCHAR(255) PRIMARY KEY,
  nome VARCHAR(255) NOT NULL,
  descricao TEXT NOT NULL,
  categoria ENUM('bowl', 'street', 'park') NOT NULL,
  cep VARCHAR(9) NOT NULL,
  rua VARCHAR(255),
  bairro VARCHAR(255),
  numero VARCHAR(50) NOT NULL,
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  publica BOOLEAN DEFAULT TRUE,
  fotos JSON,
  status ENUM('pendente', 'aprovada', 'rejeitada') DEFAULT 'pendente',
  data_solicitacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  usuario_id VARCHAR(255),
  INDEX idx_status (status),
  INDEX idx_usuario (usuario_id)
);
```

## Próximos Passos

### Para Integração Completa:
1. **Substituir AuthService** por Firebase Auth ou sistema próprio
2. **Conectar PistaRequestService** com API/Firebase
3. **Implementar upload de imagens** para Firebase Storage ou servidor
4. **Adicionar sistema de notificações** para administradores
5. **Criar painel administrativo** para aprovar/rejeitar solicitações

### Melhorias Sugeridas:
1. **Validação de localização** - Verificar se já existe pista próxima
2. **Preview no mapa** - Mostrar localização antes de enviar
3. **Sistema de comentários** - Permitir feedback nas solicitações
4. **Notificações push** - Avisar sobre status da solicitação

## Dependências Adicionadas
```yaml
dependencies:
  image_picker: ^1.0.4  # Para seleção de fotos
```

## Uso da Funcionalidade

### Fluxo do Usuário:
1. Usuário faz login no app
2. Vai para o mapa
3. Clica no botão "Solicitar Pista"
4. Preenche o formulário no modal
5. Envia a solicitação
6. Recebe confirmação de envio

### Fluxo Administrativo (futuro):
1. Admin recebe notificação de nova solicitação
2. Visualiza detalhes na tela de solicitações
3. Aprova ou rejeita a solicitação
4. Usuário é notificado sobre o status

A funcionalidade está totalmente funcional e pronta para uso, seguindo os padrões do projeto React e preparada para integração com banco de dados.
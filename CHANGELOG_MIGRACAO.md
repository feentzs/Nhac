# CHANGELOG MIGRACAO

Este arquivo registra as decisões e descobertas da migração do app Nhac do Firebase para a API REST.

## Fase 0: Preparação

### Descoberta Obrigatória

#### Buscas de dependências:
- `grep -rln "FirebaseAuth" lib/`: 26 matches.
- `grep -rln "cloud_firestore\|FirebaseFirestore" lib/`: 15 matches.
- `grep -rln "GoogleSignIn" lib/`: 7 matches.
- `grep -rln "verifyPhoneNumber\|PhoneAuthProvider\|PhoneAuthCredential" lib/`: 4 matches.
- `grep -rln "AuthService()" lib/`: 2 matches.
- `grep -rln "ApiClient()" lib/`: 6 matches.
- `grep -rn "e.response?.data\['mensagem'\]\|\['mensagem'\]" lib/`: 1 match (lib/repositories/pedido_repository.dart).
- `grep -rln "authServiceRoteador\|currentUser\b" lib/globals/router.dart`: 35 matches (em diversos arquivos).

### Verificação do Contrato da API

Realizada investigação empírica (via `curl` contra `https://backend-nhac.onrender.com/api/v1`):

- **Autenticação:** POST `/auth/registrar` funciona como documentado, retornando token JWT.
- **Campo isPadrao:** A API retorna `isPadrao` (boolean) e não `padrao`.
  - **Decisão:** `EnderecoModel.fromMap` e `toMap` devem ser atualizados para usar `isPadrao` em vez de `padrao`.

### Arquivos relevantes identificados (além dos listados no prompt):
- Não foram encontrados arquivos críticos adicionais nas buscas iniciais que precisem ser adicionados à lista principal de alteração.

---
Fase 0 concluída. Decisões registradas.

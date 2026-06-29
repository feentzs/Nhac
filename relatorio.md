# Relatório de Auditoria de Migração: Firestore para REST

Este relatório documenta os pontos de quebra arquitetural, resquícios do Firebase Firestore e desalinhamentos com a nova API REST (Spring Boot) encontrados na estrutura `lib/`.

---

## 📄 Arquivo: `lib/main.dart`
- **Linha:** 53
- **Problema Encontrado:** Uso de `FirebaseFirestore.instance.settings`.
- **Como Corrigir:** Remover a configuração do Firestore. O aplicativo não deve mais inicializar ou configurar o Firestore.

---

## 📄 Arquivo: `lib/pages/loja_page.dart`
- **Linha:** 22, 28, 354
- **Problema Encontrado:** Uso de `Stream<QuerySnapshot>` e `StreamBuilder<QuerySnapshot>`.
- **Como Corrigir:** Substituir o `StreamBuilder` por um `FutureBuilder` ou gerenciamento de estado (via Controller/Provider) que consuma dados do `LojaRepository` via REST (Dio).

---

## 📄 Arquivo: `lib/pages/search_page.dart`
- **Linha:** 73
- **Problema Encontrado:** Uso de `FirebaseFirestore.instance.collection(...)` para realizar buscas.
- **Como Corrigir:** Implementar endpoint de busca no backend Spring Boot e consumir via `ProdutoRepository`.

---

## 📄 Arquivo: `lib/pages/enderecos_page.dart`
- **Linha:** 398, 567, 602 (e outras)
- **Problema Encontrado:** Uso de `endereco.idDocumento` e chamadas diretas como `removerEndereco(endereco.idDocumento)`.
- **Como Corrigir:** Utilizar `endereco.id` (padrão camelCase) e garantir que os métodos do `EnderecoProvider` sejam chamados com os parâmetros corretos (`id` string).

---

## 📄 Arquivo: `lib/models/produto/avaliacoes.dart`
- **Linha:** 6, 14, 50
- **Problema Encontrado:** Uso de `idDocumento` e `FieldValue.serverTimestamp()`.
- **Como Corrigir:** Alterar `idDocumento` para `id`. Remover `FieldValue.serverTimestamp()`, assumindo que o timestamp é gerado no backend ou enviado como String ISO-8601 pelo cliente.

---

## 📄 Arquivo: `lib/models/usuario/endereco_model.dart`
- **Linha:** 24, 52
- **Problema Encontrado:** Existência do getter `idDocumento` e fallback para `idDocumento` no `fromMap`.
- **Como Corrigir:** Remover o getter `idDocumento`. Atualizar o `fromMap` para ler estritamente de `id` (camelCase).

---

## 📄 Arquivo: `lib/controllers/user_provider.dart`
- **Linha:** 34, 46, 57, 66
- **Problema Encontrado:** Uso de `user.uid` e `FirebaseStorage`.
- **Como Corrigir:** Migrar referências de `uid` para `id`. Se o upload de fotos ainda usar `FirebaseStorage`, refatorar para enviar o arquivo para o endpoint de upload da API REST.

---

## 📄 Arquivo: `lib/services/auth_service.dart`
- **Linha:** Várias (36, 68, 72, 85, etc.)
- **Problema Encontrado:** Forte dependência de `FirebaseAuth.instance.currentUser!.uid` e uso de `foto_url`.
- **Como Corrigir:** A autenticação deve agora ser feita via API (JWT). Os dados de usuário devem vir do `UserRepository` utilizando o `id` do usuário. Refatorar `foto_url` para `imagemUrl` nos DTOs.

---

## 📄 Arquivo: `lib/pages/carrinho_page.dart`
- **Linha:** 652
- **Problema Encontrado:** Chamada `definirComoPadrao(endereco.idDocumento)`.
- **Como Corrigir:** Atualizar para `definirComoPadrao(endereco.id)`.

---

## 📝 Observações Gerais de Arquitetura:
1. **Snake Case:** Diversos modelos (Favoritos, Pagamentos, Avaliações) ainda contêm campos como `id_produto` ou `imagem_url`. Todos devem ser convertidos para `produtoId` e `imagemUrl` para seguir o padrão `camelCase` definido.
2. **Providers:** Embora os métodos nos Providers (`CartProvider`, `EnderecoProvider`) pareçam corretos, a auditoria indica que os arquivos de `UI` (`pages/`) ainda tentam acessar propriedades obsoletas dos objetos de modelo ou usar métodos antigos que foram substituídos na refatoração dos repositórios.
3. **Null Safety:** Campos opcionais (`?`) estão sendo acessados sem `?.` em diversas partes da UI, especialmente em `checkout_page.dart` e `editar_perfil/`. Revisar todo acesso a dados de endereço e usuário.

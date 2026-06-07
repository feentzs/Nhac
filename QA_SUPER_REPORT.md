# 🚨 Relatório de Auditoria de QA - Core Logic

## 1. Testes que Passaram (Resumo)
- **Validators:** Validação de Email, Senha (força), Telefone e Nome (exceto casos de borda).
- **Models (fromMap/toMap):** Mapeamento básico de `ProdutosModel`, `LojasModel` e `CarrinhoModel` com dados íntegros e completos.
- **CartProvider:** Método `limparCarrinhoLocal` (parcialmente, pois depende do Firebase na inicialização).

## 2. Testes que Falharam (Análise Profunda)

### **Arquivo/Módulo:** `lib/utils/validators.dart`
- **Erro Recebido:** Expected: <null>, Actual: 'CPF inválido'
- **Causa Raiz:** O algoritmo de validação de CPF em `_validarDigitosCPF` apresenta inconsistências em cálculos de restos ou pesos para determinados CPFs válidos (ex: CPFs iniciados com 0 ou com dígitos verificadores específicos).
- **Ação de Correção:** Revisar a lógica de pesos e o tratamento do resto da divisão por 11. Recomenda-se utilizar uma biblioteca consolidada ou validar contra o algoritmo oficial da Receita Federal detalhadamente.

### **Arquivo/Módulo:** `lib/models/loja/lojas.dart` & `lib/models/produto/produtos.dart`
- **Erro Recebido:** `_TypeError` (type 'int' is not a subtype of type 'String') e `NoSuchMethodError` (Class 'String' has no instance method 'toDouble').
- **Causa Raiz:** Falta de robustez no método `fromMap`. O código assume que o Firebase sempre retornará o tipo exato (ex: `map['nome']` como `String`). Se o banco contiver um dado corrompido (ex: um `int` no campo `nome`), o app crasha imediatamente.
- **Ação de Correção:** Aplicar sanitização de tipos em todos os `fromMap`.
  - Usar `map['nome']?.toString() ?? ''` em vez de `map['nome'] ?? ''`.
  - Usar um helper para converter dinamicamente para double: `double.tryParse(map['preco'].toString()) ?? 0.0`.

### **Arquivo/Módulo:** `lib/controllers/cart_provider.dart`
- **Erro Recebido:** `[core/no-app] No Firebase App '[DEFAULT]' has been created`.
- **Causa Raiz:** **Falta de Injeção de Dependência (DI).** O `CartProvider` instancia `FirebaseAuth.instance` e `CartRepository` diretamente no corpo da classe. Isso impede a criação de testes unitários "Pure Dart", pois qualquer instância da classe tenta conectar ao Firebase.
- **Ação de Correção:** Refatorar o construtor para aceitar as dependências (DI):
  ```dart
  CartProvider({FirebaseAuth? auth, CartRepository? repo}) 
    : _auth = auth ?? FirebaseAuth.instance,
      _cartRepository = repo ?? CartRepository();
  ```

### **Arquivo/Módulo:** `lib/controllers/cart_provider.dart` (Lógica de Negócio)
- **Erro Recebido:** Lógica ausente.
- **Causa Raiz:** O requisito de "limite de lojas diferentes no mesmo carrinho" não está implementado. Além disso, o `CarrinhoModel` não armazena o `loja_id`, impossibilitando essa verificação sem uma consulta extra ao Firestore (que impacta performance).
- **Ação de Correção:** 
  1. Adicionar `loja_id` ao `CarrinhoModel`.
  2. No `CartProvider.adicionarItem`, verificar se o `loja_id` do novo item é igual ao dos itens já presentes no `_itens`.

## 3. Observações de Infraestrutura de Testes
- **UI Tests:** Vários testes de widgets falharam (`ProductCard`, `SetaVoltar`) por dependência de `ScreenUtil` não inicializado no ambiente de teste.
- **Mocking:** Adicionada a biblioteca `mocktail` para suportar a refatoração dos testes de lógica.

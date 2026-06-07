# 📐 Relatório de Auditoria de Responsividade & UI

## 🚨 Riscos de RenderFlex Overflow (Telas Quebradas)

- **Arquivo:** `lib/components/product_card.dart`
  - **Widget (Linha 94):** `Row` que contém o preço e o botão de "Adicionar".
  - **Por que vai dar overflow:** O preço e o ícone de adicionar estão em uma `Row` sem proteção de espaço. Se o preço for muito alto (ex: R$ 1.000,00) ou a fonte do sistema estiver grande, o texto do preço empurrará o botão para fora da largura fixa de `160.w`.
  - **Lógica da Correção:** Envolver o `Text` do preço em um `Expanded` ou `Flexible`, ou usar um `FittedBox` para garantir que o preço diminua de tamanho antes de quebrar o layout.

- **Arquivo:** `lib/pages/produto_detalhes_page.dart`
  - **Widget (Linha 148):** `Row` que contém o preço formatado e o badge de avaliação.
  - **Por que vai dar overflow:** Em telas estreitas (como iPhone SE) ou com escala de acessibilidade ativa, o preço gigante (`fontSize: 42.sp`) somado ao badge de estrela pode exceder a largura horizontal, causando a faixa amarela/preta.
  - **Lógica da Correção:** Usar `Wrap` em vez de `Row` para permitir que o badge de avaliação caia para a linha de baixo se necessário, ou envolver a `Row` em um `FittedBox`.

- **Arquivo:** `lib/pages/produto_detalhes_page.dart`
  - **Widget (Linha 426):** `Row` no método `_buildServiceRow`.
  - **Por que vai dar overflow:** Embora o `Text` do serviço já esteja em um `Expanded`, o `Row` pai pode sofrer se o ícone e o chevron forem grandes. (Nota: Este está relativamente seguro, mas vale atenção em fontes extremas).

## ⚠️ Anti-Patterns de ScreenUtil & Geometria

- **Arquivo:** `lib/components/product_card.dart`
  - **Widget (Linha 31):** `margin: EdgeInsets.only(right: 16.w)`
  - **Uso Incorreto:** Uso de `.w` para margem lateral é aceitável, mas há uma inconsistência no uso de `.h` para `Offset` de sombras (Linha 39: `Offset(0, 4.h)`).
  - **Lógica da Correção:** Padronizar o uso. Geralmente, `Offset` de sombra deve ser `Offset(0, 4.r)` ou valores fixos, pois sombras escalonadas verticalmente podem parecer estranhas em diferentes aspect ratios.

- **Arquivo:** `lib/pages/produto_detalhes_page.dart`
  - **Widget (Linha 141):** `padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 10.h)`
  - **Uso Incorreto:** Uso de `.h` em padding vertical dentro de um `SliverToBoxAdapter` que está dentro de um `CustomScrollView`. 
  - **Lógica da Correção:** Em listas roláveis (onde a altura é infinita), usar `.h` pode causar espaçamentos exagerados em tablets ou telas longas. Prefira `.w` para manter a proporção baseada na largura (estratégia de escala uniforme) ou `.r` (radius/adaptativo).

- **Arquivo:** `lib/pages/produto_detalhes_page.dart`
  - **Widget (Linha 399):** `boxShadow: [BoxShadow(..., offset: const Offset(0, -5))]`
  - **Uso Incorreto:** Valor hardcoded (`-5`) sem adaptação do `ScreenUtil`.
  - **Lógica da Correção:** Aplicar `.h` ou `.r` no offset: `Offset(0, -5.h)`.

- **Arquivo:** `lib/pages/home_page.dart`
  - **Widget (Linha 158):** `right: 24.w + (75.w / 2) - 25.w`
  - **Uso Incorreto:** Cálculos matemáticos manuais complexos para posicionamento.
  - **Lógica da Correção:** Embora use `.w`, o excesso de lógica no `Positioned` pode ser simplificado usando `Alignment` ou aproveitando melhor o sistema de grids.

- **Geral:**
  - **Hardcoded Shadows:** Muitos componentes usam `blurRadius: 10.r` (correto), mas alguns `Offsets` permanecem sem extensão (ex: `Offset(0, -5)` na `ProdutoDetalhesPage`).
  - **MediaQuery vs ScreenUtil:** Na `HomePage.dart` (Linha 252), há o uso de `MediaQuery.of(context).size.width - 48.w`. Isso pode causar conflitos se o `ScreenUtil` não estiver calibrado com a mesma largura de viewport. O ideal seria usar `1.sw - 48.w`.

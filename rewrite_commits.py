import subprocess
import os

def get_base_branch():
    """Tenta identificar se a branch base é main ou master."""
    branches = subprocess.check_output(['git', 'branch']).decode('utf-8')
    if 'main' in branches:
        return 'main'
    return 'master'

def get_commits(base_branch):
    """Lista hashes e mensagens dos commits exclusivos da branch atual."""
    log_format = "%h||%s"
    try:
        output = subprocess.check_output(
            ['git', 'log', f'{base_branch}..HEAD', f'--pretty=format:{log_format}'],
            stderr=subprocess.STDOUT
        ).decode('utf-8')
        if not output:
            return []
        return [line.split('||') for line in output.split('\n') if '||' in line]
    except subprocess.CalledProcessError:
        return []

def translate_message(old_message):
    """
    Traduz e padroniza mensagens para pt-BR + Conventional Commits.
    Adicione novos mapeamentos aqui conforme necessário.
    """
    mappings = {
        # Traduções de Inglês para pt-BR
        "fix: enforce business rules in search, improve error handling, and sync models": 
            "fix: aplicar regras de negócio na busca e sincronizar modelos de dados",
        "perf: cache futures in state to prevent firestore refetching loop during ui rebuilds":
            "perf: cachear futures no estado para evitar loops de refetching no Firestore",
        "perf: refactor expensive streams to futures, optimize search queries, and fix timer memory leak":
            "perf: refatorar streams pesadas para futures e otimizar queries de busca",
        "fix: resolve type mismatch in home product sections, remove redundant models, and fix search query routing":
            "fix: resolver inconsistência de tipos na Home e ajustar rotas de busca",
        "feat(home): add quick categories, dynamic banners and optimize queries for open status":
            "feat(home): adicionar categorias rápidas, banners dinâmicos e otimizar queries",
        
        # Padronização de mensagens pt-BR informais
        "arrumando transições": "refactor: ajustar transições de tela e animações",
        "tirando advertencia": "chore: remover warnings e avisos do compilador",
        "corrigindo algumas coisas": "fix: correções gerais de bugs e estabilidade",
        "inicio pagina da loja, tá insalubre ainda": "feat: iniciar implementação da página da loja",
        "fiz mais algumas animações": "feat: adicionar animações de interface",
        "pequenas correções": "fix: pequenos ajustes de código",
        "remove comentários desnecessários": "chore: remover comentários e código morto",
        "aplica o screenUtil em todas as páginas": "refactor: aplicar responsividade com ScreenUtil em todas as telas",
        "loja parceira": "feat: adicionar seção de lojas parceiras",
        "transição tela inicial para detalhe produto": "feat: implementar navegação da home para detalhes",
        "botão compatilhar \"funcional\" e produtos relacionados": "feat: adicionar compartilhamento e produtos relacionados",
        "tela detalhes produto iniciada": "feat: iniciar construção da tela de detalhes do produto",
        "tirando advertencia :trollface:": "chore: remover avisos de lint e código depreciado",
        "mais animação :trollface:": "feat: adicionar novas animações interativas",
        "melhorias barra total :trollface:": "refactor: otimizar layout da barra de valor total",
        "tirando debug do debug :trollface: :": "chore: remover logs de depuração desnecessários",
        "commit besta :trollface:": "chore: limpeza técnica e pequenos ajustes",
        "melhorias na animações tela carrinho": "refactor: suavizar animações na tela do carrinho",
        "animação isana carrinho/ navbar": "feat: implementar animações fluidas no carrinho e navbar",
        "incio tela carrinho": "feat: iniciar desenvolvimento da tela de carrinho",
        "Quando sem internet ou sem imagem ele não crasha mais": "fix: tratar falhas de conectividade e imagens ausentes para evitar crashes",
        "alguns detalhes pa": "chore: ajustes finos de UI e estilização",
        "Otimização com Cache": "perf: implementar cache de dados para performance",
        "Remoção Advertencias": "chore: limpeza de warnings e otimização de imports",
        "Inicio Cupons": "feat: iniciar implementação do sistema de cupons",
        "Mudanças Gerais na Tipografia": "refactor: padronizar tipografia e estilos de texto",
        "inicio tela formas de pagamento": "feat: iniciar tela de seleção de pagamentos",
    }
    
    # Retorna o mapeamento se existir, senão retorna a mensagem original (ou tenta traduzir prefixos)
    return mappings.get(old_message, old_message)

def generate_bash_script(commits, base_branch):
    """Gera um script shell para realizar o rebase automatizado."""
    with open('rewrite_history.sh', 'w', encoding='utf-8') as f:
        f.write("#!/bin/bash\n\n")
        f.write(f"git rebase -i {base_branch} <<EOF\n")
        
        # Injeta comandos reword no editor interativo (isso requer configuração de EDITOR, 
        # mas para simplicidade usaremos filter-branch limitado conforme sugerido)
        f.write("EOF\n\n")
        
        f.write("# Alternativa via filter-branch limitada ao range (mais segura que global)\n")
        f.write("git filter-branch -f --msg-filter \\\n")
        f.write('  \'python3 -c "import sys; mapping = {\\')
        for hash, msg in commits:
            new_msg = translate_message(msg)
            if new_msg != msg:
                f.write(f'\\"{hash}\\": \\"{new_msg}\\", \\')
        f.write('}; print(mapping.get(os.environ[\\"GIT_COMMIT\\"][:7], sys.stdin.read().strip()))"\' ')
        f.write(f"{base_branch}..HEAD\n")

    os.chmod('rewrite_history.sh', 0o755)
    print("Script 'rewrite_history.sh' gerado com sucesso.")

def main():
    base = get_base_branch()
    print(f"Detectada branch base: {base}")
    
    commits = get_commits(base)
    if not commits:
        print("Nenhum commit encontrado para traduzir no range da branch.")
        return

    print(f"Encontrados {len(commits)} commits. Gerando mapeamento...")
    
    # Exibe o que será alterado
    for hash, msg in commits:
        new_msg = translate_message(msg)
        if new_msg != msg:
            print(f"  {hash}: {msg} -> {new_msg}")
    
    # Por segurança, o script apenas gera as instruções/ferramentas para o rebase
    generate_bash_script(commits, base)
    
    print("\nAVISO DE SEGURANÇA:")
    print("O script 'rewrite_history.sh' foi criado. Ele usa git filter-branch")
    print(f"limitado APENAS ao range {base}..HEAD. Isso não altera o histórico principal.")
    print("Execute './rewrite_history.sh' para aplicar.")

if __name__ == "__main__":
    main()

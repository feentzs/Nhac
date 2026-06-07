const { execSync } = require('child_process');
const fs = require('fs');
const path = require('fs');

/**
 * Tenta identificar se a branch base é main ou master.
 */
function getBaseBranch() {
    try {
        const branches = execSync('git branch').toString();
        return branches.includes('main') ? 'main' : 'master';
    } catch (e) {
        return 'main';
    }
}

/**
 * Lista hashes e mensagens dos commits exclusivos da branch atual.
 */
function getCommits(baseBranch) {
    const logFormat = "%h||%s";
    try {
        const output = execSync(`git log ${baseBranch}..HEAD --pretty=format:"${logFormat}"`).toString();
        if (!output.trim()) return [];
        return output.split('\n').filter(line => line.includes('||')).map(line => line.split('||'));
    } catch (e) {
        return [];
    }
}

/**
 * Traduz e padroniza mensagens para pt-BR + Conventional Commits.
 */
function translateMessage(oldMessage) {
    const mappings = {
        // Commits recentes do Agente
        "fix: harden ui layout against renderflex overflows using FittedBox/Wrap and normalize screenutil scaling":
            "fix: blindar layout contra overflows com FittedBox/Wrap e normalizar escala ScreenUtil",
        "fix: apply defensive parsing on models, inject cart dependencies, enforce single-store cart rule, and harden CPF validation":
            "fix: aplicar parsing defensivo nos models, injeção no carrinho e validar CPF",
        "chore: generate safe branch-scoped commit translation script":
            "chore: gerar script de tradução de commits seguro por branch",
        "test: implement headless widget tests for core ui components and ensure layout stability":
            "test: implementar testes de widgets headless e garantir estabilidade de layout",
        "fix: resolve remaining DI failures and fully decouple UI from direct Firebase calls":
            "fix: resolver falhas de DI e desacoplar UI de chamadas diretas ao Firebase",
        "chore: generate read-only test report for ui and logic without modifying source code":
            "chore: gerar relatório de auditoria de testes (apenas leitura)",
        "chore: run read-only static analysis on ui components for responsiveness and overflow risks":
            "chore: realizar análise estática de UI para riscos de responsividade",

        // Traduções de Inglês para pt-BR (Anteriores)
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
        
        // Padronização de mensagens pt-BR informais
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
    };
    
    return mappings[oldMessage] || oldMessage;
}

/**
 * Gera um script shell para realizar a substituição via filter-branch limitada.
 */
function generateShellScript(commits, baseBranch) {
    let scriptContent = "#!/bin/bash\n\n";
    scriptContent += "git filter-branch -f --msg-filter \\\n";
    scriptContent += "  'node -e \"const mapping = {\\\n";
    
    commits.forEach(([hash, msg]) => {
        const newMsg = translateMessage(msg);
        if (newMsg !== msg) {
            scriptContent += `\\\"${hash}\\\": \\\"${newMsg}\\\", \\\n`;
        }
    });

    scriptContent += "}; process.stdout.write(mapping[process.env.GIT_COMMIT.substring(0, 7)] || require(\\\"fs\\\").readFileSync(0, \\\"utf8\\\").trim());\"' ";
    scriptContent += `${baseBranch}..HEAD\n`;

    fs.writeFileSync('rewrite_history.sh', scriptContent, { mode: 0o755 });
    console.log("Script 'rewrite_history.sh' gerado com sucesso.");
}

function main() {
    const base = getBaseBranch();
    console.log(`Detectada branch base: ${base}`);
    
    const commits = getCommits(base);
    if (commits.length === 0) {
        console.log("Nenhum commit encontrado para traduzir no range da branch.");
        return;
    }

    console.log(`Encontrados ${commits.length} commits. Gerando mapeamento...`);
    
    commits.forEach(([hash, msg]) => {
        const newMsg = translateMessage(msg);
        if (newMsg !== msg) {
            console.log(`  ${hash}: ${msg} -> ${newMsg}`);
        }
    });
    
    generateShellScript(commits, base);
    
    console.log("\nAVISO DE SEGURANÇA:");
    console.log("O script 'rewrite_history.sh' foi criado. Ele usa git filter-branch");
    console.log(`limitado APENAS ao range ${base}..HEAD. Isso não altera o histórico principal.`);
    console.log("Execute './rewrite_history.sh' para aplicar.");
}

main();

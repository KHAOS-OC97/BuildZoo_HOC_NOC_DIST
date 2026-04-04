#!/usr/bin/env node
'use strict';

/**
 * mirror.js — Espelha artefatos para repositório externo via GitHub API.
 *
 * Variáveis de ambiente esperadas (opcionais):
 *   MIRROR_REPO   — "owner/repo" de destino (se vazio ou igual ao repo atual, pula)
 *   MIRROR_TOKEN  — Personal Access Token com permissão de push no repo de destino
 *   MIRROR_BRANCH — Branch de destino (padrão: main)
 */

const fs = require('fs');
const path = require('path');
const https = require('https');

const settings = require('../modulos/settings.json');

const MIRROR_TOKEN  = process.env.MIRROR_TOKEN  || '';
const MIRROR_REPO   = process.env.MIRROR_REPO   || '';
const MIRROR_BRANCH = process.env.MIRROR_BRANCH || settings.distBranch || 'main';
const CURRENT_REPO  = process.env.GITHUB_REPOSITORY || '';

// ── Decisão de pular espelhamento externo ────────────────────────────────
if (!MIRROR_TOKEN) {
  console.log('[Mirror] MIRROR_TOKEN não configurado — espelhamento externo ignorado.');
  process.exit(0);
}

if (!MIRROR_REPO || MIRROR_REPO === CURRENT_REPO) {
  console.log('[Mirror] Repositório de destino é o mesmo ou não definido — nada a espelhar externamente.');
  process.exit(0);
}

const [owner, repo] = MIRROR_REPO.split('/');

if (!owner || !repo) {
  console.error('[Mirror] MIRROR_REPO inválido. Use o formato "owner/repo".');
  process.exit(1);
}

const distDir = path.resolve(__dirname, '..', 'dist');
const files = [
  { src: `${settings.scriptName}.release.obf.lua`, dest: `${settings.scriptName}.release.obf.lua` },
  { src: 'Loader.release.lua', dest: 'Loader.release.lua' },
];

// ── Utilitário HTTP (sem dependências externas) ──────────────────────────
function apiRequest(method, endpoint, body) {
  return new Promise((resolve, reject) => {
    const payload = body ? JSON.stringify(body) : null;
    const options = {
      hostname: 'api.github.com',
      path: endpoint,
      method,
      headers: {
        Authorization: `Bearer ${MIRROR_TOKEN}`,
        'User-Agent': 'hoc-noc-mirror/1.0',
        Accept: 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
        ...(payload && {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(payload),
        }),
      },
    };

    const req = https.request(options, (res) => {
      let raw = '';
      res.on('data', (chunk) => { raw += chunk; });
      res.on('end', () => {
        try { resolve({ status: res.statusCode, data: JSON.parse(raw) }); }
        catch { resolve({ status: res.statusCode, data: raw }); }
      });
    });

    req.on('error', reject);
    if (payload) req.write(payload);
    req.end();
  });
}

// ── Enviar um arquivo para o repo de destino ─────────────────────────────
async function pushFile(destPath, content) {
  const base64Content = Buffer.from(content).toString('base64');

  // Obter SHA atual do arquivo (se já existir)
  const getRes = await apiRequest(
    'GET',
    `/repos/${owner}/${repo}/contents/${destPath}?ref=${MIRROR_BRANCH}`,
  );
  const sha = getRes.status === 200 ? getRes.data.sha : undefined;

  const res = await apiRequest('PUT', `/repos/${owner}/${repo}/contents/${destPath}`, {
    message: `mirror: update ${destPath}`,
    content: base64Content,
    branch: MIRROR_BRANCH,
    ...(sha && { sha }),
  });

  if (res.status !== 200 && res.status !== 201) {
    throw new Error(`Falha ao enviar ${destPath}: ${JSON.stringify(res.data)}`);
  }

  console.log(`[Mirror] ${destPath} → ${MIRROR_REPO}@${MIRROR_BRANCH}`);
}

// ── Execução principal ────────────────────────────────────────────────────
(async () => {
  for (const file of files) {
    const srcPath = path.join(distDir, file.src);
    if (!fs.existsSync(srcPath)) {
      console.error(`[Mirror] Arquivo não encontrado: ${srcPath}`);
      process.exit(1);
    }
    const content = fs.readFileSync(srcPath);
    await pushFile(file.dest, content);
  }
  console.log('[Mirror] Concluído.');
})().catch((err) => {
  console.error('[Mirror] Erro:', err.message);
  process.exit(1);
});

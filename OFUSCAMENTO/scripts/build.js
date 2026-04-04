#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');

const settings = require('../modulos/settings.json');
const moduleOrder = require('../modulos/module-order.json');

const srcDir = path.resolve(__dirname, '..', 'src');
const distDir = path.resolve(__dirname, '..', 'dist');

if (!fs.existsSync(distDir)) {
  fs.mkdirSync(distDir, { recursive: true });
}

// ── Empacotar módulos na ordem definida em module-order.json ───────────────
let bundle = '';
for (const mod of moduleOrder) {
  const filePath = path.join(srcDir, mod);
  if (!fs.existsSync(filePath)) {
    console.error(`[Build] Módulo não encontrado: ${filePath}`);
    process.exit(1);
  }
  const content = fs.readFileSync(filePath, 'utf8');
  bundle += content + '\n';
  console.log(`[Build] Incluído: ${mod} (${content.length} bytes)`);
}

// ── Patch online: substitui readfile() por game:HttpGet() no bundle ───────
// Isso torna o script standalone quando carregado via HttpGet no executor.
const modulesBaseUrl =
  settings.modulesBaseUrl ||
  `https://raw.githubusercontent.com/${settings.distOwner}/${settings.distRepo}/${settings.distBranch}/Modules/`;

const readfileCall = 'return loadstring(readfile(BASE .. relPath))()';
const httpGetCall  =
  `return loadstring(game:HttpGet("${modulesBaseUrl}" .. relPath, true))()`;

if (bundle.includes(readfileCall)) {
  bundle = bundle.replace(readfileCall, httpGetCall);
  console.log('[Build] Patch HttpGet aplicado em loadModule.');
} else {
  console.warn('[Build] Aviso: padrão readfile não encontrado — bundle não foi alterado.');
}

// ── Bundle principal (pré-ofuscamento) ─────────────────────────────────────
const bundlePath = path.join(distDir, `${settings.scriptName}.release.lua`);
fs.writeFileSync(bundlePath, bundle);
console.log(`[Build] Bundle: ${bundlePath} (${bundle.length} bytes)`);

// ── Gerar Loader público ───────────────────────────────────────────────────
const version = process.env.GITHUB_REF_NAME || 'local';
const loader =
  `-- ${settings.scriptName} Loader ${version}\n` +
  `-- Gerado automaticamente. Nao edite manualmente.\n` +
  `loadstring(game:HttpGet("${settings.loaderUrl}", true))()\n`;

const loaderPath = path.join(distDir, 'Loader.release.lua');
fs.writeFileSync(loaderPath, loader);
console.log(`[Build] Loader: ${loaderPath}`);

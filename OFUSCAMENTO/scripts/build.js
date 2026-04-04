#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');

const settings = require('../modulos/settings.json');
const moduleOrder = require('../modulos/module-order.json');

const srcDir = path.resolve(__dirname, '..', 'src');
const distDir = path.resolve(__dirname, '..', 'dist');
const entryPath = path.join(srcDir, 'main.lua');

if (!fs.existsSync(distDir)) {
  fs.mkdirSync(distDir, { recursive: true });
}

if (!fs.existsSync(entryPath)) {
  console.error(`[Build] Entry principal nao encontrado: ${entryPath}`);
  process.exit(1);
}

function toLuaLongString(input) {
  let eqCount = 0;
  while (true) {
    const open = '[' + '='.repeat(eqCount) + '[';
    const close = ']' + '='.repeat(eqCount) + ']';
    if (!input.includes(close)) {
      return `${open}${input}${close}`;
    }
    eqCount += 1;
  }
}

// ── Leitura dos modulos na ordem oficial ───────────────────────────────────
const modules = [];
for (const relPath of moduleOrder) {
  const fullPath = path.join(srcDir, relPath);
  if (!fs.existsSync(fullPath)) {
    console.error(`[Build] Modulo nao encontrado: ${fullPath}`);
    process.exit(1);
  }
  const source = fs.readFileSync(fullPath, 'utf8');
  modules.push({ relPath, source });
  console.log(`[Build] Incluido: ${relPath} (${source.length} bytes)`);
}

const moduleTable = [
  'local __HOC_MODULES = {',
  ...modules.map(({ relPath, source }) => `  [${JSON.stringify(relPath)}] = ${toLuaLongString(source)},`),
  '}',
  '',
].join('\n');

const embeddedLoadModule = [
  '-- Loader de modulos embutidos em memoria (sem readfile)',
  'local function loadModule(relPath)',
  '    local source = __HOC_MODULES[relPath]',
  '    if type(source) ~= "string" then',
  '        warn("[HOC NOC] Modulo ausente no bundle: " .. tostring(relPath))',
  '        return {}',
  '    end',
  '',
  '    local _L = loadstring or load',
  '    if type(_L) ~= "function" then',
  '        warn("[HOC NOC] Executor sem loadstring/load para modulo: " .. tostring(relPath))',
  '        return {}',
  '    end',
  '',
  '    local chunk, compileErr = _L(source)',
  '    if type(chunk) ~= "function" then',
  '        warn("[HOC NOC] Erro de compilacao no modulo " .. tostring(relPath) .. ": " .. tostring(compileErr))',
  '        return {}',
  '    end',
  '',
  '    local ok, result = pcall(chunk)',
  '    if not ok then',
  '        warn("[HOC NOC] Erro ao executar modulo " .. tostring(relPath) .. ": " .. tostring(result))',
  '        return {}',
  '    end',
  '    return result',
  'end',
].join('\n');

let mainSource = fs.readFileSync(entryPath, 'utf8');
const startMarker = 'local BASE = "HOC_NOC_Zoo/"';
const safeInvokeMarker = 'local function safeInvoke(label, fn)';

const startIdx = mainSource.indexOf(startMarker);
const safeInvokeIdx = mainSource.indexOf(safeInvokeMarker);

if (startIdx !== -1 && safeInvokeIdx !== -1 && safeInvokeIdx > startIdx) {
  const before = mainSource.slice(0, startIdx);
  const after = mainSource.slice(safeInvokeIdx);
  mainSource = `${before}${embeddedLoadModule}\n\n${after}`;
  console.log('[Build] Patch de loadModule embutido aplicado.');
} else {
  console.error('[Build] Nao foi possivel localizar o bloco loadModule em main.lua.');
  process.exit(1);
}

const bundle = `${moduleTable}${mainSource}`;

// ── Bundle principal (pré-ofuscamento) ─────────────────────────────────────
const bundlePath = path.join(distDir, `${settings.scriptName}.release.lua`);
fs.writeFileSync(bundlePath, bundle);
console.log(`[Build] Bundle: ${bundlePath} (${bundle.length} bytes)`);

// ── Gerar Loader público ───────────────────────────────────────────────────
const version = process.env.GITHUB_REF_NAME || 'local';
const loader =
  `-- ${settings.scriptName} Loader ${version}\n` +
  `-- Gerado automaticamente. Nao edite manualmente.\n` +
  `local __SRC = game:HttpGet("${settings.loaderUrl}", true)\n` +
  `local __L = loadstring or load\n` +
  `assert(type(__L) == "function", "[HOC NOC] Executor sem loadstring/load")\n` +
  `local __F, __E = __L(__SRC)\n` +
  `assert(type(__F) == "function", "[HOC NOC] Compile error: " .. tostring(__E))\n` +
  `__F()\n`;

const loaderPath = path.join(distDir, 'Loader.release.lua');
fs.writeFileSync(loaderPath, loader);
console.log(`[Build] Loader: ${loaderPath}`);

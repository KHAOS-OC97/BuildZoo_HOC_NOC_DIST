#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');

const settings = require('../modulos/settings.json');

const distDir = path.resolve(__dirname, '..', 'dist');
const inputPath = path.join(distDir, `${settings.scriptName}.release.lua`);
const outputPath = path.join(distDir, `${settings.scriptName}.release.obf.lua`);

if (!fs.existsSync(inputPath)) {
  console.error(`[Obfuscate] Arquivo não encontrado: ${inputPath}. Execute o build primeiro.`);
  process.exit(1);
}

let source = fs.readFileSync(inputPath, 'utf8');

// ── Minificação via luamin (fallback para strip básico) ───────────────────
let minified = source;
try {
  const luamin = require('luamin');
  minified = luamin.minify(source);
  console.log('[Obfuscate] luamin minify aplicado.');
} catch (e) {
  console.warn('[Obfuscate] luamin falhou, usando minificação básica:', e.message);
  minified = source
    .replace(/--\[\[[\s\S]*?\]\]/g, '')  // remove comentários de bloco
    .replace(/--[^\n]*/g, '')             // remove comentários de linha
    .replace(/\n\s*\n/g, '\n')
    .trim();
}

// ── Wrapping em loadstring + base64 ──────────────────────────────────────
const encoded = Buffer.from(minified).toString('base64');

// Decoder Lua (single-line) + executor
const obfuscated =
  `local _B='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';` +
  `local function _D(s)` +
  `s=s:gsub('[^'.._B..'=]','');` +
  `return(s:gsub('.',function(c)` +
  `if c=='='then return''end;` +
  `local r,f='',_B:find(c,1,true)-1;` +
  `for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and'1'or'0')end;` +
  `return r` +
  `end):gsub('%d%d%d%d%d%d%d%d',function(x)` +
  `local n=0;` +
  `for i=1,8 do n=n+(x:sub(i,i)=='1'and 2^(8-i)or 0)end;` +
  `return string.char(n)` +
  `end))end;` +
  `load(_D("${encoded}"))()`;

fs.writeFileSync(outputPath, obfuscated);
console.log(`[Obfuscate] Saída: ${outputPath} (${obfuscated.length} bytes)`);

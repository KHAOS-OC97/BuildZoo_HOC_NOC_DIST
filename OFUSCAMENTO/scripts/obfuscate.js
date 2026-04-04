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

const source = fs.readFileSync(inputPath, 'utf8');
const encoded = Buffer.from(source).toString('base64');

// ── Decoder Lua puro (sem dependência externa) + executor ────────────────
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

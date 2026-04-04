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

// Mantem compatibilidade total com executores: publica o bundle direto.
// Se quiser voltar a ofuscar depois, podemos trocar por uma estrategia mais segura.
const output =
  `-- HOC_NOC release (compat mode)\n` +
  `-- Gerado por obfuscate.js sem wrapper base64 para evitar runtime nil em executores\n` +
  source;

fs.writeFileSync(outputPath, output);
console.log(`[Obfuscate] Saída: ${outputPath} (${output.length} bytes)`);

#!/usr/bin/env node

import fs from 'node:fs/promises';
import process from 'node:process';

const auditPath = optionValue('--audit-json') ?? 'tool/hotel_catalog_audit.json';
const model = optionValue('--model') ?? 'gpt-4.1-mini';

const audit = JSON.parse(await fs.readFile(auditPath, 'utf8'));
const fallback = deterministicSummary(audit);

if (!process.env.OPENAI_API_KEY) {
  console.log(fallback);
  console.log('\nOPENAI_API_KEY is not set; skipped optional LangChain summary.');
  process.exit(0);
}

let ChatOpenAI;
try {
  ({ ChatOpenAI } = await import('@langchain/openai'));
} catch {
  console.log(fallback);
  console.log(
    '\nOptional LangChain packages are not installed. To enable this review, run: npm install @langchain/openai',
  );
  process.exit(0);
}

const context = retrieveAuditContext(audit);
const llm = new ChatOpenAI({ model, temperature: 0 });
const response = await llm.invoke([
  {
    role: 'system',
    content:
      'You review Toyoko Inn hotel-catalog sync diffs. Use only the retrieved context. Do not invent hotel codes or statuses.',
  },
  {
    role: 'user',
    content: `Retrieved context:\n${context}\n\nSummarize the sync diff for a maintainer in Traditional Chinese. Include risks and recommended manual spot checks.`,
  },
]);

console.log(response.content);

function optionValue(name) {
  for (let i = 2; i < process.argv.length; i += 1) {
    const arg = process.argv[i];
    if (arg === name && i + 1 < process.argv.length) return process.argv[i + 1];
    if (arg.startsWith(`${name}=`)) return arg.slice(name.length + 1);
  }
  return undefined;
}

function deterministicSummary(data) {
  const groups = [
    ['added', data.added],
    ['removed', data.removed],
    ['renamed', data.renamed],
    ['moved', data.moved],
    ['statusChanged', data.statusChanged],
    ['detailsChanged', data.detailsChanged],
    ['unmatchedLocation', data.unmatchedLocation],
  ];
  const lines = [
    `Source: ${data.sourceUrl}`,
    `Hotel count: ${data.hotelCount}`,
    `Has changes: ${data.hasChanges}`,
  ];
  for (const [label, values] of groups) {
    lines.push(`${label}: ${values?.length ?? 0}`);
  }
  return lines.join('\n');
}

function retrieveAuditContext(data) {
  const chunks = [
    deterministicSummary(data),
    formatHotels('Added hotels', data.added),
    formatHotels('Removed hotels', data.removed),
    formatHotels('Renamed hotels', data.renamed),
    formatHotels('Moved hotels', data.moved),
    formatHotels('Status changes', data.statusChanged),
    formatHotels('Unmatched locations', data.unmatchedLocation),
  ].filter(Boolean);
  return chunks.join('\n\n---\n\n');
}

function formatHotels(title, hotels = []) {
  if (!hotels.length) return '';
  const rows = hotels
    .slice(0, 80)
    .map((hotel) => {
      const parts = [
        hotel.code,
        hotel.name,
        hotel.appLocation,
        hotel.prefecture,
        hotel.status,
      ].filter(Boolean);
      return `- ${parts.join(' | ')}`;
    })
    .join('\n');
  return `${title}\n${rows}`;
}

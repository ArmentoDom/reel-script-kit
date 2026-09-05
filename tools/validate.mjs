#!/usr/bin/env node
/**
 * Zero-dependency validator for the JSON Schema subset this kit uses.
 * No npm install, ever. Supports: type, required, properties, items,
 * enum, minLength, minItems, minimum, maximum.
 *
 * Usage:
 *   node tools/validate.mjs voice   [path]
 *   node tools/validate.mjs corpus  [path]
 *   node tools/validate.mjs script  <path>
 *   node tools/validate.mjs all
 */
import { readFileSync, existsSync, readdirSync } from "node:fs";
import { join, dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const DEFAULTS = { voice: "voice/voice.json", corpus: "corpus/corpus.json" };

const typeOf = (v) =>
  v === null ? "null" : Array.isArray(v) ? "array" : typeof v === "number" ? "number" : typeof v;

function validate(node, schema, path, errs) {
  if (!schema || typeof schema !== "object") return;

  if (schema.type) {
    const actual = typeOf(node);
    const want = schema.type === "integer" ? "number" : schema.type;
    if (actual !== want) {
      errs.push(`${path || "<root>"}: expected ${schema.type}, got ${actual}`);
      return; // stop descending; every child error would be noise
    }
  }

  if (schema.enum && !schema.enum.includes(node)) {
    errs.push(`${path}: ${JSON.stringify(node)} is not one of ${schema.enum.join(", ")}`);
  }

  if (typeOf(node) === "string") {
    if (schema.minLength != null && node.trim().length < schema.minLength) {
      errs.push(`${path}: needs at least ${schema.minLength} characters (has ${node.trim().length})`);
    }
  }

  if (typeOf(node) === "number") {
    if (schema.minimum != null && node < schema.minimum) errs.push(`${path}: ${node} is below minimum ${schema.minimum}`);
    if (schema.maximum != null && node > schema.maximum) errs.push(`${path}: ${node} is above maximum ${schema.maximum}`);
  }

  if (typeOf(node) === "array") {
    if (schema.minItems != null && node.length < schema.minItems) {
      errs.push(`${path}: needs at least ${schema.minItems} item(s) (has ${node.length})`);
    }
    if (schema.items) node.forEach((item, i) => validate(item, schema.items, `${path}[${i}]`, errs));
  }

  if (typeOf(node) === "object") {
    for (const key of schema.required || []) {
      if (!(key in node)) errs.push(`${path ? path + "." : ""}${key}: required field is missing`);
    }
    for (const [key, sub] of Object.entries(schema.properties || {})) {
      if (key in node) validate(node[key], sub, `${path ? path + "." : ""}${key}`, errs);
    }
  }
}

function check(kind, file) {
  const schemaPath = join(ROOT, "schemas", `${kind}.schema.json`);
  if (!existsSync(schemaPath)) return { kind, file, ok: false, errs: [`no schema for "${kind}"`] };
  if (!existsSync(file)) return { kind, file, ok: false, missing: true, errs: [`file not found: ${file}`] };

  let data, schema;
  try {
    schema = JSON.parse(readFileSync(schemaPath, "utf8"));
  } catch (e) {
    return { kind, file, ok: false, errs: [`schema is not valid JSON: ${e.message}`] };
  }
  try {
    data = JSON.parse(readFileSync(file, "utf8"));
  } catch (e) {
    return { kind, file, ok: false, errs: [`not valid JSON: ${e.message}`] };
  }

  const errs = [];
  validate(data, schema, "", errs);
  return { kind, file, ok: errs.length === 0, errs };
}

function report(r) {
  const rel = r.file.replace(ROOT + "/", "");
  if (r.ok) {
    console.log(`  ok    ${r.kind.padEnd(7)} ${rel}`);
  } else {
    console.log(`  FAIL  ${r.kind.padEnd(7)} ${rel}`);
    for (const e of r.errs) console.log(`          - ${e}`);
  }
  return r.ok;
}

const [kind, argPath] = process.argv.slice(2);

if (!kind || kind === "-h" || kind === "--help") {
  console.log("usage: node tools/validate.mjs <voice|corpus|script|all> [path]");
  process.exit(2);
}

console.log("");
let allOk = true;

if (kind === "all") {
  for (const k of ["voice", "corpus"]) {
    const r = check(k, join(ROOT, DEFAULTS[k]));
    if (r.missing) {
      console.log(`  --    ${k.padEnd(7)} ${DEFAULTS[k]} (not created yet)`);
      allOk = false;
    } else {
      allOk = report(r) && allOk;
    }
  }
  const projects = join(ROOT, "projects");
  if (existsSync(projects)) {
    for (const slug of readdirSync(projects)) {
      const s = join(projects, slug, "script.json");
      if (existsSync(s)) allOk = report(check("script", s)) && allOk;
    }
  }
} else {
  const file = argPath ? resolve(argPath) : join(ROOT, DEFAULTS[kind] || "");
  allOk = report(check(kind, file));
}

console.log("");
process.exit(allOk ? 0 : 1);

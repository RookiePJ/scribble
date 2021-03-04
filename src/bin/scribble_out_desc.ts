#!/usr/bin/env node
import { spawnSync } from "child_process";
import fse from "fs-extra";

type SourceMap = [number, number, number];

function scribble(fileName: string | string[], ...options: string[]): string {
    const procArgs = (fileName instanceof Array ? fileName : [fileName]).concat(options);
    const procResult = spawnSync("scribble", procArgs, { encoding: "utf8" });

    if (procResult.stderr) {
        throw new Error(procResult.stderr);
    }

    if (procResult.status !== 0) {
        throw new Error("Non-zero exit code: " + procResult.status);
    }

    return procResult.stdout;
}

function parseSourceMap(src: string): SourceMap {
    return src.split(":").map((v) => Number.parseInt(v)) as SourceMap;
}

function getFragmentBySourceMap(source: string, src: SourceMap): string {
    const [offset, length] = src;

    return source.substr(offset, length);
}

const [fileName] = process.argv.slice(2);

if (!fse.existsSync(fileName)) {
    throw new Error("File not exists: " + fileName);
}

const original = fse.readFileSync(fileName, { encoding: "utf8" });

const separator40 = "-".repeat(40);
const separator80 = separator40.repeat(2);

console.log(separator80);
console.log("INPUT");
console.log(separator80);
console.log(fileName);
console.log(separator80);
console.log(original);
console.log(separator80);

const result = scribble(fileName, "-m", "json", "-o", "--");
const json = JSON.parse(result);
const instrumented = json.sources["flattened.sol"].source;
const meta = json.instrumentationMetadata;

console.log("INSTRUMENTATION");
console.log(separator80);
console.log(instrumented);
console.log(separator80);

console.log("META");
console.log(separator80);
console.log(JSON.stringify(meta, undefined, 4));
console.log(separator80);

console.log();
console.log("SOURCE-TO-SOURCE MAPPING (ORIGINAL -> INSTRUMENTED)");
console.log(separator80);

for (const [instrSrc, origSrc] of meta.instrToOriginalMap) {
    const instrFragment = getFragmentBySourceMap(instrumented, parseSourceMap(instrSrc));
    const origFragment = getFragmentBySourceMap(original, parseSourceMap(origSrc));

    console.log(origSrc + " -> " + instrSrc);
    console.log(separator40);

    if (instrFragment === origFragment) {
        console.log(instrFragment);
    } else {
        console.log(origFragment);
        console.log(separator40);
        console.log(instrFragment);
    }

    console.log(separator80);
}

console.log();
console.log("OTHER INSTRUMENTATION");
console.log(separator80);

for (const otherSrc of meta.otherInstrumentation) {
    const otherFragment = getFragmentBySourceMap(instrumented, parseSourceMap(otherSrc));

    console.log(otherSrc);
    console.log(separator40);
    console.log(otherFragment);
    console.log(separator80);
}

console.log();
console.log("PROPERTIES");
console.log(separator80);

for (const entry of meta.propertyMap) {
    console.log("ID: " + entry.id);
    console.log("CONTRACT: " + entry.contract);
    console.log("TARGET: " + entry.target + " " + entry.targetName);
    console.log("MESSAGE: " + entry.message);

    console.log(separator40);
    console.log("PREDICATE");
    console.log(separator40);
    console.log(getFragmentBySourceMap(original, parseSourceMap(entry.propertySource)));
    console.log(separator40);
    console.log("ANNOTATION");
    console.log(separator40);
    console.log(getFragmentBySourceMap(original, parseSourceMap(entry.annotationSource)));
    console.log(separator40);

    console.log("INSTRUMENTATION RANGES");
    console.log(separator40);

    for (const src of entry.instrumentationRanges) {
        console.log(getFragmentBySourceMap(instrumented, parseSourceMap(src)));
        console.log(separator40);
    }

    console.log("CHECK RANGES");
    console.log(separator40);

    for (const src of entry.checkRanges) {
        console.log(getFragmentBySourceMap(instrumented, parseSourceMap(src)));
        console.log(separator40);
    }

    console.log(separator80);
}

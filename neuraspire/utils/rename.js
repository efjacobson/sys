#!/usr/bin/node

const fs = require('fs');
const path = require('path');
const readline = require("readline");
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

const SHOW = "Bob's Burgers";

const absolute = (f) => `${path.dirname(f)}/${path.basename(f)}`

const renames = [];
const rename = (fileOrDir) => {
    if (fs.lstatSync(fileOrDir).isDirectory()) {
        fs.readdirSync(fileOrDir).forEach((f) => {
            rename(`${absolute(fileOrDir)}/${f}`);
        });
        return;
    }
    const renamed = `${path.dirname(absolute(fileOrDir))}/${SHOW} - ${path.basename(fileOrDir).replace(/S(\d+?)E(\d+?)/, 's$1e$2')}`;
    renames.push({
        original: path.basename(fileOrDir),
        renamed: path.basename(renamed),
        fn: () => fs.renameSync(absolute(fileOrDir), renamed),
    });
}

rename(process.argv[2]);

renames.forEach((r) => {
    console.log(`${r.original} -> ${r.renamed}`);
});

rl.question("apply the above? [y/N] ", function(answer) {
    if (answer === 'y') {
        renames.forEach((r) => {
            r.fn();
        });
    }
    rl.close();
});
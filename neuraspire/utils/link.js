#!/usr/bin/node

const fs = require('fs');
const path = require('path');

const absolute = (f) => `${path.dirname(f)}/${path.basename(f)}`

const link = (fileOrDir) => {
    if (fs.lstatSync(fileOrDir).isDirectory()) {
        fs.readdirSync(fileOrDir).forEach((f) => {
            link(`${absolute(fileOrDir)}/${f}`);
        });
        return;
    }
    const linked = `${path.dirname(fileOrDir)}/${path.basename(fileOrDir).replace(new RegExp(`${path.extname(fileOrDir)}$`), `.lnk${path.extname(fileOrDir)}`)}`;
    fs.linkSync(fileOrDir, linked);
}

link(process.argv[2]);
#!/usr/bin/node

import path from 'path';
import { existsSync } from 'node:fs';
import readline from 'node:readline';
import { readdir, rename, realpath } from 'node:fs/promises';

const src = process.argv[2];

if (typeof src === 'undefined' || !existsSync(src)) {
  console.log('enter a valid src dir');
  process.exit(1);
}

const onFilePaths = async (dir, onFilePath) => {
  const dirEnts = await readdir(dir, { withFileTypes: true });
  return await Promise.all(
    dirEnts.map((dirEnt) => {
      if (!dirEnt.isDirectory()) {
        return onFilePath(`${dir}/${dirEnt.name}`);
      }
      return onFilePaths(`${dir}/${dirEnt.name}`, onFilePath);
    })
  );
};

const agree = (prompt) =>
  new Promise((resolve) => {
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });
    rl.question(prompt, (answer) => {
      rl.close();
      resolve(/^[Yy](es)?$/.test(answer));
    });
  });

(async () => {
  const rp = await realpath(src);
  const show = rp.split('/').pop();
  let example;
  console.log('rp: ', rp);
  console.log('show: ', show);
  const results = await onFilePaths(rp, async (filePath) => {
    let episode = filePath.split('/').pop();
    if (/^S\d+?E\d+?\s-/.test(episode)) {
      episode = episode.replace(/^S/, 's');
      episode = episode.replace(/^(s\d+?)E/, '$1e');
    }
    if (!episode.startsWith(show)) {
      episode = `${show} - ${episode}`;
    }
    example = episode;
    return {
      episode,
      promise: () => {
        console.log(`renaming ${filePath.split('/').pop()} to ${episode}`);
        rename(filePath, `${path.dirname(filePath)}/${episode}`);
      }
    };
  });
  if (results.length < 1) {
    return;
  }
  if (!(await agree(`rename all episodes of ${show}? example: ${example}`))) {
    return;
  }
  await Promise.all(
    results.map((season) => season.map(({ promise }) => promise())),
    []
  );
})();

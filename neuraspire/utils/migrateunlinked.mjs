#!/usr/bin/node

import fs from "fs";
import path from "path";
import { existsSync } from "node:fs";
import { readdir, rm } from "node:fs/promises";

const src = process.argv[2];
const dest = process.argv[3];

if (
  typeof src === "undefined" ||
  typeof dest === "undefined" ||
  !existsSync(src) ||
  !existsSync(dest)
) {
  console.log("enter src and destination dirs");
  process.exit(1);
}

const traverseDir = async (dir) => {
  console.log("traverseDir src: ", dir);
  // console.log('traverseDir stack: ', stack);?
  const dirEnts = await readdir(dir, { withFileTypes: true });
  return await Promise.all(
    dirEnts.map((dirEnt) => {
      if (!dirEnt.isDirectory()) {
        if (/^[Ss]ample/.test(dirEnt.name)) {
          return rm(`${dir}/${dirEnt.name}`);
        }
        const split = dirEnt.name.split(".");
        const ext = split.pop();
        if (ext === "torrent") {
          if (split.pop() === "lnk") {
            return rm(`${dir}/${dirEnt.name}`);
          }
          return dirEnt.name;
        }
        if (split.pop() === "lnk" && split.pop() === "lnk") {
          return rm(`${dir}/${dirEnt.name}`);
        }
        switch (ext) {
          case "jpg":
          case "exe":
          case "txt":
          case "nfo":
          case "png":
            return rm(`${dir}/${dirEnt.name}`);
          default:
            console.log(ext);
            return dirEnt.name;
        }
      }
      return traverseDir(`${dir}/${dirEnt.name}`);
    })
  );
  // const files = [];
  // for (const dirEnt of dirEnts) {
  //     if (dirEnt.isDirectory()) {
  //         console.log('isDirectory dirEnt:', dirEnt);
  //         await traverseDir(`${dir}/${dirEnt.name}`, [ ...stack, dir ]);
  //     } else {
  //         console.log('file dirEnt:', dirEnt);
  //     }
  // }
  // return files;
};

(async () => {
  console.log("src: ", src);
  const dirEnts = await traverseDir(src);
  // console.log(dirEnts);
  process.exit(0);
})();

// const absolute = (f) => `${path.dirname(f)}/${path.basename(f)}`

// const link = (fileOrDir) => {
//     if (fs.lstatSync(fileOrDir).isDirectory()) {
//         fs.readdirSync(fileOrDir).forEach((f) => {
//             link(`${absolute(fileOrDir)}/${f}`);
//         });
//         return;
//     }
//     const linked = `${path.dirname(fileOrDir)}/${path.basename(fileOrDir).replace(new RegExp(`${path.extname(fileOrDir)}$`), `.lnk${path.extname(fileOrDir)}`)}`;
//     fs.linkSync(fileOrDir, linked);
// }

// link(process.argv[2]);

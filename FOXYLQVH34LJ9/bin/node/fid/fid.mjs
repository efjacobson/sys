import { access, readFile, readdir, writeFile } from 'fs/promises';
import { basename, dirname } from 'path';
import { parseStringPromise as parseXml, Builder as XmlBuilder } from 'xml2js';
  
const sourceFolders = [
  {
    url: 'file://$MODULE_DIR$/src',
    isTestSource: 'false',
    packagePrefix: 'App\\',
  },
  {
    url: 'file://$MODULE_DIR$/tests',
    isTestSource: 'true',
    packagePrefix: 'App\\Tests\\',
  },
  {
    url: 'file://$MODULE_DIR$/vendor/gdbots',
    isTestSource: 'false',
  },
  {
    url: 'file://$MODULE_DIR$/vendor/triniti',
    isTestSource: 'false',
  },
];

const excludeFolders = [
  'file://$MODULE_DIR$/vendor/gdbots/schemas',
  'file://$MODULE_DIR$/vendor/triniti/schemas',
  'file://$MODULE_DIR$/var',
];

async function parseConfig(configFile) {
  const repoDir = dirname(dirname(configFile));
  const repo = basename(repoDir);
  if (!/(tmz|toofab)-(web|api|feeds|share|amp)/.test(repo)) {
    console.log(`Invalid repo: ${repo}`);
    return;
  }

  const vendor = repo.split('-')[0];
  sourceFolders.push({
    url: `file://$MODULE_DIR$/vendor/${vendor}`,
    isTestSource: 'false',
  });

  excludeFolders.push(`file://$MODULE_DIR$/vendor/${vendor}/schemas`);

  const data = await readFile(configFile, 'utf8');
  const parsed = await parseXml(data);
  for (const component of parsed.module.component) {
    for (const content of component.content) {
      content.sourceFolder = sourceFolders.map((sourceFolder) => ({ '$': sourceFolder }));
      content.excludeFolder = excludeFolders.map((excludeFolder) => ({ '$': { url: excludeFolder } }));

      if (await exists(`${repoDir}/public`)) {
        content.excludeFolder.push({
          '$': {
            url: 'file://$MODULE_DIR$/public/client',
          },
        });
      }

      if (!await exists(`${repoDir}/vendor`)) {
        continue;
      }

      const dependencies = await readdir(`${repoDir}/vendor`);
      for (const dependency of dependencies) {
        if (dependency === vendor) {
          continue;
        }
        if (!/^(gdbots|triniti)$/.test(dependency)) {
          content.excludeFolder.push({
            '$': {
              url: `file://$MODULE_DIR$/vendor/${dependency}`,
            },
          });
        }
      }
    }
  }

  const xml = (new XmlBuilder()).buildObject(parsed);
  await writeFile(configFile, xml, 'utf8');
}

async function exists(path) {
  try {
    await access(path);
    return true;
  } catch {
    return false;
  }
}

(async () => {
  const configFile = process.argv[2];
  if (!configFile || configFile === '') {
    console.log('you need to provide a config file path');
    return;
  }
  if (!await exists(configFile)) {
    console.log(`file ${configFile} does not exist`);
    return;
  }
  await parseConfig(configFile);
})();

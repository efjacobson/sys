import fs from 'fs';
import path from 'path';
import { DOMParser, XMLSerializer } from 'xmldom';

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
];

function parseConfig(configFile) {
  const repoDir = path.dirname(path.dirname(configFile));
  const repo = path.basename(repoDir);
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

  fs.readFile(configFile, 'utf8', (err, data) => {
    if (err) {
      console.error(err);
      return;
    }

    const doc = new DOMParser().parseFromString(data, 'application/xml');
    const components = doc.getElementsByTagName('component');

    for (let i = 0; i < components.length; i++) {
      const component = components[i];
      const contents = component.getElementsByTagName('content');

      for (let j = 0; j < contents.length; j++) {
        const content = contents[j];

        // Remove existing sourceFolder and excludeFolder elements
        const sourceFolders = content.getElementsByTagName('sourceFolder');
        while (sourceFolders.length > 0) {
          content.removeChild(sourceFolders[0]);
        }

        const excludeFolders = content.getElementsByTagName('excludeFolder');
        while (excludeFolders.length > 0) {
          content.removeChild(excludeFolders[0]);
        }

        // Add new sourceFolder elements
        sourceFolders.forEach(sourceFolder => {
          const el = doc.createElement('sourceFolder');
          el.setAttribute('url', sourceFolder.url);
          el.setAttribute('isTestSource', sourceFolder.isTestSource);
          if (sourceFolder.packagePrefix) {
            el.setAttribute('packagePrefix', sourceFolder.packagePrefix);
          }
          content.appendChild(el);
        });

        // Add new excludeFolder elements
        const varExclude = doc.createElement('excludeFolder');
        varExclude.setAttribute('url', 'file://$MODULE_DIR$/var');
        content.appendChild(varExclude);

        if (fs.existsSync(`${repoDir}/public`)) {
          const publicExclude = doc.createElement('excludeFolder');
          publicExclude.setAttribute('url', 'file://$MODULE_DIR$/public/client');
          content.appendChild(publicExclude);
        }

        if (!fs.existsSync(`${repoDir}/vendor`)) {
          continue;
        }

        excludeFolders.forEach(excludeFolder => {
          const el = doc.createElement('excludeFolder');
          el.setAttribute('url', excludeFolder);
          content.appendChild(el);
        });

        fs.readdirSync(`${repoDir}/vendor`).forEach(dependency => {
          if (dependency === vendor) {
            return;
          }
          if (!/(gdbots|triniti)/.test(dependency)) {
            const el = doc.createElement('excludeFolder');
            el.setAttribute('url', `file://$MODULE_DIR$/vendor/${dependency}`);
            content.appendChild(el);
          }
        });
      }
    }

    const xml = new XMLSerializer().serializeToString(doc);
    fs.writeFile(configFile, xml, 'utf8', err => {
      if (err) {
        console.error(err);
      }
    });
  });
}

function main() {
  const configFile = process.argv[2];
  if (!fs.existsSync(configFile)) {
    console.log('file does not exist');
    return;
  }
  parseConfig(configFile);
}

main();
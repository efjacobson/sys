#!/usr/bin/env pipenv run python

import sys
import os
import re
import xml.etree.ElementTree as ET

sourceFolders = [
    {
        'url': 'file://$MODULE_DIR$/src',
        'isTestSource': 'false',
        'packagePrefix': 'App\\',
    },
    {
        'url': 'file://$MODULE_DIR$/tests',
        'isTestSource': 'true',
        'packagePrefix': 'App\\Tests\\',
    },
    {
        'url': 'file://$MODULE_DIR$/vendor/gdbots',
        'isTestSource': 'false',
    },
    {
        'url': 'file://$MODULE_DIR$/vendor/triniti',
        'isTestSource': 'false',
    },
]

excludeFolders = [
    'file://$MODULE_DIR$/vendor/gdbots/schemas',
    'file://$MODULE_DIR$/vendor/triniti/schemas',
]

def parseConfig(configFile):
    repoDir = os.path.dirname(os.path.dirname(configFile))
    repo = os.path.basename(repoDir)
    if not (re.match(r"(tmz|toofab)-(web|api|feeds|share|amp)", repo)):
        print(f'Invalid repo: {repo}')
        return

    vendor = repo.split('-')[0]
    sourceFolders.append({
        'url': f'file://$MODULE_DIR$/vendor/{vendor}',
        'isTestSource': 'false',
    })

    excludeFolders.append(f'file://$MODULE_DIR$/vendor/{vendor}/schemas')
        
    tree = ET.parse(configFile)
    root = tree.getroot()
    for component in root.findall('component'):
        for content in component.findall('content'):
            for sourceFolder in content.findall('sourceFolder'):
                content.remove(sourceFolder)

            for excludeFolder in content.findall('excludeFolder'):
                content.remove(excludeFolder)

            for sourceFolder in sourceFolders:
                el = ET.SubElement(content, 'sourceFolder')
                el.set('url', sourceFolder['url'])
                el.set('isTestSource', sourceFolder['isTestSource'])
                if ('packagePrefix' in sourceFolder):
                    el.set('packagePrefix', sourceFolder['packagePrefix'])

            el = ET.SubElement(content, 'excludeFolder')
            el.set('url', 'file://$MODULE_DIR$/var')

            if (os.path.isdir(f'{repoDir}/public')):
                el = ET.SubElement(content, 'excludeFolder')
                el.set('url', 'file://$MODULE_DIR$/public/client')

            if not (os.path.isdir(f'{repoDir}/vendor')):
                continue

            for excludeFolder in excludeFolders:
                el = ET.SubElement(content, 'excludeFolder')
                el.set('url', excludeFolder)

            for dependency in os.listdir(f'{repoDir}/vendor'):
                if (dependency == vendor):
                    continue
                if not (re.match(r"(gdbots|triniti)", dependency)):
                    el = ET.SubElement(content, 'excludeFolder')
                    el.set('url', f'file://$MODULE_DIR$/vendor/{dependency}')

    ET.indent(tree, '  ')
    tree.write(configFile, encoding='utf-8', xml_declaration=True)

def main():
    if not os.path.isfile(sys.argv[1]):
        print('file does not exist')
        return
    parseConfig(sys.argv[1])

if __name__ == "__main__":
    main()
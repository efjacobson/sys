#!/usr/bin/node

const fs = require('fs');
const persistentFile = '/home/sphynx/scratch/invalidateState.json';

// const ksort = (inputObj) => Object.keys(inputObj).sort().reduce((obj, key) => {
//   obj[key] = inputObj[key];
//   return obj;
// }, {});

const vsort = (inputObj) => {
  const delimiter = 'DELIMITER'
  return Object.entries(inputObj).map((entry) => `${entry[1]}${delimiter}${entry[0]}`).sort().reduce((obj, vk) => {
    const key = vk.split(delimiter)[1];
    obj[key] = inputObj[key];
    return obj;
  }, {})
};

const getState = () => new Promise((resolve, reject) => {
  fs.readFile(persistentFile, 'utf8', (error, data) => {
    if (!error) {
      resolve(JSON.parse(data));
      return;
    }
    fs.writeFile(
      persistentFile,
      JSON.stringify({ ignored: {}, invalidated: {}, executions: 0 }),
      'utf8',
      (_error, _data) => {
        if (_error) {
          reject(_error)
        } else {
          return getState();
        }
      }
    );
  });
});

const setState = (data) => new Promise((resolve) => {
  fs.writeFile(
    persistentFile,
    JSON.stringify(data),
    'utf8',
    (_error, _data) => {
      if (_error) {
        reject(_error)
      } else {
        resolve();
      }
    }
  );
});

const main = async () => {
  let state = await getState();
  state.executions += 1;
  if (process.argv.length < 2) {
    await setState(state);
    await log();
    return;
  }
  const match = process.argv[2].match(/GET\s\/.+?\s/);
  if (!Array.isArray(match)) {
    await setState(state);
    await log();
    return;
  }
  let url = match[0].replace(/^GET\s/, '').trim();
  if ('string' === typeof (state.ignored[url] || state.invalidated[url])) {
    await setState(state);
    await log();
    return;
  }
  const key = process.argv[2]
    .replace(/\s/g, '|')
    .replace(/^.+?\|/, '')
    .replace(/\|\[.+?Oct.+?\]\|/, '|datestuff|');
  if (/(^\/(_|%5f)\/promotion|\.html$)/.test(url)) {
    state.ignored[key] = url;
    state.ignored = vsort(state.ignored);
  } else {
    const split = url.split('/');
    if ('' !== split[split.length - 1]) {
      split.push('');
    }
    state.invalidated[key] = {
      callerReference: split.join('/').replace(/\/$/, '*'),
      url,
    };
    state.invalidated = vsort(state.invalidated);
  }
  await setState(state);
  await log(url);
};

const log = async (url = null) => {
  const state = await getState();
  if (null !== url && state.executions % 500 === 10) {
    const ignoredCount = Object.keys(state.ignored).length;
    const invalidatedCount = Object.keys(state.invalidated).length;
    console.log({
      ignored: {
        ...state.ignored,
        count: ignoredCount,
      },
      invalidated: {
        ...state.invalidated,
        count: invalidatedCount,
      },
      executions: {
        total: state.executions,
        delta: state.executions - ignoredCount - invalidatedCount,
        latest: process.argv[2],
      },
    });
    console.log(`safe to quit at ${new Date().toLocaleString()}`);
  } else if (!url && state.executions % 50 === 0) {
    console.log(`early return, total executions: ${state.executions}`);
    console.log(`safe to quit at ${new Date().toLocaleString()}`);
  }
}

main();

// aws logs tail /tmz-web/prod --profile wb-tmz --region us-east-1 --since 1s --follow --filter-pattern 'GET "200 -"' | xargs -d '\n' -n1 ~/dev/git/efjacobson/sys/NeurAspire/bin/js/invalidate.js

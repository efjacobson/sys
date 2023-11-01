#!/usr/bin/node

import crypto from 'crypto';

(() => {
  const uuidv4 = crypto.randomUUID();
  console.log(uuidv4);
})()

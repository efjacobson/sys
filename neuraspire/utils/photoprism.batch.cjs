(() => {
  if (window.pp?.batchEdit) {
    return window.pp.batchEdit();
  }

  const waitFor = (getter, config = { tries: 0, delay: 500 }) =>
    new Promise((resolve) => {
      if (config.tries > 0) {
        const target = getter();
        if (typeof target !== 'undefined') {
          resolve(target);
        }
      }
      setTimeout(() => {
        resolve(
          waitFor(getter, { tries: config.tries + 1, delay: config.delay * 2 })
        );
      }, config.delay);
    });

  const doLabel = async ({ id, labels = { add: [], remove: [] } }) => {
    const labelsTab = await waitFor(() => document.getElementById('tab-labels'));
    if (!labelsTab.classList.contains('v-tabs__item--active')) {
      labelsTab.children[0].click();
    }
    const existingLabels = [];
    const actualLabelsTab = await waitFor(() => document.querySelector('.p-tab-photo-labels'));
    for (const tr of actualLabelsTab.querySelector('tbody').querySelectorAll('tr')) {
      const existingLabel = tr.children[0].innerText;
      if (existingLabel !== 'No labels found') {
        existingLabels.push(existingLabel.toLowerCase());
      }
    }
    console.log(`${id} existingLabels: ${existingLabels}`);
    const inputLabel = await waitFor(() =>
      actualLabelsTab.querySelector('.input-label')
    );
    const input = await waitFor(() => inputLabel.querySelector('input'));
    for (let i = 0; i < labels.add?.length || 0; i += 1) {
      const addLabel = labels.add[i];
      if (existingLabels.includes(addLabel)) {
        continue;
      }
      console.log(`${id} adding label: ${addLabel}`);
      input.value = addLabel;
      input.dispatchEvent(new Event('change'));
      input.dispatchEvent(new Event('keydown'));
      input.dispatchEvent(new Event('keyup'));
      input.dispatchEvent(new Event('input'));
      (await waitFor(() => actualLabelsTab.querySelector('button.p-photo-label-add'))).click();
      await waitFor(() => {
        for (const tr of actualLabelsTab.querySelector('tbody').querySelectorAll('tr')) {
          const existingLabel = tr.children[0].innerText;
          if (existingLabel.toLowerCase() === addLabel) {
            return true;
          }
        }
      });
    }
    for (let i = 0; i < labels.remove?.length; i += 1) {
      const removeLabel = labels.remove[i];
      if (!existingLabels.includes(removeLabel)) {
        continue;
      }
      console.log(`${id} removing label: ${removeLabel}`);
      const row = await waitFor(() => {
        for (const tr of actualLabelsTab.querySelector('tbody').querySelectorAll('tr')) {
          const existingLabel = tr.children[0].innerText;
          if (existingLabel.toLowerCase() === removeLabel) {
            return tr;
          }
        }
      });
      (await waitFor(() => row.querySelector('.action-delete') || row.querySelector('.action-remove'))).click();
      await waitFor(() => {
        for (const tr of actualLabelsTab.querySelector('tbody').querySelectorAll('tr')) {
          const existingLabel = tr.children[0].innerText;
          if (existingLabel.toLowerCase() === removeLabel) {
            return false;
          }
        }
        return true;
      });
    }
  };

  if (!window.pp) {
    window.pp = {};
  }
  window.pp.batchEdit = async (config = window.pp.config || {}) => {
    const clipboard = document.getElementById('t-clipboard');
    if (!clipboard) {
      return window.alert('none selected!');
    }
    clipboard.click();
    (await waitFor(() => document.querySelector('button.action-edit'))).click();

    if (!document.querySelector('.p-tab-photo-advanced')) {
      (await waitFor(() => document.querySelector('#tab-info'))).querySelector('a').click();
    }
    let doNext = true;
    let nextButton;
    let id = (await waitFor(() => document.querySelector('.p-tab-photo-advanced'))).querySelector('tr').children[1].innerText;
    do {
      await doLabel({ id, labels: config.labels });
      nextButton = nextButton || document.querySelector('button.action-next');

      if (!nextButton || nextButton.hasAttribute('disabled')) {
        doNext = false;
      } else {
        nextButton.click();
        id = await waitFor(() => {
          const newId = document
            .querySelector('.p-tab-photo-advanced')
            .querySelector('tr').children[1].innerText;
          if (newId !== id) {
            return newId;
          }
        });
      }
    } while (doNext);

    (await waitFor(() => document.querySelector('.action-close'))).click();
    (await waitFor(() => document.getElementById('t-clipboard'))).click();
  };
  return window.pp.batchEdit();
})();

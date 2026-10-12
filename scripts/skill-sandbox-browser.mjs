#!/usr/bin/env node
// Runs an isolated local prototype; HTTP requests are blocked and reported.
import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';

const projectRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const caseDirectory = path.resolve(process.argv[2] || '');
if (!caseDirectory.startsWith(path.join(projectRoot, 'sandbox', 'legacy-to-spec') + path.sep)) {
  throw new Error('Supply a case directory under sandbox/legacy-to-spec');
}
const scenarioFile = process.argv[3];
const manifest = JSON.parse(await fs.readFile(path.join(caseDirectory, 'manifest.json'), 'utf8'));
const prototypeDirectory = path.join(caseDirectory, 'artifacts', 'design', manifest.scope_id, 'prototypes');
const files = (await fs.readdir(prototypeDirectory)).filter(name => name.endsWith('.html')).sort();
assert(files.length > 0, 'No generated prototypes');
const reportDirectory = path.join(caseDirectory, 'reports');
const imageDirectory = path.join(projectRoot, 'output', 'playwright', 'skill-sandbox', manifest.run, manifest.case);
await fs.mkdir(reportDirectory, {recursive: true});
await fs.mkdir(imageDirectory, {recursive: true});
const {chromium} = await import(process.env.SKILL_SANDBOX_PLAYWRIGHT || 'playwright-core');
const browser = await chromium.launch({headless: true});
const report = {case: manifest.case, run: manifest.run, engine: browser.version(),
  viewport: {width: 1280, height: 900},
  kind: 'local-prototype-browser-check', mode: scenarioFile ? 'scenarios' : 'inspection',
  checks: [], errors: [], networkAttempts: [], snapshots: [],
  prototypeHashes: {}, styleArtifactHashes: {},
  limits: ['Only generated local prototypes are executed; no legacy JSP runtime or real backend is executed.',
    'Screenshots do not establish pixel equivalence to the legacy runtime.']};
try {
  async function recordStyleArtifacts(directory) {
    for (const entry of await fs.readdir(directory, {withFileTypes: true})) {
      const file = path.join(directory, entry.name);
      if (entry.isDirectory()) await recordStyleArtifacts(file);
      else if (entry.isFile() && (entry.name.endsWith('.css') || entry.name === 'DESIGN.md' || entry.name === 'tokens.json')) {
        report.styleArtifactHashes[path.relative(caseDirectory, file)] = createHash('sha256').update(await fs.readFile(file)).digest('hex');
      }
    }
  }
  await recordStyleArtifacts(path.join(caseDirectory, 'artifacts', 'design'));
  const context = await browser.newContext({viewport: {width: 1280, height: 900}, serviceWorkers: 'block'});
  await context.route(/^https?:/, async route => {
    report.networkAttempts.push(route.request().url());
    await route.abort();
  });
  const page = await context.newPage();
  page.on('pageerror', error => report.errors.push(error.message));
  page.on('console', message => {if (message.type() === 'error') report.errors.push(message.text());});
  const dialogs = [];
  const boxes = new Map();
  const waitForDialogs = async count => {
    const deadline = Date.now() + 5000;
    while (dialogs.length < count && Date.now() < deadline) {
      await new Promise(resolve => setTimeout(resolve, 10));
    }
    assert(dialogs.length >= count, 'Expected asynchronous dialogs were not delivered');
  };
  page.on('dialog', async dialog => { dialogs.push(dialog.message()); await dialog.dismiss(); });
  for (const file of files) {
    report.prototypeHashes[file] = createHash('sha256').update(await fs.readFile(path.join(prototypeDirectory, file))).digest('hex');
    await page.goto(pathToFileURL(path.join(prototypeDirectory, file)).href);
    report.snapshots.push({file, visibleText: await page.locator('body').innerText(),
      controls: await page.locator('input,select,textarea,button').evaluateAll(elements => elements.map(element => ({
        tag: element.tagName, id: element.id, type: element.type, text: element.textContent.trim(),
        value: element.value, disabled: element.disabled,
        options: element.options ? [...element.options].map(option => ({value: option.value, text: option.text})) : null
      })))});
    await page.screenshot({path: path.join(imageDirectory, file + '.png'), fullPage: true});
  }
  if (scenarioFile) {
    const suite = JSON.parse(await fs.readFile(scenarioFile, 'utf8'));
    assert.equal(suite.case, manifest.case);
    const locator = step => {
      const found = step.role ? page.getByRole(step.role, {name: step.name, exact: true})
        : step.label ? page.getByLabel(step.label, {exact: true})
        : step.text ? page.getByText(step.text, {exact: true}) : page.locator(step.selector);
      return step.nth === undefined ? found : found.nth(step.nth);
    };
    for (const scenario of suite.scenarios) {
      const record = {id: scenario.id, source: scenario.source, status: 'PASS', assertions: 0};
      try {
        assert(files.includes(scenario.file), 'Unknown prototype file');
        await page.goto(pathToFileURL(path.join(prototypeDirectory, scenario.file)).href);
        dialogs.length = 0;
        boxes.clear();
        for (const step of scenario.steps) {
          switch (step.action) {
            case 'click': await locator(step).click({timeout: 5000}); break;
            case 'fill': await locator(step).fill(step.value, {timeout: 5000}); break;
            case 'select': await locator(step).selectOption(step.value); break;
            case 'check': await locator(step).setChecked(step.value); break;
            case 'press': await locator(step).press(step.key); break;
            case 'blur': await page.evaluate(() => document.activeElement?.blur()); break;
            case 'press_page': await page.keyboard.press(step.key); break;
            case 'keyboard_event': await locator(step).evaluate((element, event) => {
              element.dispatchEvent(new KeyboardEvent(event.type, {bubbles: true, cancelable: true,
                key: event.key, keyCode: event.keyCode, charCode: event.charCode || 0}));
            }, step); break;
            case 'wait_visible': await locator(step).waitFor({state: 'visible', timeout: 5000}); break;
            case 'wait_contains': await page.waitForFunction(({selector, value}) => {
              return document.querySelector(selector)?.textContent.includes(value);
            }, step, {timeout: 5000}); break;
            case 'wait_dialogs': await waitForDialogs(step.value); break;
            case 'clock_install': await page.clock.install(); break;
            case 'clock_run': await page.clock.runFor(step.milliseconds); break;
            case 'copy_selection': await locator(step).evaluate((element, value) => {
              element.focus(); element.setSelectionRange(0, value.length);
              element.dispatchEvent(new Event('copy', {bubbles: true, cancelable: true}));
            }, step.value); break;
            case 'observe': await locator(step).evaluate(element => {
              window.__sandboxObservations = [];
              window.__sandboxLastObservedText = element.textContent;
              window.__sandboxObserver?.disconnect();
              window.__sandboxObserver = new MutationObserver(records => {
                for (const record of records) {
                  const next = [...record.addedNodes].map(node => node.textContent).join('');
                  const previous = window.__sandboxLastObservedText;
                  window.__sandboxObservations.push(next.startsWith(previous) ? next.slice(previous.length) : next);
                  window.__sandboxLastObservedText = next;
                }
              });
              window.__sandboxObserver.observe(element, {childList: true});
            }); break;
            case 'observations': assert.equal(await page.evaluate(filter => window.__sandboxObservations.filter(text => !filter || text.includes(filter)).length, step.filter), step.value); record.assertions++; break;
            case 'drag': {
              const title = await locator(step).boundingBox();
              const target = page.locator(step.target);
              const before = await target.boundingBox();
              assert(title && before, 'Drag target must be visible');
              const x = title.x + title.width / 2, y = title.y + title.height / 2;
              await page.mouse.move(x, y); await page.mouse.down();
              await page.mouse.move(x + step.dx, y + step.dy, {steps: 5});
              if (step.outline) {
                assert(await page.locator(step.outline).isVisible(), 'Drag outline must be visible during movement');
                assert(!(await target.isVisible()), 'Original window must be absent during movement');
                record.assertions += 2;
              }
              await page.mouse.up();
              const after = await target.boundingBox();
              assert(after, 'Window must be visible after release');
              assert(Math.abs(after.x - before.x - step.dx) <= 2, 'Window horizontal position must follow drag');
              assert(Math.abs(after.y - before.y - step.dy) <= 2, 'Window vertical position must follow drag');
              record.assertions += 2; break;
            }
            case 'count': assert.equal(await locator(step).count(), step.value); record.assertions++; break;
            case 'value': assert.equal(await locator(step).inputValue(), step.value); record.assertions++; break;
            case 'content': assert.equal((await locator(step).textContent()).trim(), step.value); record.assertions++; break;
            case 'contains': assert((await locator(step).innerText()).includes(step.value)); record.assertions++; break;
            case 'attribute': assert.equal(await locator(step).getAttribute(step.attribute), step.value); record.assertions++; break;
            case 'dialog': assert.equal(dialogs.at(-1), step.value); record.assertions++; break;
            case 'dialogs': assert.deepEqual(dialogs, step.values); record.assertions++; break;
            case 'box_record': {
              const box = await locator(step).boundingBox(); assert(box, 'Element must be visible');
              boxes.set(step.key, box); break;
            }
            case 'width_preserved': {
              const before = boxes.get(step.key), after = await locator(step).boundingBox();
              assert(before && after, 'Both window measurements must exist');
              assert(after.width >= before.width - 1, 'Accumulated message window must not shrink');
              record.assertions++; break;
            }
            case 'css': assert.equal(await locator(step).evaluate((element, property) => getComputedStyle(element).getPropertyValue(property), step.property), step.value); record.assertions++; break;
            default: throw new Error('Unsupported action: ' + step.action);
          }
        }
        assert(record.assertions > 0, 'Scenario has no observable assertion');
        await page.screenshot({path: path.join(imageDirectory, scenario.id + '.png'), fullPage: true});
      } catch (error) {
        record.status = 'FAIL'; record.detail = error.message;
      }
      report.checks.push(record);
    }
  }
  report.status = report.errors.length || report.networkAttempts.length || report.checks.some(item => item.status !== 'PASS')
    ? 'FAIL' : scenarioFile ? 'PASS' : 'INSPECTED';
  report.screenshots = path.relative(caseDirectory, imageDirectory);
} finally {
  await browser.close();
}
await fs.writeFile(path.join(reportDirectory, scenarioFile ? 'browser.json' : 'browser-inspection.json'), JSON.stringify(report, null, 2) + '\n');
console.log(JSON.stringify({status: report.status, checks: report.checks, errors: report.errors,
  networkAttempts: report.networkAttempts, screenshots: report.screenshots,
  report: path.join(reportDirectory, scenarioFile ? 'browser.json' : 'browser-inspection.json')}, null, 2));
if (report.status === 'FAIL') process.exitCode = 1;

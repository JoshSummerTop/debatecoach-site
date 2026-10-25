// Renders the page at desktop and phone widths in light and dark, runs axe
// (WCAG 2.2 AA), checks touch targets and sideways scroll, and writes the
// social preview image. Run from the shadow-judge e2e folder for Playwright:
//   node <this file> <site dir>
import { chromium } from '@playwright/test';
import { readFileSync } from 'node:fs';
import { join } from 'node:path';

const site = process.argv[2];
const url = 'file://' + join(site, 'index.html');
const axe = readFileSync(join(site, 'tools/axe.min.js'), 'utf8');
const out = join(site, 'tools/shots');
const browser = await chromium.launch();
let problems = 0;

for (const [w, h, name] of [[1440, 900, 'desktop'], [390, 844, 'phone']]) {
  for (const scheme of ['light', 'dark']) {
    const page = await browser.newPage({ viewport: { width: w, height: h }, colorScheme: scheme, deviceScaleFactor: 1 });
    await page.goto(url, { waitUntil: 'networkidle' });
    await page.screenshot({ path: `${out}/${name}-${scheme}.png`, fullPage: true });
    const sideways = await page.evaluate(() => document.documentElement.scrollWidth - window.innerWidth);
    const small = await page.evaluate(() =>
      [...document.querySelectorAll('a,button,summary')]
        .filter((el) => el.offsetParent !== null)
        .map((el) => ({ t: (el.textContent || '').trim().slice(0, 30), r: el.getBoundingClientRect() }))
        .filter(({ r }) => r.width < 44 || r.height < 44)
        .map(({ t, r }) => `${t} ${Math.round(r.width)}x${Math.round(r.height)}`),
    );
    await page.addScriptTag({ content: axe });
    const res = await page.evaluate(async () =>
      (await window.axe.run(document, { runOnly: ['wcag2a', 'wcag2aa', 'wcag21aa', 'wcag22aa', 'best-practice'] })).violations.map(
        (v) => `${v.id} (${v.impact}) x${v.nodes.length}: ${v.nodes.slice(0, 3).map((n) => n.target.join(' ')).join(' | ')}`,
      ),
    );
    console.log(`${name} ${scheme}: sideways=${sideways}px  small targets=${small.length ? small.join('; ') : 'none'}`);
    for (const v of res) console.log('   axe', v);
    problems += (sideways > 0 ? 1 : 0) + small.length + res.length;
    await page.close();
  }
}

const og = await browser.newPage({ viewport: { width: 1200, height: 630 }, colorScheme: 'light' });
await og.goto(url, { waitUntil: 'networkidle' });
await og.addStyleTag({ content: '.top{display:none}.hero{padding-top:40px}.hero h1{font-size:60px}' });
await og.screenshot({ path: join(site, 'og.png'), clip: { x: 0, y: 0, width: 1200, height: 630 } });
await browser.close();
console.log(problems ? `${problems} problem(s)` : 'no problems');

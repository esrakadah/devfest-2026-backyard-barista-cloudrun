// Renders the README/social visuals. Run from anywhere: node docs/visuals/src/render.js (needs playwright).
const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch();
  for (const [f, w, h, out] of [['social.html',1200,630,'social-card.png'],['arch.html',1600,760,'architecture.png']]) {
    const p = await b.newPage({ viewport: { width: w, height: h } });
    await p.goto('file://' + __dirname + '/' + f); await p.waitForTimeout(500);
    await p.screenshot({ path: __dirname + '/../' + out });
  }
  await b.close();
})();

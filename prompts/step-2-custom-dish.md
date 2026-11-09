# Round 2 Prompt: On-the-Fly Custom SVG Dish, 5s Tea Sipping & Gemini Structured JSON Salt Judge

Copy the prompt block below and paste it into **Google AI Studio Build Mode** (or **Google Antigravity `Cmd+I` / Agent Mode**):

```text
Upgrade our "Backyard Barista on Cloud Run" cafe game with 3 features:

1. GENERATE MY CUSTOM SIGNATURE DISH & PRANK INGREDIENT ON THE FLY (INLINE SVG OR STUDIO PNG):
Create 2 brand-new Round-2 counter items with custom, multi-color inline `<svg viewBox="0 0 120 120">` vector artwork directly in code (alongside our studio PNGs `foods/katmer_roll.png` and `toppings_pranks/isot_pepper.png`):
- Custom Signature Food: "Fıstıklı Katmer Sarma (Pistachio Katmer Roll)" (or customize the name/SVG to your own invention!)
- Custom Prank Ingredient: "İsot Biberi (Urfa & Antep Isot Pepper Flakes)" sitting right next to Sugar!
Add a toggle chip so players can switch Round-2 custom items on/off and add them to the shared tray.

2. 5-SECOND TURKISH TULIP-GLASS TEA SIPPING ANIMATION (`🫖 5sn Çay Yudumlat`) & CAFE AUDIO CUES:
- Whenever a drink is tapped or the "🫖 5sn Çay Yudumlat" button is pressed, play a 5.0-second choreographed animation where the character lifts a crimson-rimmed porcelain saucer and Turkish tulip glass (`İnce Belli Çay Bardağı`), takes 3 sips as the ruby-red tea level drops from 88% to 24%, and shows a live countdown badge (`🫖 Hüüüp! · 5.0sn -> 0.0sn`).
- Play distinct audio cues on tap (`tap_pop`), stealth prank selection (`stealth_wink`), tea sipping (`tea_sip`), 5-star sweet celebration (`sweet_fanfare`), and 1-star salty sabotage (`salty_buzzer`), with a top-bar mute button.

3. WIRE GEMINI (`gemini-3.5-flash-lite`) STRUCTURED JSON JUDGE (`CafeReview`):
When the players click "Serve Order! / Servis Et!", call `gemini-3.5-flash-lite` once with a strict JSON response schema:
{
  "ratingStars": number (1 to 5),
  "tasteVerdict": "sweet_perfection" | "salty_sabotage" | "spicy_chaos" | "creative_mix",
  "customerFace": "happy" | "shocked" | "salty_disgusted",
  "headline": string,
  "customerReaction": string,
  "cityBonusTip": number
}

Rules for the Gemini Judge:
- If the tray contains "salt_shaker" (Tuz), "chili_sauce" (Acı Sos), or "isot_pepper" (İsot Biberi) inside a sweet drink or pastry order, MUST return `ratingStars: 1`, `tasteVerdict: "salty_sabotage"` (or `"spicy_chaos"`), `customerFace: "salty_disgusted"`, and a hilarious roast referencing the active City Edition (`berlin`, `gaziantep`, `adana`, or `istanbul`).
- If the tray has a balanced drink + pastry + sugar (and zero prank items), return `ratingStars: 5`, `tasteVerdict: "sweet_perfection"`, `customerFace: "happy"`, and a warm local compliment.
- Include an instant offline fallback generator (`mock_responses.json`) if the API key is missing or returns HTTP 429 so the game never crashes on stage.
```

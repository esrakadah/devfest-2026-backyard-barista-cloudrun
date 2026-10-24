# Round 2 Prompt: On-the-Fly Custom SVG Dish + Gemini Structured JSON Salt Judge

Copy the prompt block below and paste it into **Google AI Studio Build Mode** (or **Google Antigravity `Cmd+I` / Agent Mode**):

```text
Upgrade our "Backyard Barista on Cloud Run" cafe game with 2 features:

1. GENERATE MY CUSTOM SIGNATURE DISH & PRANK INGREDIENT ON THE FLY (INLINE SVG):
Create 2 brand-new items with custom, multi-color inline `<svg viewBox="0 0 120 120">` artwork directly in code (no external image URLs needed):
- Custom Signature Food: "Pistachio Katmer Roll" (or customize the name/SVG to my own invention!)
- Custom Prank Ingredient: "İsot Pepper Flakes (İsot Biberi)" sitting right next to Sugar!
Add both to the counter so players can tap and add them to the tray.

2. WIRE GEMINI (`gemini-3.5-flash-lite`) STRUCTURED JSON JUDGE (`CafeReview`):
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
- Include an instant offline fallback generator if the API key is missing or returns HTTP 429 so the game never crashes on stage.
```

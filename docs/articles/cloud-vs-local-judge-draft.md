---
title: "Cloud Judge vs Local Judge: Running a Flutter Game's AI Critic on Gemma 4 When the Wi-Fi Dies"
subtitle: "Gemini answers in 1.4 s, a local Gemma 4 12B on my laptop in 6.8 s. Here is how both now judge the same tray in Backyard Barista, and the three prompt fixes that made the small model usable on stage."
date: "2026-11-11"
author: "Esra Kadah"
tags: ["flutter", "dart", "gemma", "ollama", "gemini-api", "local-ai"]
canonical_url: "https://esra.tech/blog/cloud-judge-vs-local-judge-gemma-flutter"
---

# Cloud Judge vs Local Judge: Running a Flutter Game's AI Critic on Gemma 4 When the Wi-Fi Dies

Backyard Barista is the cafe game I built for my DevFest sessions this season: two players fill a tray, one of them slips salt into a sweet order, and an AI critic roasts the result. The [first article](backyard-barista-cloud-run-medium.md) covered the Cloud Run side and what 1,000 Gemini verdicts cost ($0.0468).

That setup had one weak spot. When the venue Wi-Fi drops, the game falls back to a bundled JSON file in 0.09 ms. Fast and safe, but the audience gets the same canned roast every time. For Eskişehir, Adana and Istanbul I wanted a fresh roast even with the network gone, so the judge now has a middle tier: Gemma 4 12B, running in Ollama on the laptop I present from.

All numbers below were measured on 11 Nov 2026 on a MacBook Pro M3 Pro with 18 GB, Ollama as a brew service, model `gemma4:12b-it-qat` (7.2 GB on disk).

## Three tiers, one order

| Tier | Runs on | Timeout | Used when |
|---|---|---|---|
| Gemini 3.5 Flash-Lite, structured JSON | Cloud | 8 s | An API key or the Cloud Run proxy is set |
| Gemma 4 12B through Ollama `/api/chat` | Speaker laptop | 15 s | `--dart-define=LOCAL_JUDGE_URL` is set |
| `mock_responses.json` | Bundled in the app | 250 ms | Always, as the last resort |

The order lives in `CafeJudgeService.evaluateOrder`:

```dart
if (!forceOfflineMode && (_usesServerSideProxy || geminiApiKey.trim().isNotEmpty)) {
  final liveReview = await _tryCallGeminiStructuredJson(/* ... */);
  if (liveReview != null) {
    return liveReview;
  }
}

if (localJudgeUrl.trim().isNotEmpty) {
  final localReview = await _tryCallLocalGemma(/* ... */);
  if (localReview != null &&
      _verdictMatchesPranks(
        localReview,
        containsSaltPrank: containsSaltPrank,
        containsChiliPrank: containsChiliPrank,
      )) {
    return localReview;
  }
}

return _evaluateFromOfflineFallback(/* ... */);
```

Leave `LOCAL_JUDGE_URL` empty and the middle block never runs, so the Cloud Run build behaves exactly as before. No new packages either: the Ollama call is plain `package:http`.

### The request

```dart
final requestBody = <String, dynamic>{
  'model': localJudgeModel, // gemma4:12b-it-qat
  'stream': false,
  'think': false,
  'format': _localJudgeJsonSchema,
  'messages': [
    {'role': 'user', 'content': _buildJudgePrompt(/* ... */)},
  ],
};
```

Two flags matter. `format` takes a JSON schema with enums for `tasteVerdict` and `customerFace`, so the model can only answer with values the UI knows. `think: false` turns off Gemma's reasoning: with thinking on, a one-line answer took about 60 s; with it off, about 4 s. For a game, thinking stays off.

### Dart keeps the score

Whether a tray contains salt or chili is decided in Dart before any model sees it. The prompt states those flags as rules, and `_verdictMatchesPranks` throws away any local verdict that disagrees. The model writes the joke; the score never depends on a 12B model reading the tray correctly. If it gets it wrong, the bundled tier answers instead.

## The numbers

Same harness for both judges: 12 trays, Gaziantep and Berlin editions, each with salt, chili and a sweet tray, two runs each.

| | Gemini (cloud) | Gemma 4 12B (local, warm) |
|---|---|---|
| Time per verdict | 1.0-1.8 s, mean ~1.4 s | 5.0-8.4 s, mean ~6.8 s |
| Correct verdict | 12/12 | 12/12 |
| Gaziantep replies in Turkish | 6/6 | 6/6 |
| Needs network | Yes | No |
| Reaches phones in the room | Yes, through the Cloud Run proxy | No |
| Cost per 1,000 verdicts | $0.0468 | Laptop power |
| Data leaves the laptop | Yes | No |

Gemma generates 13-16 tokens per second here; the M3 Pro's memory bandwidth puts the ceiling near 21. A cold model adds about 14 s before the first verdict, which alone would break the 15 s budget, so the stage runbook warms it up ten minutes before the talk.

Some roasts from the local judge:

- Gaziantep, salt: "Baklava mı, Tuz Gölü mü?" / "Gaziantep'in meşhur baklavasına tuz atmak, baklavaya hakaret etmekten öte bir suçtur!"
- Berlin, chili: "A Spicy Betrayal in Kreuzberg" / "I thought I was getting a dessert, but my nostrils are currently undergoing a Berlin techno rave."
- Berlin, sweet: "A Pistachio Dream in Berlin" / "This pistachio pairing is smoother than a late-night U-Bahn ride through Neukölln."

## Three prompt fixes the small model needed

Gemma 4 12B needed three prompt changes before it was stage-ready.

### 1. Name the language

The prompt used to pass the city's language code, `tr`. Gemma answered 5 of 6 Gaziantep trays in English. Writing "Turkish (Türkçe)" instead of the code fixed all six.

### 2. Put the length rule next to the language

The first local roasts ran 3-5 sentences (104-440 characters), so verdicts took 7.4-15.1 s and one of 12 hit the timeout. A separate system message asking for a six-word headline and one sentence cut nothing (still ~115 tokens) and pushed the Turkish reply back into English.

What worked was one line that carries both rules:

```text
Write in Turkish (Türkçe) only: headline at most 6 words, customerReaction one sentence of at most 20 words.
```

Roasts dropped to 99-131 characters, verdicts to 5.0-8.4 s with no timeouts, and Turkish stayed at 6/6. The prompt is shared, so Gemini roasts got shorter too. They still land: "Şehitkamil'in fıstıklı baklavasına tuz atmak Antep'e ihanettir, bu kahveyle bile kurtulmaz!"

### 3. Ask for less text instead of cutting it

Ollama's `num_predict` caps output tokens, which sounds like the obvious fix. With a JSON schema it cuts the reply mid-string, the parse fails, and the verdict falls to the bundle. A shorter answer has to come from the prompt.

One more lesson from the same day: a 10 s timeout was too tight for the local tier. 15 s, measured against real runs, leaves room.

## What a laptop judge cannot do

**Phones in the hall cannot reach it.** Ollama answers a `localhost` Flutter web origin (204) and refuses the Cloud Run origin (403). The local tier works when I run the game with `flutter run -d chrome` or `-d macos` on the same laptop. Attendees playing the deployed `.run.app` on their phones keep the bundled tier, which is why it stays.

**Ollama is one queue.** On the day I measured, an unrelated eval held Ollama for about two hours and every game call waited behind it. Before going on stage, `lsof -nP -iTCP:11434` should show only the listening socket.

**The default keep-alive is five minutes.** Two demos can be further apart than that. On stage day I set `OLLAMA_KEEP_ALIVE=30m`, load the model with one request, check `ollama ps`, and only then turn the Wi-Fi off.

## A side experiment: voice orders

I also tried taking the order by voice, with two Turkish recordings. Gemma 4's native audio input through Ollama got 0 of 2: an Azeri-sounding transcript, an invented story, and the salt missed. Whisper large-v3-turbo on the same Mac transcribed both almost perfectly, and Gemma turned that text into a correct JSON order 4 times out of 4, in 3-5 s. If the game takes voice orders, it will be Whisper first, then Gemma.

## Where it stands

The three-tier judge is merged in [PR 6](https://github.com/esrakadah/devfest-2026-backyard-barista-cloudrun/pull/6). The README's Lane B has the run command, and `docs/stage-runbook.md` has the warm-up steps.

Cloud is about five times faster and reaches every phone in the room. Local needs a 7.2 GB download and a warm-up, and answers with no network at all. On stage, that turns "the Wi-Fi just died" into a live roast that arrives a few seconds later.

What would you put in the middle tier of your app: a bigger local model and a longer timeout, or a smaller one and a faster answer?

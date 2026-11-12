# Berlin cue card: 45 minutes in English

DevFest Berlin, Sat 14 Nov 2026, 10:00, Room 2, SRH Berlin. The Vibe Lounge sprints follow at 11:00-15:00, where people build Google's official Backyard Barista guide, not this game. Today the game is the stage demo, nobody in the room builds along.

The speaker notes in the deck stay the Turkish 80-minute Gaziantep script. Use this card for Berlin: same slides, English lines, a 45-minute clock. Stage Navigator (deck menu) jumps to any section.

## Running order

| Clock | Slide | Do | One English line |
|---|---|---|---|
| 00:00 | 1 `/title` | Intro, GDE line | "I'm Esra, Flutter and AI engineer at Antigua Mobile and a Flutter and Dart GDE. My views today, not Google's. We ship an AI cafe game to Cloud Run and talk real numbers." |
| 02:00 | 2 `/sweet-or-salty` | Poll: hands for A, hands for B | "Which one is sugar? Hold that thought: an AI is going to judge exactly this." Answer: A sugar, B salt. |
| (skip) | 3 `/workshop-contract` | **Skip**, use the line on slide 2 | Say instead: "If you want to build your own, the Vibe Lounge opens at 11 with Google's Backyard Barista guide." |
| 04:00 | 4 `/ai-studio-pipeline` | | "One prompt in AI Studio Build mode gives you a deployable app. Here is what actually comes out." |
| 07:00 | 5 `/meet-antigravity` | | "Antigravity edits many files at once and draws new ingredients as vectors, no designer in the loop." |
| 09:30 | 6 `/pure-flutter-widgets` | | "Flame runs the 60 fps stage, plain Flutter widgets run the counter. Each does what it is good at." |
| 12:00 | 7 `/real-numbers-latency` | Point at the measured line | "Gemini answers in 1.0 to 1.8 seconds, measured on 11 November. A local Gemma 4 on this laptop takes 5 to 8.4 seconds. The 8 and 15 second limits are code, not hopes." |
| 15:00 | 8 `/real-numbers-cost` | | "A thousand verdicts cost cents. The trap is not price, it is which model your account may call." |
| 17:30 | 9 `/room-quota-trap` | | "Three hundred people on one key is an HTTP 429 waiting to happen. So the key sits behind a rate-limited proxy, and every failure lands on the bundled roasts." |
| 20:00 | 10 `/multi-city-remote-config` | | "One build, four cities: Remote Config picks Berlin, Gaziantep, Adana or Istanbul, the in-app switcher wins on stage." |
| 22:00 | 11 `/salt-sugar-mechanic` | | "The model writes the joke. Whether there is salt on the tray is decided in Dart, so a salt tray can never get five stars." |
| 24:00 | **Live demo** in the game tab | Sweet tray, then salt tray, then Wi-Fi off and serve again | "Same tray, no Wi-Fi: the verdict now comes from the laptop. The badge under the card says which judge answered." |
| 32:00 | 12 `/hybrid-asset-pipeline` | **First cut if late** | "Fourteen studio PNGs ship in the repo, round-two ingredients are drawn on the fly." |
| 34:00 | 14 `/architecture-recap` | Skip 13 `/live-build-dashboard` | "Four layers: Flutter and Flame, Remote Config, the judge chain Gemini then Gemma then bundle, and a stateless Cloud Run container." |
| 37:00 | 15 `/winner-podium-closing` | No podium in Berlin: point at the QR codes and the badge link | "If you remember one sentence: let the model write the joke, let your code keep the score." |
| 40:00 | Q&A | Backup slide `/demo-hiccup` answers "what if the network dies" | |
| 45:00 | End | Walk to the Vibe Lounge | |

## If something breaks

- Wi-Fi gone: jump to `/demo-hiccup`, run the game with `OFFLINE_MODE=true` and `LOCAL_JUDGE_URL` (full command in [`stage-runbook.md`](stage-runbook.md)). Warm Gemma first, ten minutes before 10:00.
- Running late at 32:00: skip slide 12 and go straight to the recap.
- Deck frozen: the PDF backup `slides/build/slides/backyard_barista_deck.pdf`.

## The day around it

- Mirror `europe-west1` has no Gemini key and only serves bundled roasts; demo Gemini on `europe-west3`.
- Flight to Gaziantep is the night of the 14th, 20:40; leave the venue with time for the airport.

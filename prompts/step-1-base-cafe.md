# Round 1 Seed Prompt: Base Cafe Counter + 4-City Edition Switcher (AI Studio Build Mode)

Copy the prompt block below and paste it into **Google AI Studio Build Mode** (`https://aistudio.google.com`):

```text
Build a playful, zero-typing 2-player web game called "Backyard Barista on Cloud Run: Tatlı mı Tuzlu mu?".

1. MULTI-CITY EDITION SWITCHER (Top App Bar):
Include a top-right dropdown selector and state controller with 4 City Editions (simulating Firebase Remote Config `active_city_id` with a manual UI override):
- "berlin" (🇩🇪 DevFest Berlin Edition): Subtitle "Späti & Kiez Roasters", Local Dish: "Berliner Pfannkuchen", Salt Prank Joke: "Das ist Salz, kein Zucker! Tougher than the Berghain bouncer: 1 Star!"
- "gaziantep" (🇹🇷 DevFest Gaziantep Edition): Subtitle "Şehitkamil Baklava & Kahve Evi", Local Dish: "Fıstıklı Baklava", Salt Prank Joke: "Baklavaya ve kahveye tuz atanı Şehitkamil'den sınır dışı ederler! 1 Yıldız!"
- "adana" (🇹🇷 DevFest Adana Edition): Subtitle "Gar Kahvesi & Tatlı Durağı", Local Dish: "Bici Bici", Salt Prank Joke: "Şalgam suyu mu sandın bunu? Tatlıya tuz basmışsın, 1 Yıldız!"
- "istanbul" (🇹🇷 DevFest Istanbul Edition): Subtitle "Galata & Vapur Kafe", Local Dish: "San Sebastian Cheesecake", Salt Prank Joke: "Galata Kulesi'nde turist kazıklar gibi kahveye tuz basmışsınız, 1 Yıldız!"

2. ZERO-TYPING 2-STATION CAFE COUNTER:
Players never type text. They assemble an order on a tray by tapping ingredient cards across 3 shelves:
- Drinks (pick 1+): Espresso, Steamed Milk (Süt), Menengiç Coffee (Menengiç Kahvesi)
- Simple Foods (pick 1+): Butter Croissant (Kruvasan), San Sebastian Cheesecake, Pistachio Baklava (Fıstıklı Baklava)
- Toppings & Pranks (placed right next to each other!):
  - Sugar Jar (Şeker - sweet)
  - Salt Shaker (Tuz - PRANK ingredient, looks nearly identical to Sugar!)
  - Hot Chili Sauce (Acı Sos - PRANK ingredient, sits next to sweet toppings!)

3. HYBRID ASSET PACK (GitHub Raw PNGs with Crisp Inline SVG Fallbacks):
Load item illustrations from `https://raw.githubusercontent.com/esrakadah/devfest-2026-backyard-barista-cloudrun/main/flutter_client/assets/base/{category}/{file}.png` (`drinks/espresso.png`, `drinks/milk.png`, `drinks/menengic_coffee.png`, `foods/croissant.png`, `foods/san_sebastian.png`, `foods/baklava.png`, `toppings_pranks/sugar_jar.png`, `toppings_pranks/salt_shaker.png`, `toppings_pranks/chili_sauce.png`, `customers/customer_happy.png`, `customers/customer_shocked.png`, `customers/customer_salty_disgusted.png`), and attach an `onerror` fallback that renders a colorful inline SVG illustration for each item so the game renders offline or when the repo is private.

4. 2-PLAYER TRAY & SERVE BUTTON:
- Player 1 ("Barista") taps Drinks, Player 2 ("Pastry Chef & Prankster") taps Foods and Toppings/Pranks.
- Show the assembled Tray with animated badges and a big "Serve Order! / Servis Et!" button.
```

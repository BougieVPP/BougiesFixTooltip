# BougiesFixToolTip

![BougiesFixToolTip Logo](logo.png)

## 🇬🇧 English

**BougiesFixToolTip** is a lightweight World of Warcraft addon that automatically fixes broken singular/plural localization tags (`$lsingular:plural;`) in item, spell, and comparison tooltips.

### Why this addon?
In localized clients (such as French) or custom servers, a missing space or malformed syntax in database descriptions can cause the game engine to display raw code like `7 $lpoint:points;` instead of `7 points`. This addon intercepts tooltip text in real time and formats the correct singular or plural word based on the preceding number.

### Features
* **Automatic Singular/Plural Resolution:** Handles integers (`1`, `7`) as well as decimals (`0.5`, `1,5`).
* **Full Tooltip Coverage:** Works on main tooltips (`GameTooltip`), chat item links (`ItemRefTooltip`), and comparison tooltips (`ShoppingTooltip`).
* **ElvUI & Default UI Compatible:** Works seamlessly with Blizzard's default interface as well as ElvUI and other tooltip addons.
* **Zero Lua Errors (Midnight / 12.x Ready):** Built-in protection against Blizzard's protected `Secret Values` and forbidden frames (`IsForbidden`).
* **Ultra-Lightweight:** Less than 60 lines of code, zero configuration required, and negligible CPU/memory footprint.

### Before / After
TODO

### Installation
1. Download the addon via the **CurseForge App** or extract the `BougiesFixToolTip` folder into your `World of Warcraft\_retail_\Interface\AddOns\` directory.
2. Restart the game or type `/reload` in chat.
3. No setup needed — it works automatically!

---

## 🇫🇷 Français

**BougiesFixToolTip** est un addon léger pour World of Warcraft qui corrige automatiquement les balises de localisation singulier/pluriel cassées (`$lsingulier:pluriel;`) dans les infobulles d'objets, de sorts et de comparaison.

### Pourquoi cet addon ?
Sur les clients traduits (notamment en français) ou certains serveurs personnalisés, une erreur de syntaxe dans les descriptions d'objets affiche le code brut (ex. `7 $lpoint:points;` au lieu de `7 points`). Cet addon intercepte le texte des infobulles en temps réel et affiche le bon mot au singulier ou au pluriel selon le chiffre qui précède.

### Fonctionnalités
* **Gestion automatique du singulier et du pluriel :** Prend en charge les nombres entiers (`1`, `7`) ainsi que les nombres décimaux (`0,5`, `1.5`).
* **Couverture complète :** Fonctionne sur l'infobulle principale, les liens d'objets dans le chat et les infobulles de comparaison (`Maj`).
* **Compatible ElvUI et interface de base :** Fonctionne aussi bien sans addon qu'avec ElvUI ou d'autres skins d'infobulles.
* **Zéro erreur Lua (Compatible 12.x / Midnight) :** Protégé contre les valeurs secrètes (`Secret Values`) et les cadres protégés de Blizzard.
* **Ultra-léger :** Moins de 60 lignes de code, aucune configuration requise et impact nul sur les performances.

### Avant / Après
TODO

### Installation
1. Téléchargez l'addon via l'**application CurseForge** ou placez le dossier `BougiesFixToolTip` dans votre répertoire `World of Warcraft\_retail_\Interface\AddOns\`.
2. Relancez le jeu ou tapez `/reload` dans le chat.
3. Aucun réglage nécessaire — la correction est immédiate !

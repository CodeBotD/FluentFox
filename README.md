# FluentFox

Transparent Firefox — browser chrome + per-site website styles — inspired by Zen Browser’s Transparent Zen + Zen Internet combo.

FluentFox is two pieces that work together:

| Piece | What it does |
| --- | --- |
| **Theme** (`theme/`) | `userChrome.css` / `userContent.css` + prefs so the Firefox window (toolbars, horizontal **and** native vertical tabs, new tab) can be transparent |
| **Extension** (`extension/`) | Fork of [Zen Internet](https://github.com/sameerasw/zeninternet) that injects CSS for 1000+ sites from [my-internet](https://github.com/sameerasw/my-internet) |

```
┌────────────────────────────┐
│  Firefox chrome (theme)    │  ← translucent toolbars / tabs
│  ┌──────────────────────┐  │
│  │  Web page            │  │  ← FluentFox extension + my-internet styles
│  └──────────────────────┘  │
└────────────────────────────┘
```

## Requirements

- Firefox 115+ (vertical tabs: Firefox 136+ with sidebar layout)
- OS support for window transparency/blur varies (see [Platform notes](#platform-notes))

## Install

### 1. Browser theme

**macOS / Linux**

```bash
./theme/install.sh
```

**Windows** (PowerShell)

```powershell
.\theme\install.ps1
```

Then:

1. Quit Firefox completely and reopen (prefs in `user.js` apply on startup).
2. Open `about:addons` → Themes → use **System theme — auto** or **Firefox Default** (third-party themes often paint opaque backgrounds).
3. Optional: enable **Vertical tabs** under Settings → General → Browser Layout — the same CSS covers both layouts.

The installer finds your default profile via `profiles.ini`, copies `chrome/userChrome.css`, `chrome/userContent.css`, and `user.js`, and keeps timestamped `*.fluentfox-backup-*` copies of anything it replaces.

### 2. Extension (temporary load)

AMO / signed `.xpi` distribution is not set up yet. For now:

1. Open `about:debugging#/runtime/this-firefox`
2. Click **Load Temporary Add-on…**
3. Select [`extension/manifest.json`](extension/manifest.json)
4. Visit a supported site (YouTube, GitHub, Reddit, …) and open the FluentFox toolbar popup to toggle features

Temporary add-ons are removed when Firefox restarts — reload the same way after each restart until a signed build is published.

**Dev helpers**

```bash
cd extension
npx web-ext lint
npx web-ext run
```

## Uninstall

**Theme**

1. Delete (or restore backups of) in your profile folder:
   - `chrome/userChrome.css`
   - `chrome/userContent.css`
   - `user.js`
2. In `about:config`, set `browser.tabs.allow_transparent_browser` → **false**
3. Restart Firefox

> Important: that pref is **not** reset automatically. Leaving it `true` after removing the theme can make some pages look oddly transparent.

**Extension**

- Temporary: restart Firefox, or remove it from `about:debugging`
- Later (AMO): remove from `about:addons`

## Platform notes

| Platform | Expectation |
| --- | --- |
| **macOS** | Transparency works; behind-window blur is milder than Zen’s vibrancy. Pref: `widget.macos.titlebar-blend-mode.behind-window` |
| **Windows 11** | Best with Mica/Acrylic. Prefs: `widget.windows.mica`, `widget.windows.mica.toplevel-backdrop=2`. Optional: [Mica For Everyone](https://github.com/MicaForEveryone/MicaForEveryone) or Windhawk Translucent Windows |
| **Windows 10** | Limited; acrylic helpers help but results vary |
| **Linux** | Depends on compositor (KDE / Hyprland known-good; GNOME often poor). You may need compositor-side blur |

Dark Reader can help on sites that stay light-themed after transparency is applied.

## Requesting site styles

Styles ship from upstream [sameerasw/my-internet](https://github.com/sameerasw/my-internet). Use the extension’s **Request Theme** flow, or open an issue there. FluentFox does not maintain a separate styles fork — updates arrive when the extension refreshes `styles.json` (about every 2 hours with auto-update on).

## Repo layout

```
FluentFox/
├── extension/          # FluentFox WebExtension (fork of Zen Internet)
├── theme/
│   ├── chrome/
│   │   ├── userChrome.css
│   │   └── userContent.css
│   ├── user.js
│   ├── install.sh
│   └── install.ps1
├── LICENSE
└── README.md
```

## Credits

- [Zen Internet](https://github.com/sameerasw/zeninternet) (sameerasw) — extension base, MIT
- [Transparent Zen](https://github.com/frostybiscuit/transparent-zen) (frostybiscuit) — original addon base / inspiration, MIT
- [my-internet](https://github.com/sameerasw/my-internet) — site CSS library, MIT
- Transparent Firefox community themes (gwfox, MicaBlur-Firefox, and others) — chrome selector patterns

## License

MIT — see [LICENSE](LICENSE). Upstream licenses and the vendored commit hash are recorded in [`extension/UPSTREAM.md`](extension/UPSTREAM.md).

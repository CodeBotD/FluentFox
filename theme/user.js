// FluentFox prefs — copied into the Firefox profile as user.js by the installer.
// Restart Firefox after install. Prefs take effect on next start.

// Allow userChrome.css / userContent.css
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Let web content be transparent (needed for FluentFox extension + my-internet styles)
user_pref("browser.tabs.allow_transparent_browser", true);

// Avoid solid page backplates fighting transparency
user_pref("browser.display.use_system_colors", false);
user_pref("browser.display.background_color", "#00000000");
user_pref("browser.display.background_color.dark", "#00000000");
user_pref("browser.newtabpage.activity-stream.newtabWallpapers.enabled", false);

// SVG context properties used by some chrome themes
user_pref("svg.context-properties.content.enabled", true);

// Windows 11 Mica / Acrylic (ignored on other platforms)
user_pref("widget.windows.mica", true);
user_pref("widget.windows.mica.toplevel-backdrop", 2); // 2 = Acrylic

// macOS: blend titlebar with content behind the window (ignored elsewhere)
user_pref("widget.macos.titlebar-blend-mode.behind-window", true);

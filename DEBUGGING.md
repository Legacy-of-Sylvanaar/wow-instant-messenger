# Debugging WIM

WIM has a built-in debug capture that writes a timestamped log to disk. It
exists so that a bug report can include *what actually happened*, including
everything that fires during login -- long before a slash command could be
typed.

## Debug levels

| Level | Command | What it records |
|-------|---------|-----------------|
| 0 | `/wim debug 0` | Nothing (default). Zero overhead. |
| 1 | `/wim debug 1` | WIM's own diagnostic messages (module enable/disable, history conversion, channel/community bookkeeping, …). Shown in the chat frame **and** written to the log. |
| 2 | `/wim debug 2` | Everything from level 1, **plus** a raw trace of every chat-related event the client delivers (whispers, channels, club/community plumbing, channel-list churn), with arguments, **and a `SETTING` line for every option change committed from either options UI** (`SETTING [classic\|modern] <key> = <value>`). Trace lines go to the log only -- they are far too noisy for the chat frame. |

`/wim debug` with no number toggles between 0 and 1. The level **persists
across logout/login**, which is deliberate: most of the interesting behavior
happens during the login sequence, so you set the level once, then log out
and back in to capture it.

`/wim debugclear` empties the captured log (useful between test attempts).

## Where the log lives

The log is a per-character SavedVariable, `WIM3_DebugLog`, written by the
client **on logout or `/reload`** -- it is not on disk in real time. Find it
at:

```
WTF/Account/<ACCOUNT>/<Realm>/<Character>/SavedVariables/WIM.lua
```

Each line is prefixed with a wall-clock timestamp with millisecond
resolution (e.g. `08/14 09:12:03.481`), so event ordering within a single
frame is preserved. Whenever capture starts, a header line records the WIM
version, client build, interface number and locale:

```
=== WIM 3.18.0 | level 2 | WoW 12.1.0 (build 58238, interface 120100) | enUS | Charname-Realm ===
```

The buffer is a bounded ring (6000 lines, 500 characters per line): long
sessions overwrite the oldest half, so capture what you need and copy it out
promptly. Because the log is per-character it can never bloat the
account-wide settings file.

Trace lines never contain protected chat content: values the client marks as
secret are logged as `<secret>`.

## Including a log in a bug report

1. `/wim debug 2` (or `1` if the issue isn't event-related).
2. `/wim debugclear` to start clean.
3. Reproduce the problem. If it involves login behavior, log fully out and
   back in with the level already set.
4. Log out (or `/reload`) so the client writes the file.
5. Open `WTF/Account/<ACCOUNT>/<Realm>/<Character>/SavedVariables/WIM.lua`,
   copy the `WIM3_DebugLog` `lines` block (or attach the whole file), and
   paste it into the issue inside a code fence. Include the `===` header
   line -- it carries the version information the report needs.
6. `/wim debug 0` when you're done, so the log stops accumulating.

What a good capture shows the maintainer: the exact order the client
delivered events in, what arguments they carried, and which of WIM's
handlers ran -- three things that cannot be reconstructed from a screenshot
or a description after the fact.

## UI state snapshots (`/wim snap`)

The debug log answers *what happened*; the snapshot tool answers *what the
UI looks like right now*. `/wim snap` serializes the live widget state of
the frames WIM styles -- every region's resolved rectangle, anchor chain,
texture/atlas, texture coordinates, colors, fonts and visibility -- so a
layout or skin problem can be diagnosed numerically instead of guessed at
from a screenshot.

| Command | What it captures |
|---------|------------------|
| `/wim snap` | Nothing -- prints the available arguments. |
| `/wim snap all` | Everything WIM styles: every message window (shown or hidden, full widget trees), the History Viewer, the options windows, the menu, the minimap button, plus the native Settings widgets WIM's styling is modeled on. Also takes a screenshot of the same moment. |
| `/wim snap <Frame.Dot.Path>` | One frame by global dot-path, e.g. `/wim snap WIM3_msgFrame1` or `/wim snap SettingsPanel.SearchBox`. |
| `/wim snapmenu` | Arms a one-shot capture of the next context menu while it is open (menus strip their art when released, so they must be captured live). |

Snapshots land in the per-character SavedVariable `WIM3_Snapshots` (the
same `WIM.lua` file as the debug log) and are written to disk on logout or
`/reload`, like any SavedVariable. Snapshots accumulate -- each capture adds
an entry rather than overwriting the last, so a before/after pair around a
reproduction is one file.

Every snapshot records the build that produced it (`addonBuild`, stamped by
the packaging script; `dev` when running from the source tree), and the
confirmation line in chat prints it. When testing a fix, check that value
against the build you meant to install before drawing any conclusions.

Snapshots also record what the client itself provides and what WIM decided,
which is what isolates flavor problems (era, TBC, wrath, MoP and their
successors share atlas and layout names with retail while the art and
behavior differ):

- `client` -- the flavor (version, build number, interface, project id) and
  probe results: whether each critical atlas, texture file, nine-slice
  layout, and API surface exists on this client. Diff this block between a
  retail dump and a classic dump to see exactly which capability differs.
- `wim` -- the selected and loaded skin, whether it is modern-only, the
  options style, and the modern theme's scalar settings.
- `wimState` on each captured window -- the bookkeeping that picks the paint
  path: chrome kind (layout or lite) and visibility, portrait flags, themed
  input state, the recorded base icon size and layer, and the icon's current
  size.

The debug log gains one line per window whenever the modern theme applies or
tears down (`ModernTheme <frame>: apply/teardown, chrome=...`), so a skin
switch leaves a visible trail between two snapshots.

## Which tool for which problem

- **Behavioral** (messages not routed, history missing, events mishandled,
  errors during login): the **debug log**. Level 2 if chat events are
  involved, level 1 otherwise.
- **Visual** (overlapping or misplaced widgets, wrong textures or colors,
  skin regressions, layout drift after resizing or reskinning): a
  **snapshot** -- `/wim snap all` in the broken state, plus one after a
  `/reload` if the reload changes anything (the difference between the two
  is usually the bug).
- **Both** (something looks wrong *and* misbehaves, or the problem appears
  only after a sequence of events): capture both -- set the debug level
  first, reproduce, `/wim snap all`, then `/reload` to flush everything to
  disk in one file.

## Related diagnostic commands

- `/wim focusstreams` -- A/B switch for WIM's community-stream focus pass at
  login (on by default; without it the client refuses sends to
  community-backed channels while WIM is loaded).
- `/wim channelrepair` -- opt-in, experimental: on logins where the community
  stream focus lands late, remove and re-add community channels to
  ChatFrame1. This is the only WIM feature that mutates saved chat-window
  configuration, which is why it is off unless explicitly enabled.

---
name: Bug report
about: Create a report to help us improve
title: ''
labels: ''
assignees: ''

---

**Game version**
The game flavor and build (ex: Retail 12.1.0, Classic, Mists, etc.)

**WIM version**
The addon version (shown in the options panel), and if you can, the build
id printed by `/wim snap all` (`Build <id>` in the confirmation line).

**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Lua errors**
If an error frame appeared (or BugSack caught one), paste the full error
text including the stack trace and Locals, inside a code fence.

**Diagnostic data**
WIM ships two capture tools; see DEBUGGING.md in the addon folder for full
detail. Which one to use depends on the kind of bug:

*The bug is behavioral* -- messages routed wrong, history missing, something
firing at the wrong time, errors during login:

1. `/wim debug 2` if chat messages/channels/communities are involved,
   `/wim debug 1` otherwise. The level persists across logins on purpose:
   for login-time problems, set it, then log fully out and back in.
2. `/wim debugclear`, then reproduce the problem.
3. Log out or `/reload` (the file is only written then), open
   `WTF/Account/<ACCOUNT>/<Realm>/<Character>/SavedVariables/WIM.lua`, and
   paste the `WIM3_DebugLog` lines (or attach the file). Keep the `===`
   header line -- it carries the version info.
4. `/wim debug 0` when done.

*The bug is visual* -- overlapping or misplaced elements, wrong textures or
colors, skin problems:

1. With the problem on screen, run `/wim snap all` (it also takes a
   screenshot).
2. If a `/reload` changes or fixes the appearance, snap again after it --
   the pair is far more useful than either alone.
3. `/reload` or log out to flush, then attach the same `WIM.lua` file (the
   snapshots are stored next to the debug log in `WIM3_Snapshots`) plus
   the screenshot(s) from your `Screenshots` folder.

*The bug is both, or appears only after a sequence of events* -- set the
debug level first, reproduce, `/wim snap all`, then `/reload`; everything
lands in the one `WIM.lua` file.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Additional context**
Anything else that seems relevant: other chat addons loaded, whether the
problem survives `/reload`, whether it started after a specific game patch
or WIM update.

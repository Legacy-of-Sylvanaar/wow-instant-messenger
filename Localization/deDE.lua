--[[
	Language Localization: deDE
	Translated by: Chiaki EU-Frostwolf <chiakiaccess@hotmail.com>
]]

WIM.AddLocale("deDE", {
    ["WIM (WoW Instant Messenger)"] = true,
    ["_Description"] = "WIM ist ein AddOn, welches einem das vertraute Gefühl über ein Chatsystem zu kommunizieren zurückbringt. In diesem Fenster kannst du WIM individualisieren, um es deinen Bedürfnissen anzupassen.",

    ["_DemoText"] = "Dies ist ein Demonstrationsfenster und ist nicht voll funktionsfähig. Platziere dieses Fenster an die Stelle, an der du alle anderen Fenster erzeugen möchtest. Sobald du fertig bist kannst du das Fenster schließen, um die Einstellungen zu speichern.",

    ["_DateFormat"] = "%d/%m/%Y",

    ["Yes"] = "Ja",
    ["No"] = "Nein",
    ["None"] = "Kein(e)",
    ["Cancel"] = "Abbrechen",
    ["Unknown"] = "Unbekannt",
    ["Click to update..."] = "Klicke um ein Update zu starten...",
    ["Usage"] = "Gebrauch",

    ["state_resting"] = "Ruhend",
    ["state_combat"] = "Kampf",
    ["state_pvp"] = "PVP",
    ["state_arena"] = "Arena",
    ["state_party"] = "Gruppeninstanz",
    ["state_raid"] = "Schlachtzuginstanz",
    ["state_other"] = "Normal (Sonstiges)",

    ["Options"] = "Einstellungen",

    ["Up"] = "Oben",
    ["Down"] = "Unten",
    ["Left"] = "Links",
    ["Right"] = "Rechts",
    ["Ignore"] = "Ignorieren",
    ["Block"] = "Blockieren",
    ["Enable WIM"] = "WIM aktivieren",

    ["Enable"] = "Aktivieren",
    ["Disable"] = "Deaktivieren",

    ["History"] = "Verlauf",
    ["Filters"] = "Filter",


    ["Window Created"] = "Fenster erstellt",
    ["Last Activity"] = "Letzte Aktivität",
    ["Alphabetical"] = "Alphabetisch",

    -- Class Names --
    ["Druid"] = LOCALIZED_CLASS_NAMES_MALE.DRUID,
    ["Hunter"] = LOCALIZED_CLASS_NAMES_MALE.HUNTER,
    ["Mage"] = LOCALIZED_CLASS_NAMES_MALE.MAGE,
    ["Paladin"] = LOCALIZED_CLASS_NAMES_MALE.PALADIN,
    ["Priest"] = LOCALIZED_CLASS_NAMES_MALE.PRIEST,
    ["Rogue"] = LOCALIZED_CLASS_NAMES_MALE.ROGUE,
    ["Shaman"] = LOCALIZED_CLASS_NAMES_MALE.SHAMAN,
    ["Warlock"] = LOCALIZED_CLASS_NAMES_MALE.WARLOCK,
    ["Warrior"] = LOCALIZED_CLASS_NAMES_MALE.WARRIOR,
    ["Death Knight"] = LOCALIZED_CLASS_NAMES_MALE.DEATHKNIGHT,
    ["Monk"] = LOCALIZED_CLASS_NAMES_MALE.MONK,
    ["Demon Hunter"] = LOCALIZED_CLASS_NAMES_MALE.DEMONHUNTER,
	["Evoker"] = LOCALIZED_CLASS_NAMES_MALE.EVOKER,

    -- Female Class Names --
    ["DruidF"] = LOCALIZED_CLASS_NAMES_FEMALE.DRUID,
    ["HunterF"] = LOCALIZED_CLASS_NAMES_FEMALE.HUNTER,
    ["MageF"] = LOCALIZED_CLASS_NAMES_FEMALE.MAGE,
    ["PaladinF"] = LOCALIZED_CLASS_NAMES_FEMALE.PALADIN,
    ["PriestF"] = LOCALIZED_CLASS_NAMES_FEMALE.PRIEST,
    ["RogueF"] = LOCALIZED_CLASS_NAMES_FEMALE.ROGUE,
    ["ShamanF"] = LOCALIZED_CLASS_NAMES_FEMALE.SHAMAN,
    ["WarlockF"] = LOCALIZED_CLASS_NAMES_FEMALE.WARLOCK,
    ["WarriorF"] = LOCALIZED_CLASS_NAMES_FEMALE.WARRIOR,
    ["Death KnightF"] = LOCALIZED_CLASS_NAMES_FEMALE.DEATHKNIGHT,
    ["MonkF"] = LOCALIZED_CLASS_NAMES_FEMALE.MONK,
    ["Demon HunterF"] = LOCALIZED_CLASS_NAMES_FEMALE.DEMONHUNTER,
	["EvokerF"] = LOCALIZED_CLASS_NAMES_FEMALE.EVOKER,

    ["Game Master"] = "Spielmeister",

    -- WIM.lua --
    ["Toggle WIM 'On' and 'Off'."] = "Schalte WIM 'Ein' oder 'Aus'.",

    -- Filters.lua --
    ["Whispers Sent by Addons"] = "Flüsternachrichten gesendet durch AddOns",
    ["WhisperSelect Part 1"] = "FlüsterAuswahl Teil 1",
    ["Example Spam Blocker"] = "Beispiel Spamblocker",
    ["WhisperSelect Part 2"] = "FlüsterAuswahl Teil 2",
    ["Filter Name"] = "Filtername",
    ["Filter By"] = "Filtern nach",
    ["Pattern"] = "Muster",
    ["User Type"] = "Spielertyp",
    ["Level"] = "Level",
    ["Friends"] = "Freunde",
    ["Guild Members"] = "Gildenmitglieder",
    ["Party Members"] = "Gruppenmitglieder",
    ["Raid Members"] = "Schlachtzugsmitglieder",
    ["Cross-Realm"] = "Realm-Übergreifend",
    ["Everyone"] = "Alle",
    ["User must be at least level:"] = "Spieler muss mindestens diesen Level haben:",
    ["Apply to messages received."] = "Für eingehende Nachrichten übernehmen.",
    ["Apply to messages sent."] = "Für ausgehende Nachrichten übernehmen.",
    ["Apply to:"] = "Anwenden auf:",
    ["All Classes"] = "Alle Klassen",
    ["Action to Perform:"] = "Durchzuführende Aktion:",
    ["Allow"] = "Erlauben",
    ["Ignore"] = "Ignorieren",
    ["Blocked"] = "Blockieren",
    ["Save"] = "Speichern",
    ["Cancel"] = "Abbrechen",
    ["Edit Filter"] = "Filter bearbeiten",
    ["Add Filter"] = "Filter hinzufügen",

    -- History.lua --
    ["WIM History Button"] = "WIM Verlaufsbutton",
    ["Click to view message history."] = "Klicken um den Nachrichtenverlauf anzuzeigen.",
    ["WIM pruned %d |4message:messages; from your history."] = "WIM hat %d |4message:messages; von deinem Nachrichtenverlauf gelöscht.",
    ["History Viewer"] = "Verlaufsanzeige",
    ["Filters"] = "Filter",
    ["Are you sure you want to delete all history saved for %s on %s?"] = "Bist du sicher, dass du sämtliche Nachrichtenverläufe gespeichert für %s auf %s löschen möchtest?",
    ["Search resulted in %d |4message:messages;."] = "Ergebnis der Suche resultiert in %d |4message:messages;.",
    ["No results found!"] = "Keine Ergebnisse gefunden!",
    ["Search"] = "Suche",
    ["Show All"] = "Alle anzeigen",
    ["Loading History"] = "Verlauf wird geladen",
    ["Chat View"] = "Chatansicht",
    ["Text View"] = "Textansicht",
    ["BBCode"] = "BBCode",
    ["WIM History Viewer"] = "WIM Verlaufsanzeige",
    ["Display history viewer."] = "Verlaufsanzeige anzeigen",

    -- ldb.lua --
    ["No New Messages"] = "Keine neuen Nachrichten",

    -- Menu.lua --
    ["Whispers"] = "Flüsternachrichten",
    ["Chat"] = true,

    -- Negotiate.lua --
    ["WIM Update Available!"] = "WIM Update verfügbar!",

    -- ShortcutBar.lua --
    ["Player Location"] = "Spieler Standort",
    ["Unknown"] = "Unbekannt",
    ["Click to update..."] = "Klicke um ein Update zu starten...",
    ["Invite to Party"] = "In die Gruppe einladen",
    ["Invite to Guild"] = "In die Gilde einladen",
    ["Add Friend"] = "Freund hinzufügen",
    ["Ignore Player"] = "Spieler ignorieren",
    ["Are you sure you want to\nignore %s?"] = "Bist du sicher, dass du \n %s ignorieren willst?",
	["Copy Name"] = "Namen kopieren",
	["Profile Links"] = "Profil-Links",
	["Location"] = "Standort",
	["Game"] = "Spiel",
	["Realm"] = "Realm",
	["Character"] = "Charakter",
	["Right-Click for profile links..."] = "Rechtsklick für Profil-Links...",

    -- Tutorials.lua --
    ["View Updates"] = "Updates ansehen",

    -- WhisperEngine.lua --
    ["Whisper Received!"] = "Flüsternachricht erhalten!",
    ["Recently Sent Messages"] = "Zuletzt gesendete Nachrichten",
    ["Users in %s"] = "Benutzer in %s",

    -- Clear.lua --
    ["This action will reload your user interface."] = "Dieser Vorgang wird dein Interface neu laden.",
    ["Do you want to continue?"] = "Willst du fortfahren?",
    ["You are about to restore WIM's filters to it's default settings!"] = "Du bist dabei die WIM Filtereinstellungen auf die Standardeinstellungen zurückzusetzen!",
    ["Usage"] = "Gebrauch",
    ["Clear various WIM data."] = "Lösche diverse WIM Daten.",

    -- SlashHandler.lua --
    ["WIM Slash Commands"] = "WIM Slash-Befehle",
    ["Hide or show {all, whisper, chat} windows."] = "Alle, Flüster- oder Chat-Fenster ein-/ausblenden.",
    ["To see a list of available WIM slash commands type:"] = "Um eine Liste von verfügbaren WIM-Befehlen zu erhalten gebe ein:",
    ["Display available slash commands."] = "Zeige verfügbare Slash-Befehle an.",
    ["Reload User Interface."] = "Lade Spieler-Interface neu.",

    -- TabHandler.lua --
    ["Manipulating Tabs"] = "Manipulation von Tabs",

    -- WindowHandler.lua --
    ["Window Resized!"] = "Fenstergröße angepasst!",
    ["Creating Tab Groups"] = "Erstellung von Tab-Gruppen",
    ["You can group two or many windows together by <Shift-Clicking> a window and dragging it on top of another."] = "Du kannst zwei oder mehrere Fenster zusammengruppieren indem du ein Fenster <Shift-Klickst> und es auf ein anderes ziehst.",
    ["Resizing Windows"] = "Größenanpassung von Fenstern",
    ["You can resize a window by holding <Shift> and dragging the bottom right corner of the window."] = "Du kannst die Größe eines Fensters anpassen, indem du <Shift> gedrückt hältst und die obere rechte Ecke des Fensters ziehst.",
    ["Demo Window"] = "Demonstrationsfenster",
    ["<Shift-Click> to close window."] = "<Shift-Klick> zum Schließen des Fensters.",
    ["Message Window Hidden"] = "Nachrichtenfenster versteckt",
    ["Default"] = "Standard",
    ["%s is Away From Keyboard: %s"] = "%s ist AFK (Away From Keyboard/Abwesend): %s",
    ["%s does not wish to be disturbed: %s"] = "%s möchte nicht gestört werden: %s",
    ["Right-Mouse Click!"] = "Rechtsklick!",
    ["There might be useful tools hidden under the message box. Right-Click to see them!"] = "Unter dem Nachrichtenfeld könnten nützliche Werkzeuge verborgen sein. Rechtsklick zum Anzeigen!",

    -- Options.lua --
    ["Display WIM's options."] = "WIM Optionen anzeigen.",
    ["Resetting WIM will clear all of your settings!"] = "Das Zurücksetzen von WIM wird sämtliche deiner Einstellungen löschen!",
    ["A reset will reload your user interface."] = "Ein Zurücksetzen wird deine Benutzeroberfläche neu laden.",
    ["Reset all options to default."] = "Alle Einstellungen zurücksetzen.",

    -- CoreOptions --
    ["Created By:"] = "Kreiert von:",
    ["Special Thanks:"] = "Besonderer Dank:",
    ["Enable WIM"] = "WIM aktivieren",
    ["Credits"] = "Danksagungen",
    ["This is a long message which contains both emoticons and urls 8). WIM's home is www.WIMAddon.com."] = "Dies ist eine lange Nachricht, die sowohl Emoticons/Smileys, als auch Internetadressen enthält 8). WIMs Homepage ist www.WIMAddon.com.",
    ["Preview"] = "Vorschau",
    ["Default Width"] = "Standardbreite",
    ["Default Height"] = "Standardhöhe",
    ["Window Scale"] = "Fensterskalierung",
    ["Set Window Spawn Location"] = "Stelle Erzeugungspunkt für Fenster ein",
    ["Up"] = "Oben",
    ["Down"] = "Unten",
    ["Left"] = "Links",
    ["Right"] = "Rechts",
    ["Version"] = true,
    ["Font Outline"] = "Schriftart-Außenlinie",
    ["Thin"] = "Dünn",
    ["Thick"] = "Dick",
    ["Allow"] = "Erlauben",
    ["Ignore"] = "Ignorieren",
    ["Block"] = "Blockieren",
    ["Protected"] = "Gesichert",
    ["Action:"] = "Aktion:",
    ["Occurrences:"] = "Vorfälle:",
    ["Delete Filter"] = "Filter löschen",
    ["History"] = "Nachrichtenverlauf",
    ["Messages"] = "Nachrichten",
    ["Record Chat"] = "Chat aufzeichnen",
    ["Maintenance"] = "Wartung",
    ["%d |4Week:Weeks;"] = "%d |4Woche:Wochen;",
    ["User Level"] = "Spielerlevel",
    ["Sounds"] = "Sounds",
	["Background"] = BACKGROUND,
	["Low"] = LOW,
	["Medium"] = "Mittel",
	["High"] = "Hoch",
	["Dialog"] = ENABLE_DIALOG,
	["Tooltip"] = true,

    -- TabManagement.lua --

    -- Talent Specs --
    ["Hybrid"] = "Hybride",

    -- Filters.lua --
    ["Show Alert"] = "Warnung anzeigen",
    ["WIM has blocked a message from %s."] = "WIM hat eine Nachricht von %s blockiert.",
    ["View Blocked Message"] = "Blockierte Nachricht anzeigen",
    ["Blocked Message"] = "Blockierte Nachricht",

    -- MinimapIcon.lua
    ["Show Unread Messages"] = "Zeige ungelesene Nachrichten",
    ["Show All Windows"] = "Zeige alle Fenster",
    ["Hide All Windows"] = "Verberge alle Fenster",

    -- Emoticons.lua --
    ["Also"] = "Auch",
    ["More"] = "Mehr",
    ["Emoticons"] = "Emoticons",

    -- Expose.lua --
    ["Your conversations have been hidden in order to clear your screen while in combat. To disable this feature type"] = "Deine Gespräche wurden ausgeblendet, um den Bildschirm im Kampf zu bereinigen. Zum Deaktivieren gib ein:",
    ["Expose"] = "Expose",

    -- ChatEngine.lua --
    ["Have WIM monitor this channel."] = "WIM soll diesen Kanal überwachen.",
    ["Never Suppress"] = "Nie unterdrücken",
    ["No History"] = "Kein Verlauf",
    ["World Chat"] = "Weltchat",
    ["Custom Chat"] = "Benutzerdefinierter Chat",
    ["Community Chat"] = "Community-Chat",
    ["Chat"] = "Chat",
    ["No Sound"] = "Kein Sound",

    -- OffScreenTracker.lua --
    ["WIM Window Off Screen"] = "WIM-Fenster außerhalb des Bildschirms",
    ["Click to reposition."] = "Klicken zum Neupositionieren.",

    -- Whisper Mode Warnings --
    ["Set whispers to In-line"] = "Flüstern auf Inline setzen",
    ["It is recommended for whispers to be set to in-line in order to handle their behavior properly."] = "Es wird empfohlen, Flüstern auf Inline zu setzen, um das Verhalten korrekt zu verarbeiten.",

    -- Skins --
    ["Blue"] = "Blau",
    ["Green"] = "Grün",
    ["Red"] = "Rot",
    ["Yellow"] = "Gelb",

    -- Battle.net friend consolidation (History Viewer)
    ["Battle.net Friends"] = "Battle.net-Freunde",
    ["Are you sure you want to delete ALL history saved with %s, across every realm and every character on this account?"] = "Bist du sicher, dass du ALLE mit %s gespeicherten Nachrichtenverläufe über alle Realms und Charaktere dieses Accounts löschen möchtest?",

    -- Per-date deletion from the History Viewer filter list
    ["Are you sure you want to delete the %s history with %s across every realm and character on this account?"] = "Bist du sicher, dass du die Nachrichtenverläufe vom %s mit %s über alle Realms und Charaktere dieses Accounts löschen möchtest?",
    ["Are you sure you want to delete the %s history for %s across every character on %s?"] = "Bist du sicher, dass du die Nachrichtenverläufe vom %s für %s über alle Charaktere auf %s löschen möchtest?",
    ["Are you sure you want to delete the %s history for %s on %s?"] = "Bist du sicher, dass du die Nachrichtenverläufe vom %s für %s auf %s löschen möchtest?",


    -- Modern options panel --

    -- Modern skin styling --
    ["None (game default)"] = "Keiner (Spielstandard)",
    ["Draws the window frame background only around the message area, so a clear message area background (None or Transparent) shows the game world behind the window."] = "Zeichnet den Fensterrahmen-Hintergrund nur um den Nachrichtenbereich, sodass ein transparenter Hintergrund des Nachrichtenbereichs (Keiner oder Transparent) die Spielwelt hinter dem Fenster zeigt.",

    -- Roleplay profiles (Total RP 3 / Mary Sue Protocol) --
    ["Roleplay Profiles"] = "Rollenspiel-Profile",
    ["Open RP Profile"] = "RP-Profil öffnen",
    ["Whisper windows show the selected fields from the partner's Total RP 3 or Mary Sue Protocol profile. Fields left unselected -- or without profile data -- keep the standard display."] = "Flüsterfenster zeigen die ausgewählten Felder aus dem Total-RP-3- oder Mary-Sue-Protocol-Profil des Gegenübers. Nicht ausgewählte Felder – oder Felder ohne Profildaten – behalten die Standarddarstellung.",
    ["First Name"] = "Vorname",
    ["Last Name"] = "Nachname",
    ["Title"] = "Titel",
    ["Full Title"] = "Voller Titel",
    ["Race"] = "Volk",
    ["Class"] = "Klasse",
    ["Portrait"] = "Porträt",
    ["Name & Class Color"] = "Farbe von Name & Klasse",
    ["The profile's first name, shown as the window's name text."] = "Der Vorname des Profils, als Namenstext des Fensters angezeigt.",
    ["The profile's last name, shown as the window's name text."] = "Der Nachname des Profils, als Namenstext des Fensters angezeigt.",
    ["The short title, shown on the window's details line."] = "Der kurze Titel, in der Detailzeile des Fensters angezeigt.",
    ["The long title, shown on the window's details line and portrait tooltip."] = "Der lange Titel, in der Detailzeile des Fensters und im Porträt-Tooltip angezeigt.",
    ["The custom race, replacing the character's race on the details line."] = "Das eigene Volk, das das Volk des Charakters in der Detailzeile ersetzt.",
    ["The custom class, replacing the character's class on the details line."] = "Die eigene Klasse, die die Klasse des Charakters in der Detailzeile ersetzt.",
    ["The profile's icon, replacing the class icon."] = "Das Symbol des Profils, das das Klassensymbol ersetzt.",
    ["The profile's custom color, applied to the window's name text and to the class on the details line."] = "Die eigene Farbe des Profils, angewandt auf den Namenstext des Fensters und die Klasse in der Detailzeile.",
    ["Apply filter to character menus"] = "Filter auf Charaktermenüs anwenden",

    -- History Viewer filters --
    ["No Filter"] = "Kein Filter",
    ["Relative Dates"] = "Relative Daten",
    ["%d or more"] = "%d oder mehr",
    ["Fewer than %d"] = "Weniger als %d",
    ["Results Filtered"] = "Ergebnisse gefiltert",
    ["-- Results Filtered --"] = "-- Ergebnisse gefiltert --",
    ["Results are hidden by the active filter. Click to open the Filters menu."] = "Ergebnisse werden durch den aktiven Filter ausgeblendet. Klicke, um das Filtermenü zu öffnen.",
    ["Click to change how history is filtered."] = "Klicke, um die Verlaufsfilterung zu ändern.",
    ["Click to open the Filters menu."] = "Klicke, um das Filtermenü zu öffnen.",
    ["Clicking the %s button on the message window will show that user's history in WIM's History Viewer."] = "Ein Klick auf die Schaltfläche %s im Nachrichtenfenster zeigt den Verlauf dieses Spielers in WIMs Verlaufsanzeige.",

    -- Message input & formatting --
    ["Caps how far the input field grows; past the limit the message scrolls inside it."] = "Begrenzt, wie weit das Eingabefeld wächst; über der Grenze scrollt die Nachricht darin.",
    ["The most lines the input field grows to before the message scrolls inside it."] = "Die maximale Anzahl an Zeilen, auf die das Eingabefeld wächst, bevor die Nachricht darin scrollt.",
    ["The input field wraps long messages onto multiple lines, growing downward with the message instead of scrolling it on one line."] = "Das Eingabefeld bricht lange Nachrichten auf mehrere Zeilen um und wächst mit der Nachricht nach unten, statt sie in einer Zeile zu scrollen.",
    ["Timestamp Format"] = "Zeitstempel-Format",
    ["Bracket Style"] = "Klammerstil",
    ["Colors"] = "Farben",
    ["Sound"] = "Sound",

    -- Chat type options --
    ["Record"] = "Aufzeichnen",

    -- Help, bug reports & links --
    ["Found a bug?"] = "Fehler gefunden?",
    ["Report a Bug"] = "Fehler melden",
    ["Reports are welcome! Click below and follow the instructions in the bug report template."] = "Meldungen sind willkommen! Klicke unten und folge den Anweisungen in der Vorlage für Fehlerberichte.",
    ["Show GitHub Link"] = "GitHub-Link anzeigen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Click to show the link for copying."] = "Klickt, um den Link zum Kopieren anzuzeigen.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Press Ctrl+C to copy the link, then open it in your browser."] = "Drücke Strg+C, um den Link zu kopieren, und öffne ihn in deinem Browser.",

    -- Debugging & development slash commands --
    ["Clear the captured debug log."] = "Gespeichertes Debug-Protokoll löschen.",
    ["Set debugging level: /wim debug [0|1|2]. 2 adds verbose chat event tracing."] = "Debugging-Stufe festlegen: /wim debug [0|1|2]. 2 fügt ausführliche Chat-Ereignisverfolgung hinzu.",
    ["Snapshot the next modern context menu while it is open."] = "Momentaufnahme des nächsten modernen Kontextmenüs erstellen, während es geöffnet ist.",
    ["Snapshot UI widget state for skin development: /wim snap all | <Frame.Dot.Path> (bare /wim snap lists the arguments)."] = "Zustand der UI-Widgets für die Skin-Entwicklung festhalten: /wim snap all | <Frame.Dot.Path> (/wim snap ohne Argument listet die Möglichkeiten auf).",

    -- Tutorials & notices --
    ["WIM is currently running. To access WIM's wide array of options type:"] = "WIM läuft derzeit. Um Zugang zu WIMs umfangreichen Optionen zu erhalten, tippe:",
    ["WIM's message window has been hidden to WIM's Minimap Icon. If you want to end a conversation, you may do so by <Shift-Clicking> the close button."] = "Das Nachrichtenfenster wurde auf WIMs Minimap-Symbol versteckt. Wenn du ein Gespräch beenden möchtest, kannst du dies per <Shift-Klick> auf die Schließen-Schaltfläche tun.",
    ["If you want all windows to be this size, you can set the default window size within WIM's options."] = "Wenn alle Fenster diese Größe haben sollen, kannst du die Standardfenstergröße in WIMs Einstellungen festlegen.",
    ["You can <Shift-Click> a tab and drag it out into it's own window."] = "Du kannst einen Tab per <Shift-Klick> greifen und in ein eigenes Fenster herausziehen.",
    ["You received a whisper which was hidden due to your current activity. You can change how whispers behave in WIM's options by typing"] = "Du hast eine Flüsternachricht erhalten, die aufgrund deiner aktuellen Aktivität ausgeblendet wurde. Wie sich Flüstern verhält, kannst du in WIMs Einstellungen ändern, indem du tippst",

    -- Community channel maintenance --
    ["Toggle the experimental community channel re-add repair (mutates chat window channels)."] = "Aktiviert die experimentelle Reparatur zum erneuten Beitreten von Community-Kanälen (verändert die Kanäle der Chatfenster).",
    ["Toggle whether WIM focuses community streams at login."] = "Legt fest, ob WIM beim Login Community-Streams fokussiert.",

    -- Misc --
    ["Older Than"] = "Älter als", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation

    -- History Viewer filter modes --
    ["Sent by Me"] = "Von mir gesendet",
    ["Sent by Them"] = "Von anderen gesendet",
    ["Active Days"] = "Aktive Tage",
    ["Last 1 Day"] = "Letzter Tag",
    ["Last 7 Days"] = "Letzte 7 Tage",
    ["Last 30 Days"] = "Letzte 30 Tage",
    ["Last 90 Days"] = "Letzte 90 Tage",


    -- Chrome background names --
    ["None (fully clear)"] = "Keine (vollständig transparent)",
    ["Transparent"] = "Transparent",
    ["Rock"] = "Fels",
    ["Marble"] = "Marmor",
    ["Dark Marble"] = "Dunkler Marmor",
    ["Bank"] = "Bank",
    ["Guild Vault"] = "Gildenbank",
    ["Dark Sandstone"] = "Dunkler Sandstein",
    ["Parchment (Tileable)"] = "Pergament (kachelbar)",
    ["Quest Parchment"] = "Questpergament",
    ["Raid Frame"] = "Schlachtzugsfenster",
    ["Destiny"] = "Schicksal",
    ["Stationery (Auction)"] = "Briefpapier (Auktion)",
    ["Stationery (Illustrated)"] = "Briefpapier (illustriert)",
    ["Stationery (Orgrimmar)"] = "Briefpapier (Orgrimmar)",
    ["Stationery (Thunder Bluff)"] = "Briefpapier (Donnerfels)",
    ["Stationery (Undercity)"] = "Briefpapier (Unterstadt)",
    ["Stationery (Plain)"] = "Briefpapier (einfach)",
    ["World Map 1"] = "Weltkarte 1",
    ["World Map 2"] = "Weltkarte 2",
    ["Achievement Stats"] = "Erfolgsstatistiken",
    ["Adventure Map Parchment"] = "Abenteuerkarten-Pergament",
    ["Collections"] = "Sammlungen",
    ["Frame: Alliance"] = "Rahmen: Allianz",
    ["Frame: Horde"] = "Rahmen: Horde",
    ["Frame: Neutral"] = "Rahmen: Neutral",
    ["Frame: Marine"] = "Rahmen: Marine",
    ["Frame: Mechagon"] = "Rahmen: Mechagon",
    ["Frame: Kyrian"] = "Rahmen: Kyrianer",
    ["Frame: Necrolord"] = "Rahmen: Nekrolords",
    ["Frame: Night Fae"] = "Rahmen: Nachtfey",
    ["Frame: Venthyr"] = "Rahmen: Venthyr",
    ["Frame: Oribos"] = "Rahmen: Oribos",
    ["Frame: Dragonflight"] = "Rahmen: Dragonflight",
    ["Frame: The War Within"] = "Rahmen: The War Within",
    ["Class Hall"] = "Klassenhalle",
    ["Class Hall (Internal)"] = "Klassenhalle (intern)",
    ["Garrison Landing Page"] = "Garnisonslandeplatz",
    ["Garrison Mission"] = "Garnisonsmission",
    ["Ship Mission Parchment"] = "Schiffsmissions-Pergament",
    ["Garrison UI"] = "Garnison-UI",
    ["Garrison UI 2"] = "Garnison-UI 2",
    ["Credits: Classic"] = "Abspann: Classic",
    ["Credits: Burning Crusade"] = "Abspann: Burning Crusade",
    ["Credits: Wrath"] = "Abspann: Wrath",
    ["Credits: Cataclysm"] = "Abspann: Cataclysm",
    ["Credits: Mists of Pandaria"] = "Abspann: Mists of Pandaria",
    ["Credits: Warlords"] = "Abspann: Warlords",
    ["Credits: Legion"] = "Abspann: Legion",
    ["Credits: Battle for Azeroth"] = "Abspann: Battle for Azeroth",


    -- Skin & options style notices --


    -- Slash command feedback --
    ["WIM: community chat settings unavailable."] = "WIM: Community-Chat-Einstellungen nicht verfügbar.",
    ["WIM community stream auto-focus ON. Takes effect at next login."] = "WIM-Community-Stream-Autofokus AN. Wird beim nächsten Login wirksam.",
    ["WIM community stream auto-focus OFF - the client may refuse sends to community channels. Takes effect at next login."] = "WIM-Community-Stream-Autofokus AUS - der Client kann Nachrichten an Community-Kanäle ablehnen. Wird beim nächsten Login wirksam.",
    ["WIM channel re-add repair ON (experimental). On logins where the community stream is focused late, WIM removes and re-adds community channels to ChatFrame1 about 8s after login. If a re-add fails the channel must be restored from the chat settings UI."] = "WIM-Kanal-Reparatur AN (experimentell). Bei Logins, in denen der Community-Stream spät fokussiert wird, entfernt WIM Community-Kanäle etwa 8 Sekunden nach dem Login aus ChatFrame1 und fügt sie neu hinzu. Schlägt das Neuhinzufügen fehl, muss der Kanal über die Chat-Einstellungen wiederhergestellt werden.",
    ["WIM: attempting a repair now (see /wim debug output)."] = "WIM: Reparatur wird jetzt versucht (siehe Ausgabe von /wim debug).",
    ["WIM channel re-add repair OFF. No further attempts this session."] = "WIM-Kanal-Reparatur AUS. Keine weiteren Versuche in dieser Sitzung.",
    ["WIM: queued options open canceled."] = "WIM: Geplantes Öffnen der Optionen abgebrochen.",

    -- Placeholder: Translated with Google Translate, pending a natural language speaker to verify the translation.
    ["Click to switch between Say, Yell, and Emote."] = "Klicken, um zwischen Sagen, Schreien und Emote zu wechseln.",
    ["Say, Yell, or Emote"] = "Sagen, Schreien oder Emote",
    ["The message being typed takes the color of the chat type it will send as, like the game's own chat box."] = "Die eingegebene Nachricht erhält die Farbe des Chat-Typs, in dem sie gesendet wird, wie im Chatfenster des Spiels.",
    ["Battle.net Whispers"] = "Battle.net-Flüstern",
    ["Filter Editor"] = "Filter-Editor",
    ["Draws the frame background only around the filter area, so a clear filter area background (None or Transparent) shows the game world behind the editor."] = "Zeichnet den Fensterhintergrund nur um den Filterbereich, sodass ein durchsichtiger Filterbereich (Kein oder Transparent) die Spielwelt hinter dem Editor zeigt.",

    -- Modern options, Edit Mode, and dialogs --
    ["%d chat message(s) could not be recovered after the chat lockdown."] = "%d Chatnachricht(en) konnten nach der Chatsperre nicht wiederhergestellt werden.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["%d unsupported User Level filter(s) were removed."] = "%d nicht unterstützte Spielerstufen-Filter wurden entfernt.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["/reply Counts Sent Whispers"] = "/reply zählt gesendete Flüsternachrichten", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["A thin border along the screen edge signals that windows are hidden."] = "Ein dünner Rand am Bildschirmrand zeigt an, dass Fenster ausgeblendet sind.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Above everything, at tooltip level."] = "Über allem, auf Tooltip-Ebene.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Above most interface frames."] = "Über den meisten Interface-Fenstern.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Above the background layer."] = "Über der Hintergrundebene.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Actions"] = "Aktionen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Addon Compartment Entry"] = "Eintrag im Addon-Fach", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["All windows hide when combat starts and are restored when it ends."] = "Alle Fenster werden bei Kampfbeginn ausgeblendet und nach dem Kampf wiederhergestellt.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Also captures emotes."] = "Erfasst auch Emotes.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Animates closing windows toward the minimap, and the slide used by combat auto-hide and the show/hide key binding."] = "Animiert schließende Fenster zur Minikarte hin sowie das Gleiten beim automatischen Ausblenden im Kampf und bei der Tastenbelegung zum Ein-/Ausblenden.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Animation"] = "Animation", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Animation Direction"] = "Animationsrichtung", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Appearance"] = "Aussehen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Applies the filter list below to captured chat messages. Community chat is not filtered."] = "Wendet die Filterliste unten auf erfasste Chatnachrichten an. Community-Chat wird nicht gefiltert.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Applies to the minimap button, the addon compartment entry, and data broker launchers."] = "Gilt für den Minikartenknopf, den Eintrag im Addon-Fach und Data-Broker-Starter.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Applies to whisper and chat history alike. Pruning runs at login."] = "Gilt gleichermaßen für Flüster- und Chatverlauf. Das Aufräumen läuft beim Einloggen.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Apply To"] = "Anwenden auf", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Arrow keys keep controlling the game while the input box has focus; hold Alt to move the text cursor instead."] = "Die Pfeiltasten steuern weiter das Spiel, während das Eingabefeld den Fokus hat; haltet Alt gedrückt, um stattdessen den Textcursor zu bewegen.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["At login WIM focuses your community chat streams so the client accepts sends to their channel numbers. Takes effect at the next login and needs at least one channel type captured."] = "Beim Einloggen fokussiert WIM Eure Community-Chatstreams, damit der Client das Senden an ihre Kanalnummern akzeptiert. Wird beim nächsten Einloggen wirksam und erfordert mindestens einen erfassten Kanaltyp.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Auto Focus"] = "Automatischer Fokus", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Backgrounds, input field, and roleplay profile options for the WIM Modern skin."] = "Hintergründe, Eingabefeld und Rollenspielprofil-Optionen für den Skin WIM Modern.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Base"] = "Basis", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Battle.net Received"] = "Battle.net empfangen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Battle.net Sent"] = "Battle.net gesendet", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Behind the standard interface."] = "Hinter dem Standard-Interface.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Blizzard is restricting chat right now. Your message was not sent."] = "Blizzard schränkt den Chat gerade ein. Eure Nachricht wurde nicht gesendet.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Bracket Names"] = "Namen in Klammern", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Briefly turns game audio back on so a notification can be heard while all sound is disabled. The Master channel alone cannot get past that setting."] = "Schaltet den Spielton kurz wieder ein, damit eine Benachrichtigung hörbar ist, während der gesamte Ton deaktiviert ist. Der Master-Kanal allein kommt an dieser Einstellung nicht vorbei.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["By conversation name."] = "Nach Gesprächsname.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Calculate Minimum Size"] = "Mindestgröße berechnen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Cap Stored Messages"] = "Gespeicherte Nachrichten begrenzen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Capture"] = "Erfassen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Capture Community Channels"] = "Community-Kanäle erfassen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Capture Custom Channels"] = "Eigene Kanäle erfassen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Capture World Channels"] = "Weltkanäle erfassen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Capture community channels, set per-channel exceptions, and keep their chat channels working."] = "Community-Kanäle erfassen, Ausnahmen pro Kanal festlegen und ihre Chatkanäle funktionsfähig halten.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Capture world and custom channels and set per-channel exceptions."] = "Welt- und eigene Kanäle erfassen und Ausnahmen pro Kanal festlegen.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Cascade Direction"] = "Kaskadenrichtung", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Cascade Windows"] = "Fenster kaskadieren", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Channels"] = "Kanäle", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Chat Follows Focus Rules"] = "Chat folgt den Fokusregeln", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Chat Sounds"] = "Chat-Töne", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Chat Types"] = "Chattypen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Chat windows join the whisper tab group instead of their own, even while Group Whispers is off."] = "Chatfenster reihen sich in die Flüster-Tabgruppe ein statt in eine eigene, auch wenn „Flüstern gruppieren“ aus ist.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Chat windows opened from WIM's menus normally take focus immediately; with this on they follow the pop-up focus rules instead."] = "Aus WIMs Menüs geöffnete Chatfenster erhalten normalerweise sofort den Fokus; mit dieser Option folgen sie stattdessen den Pop-up-Fokusregeln.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Chat windows share one tabbed window. Does not apply to windows already opened."] = "Chatfenster teilen sich ein Fenster mit Tabs. Gilt nicht für bereits geöffnete Fenster.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Check to use alternate pop-up rules for this situation. Unchecked, the Base rules apply."] = "Aktivieren, um für diese Situation abweichende Pop-up-Regeln zu verwenden. Deaktiviert gelten die Basisregeln.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Choose what WIM captures: whispers, chat types, and channels."] = "Legt fest, was WIM erfasst: Flüstern, Chattypen und Kanäle.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Clamp to Screen"] = "Am Bildschirm halten", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Class-Colored Names"] = "Namen in Klassenfarbe", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Click Hold Limit"] = "Klick-Haltegrenze", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Click to Release Focus"] = "Klick gibt Fokus frei", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Clickable Links"] = "Anklickbare Links", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Clicking the game world releases WIM's keyboard focus so movement keys control your character again. Not while in combat."] = "Ein Klick in die Spielwelt gibt WIMs Tastaturfokus frei, sodass die Bewegungstasten wieder Euren Charakter steuern. Nicht im Kampf.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Clicks held longer than this are treated as camera turns and keep WIM's focus."] = "Länger gehaltene Klicks gelten als Kameradrehung und behalten WIMs Fokus.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Combat Auto-Hide"] = "Automatisch ausblenden im Kampf", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Combat hiding only happens inside dungeons, raids, battlegrounds, and arenas."] = "Das Ausblenden im Kampf erfolgt nur in Dungeons, Schlachtzügen, Schlachtfeldern und Arenen.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Communities"] = "Communities", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Content Background"] = "Inhaltshintergrund", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Continuation lines of wrapped messages are indented."] = "Folgezeilen umgebrochener Nachrichten werden eingerückt.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Conversations"] = "Gespräche", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Custom %s Rules"] = "Eigene Regeln: %s", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Custom Channels"] = "Eigene Kanäle", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Custom Rules"] = "Eigene Regeln", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Defaults"] = "Standardwerte", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Delete"] = "Löschen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Delete All History"] = "Gesamten Verlauf löschen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Delete Old Messages"] = "Alte Nachrichten löschen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Distinct Chat Sounds"] = "Eigene Chat-Töne", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Distinct Whisper Sounds"] = "Eigene Flüster-Töne", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Do not play sounds for this channel, whatever the Notifications page plays."] = "Für diesen Kanal keine Töne abspielen, unabhängig von der Seite „Benachrichtigungen“.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Do not record history for this channel, whatever History > Recording records."] = "Für diesen Kanal keinen Verlauf aufzeichnen, unabhängig von Verlauf > Aufzeichnung.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Draws the frame background only around the panels, so a clear panel background (None or Transparent) shows the game world behind the viewer."] = "Zeichnet den Rahmenhintergrund nur um die Bereiche, sodass ein klarer Bereichshintergrund (Keiner oder Transparent) die Spielwelt hinter der Anzeige zeigt.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Each message is prefixed with the time it arrived."] = "Jeder Nachricht wird die Empfangszeit vorangestellt.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Edit Mode"] = "Bearbeitungsmodus", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Erases every recorded conversation and the archive for every character on this account, then reloads the interface."] = "Löscht jedes aufgezeichnete Gespräch und das Archiv für jeden Charakter dieses Accounts und lädt dann das Interface neu.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Error Messages"] = "Fehlermeldungen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Escape Hides Windows"] = "Escape blendet Fenster aus", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Every whisper is recorded."] = "Jede Flüsternachricht wird aufgezeichnet.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Fade When Inactive"] = "Bei Inaktivität ausblenden", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Fades the window frame, header, and buttons; message and input text stay opaque. Modern skins keep their frame art opaque."] = "Blendet Fensterrahmen, Kopfzeile und Schaltflächen aus; Nachrichten- und Eingabetext bleiben deckend. Moderne Skins behalten ihre Rahmengrafik deckend.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Filter Chat"] = "Chat filtern", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Filter Panel Background"] = "Hintergrund des Filterbereichs", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Filter Whispers"] = "Flüstern filtern", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Filters run top to bottom; the first match wins. Allow lets a message through, Ignore hides it silently, Block hides it and, with Show Alert, tells you in the chat frame with a link to view it."] = "Filter laufen von oben nach unten; der erste Treffer gewinnt. Erlauben lässt eine Nachricht durch, Ignorieren verbirgt sie stillschweigend, Blockieren verbirgt sie und meldet es Euch mit „Hinweis anzeigen“ im Chatfenster mit einem Link zum Ansehen.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Focus & Input"] = "Fokus & Eingabe", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Focus Streams at Login"] = "Streams beim Einloggen fokussieren", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Font"] = "Schriftart", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Font Size"] = "Schriftgröße", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Force Blizzard's chat messaging lockdown for testing (on|off, does not persist)."] = "Blizzards Chatsperre zum Testen erzwingen (on|off, wird nicht gespeichert).", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Formatting"] = "Formatierung", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Frame Background"] = "Rahmenhintergrund", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Friends & guild"] = "Freunde & Gilde", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Friends and Battle.net friends."] = "Freunde und Battle.net-Freunde.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Friends only"] = "Nur Freunde", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Friends, Battle.net friends, and guild members."] = "Freunde, Battle.net-Freunde und Gildenmitglieder.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Friends, Battle.net friends, guild members, and your current party and raid get through; whispers from anyone else are ignored. This drives the two WhisperSelect entries in the filter list below."] = "Freunde, Battle.net-Freunde, Gildenmitglieder sowie Eure aktuelle Gruppe und Euer Schlachtzug kommen durch; Flüsternachrichten von allen anderen werden ignoriert. Dies steuert die beiden WhisperSelect-Einträge in der Filterliste unten.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Group Chat Windows"] = "Chatfenster gruppieren", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Group Whispers"] = "Flüstern gruppieren", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Group windows into shared tab strips."] = "Fenster in gemeinsamen Tableisten gruppieren.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Guild members."] = "Gildenmitglieder.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Guild only"] = "Nur Gilde", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Hidden-Windows Indicator"] = "Anzeige für ausgeblendete Fenster", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Hide During Combat"] = "Im Kampf ausblenden", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Hide windows during combat and restore them after."] = "Fenster im Kampf ausblenden und danach wiederherstellen.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Hides these messages from the game's chat frame so they appear only in WIM. Per-type and per-channel 'Never Suppress' exceptions on the Conversations pages win. A message is never hidden while its WIM window has not yet been shown."] = "Verbirgt diese Nachrichten im Chatfenster des Spiels, sodass sie nur in WIM erscheinen. Ausnahmen „Nie unterdrücken“ pro Typ und pro Kanal auf den Gesprächsseiten haben Vorrang. Eine Nachricht wird nie verborgen, solange ihr WIM-Fenster noch nicht angezeigt wurde.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Hiding"] = "Ausblenden", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Hiding waits until you finish typing your message."] = "Das Ausblenden wartet, bis Ihr Eure Nachricht fertig getippt habt.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["History Preview Received"] = "Verlaufsvorschau empfangen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["History Preview Sent"] = "Verlaufsvorschau gesendet", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Hover Item Tooltips"] = "Gegenstands-Tooltips beim Überfahren", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Hovering an item link in a message shows its tooltip without clicking."] = "Das Überfahren eines Gegenstandslinks in einer Nachricht zeigt dessen Tooltip ohne Klick.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["How messages are formatted and displayed."] = "Wie Nachrichten formatiert und angezeigt werden.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Ignore Arrow Keys"] = "Pfeiltasten ignorieren", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["In-Line Whisper Mode"] = "Flüstermodus „Im Chat“", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Includes emotes."] = "Einschließlich Emotes.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Includes raid warnings."] = "Einschließlich Schlachtzugswarnungen.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Incoming Chat"] = "Eingehender Chat", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Incoming Whispers"] = "Eingehendes Flüstern", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Incoming whispers always open in WIM while it is enabled; this additionally redirects typing /w and /r in the game's chat box into a WIM window. Not while in combat."] = "Eingehende Flüsternachrichten öffnen sich immer in WIM, solange es aktiviert ist; diese Option leitet zusätzlich das Tippen von /w und /r im Chatfeld des Spiels in ein WIM-Fenster um. Nicht im Kampf.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Indent Wrapped Lines"] = "Umgebrochene Zeilen einrücken", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Indicator"] = "Anzeige", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Indicator Thickness"] = "Dicke der Anzeige", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Input Field"] = "Eingabefeld", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Keep Focus"] = "Fokus behalten", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Keeps at most this many messages per conversation. Applies to whisper and chat history alike."] = "Behält höchstens so viele Nachrichten pro Gespräch. Gilt gleichermaßen für Flüster- und Chatverlauf.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Keeps the keyboard focus in the input box after sending a message."] = "Behält den Tastaturfokus nach dem Senden einer Nachricht im Eingabefeld.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Keyboard focus and input behavior."] = "Tastaturfokus und Eingabeverhalten.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Known Senders Only"] = "Nur bekannte Absender", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Launcher"] = "Starter", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Launcher Alerts"] = "Starter-Hinweise", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Level with dialog windows."] = "Auf Höhe von Dialogfenstern.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Level with most interface frames."] = "Auf Höhe der meisten Interface-Fenster.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Limit Height"] = "Höhe begrenzen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Links & Emoticons"] = "Links & Emoticons", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Master switch for this channel type; individual channels are captured with the Capture flag below."] = "Hauptschalter für diesen Kanaltyp; einzelne Kanäle werden mit der Markierung „Erfassen“ unten erfasst.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Maximum Lines"] = "Maximale Zeilen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Menus & Tooltips"] = "Menüs & Tooltips", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Message Area Background"] = "Hintergrund des Nachrichtenbereichs", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Message Format"] = "Nachrichtenformat", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Message Windows"] = "Nachrichtenfenster", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Message colors."] = "Nachrichtenfarben.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Message font, outline, and size."] = "Schriftart, Umriss und Größe der Nachrichten.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Message suppression requires the game's Social > Whisper Mode setting to be In-line; without it, suppressed whispers would vanish into a popout chat tab."] = "Die Nachrichtenunterdrückung erfordert, dass die Spieleinstellung Soziales > Flüstermodus auf „Im Chat“ steht; andernfalls würden unterdrückte Flüsternachrichten in einem abgetrennten Chat-Tab verschwinden.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Messages Received"] = "Empfangene Nachrichten", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Messages Sent"] = "Gesendete Nachrichten", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Messages per Conversation"] = "Nachrichten pro Gespräch", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Minimap Button"] = "Minikartenknopf", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Most recently active conversation first."] = "Zuletzt aktives Gespräch zuerst.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Multi-Line Input"] = "Mehrzeilige Eingabe", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Native Input Colors"] = "Native Eingabefarben", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Navigation List Background"] = "Hintergrund der Navigationsliste", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Never Pop Up"] = "Nie aufklappen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Never have this window pop-up on my screen. Overrides Windows > Pop-up Rules."] = "Dieses Fenster nie auf meinem Bildschirm aufklappen lassen. Übersteuert Fenster > Pop-up-Regeln.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Never suppress messages from the default chat frame. Overrides 'Show Only in WIM' under Windows > Pop-up Rules."] = "Nachrichten im Standard-Chatfenster nie unterdrücken. Übersteuert „Nur in WIM anzeigen“ unter Fenster > Pop-up-Regeln.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["New windows that would overlap are offset in the chosen direction. Whisper windows do not cascade while Group Whispers is on, nor chat windows while Group Chat Windows is on. Applies to windows opened after the change."] = "Neue Fenster, die sich überlappen würden, werden in die gewählte Richtung versetzt. Flüsterfenster kaskadieren nicht, solange „Flüstern gruppieren“ aktiv ist, Chatfenster nicht, solange „Chatfenster gruppieren“ aktiv ist. Gilt für nach der Änderung geöffnete Fenster.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["No one (GM whispers only)"] = "Niemand (nur GM-Flüstern)", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Nothing is recorded except game master whispers."] = "Außer Gamemaster-Flüstern wird nichts aufgezeichnet.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Notifications"] = "Benachrichtigungen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Oldest conversation first."] = "Ältestes Gespräch zuerst.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Only While in an Instance"] = "Nur in einer Instanz", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Open History Viewer"] = "Verlaufsanzeige öffnen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Opens a placement window; drag it to where new windows should appear, then close it to save the spot."] = "Öffnet ein Platzierungsfenster; zieht es dorthin, wo neue Fenster erscheinen sollen, und schließt es, um die Position zu speichern.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Opens the window when a message arrives in this situation."] = "Öffnet das Fenster, wenn in dieser Situation eine Nachricht eintrifft.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Opens the window when you send a message in this situation."] = "Öffnet das Fenster, wenn Ihr in dieser Situation eine Nachricht sendet.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Optional different sounds for whispers from particular senders."] = "Optional andere Töne für Flüstern von bestimmten Absendern.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Optional different sounds per chat type."] = "Optional andere Töne pro Chattyp.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Outline for the message area and input box text."] = "Umriss für den Text des Nachrichtenbereichs und des Eingabefelds.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Override Muted Audio"] = "Stummgeschalteten Ton übergehen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Placement & Size"] = "Platzierung & Größe", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Playback"] = "Wiedergabe", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Player names take their class color. Applies to new messages."] = "Spielernamen erhalten ihre Klassenfarbe. Gilt für neue Nachrichten.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays a distinct sound for raid chat instead of the standard incoming sound; raid warnings keep the standard sound. It never mutes."] = "Spielt für Schlachtzugschat einen eigenen Ton statt des Standard-Eingangstons; Schlachtzugswarnungen behalten den Standardton. Schaltet nie stumm.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays a distinct sound for this chat type instead of the standard incoming sound; it never mutes. Use a channel's No Sound flag or turn off incoming chat sounds to silence."] = "Spielt für diesen Chattyp einen eigenen Ton statt des Standard-Eingangstons; schaltet nie stumm. Nutzt die Markierung „Kein Ton“ eines Kanals oder schaltet eingehende Chat-Töne aus, um ihn zu unterdrücken.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays a sound when a captured chat message arrives. Per-channel No Sound flags on the channel lists mute individual channels."] = "Spielt einen Ton, wenn eine erfasste Chatnachricht eintrifft. Die Markierung „Kein Ton“ in den Kanallisten schaltet einzelne Kanäle stumm.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays a sound when a whisper arrives."] = "Spielt einen Ton, wenn eine Flüsternachricht eintrifft.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays a sound when you send a message in a captured chat type, from WIM or the game's chat box."] = "Spielt einen Ton, wenn Ihr eine Nachricht in einem erfassten Chattyp sendet, aus WIM oder dem Chatfeld des Spiels.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays a sound when you send a whisper."] = "Spielt einen Ton, wenn Ihr eine Flüsternachricht sendet.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays notification sounds on the Master channel so they are heard even when sound effects are turned off."] = "Spielt Benachrichtigungstöne auf dem Master-Kanal, damit sie auch bei ausgeschalteten Soundeffekten zu hören sind.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays this sound instead of the standard incoming whisper sound."] = "Spielt diesen Ton statt des Standardtons für eingehendes Flüstern.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Pop Up on Receive"] = "Beim Empfangen aufklappen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Pop Up on Send"] = "Beim Senden aufklappen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Pop-up Rules"] = "Pop-up-Regeln", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Pressing Escape hides all open WIM windows."] = "Escape blendet alle offenen WIM-Fenster aus.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Pressing Tab in a whisper window jumps to the next person you whispered. While enabled, forward Tab no longer cycles through window tabs."] = "Tab in einem Flüsterfenster springt zur nächsten Person, der Ihr geflüstert habt. Solange aktiv, wechselt Tab nicht mehr durch die Fenster-Tabs.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Preview Count"] = "Anzahl in der Vorschau", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Preview Recent Messages"] = "Vorschau der letzten Nachrichten", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays this sound instead of the standard incoming whisper sound when a Battle.net friend whispers. When several match, Battle.net friend wins over friend and guild member."] = "Spielt diesen Ton statt des Standardtons für eingehendes Flüstern, wenn ein Battle.net-Freund flüstert. Treffen mehrere zu, geht Battle.net-Freund vor Freund und Gildenmitglied.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Privacy & Filtering"] = "Privatsphäre & Filter", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Profile Fields"] = "Profilfelder", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Puts the keyboard focus in the input box when a window pops up."] = "Setzt den Tastaturfokus ins Eingabefeld, wenn ein Fenster aufklappt.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Re-adds community channels to your chat frames when the client drops them, once per login after a late stream focus; /wim channelrepair runs it now. Opt-in: this mutates saved chat window configuration."] = "Fügt Community-Kanäle Euren Chatfenstern wieder hinzu, wenn der Client sie verwirft, einmal pro Login nach einem späten Stream-Fokus; /wim channelrepair führt es sofort aus. Opt-in: Dies verändert die gespeicherte Chatfenster-Konfiguration.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Record From"] = "Aufzeichnen von", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Record Whispers"] = "Flüstern aufzeichnen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Recording"] = "Aufzeichnung", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Recording stops as soon as this is off; the history button stays on open windows until the next reload."] = "Die Aufzeichnung stoppt, sobald dies aus ist; der Verlaufsknopf bleibt bis zum nächsten Neuladen auf offenen Fenstern.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Redirect /w and /r to WIM"] = "/w und /r zu WIM umleiten", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Repair Dropped Channels"] = "Verworfene Kanäle reparieren", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Reset Position"] = "Position zurücksetzen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Retention"] = "Aufbewahrung", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Retention caps, preview, and deletion."] = "Aufbewahrungsgrenzen, Vorschau und Löschen.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Right-Click Opens Unread"] = "Rechtsklick öffnet Ungelesene", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Runs the whisper filter list below. While off, addon-spam whispers open windows like any other whisper."] = "Führt die Flüster-Filterliste unten aus. Solange aus, öffnen Addon-Spam-Flüsternachrichten Fenster wie jede andere Flüsternachricht.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["See-Through Frame"] = "Durchsichtiger Rahmen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Sender Details"] = "Absenderdetails", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Sent Chat"] = "Gesendeter Chat", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Sent Whispers"] = "Gesendetes Flüstern", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Separate Friends Group"] = "Eigene Gruppe für Freunde", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Separate Guild Group"] = "Eigene Gruppe für Gilde", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Set to In-line"] = "Auf „Im Chat“ setzen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Share Tab Group with Whispers"] = "Tabgruppe mit Flüstern teilen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Shortcut Bar"] = "Schnellzugriffsleiste", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Show Only in WIM"] = "Nur in WIM anzeigen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Show Roleplay Profiles"] = "Rollenspielprofile anzeigen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Show Timestamps"] = "Zeitstempel anzeigen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Show WIM Tooltips"] = "WIM-Tooltips anzeigen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Show an unread message badge on the WIM launcher icons."] = "Ein Abzeichen für ungelesene Nachrichten auf den WIM-Startersymbolen anzeigen.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Show an unread message badge on the WIM launcher icons. Off by default for channels."] = "Ein Abzeichen für ungelesene Nachrichten auf den WIM-Startersymbolen anzeigen. Für Kanäle standardmäßig aus.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Shows help tooltips on WIM's windows, lists, and the custom rows of these options."] = "Zeigt Hilfe-Tooltips auf WIMs Fenstern, Listen und den besonderen Zeilen dieser Optionen.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Shows the most recent messages when a window opens. Applies to whisper and chat history alike, and requires Record Whispers."] = "Zeigt die letzten Nachrichten, wenn ein Fenster geöffnet wird. Gilt gleichermaßen für Flüster- und Chatverlauf und erfordert „Flüstern aufzeichnen“.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Shows the row of shortcut buttons on message windows. Turning this off takes effect after the next interface reload."] = "Zeigt die Reihe der Schnellzugriffsknöpfe auf Nachrichtenfenstern. Das Ausschalten wird nach dem nächsten Neuladen des Interfaces wirksam.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Shows the sender's class, level, and guild on their window. Sends one /who lookup when the window opens. Applies to windows opened after the change."] = "Zeigt Klasse, Stufe und Gilde des Absenders in dessen Fenster. Sendet beim Öffnen des Fensters eine /who-Abfrage. Gilt für nach der Änderung geöffnete Fenster.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Situations without custom rules follow these base rules."] = "Situationen ohne eigene Regeln folgen diesen Basisregeln.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Skin"] = "Skin", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Skin default"] = "Skin-Standard", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Skin, fonts, message look, and colors."] = "Skin, Schriftarten, Nachrichtenaussehen und Farben.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Sort Menu by Activity"] = "Menü nach Aktivität sortieren", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Sort Tabs By"] = "Tabs sortieren nach", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Sounds for whispers and chat, and how they are played."] = "Töne für Flüstern und Chat und wie sie abgespielt werden.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Sources"] = "Quellen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Storage"] = "Speicherung", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["System Messages & Timestamps"] = "Systemnachrichten & Zeitstempel", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Tab Groups"] = "Tabgruppen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Tab to Next Whisper"] = "Tab zum nächsten Flüstern", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Text smileys render as icons."] = "Text-Smileys werden als Symbole dargestellt.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The base rules. Situations without custom rules follow these."] = "Die Basisregeln. Situationen ohne eigene Regeln folgen diesen.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The button can then be dragged anywhere on the screen."] = "Der Knopf kann dann überall auf dem Bildschirm platziert werden.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The direction windows slide out when they hide. Also used by the show/hide key binding. Only applies while Window Animations is on under Appearance > Skin."] = "Die Richtung, in die Fenster beim Ausblenden gleiten. Wird auch von der Tastenbelegung zum Ein-/Ausblenden genutzt. Gilt nur, solange „Fensteranimationen“ unter Aussehen > Skin aktiv ist.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The interface layer WIM windows draw on; higher layers cover lower ones."] = "Die Interface-Ebene, auf der WIM-Fenster gezeichnet werden; höhere Ebenen verdecken niedrigere.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The message area renders two points larger than the chosen size; the input box and header follow the skin."] = "Der Nachrichtenbereich wird zwei Punkte größer als die gewählte Größe dargestellt; Eingabefeld und Kopfzeile folgen dem Skin.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The message box at the bottom of each window."] = "Das Nachrichtenfeld unten in jedem Fenster.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The message history window."] = "Das Fenster des Nachrichtenverlaufs.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The skin and window chrome."] = "Der Skin und der Fensterrahmen.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The skin picks the font."] = "Der Skin wählt die Schriftart.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The sound to play. The speaker button plays a preview."] = "Der abzuspielende Ton. Der Lautsprecherknopf spielt eine Vorschau.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The whisper and chat windows."] = "Die Flüster- und Chatfenster.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The window for adding and editing whisper and chat filters."] = "Das Fenster zum Hinzufügen und Bearbeiten von Flüster- und Chatfiltern.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["These settings style WIM's modern-only skins (such as WIM Modern), which are built from the game's own interface art. They are available while a modern-only skin is selected on the Skin page; with a classic skin active they are greyed out."] = "Diese Einstellungen gestalten WIMs rein moderne Skins (wie WIM Modern), die aus der Interface-Grafik des Spiels aufgebaut sind. Sie sind verfügbar, solange auf der Seite „Skin“ ein rein moderner Skin gewählt ist; bei einem klassischen Skin sind sie ausgegraut.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Timestamps"] = "Zeitstempel", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Total RP 3 and Mary Sue Protocol profile display on whisper windows."] = "Anzeige von Total RP 3- und Mary Sue Protocol-Profilen in Flüsterfenstern.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Type %s to confirm."] = "Gebt %s ein, um zu bestätigen.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Unlock Minimap Button"] = "Minikartenknopf entsperren", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Use Master Sound Channel"] = "Master-Tonkanal verwenden", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["WIM Message Window"] = "WIM-Nachrichtenfenster", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["WIM Modern Skin"] = "Skin WIM Modern", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["WIM manages this chat type in its own message windows. Turning a type off stops capture now; its window button stays until the next reload."] = "WIM verwaltet diesen Chattyp in eigenen Nachrichtenfenstern. Das Ausschalten eines Typs beendet die Erfassung sofort; sein Fensterknopf bleibt bis zum nächsten Neuladen.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["WIM's launcher menus list the most recently active conversations first."] = "WIMs Startermenüs führen die zuletzt aktiven Gespräche zuerst auf.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["WIM: the options UI is not available on this client."] = "WIM: Die Optionsoberfläche ist auf diesem Client nicht verfügbar.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Wait While Typing"] = "Beim Tippen warten", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Web Addresses"] = "Webadressen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Web addresses in messages become clickable links."] = "Webadressen in Nachrichten werden zu anklickbaren Links.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["What WIM takes over: whispers, and the chat types that get their own windows."] = "Was WIM übernimmt: Flüstern und die Chattypen, die eigene Fenster erhalten.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["What is kept, and for how long."] = "Was aufbewahrt wird und wie lange.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["When choosing the /reply target, your most recent sent whisper counts as well as the last one received."] = "Bei der Wahl des /reply-Ziels zählt auch Eure zuletzt gesendete Flüsternachricht, nicht nur die zuletzt empfangene.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["When windows appear, where they sit, and what has keyboard focus."] = "Wann Fenster erscheinen, wo sie liegen und was den Tastaturfokus hat.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["When windows pop up and when messages leave the chat frame, per situation."] = "Wann Fenster aufklappen und wann Nachrichten das Chatfenster verlassen, je Situation.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Where new windows appear, their default size and scale, and the placement of the History Viewer and filter editor are set in the game's Edit Mode."] = "Wo neue Fenster erscheinen, ihre Standardgröße und -skalierung sowie die Platzierung von Verlaufsanzeige und Filtereditor werden im Bearbeitungsmodus des Spiels festgelegt.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Which whispers and chat types are recorded."] = "Welche Flüsternachrichten und Chattypen aufgezeichnet werden.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["While in a battleground."] = "Auf einem Schlachtfeld.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["While in a dungeon."] = "In einem Dungeon.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["While in a raid instance."] = "In einer Schlachtzugsinstanz.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["While in an arena match."] = "In einem Arenakampf.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["While in combat."] = "Im Kampf.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["While resting in an inn or city."] = "Beim Rasten in einem Gasthaus oder einer Stadt.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Whisper Sounds"] = "Flüster-Töne", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Whisper windows opened from WIM's menus normally take focus immediately; with this on they follow the pop-up focus rules instead."] = "Aus WIMs Menüs geöffnete Flüsterfenster erhalten normalerweise sofort den Fokus; mit dieser Option folgen sie stattdessen den Pop-up-Fokusregeln.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Whisper windows share one tabbed window. Does not apply to windows already opened."] = "Flüsterfenster teilen sich ein Fenster mit Tabs. Gilt nicht für bereits geöffnete Fenster.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Whisper windows show roleplay profile fields from Total RP 3 or any Mary Sue Protocol addon, and gain an Open RP Profile button on their shortcut bar that opens the partner's profile in the installed viewer. Requires the WIM Modern skin."] = "Flüsterfenster zeigen Rollenspielprofil-Felder aus Total RP 3 oder jedem Mary Sue Protocol-Addon und erhalten in ihrer Schnellzugriffsleiste einen Knopf „RP-Profil öffnen“, der das Profil des Gegenübers in der installierten Anzeige öffnet. Erfordert den Skin WIM Modern.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Whispers Follow Focus Rules"] = "Flüstern folgt den Fokusregeln", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Whispers from friends group into their own tabbed window."] = "Flüstern von Freunden wird in einem eigenen Fenster mit Tabs gruppiert.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Whispers from game masters are always recorded. Battle.net whispers count as friends."] = "Flüstern von Gamemastern wird immer aufgezeichnet. Battle.net-Flüstern zählt als Freunde.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Whispers from guild members group into their own tabbed window. A friend who is also a guild member goes to the friends group."] = "Flüstern von Gildenmitgliedern wird in einem eigenen Fenster mit Tabs gruppiert. Ein Freund, der zugleich Gildenmitglied ist, landet in der Freundesgruppe.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Who gets through."] = "Wer durchkommt.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Window Animations"] = "Fensteranimationen", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Window Layer"] = "Fensterebene", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Window Opacity"] = "Fensterdeckkraft", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Window Skin"] = "Fenster-Skin", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Where new windows spawn and how big they are, their layer, cascading, and screen clamping."] = "Wo neue Fenster erscheinen und wie groß sie sind, ihre Ebene, Kaskadierung und das Halten am Bildschirm.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Windows"] = "Fenster", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Windows Opened from Menus"] = "Aus Menüs geöffnete Fenster", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Windows cannot be dragged past the screen edges."] = "Fenster können nicht über die Bildschirmränder hinaus gezogen werden.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Windows fade to half opacity after two seconds without the mouse over them."] = "Fenster werden nach zwei Sekunden ohne Maus darüber auf halbe Deckkraft abgeblendet.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["World Channels"] = "Weltkanäle", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Wraps player names in brackets."] = "Setzt Spielernamen in Klammern.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["You are about to permanently delete WIM's message history for every character on this account."] = "Ihr seid dabei, WIMs Nachrichtenverlauf für jeden Charakter dieses Accounts dauerhaft zu löschen.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["instant"] = "sofort", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["slow"] = "langsam", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Community chat cannot be recorded, so this is always on for community channels."] = "Community-Chat kann nicht aufgezeichnet werden, daher ist dies für Community-Kanäle immer aktiv.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Width"] = "Breite", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Height"] = "Höhe", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["WIM Filter Editor"] = "WIM-Filtereditor", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
});

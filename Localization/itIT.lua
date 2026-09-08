--[[
    Language Localization: itIT
]]

WIM.AddLocale("itIT", {
    ["WIM (WoW Instant Messenger)"] = "WIM (WoW Instant Messenger)",
    ["_Description"] = "WIM è un addon che rende familiare la comunicazione tramite chat in World of Warcraft. In questa schermata potrai personalizzare WIM per adattarlo alle tue esigenze.",

    ["_DemoText"] = "Questa è una finestra dimostrativa e non è completamente funzionante. Posiziona questa finestra nel punto in cui vuoi che tutte le altre finestre vengano aperte. Quando hai finito, puoi chiudere questa finestra e le tue impostazioni verranno salvate.",

    ["_DateFormat"] = "%d/%m/%Y",

    ["Yes"] = "Sì",
    ["No"] = "No",
    ["None"] = "Nessuno",
    ["Cancel"] = "Annulla",
    ["Unknown"] = "Sconosciuto",
    ["Click to update..."] = "Clicca per aggiornare...",
    ["Usage"] = "Utilizzo",

    ["state_resting"] = "Riposo",
    ["state_combat"] = "Combattimento",
    ["state_pvp"] = "PvP",
    ["state_arena"] = "Arena",
    ["state_party"] = "Gruppo di istanza",
    ["state_raid"] = "Gruppo raid",
    ["state_other"] = "Normale (altro)",

    ["Options"] = "Opzioni",

    ["Up"] = "Su",
    ["Down"] = "Giù",
    ["Left"] = "Sinistra",
    ["Right"] = "Destra",
    ["Ignore"] = "Ignora",
    ["Block"] = "Blocca",
    ["Enable WIM"] = "Abilita WIM",

    ["Enable"] = "Abilita",
    ["Disable"] = "Disabilita",

    ["History"] = "Cronologia",
    ["Filters"] = "Filtri",

	["Window Created"] = "Finestra creata",
	["Last Activity"] = "Ultima attività",
    ["Alphabetical"] = "Alfabetico",

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

    ["Game Master"] = "Master di gioco",

    -- WIM.lua --
    ["Toggle WIM 'On' and 'Off'."] = "Attiva/disattiva WIM",

    -- Filters.lua --
    ["Whispers Sent by Addons"] = "Sussurri inviati dagli addon",
    ["WhisperSelect Part 1"] = "WhisperSelect parte 1",
    ["Example Spam Blocker"] = "Blocco spam di esempio",
    ["WhisperSelect Part 2"] = "WhisperSelect parte 2",
    ["Filter Name"] = "Nome filtro",
    ["Filter By"] = "Filtra per",
    ["Pattern"] = "Modello",
    ["User Type"] = "Tipo di utente",
    ["Level"] = "Livello",
    ["Friends"] = "Amici",
    ["Guild Members"] = "Membri della gilda",
    ["Party Members"] = "Membri del gruppo",
    ["Raid Members"] = "Membri del raid",
    ["Cross-Realm"] = "Cross-realm",
    ["Everyone"] = "Tutti",
    ["User must be at least level:"] = "L'utente deve essere almeno di livello:",
    ["Apply to messages received."] = "Applica ai messaggi ricevuti.",
    ["Apply to messages sent."] = "Applica ai messaggi inviati.",
    ["Apply to:"] = "Applica a:",
    ["All Classes"] = "Tutte le classi",
    ["Action to Perform:"] = "Azione da eseguire:",
    ["Allow"] = "Consenti",
    ["Ignore"] = "Ignora",
    ["Blocked"] = "Bloccato",
    ["Save"] = "Salva",
    ["Cancel"] = "Annulla",
    ["Edit Filter"] = "Modifica filtro",
    ["Add Filter"] = "Aggiungi filtro",

    -- History.lua --
    ["WIM History Button"] = "Pulsante cronologia WIM",
    ["Click to view message history."] = "Clicca per visualizzare la cronologia dei messaggi.",
    ["WIM pruned %d |4message:messages; from your history."] = "WIM ha eliminato %d |4messaggio:messaggi; dalla tua cronologia.",
    ["History Viewer"] = "Visualizzatore cronologia",
    ["Filters"] = "Filtri",
    ["Are you sure you want to delete all history saved for %s on %s?"] = "Vuoi davvero eliminare tutta la cronologia salvata per %s su %s?",
    ["Search resulted in %d |4message:messages;."] = "La ricerca ha trovato %d |4messaggio:messaggi;.",
    ["No results found!"] = "Nessun risultato trovato!",
    ["Search"] = "Cerca",
    ["Show All"] = "Mostra tutto",
    ["Loading History"] = "Caricamento cronologia",
    ["Chat View"] = "Vista chat",
    ["Text View"] = "Vista testo",
    ["BBCode"] = "BBCode",
    ["WIM History Viewer"] = "Visualizzatore cronologia WIM",
    ["Display history viewer."] = "Mostra il visualizzatore cronologia.",

    -- ldb.lua --
    ["No New Messages"] = "Nessun nuovo messaggio",

    -- Menu.lua --
    ["Whispers"] = "Sussurri",
    ["Chat"] = "Chat",

    -- Negotiate.lua --
    ["WIM Update Available!"] = "Aggiornamento WIM disponibile!",

    -- ShortcutBar.lua --
    ["Player Location"] = "Posizione del giocatore",
    ["Unknown"] = "Sconosciuto",
    ["Click to update..."] = "Clicca per aggiornare...",
    ["Invite to Party"] = "Invita nel gruppo",
    ["Invite to Guild"] = "Invita nella gilda",
    ["Add Friend"] = "Aggiungi amico",
    ["Ignore Player"] = "Ignora utente",
    ["Are you sure you want to\nignore %s?"] = "Vuoi davvero\nignorare %s?",
    ["Right-Click for profile links..."] = "Tasto destro per i collegamenti al profilo...",
    ["Profile Links"] = "Collegamenti profilo",
	["Location"] = "Posizione",
	["Game"] = "Gioco",
	["Realm"] = "Reame",
	["Character"] = "Personaggio",
	["Copy Name"] = "Copia nome",

    -- Tutorials.lua --
    ["View Updates"] = "Visualizza aggiornamenti",

    -- WhisperEngine.lua --
    ["Whisper Received!"] = "Sussurro ricevuto!",
    ["Recently Sent Messages"] = "Messaggi inviati di recente",
    ["Users in %s"] = "Utenti in %s",

    -- Clear.lua --
    ["This action will reload your user interface."] = "Questa azione ricaricherà la tua interfaccia utente.",
    ["Do you want to continue?"] = "Vuoi continuare?",
    ["You are about to restore WIM's filters to it's default settings!"] = "Stai per ripristinare i filtri di WIM alle impostazioni predefinite!",
    ["Usage"] = "Utilizzo",
    ["Clear various WIM data."] = "Cancella vari dati di WIM.",

    -- SlashHandler.lua --
    ["WIM Slash Commands"] = "Comandi slash di WIM",
    ["Hide or show {all, whisper, chat} windows."] = "Nascondi o mostra le finestre {tutte, sussurri, chat}.",
    ["To see a list of available WIM slash commands type:"] = "Per vedere un elenco dei comandi slash WIM disponibili, digita:",
    ["Display available slash commands."] = "Mostra i comandi slash disponibili.",
    ["Reload User Interface."] = "Ricarica l'interfaccia utente.",

    -- TabHandler.lua --
    ["Manipulating Tabs"] = "Gestione delle schede",

    -- WindowHandler.lua --
    ["Window Resized!"] = "Finestra ridimensionata!",
	["Creating Tab Groups"] = "Creazione di gruppi di schede",
	["You can group two or many windows together by <Shift-Clicking> a window and dragging it on top of another."] = "Puoi raggruppare due o più finestre <Maiusc-cliccando> su una finestra e trascinandola sopra un'altra.",
	["Resizing Windows"] = "Ridimensionamento delle finestre",
	["You can resize a window by holding <Shift> and dragging the bottom right corner of the window."] = "Puoi ridimensionare una finestra tenendo premuto <Maiusc> e trascinando l'angolo in basso a destra della finestra.",
	["Demo Window"] = "Finestra dimostrativa",
	["<Shift-Click> to close window."] = "<Maiusc-clic> per chiudere la finestra.",
	["Message Window Hidden"] = "Finestra messaggi nascosta",
	["Default"] = "Predefinito",
	["%s is Away From Keyboard: %s"] = "%s è assente (AFK): %s",
	["%s does not wish to be disturbed: %s"] = "%s non vuole essere disturbato: %s",
	["Right-Mouse Click!"] = "Clic con il tasto destro!",
	["There might be useful tools hidden under the message box. Right-Click to see them!"] = "Potrebbero esserci strumenti utili nascosti sotto la casella dei messaggi. Fai clic con il tasto destro per vederli!",

    -- Options.lua --
    ["Display WIM's options."] = "Mostra le opzioni di WIM.",
    ["Resetting WIM will clear all of your settings!"] = "Il ripristino di WIM cancellerà tutte le tue impostazioni!",
    ["A reset will reload your user interface."] = "Un ripristino ricaricherà la tua interfaccia utente.",
    ["Reset all options to default."] = "Ripristina tutte le opzioni ai valori predefiniti.",

    -- CoreOptions --
    ["Created By:"] = "Creato da:",
    ["Special Thanks:"] = "Ringraziamenti speciali:",
    ["Enable WIM"] = "Abilita WIM",
    ["Credits"] = "Crediti",
    ["This is a long message which contains both emoticons and urls 8). WIM's home is www.WIMAddon.com."] = "Questo è un messaggio lungo che contiene sia emoticon che URL 8). La home di WIM è www.WIMAddon.com.",
    ["Preview"] = "Anteprima",
    ["Window Scale"] = "Scala finestra",
    ["Set Window Spawn Location"] = "Imposta la posizione di comparsa delle finestre",
    ["Up"] = "Su",
    ["Down"] = "Giù",
    ["Left"] = "Sinistra",
    ["Right"] = "Destra",
    ["Version"] = "Versione",
    ["Font Outline"] = "Contorno del carattere",
    ["Thin"] = "Sottile",
    ["Thick"] = "Spesso",
    ["Allow"] = "Consenti",
    ["Ignore"] = "Ignora",
    ["Block"] = "Blocca",
    ["Protected"] = "Protetto",
    ["Action:"] = "Azione:",
    ["Occurrences:"] = "Occorrenze:",
    ["Delete Filter"] = "Elimina filtro",
    ["History"] = "Cronologia",
    ["Messages"] = "Messaggi",
    ["Record Chat"] = "Registra la chat",
    ["Maintenance"] = "Manutenzione",
    ["%d |4Week:Weeks;"] = "%d |4settimana:settimane;",
    ["User Level"] = "Livello utente",
    ["Sounds"] = "Suoni",
	["Background"] = BACKGROUND,
	["Low"] = LOW,
	["Medium"] = "Medio",
	["High"] = "Alto",
	["Dialog"] = ENABLE_DIALOG,
	["Tooltip"] = "Tooltip",

    -- TabManagement.lua --

    -- Talent Specs --
    ["Hybrid"] = "Ibrido",

    -- Filters.lua --
    ["Show Alert"] = "Mostra avviso",
    ["WIM has blocked a message from %s."] = "WIM ha bloccato un messaggio da %s.",
    ["View Blocked Message"] = "Visualizza messaggio bloccato",
    ["Blocked Message"] = "Messaggio bloccato",

    -- MinimapIcon.lua
    ["Show Unread Messages"] = "Mostra messaggi non letti",
    ["Show All Windows"] = "Mostra tutte le finestre",
    ["Hide All Windows"] = "Nascondi tutte le finestre",

    --Emoticons.lua
    ["Also"] = "Anche",
    ["More"] = "Altro",
    ["Emoticons"] = "Emoticon",

    --Expose.lua
    ["Your conversations have been hidden in order to clear your screen while in combat. To disable this feature type"] = "Le tue conversazioni sono state nascoste per liberare lo schermo durante il combattimento. Per disabilitare questa funzione digita",
    ["Expose"] = "Expose",

    --ChatEngine.lua
    ["Have WIM monitor this channel."] = "Fai monitorare a WIM questo canale.",
    ["Never Suppress"] = "Non sopprimere mai",
    ["No History"] = "Nessuna cronologia",
    ["World Chat"] = "Chat mondiale",
    ["Custom Chat"] = "Chat personalizzata",
    ["Community Chat"] = "Chat della comunità",
    ["Chat"] = "Chat",
	["No Sound"] = "Nessun suono",

	--OffScreenTracker.lua
	["WIM Window Off Screen"] = "Finestra WIM fuori schermo",
	["Click to reposition."] = "Clicca per riposizionare.",

	-- Whisper Mode Warnings
	["Set whispers to In-line"] = "Imposta i sussurri su In linea",
	["It is recommended for whispers to be set to in-line in order to handle their behavior properly."] = "Si consiglia di impostare i sussurri su In linea per gestirne correttamente il comportamento.",

	-- Skins --
	["Blue"] = "Blu",
	["Green"] = "Verde",
	["Red"] = "Rosso",
	["Yellow"] = "Giallo",

	-- Battle.net friend consolidation (History Viewer)
	["Battle.net Friends"] = "Amici Battle.net",
	["Are you sure you want to delete ALL history saved with %s, across every realm and every character on this account?"] = "Vuoi davvero eliminare TUTTA la cronologia salvata con %s, su tutti i reami e tutti i personaggi di questo account?",

	-- Per-date deletion from the History Viewer filter list
	["Are you sure you want to delete the %s history with %s across every realm and character on this account?"] = "Vuoi davvero eliminare la cronologia del %s con %s su tutti i reami e personaggi di questo account?",
	["Are you sure you want to delete the %s history for %s across every character on %s?"] = "Vuoi davvero eliminare la cronologia del %s di %s su tutti i personaggi di %s?",
	["Are you sure you want to delete the %s history for %s on %s?"] = "Vuoi davvero eliminare la cronologia del %s di %s su %s?",


	-- Modern options panel --

	-- Modern skin styling --
	["None (game default)"] = "Nessuno (predefinito del gioco)",
	["Draws the window frame background only around the message area, so a clear message area background (None or Transparent) shows the game world behind the window."] = "Disegna lo sfondo della cornice della finestra solo intorno all'area messaggi, così uno sfondo dell'area messaggi trasparente (Nessuno o Trasparente) mostra il mondo di gioco dietro la finestra.",

	-- Roleplay profiles (Total RP 3 / Mary Sue Protocol) --
	["Roleplay Profiles"] = "Profili di ruolo",
	["Open RP Profile"] = "Apri profilo di ruolo",
	["Whisper windows show the selected fields from the partner's Total RP 3 or Mary Sue Protocol profile. Fields left unselected -- or without profile data -- keep the standard display."] = "Le finestre dei sussurri mostrano i campi selezionati dal profilo Total RP 3 o Mary Sue Protocol dell'interlocutore. I campi non selezionati -- o senza dati del profilo -- mantengono la visualizzazione standard.",
	["First Name"] = "Nome",
	["Last Name"] = "Cognome",
	["Title"] = "Titolo",
	["Full Title"] = "Titolo completo",
	["Race"] = "Razza",
	["Class"] = "Classe",
	["Portrait"] = "Ritratto",
	["Name & Class Color"] = "Colore nome e classe",
	["The profile's first name, shown as the window's name text."] = "Il nome del profilo, mostrato come testo del nome della finestra.",
	["The profile's last name, shown as the window's name text."] = "Il cognome del profilo, mostrato come testo del nome della finestra.",
	["The short title, shown on the window's details line."] = "Il titolo breve, mostrato sulla riga dei dettagli della finestra.",
	["The long title, shown on the window's details line and portrait tooltip."] = "Il titolo lungo, mostrato sulla riga dei dettagli della finestra e nel suggerimento del ritratto.",
	["The custom race, replacing the character's race on the details line."] = "La razza personalizzata, che sostituisce la razza del personaggio sulla riga dei dettagli.",
	["The custom class, replacing the character's class on the details line."] = "La classe personalizzata, che sostituisce la classe del personaggio sulla riga dei dettagli.",
	["The profile's icon, replacing the class icon."] = "L'icona del profilo, che sostituisce l'icona di classe.",
	["The profile's custom color, applied to the window's name text and to the class on the details line."] = "Il colore personalizzato del profilo, applicato al testo del nome della finestra e alla classe sulla riga dei dettagli.",
	["Apply filter to character menus"] = "Applica il filtro ai menu dei personaggi",

	-- History Viewer filters --
	["No Filter"] = "Nessun filtro",
	["Relative Dates"] = "Date relative",
	["%d or more"] = "%d o più",
	["Fewer than %d"] = "Meno di %d",
	["Results Filtered"] = "Risultati filtrati",
	["-- Results Filtered --"] = "-- Risultati filtrati --",
	["Results are hidden by the active filter. Click to open the Filters menu."] = "I risultati sono nascosti dal filtro attivo. Fai clic per aprire il menu dei filtri.",
	["Click to change how history is filtered."] = "Fai clic per cambiare come viene filtrata la cronologia.",
	["Click to open the Filters menu."] = "Fai clic per aprire il menu dei filtri.",
	["Clicking the %s button on the message window will show that user's history in WIM's History Viewer."] = "Un clic sul pulsante %s nella finestra dei messaggi mostrerà la cronologia di quell'utente nel Visualizzatore cronologia di WIM.",

	-- Message input & formatting --
	["Caps how far the input field grows; past the limit the message scrolls inside it."] = "Limita quanto cresce il campo di input; oltre il limite il messaggio scorre al suo interno.",
	["The most lines the input field grows to before the message scrolls inside it."] = "Il numero massimo di righe a cui cresce il campo di input prima che il messaggio scorra al suo interno.",
	["The input field wraps long messages onto multiple lines, growing downward with the message instead of scrolling it on one line."] = "Il campo di input va a capo sui messaggi lunghi su più righe, crescendo verso il basso con il messaggio invece di farlo scorrere su una sola riga.",
	["Timestamp Format"] = "Formato timestamp",
	["Bracket Style"] = "Stile parentesi",
	["Colors"] = "Colori",
	["Sound"] = "Suono",

	-- Chat type options --
	["Record"] = "Registra",

	-- Help, bug reports & links --
	["Found a bug?"] = "Trovato un bug?",
	["Report a Bug"] = "Segnala un bug",
	["Reports are welcome! Click below and follow the instructions in the bug report template."] = "Le segnalazioni sono benvenute! Fai clic qui sotto e segui le istruzioni del modello per le segnalazioni di bug.",
	["Show GitHub Link"] = "Mostra il link GitHub", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
	["Click to show the link for copying."] = "Fai clic per mostrare il link da copiare.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
	["Press Ctrl+C to copy the link, then open it in your browser."] = "Premi Ctrl+C per copiare il link, poi aprilo nel tuo browser.",

	-- Debugging & development slash commands --
	["Clear the captured debug log."] = "Cancella il registro di debug acquisito.",
	["Set debugging level: /wim debug [0|1|2]. 2 adds verbose chat event tracing."] = "Imposta il livello di debug: /wim debug [0|1|2]. 2 aggiunge tracciamento dettagliato degli eventi di chat.",
	["Snapshot the next modern context menu while it is open."] = "Scatta un'istantanea del prossimo menu contestuale moderno mentre è aperto.",
	["Snapshot UI widget state for skin development: /wim snap all | <Frame.Dot.Path> (bare /wim snap lists the arguments)."] = "Acquisisce lo stato dei widget dell'interfaccia per lo sviluppo delle skin: /wim snap all | <Frame.Dot.Path> (/wim snap senza argomenti elenca le possibilità).",

	-- Tutorials & notices --
	["WIM is currently running. To access WIM's wide array of options type:"] = "WIM è attualmente in esecuzione. Per accedere alla vasta gamma di opzioni di WIM digita:",
	["WIM's message window has been hidden to WIM's Minimap Icon. If you want to end a conversation, you may do so by <Shift-Clicking> the close button."] = "La finestra dei messaggi è stata nascosta nell'icona della minimappa di WIM. Se vuoi terminare una conversazione, puoi farlo con <Maiusc-Clic> sul pulsante di chiusura.",
	["If you want all windows to be this size, you can set the default window size within WIM's options."] = "Se vuoi che tutte le finestre abbiano questa dimensione, puoi impostare la dimensione predefinita delle finestre nelle opzioni di WIM.",
	["You can <Shift-Click> a tab and drag it out into it's own window."] = "Puoi fare <Maiusc-Clic> su una scheda e trascinarla fuori per renderla una finestra a sé.",
	["You received a whisper which was hidden due to your current activity. You can change how whispers behave in WIM's options by typing"] = "Hai ricevuto un sussurro che è stato nascosto a causa della tua attività attuale. Puoi cambiare come si comportano i sussurri nelle opzioni di WIM digitando",

	-- Community channel maintenance --
	["Toggle the experimental community channel re-add repair (mutates chat window channels)."] = "Attiva la riparazione sperimentale del reinserimento dei canali comunità (modifica i canali delle finestre di chat).",
	["Toggle whether WIM focuses community streams at login."] = "Determina se WIM mette a fuoco i flussi comunità all'accesso.",

	-- Misc --
	["Older Than"] = "Più vecchi di", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
	["Users in %s"] = "Utenti in %s",

	-- History Viewer filter modes --
	["Sent by Me"] = "Inviato da me",
	["Sent by Them"] = "Inviati da loro",
	["Active Days"] = "Giorni attivi",
	["Last 1 Day"] = "Ultimo giorno",
	["Last 7 Days"] = "Ultimi 7 giorni",
	["Last 30 Days"] = "Ultimi 30 giorni",
	["Last 90 Days"] = "Ultimi 90 giorni",


	-- Chrome background names --
	["None (fully clear)"] = "Nessuno (completamente trasparente)",
	["Transparent"] = "Trasparente",
	["Rock"] = "Roccia",
	["Marble"] = "Marmo",
	["Dark Marble"] = "Marmo scuro",
	["Bank"] = "Banca",
	["Guild Vault"] = "Banca di gilda",
	["Dark Sandstone"] = "Arenaria scura",
	["Parchment (Tileable)"] = "Pergamena (affiancabile)",
	["Quest Parchment"] = "Pergamena della missione",
	["Raid Frame"] = "Cornice incursione",
	["Destiny"] = "Destino",
	["Stationery (Auction)"] = "Cancelleria (asta)",
	["Stationery (Illustrated)"] = "Cancelleria (illustrata)",
	["Stationery (Orgrimmar)"] = "Cancelleria (Orgrimmar)",
	["Stationery (Thunder Bluff)"] = "Cancelleria (Picco del Tuono)",
	["Stationery (Undercity)"] = "Cancelleria (Sepulcro)",
	["Stationery (Plain)"] = "Cancelleria (semplice)",
	["World Map 1"] = "Mappa del mondo 1",
	["World Map 2"] = "Mappa del mondo 2",
	["Achievement Stats"] = "Statistiche delle imprese",
	["Adventure Map Parchment"] = "Pergamena mappa d'avventura",
	["Collections"] = "Collezioni",
	["Frame: Alliance"] = "Cornice: Alleanza",
	["Frame: Horde"] = "Cornice: Orda",
	["Frame: Neutral"] = "Cornice: Neutrale",
	["Frame: Marine"] = "Cornice: Marina",
	["Frame: Mechagon"] = "Cornice: Mechagon",
	["Frame: Kyrian"] = "Cornice: Kyrian",
	["Frame: Necrolord"] = "Cornice: Necrosignori",
	["Frame: Night Fae"] = "Cornice: Fate Notturne",
	["Frame: Venthyr"] = "Cornice: Venthyr",
	["Frame: Oribos"] = "Cornice: Oribos",
	["Frame: Dragonflight"] = "Cornice: Dragonflight",
	["Frame: The War Within"] = "Cornice: The War Within",
	["Class Hall"] = "Sala di classe",
	["Class Hall (Internal)"] = "Sala di classe (interna)",
	["Garrison Landing Page"] = "Pagina di attracco della guarnigione",
	["Garrison Mission"] = "Missione della guarnigione",
	["Ship Mission Parchment"] = "Pergamena della missione navale",
	["Garrison UI"] = "Interfaccia della guarnigione",
	["Garrison UI 2"] = "Interfaccia della guarnigione 2",
	["Credits: Classic"] = "Crediti: Classic",
	["Credits: Burning Crusade"] = "Crediti: Burning Crusade",
	["Credits: Wrath"] = "Crediti: Wrath",
	["Credits: Cataclysm"] = "Crediti: Cataclysm",
	["Credits: Mists of Pandaria"] = "Crediti: Mists of Pandaria",
	["Credits: Warlords"] = "Crediti: Warlords",
	["Credits: Legion"] = "Crediti: Legion",
	["Credits: Battle for Azeroth"] = "Crediti: Battle for Azeroth",


	-- Skin & options style notices --


    -- Slash command feedback --
    ["WIM: community chat settings unavailable."] = "WIM: impostazioni della chat di comunità non disponibili.",
    ["WIM community stream auto-focus ON. Takes effect at next login."] = "Focus automatico dei canali di comunità di WIM ATTIVO. Ha effetto al prossimo accesso.",
    ["WIM community stream auto-focus OFF - the client may refuse sends to community channels. Takes effect at next login."] = "Focus automatico dei canali di comunità di WIM DISATTIVO - il client potrebbe rifiutare gli invii ai canali di comunità. Ha effetto al prossimo accesso.",
    ["WIM channel re-add repair ON (experimental). On logins where the community stream is focused late, WIM removes and re-adds community channels to ChatFrame1 about 8s after login. If a re-add fails the channel must be restored from the chat settings UI."] = "Riparazione dei canali di WIM ATTIVA (sperimentale). Negli accessi in cui il canale di comunità riceve il focus in ritardo, WIM rimuove e riaggiunge i canali di comunità a ChatFrame1 circa 8 secondi dopo l'accesso. Se una riaggiunta fallisce, il canale va ripristinato dalle impostazioni della chat.",
    ["WIM: attempting a repair now (see /wim debug output)."] = "WIM: tentativo di riparazione in corso (vedi l'output di /wim debug).",
    ["WIM channel re-add repair OFF. No further attempts this session."] = "Riparazione dei canali di WIM DISATTIVA. Nessun altro tentativo in questa sessione.",
    ["WIM: queued options open canceled."] = "WIM: apertura delle opzioni in coda annullata.",

    -- Placeholder: Translated with Google Translate, pending a natural language speaker to verify the translation.
    ["Click to switch between Say, Yell, and Emote."] = "Clicca per passare tra Dire, Urlare ed Emote.",
    ["Say, Yell, or Emote"] = "Dire, Urlare o Emote",
    ["The message being typed takes the color of the chat type it will send as, like the game's own chat box."] = "Il messaggio che scrivi assume il colore del tipo di chat con cui verrà inviato, come nella finestra di chat del gioco.",
    ["Battle.net Whispers"] = "Sussurri Battle.net",
    ["Filter Editor"] = "Editor dei filtri",
    ["Draws the frame background only around the filter area, so a clear filter area background (None or Transparent) shows the game world behind the editor."] = "Disegna lo sfondo della finestra solo attorno all'area del filtro, così uno sfondo libero (Nessuno o Trasparente) mostra il mondo di gioco dietro l'editor.",

    -- Modern options, Edit Mode, and dialogs --
    ["%d chat message(s) could not be recovered after the chat lockdown."] = "Impossibile recuperare %d messaggio/i di chat dopo il blocco della chat.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["%d unsupported User Level filter(s) were removed."] = "%d filtro/i di livello utente non supportato/i rimosso/i.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["/reply Counts Sent Whispers"] = "/reply conta i sussurri inviati", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["A thin border along the screen edge signals that windows are hidden."] = "Un bordo sottile lungo il margine dello schermo segnala che ci sono finestre nascoste.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Above everything, at tooltip level."] = "Sopra tutto, al livello dei tooltip.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Above most interface frames."] = "Sopra la maggior parte dei riquadri dell'interfaccia.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Above the background layer."] = "Sopra il livello dello sfondo.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Actions"] = "Azioni", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Addon Compartment Entry"] = "Voce nello scomparto addon", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["All windows hide when combat starts and are restored when it ends."] = "Tutte le finestre si nascondono all'inizio del combattimento e vengono ripristinate alla fine.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Also captures emotes."] = "Cattura anche le emote.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Animates closing windows toward the minimap, and the slide used by combat auto-hide and the show/hide key binding."] = "Anima la chiusura delle finestre verso la minimappa e lo scorrimento usato dal nascondimento automatico in combattimento e dal tasto mostra/nascondi.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Animation"] = "Animazione", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Animation Direction"] = "Direzione dell'animazione", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Appearance"] = "Aspetto", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Applies the filter list below to captured chat messages. Community chat is not filtered."] = "Applica l'elenco di filtri qui sotto ai messaggi di chat catturati. La chat delle comunità non viene filtrata.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Applies to the minimap button, the addon compartment entry, and data broker launchers."] = "Vale per il pulsante della minimappa, la voce nello scomparto addon e gli avviatori Data Broker.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Applies to whisper and chat history alike. Pruning runs at login."] = "Vale sia per la cronologia dei sussurri che per quella della chat. La pulizia viene eseguita all'accesso.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Apply To"] = "Applica a", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Arrow keys keep controlling the game while the input box has focus; hold Alt to move the text cursor instead."] = "Le frecce continuano a controllare il gioco mentre la casella di input ha il focus; tieni premuto Alt per spostare invece il cursore del testo.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["At login WIM focuses your community chat streams so the client accepts sends to their channel numbers. Takes effect at the next login and needs at least one channel type captured."] = "All'accesso WIM mette a fuoco i flussi di chat delle tue comunità, così il client accetta gli invii ai loro numeri di canale. Ha effetto al prossimo accesso e richiede almeno un tipo di canale catturato.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Auto Focus"] = "Focus automatico", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Backgrounds, input field, and roleplay profile options for the WIM Modern skin."] = "Sfondi, campo di input e opzioni dei profili di gioco di ruolo per la skin WIM Modern.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Base"] = "Base", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Battle.net Received"] = "Battle.net ricevuti", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Battle.net Sent"] = "Battle.net inviati", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Behind the standard interface."] = "Dietro l'interfaccia standard.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Blizzard is restricting chat right now. Your message was not sent."] = "Blizzard sta limitando la chat in questo momento. Il tuo messaggio non è stato inviato.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Bracket Names"] = "Nomi tra parentesi", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Briefly turns game audio back on so a notification can be heard while all sound is disabled. The Master channel alone cannot get past that setting."] = "Riattiva brevemente l'audio del gioco così da far sentire una notifica quando tutto l'audio è disattivato. Il canale Principale da solo non può superare quell'impostazione.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["By conversation name."] = "Per nome della conversazione.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Calculate Minimum Size"] = "Calcola dimensione minima", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Cap Stored Messages"] = "Limita i messaggi salvati", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Capture"] = "Cattura", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Capture Community Channels"] = "Cattura canali delle comunità", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Capture Custom Channels"] = "Cattura canali personalizzati", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Capture World Channels"] = "Cattura canali del mondo", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Capture community channels, set per-channel exceptions, and keep their chat channels working."] = "Cattura i canali delle comunità, imposta eccezioni per canale e mantieni funzionanti i loro canali di chat.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Capture world and custom channels and set per-channel exceptions."] = "Cattura i canali del mondo e personalizzati e imposta eccezioni per canale.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Cascade Direction"] = "Direzione della cascata", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Cascade Windows"] = "Finestre a cascata", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Channels"] = "Canali", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Chat Follows Focus Rules"] = "La chat segue le regole del focus", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Chat Sounds"] = "Suoni della chat", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Chat Types"] = "Tipi di chat", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Chat windows join the whisper tab group instead of their own, even while Group Whispers is off."] = "Le finestre di chat si uniscono al gruppo di schede dei sussurri invece che al proprio, anche con «Raggruppa sussurri» disattivato.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Chat windows opened from WIM's menus normally take focus immediately; with this on they follow the pop-up focus rules instead."] = "Le finestre di chat aperte dai menu di WIM di norma prendono subito il focus; con questa opzione seguono invece le regole del focus dei pop-up.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Chat windows share one tabbed window. Does not apply to windows already opened."] = "Le finestre di chat condividono un'unica finestra a schede. Non vale per le finestre già aperte.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Check to use alternate pop-up rules for this situation. Unchecked, the Base rules apply."] = "Spunta per usare regole pop-up alternative in questa situazione. Se non spuntato, valgono le regole di base.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Choose what WIM captures: whispers, chat types, and channels."] = "Scegli cosa cattura WIM: sussurri, tipi di chat e canali.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Clamp to Screen"] = "Blocca allo schermo", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Class-Colored Names"] = "Nomi nel colore della classe", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Click Hold Limit"] = "Limite di pressione del clic", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Click to Release Focus"] = "Clic per rilasciare il focus", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Clickable Links"] = "Link cliccabili", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Clicking the game world releases WIM's keyboard focus so movement keys control your character again. Not while in combat."] = "Cliccare nel mondo di gioco rilascia il focus della tastiera di WIM, così i tasti di movimento tornano a controllare il personaggio. Non in combattimento.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Clicks held longer than this are treated as camera turns and keep WIM's focus."] = "I clic tenuti premuti più a lungo sono trattati come rotazioni della telecamera e mantengono il focus di WIM.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Combat Auto-Hide"] = "Nascondi automaticamente in combattimento", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Combat hiding only happens inside dungeons, raids, battlegrounds, and arenas."] = "Il nascondimento in combattimento avviene solo in spedizioni, incursioni, campi di battaglia e arene.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Communities"] = "Comunità", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Content Background"] = "Sfondo del contenuto", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Continuation lines of wrapped messages are indented."] = "Le righe di continuazione dei messaggi a capo sono rientrate.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Conversations"] = "Conversazioni", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Custom %s Rules"] = "Regole personalizzate: %s", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Custom Channels"] = "Canali personalizzati", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Custom Rules"] = "Regole personalizzate", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Defaults"] = "Valori predefiniti", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Delete"] = "Elimina", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Delete All History"] = "Elimina tutta la cronologia", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Delete Old Messages"] = "Elimina i messaggi vecchi", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Distinct Chat Sounds"] = "Suoni di chat distinti", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Distinct Whisper Sounds"] = "Suoni di sussurro distinti", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Do not play sounds for this channel, whatever the Notifications page plays."] = "Non riprodurre suoni per questo canale, a prescindere dalla pagina Notifiche.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Do not record history for this channel, whatever History > Recording records."] = "Non registrare la cronologia di questo canale, a prescindere da Cronologia > Registrazione.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Draws the frame background only around the panels, so a clear panel background (None or Transparent) shows the game world behind the viewer."] = "Disegna lo sfondo del riquadro solo attorno ai pannelli, così uno sfondo dei pannelli libero (Nessuno o Trasparente) mostra il mondo di gioco dietro il visualizzatore.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Each message is prefixed with the time it arrived."] = "Ogni messaggio è preceduto dall'ora di arrivo.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Edit Mode"] = "Modalità modifica", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Erases every recorded conversation and the archive for every character on this account, then reloads the interface."] = "Cancella ogni conversazione registrata e l'archivio per ogni personaggio di questo account, poi ricarica l'interfaccia.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Error Messages"] = "Messaggi di errore", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Escape Hides Windows"] = "Esc nasconde le finestre", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Every whisper is recorded."] = "Ogni sussurro viene registrato.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Fade When Inactive"] = "Dissolvi se inattiva", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Fades the window frame, header, and buttons; message and input text stay opaque. Modern skins keep their frame art opaque."] = "Dissolve riquadro, intestazione e pulsanti della finestra; il testo dei messaggi e dell'input resta opaco. Le skin moderne mantengono opaca la grafica del riquadro.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Filter Chat"] = "Filtra la chat", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Filter Panel Background"] = "Sfondo del pannello filtri", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Filter Whispers"] = "Filtra i sussurri", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Filters run top to bottom; the first match wins. Allow lets a message through, Ignore hides it silently, Block hides it and, with Show Alert, tells you in the chat frame with a link to view it."] = "I filtri vengono eseguiti dall'alto in basso; vince la prima corrispondenza. Consenti lascia passare un messaggio, Ignora lo nasconde in silenzio, Blocca lo nasconde e, con Mostra avviso, te lo segnala nel riquadro di chat con un link per vederlo.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Focus & Input"] = "Focus e input", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Focus Streams at Login"] = "Metti a fuoco i flussi all'accesso", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Font"] = "Carattere", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Font Size"] = "Dimensione del carattere", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Force Blizzard's chat messaging lockdown for testing (on|off, does not persist)."] = "Forza il blocco dei messaggi di chat di Blizzard per i test (on|off, non persistente).", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Formatting"] = "Formattazione", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Frame Background"] = "Sfondo del riquadro", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Friends & guild"] = "Amici e gilda", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Friends and Battle.net friends."] = "Amici e amici Battle.net.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Friends only"] = "Solo amici", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Friends, Battle.net friends, and guild members."] = "Amici, amici Battle.net e membri della gilda.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Friends, Battle.net friends, guild members, and your current party and raid get through; whispers from anyone else are ignored. This drives the two WhisperSelect entries in the filter list below."] = "Passano amici, amici Battle.net, membri della gilda e il tuo gruppo e la tua incursione attuali; i sussurri di chiunque altro vengono ignorati. Questo pilota le due voci WhisperSelect nell'elenco di filtri qui sotto.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Group Chat Windows"] = "Raggruppa le finestre di chat", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Group Whispers"] = "Raggruppa sussurri", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Group windows into shared tab strips."] = "Raggruppa le finestre in barre di schede condivise.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Guild members."] = "Membri della gilda.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Guild only"] = "Solo gilda", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Hidden-Windows Indicator"] = "Indicatore di finestre nascoste", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Hide During Combat"] = "Nascondi in combattimento", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Hide windows during combat and restore them after."] = "Nascondi le finestre durante il combattimento e ripristinale dopo.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Hides these messages from the game's chat frame so they appear only in WIM. Per-type and per-channel 'Never Suppress' exceptions on the Conversations pages win. A message is not hidden when no WIM window would show it."] = "Nasconde questi messaggi dal riquadro della chat del gioco in modo che compaiano solo in WIM. Le eccezioni 'Non sopprimere mai' per tipo e per canale nelle pagine Conversazioni hanno la precedenza. Un messaggio non viene nascosto se nessuna finestra di WIM lo mostrerebbe.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Hiding"] = "Nascondimento", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Hiding waits until you finish typing your message."] = "Il nascondimento attende che tu finisca di scrivere il messaggio.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["History Preview Received"] = "Anteprima cronologia ricevuti", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["History Preview Sent"] = "Anteprima cronologia inviati", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Hover Item Tooltips"] = "Tooltip degli oggetti al passaggio", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Hovering an item link in a message shows its tooltip without clicking."] = "Passare il mouse su un link di oggetto in un messaggio mostra il suo tooltip senza cliccare.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["How messages are formatted and displayed."] = "Come vengono formattati e visualizzati i messaggi.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Ignore Arrow Keys"] = "Ignora le frecce", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["In-Line Whisper Mode"] = "Modalità sussurri in linea", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Includes emotes."] = "Include le emote.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Includes raid warnings."] = "Include gli avvisi di incursione.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Incoming Chat"] = "Chat in arrivo", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Incoming Whispers"] = "Sussurri in arrivo", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Incoming whispers always open in WIM while it is enabled; this additionally redirects typing /w and /r in the game's chat box into a WIM window. Not while in combat."] = "I sussurri in arrivo si aprono sempre in WIM finché è attivo; questa opzione reindirizza inoltre la digitazione di /w e /r nella casella di chat del gioco in una finestra WIM. Non in combattimento.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Indent Wrapped Lines"] = "Rientra le righe a capo", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Indicator"] = "Indicatore", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Indicator Thickness"] = "Spessore dell'indicatore", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Input Field"] = "Campo di input", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Keep Focus"] = "Mantieni il focus", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Keeps at most this many messages per conversation. Applies to whisper and chat history alike."] = "Conserva al massimo questo numero di messaggi per conversazione. Vale sia per la cronologia dei sussurri che per quella della chat.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Keeps the keyboard focus in the input box after sending a message."] = "Mantiene il focus della tastiera nella casella di input dopo l'invio di un messaggio.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Keyboard focus and input behavior."] = "Focus della tastiera e comportamento dell'input.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Known Senders Only"] = "Solo mittenti conosciuti", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Launcher"] = "Avviatore", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Launcher Alerts"] = "Avvisi dell'avviatore", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Level with dialog windows."] = "Al livello delle finestre di dialogo.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Level with most interface frames."] = "Al livello della maggior parte dei riquadri dell'interfaccia.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Limit Height"] = "Limita l'altezza", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Links & Emoticons"] = "Link ed emoticon", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Master switch for this channel type; individual channels are captured with the Capture flag below."] = "Interruttore principale per questo tipo di canale; i singoli canali si catturano con la casella Cattura qui sotto.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Maximum Lines"] = "Righe massime", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Menus & Tooltips"] = "Menu e tooltip", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Message Area Background"] = "Sfondo dell'area messaggi", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Message Format"] = "Formato dei messaggi", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Message Windows"] = "Finestre dei messaggi", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Message colors."] = "Colori dei messaggi.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Message font, outline, and size."] = "Carattere, contorno e dimensione dei messaggi.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Message suppression requires the game's Social > Whisper Mode setting to be In-line; without it, suppressed whispers would vanish into a popout chat tab."] = "La soppressione dei messaggi richiede che l'impostazione Sociale > Modalità sussurri del gioco sia su In linea; altrimenti i sussurri soppressi sparirebbero in una scheda di chat separata.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Messages Received"] = "Messaggi ricevuti", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Messages Sent"] = "Messaggi inviati", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Messages per Conversation"] = "Messaggi per conversazione", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Minimap Button"] = "Pulsante della minimappa", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Most recently active conversation first."] = "Prima la conversazione attiva più di recente.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Multi-Line Input"] = "Input su più righe", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Native Input Colors"] = "Colori di input nativi", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Navigation List Background"] = "Sfondo dell'elenco di navigazione", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Never Pop Up"] = "Non aprire mai", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Never have this window pop-up on my screen. Overrides Windows > Pop-up Rules."] = "Non far mai comparire questa finestra sullo schermo. Prevale su Finestre > Regole dei pop-up.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Never suppress messages from the default chat frame. Overrides 'Show Only in WIM' under Windows > Pop-up Rules."] = "Non sopprimere mai i messaggi dal riquadro di chat predefinito. Prevale su «Mostra solo in WIM» in Finestre > Regole dei pop-up.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["New windows that would overlap are offset in the chosen direction. Whisper windows do not cascade while Group Whispers is on, nor chat windows while Group Chat Windows is on. Applies to windows opened after the change."] = "Le nuove finestre che si sovrapporrebbero vengono spostate nella direzione scelta. Le finestre di sussurro non vanno a cascata con «Raggruppa sussurri» attivo, né quelle di chat con «Raggruppa le finestre di chat» attivo. Vale per le finestre aperte dopo la modifica.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["No one (GM whispers only)"] = "Nessuno (solo sussurri dei GM)", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Nothing is recorded except game master whispers."] = "Non viene registrato nulla tranne i sussurri dei game master.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Notifications"] = "Notifiche", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Oldest conversation first."] = "Prima la conversazione più vecchia.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Only While in an Instance"] = "Solo dentro un'istanza", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Open History Viewer"] = "Apri il visualizzatore della cronologia", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Opens a placement window; drag it to where new windows should appear, then close it to save the spot."] = "Apre una finestra di posizionamento; trascinala dove devono comparire le nuove finestre, poi chiudila per salvare la posizione.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Opens the window when a message arrives in this situation."] = "Apre la finestra quando arriva un messaggio in questa situazione.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Opens the window when you send a message in this situation."] = "Apre la finestra quando invii un messaggio in questa situazione.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Optional different sounds for whispers from particular senders."] = "Suoni diversi facoltativi per i sussurri di determinati mittenti.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Optional different sounds per chat type."] = "Suoni diversi facoltativi per tipo di chat.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Outline for the message area and input box text."] = "Contorno del testo dell'area messaggi e della casella di input.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Override Muted Audio"] = "Ignora l'audio disattivato", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Placement & Size"] = "Posizione e dimensione", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Playback"] = "Riproduzione", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Player names take their class color. Applies to new messages."] = "I nomi dei giocatori assumono il colore della loro classe. Vale per i nuovi messaggi.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays a distinct sound for raid chat instead of the standard incoming sound; raid warnings keep the standard sound. It never mutes."] = "Riproduce un suono distinto per la chat di incursione invece del suono in arrivo standard; gli avvisi di incursione mantengono il suono standard. Non silenzia mai.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays a distinct sound for this chat type instead of the standard incoming sound; it never mutes. Use a channel's No Sound flag or turn off incoming chat sounds to silence."] = "Riproduce un suono distinto per questo tipo di chat invece del suono in arrivo standard; non silenzia mai. Usa la casella Nessun suono di un canale o disattiva i suoni di chat in arrivo per silenziarlo.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays a sound when a captured chat message arrives. Per-channel No Sound flags on the channel lists mute individual channels."] = "Riproduce un suono quando arriva un messaggio di chat catturato. Le caselle Nessun suono per canale negli elenchi dei canali silenziano i singoli canali.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays a sound when a whisper arrives."] = "Riproduce un suono quando arriva un sussurro.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays a sound when you send a message in a captured chat type, from WIM or the game's chat box."] = "Riproduce un suono quando invii un messaggio in un tipo di chat catturato, da WIM o dalla casella di chat del gioco.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays a sound when you send a whisper."] = "Riproduce un suono quando invii un sussurro.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays notification sounds on the Master channel so they are heard even when sound effects are turned off."] = "Riproduce i suoni di notifica sul canale Principale, così si sentono anche con gli effetti sonori disattivati.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays this sound instead of the standard incoming whisper sound."] = "Riproduce questo suono invece del suono standard dei sussurri in arrivo.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Pop Up on Receive"] = "Apri alla ricezione", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Pop Up on Send"] = "Apri all'invio", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Pop-up Rules"] = "Regole dei pop-up", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Pressing Escape hides all open WIM windows."] = "Premere Esc nasconde tutte le finestre WIM aperte.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Pressing Tab in a whisper window jumps to the next person you whispered. While enabled, forward Tab no longer cycles through window tabs."] = "Premere Tab in una finestra di sussurro passa alla persona successiva a cui hai sussurrato. Finché è attivo, Tab non scorre più le schede delle finestre.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Preview Count"] = "Numero in anteprima", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Preview Recent Messages"] = "Anteprima dei messaggi recenti", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays this sound instead of the standard incoming whisper sound when a Battle.net friend whispers. When several match, Battle.net friend wins over friend and guild member."] = "Riproduce questo suono invece del suono standard dei sussurri in arrivo quando sussurra un amico Battle.net. Se corrispondono più voci, amico Battle.net prevale su amico e membro della gilda.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Privacy & Filtering"] = "Privacy e filtri", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Profile Fields"] = "Campi del profilo", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Puts the keyboard focus in the input box when a window pops up."] = "Mette il focus della tastiera nella casella di input quando compare una finestra.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Re-adds community channels to your chat frames when the client drops them, once per login after a late stream focus; /wim channelrepair runs it now. Opt-in: this mutates saved chat window configuration."] = "Riaggiunge i canali delle comunità ai tuoi riquadri di chat quando il client li perde, una volta per accesso dopo una messa a fuoco tardiva del flusso; /wim channelrepair lo esegue subito. Facoltativo: modifica la configurazione salvata delle finestre di chat.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Record From"] = "Registra da", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Record Whispers"] = "Registra i sussurri", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Recording"] = "Registrazione", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Recording stops as soon as this is off; the history button stays on open windows until the next reload."] = "La registrazione si ferma non appena disattivi questa opzione; il pulsante della cronologia resta sulle finestre aperte fino al prossimo ricaricamento.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Redirect /w and /r to WIM"] = "Reindirizza /w e /r a WIM", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Repair Dropped Channels"] = "Ripara i canali persi", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Reset Position"] = "Reimposta posizione", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Retention"] = "Conservazione", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Retention caps, preview, and deletion."] = "Limiti di conservazione, anteprima ed eliminazione.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Right-Click Opens Unread"] = "Clic destro apre i non letti", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Runs the whisper filter list below. While off, addon-spam whispers open windows like any other whisper."] = "Esegue l'elenco di filtri dei sussurri qui sotto. Se disattivato, i sussurri di spam degli addon aprono finestre come qualsiasi altro sussurro.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["See-Through Frame"] = "Riquadro trasparente", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Sender Details"] = "Dettagli del mittente", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Sent Chat"] = "Chat inviata", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Sent Whispers"] = "Sussurri inviati", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Separate Friends Group"] = "Gruppo separato per gli amici", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Separate Guild Group"] = "Gruppo separato per la gilda", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Set to In-line"] = "Imposta su In linea", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Share Tab Group with Whispers"] = "Condividi il gruppo di schede con i sussurri", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Shortcut Bar"] = "Barra delle scorciatoie", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Show Only in WIM"] = "Mostra solo in WIM", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Show Roleplay Profiles"] = "Mostra i profili di gioco di ruolo", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Show Timestamps"] = "Mostra gli orari", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Show WIM Tooltips"] = "Mostra i tooltip di WIM", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Show an unread message badge on the WIM launcher icons."] = "Mostra un badge di messaggio non letto sulle icone di avvio di WIM.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Show an unread message badge on the WIM launcher icons. Off by default for channels."] = "Mostra un badge di messaggio non letto sulle icone di avvio di WIM. Disattivato per impostazione predefinita per i canali.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Shows help tooltips on WIM's windows, lists, and the custom rows of these options."] = "Mostra tooltip di aiuto sulle finestre e sugli elenchi di WIM e sulle righe personalizzate di queste opzioni.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Shows the most recent messages when a window opens. Applies to whisper and chat history alike, and requires Record Whispers."] = "Mostra i messaggi più recenti all'apertura di una finestra. Vale sia per la cronologia dei sussurri che per quella della chat, e richiede «Registra i sussurri».", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Shows the row of shortcut buttons on message windows. Turning this off takes effect after the next interface reload."] = "Mostra la riga dei pulsanti di scorciatoia sulle finestre dei messaggi. La disattivazione ha effetto dopo il prossimo ricaricamento dell'interfaccia.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Shows the sender's class, level, and guild on their window. Sends one /who lookup when the window opens. Applies to windows opened after the change."] = "Mostra classe, livello e gilda del mittente nella sua finestra. Invia una ricerca /who all'apertura della finestra. Vale per le finestre aperte dopo la modifica.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Situations without custom rules follow these base rules."] = "Le situazioni senza regole personalizzate seguono queste regole di base.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Skin"] = "Skin", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Skin default"] = "Predefinito della skin", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Skin, fonts, message look, and colors."] = "Skin, caratteri, aspetto dei messaggi e colori.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Sort Menu by Activity"] = "Ordina il menu per attività", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Sort Tabs By"] = "Ordina le schede per", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Sounds for whispers and chat, and how they are played."] = "Suoni per sussurri e chat, e come vengono riprodotti.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Sources"] = "Sorgenti", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Storage"] = "Archiviazione", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["System Messages & Timestamps"] = "Messaggi di sistema e orari", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Tab Groups"] = "Gruppi di schede", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Tab to Next Whisper"] = "Tab al sussurro successivo", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Text smileys render as icons."] = "Le faccine testuali vengono mostrate come icone.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The base rules. Situations without custom rules follow these."] = "Le regole di base. Le situazioni senza regole personalizzate seguono queste.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The button can then be dragged anywhere on the screen."] = "Il pulsante può quindi essere trascinato ovunque sullo schermo.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The direction windows slide out when they hide. Also used by the show/hide key binding. Only applies while Window Animations is on under Appearance > Skin."] = "La direzione in cui le finestre scivolano quando si nascondono. Usata anche dal tasto mostra/nascondi. Vale solo con «Animazioni delle finestre» attivo in Aspetto > Skin.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The interface layer WIM windows draw on; higher layers cover lower ones."] = "Il livello dell'interfaccia su cui vengono disegnate le finestre WIM; i livelli superiori coprono quelli inferiori.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The message area renders two points larger than the chosen size; the input box and header follow the skin."] = "L'area messaggi viene mostrata due punti più grande della dimensione scelta; la casella di input e l'intestazione seguono la skin.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The message box at the bottom of each window."] = "La casella dei messaggi in fondo a ogni finestra.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The message history window."] = "La finestra della cronologia dei messaggi.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The skin and window chrome."] = "La skin e la cornice delle finestre.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The skin picks the font."] = "La skin sceglie il carattere.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The sound to play. The speaker button plays a preview."] = "Il suono da riprodurre. Il pulsante con l'altoparlante riproduce un'anteprima.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The whisper and chat windows."] = "Le finestre dei sussurri e della chat.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The window for adding and editing whisper and chat filters."] = "La finestra per aggiungere e modificare i filtri di sussurri e chat.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["These settings style WIM's modern-only skins (such as WIM Modern), which are built from the game's own interface art. They are available while a modern-only skin is selected on the Skin page; with a classic skin active they are greyed out."] = "Queste impostazioni definiscono lo stile delle skin esclusivamente moderne di WIM (come WIM Modern), costruite con la grafica dell'interfaccia del gioco. Sono disponibili finché nella pagina Skin è selezionata una skin esclusivamente moderna; con una skin classica attiva sono disattivate.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Timestamps"] = "Orari", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Total RP 3 and Mary Sue Protocol profile display on whisper windows."] = "Visualizzazione dei profili Total RP 3 e Mary Sue Protocol nelle finestre di sussurro.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Type %s to confirm."] = "Digita %s per confermare.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Unlock Minimap Button"] = "Sblocca il pulsante della minimappa", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Use Master Sound Channel"] = "Usa il canale audio Principale", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["WIM Message Window"] = "Finestra dei messaggi di WIM", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["WIM Modern Skin"] = "Skin WIM Modern", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["WIM manages this chat type in its own message windows. Turning a type off stops capture now; its window button stays until the next reload."] = "WIM gestisce questo tipo di chat nelle proprie finestre dei messaggi. Disattivare un tipo ferma subito la cattura; il suo pulsante di finestra resta fino al prossimo ricaricamento.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["WIM's launcher menus list the most recently active conversations first."] = "I menu di avvio di WIM elencano per prime le conversazioni attive più di recente.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["WIM: the options UI is not available on this client."] = "WIM: l'interfaccia delle opzioni non è disponibile su questo client.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Wait While Typing"] = "Attendi mentre scrivi", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Web Addresses"] = "Indirizzi web", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Web addresses in messages become clickable links."] = "Gli indirizzi web nei messaggi diventano link cliccabili.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["What WIM takes over: whispers, and the chat types that get their own windows."] = "Cosa gestisce WIM: i sussurri e i tipi di chat che hanno finestre proprie.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["What is kept, and for how long."] = "Cosa viene conservato e per quanto tempo.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["When choosing the /reply target, your most recent sent whisper counts as well as the last one received."] = "Nella scelta del destinatario di /reply conta anche l'ultimo sussurro inviato, non solo l'ultimo ricevuto.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["When windows appear, where they sit, and what has keyboard focus."] = "Quando compaiono le finestre, dove si posizionano e cosa ha il focus della tastiera.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["When windows pop up and when messages leave the chat frame, per situation."] = "Quando compaiono le finestre e quando i messaggi lasciano il riquadro di chat, per situazione.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Where new windows appear, their default size and scale, and the placement of the History Viewer and filter editor are set in the game's Edit Mode."] = "Dove compaiono le nuove finestre, la loro dimensione e scala predefinite e la posizione del visualizzatore della cronologia e dell'editor dei filtri si impostano nella modalità modifica del gioco.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Which whispers and chat types are recorded."] = "Quali sussurri e tipi di chat vengono registrati.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["While in a battleground."] = "In un campo di battaglia.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["While in a dungeon."] = "In una spedizione.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["While in a raid instance."] = "In un'istanza di incursione.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["While in an arena match."] = "In una partita in arena.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["While in combat."] = "In combattimento.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["While resting in an inn or city."] = "A riposo in una locanda o in città.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Whisper Sounds"] = "Suoni dei sussurri", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Whisper windows opened from WIM's menus normally take focus immediately; with this on they follow the pop-up focus rules instead."] = "Le finestre di sussurro aperte dai menu di WIM di norma prendono subito il focus; con questa opzione seguono invece le regole del focus dei pop-up.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Whisper windows share one tabbed window. Does not apply to windows already opened."] = "Le finestre di sussurro condividono un'unica finestra a schede. Non vale per le finestre già aperte.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Whisper windows show roleplay profile fields from Total RP 3 or any Mary Sue Protocol addon, and gain an Open RP Profile button on their shortcut bar that opens the partner's profile in the installed viewer. Requires the WIM Modern skin."] = "Le finestre di sussurro mostrano i campi del profilo di gioco di ruolo da Total RP 3 o da qualsiasi addon Mary Sue Protocol, e guadagnano un pulsante «Apri profilo GdR» nella barra delle scorciatoie che apre il profilo dell'interlocutore nel visualizzatore installato. Richiede la skin WIM Modern.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Whispers Follow Focus Rules"] = "I sussurri seguono le regole del focus", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Whispers from friends group into their own tabbed window."] = "I sussurri degli amici si raggruppano in una finestra a schede propria.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Whispers from game masters are always recorded. Battle.net whispers count as friends."] = "I sussurri dei game master vengono sempre registrati. I sussurri Battle.net contano come amici.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Whispers from guild members group into their own tabbed window. A friend who is also a guild member goes to the friends group."] = "I sussurri dei membri della gilda si raggruppano in una finestra a schede propria. Un amico che è anche membro della gilda va nel gruppo degli amici.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Who gets through."] = "Chi passa.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Window Animations"] = "Animazioni delle finestre", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Window Layer"] = "Livello delle finestre", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Window Opacity"] = "Opacità delle finestre", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Window Skin"] = "Skin delle finestre", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Where new windows spawn and how big they are, their layer, cascading, and screen clamping."] = "Dove compaiono le nuove finestre e quanto sono grandi, il loro livello, la cascata e il blocco allo schermo.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Windows"] = "Finestre", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Windows Opened from Menus"] = "Finestre aperte dai menu", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Windows cannot be dragged past the screen edges."] = "Le finestre non possono essere trascinate oltre i bordi dello schermo.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Windows fade to half opacity after two seconds without the mouse over them."] = "Le finestre si dissolvono a metà opacità dopo due secondi senza il mouse sopra.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["World Channels"] = "Canali del mondo", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Wraps player names in brackets."] = "Racchiude i nomi dei giocatori tra parentesi.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["You are about to permanently delete WIM's message history for every character on this account."] = "Stai per eliminare definitivamente la cronologia dei messaggi di WIM per ogni personaggio di questo account.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["instant"] = "istantaneo", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["slow"] = "lento", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Community chat cannot be recorded, so this is always on for community channels."] = "La chat delle comunità non può essere registrata, quindi per i canali delle comunità questa opzione è sempre attiva.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Width"] = "Larghezza", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Height"] = "Altezza", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["WIM Filter Editor"] = "Editor dei filtri WIM", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
});

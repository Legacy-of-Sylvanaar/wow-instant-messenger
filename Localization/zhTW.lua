--[[
    Update:2010/07/04
    Language Localization: zhTW
    Translated by: Junxian <junxian1121@hotmail.com>
]]

WIM.AddLocale("zhTW", {
    ["WIM (WoW Instant Messenger)"] = "WIM （魔獸世界即時通）",
    ["_Description"] = "WIM 的設計是為了讓你在魔獸世界中與人交談時有更親切的介面，在這個視窗中您可以自訂所有的設定。若您有任何的問題，歡迎各位到官方網頁提供意見。\n網址：http://www.WIMAddon.com",

    ["_DemoText"] = "這個視窗可以設定對話視窗出現的預設位置。您可以將這個視窗拖曳到您想要的位置，當您關閉這個視窗的時候，所有的設定將被自動記錄下來。",

    ["_DateFormat"] = "%Y/%m/%d",

    ["Yes"] = "是",
    ["No"] = "否",
    ["None"] = "無",
    ["Cancel"] = "取消",
    ["Unknown"] = "未知",
    ["Click to update..."] = "點擊更新……",
    ["Usage"] = "使用",

    ["state_resting"] = "休息",
    ["state_combat"] = "戰鬥",
    ["state_pvp"] = "PVP",
    ["state_arena"] = "競技場",
    ["state_party"] = "組隊",
    ["state_raid"] = "團隊",
    ["state_other"] = "一般（其他）",

    ["Options"] = "選項",

    ["Up"] = "上",
    ["Down"] = "下",
    ["Left"] = "左",
    ["Right"] = "右",
    ["Ignore"] = "忽略",
    ["Block"] = "封鎖",
    ["Enable WIM"] = "開啟 WIM",

    ["Enable"] = "開啟",
    ["Disable"] = "關閉",

    ["History"] = "聊天記錄",
    ["Filters"] = "過濾條件",

    ["Window Created"] = "最先密你的",
    ["Last Activity"] = "最後密你的",
    ["Alphabetical"] = "字母順序",

    -- Class Names --
    ["Druid"] = "德魯伊",
    ["Hunter"] = "獵人",
    ["Mage"] = "法師",
    ["Paladin"] = "聖騎士",
    ["Priest"] = "牧師",
    ["Rogue"] = "盜賊",
    ["Shaman"] = "薩滿",
    ["Warlock"] = "術士",
    ["Warrior"] = "戰士",
    ["Death Knight"] = "死亡騎士",
    ["Monk"] = "武僧",
    ["Demon Hunter"] = "惡魔獵人",
    ["Evoker"] = "喚魔師",

    -- Female Class Names --
    ["DruidF"] = "德魯伊",
    ["HunterF"] = "獵人",
    ["MageF"] = "法師",
    ["PaladinF"] = "聖騎士",
    ["PriestF"] = "牧師",
    ["RogueF"] = "盜賊",
    ["ShamanF"] = "薩滿",
    ["WarlockF"] = "術士",
    ["WarriorF"] = "戰士",
    ["Death KnightF"] = "死亡騎士",
    ["MonkF"] = "武僧",
    ["Demon HunterF"] = "惡魔獵人",
    ["EvokerF"] = "喚魔師",

    ["Game Master"] = "遊戲管理者",

    -- WIM.lua --
    ["Toggle WIM 'On' and 'Off'."] = "開啟/關閉 WIM",

    -- Filters.lua --
    ["Whispers Sent by Addons"] = "由插件所發出的密語",
    ["WhisperSelect Part 1"] = "密語選擇 1",
    ["Example Spam Blocker"] = "阻擋的訊息範例",
    ["WhisperSelect Part 2"] = "密語選擇 2",
    ["Filter Name"] = "過濾名字",
    ["Filter By"] = "過濾條件",
    ["Pattern"] = "模式",
    ["User Type"] = "玩家狀況",
    ["Level"] = "等級",
    ["Friends"] = "好友",
    ["Guild Members"] = "公會成員",
    ["Party Members"] = "隊伍成員",
    ["Raid Members"] = "團隊成員",
    ["Cross-Realm"] = "敵對陣營",
    ["Everyone"] = "所有人",
    ["User must be at least level:"] = "使用者最低等級:",
    ["Apply to messages received."] = "套用到接收訊息規則",
    ["Apply to messages sent."] = "套用到傳送訊息規則",
    ["Apply to:"] = "套用至：",
    ["All Classes"] = "所有職業",
    ["Action to Perform:"] = "執行動作:",
    ["Allow"] = "允許",
    ["Ignore"] = "忽略",
    ["Blocked"] = "封鎖",
    ["Save"] = "儲存",
    ["Cancel"] = "取消",
    ["Edit Filter"] = "編輯過濾條件",
    ["Add Filter"] = "增加過濾條件",

    -- History.lua --
    ["WIM History Button"] = "WIM 對話記錄按鈕",
    ["Click to view message history."] = "檢視歷史記錄",
    ["WIM pruned %d |4message:messages; from your history."] = "WIM 刪除 %d 消息從你的歷史記錄",
    ["History Viewer"] = "對話記錄檢視",
    ["Filters"] = "過濾器",
    ["Are you sure you want to delete all history saved for %s on %s?"] = "您確定要刪除所有 %s 在 %s 儲存的記錄？",
    ["Search resulted in %d |4message:messages;."] = "搜尋結果於 %d 消息",
    ["No results found!"] = "沒有發現符合的條件！",
    ["Search"] = "搜尋",
    ["Show All"] = "顯示全部",
    ["Loading History"] = "載入對話記錄",
    ["Chat View"] = "檢視對話",
    ["Text View"] = "檢視文字",
    ["BBCode"] = "BBCode",
    ["WIM History Viewer"] = "檢視 WIM 對話記錄",
    ["Display history viewer."] = "顯示對話記錄",

    -- ldb.lua --
    ["No New Messages"] = "沒有新的訊息",

    -- Menu.lua --
    ["Whispers"] = "密語",
    ["Chat"] = "聊天訊息",

    -- Negotiate.lua --
    ["WIM Update Available!"] = "WIM 已有新的更新！",

    -- ShortcutBar.lua --
    ["Location"] = "玩家位置",
    ["Character"] = "角色",
    ["Game"] = "遊戲",
    ["Realm"] = "伺服器",
    ["Player Location"] = "玩家位置",
    ["Unknown"] = "未知",
    ["Click to update..."] = "點擊更新資訊……",
    ["Invite to Party"] = "組隊邀請",
    ["Invite to Guild"] = "公會邀請",
    ["Add Friend"] = "添加好友",
    ["Ignore Player"] = "忽略玩家",
    ["Are you sure you want to\nignore %s?"] = "您確定您要忽略 %s",
    ["Right-Click for profile links..."] ="右鍵點擊 查看英雄榜",
    ["Profile Links"] = "查看英雄榜",
	["Copy Name"] = "複製名稱",

    -- Tutorials.lua --
    ["View Updates"] = "檢視更新",

    -- WhisperEngine.lua --
    ["Whisper Received!"] = "收到密語！",
    ["Recently Sent Messages"] = "最近傳送的訊息",
    ["Users in %s"] = "%s中的用戶",

    -- Clear.lua --
    ["This action will reload your user interface."] = "這個動作將重新載入你的使用者介面",
    ["Do you want to continue?"] = "你確定要繼續嗎?",
    ["You are about to restore WIM's filters to it's default settings!"] = "你即將把 WIM 的過濾選項恢復成預設值！",
    ["Usage"] = "使用",
    ["Clear various WIM data."] = "清除所有 WIM 資料",

    -- SlashHandler.lua --
    ["WIM Slash Commands"] = "WIM 指令",
    ["Hide or show {all, whisper, chat} windows."] = "隱藏或顯示{所有、密語、聊天}視窗。",
    ["To see a list of available WIM slash commands type:"] = "顯示可用的 WIM 指令：",
    ["Display available slash commands."] = "顯示可用的 WIM 指令",
    ["Reload User Interface."] = "重新載入使用者介面",

    -- TabHandler.lua --
    ["Manipulating Tabs"] = "操作群組標籤",

    -- WindowHandler.lua --
    ["Window Resized!"] = "視窗尺寸已改變",
    ["Creating Tab Groups"] = "建立群組標籤",
    ["You can group two or many windows together by <Shift-Clicking> a window and dragging it on top of another."] = "您可以透過 <Shift-左鍵> 點擊一個視窗後，跟其他視窗拖曳在一起，將多個視窗合併成一個",
    ["Resizing Windows"] = "變更視窗尺寸",
    ["You can resize a window by holding <Shift> and dragging the bottom right corner of the window."] = "您可以透過按著 <Shift> 鍵並拖曳視窗右下角來變更視窗大小",
    ["Demo Window"] = "視窗範例",
    ["<Shift-Click> to close window."] = "<Shift-左鍵> 關閉視窗",
    ["Message Window Hidden"] = "隱藏訊息視窗",
    ["Default"] = "預設",
    ["%s is Away From Keyboard: %s"] = "%s 目前暫離：%s",
    ["%s does not wish to be disturbed: %s"] = "%s 目前不願被打擾：%s",
    ["Right-Mouse Click!"] = "滑鼠 右鍵點擊！",
    ["There might be useful tools hidden under the message box. Right-Click to see them!"] = "有可用的工具被隱藏在訊息欄下方，請按滑鼠右鍵開啟",

    -- Options.lua --
    ["Display WIM's options."] = "顯示 WIM 設定選單",
    ["Resetting WIM will clear all of your settings!"] = "重設 WIM 將會清除您所有的設定！",
    ["A reset will reload your user interface."] = "重設後將重新載入您的使用者介面。",
    ["Reset all options to default."] = "將所有設定恢復為預設值",

    -- CoreOptions --
    ["Created By:"] = "作者：",
    ["Special Thanks:"] = "特別感謝：",
    ["Enable WIM"] = "啟用 WIM",
    ["Credits"] = "榮譽",
    ["This is a long message which contains both emoticons and urls 8). WIM's home is www.WIMAddon.com."] = "這一段很長的訊息是給你觀看設定後的顯示效果用的。 其中包含網址連接與心情符號 8)。 我們的網址是 www.WIMAddon.com",
    ["Preview"] = "預覽",
    ["Window Scale"] = "視窗縮放",
    ["Set Window Spawn Location"] = "設定視窗出現位置",
    ["Up"] = "上",
    ["Down"] = "下",
    ["Left"] = "左",
    ["Right"] = "右",
    ["Version"] = "版本",
    ["Font Outline"] = "文字描邊",
    ["Thin"] = "細",
    ["Thick"] = "粗",

    ["Allow"] = "允許",
    ["Ignore"] = "忽略",
    ["Block"] = "封鎖",
    ["Protected"] = "已保護",
    ["Action:"] = "動作：",
    ["Occurrences:"] = "發生次數：",
    ["Delete Filter"] = "刪除過濾",
    ["History"] = "訊息記錄",
    ["Messages"] = " 則訊息",
    ["Record Chat"] = "記錄對話",
    ["Maintenance"] = "維護",
    ["%d |4Week:Weeks;"] = "%d 週",
    ["User Level"] = "玩家等級",
    ["Sounds"] = "音效",
	["Background"] = BACKGROUND,
	["Low"] = LOW,
	["Medium"] = "中",
	["High"] = "高",
	["Dialog"] = ENABLE_DIALOG,
	["Tooltip"] = "提示",

    -- TabManagement.lua --

    -- Talent Specs --
	["Hybrid"] = "混合",

    -- Filters.lua --
    ["Show Alert"] = "顯示警告",
    ["WIM has blocked a message from %s."] = "WIM 發現阻檔訊息來自 %s",
    ["View Blocked Message"] = "檢視阻檔訊息",
    ["Blocked Message"] = "阻檔訊息",

    -- MinimapIcon.lua
    ["Show Unread Messages"] = "顯示未閱讀訊息",
    ["Show All Windows"] = "顯示所有視窗",
    ["Hide All Windows"] = "隱藏所有視窗",

    --Emoticons.lua
    ["Also"] = "並且",
    ["More"] = "更多",
    ["Emoticons"] = "心情符號",

    --Expose.lua
    ["Your conversations have been hidden in order to clear your screen while in combat. To disable this feature type"] = "你的對話視窗將在進入戰鬥狀態時被隱藏。要停用這個功能請輸入：",
    ["Expose"] = "Expose",

    --ChatEngine.lua
    ["Have WIM monitor this channel."] = "WIM 已監視這個頻道",
    ["Never Suppress"] = "絕不抑制",
    ["No History"] = "無對話記錄",
    ["World Chat"] = "一般頻道",
    ["Custom Chat"] = "自定頻道",
    ["Community Chat"] = "社群聊天",
    ["Chat"] = "聊天",
    ["No Sound"] = "無聲",

    --OffScreenTracker.lua
    ["WIM Window Off Screen"] = "關閉 WIM 視窗追蹤",
    ["Click to reposition."] = "點擊 重新定位",

    -- Whisper Mode Warnings
    ["Set whispers to In-line"] = "將密語設定為內聯",
    ["It is recommended for whispers to be set to in-line in order to handle their behavior properly."] = "建議將密語設定為內聯，以便正確處理其行為。",

    -- Skins --
    ["Blue"] = "藍色",
    ["Green"] = "綠色",
    ["Red"] = "紅色",
    ["Yellow"] = "黃色",

    -- Battle.net friend consolidation (History Viewer)
    ["Battle.net Friends"] = "戰網好友",
    ["Are you sure you want to delete ALL history saved with %s, across every realm and every character on this account?"] = "您確定要刪除與 %s 在此帳號所有伺服器與所有角色儲存的所有記錄嗎？",

    -- Per-date deletion from the History Viewer filter list
    ["Are you sure you want to delete the %s history with %s across every realm and character on this account?"] = "您確定要刪除 %s 當天與 %s 在此帳號所有伺服器與角色儲存的記錄嗎？",
    ["Are you sure you want to delete the %s history for %s across every character on %s?"] = "您確定要刪除 %s 當天 %s 在 %s 所有角色儲存的記錄嗎？",
    ["Are you sure you want to delete the %s history for %s on %s?"] = "您確定要刪除 %s 當天 %s 在 %s 儲存的記錄嗎？",


    -- Modern options panel --

    -- Modern skin styling --
    ["None (game default)"] = "無（遊戲預設）",
    ["Draws the window frame background only around the message area, so a clear message area background (None or Transparent) shows the game world behind the window."] = "僅在訊息區域周圍繪製視窗邊框背景，如此當訊息區域背景為空（無或透明）時，視窗背後顯示的是遊戲世界。",

    -- Roleplay profiles (Total RP 3 / Mary Sue Protocol) --
    ["Roleplay Profiles"] = "角色扮演檔案",
    ["Open RP Profile"] = "開啟 RP 檔案",
    ["Whisper windows show the selected fields from the partner's Total RP 3 or Mary Sue Protocol profile. Fields left unselected -- or without profile data -- keep the standard display."] = "密語視窗顯示對方 Total RP 3 或 Mary Sue Protocol 檔案中勾選的欄位。未勾選的欄位——或沒有檔案資料的欄位——維持標準顯示。",
    ["First Name"] = "名字",
    ["Last Name"] = "姓氏",
    ["Title"] = "頭銜",
    ["Full Title"] = "完整頭銜",
    ["Race"] = "種族",
    ["Class"] = "職業",
    ["Portrait"] = "肖像",
    ["Name & Class Color"] = "名稱與職業顏色",
    ["The profile's first name, shown as the window's name text."] = "檔案中的名字，顯示為視窗的名稱文字。",
    ["The profile's last name, shown as the window's name text."] = "檔案中的姓氏，顯示為視窗的名稱文字。",
    ["The short title, shown on the window's details line."] = "短頭銜，顯示在視窗的詳細資訊列。",
    ["The long title, shown on the window's details line and portrait tooltip."] = "長頭銜，顯示在視窗的詳細資訊列與肖像提示中。",
    ["The custom race, replacing the character's race on the details line."] = "自訂種族，取代詳細資訊列中角色的種族。",
    ["The custom class, replacing the character's class on the details line."] = "自訂職業，取代詳細資訊列中角色的職業。",
    ["The profile's icon, replacing the class icon."] = "檔案圖示，取代職業圖示。",
    ["The profile's custom color, applied to the window's name text and to the class on the details line."] = "檔案的自訂顏色，套用於視窗的名稱文字與詳細資訊列中的職業。",
    ["Apply filter to character menus"] = "將過濾器套用到角色選單",

    -- History Viewer filters --
    ["No Filter"] = "無過濾器",
    ["Relative Dates"] = "相對日期",
    ["%d or more"] = "%d 則以上",
    ["Fewer than %d"] = "少於 %d 則",
    ["Results Filtered"] = "結果已過濾",
    ["-- Results Filtered --"] = "-- 結果已過濾 --",
    ["Results are hidden by the active filter. Click to open the Filters menu."] = "結果已被目前的過濾器隱藏。點擊以開啟過濾器選單。",
    ["Click to change how history is filtered."] = "點擊變更記錄的過濾方式。",
    ["Click to open the Filters menu."] = "點擊開啟過濾器選單。",
    ["Clicking the %s button on the message window will show that user's history in WIM's History Viewer."] = "點擊訊息視窗上的 %s 按鈕，將在 WIM 的記錄檢視器中顯示該玩家的記錄。",

    -- Message input & formatting --
    ["Caps how far the input field grows; past the limit the message scrolls inside it."] = "限制輸入框可成長的高度；超過上限後，訊息會在框內捲動。",
    ["The most lines the input field grows to before the message scrolls inside it."] = "輸入框在訊息開始捲動前最多可成長到的行數。",
    ["The input field wraps long messages onto multiple lines, growing downward with the message instead of scrolling it on one line."] = "輸入框會將長訊息折行為多行，隨訊息向下增長，而不是讓訊息在單行內捲動。",
    ["Timestamp Format"] = "時間戳格式",
    ["Bracket Style"] = "括號樣式",
    ["Colors"] = "顏色",
    ["Sound"] = "音效",

    -- Chat type options --
    ["Record"] = "記錄",

    -- Help, bug reports & links --
    ["Found a bug?"] = "發現錯誤？",
    ["Report a Bug"] = "回報錯誤",
    ["Reports are welcome! Click below and follow the instructions in the bug report template."] = "歡迎回報！點擊下方並依照錯誤回報範本中的說明操作。",
    ["Show GitHub Link"] = "顯示 GitHub 連結", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Click to show the link for copying."] = "點擊顯示可複製的連結。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Press Ctrl+C to copy the link, then open it in your browser."] = "按 Ctrl+C 複製連結，然後在瀏覽器中開啟。",

    -- Debugging & development slash commands --
    ["Clear the captured debug log."] = "清除已擷取的除錯日誌。",
    ["Set debugging level: /wim debug [0||1||2]. 2 adds verbose chat event tracing."] = "設定除錯等級：/wim debug [0||1||2]。2 會加入詳細的聊天事件追蹤。",
    ["Snapshot the next modern context menu while it is open."] = "在下一個現代右鍵選單開啟時為其擷取快照。",
    ["Snapshot UI widget state for skin development: /wim snap all | <Frame.Dot.Path> (bare /wim snap lists the arguments)."] = "擷取介面元件狀態供外觀開發使用：/wim snap all | <Frame.Dot.Path>（直接輸入 /wim snap 會列出參數）。",

    -- Tutorials & notices --
    ["WIM is currently running. To access WIM's wide array of options type:"] = "WIM 正在執行中。若要存取 WIM 的完整選項，請輸入：",
    ["WIM's message window has been hidden to WIM's Minimap Icon. If you want to end a conversation, you may do so by <Shift-Clicking> the close button."] = "訊息視窗已隱藏至 WIM 的小地圖圖示。若要結束對話，可以<Shift+點擊>關閉按鈕。",
    ["If you want all windows to be this size, you can set the default window size within WIM's options."] = "若希望所有視窗都採用此尺寸，可以在 WIM 選項中設定預設視窗尺寸。",
    ["You can <Shift-Click> a tab and drag it out into it's own window."] = "您可以<Shift+點擊>一個分頁並將其拖出，使其成為獨立視窗。",
    ["You received a whisper which was hidden due to your current activity. You can change how whispers behave in WIM's options by typing"] = "您收到一則因目前活動而被隱藏的密語。要變更密語的行為方式，請在 WIM 選項中設定，或輸入",

    -- Community channel maintenance --
    ["Toggle the experimental community channel re-add repair (mutates chat window channels)."] = "開啟實驗性的社群頻道重新加入修復（會更動聊天視窗的頻道）。",
    ["Toggle whether WIM focuses community streams at login."] = "控制 WIM 登入時是否聚焦社群串流。",

    -- Misc --
    ["Older Than"] = "早於", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Users in %s"] = "%s 的玩家",

    -- History Viewer filter modes --
    ["Sent by Me"] = "由我傳送",
    ["Sent by Them"] = "由對方傳送",
    ["Active Days"] = "活躍天數",
    ["Last 1 Day"] = "最近 1 天",
    ["Last 7 Days"] = "最近 7 天",
    ["Last 30 Days"] = "最近 30 天",
    ["Last 90 Days"] = "最近 90 天",


    -- Chrome background names --
    ["None (fully clear)"] = "無（完全透明）",
    ["Transparent"] = "透明",
    ["Rock"] = "岩石",
    ["Marble"] = "大理石",
    ["Dark Marble"] = "暗色大理石",
    ["Bank"] = "銀行",
    ["Guild Vault"] = "公會銀行",
    ["Dark Sandstone"] = "暗色砂岩",
    ["Parchment (Tileable)"] = "羊皮紙（可平鋪）",
    ["Quest Parchment"] = "任務羊皮紙",
    ["Raid Frame"] = "團隊框架",
    ["Destiny"] = "命運",
    ["Stationery (Auction)"] = "信紙（拍賣場）",
    ["Stationery (Illustrated)"] = "信紙（插圖）",
    ["Stationery (Orgrimmar)"] = "信紙（奧格瑪）",
    ["Stationery (Thunder Bluff)"] = "信紙（雷霆崖）",
    ["Stationery (Undercity)"] = "信紙（幽暗城）",
    ["Stationery (Plain)"] = "信紙（素色）",
    ["World Map 1"] = "世界地圖 1",
    ["World Map 2"] = "世界地圖 2",
    ["Achievement Stats"] = "成就統計",
    ["Adventure Map Parchment"] = "冒險地圖羊皮紙",
    ["Collections"] = "收藏品",
    ["Frame: Alliance"] = "邊框：聯盟",
    ["Frame: Horde"] = "邊框：部落",
    ["Frame: Neutral"] = "邊框：中立",
    ["Frame: Marine"] = "邊框：海軍",
    ["Frame: Mechagon"] = "邊框：麥卡貢",
    ["Frame: Kyrian"] = "邊框：琪瑞安",
    ["Frame: Necrolord"] = "邊框：死靈領主",
    ["Frame: Night Fae"] = "邊框：夜妖精",
    ["Frame: Venthyr"] = "邊框：Venthyr",
    ["Frame: Oribos"] = "邊框：奧利波斯",
    ["Frame: Dragonflight"] = "邊框：巨龍崛起",
    ["Frame: The War Within"] = "邊框：地心之戰",
    ["Class Hall"] = "職業大廳",
    ["Class Hall (Internal)"] = "職業大廳（內部）",
    ["Garrison Landing Page"] = "要塞登陸頁",
    ["Garrison Mission"] = "要塞任務",
    ["Ship Mission Parchment"] = "艦船任務羊皮紙",
    ["Garrison UI"] = "要塞介面",
    ["Garrison UI 2"] = "要塞介面 2",
    ["Credits: Classic"] = "製作人員：經典版",
    ["Credits: Burning Crusade"] = "製作人員：燃燒的遠征",
    ["Credits: Wrath"] = "製作人員：巫妖王之怒",
    ["Credits: Cataclysm"] = "製作人員：浩劫與重生",
    ["Credits: Mists of Pandaria"] = "製作人員：潘達利亞的迷霧",
    ["Credits: Warlords"] = "製作人員：德拉諾之霸",
    ["Credits: Legion"] = "製作人員：軍臨天下",
    ["Credits: Battle for Azeroth"] = "製作人員：決戰艾澤拉斯",


    -- Skin & options style notices --


    -- Slash command feedback --
    ["WIM: community chat settings unavailable."] = "WIM：社群聊天設定不可用。",
    ["WIM community stream auto-focus ON. Takes effect at next login."] = "WIM 社群頻道自動聚焦已開啟。下次登入時生效。",
    ["WIM community stream auto-focus OFF - the client may refuse sends to community channels. Takes effect at next login."] = "WIM 社群頻道自動聚焦已關閉 - 用戶端可能拒絕向社群頻道發送訊息。下次登入時生效。",
    ["WIM channel re-add repair ON (experimental). On logins where the community stream is focused late, WIM removes and re-adds community channels to ChatFrame1 about 8s after login. If a re-add fails the channel must be restored from the chat settings UI."] = "WIM 頻道重加修復已開啟（實驗性）。當社群頻道聚焦過晚時，WIM 會在登入約 8 秒後從 ChatFrame1 移除並重新加入社群頻道。如果重新加入失敗，需在聊天設定中還原該頻道。",
    ["WIM: attempting a repair now (see /wim debug output)."] = "WIM：正在嘗試修復（參見 /wim debug 輸出）。",
    ["WIM channel re-add repair OFF. No further attempts this session."] = "WIM 頻道重加修復已關閉。本次工作階段不再嘗試。",
    ["WIM: queued options open canceled."] = "WIM：已取消排入佇列的選項開啟。",

    -- Placeholder: Translated with Google Translate, pending a natural language speaker to verify the translation.
    ["Click to switch between Say, Yell, and Emote."] = "點擊在說話、大喊和表情之間切換。",
    ["Say, Yell, or Emote"] = "說話、大喊或表情",
    ["The message being typed takes the color of the chat type it will send as, like the game's own chat box."] = "正在輸入的訊息會顯示為其傳送頻道的顏色，與遊戲內建聊天框一致。",
    ["Battle.net Whispers"] = "戰網密語",
    ["Filter Editor"] = "過濾器編輯器",
    ["Draws the frame background only around the filter area, so a clear filter area background (None or Transparent) shows the game world behind the editor."] = "僅在過濾區域周圍繪製視窗背景，因此當過濾區域背景為無或透明時，可以看到編輯器後面的遊戲世界。",

    -- Modern options, Edit Mode, and dialogs --
    ["%d chat message(s) could not be recovered after the chat lockdown."] = "聊天鎖定後有 %d 則聊天訊息無法復原。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["%d unsupported User Level filter(s) were removed."] = "已移除 %d 個不支援的玩家等級過濾器。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["/reply Counts Sent Whispers"] = "/reply 計入已送出的密語", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["A thin border along the screen edge signals that windows are hidden."] = "螢幕邊緣的細邊框表示視窗已隱藏。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Above everything, at tooltip level."] = "位於一切之上，提示層級。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Above most interface frames."] = "位於大多數介面框架之上。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Above the background layer."] = "位於背景層之上。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Actions"] = "動作", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Addon Compartment Entry"] = "插件收納列項目", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["All windows hide when combat starts and are restored when it ends."] = "戰鬥開始時隱藏所有視窗，戰鬥結束後恢復。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Also captures emotes."] = "同時擷取表情。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Animates closing windows toward the minimap, and the slide used by combat auto-hide and the show/hide key binding."] = "關閉視窗時朝小地圖播放動畫，並為戰鬥自動隱藏與顯示/隱藏快速鍵提供滑動效果。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Animation"] = "動畫", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Animation Direction"] = "動畫方向", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Appearance"] = "外觀", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Applies the filter list below to captured chat messages. Community chat is not filtered."] = "將下方的過濾器清單套用到擷取的聊天訊息。社群聊天不會被過濾。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Applies to the minimap button, the addon compartment entry, and data broker launchers."] = "適用於小地圖按鈕、插件收納列項目和 Data Broker 啟動器。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Applies to whisper and chat history alike. Pruning runs at login."] = "同時適用於密語與聊天紀錄。清理會在登入時執行。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Apply To"] = "套用至", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Arrow keys keep controlling the game while the input box has focus; hold Alt to move the text cursor instead."] = "輸入框取得焦點時方向鍵仍控制遊戲；按住 Alt 可改為移動文字游標。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["At login WIM focuses your community chat streams so the client accepts sends to their channel numbers. Takes effect at the next login and needs at least one channel type captured."] = "登入時 WIM 會聚焦你的社群聊天串流，讓用戶端接受傳送到其頻道編號的訊息。下次登入生效，且至少需要擷取一種頻道類型。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Auto Focus"] = "自動聚焦", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Backgrounds, input field, and roleplay profile options for the WIM Modern skin."] = "WIM Modern 面板的背景、輸入欄位與角色扮演檔案選項。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Base"] = "基礎", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Battle.net Received"] = "收到的 Battle.net 訊息", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Battle.net Sent"] = "送出的 Battle.net 訊息", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Behind the standard interface."] = "位於標準介面之後。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Blizzard is restricting chat right now. Your message was not sent."] = "Blizzard 目前正在限制聊天。你的訊息未送出。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Bracket Names"] = "名字加括號", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Briefly turns game audio back on so a notification can be heard while all sound is disabled. The Master channel alone cannot get past that setting."] = "在所有聲音停用時短暫重新開啟遊戲音訊，以便聽到通知。僅靠主聲道無法繞過該設定。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["By conversation name."] = "依對話名稱。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Calculate Minimum Size"] = "計算最小尺寸", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Cap Stored Messages"] = "限制儲存的訊息數", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Capture"] = "擷取", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Capture Community Channels"] = "擷取社群頻道", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Capture Custom Channels"] = "擷取自訂頻道", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Capture World Channels"] = "擷取世界頻道", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Capture community channels, set per-channel exceptions, and keep their chat channels working."] = "擷取社群頻道、逐頻道設定例外，並維持其聊天頻道正常運作。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Capture world and custom channels and set per-channel exceptions."] = "擷取世界頻道與自訂頻道，並逐頻道設定例外。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Cascade Direction"] = "階梯排列方向", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Cascade Windows"] = "階梯排列視窗", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Channels"] = "頻道", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Chat Follows Focus Rules"] = "聊天遵循聚焦規則", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Chat Sounds"] = "聊天音效", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Chat Types"] = "聊天類型", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Chat windows join the whisper tab group instead of their own, even while Group Whispers is off."] = "即使「密語分組」已關閉，聊天視窗也會加入密語分頁群組而非自己的群組。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Chat windows opened from WIM's menus normally take focus immediately; with this on they follow the pop-up focus rules instead."] = "從 WIM 選單開啟的聊天視窗通常會立即取得焦點；開啟後改為遵循彈出聚焦規則。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Chat windows share one tabbed window. Does not apply to windows already opened."] = "聊天視窗共用一個分頁視窗。不適用於已開啟的視窗。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Check to use alternate pop-up rules for this situation. Unchecked, the Base rules apply."] = "勾選以在此情境使用另外的彈出規則。未勾選時套用基礎規則。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Choose what WIM captures: whispers, chat types, and channels."] = "選擇 WIM 擷取的內容：密語、聊天類型與頻道。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Clamp to Screen"] = "限制在螢幕內", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Class-Colored Names"] = "職業顏色名字", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Click Hold Limit"] = "點擊按住時限", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Click to Release Focus"] = "點擊釋放焦點", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Clickable Links"] = "可點擊連結", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Clicking the game world releases WIM's keyboard focus so movement keys control your character again. Not while in combat."] = "點擊遊戲世界會釋放 WIM 的鍵盤焦點，讓移動鍵重新控制角色。戰鬥中無效。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Clicks held longer than this are treated as camera turns and keep WIM's focus."] = "按住超過此時間的點擊視為轉動鏡頭，並保留 WIM 的焦點。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Combat Auto-Hide"] = "戰鬥自動隱藏", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Combat hiding only happens inside dungeons, raids, battlegrounds, and arenas."] = "僅在地城、團隊副本、戰場與競技場中執行戰鬥隱藏。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Communities"] = "社群", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Content Background"] = "內容背景", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Continuation lines of wrapped messages are indented."] = "換行訊息的後續行會縮排。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Conversations"] = "對話", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Custom %s Rules"] = "%s 自訂規則", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Custom Channels"] = "自訂頻道", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Custom Rules"] = "自訂規則", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Defaults"] = "預設值", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Delete"] = "刪除", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Delete All History"] = "刪除全部紀錄", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Delete Old Messages"] = "刪除舊訊息", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Distinct Chat Sounds"] = "獨立聊天音效", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Distinct Whisper Sounds"] = "獨立密語音效", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Do not play sounds for this channel, whatever the Notifications page plays."] = "無論通知頁面如何設定，都不為此頻道播放音效。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Do not record history for this channel, whatever History > Recording records."] = "無論「紀錄 > 錄製」如何設定，都不記錄此頻道的紀錄。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Draws the frame background only around the panels, so a clear panel background (None or Transparent) shows the game world behind the viewer."] = "僅在面板周圍繪製框架背景，因此清空的面板背景（無或透明）會顯示檢視器後方的遊戲世界。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Each message is prefixed with the time it arrived."] = "每則訊息前顯示收到的時間。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Edit Mode"] = "編輯模式", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Erases every recorded conversation and the archive for every character on this account, then reloads the interface."] = "清除此帳號所有角色的全部已記錄對話與封存，然後重新載入介面。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Error Messages"] = "錯誤訊息", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Escape Hides Windows"] = "Esc 隱藏視窗", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Every whisper is recorded."] = "記錄每一則密語。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Fade When Inactive"] = "閒置時淡出", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Fades the window frame, header, and buttons; message and input text stay opaque. Modern skins keep their frame art opaque."] = "淡化視窗框架、標題與按鈕；訊息與輸入文字保持不透明。現代面板的框架圖案保持不透明。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Filter Chat"] = "過濾聊天", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Filter Panel Background"] = "過濾面板背景", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Filter Whispers"] = "過濾密語", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Filters run top to bottom; the first match wins. Allow lets a message through, Ignore hides it silently, Block hides it and, with Show Alert, tells you in the chat frame with a link to view it."] = "過濾器由上而下執行，第一個符合的生效。允許會放行訊息，忽略會靜默隱藏，封鎖會隱藏訊息，並在開啟「顯示提醒」時在聊天框中通知你並附上檢視連結。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Focus & Input"] = "聚焦與輸入", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Focus Streams at Login"] = "登入時聚焦社群串流", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Font"] = "字型", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Font Size"] = "字型大小", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Force Blizzard's chat messaging lockdown for testing (on|off, does not persist)."] = "為測試強制啟用 Blizzard 的聊天訊息鎖定（on|off，不儲存）。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Formatting"] = "格式", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Frame Background"] = "框架背景", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Friends & guild"] = "好友與公會", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Friends and Battle.net friends."] = "好友與 Battle.net 好友。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Friends only"] = "僅好友", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Friends, Battle.net friends, and guild members."] = "好友、Battle.net 好友與公會成員。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Friends, Battle.net friends, guild members, and your current party and raid get through; whispers from anyone else are ignored. This drives the two WhisperSelect entries in the filter list below."] = "好友、Battle.net 好友、公會成員以及你目前的隊伍與團隊可以通過；其他人的密語會被忽略。這會控制下方過濾器清單中的兩個 WhisperSelect 項目。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Group Chat Windows"] = "聊天視窗分組", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Group Whispers"] = "密語分組", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Group windows into shared tab strips."] = "將視窗歸入共用的分頁列。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Guild members."] = "公會成員。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Guild only"] = "僅公會", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Hidden-Windows Indicator"] = "隱藏視窗指示器", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Hide During Combat"] = "戰鬥中隱藏", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Hide windows during combat and restore them after."] = "戰鬥中隱藏視窗，戰鬥後恢復。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Hides these messages from the game's chat frame so they appear only in WIM. Per-type and per-channel 'Never Suppress' exceptions on the Conversations pages win. A message is not hidden when no WIM window would show it."] = "在遊戲聊天框中隱藏這些訊息，使其僅顯示於 WIM。「對話」頁面中依類型與依頻道設定的「永不隱藏」例外優先。若沒有任何 WIM 視窗會顯示某則訊息，則不會隱藏它。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Hiding"] = "隱藏", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Hiding waits until you finish typing your message."] = "隱藏會等到你輸入完訊息。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["History Preview Received"] = "紀錄預覽收到的訊息", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["History Preview Sent"] = "紀錄預覽送出的訊息", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Hover Item Tooltips"] = "懸停顯示物品提示", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Hovering an item link in a message shows its tooltip without clicking."] = "將滑鼠懸停在訊息中的物品連結上即可顯示提示，無需點擊。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["How messages are formatted and displayed."] = "訊息的格式與顯示方式。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Ignore Arrow Keys"] = "忽略方向鍵", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["In-Line Whisper Mode"] = "內嵌密語模式", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Includes emotes."] = "包含表情。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Includes raid warnings."] = "包含團隊警告。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Incoming Chat"] = "收到的聊天", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Incoming Whispers"] = "收到的密語", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Incoming whispers always open in WIM while it is enabled; this additionally redirects typing /w and /r in the game's chat box into a WIM window. Not while in combat."] = "啟用 WIM 時收到的密語一律在 WIM 中開啟；此選項還會將遊戲聊天框中輸入的 /w 與 /r 轉到 WIM 視窗。戰鬥中無效。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Indent Wrapped Lines"] = "縮排換行", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Indicator"] = "指示器", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Indicator Thickness"] = "指示器粗細", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Input Field"] = "輸入欄位", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Keep Focus"] = "保持焦點", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Keeps at most this many messages per conversation. Applies to whisper and chat history alike."] = "每個對話最多保留這麼多則訊息。同時適用於密語與聊天紀錄。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Keeps the keyboard focus in the input box after sending a message."] = "送出訊息後鍵盤焦點保持在輸入框中。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Keyboard focus and input behavior."] = "鍵盤焦點與輸入行為。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Known Senders Only"] = "僅限已知傳送者", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Launcher"] = "啟動器", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Launcher Alerts"] = "啟動器提醒", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Level with dialog windows."] = "與對話框視窗同層。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Level with most interface frames."] = "與大多數介面框架同層。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Limit Height"] = "限制高度", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Links & Emoticons"] = "連結與表情符號", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Master switch for this channel type; individual channels are captured with the Capture flag below."] = "此頻道類型的總開關；各頻道以下方的擷取標記進行擷取。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Maximum Lines"] = "最大行數", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Menus & Tooltips"] = "選單與提示", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Message Area Background"] = "訊息區域背景", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Message Format"] = "訊息格式", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Message Windows"] = "訊息視窗", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Message colors."] = "訊息顏色。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Message font, outline, and size."] = "訊息字型、外框與大小。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Message suppression requires the game's Social > Whisper Mode setting to be In-line; without it, suppressed whispers would vanish into a popout chat tab."] = "隱藏訊息需要遊戲的「社交 > 密語模式」設為內嵌；否則被隱藏的密語會消失在彈出的聊天分頁中。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Messages Received"] = "收到的訊息", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Messages Sent"] = "送出的訊息", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Messages per Conversation"] = "每個對話的訊息數", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Minimap Button"] = "小地圖按鈕", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Most recently active conversation first."] = "最近活躍的對話優先。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Multi-Line Input"] = "多行輸入", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Native Input Colors"] = "原生輸入顏色", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Navigation List Background"] = "導覽清單背景", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Never Pop Up"] = "永不彈出", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Never have this window pop-up on my screen. Overrides Windows > Pop-up Rules."] = "永不在螢幕上彈出此視窗。覆蓋「視窗 > 彈出規則」。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Never suppress messages from the default chat frame. Overrides 'Show Only in WIM' under Windows > Pop-up Rules."] = "永不隱藏預設聊天框中的訊息。覆蓋「視窗 > 彈出規則」中的「僅在 WIM 中顯示」。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["New windows that would overlap are offset in the chosen direction. Whisper windows do not cascade while Group Whispers is on, nor chat windows while Group Chat Windows is on. Applies to windows opened after the change."] = "會重疊的新視窗將沿所選方向錯開。「密語分組」開啟時密語視窗不階梯排列，「聊天視窗分組」開啟時聊天視窗不階梯排列。適用於變更後開啟的視窗。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["No one (GM whispers only)"] = "無人（僅 GM 密語）", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Nothing is recorded except game master whispers."] = "除遊戲管理員的密語外不記錄任何內容。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Notifications"] = "通知", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Oldest conversation first."] = "最早的對話優先。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Only While in an Instance"] = "僅在副本中", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Open History Viewer"] = "開啟紀錄檢視器", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Opens a placement window; drag it to where new windows should appear, then close it to save the spot."] = "開啟一個定位視窗；將其拖到新視窗應出現的位置，然後關閉以儲存位置。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Opens the window when a message arrives in this situation."] = "在此情境收到訊息時開啟視窗。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Opens the window when you send a message in this situation."] = "在此情境送出訊息時開啟視窗。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Optional different sounds for whispers from particular senders."] = "可選為特定傳送者的密語設定不同音效。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Optional different sounds per chat type."] = "可選為各聊天類型設定不同音效。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Outline for the message area and input box text."] = "訊息區域與輸入框文字的外框。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Override Muted Audio"] = "忽略靜音", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Placement & Size"] = "位置與大小", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Playback"] = "播放", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Player names take their class color. Applies to new messages."] = "玩家名字使用其職業顏色。適用於新訊息。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays a distinct sound for raid chat instead of the standard incoming sound; raid warnings keep the standard sound. It never mutes."] = "為團隊聊天播放獨立音效而非標準收到音效；團隊警告保持標準音效。不會靜音。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays a distinct sound for this chat type instead of the standard incoming sound; it never mutes. Use a channel's No Sound flag or turn off incoming chat sounds to silence."] = "為此聊天類型播放獨立音效而非標準收到音效；不會靜音。要靜音，請使用頻道的無音效標記或關閉收到聊天音效。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays a sound when a captured chat message arrives. Per-channel No Sound flags on the channel lists mute individual channels."] = "收到擷取的聊天訊息時播放音效。頻道清單中逐頻道的無音效標記可將個別頻道靜音。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays a sound when a whisper arrives."] = "收到密語時播放音效。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays a sound when you send a message in a captured chat type, from WIM or the game's chat box."] = "在已擷取的聊天類型中送出訊息時播放音效，無論來自 WIM 或遊戲聊天框。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays a sound when you send a whisper."] = "送出密語時播放音效。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays notification sounds on the Master channel so they are heard even when sound effects are turned off."] = "在主聲道播放通知音效，即使關閉音效也能聽到。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays this sound instead of the standard incoming whisper sound."] = "播放此音效以取代標準的收到密語音效。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Pop Up on Receive"] = "收到時彈出", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Pop Up on Send"] = "送出時彈出", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Pop-up Rules"] = "彈出規則", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Pressing Escape hides all open WIM windows."] = "按 Esc 隱藏所有已開啟的 WIM 視窗。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Pressing Tab in a whisper window jumps to the next person you whispered. While enabled, forward Tab no longer cycles through window tabs."] = "在密語視窗中按 Tab 跳到下一位密語對象。啟用後，Tab 不再循環切換視窗分頁。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Preview Count"] = "預覽則數", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Preview Recent Messages"] = "預覽最近訊息", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays this sound instead of the standard incoming whisper sound when a Battle.net friend whispers. When several match, Battle.net friend wins over friend and guild member."] = "Battle.net 好友傳來密語時播放此音效而非標準的收到密語音效。多項符合時，Battle.net 好友優先於好友與公會成員。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Privacy & Filtering"] = "隱私與過濾", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Profile Fields"] = "檔案欄位", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Puts the keyboard focus in the input box when a window pops up."] = "視窗彈出時將鍵盤焦點置於輸入框。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Re-adds community channels to your chat frames when the client drops them, once per login after a late stream focus; /wim channelrepair runs it now. Opt-in: this mutates saved chat window configuration."] = "當用戶端遺失社群頻道時將其重新加入聊天框，每次登入在社群串流延遲聚焦後執行一次；/wim channelrepair 可立即執行。可選：這會修改已儲存的聊天視窗設定。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Record From"] = "記錄來源", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Record Whispers"] = "記錄密語", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Recording"] = "錄製", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Recording stops as soon as this is off; the history button stays on open windows until the next reload."] = "關閉後立即停止記錄；紀錄按鈕會保留在已開啟的視窗上直到下次重新載入。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Redirect /w and /r to WIM"] = "將 /w 與 /r 轉到 WIM", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Repair Dropped Channels"] = "修復遺失的頻道", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Reset Position"] = "重設位置", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Retention"] = "保留", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Retention caps, preview, and deletion."] = "保留上限、預覽與刪除。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Right-Click Opens Unread"] = "右鍵開啟未讀訊息", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Runs the whisper filter list below. While off, addon-spam whispers open windows like any other whisper."] = "執行下方的密語過濾器清單。關閉時，插件垃圾密語會像其他密語一樣開啟視窗。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["See-Through Frame"] = "透視框架", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Sender Details"] = "傳送者詳細資料", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Sent Chat"] = "送出的聊天", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Sent Whispers"] = "送出的密語", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Separate Friends Group"] = "好友獨立分組", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Separate Guild Group"] = "公會獨立分組", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Set to In-line"] = "設為內嵌", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Share Tab Group with Whispers"] = "與密語共用分頁群組", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Shortcut Bar"] = "快捷列", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Show Only in WIM"] = "僅在 WIM 中顯示", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Show Roleplay Profiles"] = "顯示角色扮演檔案", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Show Timestamps"] = "顯示時間戳記", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Show WIM Tooltips"] = "顯示 WIM 提示", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Show an unread message badge on the WIM launcher icons."] = "在 WIM 啟動器圖示上顯示未讀訊息標記。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Show an unread message badge on the WIM launcher icons. Off by default for channels."] = "在 WIM 啟動器圖示上顯示未讀訊息標記。頻道預設關閉。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Shows help tooltips on WIM's windows, lists, and the custom rows of these options."] = "在 WIM 的視窗、清單以及這些選項的自訂列上顯示說明提示。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Shows the most recent messages when a window opens. Applies to whisper and chat history alike, and requires Record Whispers."] = "視窗開啟時顯示最近的訊息。同時適用於密語與聊天紀錄，且需要開啟「記錄密語」。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Shows the row of shortcut buttons on message windows. Turning this off takes effect after the next interface reload."] = "在訊息視窗上顯示快捷按鈕列。關閉後在下次重新載入介面時生效。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Shows the sender's class, level, and guild on their window. Sends one /who lookup when the window opens. Applies to windows opened after the change."] = "在傳送者的視窗上顯示其職業、等級與公會。視窗開啟時送出一次 /who 查詢。適用於變更後開啟的視窗。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Situations without custom rules follow these base rules."] = "沒有自訂規則的情境遵循這些基礎規則。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Skin"] = "面板", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Skin default"] = "面板預設", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Skin, fonts, message look, and colors."] = "面板、字型、訊息外觀與顏色。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Sort Menu by Activity"] = "依活躍度排序選單", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Sort Tabs By"] = "分頁排序方式", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Sounds for whispers and chat, and how they are played."] = "密語與聊天的音效及其播放方式。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Sources"] = "來源", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Storage"] = "儲存", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["System Messages & Timestamps"] = "系統訊息與時間戳記", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Tab Groups"] = "分頁群組", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Tab to Next Whisper"] = "Tab 切換到下一則密語", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Text smileys render as icons."] = "文字表情顯示為圖示。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The base rules. Situations without custom rules follow these."] = "基礎規則。沒有自訂規則的情境遵循這些規則。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The button can then be dragged anywhere on the screen."] = "之後可將按鈕拖到螢幕上的任意位置。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The direction windows slide out when they hide. Also used by the show/hide key binding. Only applies while Window Animations is on under Appearance > Skin."] = "視窗隱藏時滑出的方向。顯示/隱藏快速鍵也使用此設定。僅在「外觀 > 面板」中的「視窗動畫」開啟時生效。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The interface layer WIM windows draw on; higher layers cover lower ones."] = "WIM 視窗所在的介面層級；高層級覆蓋低層級。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The message area renders two points larger than the chosen size; the input box and header follow the skin."] = "訊息區域比所選大小大兩點顯示；輸入框與標題遵循面板設定。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The message box at the bottom of each window."] = "每個視窗底部的訊息框。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The message history window."] = "訊息紀錄視窗。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The skin and window chrome."] = "面板與視窗邊框。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The skin picks the font."] = "由面板選擇字型。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The sound to play. The speaker button plays a preview."] = "要播放的音效。喇叭按鈕可試聽。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The whisper and chat windows."] = "密語與聊天視窗。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The window for adding and editing whisper and chat filters."] = "用於新增與編輯密語及聊天過濾器的視窗。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["These settings style WIM's modern-only skins (such as WIM Modern), which are built from the game's own interface art. They are available while a modern-only skin is selected on the Skin page; with a classic skin active they are greyed out."] = "這些設定用於調整 WIM 的純現代面板（如 WIM Modern），它們由遊戲本身的介面圖案構成。僅當面板頁面選擇了純現代面板時可用；使用經典面板時會顯示為灰色。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Timestamps"] = "時間戳記", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Total RP 3 and Mary Sue Protocol profile display on whisper windows."] = "在密語視窗上顯示 Total RP 3 與 Mary Sue Protocol 檔案。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Type %s to confirm."] = "輸入 %s 以確認。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Unlock Minimap Button"] = "解鎖小地圖按鈕", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Use Master Sound Channel"] = "使用主聲道", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["WIM Message Window"] = "WIM 訊息視窗", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["WIM Modern Skin"] = "WIM Modern 面板", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["WIM manages this chat type in its own message windows. Turning a type off stops capture now; its window button stays until the next reload."] = "WIM 在自己的訊息視窗中管理此聊天類型。關閉某類型會立即停止擷取；其視窗按鈕會保留到下次重新載入。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["WIM's launcher menus list the most recently active conversations first."] = "WIM 的啟動器選單優先列出最近活躍的對話。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["WIM: the options UI is not available on this client."] = "WIM：此用戶端不支援選項介面。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Wait While Typing"] = "輸入時等待", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Web Addresses"] = "網址", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Web addresses in messages become clickable links."] = "訊息中的網址變為可點擊的連結。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["What WIM takes over: whispers, and the chat types that get their own windows."] = "WIM 接管的內容：密語，以及擁有獨立視窗的聊天類型。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["What is kept, and for how long."] = "保留哪些內容，保留多久。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["When choosing the /reply target, your most recent sent whisper counts as well as the last one received."] = "選擇 /reply 目標時，最近送出的密語與最近收到的密語同樣計入。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["When windows appear, where they sit, and what has keyboard focus."] = "視窗何時出現、位於何處，以及鍵盤焦點歸屬。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["When windows pop up and when messages leave the chat frame, per situation."] = "依情境設定視窗何時彈出以及訊息何時離開聊天框。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Where new windows appear, their default size and scale, and the placement of the History Viewer and filter editor are set in the game's Edit Mode."] = "新視窗出現的位置、預設大小與縮放，以及紀錄檢視器與過濾器編輯器的位置，都在遊戲的編輯模式中設定。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Which whispers and chat types are recorded."] = "記錄哪些密語與聊天類型。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["While in a battleground."] = "在戰場中時。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["While in a dungeon."] = "在地城中時。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["While in a raid instance."] = "在團隊副本中時。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["While in an arena match."] = "在競技場比賽中時。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["While in combat."] = "戰鬥中時。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["While resting in an inn or city."] = "在旅店或城市中休息時。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Whisper Sounds"] = "密語音效", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Whisper windows opened from WIM's menus normally take focus immediately; with this on they follow the pop-up focus rules instead."] = "從 WIM 選單開啟的密語視窗通常會立即取得焦點；開啟後改為遵循彈出聚焦規則。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Whisper windows share one tabbed window. Does not apply to windows already opened."] = "密語視窗共用一個分頁視窗。不適用於已開啟的視窗。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Whisper windows show roleplay profile fields from Total RP 3 or any Mary Sue Protocol addon, and gain an Open RP Profile button on their shortcut bar that opens the partner's profile in the installed viewer. Requires the WIM Modern skin."] = "密語視窗會顯示來自 Total RP 3 或任何 Mary Sue Protocol 插件的角色扮演檔案欄位，並在快捷列上新增「開啟 RP 檔案」按鈕，在已安裝的檢視器中開啟對方的檔案。需要 WIM Modern 面板。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Whispers Follow Focus Rules"] = "密語遵循聚焦規則", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Whispers from friends group into their own tabbed window."] = "好友的密語歸入獨立的分頁視窗。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Whispers from game masters are always recorded. Battle.net whispers count as friends."] = "遊戲管理員的密語一律記錄。Battle.net 密語視為好友密語。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Whispers from guild members group into their own tabbed window. A friend who is also a guild member goes to the friends group."] = "公會成員的密語歸入獨立的分頁視窗。同時是公會成員的好友歸入好友群組。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Who gets through."] = "誰能通過。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Window Animations"] = "視窗動畫", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Window Layer"] = "視窗層級", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Window Opacity"] = "視窗不透明度", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Window Skin"] = "視窗面板", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Where new windows spawn and how big they are, their layer, cascading, and screen clamping."] = "新視窗出現的位置與大小、層級、階梯排列與螢幕內限制。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Windows"] = "視窗", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Windows Opened from Menus"] = "從選單開啟的視窗", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Windows cannot be dragged past the screen edges."] = "視窗不能拖出螢幕邊緣。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Windows fade to half opacity after two seconds without the mouse over them."] = "滑鼠離開兩秒後視窗淡化至一半不透明度。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["World Channels"] = "世界頻道", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Wraps player names in brackets."] = "將玩家名字放在括號內。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["You are about to permanently delete WIM's message history for every character on this account."] = "你即將永久刪除此帳號所有角色的 WIM 訊息紀錄。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["instant"] = "即時", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["slow"] = "緩慢", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Community chat cannot be recorded, so this is always on for community channels."] = "社群聊天無法記錄，因此社群頻道一律開啟此項。", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Width"] = "寬度", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Height"] = "高度", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["WIM Filter Editor"] = "WIM 過濾器編輯器", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
});

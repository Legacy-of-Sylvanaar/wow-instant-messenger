--[[
    Language Localization: koKR
    Translated by: BlueNyx <bluenyx@gmail.com>
]]

WIM.AddLocale("koKR", {
    ["WIM (WoW Instant Messenger)"] = "WIM (와우 메신저)",
    ["_Description"] = "WIM은 월드 오브 워크래프트에서 채팅을 통한 대화를 보다 익숙한 방식으로 사용할 수 있도록 도와주는 애드온입니다. 이 화면에서는 WIM을 필요에 맞게 설정할 수 있습니다.",

    ["_DemoText"] = "이 창은 데모 창이며 완전한 기능을 제공하지 않습니다. 다른 모든 창이 생성될 위치에 이 창을 배치하세요. 완료되면 이 창을 닫으면 설정이 저장됩니다.",

    ["_DateFormat"] = "%Y/%m/%d",

    ["Yes"] = "예",
    ["No"] = "아니오",
    ["None"] = "없음",
    ["Cancel"] = "취소",
    ["Unknown"] = "알 수 없음",
    ["Click to update..."] = "클릭 - 위치 정보 갱신",
    ["Usage"] = "사용",

    ["state_resting"] = "대도시",
    ["state_combat"] = "전투중",
    ["state_pvp"] = "전장",
    ["state_arena"] = "투기장",
    ["state_party"] = "파티",
    ["state_raid"] = "레이드",
    ["state_other"] = "일반 (기타)",

    ["Options"] = "옵션",

    ["Up"] = "위",
    ["Down"] = "아래",
    ["Left"] = "왼쪽",
    ["Right"] = "오른쪽",
    ["Ignore"] = "무시",
    ["Block"] = "차단",
    ["Enable WIM"] = "WIM 사용",

    ["Enable"] = "켜기",
    ["Disable"] = "끄기",

    ["History"] = "대화기록",
    ["Filters"] = "필터",

	["Window Created"] = "창 생성됨",
	["Last Activity"] = "마지막 활동",
    ["Alphabetical"] = "가나다순",

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

    ["Game Master"] = "GM",

    -- WIM.lua --
    ["Toggle WIM 'On' and 'Off'."] = "WIM을 켜고 끕니다",

    -- Filters.lua --
    ["Whispers Sent by Addons"] = "애드온을 통해 귓속말",
    ["WhisperSelect Part 1"] = "귓속말 대상자 선택 파트 1",
    ["Example Spam Blocker"] = "스팸 차단 예제",
    ["WhisperSelect Part 2"] = "귓속말 대상자 선택 파트 2",
    ["Filter Name"] = "조건 이름",
    ["Filter By"] = "조건 만든이",
    ["Pattern"] = "패턴(반복적 형식)",
    ["User Type"] = "유저 타입",
    ["Level"] = "레벨",
    ["Friends"] = "친구",
    ["Guild Members"] = "길드 멤버",
    ["Party Members"] = "파티 멤버",
    ["Raid Members"] = "공대 멤버",
    ["Cross-Realm"] = "다른 서버",
    ["Everyone"] = "모두",
    ["User must be at least level:"] = "유저의 최소 레벨",
    ["Apply to messages received."] = "메세지 받기 허용",
    ["Apply to messages sent."] = "메세지 보내기 허용",
    ["Apply to:"] = "적용 대상:",
    ["All Classes"] = "전체 클래스",
    ["Action to Perform:"] = "실행할 동작:",
    ["Allow"] = "허용",
    ["Ignore"] = "무시",
    ["Blocked"] = "차단",
    ["Save"] = "저장",
    ["Cancel"] = "취소",
    ["Edit Filter"] = "조건 수정",
    ["Add Filter"] = "조건 추가",

    -- History.lua --
    ["WIM History Button"] = "WIM 대화기록 버튼",
    ["Click to view message history."] = "클릭하면 대화기록을 볼 수 있습니다.",
    ["WIM pruned %d |4message:messages; from your history."] = "WIM이 대화 기록에서 메시지 %d개를 정리했습니다.",
    ["History Viewer"] = "기록 보기",
    ["Filters"] = "필터",
    ["Are you sure you want to delete all history saved for %s on %s?"] = "%s의 %s에 저장된 모든 기록을 삭제하시겠습니까?",
    ["Search resulted in %d |4message:messages;."] = "검색 결과 메시지 %d개가 발견되었습니다.",
    ["No results found!"] = "검색 결과가 없습니다.",
    ["Search"] = "검색",
    ["Show All"] = "전체 보기",
    ["Loading History"] = "기록 불러오는 중",
    ["Chat View"] = "대화 보기",
    ["Text View"] = "텍스트 보기",
    ["BBCode"] = "BBCode",
    ["WIM History Viewer"] = "WIM 기록 보기",
    ["Display history viewer."] = "기록 보기를 표시합니다",

    -- ldb.lua --
    ["No New Messages"] = "새로운 메세지가 없습니다",

    -- Menu.lua --
    ["Whispers"] = "귓속말",
    ["Chat"] = "대화",

    -- Negotiate.lua --
    ["WIM Update Available!"] = "WIM 업데이트가 있습니다",

    -- ShortcutBar.lua --
    ["Player Location"] = "현재 위치",
    ["Unknown"] = "알 수 없음",
    ["Click to update..."] = "클릭 - 위치 정보 갱신",
    ["Invite to Party"] = "파티 초대",
    ["Invite to Guild"] = "길드 초대",
    ["Add Friend"] = "친구 추가",
    ["Ignore Player"] = "플레이어 차단",
    ["Are you sure you want to\nignore %s?"] = "%s을(를) 차단하시겠습니까?",
    ["Right-Click for profile links..."] = "우클릭하여 프로필 링크 보기...",
    ["Profile Links"] = "프로필 링크",
    ["Location"] = "위치",
    ["Game"] = "게임",
    ["Realm"] = "서버",
    ["Character"] = "캐릭터",
	["Copy Name"] = "이름 복사",

    -- Tutorials.lua --
    ["View Updates"] = "업데이트 보기",

    -- WhisperEngine.lua --
    ["Whisper Received!"] = "귓속말 받기",
    ["Recently Sent Messages"] = "최근 보낸 메시지",
    ["Users in %s"] = "%s 내 사용자",

    -- Clear.lua --
    ["This action will reload your user interface."] = "이 작업은 사용자 인터페이스(UI)를 재시작합니다.",
    ["Do you want to continue?"] = "계속 하시겠습니까?",
    ["You are about to restore WIM's filters to it's default settings!"] = "WIM의 필터 설정을 기본값으로 복원하려고 합니다!",
    ["Usage"] = "사용법",
    ["Clear various WIM data."] = "WIM 데이터를 삭제합니다",

    -- SlashHandler.lua --
    ["WIM Slash Commands"] = "WIM /명령어",
    ["Hide or show {all, whisper, chat} windows."] = "{전체, 귓속말, 채팅} 창 숨기기 또는 보이기.",
    ["To see a list of available WIM slash commands type:"] = "사용 가능한 WIM 슬래시 명령어 목록을 보려면 다음을 입력하세요:",
    ["Display available slash commands."] = "사용 가능한 명령어를 표시합니다",
    ["Reload User Interface."] = "유저 인터페이스 재시작",

    -- TabHandler.lua --
    ["Manipulating Tabs"] = "탭 조작",

    -- WindowHandler.lua --
    ["Window Resized!"] = "창 크기가 변경되었습니다!",
    ["Creating Tab Groups"] = "탭 그룹 만들기",
    ["You can group two or many windows together by <Shift-Clicking> a window and dragging it on top of another."] = "Shift 클릭으로 창을 선택한 뒤 다른 창 위로 끌어다 놓으면 여러 창을 하나의 탭 그룹으로 묶을 수 있습니다.",
    ["Resizing Windows"] = "창 크기 조절",
    ["You can resize a window by holding <Shift> and dragging the bottom right corner of the window."] = "<Shift> 키를 누른 상태에서 창의 오른쪽 아래 모서리를 끌어 크기를 조절할 수 있습니다.",
    ["Demo Window"] = "데모 창",
	["<Shift-Click> to close window."] = "Shift 클릭으로 창 닫기",
    ["Message Window Hidden"] = "메시지 창 숨김",
    ["Default"] = "기본값",
    ["%s is Away From Keyboard: %s"] = "%s님이 자리 비움 상태입니다: %s",
    ["%s does not wish to be disturbed: %s"] = "%s님은 현재 방해받고 싶지 않습니다: %s",
    ["Right-Mouse Click!"] = "오른쪽 버튼 클릭!",
    ["There might be useful tools hidden under the message box. Right-Click to see them!"] = "메시지 창 아래에 유용한 도구가 숨겨져 있을 수 있습니다. 오른쪽 클릭으로 확인하세요!",

    -- Options.lua --
    ["Display WIM's options."] = "WIM 옵션을 표시합니다.",
    ["Resetting WIM will clear all of your settings!"] = "WIM을 초기화하면 모든 설정이 삭제됩니다!",
    ["A reset will reload your user interface."] = "초기화하면 사용자 인터페이스가 다시 로드됩니다.",
    ["Reset all options to default."] = "모든 옵션을 기본값으로 초기화합니다.",

    -- CoreOptions --
    ["Created By:"] = "제작자:",
    ["Special Thanks:"] = "특별 감사:",
    ["Enable WIM"] = "WIM 사용",
    ["Credits"] = "제작자 명단",
    ["This is a long message which contains both emoticons and urls 8). WIM's home is www.WIMAddon.com."] = "이것은 이모티콘과 URL이 모두 포함된 긴 메시지입니다 8). WIM의 홈페이지는 www.WIMAddon.com입니다.",
    ["Preview"] = "미리보기",
    ["Window Scale"] = "창 크기 비율",
    ["Set Window Spawn Location"] = "창 생성 위치 설정",
    ["Up"] = "위",
    ["Down"] = "아래",
    ["Left"] = "왼쪽",
    ["Right"] = "오른쪽",
    ["Version"] = "버전",
    ["Font Outline"] = "글꼴 외곽선",
    ["Thin"] = "얇게",
    ["Thick"] = "굵게",
    ["Allow"] = "허용",
    ["Ignore"] = "무시",
    ["Block"] = "차단",
    ["Protected"] = "보호됨",
    ["Action:"] = "동작:",
    ["Occurrences:"] = "발생 조건:",
    ["Delete Filter"] = "필터 삭제",
    ["History"] = "대화 기록",
    ["Messages"] = "메시지",
    ["Record Chat"] = "채팅 기록",
    ["Maintenance"] = "관리하기",
    ["%d |4Week:Weeks;"] = "%d 주",
    ["User Level"] = "플레이어 레벨",
    ["Sounds"] = "사운드",
	["Background"] = BACKGROUND,
	["Low"] = LOW,
	["Medium"] = "보통",
	["High"] = "혼잡",
	["Dialog"] = ENABLE_DIALOG,
	["Tooltip"] = "툴팁",

    -- TabManagement.lua --

	-- Talent Specs --
    ["Hybrid"] = "하이브리드",

    -- Filters.lua --
    ["Show Alert"] = "알림 표시",
    ["WIM has blocked a message from %s."] = "%s 로부터 온 메시지가 차단되었습니다.",
    ["View Blocked Message"] = "차단된 메시지 보기",
    ["Blocked Message"] = "차단된 메시지",

    -- MinimapIcon.lua
    ["Show Unread Messages"] = "읽지 않은 메시지 표시",
    ["Show All Windows"] = "모든 창 표시",
    ["Hide All Windows"] = "모든 창 숨기기",

    --Emoticons.lua
    ["Also"] = "기타",
    ["More"] = "더 보기",
    ["Emoticons"] = "이모티콘",

    --Expose.lua
    ["Your conversations have been hidden in order to clear your screen while in combat. To disable this feature type"] = "전투 중 화면을 깨끗하게 유지하기 위해 대화창이 숨겨졌습니다. 기능을 끄려면 다음을 입력하세요:",
    ["Expose"] = "Expose",

    --ChatEngine.lua
    ["Have WIM monitor this channel."] = "이 채널을 WIM이 관리하도록 설정",
    ["Never Suppress"] = "기본 채팅창에서 메시지를 숨기지 않기",
    ["No History"] = "기록 안 함",
    ["World Chat"] = "월드 채팅",
    ["Custom Chat"] = "사용자 채팅",
    ["Community Chat"] = "커뮤니티 채팅",
    ["Chat"] = "채팅",
    ["No Sound"] = "소리 없음",

    --OffScreenTracker.lua
    ["WIM Window Off Screen"] = "WIM 창이 화면 밖에 있습니다",
    ["Click to reposition."] = "클릭하여 위치 재조정",

    -- Whisper Mode Warnings
    ["Set whispers to In-line"] = "귓속말을 인라인으로 설정",
    ["It is recommended for whispers to be set to in-line in order to handle their behavior properly."] = "귓속말의 동작을 올바르게 처리하려면 인라인 설정을 권장합니다.",

    -- Skins --
    ["Blue"] = "파란색",
    ["Green"] = "초록색",
    ["Red"] = "빨간색",
    ["Yellow"] = "노란색",

    -- Battle.net friend consolidation (History Viewer)
    ["Battle.net Friends"] = "배틀닷넷 친구",
    ["Are you sure you want to delete ALL history saved with %s, across every realm and every character on this account?"] = "모든 서버 및 이 계정의 모든 캐릭터에 걸쳐 %s와(과) 저장된 모든 기록을 삭제하시겠습니까?",

    -- Per-date deletion from the History Viewer filter list
    ["Are you sure you want to delete the %s history with %s across every realm and character on this account?"] = "%s 날짜의 %s와(과)의 기록을 모든 서버 및 이 계정의 모든 캐릭터에서 삭제하시겠습니까?",
    ["Are you sure you want to delete the %s history for %s across every character on %s?"] = "%s 날짜의 %s에 대한 기록을 %s의 모든 캐릭터에서 삭제하시겠습니까?",
    ["Are you sure you want to delete the %s history for %s on %s?"] = "%s 날짜의 %s에 대한 %s에서의 기록을 삭제하시겠습니까?",


    -- Modern options panel --

    -- Modern skin styling --
    ["None (game default)"] = "없음(게임 기본값)",
    ["Draws the window frame background only around the message area, so a clear message area background (None or Transparent) shows the game world behind the window."] = "창 프레임 배경을 메시지 영역 주위에만 그립니다. 따라서 메시지 영역 배경이 투명(없음 또는 반투명)하면 창 뒤에 게임 세계가 보입니다.",

    -- Roleplay profiles (Total RP 3 / Mary Sue Protocol) --
    ["Roleplay Profiles"] = "역할플레이 프로필",
    ["Open RP Profile"] = "RP 프로필 열기",
    ["Whisper windows show the selected fields from the partner's Total RP 3 or Mary Sue Protocol profile. Fields left unselected -- or without profile data -- keep the standard display."] = "귓속말 창에 상대방의 Total RP 3 또는 Mary Sue Protocol 프로필에서 선택한 필드를 표시합니다. 선택하지 않았거나 프로필 데이터가 없는 필드는 기본 표시를 유지합니다.",
    ["First Name"] = "이름",
    ["Last Name"] = "성",
    ["Title"] = "칭호",
    ["Full Title"] = "전체 칭호",
    ["Race"] = "종족",
    ["Class"] = "직업",
    ["Portrait"] = "초상화",
    ["Name & Class Color"] = "이름 및 직업 색상",
    ["The profile's first name, shown as the window's name text."] = "프로필의 이름으로, 창의 이름 텍스트로 표시됩니다.",
    ["The profile's last name, shown as the window's name text."] = "프로필의 성으로, 창의 이름 텍스트로 표시됩니다.",
    ["The short title, shown on the window's details line."] = "짧은 칭호로, 창의 세부 정보 줄에 표시됩니다.",
    ["The long title, shown on the window's details line and portrait tooltip."] = "긴 칭호로, 창의 세부 정보 줄과 초상화 툴팁에 표시됩니다.",
    ["The custom race, replacing the character's race on the details line."] = "사용자 지정 종족으로, 세부 정보 줄에서 캐릭터의 종족을 대체합니다.",
    ["The custom class, replacing the character's class on the details line."] = "사용자 지정 직업으로, 세부 정보 줄에서 캐릭터의 직업을 대체합니다.",
    ["The profile's icon, replacing the class icon."] = "프로필의 아이콘으로, 직업 아이콘을 대체합니다.",
    ["The profile's custom color, applied to the window's name text and to the class on the details line."] = "프로필의 사용자 지정 색상으로, 창의 이름 텍스트와 세부 정보 줄의 직업에 적용됩니다.",
    ["Apply filter to character menus"] = "캐릭터 메뉴에 필터 적용",

    -- History Viewer filters --
    ["No Filter"] = "필터 없음",
    ["Relative Dates"] = "상대 날짜",
    ["%d or more"] = "%d개 이상",
    ["Fewer than %d"] = "%d개 미만",
    ["Results Filtered"] = "결과 필터링됨",
    ["-- Results Filtered --"] = "-- 결과 필터링됨 --",
    ["Results are hidden by the active filter. Click to open the Filters menu."] = "활성 필터 때문에 결과가 숨겨져 있습니다. 클릭하여 필터 메뉴를 엽니다.",
    ["Click to change how history is filtered."] = "클릭하여 기록 필터 방식을 변경합니다.",
    ["Click to open the Filters menu."] = "클릭하여 필터 메뉴를 엽니다.",
    ["Clicking the %s button on the message window will show that user's history in WIM's History Viewer."] = "메시지 창의 %s 버튼을 클릭하면 그 사용자의 기록이 WIM 기록 뷰어에 표시됩니다.",

    -- Message input & formatting --
    ["Caps how far the input field grows; past the limit the message scrolls inside it."] = "입력 필드가 늘어나는 한도를 정합니다. 한도를 넘으면 메시지가 필드 안에서 스크롤됩니다.",
    ["The most lines the input field grows to before the message scrolls inside it."] = "메시지가 필드 안에서 스크롤되기 전까지 입력 필드가 늘어날 수 있는 최대 줄 수입니다.",
    ["The input field wraps long messages onto multiple lines, growing downward with the message instead of scrolling it on one line."] = "입력 필드는 긴 메시지를 여러 줄로 줄바꿈하여 한 줄 스크롤 대신 메시지와 함께 아래로 늘어납니다.",
    ["Timestamp Format"] = "시간 표시 형식",
    ["Bracket Style"] = "괄호 스타일",
    ["Colors"] = "색상",
    ["Sound"] = "소리",

    -- Chat type options --
    ["Record"] = "기록",

    -- Help, bug reports & links --
    ["Found a bug?"] = "버그를 찾으셨나요?",
    ["Report a Bug"] = "버그 신고",
    ["Reports are welcome! Click below and follow the instructions in the bug report template."] = "버그 보고를 환영합니다! 아래를 클릭하여 버그 보고 양식의 지침을 따라 주세요.",
    ["Show GitHub Link"] = "GitHub 링크 표시", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Click to show the link for copying."] = "클릭하면 복사할 링크가 표시됩니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Press Ctrl+C to copy the link, then open it in your browser."] = "Ctrl+C를 눌러 링크를 복사한 뒤 브라우저에서 여세요.",

    -- Debugging & development slash commands --
    ["Clear the captured debug log."] = "캡처된 디버그 로그를 지웁니다.",
    ["Set debugging level: /wim debug [0|1|2]. 2 adds verbose chat event tracing."] = "디버깅 수준을 설정합니다: /wim debug [0|1|2]. 2는 자세한 채팅 이벤트 추적을 추가합니다.",
    ["Snapshot the next modern context menu while it is open."] = "열려 있는 다음 현대식 컨텍스트 메뉴의 스냅샷을 찍습니다.",
    ["Snapshot UI widget state for skin development: /wim snap all | <Frame.Dot.Path> (bare /wim snap lists the arguments)."] = "스킨 개발을 위해 UI 위젯 상태를 기록합니다: /wim snap all | <Frame.Dot.Path> (인수 없이 /wim snap을 입력하면 목록이 표시됩니다).",

    -- Tutorials & notices --
    ["WIM is currently running. To access WIM's wide array of options type:"] = "WIM이 실행 중입니다. WIM의 다양한 옵션에 접근하려면 다음을 입력하세요:",
    ["WIM's message window has been hidden to WIM's Minimap Icon. If you want to end a conversation, you may do so by <Shift-Clicking> the close button."] = "메시지 창이 WIM 미니맵 아이콘으로 숨겨졌습니다. 대화를 끝내려면 닫기 버튼을 <Shift-클릭>하세요.",
    ["If you want all windows to be this size, you can set the default window size within WIM's options."] = "모든 창을 이 크기로 하려면 WIM 옵션에서 기본 창 크기를 설정할 수 있습니다.",
    ["You can <Shift-Click> a tab and drag it out into it's own window."] = "<Shift-클릭>으로 탭을 잡아 끌어 별도의 창으로 분리할 수 있습니다.",
    ["You received a whisper which was hidden due to your current activity. You can change how whispers behave in WIM's options by typing"] = "현재 활동 때문에 숨겨진 귓속말을 받았습니다. WIM 옵션에서 귓속말 동작 방식을 변경하려면 다음을 입력하세요",

    -- Community channel maintenance --
    ["Toggle the experimental community channel re-add repair (mutates chat window channels)."] = "실험적인 커뮤니티 채널 재참여 복구를 켭니다(채팅 창 채널을 변경합니다).",
    ["Toggle whether WIM focuses community streams at login."] = "로그인 시 WIM이 커뮤니티 스트림을 포커스할지 정합니다.",

    -- Misc --
    ["Older Than"] = "다음보다 오래된", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Users in %s"] = "%s의 사용자",

    -- History Viewer filter modes --
    ["Sent by Me"] = "내가 보냄",
    ["Sent by Them"] = "상대가 보냄",
    ["Active Days"] = "활동한 날",
    ["Last 1 Day"] = "지난 1일",
    ["Last 7 Days"] = "지난 7일",
    ["Last 30 Days"] = "지난 30일",
    ["Last 90 Days"] = "지난 90일",


    -- Chrome background names --
    ["None (fully clear)"] = "없음(완전히 투명)",
    ["Transparent"] = "투명",
    ["Rock"] = "바위",
    ["Marble"] = "대리석",
    ["Dark Marble"] = "어두운 대리석",
    ["Bank"] = "은행",
    ["Guild Vault"] = "길드 은행",
    ["Dark Sandstone"] = "어두운 사암",
    ["Parchment (Tileable)"] = "양피지(타일형)",
    ["Quest Parchment"] = "퀘스트 양피지",
    ["Raid Frame"] = "공격대 프레임",
    ["Destiny"] = "운명",
    ["Stationery (Auction)"] = "편지지(경매장)",
    ["Stationery (Illustrated)"] = "편지지(삽화)",
    ["Stationery (Orgrimmar)"] = "편지지(오그리마)",
    ["Stationery (Thunder Bluff)"] = "편지지(썬더 블러프)",
    ["Stationery (Undercity)"] = "편지지(언더시티)",
    ["Stationery (Plain)"] = "편지지(기본)",
    ["World Map 1"] = "세계 지도 1",
    ["World Map 2"] = "세계 지도 2",
    ["Achievement Stats"] = "업적 통계",
    ["Adventure Map Parchment"] = "모험 지도 양피지",
    ["Collections"] = "수집품",
    ["Frame: Alliance"] = "프레임: 얼라이언스",
    ["Frame: Horde"] = "프레임: 호드",
    ["Frame: Neutral"] = "프레임: 중립",
    ["Frame: Marine"] = "프레임: 해군",
    ["Frame: Mechagon"] = "프레임: 메카곤",
    ["Frame: Kyrian"] = "프레임: 크리안",
    ["Frame: Necrolord"] = "프레임: 네크로로드",
    ["Frame: Night Fae"] = "프레임: 밤의 요정",
    ["Frame: Venthyr"] = "프레임: 벤시르",
    ["Frame: Oribos"] = "프레임: 오리보스",
    ["Frame: Dragonflight"] = "프레임: 용군단",
    ["Frame: The War Within"] = "프레임: 내부의 전쟁",
    ["Class Hall"] = "직업 전당",
    ["Class Hall (Internal)"] = "직업 전당(내부)",
    ["Garrison Landing Page"] = "주둔지 상륙 페이지",
    ["Garrison Mission"] = "주둔지 임무",
    ["Ship Mission Parchment"] = "함선 임무 양피지",
    ["Garrison UI"] = "주둔지 UI",
    ["Garrison UI 2"] = "주둔지 UI 2",
    ["Credits: Classic"] = "크레딧: 클래식",
    ["Credits: Burning Crusade"] = "크레딧: 불타는 성전",
    ["Credits: Wrath"] = "크레딧: 리치 왕의 분노",
    ["Credits: Cataclysm"] = "크레딧: 대격변",
    ["Credits: Mists of Pandaria"] = "크레딧: 판다리아의 안개",
    ["Credits: Warlords"] = "크레딧: 드레노어의 전쟁군주",
    ["Credits: Legion"] = "크레딧: 군단",
    ["Credits: Battle for Azeroth"] = "크레딧: 아제로스의 전쟁",


    -- Skin & options style notices --


    -- Slash command feedback --
    ["WIM: community chat settings unavailable."] = "WIM: 커뮤니티 대화 설정을 사용할 수 없습니다.",
    ["WIM community stream auto-focus ON. Takes effect at next login."] = "WIM 커뮤니티 채널 자동 초점 켜짐. 다음 로그인부터 적용됩니다.",
    ["WIM community stream auto-focus OFF - the client may refuse sends to community channels. Takes effect at next login."] = "WIM 커뮤니티 채널 자동 초점 꺼짐 - 클라이언트가 커뮤니티 채널로의 전송을 거부할 수 있습니다. 다음 로그인부터 적용됩니다.",
    ["WIM channel re-add repair ON (experimental). On logins where the community stream is focused late, WIM removes and re-adds community channels to ChatFrame1 about 8s after login. If a re-add fails the channel must be restored from the chat settings UI."] = "WIM 채널 재추가 복구 켜짐 (실험적). 커뮤니티 채널 초점이 늦게 잡히는 로그인에서는 WIM이 로그인 약 8초 후 ChatFrame1에서 커뮤니티 채널을 제거하고 다시 추가합니다. 재추가에 실패하면 대화 설정에서 채널을 복원해야 합니다.",
    ["WIM: attempting a repair now (see /wim debug output)."] = "WIM: 지금 복구를 시도합니다 (/wim debug 출력 참조).",
    ["WIM channel re-add repair OFF. No further attempts this session."] = "WIM 채널 재추가 복구 꺼짐. 이번 세션에서는 더 이상 시도하지 않습니다.",
    ["WIM: queued options open canceled."] = "WIM: 대기 중인 옵션 열기가 취소되었습니다.",

    -- Placeholder: Translated with Google Translate, pending a natural language speaker to verify the translation.
    ["Click to switch between Say, Yell, and Emote."] = "클릭하면 일반 대화, 외치기, 감정표현을 전환합니다.",
    ["Say, Yell, or Emote"] = "일반 대화, 외치기 또는 감정표현",
    ["The message being typed takes the color of the chat type it will send as, like the game's own chat box."] = "입력 중인 메시지가 전송될 대화 유형의 색상으로 표시됩니다. 게임의 대화 입력창과 같습니다.",
    ["Battle.net Whispers"] = "Battle.net 귓속말",
    ["Filter Editor"] = "필터 편집기",
    ["Draws the frame background only around the filter area, so a clear filter area background (None or Transparent) shows the game world behind the editor."] = "창 배경을 필터 영역 주위에만 그립니다. 필터 영역 배경이 없음 또는 투명이면 편집기 뒤로 게임 세계가 보입니다.",

    -- Modern options, Edit Mode, and dialogs --
    ["%d chat message(s) could not be recovered after the chat lockdown."] = "대화 잠금 이후 대화 메시지 %d개를 복구할 수 없었습니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["%d unsupported User Level filter(s) were removed."] = "지원되지 않는 사용자 레벨 필터 %d개가 제거되었습니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["/reply Counts Sent Whispers"] = "/reply에 보낸 귓속말 포함", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["A thin border along the screen edge signals that windows are hidden."] = "화면 가장자리의 얇은 테두리가 창이 숨겨져 있음을 알립니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Above everything, at tooltip level."] = "모든 것 위, 툴팁 수준.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Above most interface frames."] = "대부분의 인터페이스 창 위.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Above the background layer."] = "배경 층 위.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Actions"] = "동작", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Addon Compartment Entry"] = "애드온 서랍 항목", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["All windows hide when combat starts and are restored when it ends."] = "전투가 시작되면 모든 창이 숨겨지고 전투가 끝나면 복원됩니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Also captures emotes."] = "감정 표현도 가져옵니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Animates closing windows toward the minimap, and the slide used by combat auto-hide and the show/hide key binding."] = "창을 닫을 때 미니맵 쪽으로 움직이는 애니메이션과 전투 자동 숨김 및 표시/숨김 단축키에 쓰이는 밀기 효과를 재생합니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Animation"] = "애니메이션", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Animation Direction"] = "애니메이션 방향", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Appearance"] = "외형", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Applies the filter list below to captured chat messages. Community chat is not filtered."] = "아래 필터 목록을 가져온 대화 메시지에 적용합니다. 커뮤니티 대화는 필터링되지 않습니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Applies to the minimap button, the addon compartment entry, and data broker launchers."] = "미니맵 버튼, 애드온 서랍 항목, Data Broker 실행기에 적용됩니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Applies to whisper and chat history alike. Pruning runs at login."] = "귓속말과 대화 기록 모두에 적용됩니다. 정리는 로그인 시 실행됩니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Apply To"] = "적용 대상", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Arrow keys keep controlling the game while the input box has focus; hold Alt to move the text cursor instead."] = "입력 상자에 포커스가 있어도 방향키는 계속 게임을 조작합니다. 대신 텍스트 커서를 옮기려면 Alt를 누른 채 사용하세요.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["At login WIM focuses your community chat streams so the client accepts sends to their channel numbers. Takes effect at the next login and needs at least one channel type captured."] = "로그인 시 WIM이 커뮤니티 대화 스트림에 포커스를 맞춰 클라이언트가 해당 채널 번호로의 전송을 받아들이게 합니다. 다음 로그인부터 적용되며 채널 유형이 하나 이상 가져오기 상태여야 합니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Auto Focus"] = "자동 포커스", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Backgrounds, input field, and roleplay profile options for the WIM Modern skin."] = "WIM Modern 스킨의 배경, 입력창, 롤플레잉 프로필 옵션.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Base"] = "기본", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Battle.net Received"] = "Battle.net 받은 메시지", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Battle.net Sent"] = "Battle.net 보낸 메시지", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Behind the standard interface."] = "기본 인터페이스 뒤.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Blizzard is restricting chat right now. Your message was not sent."] = "현재 Blizzard가 대화를 제한하고 있습니다. 메시지가 전송되지 않았습니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Bracket Names"] = "이름에 괄호 표시", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Briefly turns game audio back on so a notification can be heard while all sound is disabled. The Master channel alone cannot get past that setting."] = "모든 소리가 꺼져 있을 때 알림이 들리도록 게임 오디오를 잠시 다시 켭니다. 마스터 채널만으로는 그 설정을 넘을 수 없습니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["By conversation name."] = "대화 상대 이름순.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Calculate Minimum Size"] = "최소 크기 계산", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Cap Stored Messages"] = "저장 메시지 수 제한", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Capture"] = "가져오기", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Capture Community Channels"] = "커뮤니티 채널 가져오기", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Capture Custom Channels"] = "사용자 채널 가져오기", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Capture World Channels"] = "월드 채널 가져오기", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Capture community channels, set per-channel exceptions, and keep their chat channels working."] = "커뮤니티 채널을 가져오고, 채널별 예외를 설정하며, 해당 대화 채널이 계속 작동하게 합니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Capture world and custom channels and set per-channel exceptions."] = "월드 채널과 사용자 채널을 가져오고 채널별 예외를 설정합니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Cascade Direction"] = "계단식 배치 방향", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Cascade Windows"] = "창 계단식 배치", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Channels"] = "채널", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Chat Follows Focus Rules"] = "대화 창이 포커스 규칙을 따름", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Chat Sounds"] = "대화 소리", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Chat Types"] = "대화 유형", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Chat windows join the whisper tab group instead of their own, even while Group Whispers is off."] = "\"귓속말 묶기\"가 꺼져 있어도 대화 창이 자체 그룹 대신 귓속말 탭 그룹에 합류합니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Chat windows opened from WIM's menus normally take focus immediately; with this on they follow the pop-up focus rules instead."] = "WIM 메뉴에서 연 대화 창은 보통 즉시 포커스를 받습니다. 이 옵션을 켜면 대신 팝업 포커스 규칙을 따릅니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Chat windows share one tabbed window. Does not apply to windows already opened."] = "대화 창이 탭이 있는 하나의 창을 공유합니다. 이미 열린 창에는 적용되지 않습니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Check to use alternate pop-up rules for this situation. Unchecked, the Base rules apply."] = "이 상황에 별도의 팝업 규칙을 쓰려면 선택하세요. 선택하지 않으면 기본 규칙이 적용됩니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Choose what WIM captures: whispers, chat types, and channels."] = "WIM이 가져올 항목을 선택합니다: 귓속말, 대화 유형, 채널.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Clamp to Screen"] = "화면 안에 고정", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Class-Colored Names"] = "직업 색상 이름", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Click Hold Limit"] = "클릭 유지 한도", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Click to Release Focus"] = "클릭으로 포커스 해제", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Clickable Links"] = "클릭 가능한 링크", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Clicking the game world releases WIM's keyboard focus so movement keys control your character again. Not while in combat."] = "게임 월드를 클릭하면 WIM의 키보드 포커스가 해제되어 이동 키가 다시 캐릭터를 조작합니다. 전투 중에는 적용되지 않습니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Clicks held longer than this are treated as camera turns and keep WIM's focus."] = "이보다 오래 누른 클릭은 카메라 회전으로 간주되어 WIM의 포커스를 유지합니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Combat Auto-Hide"] = "전투 중 자동 숨김", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Combat hiding only happens inside dungeons, raids, battlegrounds, and arenas."] = "전투 숨김은 던전, 공격대, 전장, 투기장 안에서만 일어납니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Communities"] = "커뮤니티", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Content Background"] = "내용 배경", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Continuation lines of wrapped messages are indented."] = "줄바꿈된 메시지의 이어지는 줄을 들여씁니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Conversations"] = "대화", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Custom %s Rules"] = "%s 사용자 규칙", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Custom Channels"] = "사용자 채널", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Custom Rules"] = "사용자 규칙", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Defaults"] = "기본값", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Delete"] = "삭제", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Delete All History"] = "모든 기록 삭제", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Delete Old Messages"] = "오래된 메시지 삭제", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Distinct Chat Sounds"] = "대화 유형별 소리", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Distinct Whisper Sounds"] = "귓속말 발신자별 소리", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Do not play sounds for this channel, whatever the Notifications page plays."] = "알림 페이지 설정과 상관없이 이 채널의 소리를 재생하지 않습니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Do not record history for this channel, whatever History > Recording records."] = "기록 > 녹화 설정과 상관없이 이 채널의 기록을 남기지 않습니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Draws the frame background only around the panels, so a clear panel background (None or Transparent) shows the game world behind the viewer."] = "창 배경을 패널 주변에만 그려서, 패널 배경이 비어 있으면(없음 또는 투명) 뷰어 뒤의 게임 월드가 보입니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Each message is prefixed with the time it arrived."] = "각 메시지 앞에 도착 시각을 붙입니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Edit Mode"] = "편집 모드", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Erases every recorded conversation and the archive for every character on this account, then reloads the interface."] = "이 계정의 모든 캐릭터에 대해 기록된 모든 대화와 보관함을 지운 뒤 인터페이스를 다시 불러옵니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Error Messages"] = "오류 메시지", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Escape Hides Windows"] = "Esc로 창 숨기기", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Every whisper is recorded."] = "모든 귓속말을 기록합니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Fade When Inactive"] = "비활성 시 흐리게", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Fades the window frame, header, and buttons; message and input text stay opaque. Modern skins keep their frame art opaque."] = "창 틀, 머리글, 버튼을 흐리게 합니다. 메시지와 입력 텍스트는 불투명하게 유지됩니다. 모던 스킨은 틀 그래픽을 불투명하게 유지합니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Filter Chat"] = "대화 필터링", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Filter Panel Background"] = "필터 패널 배경", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Filter Whispers"] = "귓속말 필터링", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Filters run top to bottom; the first match wins. Allow lets a message through, Ignore hides it silently, Block hides it and, with Show Alert, tells you in the chat frame with a link to view it."] = "필터는 위에서 아래로 실행되며 처음 일치한 필터가 적용됩니다. 허용은 메시지를 통과시키고, 무시는 조용히 숨기며, 차단은 숨긴 뒤 경고 표시가 켜져 있으면 대화창에 확인 링크와 함께 알려 줍니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Focus & Input"] = "포커스 및 입력", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Focus Streams at Login"] = "로그인 시 스트림 포커스", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Font"] = "글꼴", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Font Size"] = "글꼴 크기", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Force Blizzard's chat messaging lockdown for testing (on|off, does not persist)."] = "테스트용으로 Blizzard 대화 메시지 잠금을 강제합니다 (on|off, 저장되지 않음).", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Formatting"] = "서식", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Frame Background"] = "창 배경", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Friends & guild"] = "친구 및 길드", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Friends and Battle.net friends."] = "친구와 Battle.net 친구.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Friends only"] = "친구만", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Friends, Battle.net friends, and guild members."] = "친구, Battle.net 친구, 길드원.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Friends, Battle.net friends, guild members, and your current party and raid get through; whispers from anyone else are ignored. This drives the two WhisperSelect entries in the filter list below."] = "친구, Battle.net 친구, 길드원, 현재 파티와 공격대의 귓속말은 통과하고 그 외 모든 귓속말은 무시됩니다. 아래 필터 목록의 WhisperSelect 항목 두 개를 제어합니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Group Chat Windows"] = "대화 창 묶기", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Group Whispers"] = "귓속말 묶기", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Group windows into shared tab strips."] = "창을 공유 탭 줄로 묶습니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Guild members."] = "길드원.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Guild only"] = "길드만", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Hidden-Windows Indicator"] = "숨겨진 창 표시기", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Hide During Combat"] = "전투 중 숨기기", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Hide windows during combat and restore them after."] = "전투 중 창을 숨기고 전투 후 복원합니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Hides these messages from the game's chat frame so they appear only in WIM. Per-type and per-channel 'Never Suppress' exceptions on the Conversations pages win. A message is not hidden when no WIM window would show it."] = "이 메시지를 게임 채팅창에서 숨겨 WIM에서만 표시되게 합니다. 대화 페이지의 유형별 및 채널별 '절대 숨기지 않음' 예외가 우선합니다. 표시할 WIM 창이 없는 메시지는 숨기지 않습니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Hiding"] = "숨기기", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Hiding waits until you finish typing your message."] = "메시지 입력이 끝날 때까지 숨기기를 기다립니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["History Preview Received"] = "기록 미리보기 받은 메시지", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["History Preview Sent"] = "기록 미리보기 보낸 메시지", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Hover Item Tooltips"] = "마우스 올리면 아이템 툴팁", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Hovering an item link in a message shows its tooltip without clicking."] = "메시지의 아이템 링크에 마우스를 올리면 클릭 없이 툴팁이 표시됩니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["How messages are formatted and displayed."] = "메시지의 서식과 표시 방식.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Ignore Arrow Keys"] = "방향키 무시", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["In-Line Whisper Mode"] = "인라인 귓속말 모드", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Includes emotes."] = "감정 표현 포함.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Includes raid warnings."] = "공격대 경고 포함.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Incoming Chat"] = "받은 대화", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Incoming Whispers"] = "받은 귓속말", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Incoming whispers always open in WIM while it is enabled; this additionally redirects typing /w and /r in the game's chat box into a WIM window. Not while in combat."] = "WIM이 켜져 있으면 받은 귓속말은 항상 WIM에서 열립니다. 이 옵션은 추가로 게임 대화 입력창의 /w 및 /r 입력을 WIM 창으로 돌립니다. 전투 중에는 적용되지 않습니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Indent Wrapped Lines"] = "줄바꿈 줄 들여쓰기", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Indicator"] = "표시기", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Indicator Thickness"] = "표시기 두께", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Input Field"] = "입력창", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Keep Focus"] = "포커스 유지", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Keeps at most this many messages per conversation. Applies to whisper and chat history alike."] = "대화 상대당 최대 이만큼의 메시지를 보관합니다. 귓속말과 대화 기록 모두에 적용됩니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Keeps the keyboard focus in the input box after sending a message."] = "메시지를 보낸 뒤에도 키보드 포커스를 입력 상자에 유지합니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Keyboard focus and input behavior."] = "키보드 포커스와 입력 동작.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Known Senders Only"] = "아는 발신자만", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Launcher"] = "실행기", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Launcher Alerts"] = "실행기 알림", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Level with dialog windows."] = "대화상자 창과 같은 수준.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Level with most interface frames."] = "대부분의 인터페이스 창과 같은 수준.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Limit Height"] = "높이 제한", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Links & Emoticons"] = "링크 및 이모티콘", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Master switch for this channel type; individual channels are captured with the Capture flag below."] = "이 채널 유형의 주 스위치입니다. 개별 채널은 아래의 가져오기 표시로 가져옵니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Maximum Lines"] = "최대 줄 수", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Menus & Tooltips"] = "메뉴 및 툴팁", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Message Area Background"] = "메시지 영역 배경", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Message Format"] = "메시지 형식", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Message Windows"] = "메시지 창", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Message colors."] = "메시지 색상.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Message font, outline, and size."] = "메시지 글꼴, 외곽선, 크기.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Message suppression requires the game's Social > Whisper Mode setting to be In-line; without it, suppressed whispers would vanish into a popout chat tab."] = "메시지 숨김은 게임의 소셜 > 귓속말 모드 설정이 인라인이어야 합니다. 그렇지 않으면 숨겨진 귓속말이 분리된 대화 탭으로 사라집니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Messages Received"] = "받은 메시지", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Messages Sent"] = "보낸 메시지", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Messages per Conversation"] = "대화 상대당 메시지 수", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Minimap Button"] = "미니맵 버튼", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Most recently active conversation first."] = "가장 최근에 활동한 대화부터.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Multi-Line Input"] = "여러 줄 입력", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Native Input Colors"] = "기본 입력 색상", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Navigation List Background"] = "탐색 목록 배경", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Never Pop Up"] = "팝업 안 함", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Never have this window pop-up on my screen. Overrides Windows > Pop-up Rules."] = "이 창을 화면에 절대 띄우지 않습니다. 창 > 팝업 규칙보다 우선합니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Never suppress messages from the default chat frame. Overrides 'Show Only in WIM' under Windows > Pop-up Rules."] = "기본 대화창의 메시지를 절대 숨기지 않습니다. 창 > 팝업 규칙의 'WIM에만 표시'보다 우선합니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["New windows that would overlap are offset in the chosen direction. Whisper windows do not cascade while Group Whispers is on, nor chat windows while Group Chat Windows is on. Applies to windows opened after the change."] = "겹칠 새 창을 선택한 방향으로 어긋나게 배치합니다. \"귓속말 묶기\"가 켜져 있으면 귓속말 창은, \"대화 창 묶기\"가 켜져 있으면 대화 창은 계단식으로 배치되지 않습니다. 변경 후 열린 창에 적용됩니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["No one (GM whispers only)"] = "아무도 안 함 (GM 귓속말만)", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Nothing is recorded except game master whispers."] = "게임 마스터 귓속말 외에는 기록하지 않습니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Notifications"] = "알림", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Oldest conversation first."] = "가장 오래된 대화부터.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Only While in an Instance"] = "인스턴스 안에서만", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Open History Viewer"] = "기록 뷰어 열기", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Opens a placement window; drag it to where new windows should appear, then close it to save the spot."] = "배치 창을 엽니다. 새 창이 나타날 위치로 끌어다 놓은 뒤 닫으면 위치가 저장됩니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Opens the window when a message arrives in this situation."] = "이 상황에서 메시지가 도착하면 창을 엽니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Opens the window when you send a message in this situation."] = "이 상황에서 메시지를 보내면 창을 엽니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Optional different sounds for whispers from particular senders."] = "특정 발신자의 귓속말에 다른 소리를 선택적으로 지정합니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Optional different sounds per chat type."] = "대화 유형별로 다른 소리를 선택적으로 지정합니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Outline for the message area and input box text."] = "메시지 영역과 입력 상자 텍스트의 외곽선.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Override Muted Audio"] = "음소거 무시", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Placement & Size"] = "위치 및 크기", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Playback"] = "재생", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Player names take their class color. Applies to new messages."] = "플레이어 이름에 직업 색상을 적용합니다. 새 메시지에 적용됩니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays a distinct sound for raid chat instead of the standard incoming sound; raid warnings keep the standard sound. It never mutes."] = "공격대 대화에 기본 수신음 대신 별도의 소리를 재생합니다. 공격대 경고는 기본 소리를 유지합니다. 음소거되지 않습니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays a distinct sound for this chat type instead of the standard incoming sound; it never mutes. Use a channel's No Sound flag or turn off incoming chat sounds to silence."] = "이 대화 유형에 기본 수신음 대신 별도의 소리를 재생합니다. 음소거되지 않습니다. 조용히 하려면 채널의 소리 없음 표시를 쓰거나 받은 대화 소리를 끄세요.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays a sound when a captured chat message arrives. Per-channel No Sound flags on the channel lists mute individual channels."] = "가져온 대화 메시지가 도착하면 소리를 재생합니다. 채널 목록의 채널별 소리 없음 표시로 개별 채널을 음소거합니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays a sound when a whisper arrives."] = "귓속말이 도착하면 소리를 재생합니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays a sound when you send a message in a captured chat type, from WIM or the game's chat box."] = "가져오기 대상 대화 유형에서 WIM이나 게임 대화창으로 메시지를 보내면 소리를 재생합니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays a sound when you send a whisper."] = "귓속말을 보내면 소리를 재생합니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays notification sounds on the Master channel so they are heard even when sound effects are turned off."] = "효과음이 꺼져 있어도 들리도록 알림 소리를 마스터 채널로 재생합니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays this sound instead of the standard incoming whisper sound."] = "기본 귓속말 수신음 대신 이 소리를 재생합니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Pop Up on Receive"] = "받을 때 팝업", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Pop Up on Send"] = "보낼 때 팝업", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Pop-up Rules"] = "팝업 규칙", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Pressing Escape hides all open WIM windows."] = "Esc를 누르면 열린 모든 WIM 창이 숨겨집니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Pressing Tab in a whisper window jumps to the next person you whispered. While enabled, forward Tab no longer cycles through window tabs."] = "귓속말 창에서 Tab을 누르면 다음 귓속말 상대로 넘어갑니다. 켜져 있는 동안 Tab은 더 이상 창 탭을 순환하지 않습니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Preview Count"] = "미리보기 개수", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Preview Recent Messages"] = "최근 메시지 미리보기", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Plays this sound instead of the standard incoming whisper sound when a Battle.net friend whispers. When several match, Battle.net friend wins over friend and guild member."] = "Battle.net 친구가 귓속말을 보내면 기본 귓속말 수신음 대신 이 소리를 재생합니다. 여럿이 해당되면 Battle.net 친구가 친구와 길드원보다 우선합니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Privacy & Filtering"] = "개인정보 및 필터링", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Profile Fields"] = "프로필 항목", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Puts the keyboard focus in the input box when a window pops up."] = "창이 뜨면 키보드 포커스를 입력 상자에 둡니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Re-adds community channels to your chat frames when the client drops them, once per login after a late stream focus; /wim channelrepair runs it now. Opt-in: this mutates saved chat window configuration."] = "클라이언트가 커뮤니티 채널을 놓치면 로그인당 한 번, 늦은 스트림 포커스 후 대화창에 다시 추가합니다. /wim channelrepair로 즉시 실행할 수 있습니다. 선택 사항: 저장된 대화창 구성을 변경합니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Record From"] = "기록 대상", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Record Whispers"] = "귓속말 기록", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Recording"] = "기록", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Recording stops as soon as this is off; the history button stays on open windows until the next reload."] = "이 옵션을 끄면 즉시 기록이 중단됩니다. 기록 버튼은 다음 다시 불러오기까지 열린 창에 남아 있습니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Redirect /w and /r to WIM"] = "/w와 /r을 WIM으로 돌리기", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Repair Dropped Channels"] = "놓친 채널 복구", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Reset Position"] = "위치 초기화", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Retention"] = "보관", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Retention caps, preview, and deletion."] = "보관 한도, 미리보기, 삭제.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Right-Click Opens Unread"] = "우클릭으로 안 읽은 메시지 열기", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Runs the whisper filter list below. While off, addon-spam whispers open windows like any other whisper."] = "아래 귓속말 필터 목록을 실행합니다. 꺼져 있으면 애드온 스팸 귓속말도 다른 귓속말처럼 창을 엽니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["See-Through Frame"] = "투명 창 틀", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Sender Details"] = "발신자 정보", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Sent Chat"] = "보낸 대화", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Sent Whispers"] = "보낸 귓속말", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Separate Friends Group"] = "친구 별도 그룹", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Separate Guild Group"] = "길드 별도 그룹", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Set to In-line"] = "인라인으로 설정", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Share Tab Group with Whispers"] = "귓속말과 탭 그룹 공유", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Shortcut Bar"] = "바로 가기 막대", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Show Only in WIM"] = "WIM에만 표시", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Show Roleplay Profiles"] = "롤플레잉 프로필 표시", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Show Timestamps"] = "시간 표시", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Show WIM Tooltips"] = "WIM 툴팁 표시", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Show an unread message badge on the WIM launcher icons."] = "WIM 실행기 아이콘에 안 읽은 메시지 표시를 보여줍니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Show an unread message badge on the WIM launcher icons. Off by default for channels."] = "WIM 실행기 아이콘에 안 읽은 메시지 표시를 보여줍니다. 채널은 기본적으로 꺼져 있습니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Shows help tooltips on WIM's windows, lists, and the custom rows of these options."] = "WIM의 창, 목록, 그리고 이 옵션의 사용자 정의 줄에 도움말 툴팁을 표시합니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Shows the most recent messages when a window opens. Applies to whisper and chat history alike, and requires Record Whispers."] = "창이 열릴 때 최근 메시지를 표시합니다. 귓속말과 대화 기록 모두에 적용되며 \"귓속말 기록\"이 필요합니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Shows the row of shortcut buttons on message windows. Turning this off takes effect after the next interface reload."] = "메시지 창에 바로 가기 버튼 줄을 표시합니다. 끄면 다음 인터페이스 다시 불러오기 후 적용됩니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Shows the sender's class, level, and guild on their window. Sends one /who lookup when the window opens. Applies to windows opened after the change."] = "발신자의 직업, 레벨, 길드를 창에 표시합니다. 창이 열릴 때 /who 조회를 한 번 보냅니다. 변경 후 열린 창에 적용됩니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Situations without custom rules follow these base rules."] = "사용자 규칙이 없는 상황은 이 기본 규칙을 따릅니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Skin"] = "스킨", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Skin default"] = "스킨 기본값", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Skin, fonts, message look, and colors."] = "스킨, 글꼴, 메시지 모양, 색상.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Sort Menu by Activity"] = "메뉴를 활동순으로 정렬", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Sort Tabs By"] = "탭 정렬 기준", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Sounds for whispers and chat, and how they are played."] = "귓속말과 대화의 소리, 그리고 재생 방식.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Sources"] = "출처", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Storage"] = "저장", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["System Messages & Timestamps"] = "시스템 메시지 및 시간", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Tab Groups"] = "탭 그룹", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Tab to Next Whisper"] = "Tab으로 다음 귓속말", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Text smileys render as icons."] = "텍스트 이모티콘을 아이콘으로 표시합니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The base rules. Situations without custom rules follow these."] = "기본 규칙입니다. 사용자 규칙이 없는 상황은 이 규칙을 따릅니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The button can then be dragged anywhere on the screen."] = "그러면 버튼을 화면 어디로든 끌어다 놓을 수 있습니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The direction windows slide out when they hide. Also used by the show/hide key binding. Only applies while Window Animations is on under Appearance > Skin."] = "창이 숨겨질 때 밀려나가는 방향입니다. 표시/숨김 단축키에도 사용됩니다. 외형 > 스킨의 \"창 애니메이션\"이 켜져 있을 때만 적용됩니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The interface layer WIM windows draw on; higher layers cover lower ones."] = "WIM 창이 그려지는 인터페이스 층입니다. 높은 층이 낮은 층을 덮습니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The message area renders two points larger than the chosen size; the input box and header follow the skin."] = "메시지 영역은 선택한 크기보다 2포인트 크게 표시됩니다. 입력 상자와 머리글은 스킨을 따릅니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The message box at the bottom of each window."] = "각 창 하단의 메시지 상자.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The message history window."] = "메시지 기록 창.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The skin and window chrome."] = "스킨과 창 테두리.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The skin picks the font."] = "스킨이 글꼴을 고릅니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The sound to play. The speaker button plays a preview."] = "재생할 소리입니다. 스피커 버튼으로 미리 들을 수 있습니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The whisper and chat windows."] = "귓속말 창과 대화 창.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["The window for adding and editing whisper and chat filters."] = "귓속말 및 대화 필터를 추가하고 편집하는 창.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["These settings style WIM's modern-only skins (such as WIM Modern), which are built from the game's own interface art. They are available while a modern-only skin is selected on the Skin page; with a classic skin active they are greyed out."] = "이 설정은 게임 자체 인터페이스 그래픽으로 만들어진 WIM의 모던 전용 스킨(WIM Modern 등)의 모양을 정합니다. 스킨 페이지에서 모던 전용 스킨을 선택한 동안에만 사용할 수 있으며, 클래식 스킨이 활성화되어 있으면 비활성 표시됩니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Timestamps"] = "시간 표시", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Total RP 3 and Mary Sue Protocol profile display on whisper windows."] = "귓속말 창에 Total RP 3 및 Mary Sue Protocol 프로필을 표시합니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Type %s to confirm."] = "확인하려면 %s을(를) 입력하세요.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Unlock Minimap Button"] = "미니맵 버튼 잠금 해제", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Use Master Sound Channel"] = "마스터 소리 채널 사용", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["WIM Message Window"] = "WIM 메시지 창", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["WIM Modern Skin"] = "WIM Modern 스킨", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["WIM manages this chat type in its own message windows. Turning a type off stops capture now; its window button stays until the next reload."] = "WIM이 이 대화 유형을 자체 메시지 창에서 관리합니다. 유형을 끄면 즉시 가져오기가 중단됩니다. 창 버튼은 다음 다시 불러오기까지 남아 있습니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["WIM's launcher menus list the most recently active conversations first."] = "WIM 실행기 메뉴가 가장 최근에 활동한 대화를 먼저 나열합니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["WIM: the options UI is not available on this client."] = "WIM: 이 클라이언트에서는 옵션 UI를 사용할 수 없습니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Wait While Typing"] = "입력 중에는 대기", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Web Addresses"] = "웹 주소", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Web addresses in messages become clickable links."] = "메시지의 웹 주소가 클릭 가능한 링크가 됩니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["What WIM takes over: whispers, and the chat types that get their own windows."] = "WIM이 맡는 항목: 귓속말과 자체 창을 갖는 대화 유형.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["What is kept, and for how long."] = "무엇을 얼마나 오래 보관할지.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["When choosing the /reply target, your most recent sent whisper counts as well as the last one received."] = "/reply 대상을 고를 때 마지막으로 받은 귓속말뿐 아니라 가장 최근에 보낸 귓속말도 포함합니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["When windows appear, where they sit, and what has keyboard focus."] = "창이 언제 나타나고, 어디에 놓이며, 무엇이 키보드 포커스를 갖는지.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["When windows pop up and when messages leave the chat frame, per situation."] = "상황별로 창이 언제 뜨고 메시지가 언제 대화창에서 사라지는지.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Where new windows appear, their default size and scale, and the placement of the History Viewer and filter editor are set in the game's Edit Mode."] = "새 창이 나타나는 위치, 기본 크기와 배율, 기록 뷰어와 필터 편집기의 위치는 게임의 편집 모드에서 설정합니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Which whispers and chat types are recorded."] = "어떤 귓속말과 대화 유형을 기록할지.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["While in a battleground."] = "전장에 있을 때.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["While in a dungeon."] = "던전에 있을 때.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["While in a raid instance."] = "공격대 인스턴스에 있을 때.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["While in an arena match."] = "투기장 경기 중일 때.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["While in combat."] = "전투 중일 때.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["While resting in an inn or city."] = "여관이나 도시에서 휴식 중일 때.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Whisper Sounds"] = "귓속말 소리", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Whisper windows opened from WIM's menus normally take focus immediately; with this on they follow the pop-up focus rules instead."] = "WIM 메뉴에서 연 귓속말 창은 보통 즉시 포커스를 받습니다. 이 옵션을 켜면 대신 팝업 포커스 규칙을 따릅니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Whisper windows share one tabbed window. Does not apply to windows already opened."] = "귓속말 창이 탭이 있는 하나의 창을 공유합니다. 이미 열린 창에는 적용되지 않습니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Whisper windows show roleplay profile fields from Total RP 3 or any Mary Sue Protocol addon, and gain an Open RP Profile button on their shortcut bar that opens the partner's profile in the installed viewer. Requires the WIM Modern skin."] = "귓속말 창에 Total RP 3 또는 Mary Sue Protocol 애드온의 롤플레잉 프로필 항목을 표시하고, 바로 가기 막대에 상대의 프로필을 설치된 뷰어에서 여는 'RP 프로필 열기' 버튼이 추가됩니다. WIM Modern 스킨이 필요합니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Whispers Follow Focus Rules"] = "귓속말이 포커스 규칙을 따름", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Whispers from friends group into their own tabbed window."] = "친구의 귓속말을 별도의 탭 창으로 묶습니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Whispers from game masters are always recorded. Battle.net whispers count as friends."] = "게임 마스터의 귓속말은 항상 기록됩니다. Battle.net 귓속말은 친구로 취급됩니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Whispers from guild members group into their own tabbed window. A friend who is also a guild member goes to the friends group."] = "길드원의 귓속말을 별도의 탭 창으로 묶습니다. 길드원이기도 한 친구는 친구 그룹으로 갑니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Who gets through."] = "누구를 통과시킬지.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Window Animations"] = "창 애니메이션", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Window Layer"] = "창 층", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Window Opacity"] = "창 불투명도", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Window Skin"] = "창 스킨", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Where new windows spawn and how big they are, their layer, cascading, and screen clamping."] = "새 창이 나타나는 위치와 크기, 층, 계단식 배치, 화면 안 고정.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Windows"] = "창", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Windows Opened from Menus"] = "메뉴에서 연 창", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Windows cannot be dragged past the screen edges."] = "창을 화면 가장자리 밖으로 끌 수 없습니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Windows fade to half opacity after two seconds without the mouse over them."] = "마우스가 2초 동안 창 위에 없으면 창이 절반 불투명도로 흐려집니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["World Channels"] = "월드 채널", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Wraps player names in brackets."] = "플레이어 이름을 괄호로 감쌉니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["You are about to permanently delete WIM's message history for every character on this account."] = "이 계정의 모든 캐릭터에 대한 WIM 메시지 기록을 영구히 삭제하려고 합니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["instant"] = "즉시", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["slow"] = "느림", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Community chat cannot be recorded, so this is always on for community channels."] = "커뮤니티 대화는 기록할 수 없으므로 커뮤니티 채널에서는 항상 켜져 있습니다.", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Width"] = "너비", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["Height"] = "높이", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
    ["WIM Filter Editor"] = "WIM 필터 편집기", -- Google Translate placeholder until native language speaker can confirm locale or suggest corrected translation
});

--imports
local WIM = WIM;
local _G = _G;
local table = table;
local string = string;
local pairs = pairs;
local tonumber = tonumber;
local type = type;
local math = math;

--set namespace
setfenv(1, WIM);

 SocketPool = {};
local recycled = {};

local socketCount = 0;
local socketFrame = _G.CreateFrame("Frame");
socketFrame:RegisterEvent("CHAT_MSG_ADDON");

-- thank you stewarta
local function huff_encode(thestr)
	thestr=thestr:gsub("\001","\001\001");
	thestr=thestr:gsub("%z","\001\255");
	return thestr;
end

local function huff_decode(thestr)
	thestr=thestr:gsub("\001\001","\001");
	thestr=thestr:gsub("\001\255","\000");
	return thestr;
end

local function getNewTable()
    if(#recycled > 0) then
        local tbl = recycled[1];
        table.remove(recycled, 1);
        return tbl;
    else
        return {};
    end
end

local function recycleTable(tbl)
    for k, _ in pairs(tbl) do
        tbl[k] = nil;
    end
    table.insert(recycled, tbl);
end


-- inbound Traffic:
local function getSocket(user, socketIndex)
    -- returns nil if socket doesn't exist
    return SocketPool[user] and SocketPool[user][socketIndex] or nil;
end

local function createNewSocket(user, socketIndex, dataLength)
    SocketPool[user] = SocketPool[user] or getNewTable();
    SocketPool[user][socketIndex] = getNewTable();
    SocketPool[user][socketIndex].data = "";
    SocketPool[user][socketIndex].len = tonumber(dataLength);
    return SocketPool[user][socketIndex];
end

local function ProcessData(channel, from, data)
    local str, err = libs.LibCompress:DecompressHuffman(huff_decode(data));
    if(err) then
        dPrint(err);
        return;
    end
    dPrint(string.sub(str, -25))
    dPrint(string.sub(str, 1, 50))
    local cmd, args = string.match(str, "(%w+):(.*)");
    if(cmd and args) then
        if(cmd == "TEST") then
            local canvas = createCanvas()
            canvas:LoadImage(args);
            --[[if(args == _G.orig) then
                dPrint("EQUAL");
            else
                dPrint("NOT EQUAL");
            end
            dPrint(string.len(_G.orig));
            dPrint(string.len(args));]]
        else
            dPrint("Command Other than TEST received");
        end
    else
        dPrint("Transmission received, invalid WIM data.");
    end
end

local function OnEvent(self, event, ...)
    local addon, data, channel, from = ...;
    -- we are only processing WIM addon messages
    if(addon == "WIM") then
        local cmd, args = string.match(data, "^#HEADER:(%d+):(%d+)");
        if(cmd and args) then
            local socket = createNewSocket(from, tonumber(cmd), tonumber(args));
            return;
        end
        cmd, args = string.match(data, "^#(%d+):(.*)");
        if(cmd and args) then
            local socket = getSocket(from, tonumber(cmd));
            socket.data = socket.data..args;
            dPrint(string.len(socket.data)/socket.len*100 .. "%")
            if(string.len(socket.data) == socket.len) then
                ProcessData(channel, from, socket.data);
                SocketPool[from][tonumber(cmd)] = nil;
                recycleTable(socket);
            end
            return;
        end
        cmd, args = string.match(data, "^!(.*)");
        if(cmd) then
            ProcessData(channel, from, cmd);
            return;
        end
    end
end

socketFrame:SetScript("OnEvent", OnEvent);


-- outbound Traffic:
function SendData(user, cmd, data)
    local msg = libs.LibCompress:CompressHuffman(string.upper(cmd)..":"..data);
    msg = huff_encode(msg);
    --local msg = string.upper(cmd)..":"..data
    local msgCount = math.ceil(string.len(msg)/200);
    if(msgCount == 1) then
        _G.ChatThrottleLib:SendAddonMessage("NORMAL", "WIM", "!"..msg, "WHISPER", user);
    else
        socketCount = socketCount + 1;
        local header = "#HEADER:"..socketCount..":"..string.len(msg);
        local prefix = "#"..socketCount..":";
        _G.ChatThrottleLib:SendAddonMessage("NORMAL", "WIM", header, "WHISPER", user);
        for i=1, msgCount do
            local chunk = string.sub(msg, ((i-1)*200+1), (((i-1)*200)+200));
            _G.ChatThrottleLib:SendAddonMessage("BULK", "WIM", prefix..chunk, "WHISPER", user);
        end
    end
end


function _G.test()
    _G.orig = [[88bff587bff786bff984c0fc84c0ff84bfff84bfff84bfff84c0fe84c0fe85c2fa85c2f985c2f886c2f886c0f787c0f786bff786bef986befb85bcfb88bffd8bc2fe8ac2ff82befc7dbbfb7bbbfb7cbdfd81c2ff82c4ff83c5ff81c3fd7ec1f87fc1fe82c3fd84c4fd85c2fe81bdfc81bdfa85bffd86bffe83bdfc7ebaf888c5fd86c3f981bef381bff287c4fa85c2fa84c0fb83bfff80bbff82bfff83c0fe83c1fd83c1fa83c1f784c1f784c1f784c1f784c1fa84c0fb84c0fd84c0fe84c0fe
87bff687bff886bffb84bffd84c0ff84bfff84bfff84bffe84c0fe84c0fc84c1f984c1f884c1f785c1f785c0f786bff786bff886bef986befd86bdfd88befc8abefb87bbf983bbfb83befd84c0fe84c1fe83c1ff81bffd7fbffc80c2fb85c9fc79bcec7cbef481c1fa87c5fd88c5fe80bcfd7db8f67fb9f687c0fe87c3fd87c4fc83c0f880bdf485c2f888c5fc85c2fb83c0fc82c0fe7fbbfc82bffd83c0fd83c1fb83c1fa83c1f784c1f784c1f784c1f784c1fa84c0fa84c0fc84c0fe84c0fe
86c0f886bffa85bffc84bffe84bfff84bfff84bffe84c0fd84c0fc84c0fa82c0f782c0f682c0f684c0f684c0f786bff787bff987bffb88befe88befe83bcfa80bbf786c0fb86c0fb86c0f889c1f78cc4f789c0f283b9ea83b9e983bce782bee48ec9ed8fcaf58cc5f385beec84bcec87bcf486baf187baef8bbdf387c3fa85c1f982bff782bff787c4fc88c4fd85c1fc83c0fc82bffc80befa82c0fd83c1fc83c1fb83c1fa83c1f884c1f784c1f784c1f884c1fa84c1fa84c0fc84c0fe84c0fe
84c0fa84c0fb84bffd84bffe85bfff84bffe84bffe84c0fc84c1f984c1f781c0f581c0f581c0f582c0f684c0f786bff887bffa88bffd8abfff8abfff7dbbf876bbf484c6fc89c6fb89c2f38bc1ed8fc1e98cb9dd8ab4d590bbd78ebad47aabc2acddf8aee0fb9acceb80b0d57aaad192c0e897c3ef95bfed8eb8e481bcf181bcf383bef785c1fb87c3fe86c2fe84c1fd82c0fb81bff983c1fa83c1fc83c1fc83c1fb83c1fa83c0fa84c0f884c1f884c1f884c1f984c1f984c0fc84c0fe84c0fe
84c0fe84c0fe84c0ff84bfff85bfff85bffe85bffc84c0fa84c1f784c1f782c1f682c1f682c1f682c1f783c1f784c0f986c0fb88bffd8bbeff8bbeff86c2fd80c2f978b7ed88c0f391c5f68bbbe97da7d1779fc396bedfb2d8f3add5ec77a5bcbae8ffbdeeff9ed0e773a5c870a2c7a1d0efa8d4f9a1cbf393bce077b1e180b9ed85bff687c2fd85bffe83bffe83c0fc82c0f981c0f687c6fb83c2fb83c1fc83c1fc83c1fc83c0fc84c0fa84c1fa84c1f984c1f884c1f884c0fb84c0fe84c0fe
81c0fe82c0fe83c0ff84bfff85bfff85bffc85bffb84c0f984c1f784c1f782c2f882c2f882c2f982c2fa83c1f983c0fb84bffb86befb89bcfb89bcfb8ac3fb86c6f67cb9e98fc5f585b7e675a2cf6a93bd9bc1e6c4e8f8b4d7eb96bad87aa3c5bce8ff95c4e58ebfe398caeb94c6e67baacba5d1e8bfe8fcb6dcf891c7f487bfef84bcf184bcf688bffe85bffe83befb82bff982c1f784c3f683c1f983c1fb83c1fc83c1fd83c0fd84c0fd84c0fc84c1f984c1f884c1f784c0fa84c0fe84c0fe
80c1ff81c0ff82c0ff84bffe85bffe86bffc85bffa84c0f984c0f784c1f782c2fa82c3fc82c3fc82c3fc81c1fb83c0fb84bffb86bdf989bbf889bbf787bff184c3ec85c3ec89c2ec77abd86493bf5782ac7299be95b8d099bbd492b3d382a6d097bfe392bde795c4ec9acbef93c4e587b5d4a1cae2bce2f2cff2fdade1fb93c9f185baec81b6ee8cc2ff89c2ff84bffb83bff985c3f981c0f382c1f783c1fa83c1fc83c1fe83c0fe84c0fe84c0fd84c0fa84c1f884c1f684c0fa84c0fe84c0fe
7fc1ff80c1ff82c0ff83bffe85bffe86bffc86bffa85bff984c0f884c1f882c2fc82c3fe81c3fd81c2fd81c1fc82c0fc84bffa86bef889bbf58abbf487bbe788c0e197cff38ac0ea72a6d56192c45987b85681af628ab3759ac182a6d083a7dc7ba4d990beef94c6f58dc1f086bbe395c7e79dcbe9aed7eec7edf8b6e9fe9ed1f58bbfed82b6ea8cc1fb8cc3fe86bffa84bff987c4fb80bef282c1f683c1f983c0fc83c0fe83bffe84bfff84bffe84c0fc84c1f884c1f584c0fa84c0fe84c0fe
7dc2ff7fc2ff81c1fe83bffe85bffd86bffc87bffa86bffa84c0fa84c1fa81c0fd80c1fd7fc1fe7fc1fe80c1fe82c1fc84c0fa87bef78bbef48dbdf38db9e095bedab0dcfd92c1ee77a8df6fa1df72a5e75b8ed04374b44e7dbb6391ce7aa6e775a5ec88c0f985c1fa77b4f272b0e999d4fb9cd2fd99ccf697c8e9a7d8f9a7d8fd98caf588bbec88bbf28cc2fd87bef985bef888c3fb82bff582c1f783c1f983c0fb83c0ff83bfff84bfff84bffe84c0fd84c1f884c1f584c0fa84c0fe84c0fe
7dc3ff7fc2ff81c1fe83c0fd85c0fc86bffc87bffa86bffa84c0fa84c1fa7fc0fc7ec0fd7fc0fe7fc1fe7fc1fe81c1fd84c0fa88bff88dbff490bff3aedaf9bde8f798c6e06396c0568bc05790cb639ddd70a5e76d9fdd6a9ad66d98d7789ee594c1ff86b9fd82bbfd81befb72b0e979b3ea93c7f790bfea6893be73a2c0aadaefadddfc96c7f47caee18bbff889bff887bef788c0f98bc6fe84c2f883c1f883c0fb83c0ff83bfff84bfff84bffe84c0fd84c1f884c1f384c0f984c0fe84c0fe
7fc2fe80c2fd81c1fc83c0fc84c0fa85bffb85bffc85befd84befd84befd88c4fe83c1fc7ebcfa85c4fe86c4fe88c4fb86bff382b7e892c2ee90bde778a2c56288a66085a0457ab45787be6192cb6599d86f99da6487b9708fc07492c66181ba6a8bc57eace788bdf98abffc7fb6f175aee579a9de759fd1648ebe739dc6afd9f1bfeefeb7e9fb9ecaf488bcef89bdee88bff085c1f387c2fe82c1fd82c1fd83c0fc83c0fc83c0fb84c0fa84c0fa84c0fa84c0f984c0f984c0fc84c0fe84c0fe
80c2fd81c1fc82c1fb83c1fa84c1fa84c0fb85bffd85befe85beff85beff86c0fd84bffc83bffc88c5ff84c0f886c0f689c0f28dc0ef9fcef57ba8cf5981a6486c8e5f809d6395d473a1dc74a2dd6899da628cce5071a053719f5471a349669c48659f6692cc7eb1eb88bbf86ba0dc528ac15d8cc2618abf5681b36c94c295bddcaedbefb8e8fbacd4fc87bbed8bbef08bc1f384c1f582bdff81c0ff81c1fe82c1fd83c1fc83c1fa84c1f884c0f885c0fa85c0fa85c0fb84c0fd84c0fe84c0fe
81c1fb82c1fb83c1fa83c1fa84c1fa84c0fb84bffd85befe85beff85beff82bbfb85befc89c2fe89c3fe82bbf486bef390c5f69ed0fca9d8fe638fb64f789e567da07398b98cbcf78ebaf47fa9e3668fca537ab54d6a92506a90546e9659729e4b6495577dae6b98cb77a6dc4f7fb62e60954a73a85c80b5567caf698fbf749ac08eb8d7a8d5f3b0d6fe86baeb8bbef28cc2f785c1fa81bbff81bfff81c1fe81c1fd83c1fc83c1fa83c1f884c0f985c0fa85c0fa85c0fb84c0fc84c0fe84c0fe
84c1fa84c1fa84c1fa84c1fa84c1fa84c0fb84bffd85bffe85beff85beff88bffe8ac0fe8ac0fe89bffb8abff895c7fca1d2ffacdcfea4d1fb5985af6595c280b6e37fb3db8dbcea7ea7cf6786a64e637b4c5a74908e93c7c2c5e9e6e8e9efedb3bac0738590556c7e4d65814c648a334b785464987681ba8a95cf789dca6286af729abe91bddeadd4fb81b5df81b4e584baf087c3fd89c3ff82c1ff81c1fe81c1fd83c1fc83c1fa83c1fa84c0fa85c0fa85c0fa85c0fa84c0fc84c0fe84c0fe
86bffa85bffa84c0fa84c0fa84c1fa84c0fb84bffc84bffc84bffe85befe8fc3fe8cbef987b9f490c1fa93c3f992c0f485b3e36f9bc9527da85681ac5182ad5c90bd8dc0ef91b5e45e7fb0546d987583a4cedff3eef3f6f4f9faf3fcfbf1fcf8e9f6f8a7bbc36f86975b738bbcd5f4b6cdf498acda7a8bbe6273a67ea0c46989af7398bb93bdd9caf2fea7ddfa90c2ec85baed87c4fb87c3f982c1fd81c1fe81c1fd83c1fc83c1fb83c1fa84c0fa84c0fa85c0fa85c0fa84c0fc84c0fe84c0fe
88befa87befa86bffa85bffa84c1fa84c0fa84c0fa84c0fa84c0fb85bffa89bdf58bbcf28ebdf399c7fb90bbf083ade06e98ca537cac325c8a4e7aa75d8ebb6ea2cf8bbde96c8dac7997b49ab0c7c6d2dfe8f7fff1f9fbf3fbfdf3fdfef5fcfdf4fcfec6d0d58b959f6c7785e2edfee6f0fed3ddf2bdc7e1a7b2cd82a2c16583a8688baf83accbc1e6fba8ddf98fc0ea82b6e984c1f787c3f782c1fc81c1fe81c1fd81c1fc82c1fc83c0fb84c0fa84c0fa85c0fa85c0f884c0fb84c0fe84c0fe
8abdfa89bdfa87befa86bffa84c0fa83c0fa83c1f983c1f884c1f884c0f689bdf08fbff194c1f397c1f281a9db759bce6b92c4638bbd4a73a55a87b770a0d07fb2e17dacda5d7a909cb4c5d2e2ecf6fdfef4fdfcf1f9faeef7f9ecf7faeffbfff4fdffcfd4da93969f71737dedeff9f5f6fbf1f6fce9f0f8dce4ed8eacc7647fa46080a7799ec4b7d8f9a9dcfa93c3ee85b8ed83bef583bff481c0fb81c1fd81c1fd81c1fc82c1fc83c0fc83c0fb84c0fa84c0fa84c0f884c0fb84c0fe84c0fe
8cbbfc8abcfc88bdfc86bffc84c0fc83c0fa83c1f883c2f684c2f484c2f290c3f193c1ef8fbae880a9d76d91c06b8ec0799dd093b8ec89b2e679a6d985b5e787b8e9628fc06e849ac0cfdeeef7fefbfdfdf8faf8ecf6fadeeaefd7e8edddf7fee9fdffbfc8d2858896676876e1dfedece9f4f2f6fbf5fefef0fafda2c0d96781a65d7aa57596c2acccf5aadafc9ccafa8ec0f883bdf77eb9f180c0f980c2fc81c1fc81c1fe82c1fe83c1fc83c0fb84c0fa84c1f984c0f884c0fb84c0fe84c0fe
8ebbff8cbbff8abcfe87befd84c0fc83c1f883c2f683c2f384c3ee84c3ee90c3ea5b89af1d486f194069688ab76c8ebd6083b54e73a7527db28ab8ef9fc6f58dacd23e5b7db6c7c8e2eeeeecfbfbdff7f7e4ffff7babcf548cb86096c1a3cdf5c7eaff8e9fbf5d63844e4e6bb9b6cbe1ddece8eff7eafafcecfeffd2efff829cbb5e7aa35b7ba9839fcf8fbde98fbbee8cbbf389c1fa89c1fc81c1fc80c2fc81c1fc81c1fe82c1fe83c1fe83c0fd84c0fb84c1f884c1f884c0fb84c0fe84c0fe
8eb9ff8cbaff8abbfe87bdfe84c0fc83c1f883c2f583c3f183c3ee84c3ea6ea2c54e7c9f406b8f749ac1a3c5ee80a2d05e81b3476ca23d67a073a1db769dcf6786af567095deedf0f1f9f7f2fdfae9fbfbd8eceb5987ab3065903368955c8dc37fa9d67e91bf8388b28c8aad968ea87d75877e848b9fafafdef1f0ddfaff96afc56582a253739c7b97c695c2ed90bdeb8cbdee8bc5f787c0f681c2f980c2fb81c1fc81c1fe82c1fe83c1fe83c0fd84c0fb84c1f884c1f784c0fb84c0fe84c0fe
8bbcfb89bcfb88befc87c1fc83c1f980bff582c1f584c3f484c3f27fbde96fa0c45b86a953799e7591b56b86ac536f9a4564914365964570ac719cd95b7eae4a63857186a1edf8f5f5fceff4faf1eff7fbe6f3f38aa7c356789a47677e647c7a9ab4a6b6bda9c7c7afcbcbb5bab4ae6b6965445b6c58819faed9f3e0fefcb1cdd77996ad4f6c8f5a759eaabfe293abcb87aed28eccfa7fc3f684bffa85befc85befc85befd85bffd85bffe84bffd84c0fb84c0fa84c0f984c0fc84c0fe84c0fe
87bff785bef786c0f886c4fb83c2f97ebdf380bff484c1f687c2f680bbed729fc56288ad55769c596b8b293e63263e652f49743f5d8b517dbc76a0df4c6b983347627c8da1eef8ecf5fce9f5f9eef3f4fbeff6fbb6c3d98494ad727f80969258c9cf86efe792fcf69ef7f9aae9e8c083886b375e753674a98dcdfadefefbc6e6e98aa8b94d68883c5579bfbcd9979aaf829db98ecefd79c5f786bdfb89bbfd89bbfc88bcfc87befd86befd85bffc85c0fb85c0fc85c0fc84c0fd84c0fe84c0fe
84bff781bcf481bef684c2fb87c5fe7fbdf47ebbf181bdf38ac3f890c8fb5d88af466b913e5e843e4e6f2a3e632c446b304b753654825581be81abe94c6c97233a5460718be1efe2f4fbf4f9fdfcf4f7fdd9def19ba6bd8a99b2a2aaaceadba0dcd88ff1e18bf8ec90f7f6a1ffffd1bcc39b6c939e5f9ac1a8e3fed8fbfdc8eaf18dadc34d698e364d76c8c1e19b9ab18197b78ac5fb7dc5f786bdfb89bcfd88bcfc87bdfb87befa85bffa85c0fa85c0fa85c0fc85c0fc84c0fd84c0fe84c0fe
82c0f783c1f982c1fa80c1f97bbcf480bff587c5fb87c1f77ab1e65689be476d9744658d3f5d8426365736476d344a72304b7333517b79a8e08ab7f05f7cb32b376d0f144b5a5d5480786f887a5f7b6b3579652ca99743dacb70fbef8bfef47debe56bf7f271fafa77f9fd80ffff9fddd578aba676a19d89cbc6b0d5f3fdbadbe995bdd86c9cc347789ba9c3da85a0b0729fb77dc7f47fd2fc84c1fd86bcfd85bdfc85bffa84c0f784c0f784c0f784c0f885c0fc86befd85bffd84c0fe84c0fe
80c1f880c0f880c1f980c1f97fc0f882c0f886c2f984bcf37aaee55c8ec5486e983d5e853552792c3a5c3042662a4066314b7246648c6b99ce5884ba5974aa596399494c854c4d4b6a6160877964a3925cbca66bdec972e9d574f1de73fce96ef8e86efbf372fbf977fafb7ffffc99e8e385c3b783ad9c86ad9e8cb0d3dea6c8d686b0cc5e90b93d699096abc5899fb180a6c082c6f27bc7f282bffc84bdfd84befb84c0f883c1f583c1f583c1f684c0f785c0fc86befe85bffe84c0fe84c0fe
81c1f97fc0f880c1f981c2fb82c3fc84c1fa86c0f882b9f178ace45e8fc74c729d3b5d852d4a722937572a3b5e263b5f364f7457739a628ec0325c8f596e7e8e9082a3a39a918c599f8f60b7a062d3b860e4c467f7d566f3d05bf2cf57fddd64ffe36efbef73f9f676faf97bfffb8df3ed7fdfc576c9a167b28a568297a197abb87ea0bc5384ae325f867994ad829baf82aac47ec1eb7dc5ef82befb83bdfd83bffb83c1f882c2f582c2f582c2f583c1f785c0fc86befe85bffe84c0fe84c0fe
83c0fa80c0f980c1fa82c3fd83c4fe85c3fc86c1fa82b9f275a9e25788c0537aa53e618a27456e202f4e243456273b5d3d5477627ba05c84b4254a7b66724cc2b644faf388faec6bf9dc62fad454fad141f0c02ff7c130fac22ffcc63bfcd05dfcd867f8e971f7f374f8f675fef87dfdf06bfacc55eea83ad48a205b565c86858d748aa24978a02a5b80598097789bb080afca77bbe583c8f384bffc83bdfe83bffc83c1f881c2f580c2f581c2f683c1f885bffc86befe85bffe84c0fe84c0fe
85c0fc85c1fd85c2fe84c2fd80bef984c2fb89c6fd85bef672a9e0457ab05d89b34068901c3d642839572737572b3d5e3f53745d729446689650709ea4a584e9ce64d6b953dabb47e3c04be8c242eac12ff1c328eeb828f5bc2cf7c038eec051ecc252f3e06afaef75fdf277f8ee7defdb68ebb849eca237eea23c7875624c483c364a54305c7f3960874e708a97b7d0aad5f584c4f07cc0ed84bcfb85bdff84bffd83c1fa81c1f880c2f881c2f883c0fa85bffe86befe85bffe84c0fe84c0fe
87befc83bbf882bcf983c0fb85c3fe82c0fa80bef880bdf57fbbf179b3e96193bb3b678e1a3f651c2e4c2f3f603041623545663d4e70405d8b5c74a3a5856cde8b30cf7e23e99e33f4ae3df6b432f2b51dfcc31ff6b624fab928fdbc2afcba2bf4bb2df2d046f6df5cfde871fdf18ff4d379eda748ee8e2bf5902fae7e6250251d322935395270556f9634526f7994b39dc1e692caf98bc2f589bcfc88bcfe86befe83c0fd81c1fb80c2fb80c2fb81c1fb84bffe85bdfd84befd84c0fe84c0fe
8abefc85bbf982bbf982bdfb82c0fb7ebef880bff981c1f882c0f67ab8ed669bc342719720476c182d4a2a3a5b2e3d5e37456647547658709f687cabb18975eb8a3ad57524dd8721f1a135f8b030f7b71bfcbf1cf8b725f9b627fab626fab121fbc02defc83bf0d24ef9df67ffef8ff4cd78efa444ee8a21f0871ec1875f7d482e49383830455e4f658a25415f50698b7a9dc594cbfc8cc2f78bbcfd8abcfe88bdfe84bffe81c1fd80c1fd80c1fd81c1fd84c0fe84bdfd84befd84c0fe84c0fe
88befc84bdfb83bdfb82befb80bef97fbef881c0fa83c1fa82bff676b3e96b9cc846729b20456d172b4a24365628395a3443634756756780ac6b81acb28b7bed8f48db7a34d47b1cec9a34f9ae35fab624f8b91ff8b72bf6b42cf6b12af9ad27febe35efc03aefc847f8d45effe589f7c671f4a142f1891fed8216ce8953a461325f4538293a52415274213a5d344c715d81ab91cafb8cc4f98cbcfd8abcff88bdff84bfff81c0ff81c1ff81c0fe82c0fe84bffe84befc84bffd84c0fe84c0fe
7ec0fc7fc1fd81c2fe83c3ff86c4ff86c1fd84bef983baf580b6f27eb5ee7094c842619315336115274b2138582338582439552b405a5f7fa55f7da09d7f70d78246db824adb812cef9a3df9a93ff9ae34f3b32bf7b539f4b238f5b037ffb13efcac3bf1b640f4bf48ffc758ffd282ffc067fd9b43fa8428f3821edf7e37b14e0f693a272d375036405b2c40703449755579a589c5f792ccfc8dbefe89bcff87bdff84bfff83bfff83bfff84bfff85bffe85bffe84bffc84c0fd84c0fe84c0fe
81c1fe81c1fe82c2ff84c2fe85c3fe85c1fd85c0fb84bff983bdf784bcf7577fb1264576051f4e1a3153263e601d3454192e4c223450516f95627da17e5850953504993a04a74a00d67e26f4a53bfdbb3bf6b128edae32f6b53dffb942ffb33dffb43ff2b740f0b73ff5b743fdbd65f8b052fa9138fa7e26f57d21d97b33a8480c6438262c3954344364283e702b45724b75a07fc3f48bcef98bc0fb88bdfd86befe84c0fe83c0fe83c0fe85bffe87befd87bffc85bffa84c0fc84c0fe84c0fe
84c1fe84c1fe84c0fe84c0fe84c0fc84c0fc85c1fc86c1fc86c3fc87c3fc6996c9355e8f0b2f5e153054152e511a3152203553293a573b557d4f678d49515c413a2b473e2f6d3a139e6b3fd0964af9b43bf6b337f6ae21fbb525feb52cfca530ffaa37f5ab39f3a734f6a432fdaa4cf99f3efc822cfd7122fa7223ce7b459947175a382d293c58314864223d67223f63416c9178bbe78bcbf68ac0f787bef985bffa83c0fb83c0fb84c0fc85bffb87befb87befa86bff885bffb84c0fe84c0fe
86c1ff85c0ff85c0fe84bffd83bffc84c0fd84c2fd85c3fe87c5fe88c6ff7eb1e45685b72c58872442670d294d1b3456273c5b2c3d5b2841693e537b374c612c4144304344512d16755135a97a38e29f27f5b43dfab01cf9ae16f9aa1dfca12effa633f6a333f39d2cf59827fb9f3bf7952ef97a24fc6b21fc712bc57a498c431950352f253c5b2e496a1f3d671a395e3664886cb4df89cdf688c2f586c0f583c1f782c1f882c1f984c0f985bff987bef988bef987bef885bffb84c0fe84c0fe
87c0fe86bffe85bffe84bffd83bffd83c0fd82c2fe83c4fe85c6ff85c7ff8ec6fa7aafe25c8dbd45688d153458213b5e2b41612b3c5c1c355e32476f364a6735495a364b5545261e5438277e5720b87e13e8ab45f7af26f4a518f39e1bffa232fea231f59c2ff39627f49320f99c31f38f23f2761ef56a24f97334b8764a7d3c1946302f213a5c2a486f1f3d6915355b2c5d8261add889d2f987c4f485c1f483c2f580c3f780c2f783c0f886bff888bef888bef888bef885bffb84c0fe84c0fe
87befe87befe86befe84bffd83bffd83c0fd81c1fe81c1fe80c3ff7fc4ff84bef589c1f78cc2f488aed54062882d4c6f243c5e21325328416a384c7428518117548c1c598f2b3367272e5f3f35466e482eac8269e0a153eca44cf2a043ff9b33f9972af39029f48e24f99020ff9d2ef08c1de8721be86724eb7238986c615f332b312a3715385a2148672842601c364e2e577460a3cd99d8ff8ac5f584c1f482c2f580c3f780c2f783c1f885c0f888bef88abef888bef885bffb84c0fe84c0fe
86bdfd86bdfd85bdfd83befd83bffd80bffd7fc0fd7ec0fd7cc0fd7cc0fd7fb9f384bef68ec6fa9fc9f15a80a736567b2741642d4163405d872f47701a44760e4a8419568c3a46752f426a353342482412614335b37223db9138f29e47ff923afb902df8892cf98625fb881ffe942bec811cde671ada5d20dd693083645954332f2e2c3c17365c1e406735476b2438572d53765497c691d4ff89c4f885c0f782c1f880c3f980c2f983c0fa85bffa87bef988bef988bef885bffb84c0fe84c0fe
86bdfd85bdfd84bdfd83befd83bffd80bffd7fc0fd7ec0fd7cc0fd7dc1fe84bffa86c0f98ac1f89ac3ed5177a033567c2d4a6d3a51723e5f882440681c39621d3c6625476c3246772e4a742e3e60302745322b477446259d6539c57e48f38b3bf79232f98c32f8872af78521f58d28e47c1cd36419ca581dc95f276a5a6047353e2a304817375e1a3b5f414c69323d57355274538dbe91cbff89c1fb85bffa83c0fb80c1fc80c1fc83c0fd85bffc87befc87befb87bef985bffb84c0fe84c0fe
85bdfd84bdfd83befd83befd82befd80bffd7fc0fe7fc1fe7ec2fe7ec2ff87c2fd88c1fb8ac1f794bde94169922e52793050723e59792f537c20406622375a2936552d3d572641742a4f792d4a7a2d36761e2962492827693d30945639d36d28e78529f48731f8852cf78324f38929e27a1fcc5e18bc4e15b24d18524c5f3c334627314f17375f1636584c516940445a4055765589bc92c6ff8abffd86befd83bffe81c1fe81c1fe83c0fe84bffe86befe86bffc86bffa85bffc84c0fe84c0fe
85befd84befd83befd82befc81befd80bffd80c1fe80c2fe81c3fe81c4fe82bdf989c1fb91c6fa95bfea325a83284d732e4f72365475183c6625476d2941642a39592c3d571d3c69244f75335384414a90283a793f1f204e241a6a30199d3702c66410e77726f87f2bfc8229fb8931e77825c85618ae3d0b9934053f3d53332d44242f4f17355e15315553556f4b4c65495d7f598cc194c8ff8abffe86bdfe84befe81c0fe81c0fe83bffe84bffe84bffe84bffe84bffc84c0fd84c0fe84c0fe
88befc87befc87bffc86bffc85bffe84bffc83c0fa82c1f981c2f881c2f886c3f68dc9fa93ccfa93c0e925547e21456826446529466a2539542d42603749653d4c67374a6a203c63183962193c6622446e2a4a71233d661f345e272f52442d3d4b2b409a5128c96d2ae2813cfc9b54ce7229834a37513043472c422e38532e38532a3959283f63344b6d2a527f365f8b4673a15b90c29cd2ff89c3fb85c0fa85c0fa85c0fc84c0fc84c0fd84c0fe83c0fe83c0ff83c0ff83c0fe84c0fe84c0fe
87befc87befc86bffc85bffc85bffe84bffc83c0fb82c1fa81c2f981c2f883bcf08ac0f490c5f690bbe52b5783214267203b5e1f3b60213350283c5b384a664555714457772f486e29466d27476f2849702b486f29426a283d6633395a55394355323f863d17a2460ab35513d97b33c46b21844a34593644533648323f59323f592d3f5e31486c536b8f3d65943a64924a77a86a9fd494c9fb88c1fa85c0fa85c0fa85c0fc84c0fc84c0fd84c0fe83c0fe83c0ff83c0ff83c0fe84c0fe84c0fe
87bffc86bffc85bffc84bffd84bffe84bffd83c0fc82c1fb81c1f981c2f883bef189c2f48fc6f794c2eb31608c1a3e631535571d3e63304765233b5a2f46673f5678445c82314d773755803959843759823050782c497326406c293c653d3f5d3f3f625b3a3365391f6b3e22895c3b8d643f63525947486d494d72394963394963314564354f746e88ac4c75a63d67964d7bad78aee58ec4fa86c0fa85c0fa84c0fb84c0fc84c0fc84c0fd84c0fe83c0fe83c0fe83c0fe83c0fe84c0fe84c0fe
86bffb85bffb85bffc84bffd84c0fe84c0fe83c0fc83c0fb83c1fa83c1f886c1f58ac5f790c9fa9dccf6396a9613395e0f3154294f74526e8d23416124426734527c3d5d892a4a793b5c8c4366944165913557812e507c2342721b3b6d1e4275234784313e553136412d343f39414b555e62415d83345b98385f9a3f526c40526d334a6a375479829fc45a85b7416c9d5080b383baf48bc2fb86c0fa84c0fb84c0fc84c0fc84c0fc84c0fd84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe
85c0fa85c0fb85c0fc84c0fc84c0fe84c0fe84c0fc83c0fc83c1fb83c1fa8bc0f68ec0f695c4faacd2ff4872a317325c1b335b52739d97b1d434507623426d2d4f7d375989133467294a7a35578437588231527b3455812748761e3d6c223e6d233f712c374d2f32402d303e272b37535b644d65883e60952f54883e5672425875324d6f35577d8cacd36b99ce4e7db05a8cc28ac2ff8cc4ff85c0fc84c0fc84c0fc84c0fc84c0fc84c0fd84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe
84c0fa84c0fb84c0fc84c0fc84c0fe84c0fe84c0fd83c0fd83c0fb83c0fb82bdf582bdf387c2f69fd1fe5289b923527c2f5b8471a2ccafdafb3d6b902b50773c577f526c951e3660273e672c42672d42633d52704c6080374b6c22395e1f3b6a203f78223f6e22416f1d3f6f072b5732557b3d6494375f9622497d2b486635506d29496d2f558089acd585b7ee73a3da74a6df87c1ff89c4ff85c0fc84c0fc84c0fc84c0fc84c0fc84c0fd84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe
84c1fa84c0fb84c0fc84c0fc84c0fe84c0fe84c0fe84bffd84bffd84c0fc86bdf788bdf78dc1f99cc9fa6c9fd4517dac5a86b285b6e4aad4fc5481ac496f995978a1708db926406d1f39631d365c223a5c4d62815e72913d516f1f365a193b6b28477e27467a264478203f730a2b5a204570315889355e922953861e3e612645681f436a2a527f81a6d28fc1f786b7ef81b5ef83befc84c0fb84c0fc84c0fd84c0fd84c0fd84c0fd84c0fc84c0fc84c0fc84c0fc84c0fc84c0fd84c0fe84c0fe
83c1fa83c0fb83c0fc83c0fc84c0fe84c0fe84bffe84bffe85bffd85bffc88bdf98abefb8dc1fc95c3f780b5ec76a5d67caad98ec3f49eccf86b9dcb6995c2789ecb8aaedf294c7e18396912335f1d3c625c789a6e88a7445c7b20395c1f3e69314a792a4578274175233d6f1632601a3b672f517c3c5e8a385d891b3e6521436a1d446e2c57857fa6d48fc4fb8ec1f988bef981bdfc81bdf983bffd83c0fe83c0fe84c0fe84c0fe84c0fc84c0fc84c0fc85c0fc85c0fc84c0fd84c0fe84c0fe
83c1fa83c1fb83c1fc83c0fc84c0fe84c0fe84bffe85bffe85befe85befe86bffc86c0fd87c1fc8cbff48bc7fe8cc2f48cc3f38cc9fc90c6f47fbbea86bced93c3f49ccbff2c599217437b133e71224b786e94b97c9ec14b6b8d2642632d436238486a2a3f6d253b6d253b6b273e6a1c3961374f704b617e4d6785234973264a74254d7b36649585afdf8ac1fb8cc2fb89c0fb82bffd81bdf982c0fd83c1fe83c0fe84c0fe84c0fe84c0fc84c0fc85c0fc85c0fc85c0fc84c0fd84c0fe84c0fe
83c1fa83c1fb83c1fc83c0fc84c0fe84c0fe84bfff85bffe85befe87befe8ac0fe88bffe87bcfb8bbcf48cc7fe89bff285baee81bcf38abff18dc7fb8ec3f694c3f2a7d6ff5384bd5686bf5d8bbf6a95c39ec6ea8eb1d2506e8e1f3c5b1a385a2f43662e48753149793447742d436a0f2d54334f6d56718a6385a237608c375f8a3b66955180b39dc9fa8ac1fd89bef888c0f987c7fe84c2fd83c1fd83c1fe83c0fe84c0fe84c0fe84c0fc84c0fc85c0fc85c0fc85c0fc84c0fd84c0fe84c0fe
83c1fd83c1fd83c0fd83c0fd84c0fe84bffe84bfff85befe86befe87befe87befe86befe85befd86bffa85c1fc84c0f983c0f782c0f782c1f683c3f884c0f987bffa8fc5ff80b6f181b9f282bdf284c2f28dc7f78fc2f05480af234a751e40641a395e2b416c2e416f273c692037620a265036597f678eb189afd42f5d8b3261905282b479ace192c9fe84c0f982bef981bffa80c0fc81c1fe82c1fe83c1fe83c0fd84c0fc84c0fc84c0fc84c0fc84c0fc84c0fd84c0fe84c0fe84c0fe84c0fe
83c1fe83c1fe83c0fe84c0fe84c0fe84bffe85bfff85beff86beff87beff86befe85befe85bffd85bffd84bffc83c0fb83c1fa82c1f981c2f981c2f881bff882bdf986befb8ac0fd89c3fd89c6fd89c8fc87c4f88ec4f65988ba27507e16385e25476d283e68283b67253a661f37620e26512d5177618aaf9cc2e8406f9e4272a26294c787bbf091caff86c1fa84c2fb83c1fc80c0fd81c1ff82c1fe83c1fe83c0fd84c0fc84c0fc85c0fc85c0fc84c0fc84c0fe84c0fe84c0fe84c0fe84c0fe
83c0fe83c0fe83c0fe84c0fe84c0fe84bffe85bfff85bfff85beff86beff85befe85bffe84bffe84bffe84bffc83c0fc83c0fb82c1fa81c1fa81c1f881bff781bcf683bbf788bffc87c0fb87c1fa87c3fa86c0f58cc1f45f8fc1325c8a1a3c63466a902c436e243863263c66223963162d5622436951789c9fc5ea5f8dbe5d8cbe73a4d88cc0f690c9fe88c2fc87c4fe85c4ff83c2ff82c1ff82c1fe83c0fd83c0fd84c0fc84c0fb85c0fb85c0fc84c0fc84c0fe83c0fe83c0fe84c0fe84c0fe
84c0fe84c0fe84c0fe84c0fe84c0ff84bfff85bfff85bfff85bfff85bfff85bfff85bffe84bffe84c0fe84c0fe84c0fc83c0fc83c1fc83c1fc83c1fa83bff782bcf480b8f189bffb87bdf986bcf786bdf686bdf38bc0f36a9ccd4b78a640658f82a9d03f5b85263e69263f68253c6623396218385e3a608490b5d98ab8ea81b0e388b9ee90c4fc8cc3fc85c0fc85c2fd85c2ff84c1ff84c1ff83c1fe83c0fc84c0fc85c0fc85c0fa85c0fb85c0fc84c0fc84c0fe83c0fe83c0fe84c0fe84c0fe
84bffe84bffe84bffe84bffe84bfff84bfff85bfff85bfff85bfff85bfff84bfff84bffe84bffe84c0fe84c0fe84c0fd83c0fd83c0fd83c0fc83c0fb85c2fb86c2fa80bbf58ac5fe87bffd85bcfb85bdf987bef78dc3f97cb1e473a6d680aedca3d4fd4c719e2342701c3a66253f6a283e681131571b416554799da1cffe98c7fa92c3f98cc0f783baf381bcf782befb82befc80bdfc83c0ff83c0fc83c0fc84c0fb85c0fa85c0fa85c0fb85c0fc84c0fc84c0fe83c0fe83c0fe84c0fe84c0fe
86befe86befe85befe85bfff85bfff85bfff84bfff84bffe84bffe84bffe84bffe84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe84bffd84bffd84bffd87c3fd87c5fc81bef787c6fe84c0fe83bdfd84bdfd88bffc8cc2fc84baf282b7ec8bc0f297d0fd517dac264b79153864294671293f6b17365e163c6032587d93c1f296c5f891c2f889bdf583baf384bffb84bffd82befc80bcfa83c0fe83c0fc84c0fb84c0fa85c0fa86bffa85bffa85c0fb84c0fc84c0fe83c0fe83c0fe84c0fe84c0fe
87bdff87bdff86beff85beff85bfff85bfff84bffe84c0fe84c0fe84c0fe83c0fd83c0fd83c0fd84c0fd84c0fd84c0fd84c0fd84bffd85bffe85bffe87c2fd87c4fb81bff884c5fe7fc0fe7fbdfe82bdfe86bdfe89bffc88bff988c0f789c2f78fcefd6092c2325c8b12386426426e2a3e6a1e3b63163a5f193e637dacdd91c1f491c3f88abdf583baf387c1fc85c0fd82befb80bcf983bffc84bffb84c0fa85bffa85bffa86bffa85bffa85c0fa84c0fc84c0fe83c0fe83c0fe84c0fe84c0fe
88bdff88bdff87bdff86beff85beff85befe84bffe83c0fe83c0fe83c0fe83c0fc83c1fb83c0fc84c0fc84c0fc84c0fc85c0fc85bffc85bffd85bffd87c0fb88c1f881bff77fc4fe7bbffd7cbdfe81bdfe85bbfc85bbf98ac0fa89c1f97ebaf08dcffe78aedd4775a2153d671c37612a3964263f661a3a5e0a2c4f6191c289bbed92c5f98cc0f784bbf487c1fb85c0fb83befa80bcf883bffa84bffa85bff985bff987bff987bff985bffa85c0fa84c0fc83c0ff83c0ff83c0fe84c0fe84c0fe
88bdff88bdff88bdff87bdff87beff85befe84bffe83c0fe83c1fe83c1fe83c1fa83c1fa83c0fc84c0fc84c0fc84c0fc85c0fc85bffc87bffc87bffc88bdf589bcf087c0f57fc1f87abef97dbefc83bffe87bafb86b7f38cbcf58bbef57bb7ed8bcefb91c7f36b98c132577e132950283158283a5c1b35540623423868997cade092c4f890c3f984bbf385bdf685bff885c0fa84bff984bff984bff986bff887bff887bff887bff985bffa85c0fa84c0fc83c0ff83c0ff83c0fe84c0fe84c0fe
89bcff88bcff88bdff87bdff87beff85befe84bffe83c0fe83c1fe83c1fe83c1fa83c1fa83c0fa84c0fa84c0fa84c0fa85bffa86bffc87bffc87befc8bbbf28dbbec8cc3f381c2f77cc0f87fc1fb87c2fe8abaf989b5f18fbaf392c0f78cc5f87cbee894c9f28bb7dd688cae293d5f353a5e303e5d283e591f37530f3f6f699acb8bbef18fc2f883baf086bef788c2fb8ac5fd8ac5fd85c0fa86bff886bff887bff887bff887bff886bff986bffa84c0fc83c0ff83c0ff83c0fe84c0fe84c0fe
86befe86befe85befe85befe85bffe84bffe84bffe83c0fe83c0fe83c0fe83c0fc83c0fc83c0fc84c0fc84c0fc84c0fc84bffc85bffd85bffd85bffd87bdf788bdf388c1f682c0f880c0f981c0fc84c1fe87befc87bbf88cbdf78cbff885c1fa81c0f28cc3f192c3ec85afd33b4e6f24335226395d263c621e35590b3055557aa082afd996cdf988beed80bcf585c1f989c4fc8ac3fe84c0f883c1f883c0f884c0f985c0f985bffa85bffb85bffc84c0fd81c1fd81c1fd82c0fd84c0fe84c0fe
84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe83bffc84bffb84bff984bff984bffb82c0fc81c0fe83c0fe84c0fc87bff986bef97ebefb87c4fd86beef90c6f294c4eb6073941d344f1e355d233a6a1f3762122d4a3e59776f99bb94cdf490c5ef7dbdf681c0f786c1fa89c0fe81bef580c2f780c2f981c1fa84c1fa84c0fb85bffd84bffe83c0fd81c2fc80c2fc82c0fd84c0fe84c0fe
84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe84c0fe85c1fe86c2fd87c2fc86c1fb84c0fb82c0fc81c0fe82bffe82befa85bcf786bdf882c2ff89c6ff86beef8bc1ee96c6f0a5b8d9304863213760263c6c3047721a3552233e5c4e789b80b9e29bd0fa84c4fc80bef582bdf688bffd7ebbf27fc1f680c2f981c1fa84c1fa84c0fb85bffd84bffe83c0fd81c2fc80c2fc82c0fd84c0fe84c0fe]];
SendData("Stewstew", "test", _G.orig);
end

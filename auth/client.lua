function onPreFunction(sourceResource, functionName, isAllowedByACL, luaFileName, luaLineNumber, ...)
    if functionName == 'loadstring' then
        -- triggerServerEvent('anticheat.sendPlayerInfo', resourceRoot, localPlayer)
        outputChatBox('Bunu denemesen iyi olur.', 255, 0, 0)
        return 'skip'
    end
    return true
end
addDebugHook('preFunction', onPreFunction, 'loadstring')

local rot = 0
local alpha = 200
local alphaState = "down"
local imgrot = 0
local img = 3
local destroyTimer
local loadingText = ""
local bgb_alpha = 255
local bgb_state = "-"
local sx, sy = guiGetScreenSize()
local playerCharacters = {};
local browser = guiCreateBrowser(0, 60, sx, sy, true, true, false)
guiSetVisible(browser, false)
local theBrowser = guiGetBrowser(browser)

local x1, y1, z1, x1t, y1t, z1t = 657.9853515625, -1898.9970703125, 8.8359375, 748.8056640625, -1822.10546875, 20.8359375
local x2, y2, z2, x2t, y2t, z2t = -1546.3354492188, 1351.4052734375, 230, 1546.3354492188, -1351.4052734375, 230

res = exports.resources

local animation = {}
animation.alpha = {}
animation.step = 1
for i=1, 5 do
	animation.alpha[i] = 0
end

--local RobotoFont = dxCreateFont("html/fonts/Roboto.ttf", 10)
--local RobotoFont2 = dxCreateFont("html/fonts/Roboto.ttf", 14)

--local baslik = dxCreateFont("html/fonts/Roboto-Light.ttf", 40)
--local kucuk = dxCreateFont("html/fonts/Roboto-Light.ttf", 20)
--local characterFont = dxCreateFont("html/fonts/Roboto-Light.ttf", 10)
-- function renderGTAVLoading()
	-- if alphaState == "down" then
		-- alpha = alpha - 2
		-- if alpha <= 100 then
			-- alphaState = "up"
			-- if changeTextTo then
				-- loadingText = changeTextTo
			-- end
		-- end
	-- else
		-- alpha = alpha + 2
		-- if alpha >= 200 then
			-- alphaState = "down"
		-- end
	-- end
	-- dxDrawText(loadingText,0+10,0,sx,sy,tocolor(255,255,255,alpha),1,RobotoFont,"center","center")
	-- if rot > 360 then rot = 0 end
	-- rot = rot + 5
	-- local minusX = dxGetTextWidth(loadingText)
	-- dxDrawImage(sx/2,sy/2,32,32,"img/loading.png",rot)
-- end
addEventHandler("accounts:login:request", getRootElement(),
	function ()
		setElementDimension ( localPlayer, 0 )
		setElementInterior( localPlayer, 0 )
		--setElementPosition( localPlayer, -262, -1143, 24)
		--setCameraMatrix(-262, -1143, 24, -97, -1167, 2)
		setElementPosition( localPlayer, unpack( defaultCharacterSelectionSpawnPosition ) )

		guiSetInputEnabled(true)
		clearChat()
		triggerServerEvent("onJoin", localPlayer)
		--LoginScreen_openLoginScreen()
	end
);

local wLogin, lUsername, tUsername, lPassword, tPassword, chkRememberLogin, bLogin, bRegister--[[, updateTimer]] = nil
local Exclusive = {}
function LoginScreen_openLoginScreen(title)
	--open_log_reg_pannel()
	Exclusive.loginStart()
end
addEvent("beginLogin", true)
addEventHandler("beginLogin", getRootElement(), LoginScreen_openLoginScreen)

local warningBox, warningMessage, warningOk = nil
local errorMain = {
    button = {},
    window = {},
    label = {}
}
function LoginScreen_showWarningMessage( message )
	if (isElement(errorMain.window[1])) then
		destroyElement(errorMain.window[1])
	end

	errorMain.window[1] = guiCreateWindow(538, 376, 432, 172, "Hata Penceresi", false)
    guiWindowSetSizable(errorMain.window[1], false)
    guiWindowSetMovable(errorMain.window[1], false)
    exports.global:centerWindow(errorMain.window[1]);

    errorMain.label[1] = guiCreateLabel(10, 28, 412, 96, message, false, errorMain.window[1])
    guiLabelSetHorizontalAlign(errorMain.label[1], "center", false)
    guiLabelSetVerticalAlign(errorMain.label[1], "center")
    errorMain.button[1] = guiCreateButton(9, 128, 413, 34, "Tamam", false, errorMain.window[1])
    addEventHandler("onClientGUIClick", errorMain.button[1], function() destroyElement(errorMain.window[1]) end )

	guiBringToFront(errorMain.window[1])
end
addEventHandler("accounts:error:window", getRootElement(), LoginScreen_showWarningMessage)

addEvent("accounts:recieveCharacterlist", true)
addEventHandler("accounts:recieveCharacterlist", root,
	function(list)
		localPlayer:setData("account:characters", list)
		playerCharacters = list
	end
)

addEventHandler("accounts:login:attempt", getRootElement(),
	function (statusCode, additionalData, pChars)
		if (statusCode == 0) then
			if (isElement(warningBox)) then
				destroyElement(warningBox)
			end
			local newAccountHash = localPlayer:getData("account:newAccountHash")
			characterList = localPlayer:getData("account:characters") or playerCharacters
			--Characters_showSelection()
			setElementData(localPlayer, "acc", nil)
			setCameraTarget(localPlayer)
			removeEventHandler("onClientRender",root, drawnLogin)
		    --exports.hud:stopBlackWhite();
			triggerEvent("accfix", localPlayer, localPlayer)
			--Exclusive.drawnCharacters(characterList)
			loadCharacterSelector(characterList)
		

		elseif (statusCode > 0) and (statusCode < 5) then
			LoginScreen_showWarningMessage( additionalData )
		elseif (statusCode == 5) then
			LoginScreen_showWarningMessage( additionalData )
		end
	end
)

local function onResourceStart()
	--clearChat()
	setPlayerHudComponentVisible("weapon", false)
	setPlayerHudComponentVisible("ammo", false)
	setPlayerHudComponentVisible("vehicle_name", false)
	setPlayerHudComponentVisible("money", false)
	setPlayerHudComponentVisible("clock", false)
	setPlayerHudComponentVisible("health", false)
	setPlayerHudComponentVisible("armour", false)
	setPlayerHudComponentVisible("breath", true)
	setPlayerHudComponentVisible("area_name", false)
	setPlayerHudComponentVisible("radar", false)
	setPlayerHudComponentVisible("crosshair", true)

	engineSetAsynchronousLoading(true, true)
	setWorldSpecialPropertyEnabled("extraairresistance", false)
	setAmbientSoundEnabled( "gunfire", false )
	setDevelopmentMode( false )
	setPedTargetingMarkerEnabled(false) -- Adams
	guiSetInputMode("no_binds_when_editing")
	triggerServerEvent( "accounts:login:request", getLocalPlayer() )
end
addEventHandler( "onClientResourceStart", getResourceRootElement( ), onResourceStart )

--[[ XML STORAGE ]]--
local oldXmlFileName = "settings.xml"
local migratedSettingsFile = "@migratedsettings.empty"
local xmlFileName = "@settings.xml"
function loadSavedData(parameter, default)
	-- migrate existing settings
	if not fileExists(migratedSettingsFile) then
		if not fileExists(xmlFileName) and fileExists(oldXmlFileName) then
			fileRename(oldXmlFileName, xmlFileName)
		end
		fileClose(fileCreate(migratedSettingsFile))
	end
	local xmlRoot = xmlLoadFile( xmlFileName )
	if (xmlRoot) then
		local xmlNode = xmlFindChild(xmlRoot, parameter, 0)
		if xmlNode then
			return xmlNodeGetValue(xmlNode)
		end
	end
	return default or false
end

function appendSavedData(parameter, value)
	localPlayer:setData(parameter, value, false)
	local xmlFile = xmlLoadFile ( xmlFileName )
	if not (xmlFile) then
		xmlFile = xmlCreateFile( xmlFileName, "login" )
	end

	local xmlNode = xmlFindChild (xmlFile, parameter, 0)
	if not (xmlNode) then
		xmlNode = xmlCreateChild(xmlFile, parameter)
	end
	xmlNodeSetValue ( xmlNode, value )
	xmlSaveFile(xmlFile)
	xmlUnloadFile(xmlFile)
end

local BizNoteFont18 = dxCreateFont ( ":resources/fonts/BizNote.ttf" , 18 )

fontType = {-- (1)font (2)scale offset
	["default"] = {"default", 1},
	["default-bold"] = {"default-bold",1},
	["clear"] = {"clear",1.1},
	["arial"] = {"arial",1},
	["sans"] = {"sans",1.2},
	["pricedown"] = {"pricedown",3},
	["bankgothic"] = {"bankgothic",4},
	["diploma"] = {"diploma",2},
	["beckett"] = {"beckett",2},
	["BizNoteFont18"] = {"BizNoteFont18",1.1},
}

function loadSavedData2(parameter)

	for key, font in pairs(fontType) do
		local value = loadSavedData(parameter, font[1])
		if value then
			return value
		end
	end

	return false
end

--[[ END XML STORAGE ]]--

--[[ START ANIMATION STUFF ]]--
local happyAnims = {
	{ "ON_LOOKERS", "wave_loop"}
}

local idleAnims = {
	{ "PLAYIDLES", "shift"},
	{ "PLAYIDLES", "shldr"},
	{ "PLAYIDLES", "stretch"},
	{ "PLAYIDLES", "strleg"},
	{ "PLAYIDLES", "time"}
}

local danceAnims = {
	{ "DANCING", "dance_loop" },
	{ "STRIP", "strip_D" },
	{ "CASINO", "manwinb" },
	{ "OTB", "wtchrace_win" }
}

local deathAnims = {
	{ "GRAVEYARD", "mrnF_loop" },
	{ "GRAVEYARD", "mrnM_loop" }
}

function getRandomAnim( animType )
	if (animType == 1) then -- happy animations
		return happyAnims[ math.random(1, #happyAnims) ]
	elseif (animType == 2) then -- idle animations
		return idleAnims[ math.random(1, #idleAnims) ]
	elseif (animType == 3) then -- idle animations
		return danceAnims[ math.random(1, #danceAnims) ]
	elseif (animType == 4) then -- death animations
		return deathAnims[ math.random(1, #deathAnims) ]
	end
end

function clearChat()
	local lines = getChatboxLayout()["chat_lines"]
	for i=1,lines do
		outputChatBox("")
	end
end
addCommandHandler("clearchat", clearChat)

function applyClientConfigSettings()

	local borderVeh = tonumber( loadSavedData("borderVeh", "1") )
	localPlayer:setData("borderVeh", borderVeh, false)

	local bgVeh = tonumber( loadSavedData("bgVeh", "1") )
	localPlayer:setData("bgVeh", bgVeh, false)

	local bgPro = tonumber( loadSavedData("bgPro", "1") )
	localPlayer:setData("bgPro", bgPro, false)

	local borderPro = tonumber( loadSavedData("borderPro", "1") )
	localPlayer:setData("borderPro", borderPro, false)

	local enableOverlayDescription = tonumber( loadSavedData("enableOverlayDescription", "1") )
	localPlayer:setData("enableOverlayDescription", enableOverlayDescription or 1, false)

	local enableOverlayDescriptionVeh = tonumber( loadSavedData("enableOverlayDescriptionVeh", "1") )
	localPlayer:setData("enableOverlayDescriptionVeh", enableOverlayDescriptionVeh or 1, false)

	local enableOverlayDescriptionVehPin = tonumber( loadSavedData("enableOverlayDescriptionVehPin", "1") )
	localPlayer:setData("enableOverlayDescriptionVehPin", enableOverlayDescriptionVehPin, false)

	local enableOverlayDescriptionPro = tonumber( loadSavedData("enableOverlayDescriptionPro", "1") )
	localPlayer:setData("enableOverlayDescriptionPro", enableOverlayDescriptionPro or 1, false)

	local enableOverlayDescriptionProPin = tonumber( loadSavedData("enableOverlayDescriptionProPin", "1") )
	localPlayer:setData("enableOverlayDescriptionProPin", enableOverlayDescriptionProPin or 1, false)

	local cFontPro = loadSavedData2("cFontPro")
	localPlayer:setData("cFontPro", cFontPro or "BizNoteFont18", false)

	local cFontVeh = loadSavedData2("cFontVeh")
	localPlayer:setData("cFontVeh", cFontVeh or "default", false)

	local blurEnabled = tonumber( loadSavedData("motionblur", "1") )
	if (blurEnabled == 1) then
		setBlurLevel(38)
	else
		setBlurLevel(0)
	end

	local skyCloudsEnabled = tonumber( loadSavedData("skyclouds", "1") )
	if (skyCloudsEnabled == 1) then
		setCloudsEnabled ( true )
	else
		setCloudsEnabled ( false )
	end

	local streamingMediaEnabled = tonumber(loadSavedData("streamingmedia", "1"))
	if streamingMediaEnabled == 1 then
		localPlayer:setData("streams", 1, true)
	else
		localPlayer:setData("streams", 0, true)
	end

	local phone_anim = tonumber(loadSavedData("phone_anim", "1"))
	if phone_anim == 1 then
		localPlayer:setData("phone_anim", 1, true)
	else
		localPlayer:setData("phone_anim", 0, true)
	end
end

blackMales = {66,311}
whiteMales = {29,30,60,122,124,125,153,236,240,292}
asianMales = {258,294}
blackFemales = {90}
whiteFemales = {41,45,55,56,91,93}
asianFemales = {40,92}

local screenX, screenY = guiGetScreenSize( )
local label = guiCreateLabel( 0, 0, screenX, 15, "holly roleplay ingame v.beta", false )
guiSetSize( label, guiLabelGetTextExtent( label ) + 5, 14, false )
guiSetPosition( label, screenX - guiLabelGetTextExtent( label ) - 5, screenY - 27, false )
guiSetAlpha( label, 0.5 )

addEventHandler('onClientMouseEnter', label, function()
	guiSetAlpha(label, 1)
end, false)

addEventHandler('onClientMouseLeave', label, function()
	guiSetAlpha(label, 0.5)
end, false)

function stopNameChange(oldNick, newNick)
	if (source==getLocalPlayer()) then
		local legitNameChange = getElementData(getLocalPlayer(), "legitnamechange")

		if (oldNick~=newNick) and (legitNameChange==0) then
			triggerServerEvent("resetName", getLocalPlayer(), oldNick, newNick)
			outputChatBox("Karakterinizi değiştirmek isterseniz, karakteri değiştir seçeneğine tıklayın.", 255, 0, 0)
		end
	end
end
addEventHandler("onClientPlayerChangeNick", getRootElement(), stopNameChange)

function update_updateElementData(theElement, theParameter, theValue)
	if (theElement) and (theParameter) then
		if (theValue == nil) then
			theValue = false
		end
		theElement:setData(theParameter, theValue, false)
	end
end
addEventHandler("edu", getRootElement(), update_updateElementData)

function Exclusive.loginStart()
	time = 200000/1.5
	lastClick = 0
	--[[local sesler = 
	{
		[1] = "https://mp3semti.com/dinle/Y2K-Lalala",
		[2] = "img/music.mp3",
		[3] = "img/music.mp3",
	}
	local randomcek = math.random(1,3)
	local cek = sesler[randomcek]
	
	--]]
	-- bgMusic = playSound("img/music.mp3", true)
	-- setSoundVolume(bgMusic, 0.3)
	-- localPlayer:setData("bgMusic", bgMusic , false)
	fadeCamera ( true, 1, 0,0,0 );	
	
	
	
	setCameraMatrix(x1, y1+40, z1, x1t+170, y1t+30, z1t);
	
	airRotation, oldAirRotation, airYRotation = 90, 0, 0
	
	setCloudsEnabled(false)
	cameraMatrix, cameraMatrix2 = 0, 0;
	showCursor(true)
	showChat(false)
	   -- exports['blur']:createBlur("Loginblur", 5)
            showLoginPanel()
            -- startLogin()
            -- fadeCamera(true)
            --toggleAllControls(false, false)
            --exports['controls']:toggleAllControls(false, "low")
            --exports['custom-chat']:showChat(false)
            showChat(false)
            --createLogoAnimation(1, {sx/2, sy/2 - 190})
            -- createSituation(math.random(1, #cameraPos), true)
end

-- addEvent("hideLoginWindow", true)
-- addEventHandler("hideLoginWindow", root,
	-- function()
		   -- stopLoginPanel()
		   -- stopCharacterRegistration()
	   -- stopLoadingScreen()
	   -- stopLoginSound()
	   -- stopSituations()
	      -- exports['blur']:removeBlur("Loginblur")
--		  stopLogoAnimation()
	-- end
-- )

--[[
addEventHandler("onClientBrowserCreated", theBrowser, 
	function()
		setDevelopmentMode(true,true)
		loadBrowserURL(source, "http://mta/local/html/index.html")
	end
)
-- sendJS(fonksiyonadı, fonksiyon argları)
function sendJS(functionName, ...)
	if (not theBrowser) then
		outputDebugString("Browser is not loaded yet, can't send JS.")
		return false
	end

	local js = functionName.."("
	local argCount = #arg
	for i, v in ipairs(arg) do
		local argType = type(v)
		if (argType == "string") then
			js = js.."'"..addslashes(v).."'"
		elseif (argType == "boolean") then
			if (v) then js = js.."true" else js = js.."false" end
		elseif (argType == "nil") then
			js = js.."undefined"
		elseif (argType == "table") then
			--
		elseif (argType == "number") then
			js = js..v
		elseif (argType == "function") then
			js = js.."'"..addslashes(tostring(v)).."'"
		elseif (argType == "userdata") then
			js = js.."'"..addslashes(tostring(v)).."'"
		else
			outputDebugString("Unknown type: "..type(v))
		end

		argCount = argCount - 1
		if (argCount ~= 0) then
			js = js..","
		end
	end
	js = js .. ");"

	executeBrowserJavascript(theBrowser, js)
end--]]

function addslashes(s)
	local s = string.gsub(s, "(['\"\\])", "\\%1")
	s = string.gsub(s, "\n", "")
	return (string.gsub(s, "%z", "\\0"))
end

function drawnLogin()

	dxDrawRectangle(0, 0, sx, sy, tocolor(5, 5, 5, 120))
		w, h = 376, 81
		dxDrawImage(10, sy-120, w, h, "img/Rota.png")
		if isInBox(10, sy-12, w, h) then
			if getKeyState("mouse1") and lastClick+200 <= getTickCount() then
				lastClick = getTickCount()
				-- stopSound(bgMusic)
			end
		end	
	if bgb_state == "-" then
		bgb_alpha = bgb_alpha - 2
		if bgb_alpha <= 130 then
			bgb_alpha = 130
			bgb_state = "+"
		end
	elseif bgb_state == "+" then
		bgb_alpha = bgb_alpha + 2
		if bgb_alpha >= 255 then
			bgb_alpha = 255
			bgb_state = "-"
		end
	end
end

addEvent("sign-in", true)
addEventHandler("sign-in", root,
	function(username, password)
		access, code = checkVariables(1, username, password)
		if access then
			triggerServerEvent("accounts:login:attempt", getLocalPlayer(), username, password, false)
--			exports["infobox"]:addBox("success", "Başarıyla hesabına giriş yaptın.")
		else
			Error_msg("Everyone", code);
		end
	end
);

addEvent("register", true)
addEventHandler("register", root,
	function(username, password)
		access, code = checkVariables(2, username, password)
		if access then
			exports["notification"]:addBox("success", "Başarıyla "..username.." isimli hesabın sahibi oldun.")
			triggerServerEvent("accounts:register:attempt",getLocalPlayer(),username,password,password, "@")
		else
			Error_msg("Everyone", code);
		end
	end
);
--[[
function Error_msg(Page, message_text)
	--animation.text = message_text;
	-- alert_text kısmı. 
	sendJS("error", message_text); -- dene
end
addEvent("set_warning_text", true)
addEventHandler("set_warning_text", root, Error_msg)
addEvent("set_authen_text", true)
addEventHandler("set_authen_text", root, Error_msg)--]]

function checkVariables(page, username, password)
	if page == 1 then
		if username == "" then
			return false,"Kullanıcı adı boş kalmamalıdır.","blue"
		end

		if password == "" then
			return false,"Şifre boş kalmamalıdır.","blue"
		end

		return true
	elseif page == 2 then
		if username == "" then
			return false,"Kullanıcı adı boş kalmamalıdır!","blue"
		end
		if password == "" then
			return false,"Şifre boş kalmamalıdır!","blue"
		end
		
		if string.find(password, "'") or string.find(password, '"') then
			return false,"Şifrenizde istenmeyen karakter saptandı!","red"
		end
		if string.match(username,"%W") then
			return false,"Kullanıcı adınızda istenmeyen karakter saptandı!","red"
		end
		
		if string.len(password) < 8 then
			return false,"Girdiğiniz şifre en az 8 karakter olmalıdır!","red"
		end
		if string.len(password) > 16 then
			return false,"Girdiğiniz şifre en fazla 16 karakter olmalıdır!","red"
		end
		if string.len(password) < 3 then
			return false,"Girdiğiniz kullanıcı adı en az 3 karakter olmalıdır!","red"
		end
		
		return true
	end
end

function passwordHash(password)
    local length = utfLen(password)

    if length > 23 then
        length = 23
    end
    return string.rep("", length)
end

function getCameraRotation()
	cam = Camera.matrix:getRotation():getZ()
	--cam = tonumber(string.format("%.0f",cam/90))*90
	return cam
end

function Characters_showSelection()
	loadCharacterSelector(getElementData(localPlayer, "account:characters"))
end

local renderData = {
	username = "",
	password = "",
	passwordHidden = "",
	email = "",
	password2 = "",
	password2Hidden = "",
	activeFakeInput = "username",
	canUseFakeInputs = false,
	buttons = {},
	activeButton = false,
	rememberMe = false
}

local maxCreatableChar = 1
local logoSize = 128 * (1 / 75)

local localCharacters = {}
local characterVeriables = {}
local pedData = {}
local pedID = {}



function loadCharacterSelector(characters)

    setElementDimension(localPlayer, 1)
	--removeEventHandler("onClientRender", getRootElement(), onClientRender)
	--removeEventHandler("onClientCharacter", getRootElement(), onClientCharacter)
	--removeEventHandler("onClientKey", getRootElement(), onClientKey)
	--removeEventHandler("onClientClick", getRootElement(), onClientClick)

	renderData.characterMakingActive = false

	selectedChar = 1
	pedData = localPlayer:getData("account:characters") or characters

	local playerDimension = getElementDimension(localPlayer)
		
	for k, v in ipairs(pedData) do
		localCharacters[k] = createPed(v[9], 1148.2672119141 - (k - 1) * 6, -1156.669921875, 23.828125, 0)
        characterVeriables[k] = v[2]
		pedID[k] = v[1]
		setElementDimension(localCharacters[k], playerDimension)
		setElementFrozen(localCharacters[k], true)
	end
	
	if not pedID[selectedChar] then
	  removeEventHandler("onClientRender", getRootElement(), characterSelectRender)
				-- removeEventHandler("onClientKey", getRootElement(), characterSelectKey)
				-- removeEventHandler("onClientCharacter", getRootElement(), characterSelectCharacter)

				for k,v in pairs(localCharacters) do
					if isElement(v) then
						destroyElement(v)
					end
					localCharacters[k] = nil
				end

				renderData.canUseFakeInputs = false
				renderData.inputDisabled = false

				-- addEventHandler("onClientRender", getRootElement(), onClientRender)
				-- addEventHandler("onClientCharacter", getRootElement(), onClientCharacter)
				-- addEventHandler("onClientKey", getRootElement(), onClientKey)
				-- addEventHandler("onClientClick", getRootElement(), onClientClick)
                
				triggerEvent("successfulLogin", localPlayer, "createChar")
	  
    end
    if pedID[selectedChar] then
	setPedAnimation(localCharacters[1], "ON_LOOKERS", "wave_loop", -1, true, false, false)
	setCameraMatrix(1148.2672119141, -1150.2779541016, 31.311100006104, 1100.8375244141, -1150.2779541016, 31.311100006104)

	addEventHandler("onClientRender", getRootElement(), characterSelectRender)

	renderData.charCamX = 1148.2672119141
	renderData.charCamY = -1150.2779541016
	renderData.charCamZ = 31.311100006104
	renderData.charCamLX = 1148.2672119141
	renderData.charCamLY = -1150.2779541016
	renderData.charCamLZ = 31.311100006104
    
	renderData.charGotInterpolation = getTickCount()
	end
end

function loadFonts()
	local fonts = {
		Roboto18 = exports.assets:loadFont("Roboto-Regular.ttf", 18, false, "cleartype"),
		Roboto18L = exports.assets:loadFont("Roboto-Light.ttf", 18, false, "cleartype"),
		Roboto32B = exports.assets:loadFont("Roboto-Bold.ttf", 32, false, "cleartype"),
		SARPFont = exports.assets:loadFont("SARP.ttf", 32, false, "cleartype"),
	}

	for k,v in pairs(fonts) do
		_G[k] = v
		_G[k .. "H"] = dxGetFontHeight(1, _G[k])
	end
end


function karakterOlustur()
				Exclusive.destroyCharacters()
				newCharacter_init()
				end
				addCommandHandler("karakter", karakterOlustur)

addEventHandler("onAssetsLoaded", getRootElement(),
	function ()
		loadFonts()
	end
)

screenX, screenY = guiGetScreenSize()
screenWidth, screenHeight = 250, 160
scaleX, scaleY = 30, 30	
vegas = 0
mahlukat = 0

function characterSelectRender()

		dxDrawImage(0, 0, sx, sy, "files/bg.jpg")
		dxDrawRectangle(0, 0, sx, sy,tocolor(0, 0, 0, 240), false)
		dxDrawRectangle(scaleX, scaleY+180, 40, 37, tocolor(23, 23, 23, 255))

		if vstart or vend then
			w = interpolateBetween(vend and 250 or 0, 0, 0, vend and 0 or 250, 0, 0, (getTickCount()-(vstart or vend))/500, 'Linear')
		end
		if localPlayer:getData('charlimit') <= 1 then
			text = 'karakter limit yok!'
		else
			text = 'karakter oluştur!'
		end
		dxDrawRectangle(scaleX, scaleY+180, w or 0, 37, tocolor(23, 23, 23, 255))
		--dxDrawRectangle(scaleX+37, scaleY+186, 1, 25, tocolor(188, 188, 188, 255))
		dxDrawText(text, scaleX+40, scaleY+188, scaleX+(w or 0), scaleY+188+20, tocolor( 188, 188, 188, 235 ), 0.70, 'bankgothic', 'left', 'top', true)

		dxDrawImage(scaleX+6, scaleY+184, 30, 28, "files/characterCreate.png")
		hypnos = 0

		for index, value in ipairs(pedData) do
			
			local charName = characterVeriables[index]:gsub("_", " ")
			local nameWidth = dxGetTextWidth(charName, 1.85, "default-bold")
			local mahlukat = dxGetTextWidth(string.gsub(charName,'_',' ')..' ('..value[1]..')', 0.60, 'bankgothic')
			
			rx = scaleX+hypnos

			dxDrawRectangle(rx, scaleY, mahlukat+50, screenHeight, tocolor(23, 23, 23, 255))
			dxDrawImage(rx+(mahlukat+50-128)/2, scaleY+25, 128, 128, "components/skins/"..getPlayerSkin(localCharacters[index])..".png")
			dxDrawText(string.gsub(charName,'_',' ')..' ('..value[1]..')', rx, scaleY+5, rx+mahlukat+50, scaleY, tocolor( 188, 188, 188, 235 ), 0.60, 'bankgothic', 'center', 'top')

			--iprint((index == 1 and 0 or mahlukat))
			if res:isInSlot(rx, scaleY, screenWidth, screenHeight) then
				if getKeyState('mouse1') and vegas + 400 < getTickCount() then
					vegas = getTickCount()
					-- if isElement(loginMusic) then
						-- destroyElement(loginMusic)
					-- end
					-- loginMusic = nil
							
					removeEventHandler("onClientRender", getRootElement(), characterSelectRender)
					triggerServerEvent("accounts:characters:spawn", localPlayer, pedID[index])
					showCursor(false)
					renderData.charGotSelected = false
			removeEventHandler("onClientRender",root,renderLoginV2)
			removeEventHandler("onClientKey", root, keyLoginV2)
					setTimer(function()
						triggerEvent("client:showloading", localPlayer)
					end, 100, 1)

					for k,v in pairs(localCharacters) do
						if isElement(v) then
							destroyElement(v)
						end
						localCharacters[k] = nil
					end
				end
			end

			hypnos = hypnos + mahlukat + 60

		end

		if res:isInSlot(scaleX, scaleY+180, 40, 37) then
			if getKeyState('mouse1') and vegas + 400 < getTickCount() then
				-- if localPlayer:getData('charlimit') <= 1 then exports.notification:create('Karakter sınırınız dolmuş!', 'error') return end
				vegas = getTickCount()
				-- if isElement(loginMusic) then
					-- destroyElement(loginMusic)
				-- end
				-- loginMusic = nil
						
				removeEventHandler("onClientRender", getRootElement(), characterSelectRender)
				triggerEvent("successfulLogin", localPlayer, "createChar")
				
				renderData.charGotSelected = false
				
				for k,v in pairs(localCharacters) do
					if isElement(v) then
						destroyElement(v)
					end
					localCharacters[k] = nil
				end
			end
			vend = nil
			if not vstart then
				vstart = getTickCount()
			end
		else
			if not vend and vstart then
				vstart = nil
				vend = getTickCount()
			end
		end

end
--[[
function characterSelectKey(key, state)
	if state then
		cancelEvent()
		
		pedData = localPlayer:getData("account:characters") or playerCharacters 

		if not renderData.charSelectInterpolation then
			if key == "arrow_l" and selectedChar > 1 then
				renderData.charCamStartX = 1148.2672119141 - (selectedChar - 1) * 6

				setPedAnimation(localCharacters[selectedChar])
				selectedChar = selectedChar - 1
			
				if selectedChar < 1 then
					selectedChar = 1
					characterVeriables[selectedChar] = selectedChar
				end
			
				setPedAnimation(localCharacters[selectedChar], "ON_LOOKERS", "wave_loop", -1, true, false, false)

				renderData.charCamEndX = 1148.2672119141 - (selectedChar - 1) * 6
				renderData.charSelectInterpolation = getTickCount()
			elseif key == "arrow_r" and selectedChar < #pedData then
				renderData.charCamStartX = 1148.2672119141 - (selectedChar - 1) * 6

				setPedAnimation(localCharacters[selectedChar])
				selectedChar = selectedChar + 1
			
				if selectedChar > #pedData then
					selectedChar = #pedData
                    characterVeriables[selectedChar] = selectedChar				
				end
			
				setPedAnimation(localCharacters[selectedChar], "ON_LOOKERS", "wave_loop", -1, true, false, false)

				renderData.charCamEndX = 1148.2672119141 - (selectedChar - 1) * 6
				renderData.charSelectInterpolation = getTickCount()
			elseif key == "enter" or key == "lshift" and not renderData.charGotSelected and selectedChar then
			renderData.charGotSelected = true
				if pedID[selectedChar] then
					if isElement(loginMusic) then
						destroyElement(loginMusic)
					end
					loginMusic = nil
							
					local spawnTime = math.random(7500, 10000)

					removeEventHandler("onClientRender", getRootElement(), characterSelectRender)
					removeEventHandler("onClientKey", getRootElement(), characterSelectKey)
					
					triggerServerEvent("accounts:characters:spawn", localPlayer, pedID[selectedChar])


					showCursor(false)
					
					renderData.charGotSelected = false
					
					for k,v in pairs(localCharacters) do
						if isElement(v) then
							destroyElement(v)
						end
						localCharacters[k] = nil
					end
				else
					renderData.charGotSelected = false
					
				end
			elseif key == "space" and not renderData.charGotSelected and not (#getElementData(getLocalPlayer(), "account:characters") >= getElementData(getLocalPlayer(), "charlimit")) then
				removeEventHandler("onClientRender", getRootElement(), characterSelectRender)
				removeEventHandler("onClientKey", getRootElement(), characterSelectKey)
				removeEventHandler("onClientCharacter", getRootElement(), characterSelectCharacter)

				for k,v in pairs(localCharacters) do
					if isElement(v) then
						destroyElement(v)
					end
					localCharacters[k] = nil
				end

				renderData.canUseFakeInputs = false
				renderData.inputDisabled = false

				addEventHandler("onClientRender", getRootElement(), onClientRender)
				addEventHandler("onClientCharacter", getRootElement(), onClientCharacter)
				addEventHandler("onClientKey", getRootElement(), onClientKey)
				addEventHandler("onClientClick", getRootElement(), onClientClick)

				triggerEvent("successfulLogin", localPlayer, "createChar")
			else
                outputChatBox(">#C8C8C8 Olumsuz bir deneme yaptınız, Ne0R` ile görüşün.", 255, 0, 0, true)			
			end
		end
	end
end
]]

function Exclusive.destroyCharacters()
	removeEventHandler("onClientRender", root, drawnCharacters);
end

function DeleteMoneyItem(thePlayer)
    if exports.global:hasItem(thePlayer, 134) then
	    takeItem(thePlayer, 134)
	end
end

function characters_onSpawn(fixedName, adminLevel, gmLevel, location)
	clearChat()
	showChat(true)
	guiSetInputEnabled(false)
	showCursor(false)
	
	triggerServerEvent("item-system:deletemoney", getLocalPlayer(), getLocalPlayer())
	outputChatBox(" ")

	-- bgMusic = localPlayer:getData("bgMusic")
	-- if isElement(bgMusic) then
		-- destroyElement(bgMusic)
	-- end
	localPlayer:setData("admin_level", adminLevel, false)
	localPlayer:setData("account:gmlevel", gmLevel, false)

	options_enable()
end
addEvent("account:character:spawned", true)
addEventHandler("accounts:characters:spawn", getRootElement(), characters_onSpawn)


function isInBox(startX, startY, sizeX, sizeY)
    if isCursorShowing() then
        local cursorPosition = {getCursorPosition()};
        cursorPosition.x, cursorPosition.y = cursorPosition[1] * sx, cursorPosition[2] * sy

        if cursorPosition.x >= startX and cursorPosition.x <= startX + sizeX and cursorPosition.y >= startY and cursorPosition.y <= startY + sizeY then
            return true
        else
            return false
        end
    else
        return false
    end
end

function toRGBA(color)
    local r = bitExtract(color, 16, 8 ) 
    local g = bitExtract(color, 8, 8 ) 
    local b = bitExtract(color, 0, 8 ) 
    local a = bitExtract(color, 24, 8 ) 
    return r, g, b, a;
end

function stringToRGBA(string)
    local r = tonumber(string:sub(2, 3), 16);
    local g = tonumber(string:sub(4, 5), 16);
    local b = tonumber(string:sub(6, 7), 16);
    local a = 0;
    if string:len() == 7 then
        a = 255;
    else
        a = tonumber(string:sub(8, 9), 16);
    end
    return r, g, b, a;
end

function stringToColor(string)
    local r, g, b, a = stringToRGBA(string);
    return tocolor(r, g, b, a);
end

function colorDarker(color, factor)
    local r, g, b, a = toRGBA(color);
    r = r * factor;
    if r > 255 then r = 255; end
    g = g * factor;
    if g > 255 then g = 255; end
    b = b * factor;
    if b > 255 then b = 255; end
    return tocolor(r, g, b, a);
end


local Window = {}
local Button = {}
local Label = {}
local Edit = {}

function showEmailUpdate()
	showCursor(true)
	Window[1] = guiCreateWindow(0.3562,0.3997,0.2891,0.2383,"E-Posta Değiştirme Sistemi",true)
		guiSetInputEnabled ( true)
		Label[1] = guiCreateLabel(0.0378,0.153,0.9324,0.2404,"Güvenliğiniz nedeniyle ve sizlere bildiri göndermemiz amacıyla\ne-posta adresinizi girmenizi istiyoruz.\nBildirimlerden haberdar olmak için ve güncel haberleri\nöğrenmek için bilgileri doldur. ",true,Window[1])
			guiLabelSetColor(Label[1],210,210,210)
			guiLabelSetHorizontalAlign(Label[1],"center",false)
		Edit[1] = guiCreateEdit(0.2341,0.4781+0.100,0.5351,0.1475,"",true,Window[1])
		Label[2] = guiCreateLabel(0.32,0.4054+0.100,0.3432,0.1038,"e-posta adresinizi aşağıya doldurun.",true,Window[1])
		guiLabelSetHorizontalAlign(Label[2],"center")
		Button[1] = guiCreateButton(0.02,0.8087,2.2857,0.1257,"Doğrula",true,Window[1])
			addEventHandler("onClientGUIClick", Button[1], function()
				triggerServerEvent("email:degistir", getLocalPlayer(), guiGetText(Edit[1]))
			end)
end
addEvent("email:GUI", true)
addEventHandler("email:GUI", getRootElement(), showEmailUpdate)
addCommandHandler("epostadegistir", showEmailUpdate)

function closeEmailUpdate()
	destroyElement(Window[1])
	showCursor(false)
	guiSetInputEnabled ( false)
end
addEvent("email:GUIClose", true)
addEventHandler("email:GUIClose", getRootElement(), closeEmailUpdate)


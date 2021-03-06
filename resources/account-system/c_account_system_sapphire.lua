local version = "0.22"
local motd = ""
local canScroll = true

local language = "English"

function saveMOTD(theMOTD)
	motd = theMOTD
end
addEvent("updateMOTD", true)
addEventHandler("updateMOTD", getRootElement(), saveMOTD)

function hasBeta()
	local xmlRoot = xmlLoadFile( "sapphirebeta.xml" )
	if (xmlRoot) then
		local betaNode = xmlFindChild(xmlRoot, "beta", 0)

		if (betaNode) then
			return true
		end
		return false
	end
	
	return false
end

if ( hasBeta() ) then
	triggerServerEvent("hasBeta", getLocalPlayer())

function stopNameChange(oldNick, newNick)
	if (source==getLocalPlayer()) then
		local legitNameChange = getElementData(getLocalPlayer(), "legitnamechange")

		if (oldNick~=newNick) and (legitNameChange==0) then
			triggerServerEvent("resetName", getLocalPlayer(), oldNick, newNick) 
			outputChatBox("Click 'Change Character' if you wish to change your roleplay identity.", 255, 0, 0)
		end
	end
end
addEventHandler("onClientPlayerChangeNick", getRootElement(), stopNameChange)

function onPlayerSpawn()
	showCursor(false)
	
	local interior = getElementInterior(source)
	setCameraInterior(interior)
end
addEventHandler("onClientPlayerSpawn", getLocalPlayer(), onPlayerSpawn)

function clearChatBox()
	outputChatBox("")
	outputChatBox("")
	outputChatBox("")
	outputChatBox("")
	outputChatBox("")
	outputChatBox("")
	outputChatBox("")
	outputChatBox("")
	outputChatBox("")
	outputChatBox("")
	outputChatBox("")
	outputChatBox("")
	outputChatBox("")
end

function hideInterfaceComponents()
	--triggerEvent("hideHud", getLocalPlayer())
	showPlayerHudComponent("weapon", false)
	showPlayerHudComponent("ammo", false)
	showPlayerHudComponent("vehicle_name", false)
	showPlayerHudComponent("money", false)
	showPlayerHudComponent("clock", false)
	showPlayerHudComponent("health", false)
	showPlayerHudComponent("armour", false)
	showPlayerHudComponent("breath", false)
	showPlayerHudComponent("area_name", false)
	showPlayerHudComponent("radar", false)
	--triggerEvent("hideHud", getLocalPlayer())
	
	loadSettings()
	saveLanguageInformation()
end
addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), hideInterfaceComponents)


settingsNode = nil
langNode = nil
function loadSettings()
	settingsNode = xmlLoadFile("sapphire-settings.xml")
	
	if not (settingsNode) then
		loadDefaultSettings()
	else
		langNode = xmlFindChild(settingsNode, "language", 0)
		
		if not (langNode) then
			loadDefaultSettings()
		end
		
		language = xmlNodeGetValue(langNode)
		
		-- check its a valid language
		if ( strings[language] == nil ) then
			loadDefaultSettings()
		end
	end
end

function loadDefaultSettings()
	settingsNode = xmlCreateFile("sapphire-settings.xml", "settings")
	langNode = xmlCreateChild(settingsNode, "language")
	language = "English"
	saveSettings()
end

function saveSettings()
	xmlNodeSetValue(langNode, tostring(language))
	xmlSaveFile(settingsNode)
end

---------------------- [ ACCOUNT SCRIPT ] ----------------------
-- increasing this will reshow the tos as updated
local tosversion = 100
local toswindow, tos, bAccept, bDecline = nil
function checkTOS()
	local xmlRoot = xmlLoadFile("vgrptos.xml")
	
	if (xmlRoot) then
		local tosNode = xmlFindChild(xmlRoot, "tosversion", 0)
		
		if (tosNode) then
			local tversion = xmlNodeGetValue(tosNode)
			if (tversion) and (tversion~="") then
				if (tonumber(tversion)~=tosversion) then
					xmlRoot = nil
				end
			else
				xmlRoot = nil
			end
		else
			xmlRoot = nil
		end
	end
	
	if not (xmlRoot) then -- User hasn't accepted terms of service or is out of date
		local width, height = 700, 300
		local scrWidth, scrHeight = guiGetScreenSize()
		local x = scrWidth/2 - (width/2)
		local y = scrHeight/2 - (height/2)
		
		toswindow = guiCreateWindow(x, y, width, height, "Terms of Service", false)
		guiWindowSetMovable(toswindow, false)
		
		tos = guiCreateMemo(0.025, 0.1, 0.95, 0.7, "", true, toswindow)
		guiSetText(tos, "By connecting, playing, registering and logging into this server you agree to the following terms and conditions (Last revised 17/October/2008). \n\n- You will not use any external software to 'hack' or cheat in the game.\n- You will not exploit any bugs within the script to gain an advantage over other players.\n- Your account and character are property of Valhalla Gaming.\n- Your account may be removed after 30 days of inactivity (character inactivity does not count).\n\n Visit www.valhallagaming.net if you require any assistance with these terms.")
		guiEditSetReadOnly(tos, true)
		
		bAccept = guiCreateButton(0.1, 0.8, 0.4, 0.15, "Accept", true, toswindow)
		bDecline = guiCreateButton(0.51, 0.8, 0.4, 0.15, "Decline", true, toswindow)
		addEventHandler("onClientGUIClick", bAccept, acceptTOS, false)
		addEventHandler("onClientGUIClick", bDecline, declineTOS, false)
		
		showCursor( true )
	else
		triggerServerEvent("getSalt", getLocalPlayer(), scripter)
	end
end
addEventHandler( "onClientResourceStart", getResourceRootElement( ), checkTOS )

function acceptTOS(button, state)
	local theFile = xmlCreateFile("vgrptos.xml", "tosversion")
	if (theFile) then
		local node = xmlCreateChild(theFile, "tosversion")
		xmlNodeSetValue(node, tostring(tosversion))
		xmlSaveFile(theFile)
	end
	destroyElement(toswindow)
	toswindow = nil
	
	triggerServerEvent("getSalt", getLocalPlayer(), scripter)
end

function declineTOS(button, state)
	triggerServerEvent("declineTOS", getLocalPlayer())
end

function generateTimestamp(daysAhead)
	return tostring( 50000000 + getRealTime().year * 366 + getRealTime().yearday + daysAhead )
end

function storeSalt(theSalt, theIP, theMOTD)
	ip = theIP
	salt = theSalt
	motd = theMOTD
	
	if xmlLoadFile("vgrptut.xml") then
		createXMB()
	else
		showTutorial()
		showCursor(true)
		showChat(true)
	end
end
addEvent("sendSalt", true)
addEventHandler("sendSalt", getRootElement(), storeSalt)

-- ////////////////// tognametags
local nametags = true
function toggleNametags()
	if (nametags) then
		nametags = false
		outputChatBox("Nametags are no longer visible.", 255, 0, 0)
		triggerEvent("hidenametags", getLocalPlayer())
	elseif not (nametags) then
		nametags = true
		outputChatBox("Nametags are now visible.", 0, 255, 0)
		triggerEvent("shownametags", getLocalPlayer())
	end
end
addCommandHandler("tognametags", toggleNametags)
addCommandHandler("togglenametags", toggleNametags)

--============================================================
--							XMB
--============================================================
width, height = guiGetScreenSize()

state = 0
------ STATES
-- 0 = login screen
-- 1 = logged in

function shutdownXMB()
	fadeCamera(false, 0.0)
end
addEventHandler("onClientResourceStop", getResourceRootElement(getThisResource()), shutdownXMB)

logoAlpha = 255
logoAlphaDir = 0

errorMsg = nil
errorMsgx = 0
errorMsgy = 0

local xoffset = width / 6
local yoffset = height / 6

local initX = (width / 6.35) + xoffset
local initY = height / 5.2

local lowerAlpha = 100

local logoutID = 1
local languagesID = 2
local accountID = 3
local charactersID = 4
local socialID = 5
local achievementsID = 6
local settingsID = 7
local helpID = 8

local initPos = charactersID

local mainMenuItems =
{
	[logoutID] = { text = "Logout", image = "logout-icon.png" },
	[languagesID] = { text = "Languages", image = "submit-app-icon.png" },
	[accountID] = { text = "Account", image = "account-icon.png" },
	[charactersID] = { text = "Characters", image = "characters-icon.png" },
	[socialID] = { text = "Social", image = "social-icon.png" },
	[achievementsID] = { text = "Achievements", image = "achievements-icon.png" },
	[settingsID] = { text = "Settings", image = "settings-icon.png" },
	[helpID] = { text = "Help", image = "help-icon.png" }
}

local images = { }
for i = 1, #mainMenuItems do
	local v = mainMenuItems[i]
	v.tx = initX + ( i - initPos ) * xoffset
	v.ty = initY
	v.cx = v.tx
	v.cy = v.ty
	v.alpha = initPos == i and 255 or lowerAlpha
	
	images[v.text] = "gui/" .. v.image
end

local fontHeight1 = dxGetFontHeight(1, "default-bold")
local fontHeight2 = dxGetFontHeight(0.9, "default")

-- SUBMENUS
local characterMenu = { }

local xmbAlpha = 1.0
local currentItem = charactersID
local currentItemAlpha = 1.0
local lastItemLeft = 2
local lastItemRight = 4
local lastItemAlpha = 1.0

local loadedCharacters = false
local loadedLanguages = false
local loadedAchievements = false
local loadedFriends = false
local loadedAccount = false
local loadedHelp = false
local loadedSettings = false
local loadingImageRotation = 0

local mtaUsername = nil
local MTAaccountTimer = nil

local tFriends =  { }
local tAchievements =  { }
local tAccount = { }
local tHelp = { }
local tLanguages = { }

local currentVerticalItem = 1
lastKey = 0

-- MOTD
local motdX = guiGetScreenSize()
local motdSpeed = 1
function drawBG()
	local width, height = guiGetScreenSize()
	-- background
	dxDrawRectangle(0, 0, width, height, tocolor(0, 0, 0, 200 * xmbAlpha), false)
	
	-- top right text and image
	dxDrawText("Valhalla MTA Server", width - 350,80, width-200, 30, tocolor(255, 255, 255, 200 * xmbAlpha), 0.7, "bankgothic", "center", "middle", false, false, false)
	dxDrawText("Sapphire V" .. version, width - 350, 100, width-200, 30, tocolor(255, 255, 255, 200 * xmbAlpha), 0.5, "bankgothic", "center", "middle", false, false, false)
	dxDrawImage(width - 131, 30, 131, 120, "gui/valhalla1.png", 0, 0, 0, tocolor(255, 255, 255, 200 * xmbAlpha), false)
	
	-- MOTD
	dxDrawRectangle(0, height - 40, width, 20, tocolor(195, 195, 195, 150 * xmbAlpha), false)
	dxDrawText(motd, motdX, height - 40, width, 20, tocolor(255, 255, 255, 200 * xmbAlpha), 0.5, "bankgothic", "left", "middle", false, false, false)
	motdX = motdX - motdSpeed
	
	if ( motdX < 0 - dxGetTextWidth(motd, 0.5, "bankgothic") ) then
		motdX = width
	end
	
	-- fading
	local step = 3
	if (logoAlpha > 0) and (logoAlphaDir == 0) then
		logoAlpha = logoAlpha - step
	elseif (logoAlpha <= 0) and (logoAlphaDir == 0) then
		logoAlphaDir = 1
		logoAlpha = logoAlpha + step
	elseif (logoAlpha < 255) and (logoAlphaDir == 1) then
		logoAlpha = logoAlpha + step
	elseif (logoAlpha >= 255) and (logoAlphaDir == 1) then
		logoAlphaDir = 0
		logoAlpha = logoAlpha - step
	end
	-- end fading
	
	local time = getRealTime()
	-- fix trailing 0's
	local hour = tostring(time.hour)
	local mins = tostring(time.minute)
	local secs = tostring(time.second)
	
	if ( time.hour < 10 ) then
		hour = "0" .. hour
	end
	
	if ( time.minute < 10 ) then
		mins = "0" .. mins
	end
	
	if ( time.second < 10 ) then
		secs = "0" .. secs
	end
	
	dxDrawText(hour .. ":" .. mins, width - 75, 20, width - 50, 30, tocolor(255, 255, 255, 200 * xmbAlpha), 0.7, "bankgothic", "center", "middle", false, false, false)
	dxDrawText(":" .. secs, width - 30, 20, width - 5, 30, tocolor(255, 255, 255, 200 * xmbAlpha), 0.5, "bankgothic", "center", "middle", false, false, false)
	
	-- error msg
	if (errorMsg ~= nil) then
		dxDrawText(errorMsg, errorMsgx, errorMsgy, errorMsgx, errorMsgy, tocolor(255, 0, 0, logoAlpha * xmbAlpha), 0.5, "bankgothic", "center", "middle", false, false, false)
	end
	
	if (state == 0 ) then -- login screen
		dxDrawLine(50, height / 4, width - 50, height / 4, tocolor(255, 255, 255, 255), 2, false)
		dxDrawText("Login", 80, height / 5, 80, height / 5, tocolor(255, 255, 255, 255), 0.7, "bankgothic", "center", "middle", false, false, false)
	elseif (state == 1 ) then -- attempt login
		dxDrawLine(50, height / 4, width - 50, height / 4, tocolor(255, 255, 255, 255), 2, false)
		dxDrawText("Login", 80, height / 5, 80, height / 5, tocolor(255, 255, 255, 255), 0.7, "bankgothic", "center", "middle", false, false, false)
		local x, y = guiGetPosition(tUsername, false)
		dxDrawText("Attempting to Login...", x, y, x, y, tocolor(255, 255, 255, logoAlpha * xmbAlpha), 0.7, "bankgothic", "center", "middle", false, false, false)
	elseif (state >= 2 ) then -- main XMB
		dxDrawLine(mainMenuItems[1].cx, height / 5, mainMenuItems[#mainMenuItems].cx + 131, height / 5, tocolor(255, 255, 255, 155 * xmbAlpha), 2, false)
		
		-- serial
		dxDrawText(tostring(md5(getElementData(getLocalPlayer(),"gameaccountusername"))), xoffset * 0.3, 10, 150, 30, tocolor(255, 255, 255, 200 * xmbAlpha), 0.8, "verdana", "center", "middle", false, false, false)
		
		-- draw our vertical menus
		-- put the if statements inside, so the logic is still updated!
		drawCharacters()
		drawLanguages()
		drawAchievements()
		drawFriends()
		drawAccount()
		drawSettings()
		drawHelp()
		
		if (lastItemAlpha > 0.0) then
			lastItemAlpha = lastItemAlpha - 0.1
		elseif lastItemAlpha ~= 0 then
			lastItemAlpha = 0
		end
		
		if currentItemAlpha < 1.0 then
			currentItemAlpha = currentItemAlpha + 0.1
		elseif currentItemAlpha ~= 1 then
			currentItemAlpha = 1
		end
		
		dxDrawImage(initX, initY + 20, 130, 93, "gui/icon-glow.png", 0, 0, 0, tocolor(255, 255, 255, logoAlpha * xmbAlpha))
		for i = 1, #mainMenuItems do
			local tx = mainMenuItems[i].tx
			local ty = mainMenuItems[i].ty
			local cx = mainMenuItems[i].cx
			local cy = mainMenuItems[i].cy
			local text = strings[language][mainMenuItems[i].text]
			local alpha = mainMenuItems[i].alpha
		
			-- ANIMATIONS
			if ( round(cx, -1) < round(tx, -1) ) then -- we need to move right!
				mainMenuItems[i].cx = mainMenuItems[i].cx + 10
			end
			
			if ( round(cx, -1) > round(tx, -1) ) then -- we need to move left!
				mainMenuItems[i].cx = mainMenuItems[i].cx - 10
			end
			
			if ( round(cx, -1) == round(initX, -1) ) then -- its the selected
				dxDrawText(text, cx+30, cy+120, cx+100, cy+140, tocolor(255, 255, 255, logoAlpha * xmbAlpha), 0.5, "bankgothic", "center", "middle")
			end
			
			-- ALPHA SMOOTHING
			if ( round(tx, -1) == round(initX, -1) and round(alpha, -1) < 255 ) then
				mainMenuItems[i].alpha = mainMenuItems[i].alpha + 10
			elseif ( tx ~= initX and round(alpha, -1) ~= lowerAlpha ) then
				mainMenuItems[i].alpha = mainMenuItems[i].alpha - 10
			end
			
			if ( mainMenuItems[i].alpha > 255 ) then
				mainMenuItems[i].alpha = 255
			end
		
			dxDrawImage(cx, cy, 131, 120, images[mainMenuItems[i].text], 0, 0, 0, tocolor(255, 255, 255, mainMenuItems[i].alpha * xmbAlpha))
		end
	end
end

function round(num, idp)
	if (idp) then
		local mult = 10^idp
		return math.floor(num * mult + 0.5) / mult
	end
	return math.floor(num + 0.5)
end


function createXMB(isChangeAccount)
	guiSetInputEnabled(true)
	addEventHandler("onClientRender", getRootElement(), drawBG)
	showChat(false)
	
	fadeCamera(true)
	setCameraMatrix(1401.4228515625, -887.6865234375, 76.401107788086, 1415.453125, -811.09375, 80.234382629395)

	createXMBLogin(isChangeAccount)
end


--------------------------------------------------------------------
--						LOGIN & REGISTER
--------------------------------------------------------------------
lUsername, lPassword, tUsername, tPassword, bLogin, bRegister, chkRememberLogin, chkAutoLogin = nil
function createXMBLogin(isChangeAccount)
	lUsername = guiCreateLabel(width /2.65, height /2.5, 100, 50, "Username:", false)
	guiSetFont(lUsername, "default-bold-small")
	
	tUsername = guiCreateEdit(width /2.25, height /2.5, 100, 17, "Username", false)
	guiSetFont(tUsername, "default-bold-small")
	guiEditSetMaxLength(tUsername, 32)
	
	lPassword = guiCreateLabel(width /2.65, height /2.3, 100, 50, "Password:", false)
	guiSetFont(lPassword, "default-bold-small")
	
	tPassword = guiCreateEdit(width /2.25, height /2.3, 100, 17, "Password", false)
	guiSetFont(tPassword, "default-bold-small")
	guiEditSetMasked(tPassword, true)
	guiEditSetMaxLength(tPassword, 32)
	
	chkRememberLogin = guiCreateCheckBox(width /2.65, height /2.15, 175, 17, "Remember My Details", false, false)
	addEventHandler("onClientGUIClick", chkRememberLogin, updateRemember)
	guiSetFont(chkRememberLogin, "default-bold-small")
	
	chkAutoLogin = guiCreateCheckBox(width /2.65, height /2.05, 175, 17, "Log in Automatically", false, false)
	guiSetFont(chkAutoLogin, "default-bold-small")
	
	bLogin = guiCreateButton(width /2.65, height /1.9, 75, 17, "Login", false)
	guiSetFont(bLogin, "default-bold-small")
	addEventHandler("onClientGUIClick", bLogin, validateLogin, false)
	
	bRegister = guiCreateButton(width /2.15, height /1.9, 75, 17, "Register", false)
	guiSetFont(bRegister, "default-bold-small")
	
	loginImage = guiCreateStaticImage(width/4, height/2.8, 128, 128, "gui/folder-user.png", false)
	
	loadSavedDetails(isChangeAccount)
end

function updateRemember()
	if (guiCheckBoxGetSelected(chkRememberLogin)) then
		guiSetEnabled(chkAutoLogin, true)
	else
		guiSetEnabled(chkAutoLogin, false)
		guiCheckBoxSetSelected(chkAutoLogin, false)
	end
end

function loadSavedDetails(isChangeAccount)
	local xmlRoot = xmlLoadFile( ip == "127.0.0.1" and "vgrploginlocal.xml" or "vgrplogin.xml" )
	if (xmlRoot) then
		local usernameNode = xmlFindChild(xmlRoot, "username", 0)
		local passwordNode = xmlFindChild(xmlRoot, "password", 0)
		local autologinNode = xmlFindChild(xmlRoot, "autologin", 0)
		local timestampNode = xmlFindChild(xmlRoot, "timestamp", 0)
		local timestamphashNode = xmlFindChild(xmlRoot, "timestamphash", 0)
		local iphashNode = xmlFindChild(xmlRoot, "iphash", 0)
		local uname = nil
		
		if (usernameNode) then
			uname = xmlNodeGetValue(usernameNode)
		end
		
		if (timestampNode and timestamphashNode and iphashNode) then -- no security information? no continuing.
			local timestamp = xmlNodeGetValue(timestampNode)
			local timestampHash = xmlNodeGetValue(timestamphashNode)
			local ipHash = xmlNodeGetValue(iphashNode)
			local currTimestamp = generateTimestamp(0)
			
			-- Split the current ip up
			local octet1 = gettok(ip, 1, string.byte("."))
			local octet2 = gettok(ip, 2, string.byte("."))
			local hashedIP = md5(octet1 .. octet2 .. salt .. uname)
			
			if ( md5(timestamp .. salt) ~= timestampHash) then
				showError(4)
				guiCheckBoxSetSelected(chkAutoLogin, false)
			elseif ( ipHash ~= hashedIP ) then
				showError(5)
				guiCheckBoxSetSelected(chkAutoLogin, false)
			elseif ( currTimestamp >= timestamp ) then
				showError(6)
				guiCheckBoxSetSelected(chkAutoLogin, false)
			else
				if (uname) and (uname~="") then
					guiSetText(tUsername, tostring(uname))
					guiCheckBoxSetSelected(chkRememberLogin, true)
				end
				
				if (passwordNode) then
					local pword = xmlNodeGetValue(passwordNode)
					if (pword) and (pword~="") then
						guiSetText(tPassword, tostring(pword))
						guiCheckBoxSetSelected(chkRememberLogin, true)
					else
						guiSetEnabled(chkAutoLogin, false)
					end
				end
				
				if (autologinNode) then
					local autolog = xmlNodeGetValue(autologinNode)
					if (autolog) and (autolog=="1") then
						
						if(guiGetEnabled(chkAutoLogin)) then
							guiCheckBoxSetSelected(chkAutoLogin, true)
							if not (isChangeAccount) then
								validateLogin()
							end
						end
					end
				else
					guiCheckBoxSetSelected(chkAutoLogin, false)
				end
			end
		end
	end
end

function validateLogin()
	local username = guiGetText(tUsername)
	local password = guiGetText(tPassword)
	
	if (string.len(username)<3) then
		outputChatBox("Your username is too short. You must enter 3 or more characters.", 255, 0, 0)
	elseif (string.find(username, ";", 0)) or (string.find(username, "'", 0)) or (string.find(username, "@", 0)) or (string.find(username, ",", 0)) then
		outputChatBox("Your name cannot contain ;,@.'", 255, 0, 0)
	elseif (string.len(password)<6) then
		outputChatBox("Your password is too short. You must enter 6 or more characters.", 255, 0, 0)
	elseif (string.find(password, ";", 0)) or (string.find(password, "'", 0)) or (string.find(password, "@", 0)) or (string.find(password, ",", 0)) then
		outputChatBox("Your password cannot contain ;,@'.", 255, 0, 0)
	else
		if (string.len(password)~=32) then
			password = md5(salt .. password)
		end
		
		local vinfo = getVersion()
		local operatingsystem = vinfo.os
		
		state = 1
		toggleLoginVisibility(false)
		
		
		triggerServerEvent("attemptLogin", getLocalPlayer(), username, password) 
		
		local saveInfo = guiCheckBoxGetSelected(chkRememberLogin)
		local autoLogin = guiCheckBoxGetSelected(chkAutoLogin)
		
		local theFile = xmlCreateFile( ip == "127.0.0.1" and "vgrploginlocal.xml" or "vgrplogin.xml", "login")
		if (theFile) then
			if (saveInfo) then
				local node = xmlCreateChild(theFile, "username")
				xmlNodeSetValue(node, tostring(username))
				
				local node = xmlCreateChild(theFile, "password")
				xmlNodeSetValue(node, tostring(password))
				
				local node = xmlCreateChild(theFile, "autologin")
				if (autoLogin) then
					xmlNodeSetValue(node, tostring(1))
				else
					xmlNodeSetValue(node, tostring(0))
				end
				
				-- security information
				local node = xmlCreateChild(theFile, "timestamp")
				local timestamp = generateTimestamp(7)
				xmlNodeSetValue(node, tostring(timestamp))
				
				local node = xmlCreateChild(theFile, "timestamphash")
				local timestamphash = md5(timestamp .. salt)
				xmlNodeSetValue(node, tostring(timestamphash))
				
				local node = xmlCreateChild(theFile, "iphash")
				local octet1 = gettok(ip, 1, string.byte("."))
				local octet2 = gettok(ip, 2, string.byte("."))
				local hashedIP = md5(octet1 .. octet2 .. salt .. tostring(username))
				xmlNodeSetValue(node, tostring(hashedIP))
			else
				local node = xmlCreateChild(theFile, "username")
				xmlNodeSetValue(node, "")
				
				local node = xmlCreateChild(theFile, "password")
				xmlNodeSetValue(node, "")
				
				local node = xmlCreateChild(theFile, "autologin")
				xmlNodeSetValue(node, tostring(0))
				
				local node = xmlCreateChild(theFile, "timestamp")
				xmlNodeSetValue(node, "")
				
				local node = xmlCreateChild(theFile, "timestamphash")
				xmlNodeSetValue(node, "")
				
				local node = xmlCreateChild(theFile, "iphash")
				xmlNodeSetValue(node, "")
			end
			xmlSaveFile(theFile)
		end
	end
end

function toggleLoginVisibility(visible)
	guiSetVisible(lUsername, visible)
	guiSetVisible(tUsername, visible)
	guiSetVisible(lPassword, visible)
	guiSetVisible(tPassword, visible)
	guiSetVisible(loginImage, visible)
	guiSetVisible(bLogin, visible)
	guiSetVisible(bRegister, visible)
	guiSetVisible(chkRememberLogin, visible)
	guiSetVisible(chkAutoLogin, visible)
end

--------------------------------------------------------------------
--- ERROR CODES
-- 1 = WRONG PW OR USERNAME
-- 2 = ACCOUNT ALREADY LOGGED IN
-- 3 = ACCOUNT BANNED
-- 4 = LOGIN FILE MODIFIED EXTERNALLY
-- 5 = LOGIN FILE DOES NOT BELONG TO THIS PC
-- 6 = LOGIN FILE EXPIRED
-- 7 = INVALID LIVE ACCOUNT
errorTimer = nil
errorCode = 0
function showError(theErrorCode)
	errorCode = theErrorCode
	if (errorCode == 1) then -- wrong pw
		errorMsg = "Invalid Username or Password"
		errorMsgx, errorMsgy = guiGetPosition(tUsername, false)
		local width = guiGetSize(tUsername, false)
		errorMsgx = errorMsgx + (width * 2.5)
		toggleLoginVisibility(true)
		state = 0
	elseif (errorCode == 2) then -- account in use
		errorMsg = "This account is currently in use"
		errorMsgx, errorMsgy = guiGetPosition(tUsername, false)
		local width = guiGetSize(tUsername, false)
		errorMsgx = errorMsgx + (width * 2.5)
		toggleLoginVisibility(true)
		state = 0
	elseif (errorCode == 3) then -- account banned
		errorMsg = "That account is banned"
		errorMsgx, errorMsgy = guiGetPosition(tUsername, false)
		local width = guiGetSize(tUsername, false)
		errorMsgx = errorMsgx + (width * 2.5)
		toggleLoginVisibility(true)
		state = 0
	elseif (errorCode == 4) then
		errorMsg = "Login file was modified externally"
		errorMsgx, errorMsgy = guiGetPosition(tUsername, false)
		local width = guiGetSize(tUsername, false)
		errorMsgx = errorMsgx + (width * 2.5)
		toggleLoginVisibility(true)
		state = 0
	elseif (errorCode == 5) then
		errorMsg = "Login file does not belong to this PC"
		errorMsgx, errorMsgy = guiGetPosition(tUsername, false)
		local width = guiGetSize(tUsername, false)
		errorMsgx = errorMsgx + (width * 2.5)
		toggleLoginVisibility(true)
		state = 0
	elseif (errorCode == 6) then
		errorMsg = "Login file has expired"
		errorMsgx, errorMsgy = guiGetPosition(tUsername, false)
		local width = guiGetSize(tUsername, false)
		errorMsgx = errorMsgx + (width * 2.5)
		toggleLoginVisibility(true)
		state = 0
	elseif (errorCode == 7) then
		errorMsg = "Invalid Live Username"
		local cx = mainMenuItems[accountID].cx
		errorMsgx = cx + (xoffset/1.5)
		
		for k = 1, #tAccount do
			local title = tAccount[k].title
			
			if ( title == strings[language]["Xbox"] ) then
				hideXbox()
				errorMsgy = tAccount[k].ty + dxGetFontHeight(0.9, "default") + 40
			end
		end
	elseif (errorCode == 8) then
		errorMsg = "Invalid Steam Username"
		local cx = mainMenuItems[accountID].cx
		errorMsgx = cx + (xoffset/1.5)
		
		for k = 1, #tAccount do
			local title = tAccount[k].title
			
			if ( title == strings[language]["Steam"] ) then
				hideSteam()
				errorMsgy = tAccount[k].ty + dxGetFontHeight(0.9, "default") + 40
			end
		end
	elseif (errorCode == 9) then
		errorMsg = "Service Unavailable"
		local cx = mainMenuItems[accountID].cx
		errorMsgx = cx + (xoffset/1.5)
		
		for k = 1, #tAccount do
			local title = tAccount[k].title
			
			if ( title == strings[language]["Steam"] ) then
				hideSteam()
				errorMsgy = tAccount[k].ty + dxGetFontHeight(0.9, "default") + 40
			end
		end
	end
	
	playSoundFrontEnd(4)
	if (isTimer(errorTimer)) then
		killTimer(errorTimer)
	end
	errorTimer = setTimer(resetError, 5000, 1)
end
addEvent("loginFail", true)
addEventHandler("loginFail", getRootElement(), showError)

function resetError()
	errorMsg = nil
end
--------------------------------------------------------------------------

keyTimer = nil
function moveRight()
	if ( round(mainMenuItems[#mainMenuItems].tx, -1) > initX and canScroll) then -- can move left
		for i = 1, #mainMenuItems do
			mainMenuItems[i].tx = mainMenuItems[i].tx - xoffset
			
			if ( round(initX, -1) == round(mainMenuItems[i].tx, -1) ) then
				currentItem = i
				currentItemAlpha = 0.0
				lastItemAlpha = 1.0

				lastItemLeft = i - 1
				lastItemRight = i + 1
			end
		end
		keyTimer = setTimer(checkKeyState, 400, 1, "arrow_r")
		lastKey = 1
		
		checkForInvalidErrors()
	end
end

function moveLeft()
	if ( mainMenuItems[1].tx < initX and canScroll) then -- can move left
		lastItemAlpha = 1.0
		for i = 1, #mainMenuItems do
			mainMenuItems[i].tx = mainMenuItems[i].tx + xoffset
			
			if ( round(initX, -1) == round(mainMenuItems[i].tx, -1) ) then
				currentItem = i
				currentItemAlpha = 0.0
				lastItemAlpha = 1.0
				
				lastItemLeft = i - 1
				lastItemRight = i + 1
			end
		end
		
		
		keyTimer = setTimer(checkKeyState, 400, 1, "arrow_l")
		lastKey = 2
		
		checkForInvalidErrors()
	end
end

function moveDown()
	local items = { [accountID] = tAccount, [languagesID] = tLanguages, [charactersID] = characterMenu, [socialID] = tFriends, [achievementsID] = tAchievements, [helpID] = tHelp }
	local t = items[ currentItem ]
	if t and canScroll then
		if ( math.ceil( t[#t].ty ) > math.ceil(initY + yoffset + 40) ) then -- can move down
			lastItemAlpha = 1.0
			for i = 1, #t do
				if ( round(t[i].ty, -1) == round(initY + yoffset + 40, -1) ) then -- its selected
					t[i].ty = t[i].ty - 2*yoffset
					
					if currentItem == charactersID and not isLoggedIn() then
						setElementModel(getLocalPlayer(), tonumber(t[i + 1].skin))
					end
				elseif ( round(t[i].ty, -1) < round(initY + xoffset, -1) ) then -- its in the no mans land
					t[i].ty = t[i].ty - yoffset
				else
					t[i].ty = t[i].ty - yoffset
				end
			end
			keyTimer = setTimer(checkKeyState, 200, 1, "arrow_d")
			lastKey = 3
			
			checkForInvalidErrors()
		end
	end
end

function isLoggedIn()
	return getElementData(getLocalPlayer(), "loggedin") == 1
end

function checkForInvalidErrors()
	-- update error message which shouldnt show on move
	if ( errorCode == 7 ) then
		if (isTimer(errorTimer)) then
			killTimer(errorTimer)
		end
		errorCode = 0
		errorMsg = nil
	end
end

function moveUp()
	local items = { [accountID] = tAccount, [languagesID] = tLanguages, [charactersID] = characterMenu, [socialID] = tFriends, [achievementsID] = tAchievements, [helpID] = tHelp }
	local t = items[ currentItem ]
	if t and canScroll then
		if ( math.ceil( t[1].ty ) < math.ceil(initY + yoffset + 40) ) then -- can move up
			local selIndex = nil
			for k = 1, #t do
				local i = #t - (k - 1)
				if ( round(t[i].ty, -1) == round(initY + yoffset + 40, -1) ) then -- its selected
					t[i].ty = t[i].ty + yoffset
					selIndex = i - 1
					
				elseif (i == selIndex) then -- new selected
					t[i].ty = t[i].ty + 2*yoffset
					
					if currentItem == characterMenu and not isLoggedIn() then
						setElementModel(getLocalPlayer(), tonumber(t[i].skin))
					end
				else
					t[i].ty = t[i].ty + yoffset
				end
			end
			keyTimer = setTimer(checkKeyState, 200, 1, "arrow_u")
			lastKey = 4
			
			checkForInvalidErrors()
		end

	end
end

function checkKeyState(key)
	if (getKeyState(key)) then
		if ( key == "arrow_l" ) then
			moveLeft()
		elseif ( key == "arrow_r" ) then
			moveRight()
		elseif ( key == "arrow_u" ) then
			moveUp()
		elseif ( key == "arrow_d" ) then
			moveDown()
		end
	else
		keyTimer = nil
	end
end

-- XBOX LIVE
local tXboxUsername = nil
local bXboxUpdate = nil
local bXboxCancel = nil
local xboxUsername = nil

-- STEAM
local tSteamUsername = nil
local bSteamUpdate = nil
local bSteamCancel = nil
local steamUsername = nil

local currentCharacterID = nil
function selectItemFromVerticalMenu()
	if isPlayerDead( getLocalPlayer( ) ) and getElementData( getLocalPlayer( ), "dbid" ) then
		return
	elseif ( currentItem == charactersID ) then
		-- lets determine which character is selected
		for k = 1, #characterMenu do
			local i = #characterMenu - (k - 1)

			if ( round(characterMenu[k].ty, -1) >= round(initY + xoffset, -1) - 100) then -- selected
				if ( currentCharacterID == k ) then
					hideXMB()
					return
				end
				
				local name = characterMenu[k].name
				local skin = characterMenu[k].skin
				local cked = characterMenu[k].cked
				if not cked or cked == 0 then
					currentCharacterID = k
					state = 3
					triggerServerEvent("spawnCharacter", getLocalPlayer(), name, getVersion().mta)

					hideXMB()
				else
					outputChatBox( name .. " is dead.", 255, 0, 0 )
				end
				break
			end
		end
	elseif ( currentItem == accountID ) then
		for k = 1, #tAccount do
			local i = #tAccount - (k - 1)
			if ( round(tAccount[k].ty, -1) >= round(initY + xoffset, -1) - 100) then -- selected
				local title = strings[language][tAccount[k].title]
				local stateAccount = tAccount[k].state
				
				if ( title == strings[language]["Revert"] ) then -- leave the beta
					local xml = xmlLoadFile("sapphirebeta.xml")
					local betaNode = xmlFindChild(xml, "beta", 0)
					xmlDestroyNode(betaNode)
					xmlSaveFile(xml)
					xmlUnloadFile(xml)
					triggerServerEvent("acceptBeta", getLocalPlayer())
					
				elseif ( title == strings[language]["Xbox"] and stateAccount == 0 ) then
					local cx = mainMenuItems[accountID].cx + 30
					
					local text = "Xbox Live Username"
					if (xboxUsername ~= nil) then
						text = xboxUsername
					end
					
					tXboxUsername = guiCreateEdit(cx, tAccount[k].ty + dxGetFontHeight(0.9, "default") + 15, 150, 17, text, false)
					guiSetFont(tXboxUsername, "default-bold-small")
					guiEditSetMaxLength(tXboxUsername, 20)
					
					bXboxUpdate = guiCreateButton(cx, tAccount[k].ty + dxGetFontHeight(0.9, "default") + 40, 75, 17, "Update", false)
					guiSetFont(bXboxUpdate, "default-bold-small")
					addEventHandler("onClientGUIClick", bXboxUpdate, updateXbox, false)
					
					bXboxCancel = guiCreateButton(cx + 80, tAccount[k].ty + dxGetFontHeight(0.9, "default") + 40, 75, 17, "Cancel", false)
					guiSetFont(bXboxCancel, "default-bold-small")
					addEventHandler("onClientGUIClick", bXboxCancel, cancelXbox, false)
					
					showCursor(true)
					guiSetInputEnabled(true)
					
					tAccount[k].state = 1
					canScroll = false
				elseif ( title == strings[language]["Steam"] and stateAccount == 0 ) then
					local cx = mainMenuItems[accountID].cx + 30
					
					local text = "Steam Community Name"
					if (steamUsername ~= nil) then
						text = steamUsername
					end
					
					tSteamUsername = guiCreateEdit(cx, tAccount[k].ty + dxGetFontHeight(0.9, "default") + 15, 150, 17, text, false)
					guiSetFont(tSteamUsername, "default-bold-small")
					guiEditSetMaxLength(tSteamUsername, 20)
					
					bSteamUpdate = guiCreateButton(cx, tAccount[k].ty + dxGetFontHeight(0.9, "default") + 40, 75, 17, "Update", false)
					guiSetFont(bSteamUpdate, "default-bold-small")
					addEventHandler("onClientGUIClick", bSteamUpdate, updateSteam, false)
					
					bSteamCancel = guiCreateButton(cx + 80, tAccount[k].ty + dxGetFontHeight(0.9, "default") + 40, 75, 17, "Cancel", false)
					guiSetFont(bXboxCancel, "default-bold-small")
					addEventHandler("onClientGUIClick", bSteamCancel, cancelSteam, false)
					
					showCursor(true)
					guiSetInputEnabled(true)
					
					tAccount[k].state = 1
					canScroll = false
				end
				break
			end
		end
	elseif ( currentItem == languagesID ) then
		for k = 1, #tLanguages do
			local i = #tLanguages - (k - 1)
			if ( round(tLanguages[k].ty, -1) >= round(initY + xoffset, -1) - 100) then -- selected
				local title = tLanguages[k]
				local stateAccount = tLanguages[k].state

				language = tLanguages[k].title
				-- save language
				saveSettings()
				return

			end
		end
	elseif ( currentItem == logoutID ) then
		-- cleanup
		removeEventHandler("onClientRender", getRootElement(), drawBG)
		state = 0
		
		triggerServerEvent("accountplayer:loggedout", getLocalPlayer())
		
		unbindKey("arrow_l", "down", moveLeft)
		unbindKey("arrow_r", "down", moveRight)
		unbindKey("arrow_u", "down", moveUp)
		unbindKey("arrow_d", "down", moveDown)
		unbindKey("enter", "down", selectItemFromVerticalMenu)
		removeCommandHandler("home", toggleXMB)
		
		createXMB(true)
	end
end

function updateXbox(button, state)
	if ( button == "left" ) then
		guiSetEnabled(tXboxUsername, false)
		guiSetEnabled(bXboxUpdate, false)
		guiSetEnabled(bXboxCancel, false)
		
		-- update our state
		for k = 1, #tAccount do
			local title = tAccount[k].title
			
			if ( title == strings[language]["Xbox"] ) then
				tAccount[k].state = 2
			end
		end
		
		triggerServerEvent("SupdateXbox", getLocalPlayer(), guiGetText(tXboxUsername))
		
		local x, y = getCursorPosition()
		setCursorPosition(x+50, y+50)
		showCursor(false)
		guiSetInputEnabled(false)
	end
end

xboxString = nil
function xboxSuccessfulUpdate(gamertag, status, activity, lastgame, level)
	for k = 1, #tAccount do
		local title = strings[language][tAccount[k].title]
		
		if ( title == strings[language]["Xbox"] ) then
			if ( lastgame == nil ) then
				lastgame = "None"
			end
			
			if ( activity == "" ) then
				activity = "Never Seen"
			end
		
			xboxUsername = gamertag
			xboxString = gamertag .. " (" .. status .. " - " .. level .. ")\nActivity: " .. tostring(activity) .. "\nLast Game Played: " .. tostring(lastgame)
			tAccount[k].state = 0
			
			if ( isElement(tXboxUsername) ) then
				hideXbox()
			end
		end
	end
end
addEvent("CxboxSuccess", true)
addEventHandler("CxboxSuccess", getLocalPlayer(), xboxSuccessfulUpdate)

function xboxFailedUpdate()
	showError(7)
end
addEvent("CxboxFail", true)
addEventHandler("CxboxFail", getLocalPlayer(), xboxFailedUpdate)

function cancelXbox(button, state)
	if ( button == "left" ) then
		hideXbox()
	end
end

function hideXbox()
	destroyElement(tXboxUsername)
	tXboxUsername = nil
	
	destroyElement(bXboxUpdate)
	bXboxUpdate = nil
	
	destroyElement(bXboxCancel)
	bXboxCancel = nil
	
	canScroll = true
	
	-- reset our state
	for k = 1, #tAccount do
		local title = tAccount[k].title
		
		if ( title == strings[language]["Xbox"] ) then
			tAccount[k].state = 0
		end
	end
	
	showCursor(false)
	guiSetInputEnabled(false)
end

-- STEAM
steamString = nil
function updateSteam(button, state)
	if ( button == "left" ) then
		guiSetEnabled(tSteamUsername, false)
		guiSetEnabled(bSteamUpdate, false)
		guiSetEnabled(bSteamCancel, false)
		
		-- update our state
		for k = 1, #tAccount do
			local title = tAccount[k].title
			
			if ( title == strings[language]["Steam"]) then
				tAccount[k].state = 2
			end
		end
		
		triggerServerEvent("SupdateSteam", getLocalPlayer(), guiGetText(tSteamUsername))
		
		local x, y = getCursorPosition()
		setCursorPosition(x+50, y+50)
		showCursor(false)
		guiSetInputEnabled(false)
	end
end


function steamSuccessfulUpdate(name, nickname, online, state, game, timeplayed)
	for k = 1, #tAccount do
		local title = strings[language][tAccount[k].title]
		steamUsername = name
		
		if ( title == strings[language]["Steam"] ) then
			if ( game ~= nil and timeplayed ~= nil ) then -- its public
				
				
				steamString = nickname .. " (" .. online .. ")\nActivity: " .. tostring(state) .. "\nLast Game Played: " .. tostring(game) .. "(" .. timeplayed .. " hours)"
			else -- its private
				steamString = nickname .. " (unknown)\nProfile is currently Private!"
			end
			
			tAccount[k].state = 0
			
			if ( isElement(tSteamUsername) ) then
				hideSteam()
			end
		end
	end
end
addEvent("CsteamSuccess", true)
addEventHandler("CsteamSuccess", getLocalPlayer(), steamSuccessfulUpdate)


function steamFailedUpdate()
	showError(8)
end
addEvent("CsteamFail", true)
addEventHandler("CsteamFail", getLocalPlayer(), steamFailedUpdate)

function steamFailedUpdateDown()
	showError(9)
end
addEvent("CsteamDown", true)
addEventHandler("CsteamDown", getLocalPlayer(), steamFailedUpdateDown)

function cancelSteam(button, state)
	if ( button == "left" ) then
		hideSteam()
	end
end

function hideSteam()
	destroyElement(tSteamUsername)
	tSteamUsername = nil
	
	destroyElement(bSteamUpdate)
	bSteamUpdate = nil
	
	destroyElement(bSteamCancel)
	bSteamCancel = nil
	
	canScroll = true
	
	-- reset our state
	for k = 1, #tAccount do
		local title = tAccount[k].title
		
		if ( title == strings[language]["Steam"] ) then
			tAccount[k].state = 0
		end
	end
	
	showCursor(false)
	guiSetInputEnabled(false)
end

function drawCharacters()
	local currentAlpha = 0
	if currentItem == charactersID then
		currentAlpha = xmbAlpha * currentItemAlpha
	elseif ( lastItemLeft == charactersID and lastKey == 1 ) or ( lastItemRight == charactersID and lastKey == 2 ) then
		currentAlpha = xmbAlpha * lastItemAlpha
	end
		
	if currentAlpha < 0.001 then
		return
	end
	
	local cx = mainMenuItems[charactersID].cx + 30
	if ( loadedCharacters ) then
		for i = 1, #characterMenu do
			local name = characterMenu[i].name
			local age = characterMenu[i].age
			local cked = characterMenu[i].cked
			local cy = characterMenu[i].cy
			local ty = characterMenu[i].ty
			local faction = characterMenu[i].faction
			local rank = characterMenu[i].rank
			local lastseen = characterMenu[i].lastseen
			local skin = characterMenu[i].skin
			
			local dist = getDistanceBetweenPoints2D(0, initY + yoffset + 40, 0, cy)
			
			
			local alpha = 255
			if ( cy < (initY + 2*yoffset)) then
				alpha = 255 - ( dist/ 2 )
			else
				alpha = 255 - (dist / 2)
			end
			alpha = alpha * currentAlpha
			
			-- ANIMATIONS
			if ( round(cy, -1) > round(ty, -1) ) then -- we need to move down!
				characterMenu[i].cy = characterMenu[i].cy - 10
			end
			
			if ( round(cy, -1) < round(ty, -1) ) then -- we need to move up!
				characterMenu[i].cy = characterMenu[i].cy + 10
			end
			
			local gender = characterMenu[i].gender == 0 and "Male" or "Female"
			local agestring = age .. " year old " .. gender .. "."
			
			local factionstring = faction
			if cked and cked > 0 then
				factionstring = "Dead."
			elseif rank then
				factionstring = rank .. " of '" .. faction .. "'."
			end
			
			local laststring = "Last Seen: Today."
			if not lastseen then
				laststring = "Last Seen: Never."
			elseif lastseen == 1 then
				laststring = "Last Seen: Yesterday."
			elseif lastseen > 1 then
				laststring = "Last Seen: " .. lastseen .. " Days Ago."
			end
			
			local color = tocolor(255, 255, 255, alpha)
			
			
			dxDrawText(name, cx-10, cy, cx + dxGetTextWidth(name, 1, "default-bold"), cy + fontHeight1, color, 1, "default-bold", "center", "middle")
			dxDrawText(agestring, cx, cy+20, cx + dxGetTextWidth(agestring, 0.9), cy + 20 + fontHeight2, color, 0.9, "default", "center", "middle")
			dxDrawText(factionstring, cx, cy+40, cx + dxGetTextWidth(factionstring, 0.9), cy + 40 + fontHeight2, color, 0.9, "default", "center", "middle")
			dxDrawText(laststring, cx, cy+60, cx + dxGetTextWidth(laststring, 0.9), cy + 60 + fontHeight2, color, 0.9, "default", "center", "middle")
			
			dxDrawImage(cx - 108, cy, 25, 20, "/gui/valhalla1.png", 0, 0, 0, color)
			dxDrawImage(cx - 108, cy, 78, 64, "img/" .. ("%03d"):format(skin) .. ".png", 0, 0, 0, color)
		end
	else
		dxDrawImage(cx + 5, initY + yoffset + 40, 66, 66, "gui/loading.png", loadingImageRotation, 0, 0, tocolor(255, 255, 255, xmbAlpha * 150))
		loadingImageRotation = loadingImageRotation + 5
	end
end

local visible = true
function hideXMB()
	unbindKey("arrow_l", "down", moveLeft)
	unbindKey("arrow_r", "down", moveRight)
	unbindKey("arrow_u", "down", moveUp)
	unbindKey("arrow_d", "down", moveDown)
	unbindKey("enter", "down", selectItemFromVerticalMenu)

	visible = false
	
	addEventHandler("onClientRender", getRootElement(), decreaseAlpha)
end

function toggleXMB()
	if ( visible or not isPlayerDead( getLocalPlayer( ) ) ) and state == 3 and not fading then
		fading = true
		if ( visible ) then
			hideXMB()
		else
			showXMB()
		end
	end
end

function decreaseAlpha()
	if ( xmbAlpha > 0.0 ) then
		xmbAlpha = xmbAlpha - 0.1
	else
		toggleAllControls(true, true, true)
		guiSetInputEnabled(false)
		showCursor(false)
		showChat(true)
			
		showPlayerHudComponent("weapon", true)
		showPlayerHudComponent("ammo", true)
		showPlayerHudComponent("vehicle_name", false)
		showPlayerHudComponent("money", true)
		showPlayerHudComponent("health", true)
		showPlayerHudComponent("armour", true)
		showPlayerHudComponent("breath", true)
		showPlayerHudComponent("radar", true)
		showPlayerHudComponent("area_name", true)
		showPlayerHudComponent("clock", true)
	
		fading = false
	
		removeEventHandler("onClientRender", getRootElement(), decreaseAlpha)
		removeEventHandler("onClientRender", getRootElement(), drawBG)
	end
end

function increaseAlpha()
	if ( xmbAlpha < 1.0 ) then
		xmbAlpha = xmbAlpha + 0.1
	else
		fading = false
		updateFriends()
		removeEventHandler("onClientRender", getRootElement(), increaseAlpha)
	end
end

function showXMB()
	bindKey("arrow_l", "down", moveLeft)
	bindKey("arrow_r", "down", moveRight)
	bindKey("arrow_u", "down", moveUp)
	bindKey("arrow_d", "down", moveDown)
	bindKey("enter", "down", selectItemFromVerticalMenu)

	visible = true
	toggleAllControls(false, true, true)
	guiSetInputEnabled(false)
	showCursor(false)
	showChat(false)
		
	showPlayerHudComponent("weapon", false)
	showPlayerHudComponent("ammo", false)
	showPlayerHudComponent("vehicle_name", false)
	showPlayerHudComponent("money", false)
	showPlayerHudComponent("health", false)
	showPlayerHudComponent("armour", false)
	showPlayerHudComponent("breath", false)
	showPlayerHudComponent("radar", false)
	showPlayerHudComponent("area_name", false)
	showPlayerHudComponent("clock", false)

	
	addEventHandler("onClientRender", getRootElement(), increaseAlpha)
	addEventHandler("onClientRender", getRootElement(), drawBG)
end

------------- FRIENDS
function saveFriends(friends, friendsmessage)
	local resource = getResourceFromName("achievement-system")
	
	-- load ourself
	tFriends[1] = { id = getElementData(getLocalPlayer(), "gameaccountid"), username = getElementData(getLocalPlayer(), "gameaccountusername"), message = friendsmessage, country = getElementData(getLocalPlayer(), "country"), online = true, character = nil, cy = initY - yoffset + 40, ty = initY - yoffset + 40 }
	
	for k,v in pairs(friends) do
		local id, username, message, country = unpack( v )
		tFriends[k+1] = { id = id, username = username, message = message, country = country, cy = initY + k*yoffset + 40, ty = initY + k*yoffset + 40 }
		tFriends[k+1].online, tFriends[k+1].character = isPlayerOnline(id)
	end
	loadedFriends = true
end
addEvent("returnFriends", true)
addEventHandler("returnFriends", getRootElement(), saveFriends)

function updateFriends()
	for i = 1, #tFriends do
		local id = tFriends[i].id
		local online = tFriends[i].online
		
		if ( i ~= 1 ) then
			tFriends[i].online, tFriends[i].character = isPlayerOnline(id)
		end
	end
end

function isPlayerOnline(id)
	for key, value in ipairs(getElementsByType("player")) do
		local pid = getElementData(value, "gameaccountid")

		if (id==pid) then
			return true, string.gsub(getPlayerName(value), "_", " ")
		end
	end
	return false
end

function isSpawned(id)
	for key, value in ipairs(getElementsByType("player")) do
		local pid = getElementData(value, "gameaccountid")

		if (id==pid) then
			return getElementData(value, "loggedin") == 1
		end
	end
	return false
end

function drawFriends()
	local currentAlpha = 0
	if currentItem == socialID then
		currentAlpha = xmbAlpha * currentItemAlpha
	elseif ( lastItemLeft == socialID and lastKey == 1 ) or ( lastItemRight == socialID and lastKey == 2 ) then
		currentAlpha = xmbAlpha * lastItemAlpha
	end
	
	if currentAlpha < 0.001 then
		return
	end
	
	local cx = mainMenuItems[socialID].cx + 30
	if ( loadedFriends ) then
		for i = 1, #tFriends do
			local id = tFriends[i].id
			local name = tFriends[i].username
			local message = "'" .. tFriends[i].message .. "'"
			local country = string.lower(tFriends[i].country)
			local online = tFriends[i].online
			local character = tFriends[i].character
			local cy = tFriends[i].cy
			local ty = tFriends[i].ty
			
			local dist = getDistanceBetweenPoints2D(0, initY + yoffset + 40, 0, cy)
			
			local alpha = 255
			if ( cy < (initY + 2*yoffset)) then
				alpha = 255 - ( dist/ 2 )
			else
				alpha = 255 - (dist / 2)
			end
			alpha = alpha * currentAlpha
			
			-- ANIMATIONS
			if ( round(cy, -1) > round(ty, -1) ) then -- we need to move down!
				tFriends[i].cy = tFriends[i].cy - 10
			end
			
			if ( round(cy, -1) < round(ty, -1) ) then -- we need to move up!
				tFriends[i].cy = tFriends[i].cy + 10
			end
			
			local statusText = "Currently Offline"
			local characterText = nil
			
			if (online) then
				if ( i ~= 1 ) then
					statusText = "Online Now!"
				else
					statusText = "You are Online!"
				end
				
				if ( isSpawned(id) ) then
					if ( id == getElementData(getLocalPlayer(), "gameaccountid") ) then
						character = getPlayerName(getLocalPlayer())
					end
					
					if ( character == nil ) then
						characterText = "Currently at Home Menu"
					else
						characterText = "Playing as '" .. character .. "'."
					end
				else
					characterText = "Currently at Home Menu"
				end
			end
			
			local color = tocolor(255, 255, 255, alpha)
			
			
			dxDrawText(name, cx-10, cy, cx + dxGetTextWidth(name, 1, "default-bold"), cy + fontHeight1, color, 1, "default-bold", "center", "middle")
			dxDrawText(statusText, cx, cy+20, cx + dxGetTextWidth(statusText, 0.9), cy + 20 + fontHeight2, color, 0.9, "default", "center", "middle")
			dxDrawText(message, cx, cy+40, cx + dxGetTextWidth(message, 0.9), cy + 40 + fontHeight2, color, 0.9, "default", "center", "middle")
				
			if (characterText) then
				dxDrawText(characterText, cx, cy+60, cx + dxGetTextWidth(characterText, 0.9), cy + 40 + fontHeight2, color, 0.9, "default", "center", "middle")
			end
				
			dxDrawImage(cx - 46, cy, 16, 11, ":social-system/images/flags/" .. country .. ".png", 0, 0, 0, color)
		end
	else
		dxDrawImage(cx + 5, initY + yoffset + 40, 66, 66, "gui/loading.png", loadingImageRotation, 0, 0, tocolor(255, 255, 255, currentAlpha * 150))
		loadingImageRotation = loadingImageRotation + 5
	end
end


----------- ACHIEVEMENTS
function saveAchievements(achievements)
	local resource = getResourceFromName("achievement-system")
	
	for k,v in pairs(achievements) do
		tAchievements[k] = { date = v[2], cy = initY + k * yoffset + 40, ty = initY + k * yoffset + 40 }
		tAchievements[k].name, tAchievements[k].desc, tAchievements[k].points = unpack( call( getResourceFromName( "achievement-system" ), "getAchievementInfo", v[1] ) )
	end
	loadedAchievements = true
end
addEvent("returnAchievements", true)
addEventHandler("returnAchievements", getRootElement(), saveAchievements)

function drawAchievements()
	local currentAlpha = 0
	if currentItem == achievementsID then
		currentAlpha = xmbAlpha * currentItemAlpha
	elseif ( lastItemLeft == achievementsID and lastKey == 1 ) or ( lastItemRight == achievementsID and lastKey == 2 ) then
		currentAlpha = xmbAlpha * lastItemAlpha
	end
		
	if currentAlpha < 0.001 then
		return
	end
	
	local cx = mainMenuItems[achievementsID].cx
	if ( loadedAchievements ) then
		for i = 1, #tAchievements do
			local name = tAchievements[i].name
			local desc = tAchievements[i].desc
			local points = "Points: " .. tostring(tAchievements[i].points)
			local date = "Unlocked: " .. tostring(tAchievements[i].date)
			local cy = tAchievements[i].cy
			local ty = tAchievements[i].ty
			
			local dist = getDistanceBetweenPoints2D(0, initY + yoffset + 40, 0, cy)
			
			local alpha = 255
			if ( cy < (initY + 2*yoffset)) then
				alpha = 255 - ( dist/ 2 )
			else
				alpha = 255 - (dist / 2)
			end
			alpha = alpha * currentAlpha
			
			-- ANIMATIONS
			if ( round(cy, -1) > round(ty, -1) ) then -- we need to move down!
				tAchievements[i].cy = tAchievements[i].cy - 10
			end
			
			if ( round(cy, -1) < round(ty, -1) ) then -- we need to move up!
				tAchievements[i].cy = tAchievements[i].cy + 10
			end
			
			local color = tocolor(255, 255, 255, alpha)
			local color2 = tocolor(255, 0, 0, alpha)

			
			dxDrawText(name, cx-10, cy, cx + dxGetTextWidth(name, 1, "default-bold"), cy + fontHeight1, color, 1, "default-bold", "center", "middle")
			dxDrawText(desc, cx, cy+20, cx + dxGetTextWidth(desc, 0.9), cy + 20 + fontHeight2, color, 0.9, "default", "center", "middle")
			dxDrawText(points, cx, cy+40, cx + dxGetTextWidth(points, 0.9), cy + 40 + fontHeight2, color, 0.9, "default", "center", "middle")
			dxDrawText(date, cx, cy+60, cx + dxGetTextWidth(date, 0.9), cy + 60 + fontHeight2, color, "default", "center", "middle")
			
			dxDrawImage(cx - 108, cy, 78, 64, "/gui/valhalla1.png", 0, 0, 0, color2)
		end
	else
		dxDrawImage(cx + 5, initY + yoffset + 40, 66, 66, "gui/loading.png", loadingImageRotation, 0, 0, tocolor(255, 255, 255, currentAlpha * 150))
		loadingImageRotation = loadingImageRotation + 5
	end
end

function checkForMTAAccount()
	--[[
	if ( getPlayerUserName() ) then
		outputDebugString("DETECTED MTA ACCOUNT: " .. getPlayerUserName())
		mtaUsername = getPlayerUserName()
		triggerServerEvent("storeMTAUsername", getLocalPlayer())
		killTimer(MTAaccountTimer)
		MTAaccountTimer = nil
		
		tAccount[1].title = "MTA Account"
		tAccount[1].text = tostring(getPlayerUserName())
	end
	]]--
end

-- Detect friends logging in
local friendAlertUsername = nil
local friendAlertTimer = nil
local friendAlertType = 0
local friendAlertAlpha = 0
local friendAlertFadeIn = true
local friendAlertVisible = false
local friendAlertCharname = nil
function friendLogin(username)
	for i = 1, #tFriends do
		if ( tostring(tFriends[i].username) == username ) then
			friendAlertType = 0
			showFriendOnline(username)
			break
		end
	end
end
addEvent("onPlayerAccountLogin", true)
addEventHandler("onPlayerAccountLogin", getRootElement(), friendLogin)

function characterChange(charname, username)
	local username = getElementData(source, "gameaccountusername")
	for i = 1, #tFriends do
		if ( tostring(tFriends[i].username) == username ) then
			friendAlertType = 1
			friendAlertCharname = string.gsub(charname, "_", " ")
			showFriendOnline(username)
			break
		end
	end
end
addEvent("onPlayerCharacterChange", true)
addEventHandler("onPlayerCharacterChange", getRootElement(), characterChange)

function showFriendOnline(username)
	if ( friendAlertVisible ) then
		hideFriendAlert()
		removeEventHandler("onClientRender", getRootElement(), showFriendAlert)
	end
	
	-- disable hud elements
	showPlayerHudComponent("clock", false)
	showPlayerHudComponent("weapon", false)
	showPlayerHudComponent("ammo", false)
	showPlayerHudComponent("health", false)
	showPlayerHudComponent("armour", false)
	showPlayerHudComponent("breath", false)
	showPlayerHudComponent("money", false)

	friendAlertVisible = true
	friendAlertFadeIn = true
	friendAlertUsername = username
	friendAlertAlpha = 0
	addEventHandler("onClientRender", getRootElement(), showFriendAlert)
end

function hideFriendAlert()
	if ( isTimer(friendAlertTimer) ) then
		killTimer(friendAlertTimer)
		friendAlertTimer = nil
	end
	
	friendAlertFadeIn = false
end

function showFriendAlert()
	if ( friendAlertAlpha < 150 and friendAlertFadeIn ) then
		friendAlertAlpha = friendAlertAlpha + 5
	elseif ( friendAlertAlpha > 0 and not friendAlertFadeIn ) then
		friendAlertAlpha = friendAlertAlpha - 5
	end
	
	if ( friendAlertAlpha >= 150 and friendAlertFadeIn and not isTimer(friendAlertTimer) ) then
		friendAlertTimer = setTimer(hideFriendAlert, 3000, 1)
	elseif ( friendAlertAlpha <= 0 and not friendAlertFadeIn ) then
		-- enable hud elements
		showPlayerHudComponent("clock", true)
		showPlayerHudComponent("weapon", true)
		showPlayerHudComponent("ammo", true)
		showPlayerHudComponent("health", true)
		showPlayerHudComponent("armour", true)
		showPlayerHudComponent("breath", true)
		showPlayerHudComponent("money", true)
		
		friendAlertAlpha = 0
		removeEventHandler("onClientRender", getRootElement(), showFriendAlert)
		
		friendAlertVisible = false
	end
	
	dxDrawRectangle(width - xoffset*2, 30, xoffset*1.9, 120, tocolor(0, 0, 0, friendAlertAlpha), false)
	
	local x = width - xoffset*2
	local y = 30
	dxDrawText(friendAlertUsername, x+10, y+10, x + xoffset*1.9, y + 120, tocolor(0,0,0, friendAlertAlpha + 50), 2, "sans", "center", "center", false, false, false)
	dxDrawText(friendAlertUsername, x, y, x + xoffset*1.9, y + 120, tocolor(255, 255, 255, friendAlertAlpha + 50), 2, "sans", "center", "center", false, false, false)

	if ( friendAlertType == 0 ) then
		local x = width - xoffset*1.6
		local y = 20 + dxGetFontHeight(2, "sans")
		dxDrawText("has just signed in.", x+10, y+10, x + xoffset*1.8, y + 120, tocolor(0,0,0, friendAlertAlpha + 50), 1, "sans", "center", "center", false, false, false)
		dxDrawText("has just signed in.", x, y, x + xoffset*1.8, y + 120, tocolor(255, 255, 255, friendAlertAlpha + 50), 1, "sans", "center", "center", false, false, false)
	elseif ( friendAlertType == 1 ) then
		local x = width - xoffset*2.0
		local y = 20 + dxGetFontHeight(2, "sans")
		dxDrawText("is now playing as '" .. friendAlertCharname .. "'", x+10, y+10, x + xoffset*2.2, y + 120, tocolor(0,0,0, friendAlertAlpha + 50), 1, "sans", "center", "center", false, false, false)
		dxDrawText("is now playing as '" .. friendAlertCharname .. "'", x, y, x + xoffset*2.2, y + 120, tocolor(255, 255, 255, friendAlertAlpha + 50), 1, "sans", "center", "center", false, false, false)
	end
end

function drawLanguages()
	local currentAlpha = 0
	if currentItem == languagesID then
		currentAlpha = xmbAlpha * currentItemAlpha
	elseif ( lastItemLeft == languagesID and lastKey == 1 ) or ( lastItemRight == languagesID and lastKey == 2 ) then
		currentAlpha = xmbAlpha * lastItemAlpha
	end
	
	if currentAlpha == 0 then
		return
	end
	
	local cx = mainMenuItems[languagesID].cx + 30
	if ( loadedLanguages) then
		for i = 1, #tLanguages do
			local title = strings[tLanguages[i].title][tLanguages[i].title]
			local text = strings[tLanguages[i].title][tLanguages[i].title .. "Desc"]
			local flag = tLanguages[i].flag
			local cy = tLanguages[i].cy
			local ty = tLanguages[i].ty
			
			local dist = getDistanceBetweenPoints2D(0, initY + yoffset + 40, 0, cy)
			
			local alpha = 255
			if ( cy < (initY + 2*yoffset)) then
				alpha = 255 - ( dist/ 2 )
			else
				alpha = 255 - (dist / 2)
			end
			alpha = alpha * currentAlpha
			
			-- ANIMATIONS
			if ( round(cy, -1) > round(ty, -1) ) then -- we need to move down!
				tLanguages[i].cy = tLanguages[i].cy - 10
			end
			
			if ( round(cy, -1) < round(ty, -1) ) then -- we need to move up!
				tLanguages[i].cy = tLanguages[i].cy + 10
			end
			
			local color = tocolor(255, 255, 255, alpha)
			local color2 = tocolor(255, 0, 0, alpha)
			
			dxDrawText(title, cx-10, cy, cx + dxGetTextWidth(title, 1, "default-bold"), cy + fontHeight1, color, 1, "default-bold", "center", "middle")
			dxDrawText(text, cx, cy+20, cx + dxGetTextWidth(text, 0.9, "default"), cy + 20 + fontHeight2, color, 0.9, "default", "left", "middle")
			
			dxDrawImage(cx - 46, cy, 16, 11, ":social-system/images/flags/" .. flag .. ".png", 0, 0, 0, color)
			if language == tLanguages[i].title then
				dxDrawImage(cx - 98, cy + 10, 58, 44, "/gui/valhalla1.png", 0, 0, 0, color2)
			end
		end
	else
		dxDrawImage(cx + 5, initY + yoffset + 40, 66, 66, "gui/loading.png", loadingImageRotation, 0, 0, tocolor(255, 255, 255, currentAlpha * 150))
		loadingImageRotation = loadingImageRotation + 5
	end
end

function drawAccount()
	local currentAlpha = 0
	if currentItem == accountID then
		currentAlpha = xmbAlpha * currentItemAlpha
	elseif ( lastItemLeft == accountID and lastKey == 1 ) or ( lastItemRight == accountID and lastKey == 2 ) then
		currentAlpha = xmbAlpha * lastItemAlpha
	end
	
	if currentAlpha == 0 then
		return
	end
	
	local cx = mainMenuItems[accountID].cx + 30
	if ( loadedAccount ) then
		for i = 1, #tAccount do
			local title = strings[language][tAccount[i].title]
			local text = strings[language][tAccount[i].text]
			local cy = tAccount[i].cy
			local ty = tAccount[i].ty
			local stateAccount = tAccount[i].state
			
			local dist = getDistanceBetweenPoints2D(0, initY + yoffset + 40, 0, cy)
			
			local alpha = 255
			if ( cy < (initY + 2*yoffset)) then
				alpha = 255 - ( dist/ 2 )
			else
				alpha = 255 - (dist / 2)
			end
			alpha = alpha * currentAlpha
			
			-- ANIMATIONS
			if ( round(cy, -1) > round(ty, -1) ) then -- we need to move down!
				tAccount[i].cy = tAccount[i].cy - 10
			end
			
			if ( round(cy, -1) < round(ty, -1) ) then -- we need to move up!
				tAccount[i].cy = tAccount[i].cy + 10
			end
			
			local color = tocolor(255, 255, 255, alpha)
			
			if ( strings[language][tAccount[i].title] == strings[language]["Xbox"] and xboxString ) then
				text = xboxString
			elseif ( strings[language][tAccount[i].title] == strings[language]["Steam"] and steamString ) then
				text = steamString
			end
			dxDrawText(title, cx-10, cy, cx + dxGetTextWidth(title, 1, "default-bold"), cy + fontHeight1, color, 1, "default-bold", "center", "middle")
			
			if ( stateAccount == 0 ) then
				dxDrawText(text, cx, cy+20, cx + dxGetTextWidth(text, 0.9, "default"), cy + 20 + fontHeight2, color, 0.9, "default", "left", "middle")
			end
		end
	else
		dxDrawImage(cx + 5, initY + yoffset + 40, 66, 66, "gui/loading.png", loadingImageRotation, 0, 0, tocolor(255, 255, 255, currentAlpha * 150))
		loadingImageRotation = loadingImageRotation + 5
	end
end

function drawSettings()
	local currentAlpha = 0
	if currentItem == settingsID then
		currentAlpha = xmbAlpha * currentItemAlpha
	elseif ( lastItemLeft == settingsID and lastKey == 1 ) or ( lastItemRight == settingsID and lastKey == 2 ) then
		currentAlpha = xmbAlpha * lastItemAlpha
	end
	
	if currentAlpha == 0 then
		return
	end
	
	local cx = mainMenuItems[settingsID].cx + 30
	if ( loadedSettings ) then
		
	else
		dxDrawImage(cx + 5, initY + yoffset + 40, 66, 66, "gui/loading.png", loadingImageRotation, 0, 0, tocolor(255, 255, 255, currentAlpha * 150))
		loadingImageRotation = loadingImageRotation + 5
	end
end

function drawHelp()
	local currentAlpha = 0
	if currentItem == helpID then
		currentAlpha = xmbAlpha * currentItemAlpha
	elseif ( lastItemLeft == helpID and lastKey == 1 ) or ( lastItemRight == helpID and lastKey == 2 ) then
		currentAlpha = xmbAlpha * lastItemAlpha
	end
	
	if currentAlpha == 0 then
		return
	end
	
	local cx = mainMenuItems[helpID].cx + 30
	if ( loadedHelp ) then
		for i = 1, #tHelp do
			local title = tHelp[i].title
			local text = tHelp[i].text
			local cy = tHelp[i].cy
			local ty = tHelp[i].ty
			
			local dist = getDistanceBetweenPoints2D(0, initY + yoffset + 40, 0, cy)
			
			local alpha = 255
			if ( cy < (initY + 2*yoffset)) then
				alpha = 255 - ( dist/ 2 )
			else
				alpha = 255 - (dist / 2)
			end
			alpha = alpha * currentAlpha
			
			-- ANIMATIONS
			if ( round(cy, -1) > round(ty, -1) ) then -- we need to move down!
				tHelp[i].cy = tHelp[i].cy - 10
			end
			
			if ( round(cy, -1) < round(ty, -1) ) then -- we need to move up!
				tHelp[i].cy = tHelp[i].cy + 10
			end
			
			local color = tocolor(255, 255, 255, alpha)
			
			dxDrawText(title, cx-10, cy, cx + dxGetTextWidth(title, 1, "default-bold"), cy + fontHeight1, color, 1, "default-bold", "center", "middle")
			dxDrawText(text, cx, cy+20, cx + dxGetTextWidth(text, 0.9), cy + 20 + fontHeight2, color, 0.9, "default", "left", "middle")
		end
	else
		dxDrawImage(cx + 5, initY + yoffset + 40, 66, 66, "gui/loading.png", loadingImageRotation, 0, 0, tocolor(255, 255, 255, currentAlpha * 150))
		loadingImageRotation = loadingImageRotation + 5
	end
end

function manageCamera()
	setControlState("change_camera", true)
end

function createXMBMain(characters)
	setCameraMatrix(1401.4228515625, -887.6865234375, 76.401107788086, 1415.453125, -811.09375, 80.234382629395)
	
	state = 2
	
	toggleAllControls(false, true, true)
	guiSetInputEnabled(false)
	bindKey("arrow_l", "down", moveLeft)
	bindKey("arrow_r", "down", moveRight)
	bindKey("arrow_u", "down", moveUp)
	bindKey("arrow_d", "down", moveDown)
	bindKey("enter", "down", selectItemFromVerticalMenu)
	toggleControl("change_camera", false)
	
	keys = getBoundKeys("change_camera")
	for name, state in pairs(keys) do
		if ( name ~= "home" ) then
			bindKey(name, "down", manageCamera)
		end
	end
	addCommandHandler("home", toggleXMB)
	bindKey("home", "down", "home")
end
addEvent("loginOK", true)
addEventHandler("loginOK", getRootElement(), createXMBMain)

function saveHelpInformation()
	tHelp = {
		{ title = "My Reports", text = "You currently have no tickets open." },
		{ title = "Reports Affecting Me", text = "You currently have no reports regarding yourself." },
		{ title = "Report a Bug", text = "Select this to report a bug directly to Mantis." }
	}
	
	for k, v in ipairs( tHelp ) do
		v.cy = initY + k * yoffset + 40
		v.ty = v.cy
	end
	
	loadedHelp = true
end

function saveLanguageInformation()
	tLanguages = { }
	for language, data in pairs( strings ) do
		table.insert( tLanguages,  { title = language, flag = data.flag, order = data.order } )
	end
	table.sort( tLanguages, function( a, b ) return a.order < b.order end )
	
	for k, v in ipairs( tLanguages ) do
		v.cy = initY + k * yoffset + 40
		v.ty = v.cy
	end
	
	loadedLanguages = true
end

function saveAccountInformation(mtausername)
	tAccount = {
		{ title = "Revert", text = "RevertSubtext" },
		{ title = "Forum", text = "ForumSubtext" },
		{ title = "Xbox", text = "XboxSubtext" },
		{ title = "Steam", text = "SteamSubtext" }
	}
	
	if ( exports.global:isPlayerScripter(getLocalPlayer()) ) then
		tAccount[#tAccount+1] = { title = "Developer", text = "DeveloperSubtext" }
	end
		
	if ( exports.global:isPlayerAdmin(getLocalPlayer()) ) then
		tAccount[#tAccount+1] = { title = "Administrator", text = "AdministratorSubtext"  }
	end
	
	if mtausername then
		mtaUsername = mtausername
	else
		MTAaccountTimer = setTimer(checkForMTAAccount, 1000, 0)
	end
	
	for k, v in ipairs( tAccount ) do
		v.cy = initY + k * yoffset + 40
		v.ty = v.cy
		v.state = 0
	end
	
	loadedAccount = true
	saveHelpInformation()
end
addEvent("storeAccountInformation", true)
addEventHandler("storeAccountInformation", getLocalPlayer(), saveAccountInformation)

function saveCharacters(characters)
	-- load the characters
	setCameraMatrix(1401.4228515625, -887.6865234375, 76.401107788086, 1415.453125, -811.09375, 80.234382629395)
	for k, v in ipairs(characters) do
		characterMenu[k] = { id = v[1], name = v[2]:gsub("_", " "), cked = v[3], lastarea = v[4], age = v[5], gender = v[6], faction = v[7] or "Not in a faction.", rank = v[8], skin = v[9], lastseen = v[10], cy = initY + k * yoffset + 40, ty = initY + k * yoffset + 40 }
	end
	
	-- CK
	if loadedCharacters and not visible and state == 3 and not fading then
		fading = true
		showXMB()
		currentCharacterID = nil
		state = 2
	end
	
	loadedCharacters = true
end
addEvent("showCharacterSelection", true)
addEventHandler("showCharacterSelection", getRootElement(), saveCharacters)

addEvent("updateName", true)
addEventHandler("updateName", getLocalPlayer(),
	function( id )
		for k, v in ipairs(characterMenu) do
			if v.id == id then
				v.name = getPlayerName(getLocalPlayer()):gsub("_", " ")
				break
			end
		end
	end
)
end
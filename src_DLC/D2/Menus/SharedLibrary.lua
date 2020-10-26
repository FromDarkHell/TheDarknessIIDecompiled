module((...), package.seeall)
TRANSITON_VIDEO_PRESS_START = 1
TRANSITON_VIDEO_MAIN_MENU = 2
TRANSITON_VIDEO_OPTIONS_1 = 3
TRANSITON_VIDEO_OPTIONS_2 = 4
TRANSITION_DESTINATON_PARENT_SCREEN = "##parent"
TRANSITION_DESTINATON_START_NEW_GAME = "##new"
TRANSITION_DESTINATON_CONTINUE_LAST_SAVE = "##continue"
TRANSITION_DESTINATON_PLAY_NEW_GAME_VIDEO = "##videonewgame"
SELECTED_COLOR = 9699586
local mGlobalMusicTrackInstance
local mFrontendGameRulesName = "AttractModeGameRules"
local mBackgroundBink
local _IsPC = function(movie)
  if movie:GetVariable("$platform") == "WINDOWS" then
    return true
  end
  return false
end
function IsPC(movie)
  return _IsPC(movie)
end
function IsPS3(movie)
  if movie:GetVariable("$platform") == "PS3" then
    return true
  end
  return false
end
function IsXbox360(movie)
  if movie:GetVariable("$platform") == "XBOX360" then
    return true
  end
  return false
end
function IsInFrontend()
  local gameRules = gRegion:GetGameRules()
  return not IsNull(gameRules) and gameRules:GetResourceName() == mFrontendGameRulesName
end
local function _StopBackgroundBink()
  if not IsNull(mBackgroundBink) then
    gRegion:StopVideoTexture(mBackgroundBink)
    mBackgroundBink = nil
  end
end
function StopBackgroundBink()
  _StopBackgroundBink()
end
function PlayBackgroundBink(movie, binkTexture)
  _StopBackgroundBink()
  mBackgroundBink = binkTexture
  movie:SetTexture("BinkPlaceholder.png", mBackgroundBink)
  gRegion:StartVideoTexture(mBackgroundBink)
end
function GetActiveControllerIndex(movie)
  local controllerNum = gFlashMgr:GetExclusiveDeviceID()
  if not IsNull(movie) and _IsPC(movie) then
    controllerNum = 0
  end
  return controllerNum
end
function ListClassVerticalScroll(movie, listClass, dir)
  movie:ResetButtons()
  dir = tonumber(dir)
  local numElements = tonumber(movie:GetVariable(string.format("%s.ListClass.numElements", listClass)))
  if numElements == nil then
    return false
  end
  if numElements <= 1 then
    return true
  end
  local curScrollPos = tonumber(movie:GetVariable(string.format("%s.ListClass.mScrollPos", listClass)))
  local curSelection = tonumber(movie:GetVariable(string.format("%s.ListClass.mCurrentSelection", listClass)))
  local numLabels = tonumber(movie:GetVariable(string.format("%s.ListClass.numLabels", listClass)))
  local maxSize = math.min(numLabels, numElements)
  local isWrapEnabled = movie:GetVariable(string.format("%s.ListClass.mIsWrapEnabled", listClass))
  if isWrapEnabled == nil then
    isWrapEnabled = true
  else
    isWrapEnabled = isWrapEnabled == "true"
  end
  if curSelection < 0 then
    if numElements <= numLabels then
      FlashMethod(movie, string.format("%s.ListClass.SetSelected", listClass), 0)
    else
      FlashMethod(movie, string.format("%s.ListClass.WrapToTop", listClass))
    end
    FlashMethod(movie, string.format("%s.ListClass.Selected", listClass), 0)
    return true
  elseif curSelection > numLabels then
    local newSelection = numElements - 1
    if numElements <= numLabels then
      FlashMethod(movie, string.format("%s.ListClass.SetSelected", listClass), newSelection)
    else
      FlashMethod(movie, string.format("%s.ListClass.WrapToBottom", listClass))
      newSelection = numLabels - 1
    end
    FlashMethod(movie, string.format("%s.ListClass.Selected", listClass), newSelection)
    return true
  end
  if dir == -1 then
    if curSelection == 0 then
      if 0 < curScrollPos then
        FlashMethod(movie, string.format("%s.ListClass.ScrollUp", listClass))
      elseif curScrollPos == 0 then
        if numElements <= numLabels then
          local newSelection = numElements - 1
          FlashMethod(movie, string.format("%s.ListClass.SetSelected", listClass), newSelection)
          FlashMethod(movie, string.format("%s.ListClass.Selected", listClass), newSelection)
        elseif isWrapEnabled then
          FlashMethod(movie, string.format("%s.ListClass.WrapToBottom", listClass))
        end
      end
      return true
    else
      local newSelection = Clamp(curSelection + dir, 0, numElements - 1)
      FlashMethod(movie, string.format("%s.ListClass.SetSelected", listClass), newSelection)
    end
  elseif dir == 1 then
    if curSelection + dir == numLabels and 1 < numElements then
      if curSelection + curScrollPos + 1 ~= numElements then
        FlashMethod(movie, string.format("%s.ListClass.ScrollDown", listClass))
        return true
      else
        if isWrapEnabled then
          FlashMethod(movie, string.format("%s.ListClass.WrapToTop", listClass))
        end
        return true
      end
    elseif numElements <= curSelection + dir then
      if isWrapEnabled then
        FlashMethod(movie, string.format("%s.ListClass.WrapToTop", listClass))
      end
      return true
    else
      FlashMethod(movie, string.format("%s.ListClass.SetSelected", listClass), curSelection + dir)
    end
  end
  return false
end
function DropDownClassVerticalScroll(movie, listClass, dir)
  local curScrollPos = tonumber(movie:GetVariable(string.format("%s.ListClass.mScrollPos", listClass)))
  local curSelection = tonumber(movie:GetVariable(string.format("%s.ListClass.mCurrentSelection", listClass)))
  local numLabels = tonumber(movie:GetVariable(string.format("%s.ListClass.numLabels", listClass)))
  local numElements = tonumber(movie:GetVariable(string.format("%s.ListClass.numElements", listClass)))
  local maxSize = math.min(numLabels, numElements)
  if numElements <= 1 then
    return true
  end
  local scrubberPos = 0
  scrubberPos = curSelection + curScrollPos + dir
  scrubberPos = Clamp(scrubberPos, 0, numElements)
  FlashMethod(movie, "Resolution.ScrollBarClass.SetRange", numElements - 1)
  FlashMethod(movie, "Resolution.ScrollBarClass.SetScrubberPos", scrubberPos)
  print(string.format("dir=%i, curSelection=%i, numLabels=%i, numElements=%i, curScrollPos=%i scrubberPos=%i", dir, curSelection, numLabels, numElements, curScrollPos, scrubberPos))
  if dir == -1 then
    if curSelection == 0 then
      if 0 < curScrollPos then
        FlashMethod(movie, string.format("%s.ListClass.ScrollUp", listClass))
      elseif curScrollPos == 0 then
      end
      return true
    end
  elseif dir == 1 then
    if curSelection + dir == numLabels and 1 < numElements then
      if curSelection + curScrollPos + 1 ~= numElements then
        FlashMethod(movie, string.format("%s.ListClass.ScrollDown", listClass))
        return true
      else
        return true
      end
    elseif numElements <= curSelection + dir then
      return true
    end
  end
  return false
end
function GridClassScroll(movie, gc, xDir, yDir)
  local retVal = false
  if xDir ~= 0 then
    local xOffset = tonumber(movie:GetVariable(string.format("%s.GridClass.mItemOffsetX", gc)))
    local xSelected = tonumber(movie:GetVariable(string.format("%s.GridClass.mSelectedX", gc)))
    local xDim = tonumber(movie:GetVariable(string.format("%s.GridClass.mDimensionX", gc)))
    local xClip = tonumber(movie:GetVariable(string.format("%s.GridClass.mClipDimensionX", gc)))
    if xDir == -1 then
      if xSelected + xDir < 0 then
        retVal = true
        xDir = 0
      elseif xSelected - xOffset + xDir < 0 then
        retVal = true
      else
        xDir = 0
      end
    elseif xDir == 1 then
      if xDim <= xSelected + xDir then
        retVal = true
        xDir = 0
      elseif xClip <= xSelected - xOffset + xDir then
        retVal = true
      else
        xDir = 0
      end
    end
  end
  if yDir ~= 0 then
    local yOffset = tonumber(movie:GetVariable(string.format("%s.GridClass.mItemOffsetY", gc)))
    local ySelected = tonumber(movie:GetVariable(string.format("%s.GridClass.mSelectedY", gc)))
    local yDim = tonumber(movie:GetVariable(string.format("%s.GridClass.mDimensionY", gc)))
    local yClip = tonumber(movie:GetVariable(string.format("%s.GridClass.mClipDimensionY", gc)))
    if yDir == -1 then
      if ySelected == -1 and 0 < yOffset + yDir and 0 < yOffset + yDir then
      elseif ySelected + yDir < 0 then
        retVal = true
        yDir = 0
      elseif ySelected - yOffset + yDir < 0 then
        retVal = true
      else
        yDir = 0
      end
    elseif yDir ~= 1 or ySelected == -1 and yOffset + yDir < yClip - 1 and yOffset + yDir < yDim - 1 then
    elseif yDim <= ySelected + yDir then
      retVal = true
      yDir = 0
    elseif yClip <= ySelected - yOffset + yDir then
      retVal = true
    else
      yDir = 0
    end
  end
  FlashMethod(movie, string.format("%s.GridClass.Scroll", gc), xDir, yDir)
  return retVal
end
function StringTokenize(text, delimiter)
  local tokenList = {}
  local numDelimiters = 0
  if delimiter == nil then
    return tokenList
  end
  numDelimiters = string.len(delimiter)
  if numDelimiters == 0 then
    return tokenList
  end
  if text == nil then
    return tokenList
  end
  local length = string.len(text)
  if length == 0 then
    return tokenList
  end
  local start = 1
  for i = start, length do
    local foundCharacter = false
    for j = 1, numDelimiters do
      if string.byte(text, i) == string.byte(delimiter, j) and start ~= 0 then
        local str = string.sub(text, start, i - 1)
        tokenList[#tokenList + 1] = str
        start = 0
        foundCharacter = true
        break
      end
    end
    if not foundCharacter and start == 0 then
      start = i
    end
  end
  if start ~= 0 then
    local str = string.sub(text, start, length)
    tokenList[#tokenList + 1] = str
  end
  return tokenList
end
function GetLocalizedMapName(mapName)
  if mapName ~= "" then
    local desrever = string.reverse(mapName)
    local strEnd = string.find(desrever, "/")
    local strSub = string.sub(desrever, 0, strEnd - 1)
    desrever = string.reverse(strSub)
    local strStart = string.find(desrever, ".level")
    strSub = string.sub(desrever, 0, strStart - 1)
    mapName = string.format("/D2/Language/MPGame/RegionName_%s", strSub)
  end
  return mapName
end
function StringNumberFormat(s, separatorChar)
  if s == nil then
    return ""
  end
  local len = string.len(s)
  local rev = string.reverse(s)
  local w = ""
  for i = 1, len do
    local sub = string.sub(rev, i, i)
    w = w .. sub
    if i % 3 == 0 and i ~= len then
      w = w .. separatorChar
    end
  end
  local fs = string.reverse(w)
  return fs
end
function IsPCInputDevice(device)
  return device < 0 or 100 < device
end
function StringTimeFormat(t, fmt, separatorChar)
  if t == nil then
    return ""
  end
  if fmt == nil then
    fmt = "hms"
  end
  if separatorChar == nil then
    separatorChar = ":"
  end
  t = tonumber(t)
  local elements = {}
  if string.find(fmt, "h") ~= nil then
    local v = 0
    if 3600 <= t then
      v = t / 3600 - t % 3600
    end
    elements[#elements + 1] = v
  end
  if string.find(fmt, "m") ~= nil then
    local v = 0
    if 60 <= t then
      v = math.floor(t / 60)
    end
    elements[#elements + 1] = v
  end
  if string.find(fmt, "s") ~= nil then
    local v = 0
    if 0 < t then
      v = t % 60
    end
    elements[#elements + 1] = v
  end
  local text = ""
  for i = 1, #elements do
    text = text .. string.format("%02i", elements[i])
    if i + 1 <= #elements then
      text = text .. separatorChar
    end
  end
  return text
end
function GetBaseMapName(mapName)
  if mapName ~= "" then
    local desrever = string.reverse(mapName)
    local strBeg = string.find(desrever, "/")
    local strEnd = string.find(desrever, "/", strBeg + 1)
    local strSub = string.sub(desrever, strBeg + 1, strEnd - 1)
    mapName = string.reverse(strSub)
  end
  return mapName
end
function GetGradeMCFromValue(grade)
  local mapping = {}
  if 0 < grade then
    mapping[1] = "DMinus"
    mapping[2] = "D"
    mapping[3] = "DPlus"
    mapping[4] = "CMinus"
    mapping[5] = "C"
    mapping[6] = "CPlus"
    mapping[7] = "BMinus"
    mapping[8] = "B"
    mapping[9] = "BPlus"
    mapping[10] = "AMinus"
    mapping[11] = "A"
    mapping[12] = "APlus"
    mapping[13] = "S"
    return mapping[grade]
  end
  return ""
end
function DoScreenTransition(currentScreenInstance, destinationScreenName, transitionScreenRes, transitionVideoIndex)
  local transitionInstance = currentScreenInstance:PushChildMovie(transitionScreenRes)
  transitionInstance:Execute("PlayTransition", destinationScreenName .. "," .. tostring(transitionVideoIndex))
end
function PlayGlobalMusicTrack(musicResource)
  if IsNull(mGlobalMusicTrackInstance) then
    mGlobalMusicTrackInstance = gRegion:PlaySound(musicResource, Vector(), false)
  end
end
function StopGlobalMusicTrack()
  if not IsNull(mGlobalMusicTrackInstance) then
    mGlobalMusicTrackInstance:Stop(true)
  end
  mGlobalMusicTrackInstance = nil
end
function GetGlobalMusicTrackGain()
  if not IsNull(mGlobalMusicTrackInstance) then
    return (mGlobalMusicTrackInstance:GetMixedGain())
  end
  return 0
end
function SetGlobalMusicTrackGain(newVolume)
  if not IsNull(mGlobalMusicTrackInstance) then
    return (mGlobalMusicTrackInstance:SetGain(newVolume))
  end
end
function GetDifficultyTable()
  local difficultyTable = {
    {
      name = "/D2/Language/Menu/Options_Game_Difficulty_VeryEasy",
      description = "/D2/Language/Menu/Options_Game_Difficulty_VeryEasy_Description",
      difficulty = 0
    },
    {
      name = "/D2/Language/Menu/Options_Game_Difficulty_Easy",
      description = "/D2/Language/Menu/Options_Game_Difficulty_Easy_Description",
      difficulty = 1
    },
    {
      name = "/D2/Language/Menu/Options_Game_Difficulty_Medium",
      description = "/D2/Language/Menu/Options_Game_Difficulty_Medium_Description",
      difficulty = 2
    },
    {
      name = "/D2/Language/Menu/Options_Game_Difficulty_Hard",
      description = "/D2/Language/Menu/Options_Game_Difficulty_Hard_Description",
      difficulty = 4
    }
  }
  return difficultyTable
end
function InviteFriends()
  local gameInviteSubject = "/D2/Language/MPGame/GameInviteSubject"
  local gameInviteMessage = "/D2/Language/MPGame/GameInviteMessage"
  local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  Engine.GetMatchingService():ShowSystemGameInviteUI(playerProfile, gameInviteSubject, gameInviteMessage)
end
local function _FormatPlayerName(movie, name)
  if _IsPC(movie) then
    local maxLength = 16
    if name ~= nil and maxLength < string.len(name) then
      name = string.sub(name, 0, maxLength) .. "..."
    end
  end
  return name
end
function FormatPlayerName(movie, name)
  return _FormatPlayerName(movie, name)
end
local _PartyListUpdateSelection = function(movie, partyList)
  partyList.curIndex = Clamp(partyList.curIndex, 0, #partyList.members - 1)
  if partyList.enabled then
    FlashMethod(movie, "PartyList.OptionList.ListClass.SetSelected", partyList.curIndex)
  end
  return partyList
end
local function _PartyListSetEnabled(movie, partyList, enabled)
  FlashMethod(movie, "PartyList.OptionList.ListClass.SetEnabled", enabled)
  partyList.enabled = enabled
  return _PartyListUpdateSelection(movie, partyList)
end
function PartyListSetEnabled(movie, partyList, enabled)
  return _PartyListSetEnabled(movie, partyList, enabled)
end
function PartyListDisplayMemberInfo(partyList)
  local selectionInfo = partyList.members[partyList.curIndex + 1]
  if selectionInfo == nil then
    return
  end
  if partyList.isInGameplay then
    if not IsNull(selectionInfo.humanPlayer) then
      Engine.GetMatchingService():DisplayHumanPlayerInfo(selectionInfo.humanPlayer)
    end
  else
    local name = selectionInfo.name
    local id = Engine.GetMatchingService():GetOnlineIdForPartyMember(name)
    Engine.GetMatchingService():DisplayPlayerInfo(id)
  end
end
function PartyListInitialize(movie, _inGameplay)
  if _inGameplay == nil then
    _inGameplay = false
  end
  local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  local isOnline = not IsNull(Engine.GetMatchingService():GetPartySession())
  if isOnline or _inGameplay then
    movie:SetLocalized("PartyList.Title.text", "/D2/Language/Menu/PartyList_Title_Windows")
  end
  movie:SetVariable("PartyList._visible", isOnline or _inGameplay)
  movie:SetVariable("PartyList.Title._enabled", false)
  FlashMethod(movie, "PartyList.OptionList.ListClass.SetSelectedCallback", "PartyListButtonSelected")
  FlashMethod(movie, "PartyList.OptionList.ListClass.SetPressedCallback", "PartyListButtonPressed")
  FlashMethod(movie, "PartyList.OptionList.ListClass.SetAlignment", "left")
  for i = 1, 8 do
    FlashMethod(movie, "PartyList.OptionList.ListClass.AddItem", " ")
  end
  movie:SetVariable("PartyList.OptionList.ListClass.numElements", 0)
  local partyList = {
    timer = -1,
    timerDone = 1,
    members = {},
    enabled = false,
    isInGameplay = _inGameplay,
    curIndex = -1
  }
  partyList.members = {}
  partyList = _PartyListSetEnabled(movie, partyList, false)
  return partyList
end
function PartyListGetStatusOptions(isPartyClient, enableKick)
  if enableKick ~= nil and enableKick then
    return {
      "/D2/Language/MPGame/Shared_ViewPlayer_Windows",
      "/D2/Language/MPGame/Shared_InviteToParty",
      "/D2/Language/MPGame/Shared_PlayerList_Kick",
      "/D2/Language/MPGame/Shared_PlayerList_Back"
    }
  elseif isPartyClient then
    return {
      "/D2/Language/MPGame/Shared_ViewPlayer_Windows",
      "/D2/Language/MPGame/Shared_InviteToParty",
      "/D2/Language/Menu/Shared_Back"
    }
  else
    return {
      "/D2/Language/MPGame/Shared_ViewPlayer_Windows",
      "/D2/Language/MPGame/Shared_InviteToParty",
      "/D2/Language/MPGame/Shared_PlayerList_Back"
    }
  end
end
local _PartyListCanKick = function(partyList)
  local humanPlayers = gRegion:GetHumanPlayers()
  if IsNull(humanPlayers) then
    return false
  end
  if #humanPlayers == 0 then
    return false
  end
  local human = humanPlayers[partyList.curIndex + 1]
  return not IsNull(human) and not human:IsLocal()
end
function PartyListCanKick(partyList)
  return _PartyListCanKick(partyList)
end
function PartyListUpdateKickStatus(partyList, movie)
  local isAvailable = _PartyListCanKick(partyList)
  FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByName", "/D2/Language/MPGame/Shared_PlayerList_Kick", isAvailable)
end
function PartyListKick(partyList)
  if _PartyListCanKick(partyList) then
    local humanPlayers = gRegion:GetHumanPlayers()
    local human = humanPlayers[partyList.curIndex + 1]
    Engine.GetMatchingService():DisconnectPlayer(human)
  end
end
function PartyListUpdate(movie, rdt, partyList)
  if partyList == nil then
    return partyList
  end
  partyList.timer = partyList.timer - rdt
  if partyList.timer > 0 then
    return partyList
  end
  partyList.timer = partyList.timerDone
  local hostName = ""
  local session = Engine.GetMatchingService():GetSession()
  if not IsNull(session) then
    hostName = session:GetHostName()
  end
  local playerList = {}
  if partyList.isInGameplay then
    local humanPlayers = gRegion:GetHumanPlayers()
    local numHumanPlayers = #humanPlayers
    for i = 1, numHumanPlayers do
      local theHumanPlayer = humanPlayers[i]
      local thePlayerName = theHumanPlayer:GetPlayerName()
      local theHostString = ""
      if thePlayerName == hostName then
        theHostString = movie:GetLocalized("<Host>")
      end
      local theAvatar = theHumanPlayer:GetAvatar()
      local theAvatarName = ""
      if not IsNull(theAvatar) then
        local theName = theAvatar:GetName()
        if string.find(theName, "TransitionAvatar") == nil then
          theAvatarName = string.format("<%s>", theName)
          theAvatarName = movie:GetLocalized(theAvatarName)
        end
      end
      local theFriendlyName = theAvatarName .. " " .. _FormatPlayerName(movie, thePlayerName) .. " " .. theHostString
      playerList[#playerList + 1] = {
        name = thePlayerName,
        friendlyName = theFriendlyName,
        humanPlayer = theHumanPlayer,
        avatar = theAvatar
      }
    end
  else
    local partyList = Engine.GetMatchingService():GetPartyMemberList()
    if not IsNull(partyList) then
      for i = 1, #partyList do
        local thePlayerName = partyList[i]
        local theHostString = ""
        if thePlayerName == hostName then
          thePlayerName = thePlayerName .. " " .. movie:GetLocalized("<Host>")
        end
        playerList[#playerList + 1] = {
          name = thePlayerName,
          friendlyName = thePlayerName,
          humanPlayer = nil,
          avatar = nil
        }
      end
    end
  end
  local isDifferent = false
  local numPlayers = #playerList
  local prevNumPlayers = #partyList.members
  if numPlayers ~= prevNumPlayers then
    isDifferent = true
  else
    for i = 1, #playerList do
      if playerList[i].friendlyName ~= partyList.members[i].friendlyName then
        isDifferent = true
        break
      end
    end
  end
  if isDifferent then
    for i = 1, 4 do
      local friendlyName = ""
      if i <= #playerList then
        friendlyName = playerList[i].friendlyName
      end
      FlashMethod(movie, "PartyList.OptionList.ListClass.SetItem", i - 1, friendlyName, true)
    end
    movie:SetVariable("PartyList.OptionList.ListClass.numElements", numPlayers)
    partyList.members = playerList
    partyList = _PartyListUpdateSelection(movie, partyList)
  end
  return partyList
end
local _BannerSpinner = function(movie, banner)
  if banner.spinner then
    local curFrame = tonumber(movie:GetVariable("Banner.Container.Spinner._currentframe"))
    if curFrame == 1 then
      FlashMethod(movie, "Banner.Container.Spinner.gotoAndPlay", "Play")
    end
  else
    FlashMethod(movie, "Banner.Container.Spinner.gotoAndStop", "Init")
  end
  FlashMethod(movie, "Banner.Container.Spinner._visible", banner.spinner)
end
function BannerSpinner(movie, banner)
  _BannerSpinner(movie, banner)
end
local _BannerLine = function(movie, banner)
  local frame = "Single"
  if banner.line == banner.LINE_Double then
    frame = "Double"
  end
  FlashMethod(movie, "Banner.Container.gotoAndStop", frame)
end
function BannerLine(movie, banner)
  _BannerLine(movie, banner)
end
function BannerInitialize(movie)
  local banner = {
    state = "",
    loc = "",
    text = "",
    line = 0,
    spinner = false,
    STATE_Show = "Show",
    STATE_Hide = "Hide",
    STATE_FadeIn = "FadeIn",
    STATE_FadeOut = "FadeOut",
    LINE_Single = 0,
    LINE_Double = 1
  }
  banner.state = banner.STATE_Hide
  FlashMethod(movie, "Banner.gotoAndStop", banner.state)
  banner.line = banner.LINE_Single
  _BannerLine(movie, banner)
  FlashMethod(movie, "Banner.Container.Spinner._visible", false)
  _BannerSpinner(movie, banner)
  return banner
end
local _BannerSetText = function(movie, banner)
  if banner.loc ~= "" then
    movie:SetLocalized("Banner.Container.Text.text", banner.loc)
  elseif banner.text ~= "" then
    movie:SetVariable("Banner.Container.Text.text", banner.text)
  end
end
function BannerSetText(movie, banner)
  _BannerSetText(movie, banner)
end
function BannerDisplay(movie, banner)
  FlashMethod(movie, "Banner.gotoAndPlay", banner.state)
  _BannerLine(movie, banner)
  _BannerSpinner(movie, banner)
  _BannerSetText(movie, banner)
end
function BannerIsVisible(banner)
  return banner.state == banner.STATE_FadeIn or banner.state == banner.STATE_Show
end
function StyleTextSet(movie, text)
  if text ~= nil and text ~= "" then
    movie:SetLocalized("StyleText.TextHolder.Text.text", text)
    local messageX = movie:GetVariable("StyleText._x")
    local messageTextWidth = tonumber(movie:GetVariable("StyleText.TextHolder.Text.textWidth"))
    local messageTextLength = messageTextWidth * 2
    local gougeAnims = {
      0,
      1024,
      512,
      128,
      64
    }
    local gougeIndex = 1
    local gougeAnim = 0
    if 640 < messageTextWidth then
      gougeIndex = 2
    elseif 384 < messageTextWidth then
      gougeIndex = 3
    elseif 128 <= messageTextWidth then
      gougeIndex = 4
    else
      gougeIndex = 5
    end
    FlashMethod(movie, "StyleText.gotoAndPlay", "FadeIn")
    for i = 1, 5 do
      local gougeAnim = gougeAnims[i]
      if i == gougeIndex then
        local spacing = 40
        local newX = 560 - messageTextWidth / 2 - messageX
        movie:SetVariable(string.format("StyleText.Gouge%i._width", gougeAnim), messageTextWidth + spacing)
        movie:SetVariable(string.format("StyleText.Gouge%i._x", gougeAnim), newX - spacing / 2)
        FlashMethod(movie, string.format("StyleText.Gouge%i.gotoAndPlay", gougeAnim), "Play")
      else
        FlashMethod(movie, string.format("StyleText.Gouge%i.gotoAndStop", gougeAnim), "Default")
      end
    end
  else
    FlashMethod(movie, "StyleText.gotoAndStop", "Default")
  end
end
local _GridGetItemName = function(baseName, x, y)
  return string.format("%s_Item%dx%d", baseName, x, y)
end
function GridGetItemName(baseName, x, y)
  return _GridGetItemName(baseName, x, y)
end

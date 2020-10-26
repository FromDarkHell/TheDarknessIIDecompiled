local LIB = require("D2.Menus.SharedLibrary")
itemDisplayOptionsMovie = Resource()
itemMultiPlayerMovie = Resource()
itemOptionsMovie = Resource()
itemCreditsMovie = Resource()
popupConfirmMovie = WeakResource()
offlineMultiplayerLevel = WeakResource()
offlineMultiplayerGameRules = WeakResource()
demoGameRules = WeakResource()
demoGameRulesPAX = WeakResource()
demoLevels = {
  WeakResource()
}
demoLevelsPAX = {
  WeakResource()
}
transitionMovie = Resource()
transitionDelay = 1
pressStartMovie = WeakResource()
preloadedMovie = {
  Resource()
}
cmdQuit = Resource()
rollOverSound = Resource()
pressSound = Resource()
binkTexture = Resource()
music = Resource()
local isSigningInForMuliplayer = false
local hasLoggedMpTransitionError = false
local SCREENSTATE_SelectingMain = 0
local SCREENSTATE_SelectingDifficulty = 1
local SCREENSTATE_SelectingMap = 2
local SCREENSTATE_SelectingBeginOrChapSelect = 3
local SCREENSTATE_SelectingNewGameMap = 4
local itemSinglePlayer = "/D2/Language/Menu/MainMenu_Item_SinglePlayer"
local itemNewGamePlus = "/D2/Language/Menu/MainMenu_Item_NewGamePlus"
local itemContinue = "/D2/Language/Menu/MainMenu_Item_Continue"
local itemMultiPlayer = "/D2/Language/Menu/MainMenu_Item_MultiPlayer"
local itemDLC = "/D2/Language/Menu/MainMenu_Item_DLC"
local itemOptions = "/D2/Language/Menu/MainMenu_Item_Options"
local itemCredits = "/D2/Language/Menu/MainMenu_Item_Credits"
local itemQuit = "/D2/Language/Menu/MainMenu_Item_Quit"
local itemDarkness1 = "/D2/Language/Menu/MainMenu_Item_Darkness1"
local itemFromBeginning = "/D2/Language/Menu/MainMenu_FromTheBeginning"
local itemChapterSelect = "/D2/Language/Menu/MainMenu_ChapterSelect"
local itemList = {}
local popupItemOk = "/D2/Language/Menu/Confirm_Item_Ok"
local popupItemCancel = "/D2/Language/Menu/Confirm_Item_Cancel"
local confirmItemSignIn = "/D2/Language/Menu/MainMenu_Request_SignIn_Option_SignIn"
local confirmItemOffline = "/D2/Language/Menu/MainMenu_Request_SignIn_Option_Play_Offline"
local confirmItemOnline = "/D2/Language/Menu/MainMenu_Request_SignIn_Option_Play_Online"
local confirmItemBack = "/D2/Language/Menu/MainMenu_Cancel"
local confirmList = {
  confirmItemSignIn,
  confirmItemOffline,
  confirmItemBack
}
local confirmListOnline = {
  confirmItemOnline,
  confirmItemOffline,
  confirmItemBack
}
local statusSaveProfile = "/D2/Language/Menu/MainMenu_Status_SaveProfile"
local statusClearProfile = "/D2/Language/Menu/MainMenu_Status_ClearProfile"
local statusMapList = "/D2/Language/Menu/MainMenu_Status_MapList"
local statusSelect = "/D2/Language/Menu/Shared_Select"
local statusBack = "/D2/Language/Menu/Shared_Back"
local statusList = {statusSelect, statusBack}
local gameHosted = false
local popupMovie, movieInstance, mMultiplayerPopupMovie
local mHasSaveGame = false
local mDifficultyTable
local mItemSelected = 0
local mScreenState = 0
local mScreenStatePrevious = 0
local mIsPreloadCheckDone = false
local mQueuedTransitionToMP = false
local mIsPresenceUpdateRequired = true
local mDarkness1ExeName = "D1.BIN"
local mAllowInputTimer = -1
local mNewGamePlusChapter = ""
local mNewGamePlusSelection = 0
local mNewGamePlusCompletionInfo = {}
local mMPLoginFailureMessage = "/Multiplayer/ValidOnlineProfileRequired_Windows"
function Shutdown()
  LIB.StopGlobalMusicTrack()
end
local function ClosePopup()
  if not IsNull(popupMovie) then
    popupMovie:Close()
  end
  popupMovie = nil
end
function CloseActivePopup()
  ClosePopup()
end
local UpdateStrike = function(movie, strikeIdx, isCompleted)
  movie:SetVariable(string.format("Strikes.ObjStrike%i._visible", strikeIdx), isCompleted)
  if isCompleted then
    local textWidth = movie:GetVariable(string.format("OptionList.ButtonLabel%i.TxtHolder.Txt.textWidth", strikeIdx))
    movie:SetVariable(string.format("Strikes.ObjStrike%i._width", strikeIdx), textWidth)
  end
end
local function SetupChapterStrikes(movie)
  for i = 0, 7 do
    UpdateStrike(movie, i, false)
  end
end
local ReturnToPressStart = function(movie)
  if not IsNull(pressStartMovie) then
    gFlashMgr:CloseAllMovies()
    gFlashMgr:GotoMovie(pressStartMovie)
    movie:Close()
  end
end
local LoadLevel = function(theLevel)
  local openArgs = Engine.OpenLevelArgs()
  openArgs:SetLevel(theLevel)
  openArgs.saveOnStart = true
  openArgs.migrateServer = false
  for i = 1, #demoLevels do
    if theLevel == demoLevels[i]:GetResourceName() then
      openArgs:SetGameRules(demoGameRules:GetResourceName())
      break
    end
  end
  for i = 1, #demoLevelsPAX do
    if theLevel == demoLevelsPAX[i]:GetResourceName() then
      openArgs:SetGameRules(demoGameRulesPAX:GetResourceName())
      break
    end
  end
  Engine.GetMatchingService():DisableSessionReconnect()
  gFlashMgr:CloseAllMovies()
  Engine.OpenLevel(openArgs)
end
function ConfirmMultiplayerListButtonPressed(movie, buttonArg)
  local idx = tonumber(buttonArg)
  gRegion:PlaySound(pressSound, Vector(), false)
  if not IsNull(mMultiplayerPopupMovie) then
    local profile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
    if not IsNull(profile) then
      local profileData = profile:GetGameSpecificData()
      if not IsNull(profileData) then
        if idx == 0 then
          Engine.GetPlayerProfileMgr():LogIn(1, true, true, LIB.GetActiveControllerIndex(movie), "OnLoginForMultiplayerComplete")
        elseif idx == 1 then
          profileData:SetPlayingOfflineMP(true)
          Engine.GetPlayerProfileMgr():SetOnlineConnectionRequired(false)
          LIB.DoScreenTransition(movie, itemMultiPlayerMovie:GetResourceName(), transitionMovie, LIB.TRANSITON_VIDEO_MAIN_MENU)
        end
      end
    end
    mMultiplayerPopupMovie:Close()
    mMultiplayerPopupMovie = nil
  end
  return 1
end
function ConfirmListButtonSelected(movie, buttonArg)
  gRegion:PlaySound(rollOverSound, Vector(), false)
end
function ConfirmListButtonUnselected(movie, buttonArg)
end
function QuitConfirm(movie, args)
  if tonumber(args) == 0 then
    gFlashMgr:ExecuteToolMenuCommand(cmdQuit)
  end
end
function Darkness1Confirm(movie, args)
  if tonumber(args) == 0 then
    local d1Path = GetExecutableDir() .. "\\" .. mDarkness1ExeName
    LaunchExecutable(d1Path)
  end
end
local function UpdateDifficultyBox(movie, selectedItem)
  local desc = mDifficultyTable[selectedItem + 1].description
  movie:SetLocalized("DifficultyDescription.Text.text", desc)
  local y = movie:GetVariable("OptionList._y")
  movie:SetVariable("DifficultyDescription._y", y + movie:GetVariable(string.format("OptionList.ButtonLabel%i._y", selectedItem)))
end
local function InitDifficultyItems(movie)
  mScreenState = SCREENSTATE_SelectingDifficulty
  FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByName", statusBack, true)
  mDifficultyTable = LIB.GetDifficultyTable()
  itemList = {}
  FlashMethod(movie, "OptionList.ButtonLabel0.gotoAndStop", "NoFocus")
  FlashMethod(movie, "OptionList.ListClass.EraseItems", "")
  for i = 1, #mDifficultyTable do
    FlashMethod(movie, "OptionList.ListClass.AddItem", mDifficultyTable[i].name)
    itemList[i] = mDifficultyTable[i].name
  end
  movie:SetVariable("OptionList.ListClass.mCurrentSelection", 1)
  FlashMethod(movie, "OptionList.ListClass.SetSelected", 1)
  UpdateDifficultyBox(movie, 1)
  local completionText = ""
  if 0 < mNewGamePlusSelection then
    local rank = mNewGamePlusCompletionInfo[mNewGamePlusSelection] - 1
    if 0 <= rank then
      local difficultyTable = LIB.GetDifficultyTable()
      local strFmt = movie:GetLocalized("/D2/Language/Menu/MainMenu_BestCompleted")
      for i = 1, #difficultyTable do
        if difficultyTable[i].difficulty == rank then
          local strDifficulty = movie:GetLocalized(difficultyTable[i].name)
          completionText = string.format(strFmt, strDifficulty)
          break
        end
      end
    end
  end
  movie:SetVariable("NewGameChapterCompletion.text", completionText)
end
local function InitBeginOrChapSelect(movie)
  mScreenState = SCREENSTATE_SelectingBeginOrChapSelect
  FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByName", statusBack, true)
  mNewGamePlusChapter = ""
  itemList = {}
  FlashMethod(movie, "OptionList.ListClass.EraseItems", "")
  Sleep(0.1)
  FlashMethod(movie, "OptionList.ListClass.AddItem", itemFromBeginning)
  itemList[0] = itemFromBeginning
  FlashMethod(movie, "OptionList.ListClass.AddItem", itemChapterSelect)
  itemList[1] = itemChapterSelect
  FlashMethod(movie, "OptionList.ListClass.SetSelected", 0)
end
local function InitNewGameMaps(movie)
  mScreenState = SCREENSTATE_SelectingNewGameMap
  FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByName", statusBack, true)
  mNewGamePlusChapter = ""
  itemList = {}
  FlashMethod(movie, "OptionList.ListClass.EraseItems", "")
  Sleep(0.1)
  local profile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  mNewGamePlusSelection = 0
  mNewGamePlusCompletionInfo = {}
  local numChapters = gGameConfig:GetNumChapters()
  for i = 0, numChapters - 1 do
    local chapterName = tostring(gGameConfig:GetChapterName(i))
    chapterName = movie:GetLocalized(chapterName)
    local rank = -1
    if not IsNull(profile) then
      local profileData = profile:GetGameSpecificData()
      if not IsNull(profileData) then
        rank = profileData:GetNewGamePlusLevelCompletion(i)
      end
    end
    mNewGamePlusCompletionInfo[i + 1] = rank
    FlashMethod(movie, "OptionList.ListClass.AddItem", chapterName)
    itemList[i] = gGameConfig:GetChapterLevel(i)
  end
  FlashMethod(movie, "OptionList.ListClass.SetSelected", 0)
end
local function InitMaps(movie)
  local defaultGameRules = gGameConfig:GetDefaultGameRules()
  local demoLevels = defaultGameRules.mLevels
  local levelNames = demoLevels:GetLevelNames(false)
  FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByName", statusBack, false)
  if levelNames ~= nil then
    FlashMethod(movie, "OptionList.ListClass.EraseItems", "")
    for i = 1, #levelNames do
      local levelName = levelNames[i]
      local levelNameTokenList = LIB.StringTokenize(levelName, "/")
      if 1 < #levelNameTokenList then
        levelName = levelNameTokenList[#levelNameTokenList]
      end
      FlashMethod(movie, "OptionList.ListClass.AddItem", levelName, true)
    end
  end
end
local BeginLevelPreload = function()
  local streamLevelName = ""
  if Engine.GetPlayerProfileMgr():ScriptIsSaveGameAvailable() then
    streamLevelName = Engine.GetPlayerProfileMgr():ScriptGetLastSaveGameLevelName()
  else
    local defaultGameRules = gGameConfig:GetDefaultGameRules()
    local levels = defaultGameRules.mLevels
    local levelNames = levels:GetLevelNames(false)
    streamLevelName = levelNames[1]
  end
  if streamLevelName ~= "" then
    print("Main Menu: preloading " .. streamLevelName)
    local openArgs = Engine.OpenLevelArgs()
    openArgs:SetLevel(streamLevelName)
    local defaultGameRules = gGameConfig:GetDefaultGameRules()
    openArgs:SetGameRules(defaultGameRules:GetGameRulesType())
    Engine.StreamRegion(openArgs)
  end
end
local UpdateStrikeAlpha = function(movie, missionIdx, isSelected)
  local animToPlay = "FadeIn"
  if isSelected then
    animToPlay = "FadeOut"
  end
  FlashMethod(movie, string.format("Strikes.ObjStrike%i.gotoAndPlay", missionIdx), animToPlay)
end
local function UpdateStrikes(movie)
  local scrollOffset = tonumber(movie:GetVariable("OptionList.ListClass.mScrollPos"))
  local strikeIdx = mItemSelected - scrollOffset
  for i = 0, 7 do
    local isCompleted = 0 <= mNewGamePlusCompletionInfo[scrollOffset + i + 1]
    UpdateStrike(movie, i, isCompleted)
  end
end
local function InitMainItems(movie)
  mNewGamePlusChapter = ""
  mScreenState = SCREENSTATE_SelectingMain
  FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByName", statusBack, false)
  itemList = {}
  FlashMethod(movie, "OptionList.ListClass.EraseItems")
  mHasSaveGame = Engine.GetPlayerProfileMgr():ScriptIsSaveGameAvailable()
  if mHasSaveGame then
    table.insert(itemList, itemContinue)
  end
  itemList[#itemList + 1] = itemSinglePlayer
  local profile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  if not IsNull(profile) then
    local profileData = profile:GetGameSpecificData()
    if not IsNull(profileData) and profileData:HasEndGameData() then
      table.insert(itemList, itemNewGamePlus)
    end
  end
  table.insert(itemList, itemMultiPlayer)
  table.insert(itemList, itemOptions)
  table.insert(itemList, itemCredits)
  table.insert(itemList, itemDLC)
  if LIB.IsPC(movie) then
    table.insert(itemList, itemQuit)
  end
  for i = 1, #itemList do
    FlashMethod(movie, "OptionList.ListClass.AddItem", itemList[i], false)
  end
  FlashMethod(movie, "OptionList.ListClass.SetLetterSpacing", 2)
  FlashMethod(movie, "OptionList.ListClass.SetAlignment", "left")
  FlashMethod(movie, "OptionList.ListClass.SetPressedCallback", "ListButtonPressed")
  FlashMethod(movie, "OptionList.ListClass.SetSelectedCallback", "ListButtonSelected")
  FlashMethod(movie, "OptionList.ListClass.SetUnselectedCallback", "ListButtonUnselected")
  FlashMethod(movie, "OptionList.ListClass.SetSelected", 0)
end
local function ResetInputTimer()
  mAllowInputTimer = 0.1
end
local function ShouldBlockInput()
  return 0 <= mAllowInputTimer
end
local function SetScreenState(movie, newState)
  movie:ResetButtons()
  ResetInputTimer()
  mScreenStatePrevious = mScreenState
  movie:SetVariable("NewGameChapterCompletion.text", "")
  if newState == SCREENSTATE_SelectingMain then
    InitMainItems(movie)
  elseif newState == SCREENSTATE_SelectingDifficulty then
    mAllowInputTimer = 0.5
    InitDifficultyItems(movie)
  elseif newState == SCREENSTATE_SelectingBeginOrChapSelect then
    InitBeginOrChapSelect(movie)
  elseif newState == SCREENSTATE_SelectingNewGameMap then
    InitNewGameMaps(movie)
    SetupChapterStrikes(movie)
    UpdateStrikes(movie)
  elseif newState == SCREENSTATE_SelectingMap then
    InitMaps(movie)
  end
  if newState == SCREENSTATE_SelectingNewGameMap then
    FlashMethod(movie, "OptionList.ListClass.SetWrapEnabled", false)
  else
    FlashMethod(movie, "OptionList.ListClass.SetWrapEnabled", true)
  end
  movie:SetVariable("Strikes._visible", newState == SCREENSTATE_SelectingNewGameMap)
  movie:SetVariable("DifficultyDescription._visible", newState == SCREENSTATE_SelectingDifficulty or newState == SCREENSTATE_SelectingNewGameMap)
  if newState == SCREENSTATE_SelectingDifficulty then
    movie:SetVariable("DifficultyDescription._x", "401")
  else
    movie:SetVariable("DifficultyDescription._x", "525")
  end
  movie:SetVariable("Logo.enabled", newState == SCREENSTATE_SelectingMain)
  movie:SetVariable("Logo._visible", newState == SCREENSTATE_SelectingMain)
  movie:SetVariable("Title._visible", newState == SCREENSTATE_SelectingDifficulty or newState == SCREENSTATE_SelectingNewGameMap or newState == SCREENSTATE_SelectingBeginOrChapSelect)
  if newState == SCREENSTATE_SelectingDifficulty then
    movie:SetLocalized("Title.TxtHolder.Txt.text", "/D2/Language/Menu/MainMenu_SelectDifficulty")
  elseif newState == SCREENSTATE_SelectingBeginOrChapSelect then
    movie:SetLocalized("Title.TxtHolder.Txt.text", "/D2/Language/Menu/MainMenu_Item_NewGamePlus")
  else
    movie:SetLocalized("Title.TxtHolder.Txt.text", "/D2/Language/Menu/MainMenu_ChapterSelect")
  end
  mScreenState = newState
end
function NewGameDestroyOldConfirm(movie, args)
  if tonumber(args) == 0 then
    SetScreenState(movie, SCREENSTATE_SelectingDifficulty)
  end
end
function NewGamePlusDestroyOldConfirm(movie, args)
  if tonumber(args) == 0 then
    SetScreenState(movie, SCREENSTATE_SelectingBeginOrChapSelect)
  end
end
local function NewGameConfirm(movie)
  if mHasSaveGame then
    popupMovie = movie:PushChildMovie(popupConfirmMovie)
    FlashMethod(popupMovie, "CreateOkCancel", "/D2/Language/Menu/MainMenu_NewGameConfirm", popupItemOk, popupItemCancel, "NewGameDestroyOldConfirm")
  else
    SetScreenState(movie, SCREENSTATE_SelectingDifficulty)
  end
end
local function NewGamePlusConfirm(movie)
  if mHasSaveGame then
    popupMovie = movie:PushChildMovie(popupConfirmMovie)
    FlashMethod(popupMovie, "CreateOkCancel", "/D2/Language/Menu/MainMenu_NewGamePlusConfirm", popupItemOk, popupItemCancel, "NewGamePlusDestroyOldConfirm")
  else
    SetScreenState(movie, SCREENSTATE_SelectingNewGameMap)
  end
end
local function ShowDLC(movie)
  if LIB.IsPS3(movie) and not Engine.GetPlayerProfileMgr():GetPlayerProfile(0):IsOnline() then
    Engine.GetPlayerProfileMgr():LogIn(1, true, true, LIB.GetActiveControllerIndex(movie), "OnLoginForDLCNoConfirmationComplete")
    return
  end
  local success = Engine.GetDownloadableContentMgr():ShowSystemMarketplaceUI(gClient:GetOverlayMgr(), "/D2/Menus/MainMenu.swf")
  if not success and movie:GetVariable("$platform") == "WINDOWS" then
    popupMovie = movieInstance:PushChildMovie(popupConfirmMovie)
    FlashMethod(popupMovie, "CreateOkCancel", "Menu/SteamOverlayDisabled", popupItemOk, "\t", "CloseActivePopup")
    popupMovie:Execute("SetRightItemText", "")
  end
end
local function DLCConfirm(movie)
  if movie:GetVariable("$platform") == "PS3" then
    local residentInstance = gFlashMgr:FindMovie(popupConfirmMovie)
    if not IsNull(residentInstance) then
      return
    end
    popupMovie = movie:PushChildMovie(popupConfirmMovie)
    FlashMethod(popupMovie, "CreateOkCancel", "/D2/Language/Menu/MainMenu_DLCConfirm", popupItemOk, popupItemCancel, "DLCConfirmButtonPressed")
  else
    ShowDLC(movie)
  end
end
function DLCConfirmButtonPressed(movie, buttonArg)
  if tonumber(buttonArg) == 0 then
    ShowDLC(movie)
  else
    popupMovie = nil
  end
end
function PopupTransitionInDone(movie)
  FlashMethod(mMultiplayerPopupMovie, "CreateList", "ConfirmMultiplayerListButtonPressed", "ConfirmListButtonSelected", "ConfirmListButtonUnselected")
  local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  if not IsNull(playerProfile) and playerProfile:IsOnline() or Engine.GetPlayerProfileMgr():IsLoggedIn() then
    for i = 1, #confirmListOnline do
      FlashMethod(mMultiplayerPopupMovie, "OptionList.ListClass.AddItem", confirmListOnline[i], false)
    end
    mMultiplayerPopupMovie:Execute("SetDescription", "/D2/Language/Menu/MainMenu_Request_PlayOnline")
  else
    for i = 1, #confirmList do
      FlashMethod(mMultiplayerPopupMovie, "OptionList.ListClass.AddItem", confirmList[i], false)
    end
    mMultiplayerPopupMovie:Execute("SetDescription", "/D2/Language/Menu/MainMenu_Request_SignIn_Windows")
  end
  FlashMethod(mMultiplayerPopupMovie, "OptionList.ListClass.SetAlignment", "center")
  FlashMethod(mMultiplayerPopupMovie, "OptionList.ListClass.SetSelected", 0)
end
local function HandleMainItemPress(movie, index)
  if mQueuedTransitionToMP then
    return
  end
  local profile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  local profileData
  if not IsNull(profile) then
    profileData = profile:GetGameSpecificData()
  end
  if not IsNull(profileData) then
    profileData:SetStartingNewGamePlus(false)
  end
  if itemList[index] == itemSinglePlayer then
    Engine.GetMatchingService():DisableSessionReconnect()
    NewGameConfirm(movie)
  elseif itemList[index] == itemNewGamePlus then
    Engine.GetMatchingService():DisableSessionReconnect()
    if not IsNull(profileData) then
      profileData:SetStartingNewGamePlus(true)
    end
    NewGamePlusConfirm(movie)
  elseif itemList[index] == itemContinue then
    Engine.GetMatchingService():DisableSessionReconnect()
    LIB.DoScreenTransition(movie, LIB.TRANSITION_DESTINATON_CONTINUE_LAST_SAVE, transitionMovie, LIB.TRANSITON_VIDEO_MAIN_MENU)
  elseif itemList[index] == itemMultiPlayer then
    mMultiplayerPopupMovie = movie:PushChildMovie(popupConfirmMovie)
    mMultiplayerPopupMovie:Execute("SetTransitionInDoneCallback", "PopupTransitionInDone")
  elseif itemList[index] == itemDLC then
    if Engine.GetPlayerProfileMgr():GetPlayerProfile(0):IsOnline() then
      DLCConfirm(movie)
    else
      Engine.GetPlayerProfileMgr():LogIn(1, true, true, LIB.GetActiveControllerIndex(movie), "OnLoginForDLCComplete")
    end
  elseif itemList[index] == itemOptions then
    LIB.DoScreenTransition(movie, itemOptionsMovie:GetResourceName(), transitionMovie, LIB.TRANSITON_VIDEO_MAIN_MENU)
  elseif itemList[index] == itemCredits then
    LIB.DoScreenTransition(movie, itemCreditsMovie:GetResourceName(), transitionMovie, LIB.TRANSITON_VIDEO_MAIN_MENU)
  elseif itemList[index] == itemQuit then
    popupMovie = movie:PushChildMovie(popupConfirmMovie)
    FlashMethod(popupMovie, "CreateOkCancel", "/D2/Language/Menu/MainMenu_QuitConfirm", popupItemOk, popupItemCancel, "QuitConfirm")
  elseif itemList[index] == itemDarkness1 then
    popupMovie = movie:PushChildMovie(popupConfirmMovie)
    FlashMethod(popupMovie, "CreateOkCancel", "/D2/Language/Menu/MainMenu_Darkness1Confirm", popupItemOk, popupItemCancel, "Darkness1Confirm")
  end
end
function ListButtonPressed(movie, buttonArg)
  if mQueuedTransitionToMP then
    return
  end
  if ShouldBlockInput() then
    return
  end
  local index = tonumber(buttonArg) + 1
  gRegion:PlaySound(pressSound, Vector(), false)
  if mScreenState == SCREENSTATE_SelectingMain then
    HandleMainItemPress(movie, index)
  elseif mScreenState == SCREENSTATE_SelectingDifficulty then
    if mNewGamePlusChapter ~= "" then
      local difficultyTable = LIB.GetDifficultyTable()
      local theLevel = difficultyTable[tonumber(buttonArg) + 1]
      local profile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
      profile:Settings():SetDifficulty(theLevel.difficulty)
      LoadLevel(mNewGamePlusChapter)
    else
      movie:SetVariable("_root.Difficulty", tonumber(buttonArg))
      local childMovie = movie:PushChildMovie(itemDisplayOptionsMovie)
      if childMovie ~= nil then
        childMovie:SetTexture("BinkPlaceholder.png", binkTexture)
      end
    end
  elseif mScreenState == SCREENSTATE_SelectingBeginOrChapSelect then
    if index == 1 then
      mNewGamePlusSelection = -1
      mNewGamePlusChapter = ""
      SetScreenState(movie, SCREENSTATE_SelectingDifficulty)
    else
      SetScreenState(movie, SCREENSTATE_SelectingNewGameMap)
    end
  elseif mScreenState == SCREENSTATE_SelectingNewGameMap then
    mNewGamePlusSelection = index
    mNewGamePlusChapter = gGameConfig:GetChapterLevel(mNewGamePlusSelection - 1)
    SetScreenState(movie, SCREENSTATE_SelectingDifficulty)
  elseif mScreenState == SCREENSTATE_SelectingMap then
    local defaultGameRules = gGameConfig:GetDefaultGameRules()
    local demoLevels = defaultGameRules.mLevels
    local levelNames = demoLevels:GetLevelNames(false)
    LoadLevel(levelNames[index])
  end
  return 1
end
function ListButtonUnselected(movie, buttonArg)
  if mScreenState == SCREENSTATE_SelectingNewGameMap then
    local scrollOffset = tonumber(movie:GetVariable("OptionList.ListClass.mScrollPos"))
    local idx = tonumber(buttonArg)
    local strikeIdx = idx - scrollOffset
    UpdateStrikeAlpha(movie, strikeIdx, false)
    mItemSelected = -1
  end
end
function ListButtonSelected(movie, buttonArg)
  gRegion:PlaySound(rollOverSound, Vector(), false)
  local lastItemSelected = mItemSelected
  mItemSelected = tonumber(buttonArg)
  if mItemSelected < 0 then
    print("Whoa... selected negative index in list O_O")
    return
  end
  if mScreenState == SCREENSTATE_SelectingDifficulty then
    UpdateDifficultyBox(movie, mItemSelected)
  elseif mScreenState == SCREENSTATE_SelectingNewGameMap then
    local y = tonumber(movie:GetVariable("OptionList._y"))
    local desc = tostring(gGameConfig:GetChapterDescription(mItemSelected))
    movie:SetLocalized("DifficultyDescription.Text.text", desc)
    movie:SetVariable("DifficultyDescription._y", y)
    UpdateStrikes(movie)
    local scrollOffset = tonumber(movie:GetVariable("OptionList.ListClass.mScrollPos"))
    local strikeIdx = mItemSelected - scrollOffset
    UpdateStrikeAlpha(movie, strikeIdx, true)
    if 0 <= lastItemSelected then
      UpdateStrikeAlpha(movie, lastItemSelected, false)
    end
  end
  return 1
end
local function ShowChatDisabledPopup(movie)
  ClosePopup()
  popupMovie = movie:PushChildMovie(popupConfirmMovie)
  FlashMethod(popupMovie, "CreateOkCancel", "Menu/NoVoicePS3", popupItemOk, popupItemCancel, "ChatDisabledConfirmed")
  popupMovie:Execute("SetRightItemText", "")
end
function ChatDisabledConfirmed(movie, args)
  print("Main menu queueing transition to MP")
  mQueuedTransitionToMP = true
end
local function _TransitionToMultiplayer()
  local profile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  if not IsNull(profile) then
    local profileData = profile:GetGameSpecificData()
    if IsNull(profileData) and not IsNull(gRegion:GetGameRules()) then
      gRegion:GetGameRules():InitializeGameSpecificProfileData()
    end
  end
  if LIB.IsPS3(movieInstance) and not IsNull(profile) and profile:IsOnline() and not profile:IsVoiceAllowed() then
    ShowChatDisabledPopup(movieInstance)
  elseif LIB.IsPS3(movieInstance) and not IsNull(profile) and not profile:AllowOnlineMultiplayer() then
    ClosePopup()
    mMPLoginFailureMessage = "/Multiplayer/Restricted_Parental_Control_Windows"
    popupMovie = movieInstance:PushChildMovie(popupConfirmMovie)
    popupMovie:Execute("SetTransitionInDoneCallback", "MPCompleteTransitionDone")
  else
    print("Main menu queueing transition to MP")
    mQueuedTransitionToMP = true
  end
end
local function CheckForMpSessionReconnect(movie)
  if Engine.GetPlayerProfileMgr():IsLoggedIn() and Engine.GetPlayerProfileMgr():GetPlayerProfile(0):IsOnline() and Engine.GetMatchingService():IsSessionReconnectAvailable() then
    local platform = movie:GetVariable("$platform")
    if platform == "WINDOWS" then
      Engine.GetPlayerProfileMgr():LogIn(1, true, true, LIB.GetActiveControllerIndex(movie), "OnLoginForMultiplayerComplete")
    end
    print("automatically advancing to multiplayer screen for session reconnect")
    Engine.GetPlayerProfileMgr():SetOnlineConnectionRequired(true)
    _TransitionToMultiplayer()
  else
    Engine.GetMatchingService():DisableSessionReconnect()
  end
end
function NotifyDLCClosed()
  local movie = movieInstance
  local profile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  if not IsNull(profile) and not IsNull(popupConfirmMovie) then
    popupMovie = movie:PushChildMovie(popupConfirmMovie)
    FlashMethod(popupMovie, "CreateOkCancel", "/D2/Language/Menu/Profile_LoadingPlayerData", "", "", "")
    Engine.GetPlayerProfileMgr():ScriptRefreshSaveGames("OnSaveGameRefresh")
  end
end
function Initialize(movie)
  mAllowInputTimer = -1
  movie:SetVariable("Strikes._visible", false)
  _T.gResetMultiplayerScreen = false
  movieInstance = movie
  mIsPresenceUpdateRequired = true
  movie:SetVariable("Title.TxtHolder.Txt.text", "")
  if not Engine.GetPlayerProfileMgr():IsLoggedIn() then
    ReturnToPressStart(movie)
    return
  end
  D2_Game.D2SecurityMgr_GetD2SecurityMgr():ValidateWith2K()
  Engine.GetPlayerProfileMgr():SetOnlineConnectionRequired(false)
  if movie:GetParent() ~= nil then
    movie:GetParent():Close()
  end
  LIB.PlayBackgroundBink(movie, binkTexture)
  LIB.PlayGlobalMusicTrack(music)
  if Engine.GameRules_CheatsEnabled() then
    statusList = {
      statusSaveProfile,
      statusMapList,
      statusClearProfile,
      statusSelect,
      statusBack
    }
  end
  for i = 1, #statusList do
    FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", statusList[i], statusList[i] ~= statusSelect and statusList[i] ~= statusBack)
  end
  FlashMethod(movie, "StatusBar.StatusBarClass.SetCallbackOnPress", "StatusButtonPressed")
  ClosePopup()
  local profile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  if not IsNull(profile) and not profile:SavedGamesUpToDate() and not IsNull(popupConfirmMovie) then
    popupMovie = movie:PushChildMovie(popupConfirmMovie)
    FlashMethod(popupMovie, "CreateOkCancel", "/D2/Language/Menu/Profile_LoadingPlayerData", "", "", "")
    Engine.GetPlayerProfileMgr():ScriptRefreshSaveGames("OnSaveGameRefresh")
  else
    SetScreenState(movie, SCREENSTATE_SelectingMain)
  end
  if Engine.GetPlayerProfileMgr():GetPlayerProfile(0):IsOnline() and not IsNull(Engine.GetMatchingService():GetPartySession()) then
    local profile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
    if not IsNull(profile) then
      local profileData = profile:GetGameSpecificData()
      if not IsNull(profileData) then
        profileData:SetPlayingOfflineMP(false)
      end
    end
    Engine.GetPlayerProfileMgr():SetOnlineConnectionRequired(true)
    _TransitionToMultiplayer()
  else
    CheckForMpSessionReconnect(movie)
  end
  Engine.GetPlayerProfileMgr():ScriptSetStorageChangedCallback("OnStorageChanged")
  mNewGamePlusChapter = ""
end
local ClearProfile = function(movie)
  if Engine.GetPlayerProfileMgr():IsLoggedIn() then
    Engine.GetPlayerProfileMgr():GetPlayerProfile(0):ClearGameSpecificData()
    gRegion:GetGameRules():InitializeGameSpecificProfileData()
    Engine.GetPlayerProfileMgr():ScriptRefreshSaveGames("OnSaveGameRefresh")
  end
end
local function SaveProfile(movie)
  if Engine.GetPlayerProfileMgr():IsLoggedIn() then
    popupMovie = movie:PushChildMovie(popupConfirmMovie)
    FlashMethod(popupMovie, "CreateOkCancel", "/D2/Language/Menu/Profile_SavingPleaseWait", "", "", "")
    Engine.GetPlayerProfileMgr():ScriptSaveProfile(0, "OnSaveProfileComplete")
  end
end
function OnSaveProfileComplete(success)
  local text
  if success then
    text = "/D2/Language/Menu/Profile_SavingSuccess"
  else
    text = "/D2/Language/Menu/Profile_SavingFail"
  end
  if popupMovie ~= nil then
    FlashMethod(popupMovie, "CreateOkCancel", text, popupItemOk, "", "")
  end
  return 1
end
function StatusButtonPressed(movie, buttonArg)
  local index = tonumber(buttonArg) + 1
  if statusList[index] == statusClearProfile then
    ClearProfile(movie)
  elseif statusList[index] == statusSaveProfile then
    SaveProfile(movie)
  elseif statusList[index] == statusMapList then
    if mScreenState ~= SCREENSTATE_SelectingMap then
      SetScreenState(movie, SCREENSTATE_SelectingMap)
    else
      SetScreenState(movie, SCREENSTATE_SelectingMain)
    end
  end
  return 1
end
function onKeyDown_MENU_LEFT_FROM_ANALOG(movie)
  return 1
end
function onKeyDown_MENU_LEFT(movie)
  return 1
end
function onKeyDown_MENU_RIGHT_FROM_ANALOG(movie)
  return 1
end
function onKeyDown_MENU_RIGHT(movie)
  return 1
end
function onKeyDown_MENU_UP_FROM_ANALOG(movie)
  if ShouldBlockInput() then
    return true
  end
  ResetInputTimer()
  return LIB.ListClassVerticalScroll(movie, "OptionList", -1)
end
function onKeyDown_MENU_UP(movie)
  if ShouldBlockInput() then
    return true
  end
  ResetInputTimer()
  return LIB.ListClassVerticalScroll(movie, "OptionList", -1)
end
function onKeyDown_MENU_DOWN_FROM_ANALOG(movie)
  if ShouldBlockInput() then
    return true
  end
  ResetInputTimer()
  return LIB.ListClassVerticalScroll(movie, "OptionList", 1)
end
function onKeyDown_MENU_DOWN(movie)
  if ShouldBlockInput() then
    return true
  end
  ResetInputTimer()
  return LIB.ListClassVerticalScroll(movie, "OptionList", 1)
end
function onKeyDown_MENU_GENERIC1(movie)
  if Engine.GameRules_CheatsEnabled() then
    SaveProfile(movie)
  end
  return 1
end
function onKeyDown_MENU_GENERIC2(movie)
  if Engine.GameRules_CheatsEnabled() then
    ClearProfile(movie)
  end
  return 1
end
function onKeyDown_MENU_LTRIGGER2(movie)
  if Engine.GameRules_CheatsEnabled() then
    if mScreenState ~= SCREENSTATE_SelectingMap then
      SetScreenState(movie, SCREENSTATE_SelectingMap)
    else
      SetScreenState(movie, SCREENSTATE_SelectingMain)
    end
  end
  return 1
end
function onKeyDown_MENU_CANCEL(movie)
  if mScreenState == SCREENSTATE_SelectingDifficulty then
    if mScreenStatePrevious == SCREENSTATE_SelectingNewGameMap then
      SetScreenState(movie, SCREENSTATE_SelectingNewGameMap)
    elseif mScreenStatePrevious == SCREENSTATE_SelectingBeginOrChapSelect then
      SetScreenState(movie, SCREENSTATE_SelectingBeginOrChapSelect)
    else
      SetScreenState(movie, SCREENSTATE_SelectingMain)
    end
  elseif mScreenState == SCREENSTATE_SelectingBeginOrChapSelect then
    SetScreenState(movie, SCREENSTATE_SelectingMain)
  elseif mScreenState == SCREENSTATE_SelectingNewGameMap then
    SetScreenState(movie, SCREENSTATE_SelectingBeginOrChapSelect)
  end
  return 1
end
local decay = 0
local newZoom = 0
local lerpZoom = 0
local function UpdateMusicBasedFX(movie)
  local a = Lerp(40, 60, AbsNoise(Time() * 0.05))
  local amp = 0
  if 0.5 < amp and decay <= 0 then
    decay = 1
    newZoom = Random(0, 1)
  end
  movie:SetVariable("LogoGlow._alpha", 30 + decay * 50)
  decay = decay - DeltaTime() * 0.5
  if decay < 0 then
    decay = 0
  end
  if lerpZoom ~= newZoom then
    lerpZoom = newZoom
  end
end
function onRawInputEvent(movie, deviceID, keyName, isDown)
  gFlashMgr:SetRawInputEventEnabled(false)
  return true
end
local function ShowLoadFailedPopup()
  if popupMovie == nil then
    popupMovie = movieInstance:PushChildMovie(popupConfirmMovie)
  end
  FlashMethod(popupMovie, "CreateOkCancel", "/D2/Language/Menu/Profile_LoadFailed_Windows", popupItemOk, "\t", "OnConfirmLoadFailed")
  popupMovie:Execute("SetRightItemText", "")
end
function OnConfirmLoadFailed(movie)
  ClosePopup()
  local platform = movie:GetVariable("$platform")
  if platform == "WINDOWS" then
    local profile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
    if not IsNull(profile) then
      local profileData = profile:GetGameSpecificData()
      if not IsNull(profileData) and Engine.GetPlayerProfileMgr():OnlineConnectionRequired() then
        profileData:SetPlayingOfflineMP(true)
        Engine.Disconnect(true)
      end
    end
  end
  if not Engine.GetPlayerProfileMgr():IsLoggedIn() then
    print("ruh roh, we're not logged in?  Better get on that pronto!")
    popupMovie = movieInstance:PushChildMovie(popupConfirmMovie)
    FlashMethod(popupMovie, "CreateOkCancel", "/D2/Language/Menu/Profile_PleaseWait", "", "", "")
    Engine.GetPlayerProfileMgr():LogIn(1, false, false, 0, "OnLoginOfflineComplete")
    return
  end
  Engine.GetPlayerProfileMgr():SetOnlineConnectionRequired(false)
  return 1
end
function OnLoginOfflineComplete(success)
  ClosePopup()
  if success then
    print("Ok, we've successfully re-logged in after failing to login for online.  Now let's do a script refresh save games")
    popupMovie = movieInstance:PushChildMovie(popupConfirmMovie)
    FlashMethod(popupMovie, "CreateOkCancel", "/D2/Language/Menu/Profile_LoadingPlayerData", "", "", "")
    Engine.GetPlayerProfileMgr():ScriptRefreshSaveGames("OnSaveGameRefresh")
  else
    print("O_O well this is just bad news bears.  Better restart the console")
  end
end
function MPCompleteTransitionDone(movie)
  popupMovie:Execute("CreateOkCancel", mMPLoginFailureMessage .. "," .. popupItemOk .. "," .. popupItemCancel .. ",OnConfirmLoadFailed")
  popupMovie:Execute("SetRightItemText", "")
  popupMovie:Execute("Setup", "")
end
function OnLoginForMultiplayerComplete(success)
  print("OnLoginForMultiplayerComplete success=" .. tostring(success))
  local profile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  local message = Engine.GetPlayerProfileMgr():GetLastError()
  if success and not profile:AllowOnlineMultiplayer() then
    if not IsNull(profile) and not IsNull(popupConfirmMovie) then
      if not IsNull(popupMovie) then
        popupMovie:Close()
        popupMovie = nil
      end
      local confirmInstance = gFlashMgr:FindMovie(popupConfirmMovie)
      if not IsNull(confirmInstance) then
        confirmInstance:Close()
        confirmInstance = nil
      end
      popupMovie = movieInstance:PushChildMovie(popupConfirmMovie)
      FlashMethod(popupMovie, "CreateOkCancel", "/D2/Language/Menu/Profile_LoadingPlayerData", "", "", "")
      Engine.GetPlayerProfileMgr():ScriptRefreshSaveGames("NoOnlineRefreshSavegamesDone")
    end
    return 1
  end
  if success then
    popupMovie = movieInstance:PushChildMovie(popupConfirmMovie)
    FlashMethod(popupMovie, "CreateOkCancel", "/D2/Language/Menu/Profile_LoadingPlayerData", "", "", "")
    local profile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
    if not IsNull(profile) then
      local profileData = profile:GetGameSpecificData()
      if not IsNull(profileData) then
        profileData:SetPlayingOfflineMP(false)
      end
    end
    Engine.GetPlayerProfileMgr():ScriptRefreshSaveGames("InitMenuPlusStartMp")
  else
    if message ~= "" then
      mMPLoginFailureMessage = message
      if not IsNull(popupMovie) then
        popupMovie:Close()
        popupMovie = nil
      end
      local confirmInstance = gFlashMgr:FindMovie(popupConfirmMovie)
      if not IsNull(confirmInstance) then
        confirmInstance:Close()
        confirmInstance = nil
      end
      popupMovie = movieInstance:PushChildMovie(popupConfirmMovie)
      popupMovie:Execute("SetTransitionInDoneCallback", "MPCompleteTransitionDone")
      return 1
    else
      Engine.GetPlayerProfileMgr():SetOnlineConnectionRequired(false)
    end
    if not Engine.GetPlayerProfileMgr():IsLoggedIn() then
      print("Whoa whoa whoa we're not logged in?  Better get on that pronto!")
      popupMovie = movieInstance:PushChildMovie(popupConfirmMovie)
      FlashMethod(popupMovie, "CreateOkCancel", "/D2/Language/Menu/Profile_PleaseWait", "", "", "")
      Engine.GetPlayerProfileMgr():LogIn(1, false, false, 0, "OnLoginOfflineComplete")
      return
    end
  end
  return 1
end
function DLCCompleteTransitionDone(movie)
  popupMovie:Execute("CreateOkCancel", "/Multiplayer/ValidOnlineProfileRequired_Windows," .. popupItemOk .. "," .. popupItemCancel .. ",CloseActivePopup")
  popupMovie:Execute("SetRightItemText", "")
  popupMovie:Execute("Setup", "")
end
local function _OnLoginForDLCComplete(success)
  if success then
    DLCConfirm(movieInstance)
  else
    if not IsNull(popupMovie) then
      popupMovie:Close()
      popupMovie = nil
    end
    local confirmInstance = gFlashMgr:FindMovie(popupConfirmMovie)
    if not IsNull(confirmInstance) then
      confirmInstance:Close()
      confirmInstance = nil
    end
    popupMovie = movieInstance:PushChildMovie(popupConfirmMovie)
    popupMovie:Execute("SetTransitionInDoneCallback", "DLCCompleteTransitionDone")
  end
  Engine.GetPlayerProfileMgr():SetOnlineConnectionRequired(false)
end
function OnLoginForDLCComplete(success)
  _OnLoginForDLCComplete(success)
  return 1
end
function OnLoginForDLCNoConfirmationComplete(success)
  if success then
    Engine.GetDownloadableContentMgr():ShowSystemMarketplaceUI(gClient:GetOverlayMgr(), "/D2/Menus/MainMenu.swf")
  else
    _OnLoginForDLCComplete(false)
  end
  return 1
end
local function RefreshCompleted(success, handlePopup)
  if handlePopup then
    if success then
      ClosePopup()
    else
      ShowLoadFailedPopup()
    end
  end
  local profile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  if not IsNull(profile) then
    local profileData = profile:GetGameSpecificData()
    if IsNull(profileData) then
      print("Null profile data!  Re-initializing")
      gRegion:GetGameRules():InitializeGameSpecificProfileData()
    end
  end
  if not IsNull(movieInstance) then
    SetScreenState(movieInstance, SCREENSTATE_SelectingMain)
  end
  return 1
end
function PostLoginFailRefresh(success)
  RefreshCompleted(success, false)
end
function OnSaveGameRefresh(success)
  RefreshCompleted(success or Engine.GetPlayerProfileMgr():IsPlayingWithoutSignIn(), true)
end
function OnStorageChanged()
  RefreshCompleted(true, false)
end
function TransitionToMultiplayer()
  _TransitionToMultiplayer()
  return 1
end
function InitMenuPlusStartMp(success)
  if success then
    ClosePopup()
    _TransitionToMultiplayer()
  else
    ShowLoadFailedPopup()
  end
  return 1
end
function NoOnlineRefreshSavegamesDone(success)
  if not IsNull(popupMovie) then
    popupMovie:Close()
    popupMovie = nil
  end
  local confirmInstance = gFlashMgr:FindMovie(popupConfirmMovie)
  if not IsNull(confirmInstance) then
    confirmInstance:Close()
    confirmInstance = nil
  end
  mMPLoginFailureMessage = "/Multiplayer/Restricted_Parental_Control_Windows"
  popupMovie = movieInstance:PushChildMovie(popupConfirmMovie)
  popupMovie:Execute("SetTransitionInDoneCallback", "MPCompleteTransitionDone")
end
function Update(movie)
  if ShouldBlockInput() then
    mAllowInputTimer = mAllowInputTimer - DeltaTime()
  end
  Engine.GetMatchingService():HandleJoinInviteFailure()
  if mIsPresenceUpdateRequired and not IsNull(gRegion:GetGameRules()) then
    mIsPresenceUpdateRequired = false
    gRegion:GetGameRules():SetRichPresence()
  end
  if not mIsPreloadCheckDone and gRegion:IsReadyForLevelStreaming() then
    if gCmdLine:Stripped() then
      BeginLevelPreload()
    end
    mIsPreloadCheckDone = true
  end
  if mQueuedTransitionToMP and not gClient:HasDisconnectError() then
    if not gFlashMgr:FindMovie(transitionMovie) then
      mQueuedTransitionToMP = false
      local popupInstance = gFlashMgr:FindMovie(popupConfirmMovie)
      if not IsNull(popupInstance) then
        popupInstance:Close()
      end
      local mpScreenInstance = gFlashMgr:FindMovie(itemMultiPlayerMovie)
      if not IsNull(mpScreenInstance) then
        print("Main menu calling ResetState on multiplayer lobby screen")
        local profile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
        if not IsNull(profile) then
          local profileData = profile:GetGameSpecificData()
          if not IsNull(profileData) then
            profileData:SetPlayingOfflineMP(false)
          end
        end
        _T.gResetMultiplayerScreen = true
      else
        local moviesToClose = {
          itemDisplayOptionsMovie,
          itemOptionsMovie,
          itemCreditsMovie
        }
        for i = 1, #moviesToClose do
          local instance = gFlashMgr:FindMovie(moviesToClose[i])
          if not IsNull(instance) then
            instance:Close()
          end
        end
        LIB.DoScreenTransition(movieInstance, itemMultiPlayerMovie:GetResourceName(), transitionMovie, LIB.TRANSITON_VIDEO_MAIN_MENU)
      end
    elseif not hasLoggedMpTransitionError then
      print("ERROR: cannot transition to MP because transition movie is still playing")
      hasLoggedMpTransitionError = true
    end
  elseif mQueuedTransitionToMP and not hasLoggedMpTransitionError then
    print("ERROR: cannot transition to MP because Client:HasDisconnectError is TRUE")
    hasLoggedMpTransitionError = true
  end
end
function RestartBackgroundVideo(movie, resetState)
  LIB.PlayBackgroundBink(movie, binkTexture)
  if resetState ~= nil and resetState == "1" then
    SetScreenState(movie, SCREENSTATE_SelectingMain)
    FlashMethod(movie, "OptionList.ListClass.SetSelected", 0)
  end
end

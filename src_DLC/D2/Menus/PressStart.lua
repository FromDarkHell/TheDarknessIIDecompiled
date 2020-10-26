local LIB = require("D2.Menus.SharedLibrary")
itemMainMenuMovie = Resource()
binkTexture = Resource()
notificationPopupMovie = Resource()
attractModeInitialDelay = 30
attractModeRepeatDelay = 20
transitionMovie = Resource()
pressSound = Resource()
music = Resource()
confirmMovie = WeakResource()
local itemPressStart = "/D2/Language/Menu/PressStart_Item_PressStart"
local itemPressEnter = "/D2/Language/Menu/PressStart_Item_PressEnter"
local itemList = {" "}
local attractModeTimer = 9999
local popupMovie, movieInstance
local readyForInput = false
local attractVideoPlaying = false
local loginInProgress = false
local screenAlpha = 0
local popupItemOk = "/D2/Language/Menu/Confirm_Item_Ok"
local popupItemCancel = "/D2/Language/Menu/Confirm_Item_Cancel"
local POST_LOGIN_TASK_NONE = 0
local POST_LOGIN_TASK_AUTHORIZE = 1
local POST_LOGIN_TASK_SAVE_GAME_CHECK = 2
local POST_LOGIN_TASK_WRITE_INITIAL_SETTINGS = 3
local POST_LOGIN_TASK_PURCHASEABLE_DLC_CHECK = 4
local POST_LOGIN_TASK_DONE = 5
local currentPostLoginTask = POST_LOGIN_TASK_NONE
local loginTaskFrameDelay = -1
local loginDeviceId = 0
local presenceUpdateRequired = true
local autoAcceptInvitePostlogin = false
local function InitializePressStart()
  if LIB.IsPC(movieInstance) then
    itemList = {itemPressEnter}
  else
    itemList = {itemPressStart}
  end
  for i = 1, #itemList do
    FlashMethod(movieInstance, "OptionList.ListClass.AddItem", itemList[i], false)
  end
  FlashMethod(movieInstance, "OptionList.ListClass.SetPressedCallback", "ListButtonPressed")
  movieInstance:SetVariable("OptionList.ButtonLabel0.Txt.textAlign", "center")
  gFlashMgr:ClearExclusiveDevice()
  presenceUpdateRequired = true
  readyForInput = true
  attractModeTimer = attractModeInitialDelay
  attractVideoPlaying = false
  currentPostLoginTask = POST_LOGIN_TASK_NONE
  loginTaskFrameDelay = -1
  loginInProgress = false
  autoAcceptInvitePostlogin = false
  Engine.GetMatchingService():DisableSessionReconnect()
end
function Initialize(movie)
  movieInstance = movie
  movie:SetVariable("._alpha", screenAlpha)
  if LIB.IsPC(movieInstance) then
    Engine.GetPlayerProfileMgr():LogIn(1, false, false, 0)
  end
  LIB.PlayBackgroundBink(movie, binkTexture)
  LIB.PlayGlobalMusicTrack(music)
  FlashMethod(movie, "MenuBackgroundClip.gotoAndStop", "MainMenuPosition")
  readyForInput = false
  attractModeTimer = 99999
  loginInProgress = false
  InitializePressStart()
end
local function ClosePopup(movie)
  if not IsNull(popupMovie) then
    popupMovie:Close()
  end
  popupMovie = nil
  attractModeTimer = attractModeRepeatDelay
end
local ValidateCurrentUser = function()
  D2_Game.D2SecurityMgr_GetD2SecurityMgr():Init2KLib()
  D2_Game.D2SecurityMgr_GetD2SecurityMgr():ValidateWith2K()
  D2_Game.D2SecurityMgr_GetD2SecurityMgr():ValidateWithTitleServer("OnValidateDeviceComplete")
end
local function _TransitionToMainMenu()
  LIB.DoScreenTransition(movieInstance, itemMainMenuMovie:GetResourceName(), transitionMovie, LIB.TRANSITON_VIDEO_PRESS_START)
end
function TransitionToMainMenu()
  _TransitionToMainMenu()
end
local function AdvancePostLoginTasks()
  currentPostLoginTask = currentPostLoginTask + 1
  if currentPostLoginTask == POST_LOGIN_TASK_AUTHORIZE then
    print("Press Start Screen: validating logged in user")
    ValidateCurrentUser()
  elseif currentPostLoginTask == POST_LOGIN_TASK_SAVE_GAME_CHECK then
    print("Press Start Screen: checking for save game data")
    Engine.GetPlayerProfileMgr():ScriptRefreshSaveGames("OnCheckForSaveGamesComplete")
  elseif currentPostLoginTask == POST_LOGIN_TASK_WRITE_INITIAL_SETTINGS then
    if LIB.IsPS3(movieInstance) and not Engine.GetPlayerProfileMgr():ScriptIsSaveGameAvailable() and not Engine.GetPlayerProfileMgr():GetPlayerProfile(0):ScriptIsSettingsAvailable() then
      print("Press Start Screen: No existing save data - writing out initial settings")
      Engine.GetPlayerProfileMgr():GetPlayerProfile(0):Settings():MarkDirty()
      Engine.GetPlayerProfileMgr():ScriptSaveProfile(0, "OnWriteInitialSettingsComplete")
    else
      print("Press Start Screen: No need to write initial settings")
      AdvancePostLoginTasks()
    end
  elseif currentPostLoginTask == POST_LOGIN_TASK_PURCHASEABLE_DLC_CHECK then
    print("Press Start Screen: checking online store for purchaseable DLC")
    Engine.GetDownloadableContentMgr():CheckForPurchaseableDlc("OnPurchaseableDlcCheckComplete")
  elseif currentPostLoginTask == POST_LOGIN_TASK_DONE then
    print("Press Start Screen: post login tasks complete")
    ClosePopup(movieInstance)
    if autoAcceptInvitePostlogin then
      autoAcceptInvitePostlogin = false
      local profile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
      if not IsNull(profile) and profile:IsOnline() and not profile:IsVoiceAllowed() then
        ClosePopup(movieInstance)
        popupMovie = movieInstance:PushChildMovie(notificationPopupMovie)
        FlashMethod(popupMovie, "CreateOkCancel", "Menu/NoVoicePS3", popupItemOk, popupItemCancel, "ChatDisabledConfirmed")
        popupMovie:Execute("SetRightItemText", "")
      else
        Engine.GetMatchingService():JoinSessionByInvite()
      end
    else
      _TransitionToMainMenu()
    end
  else
    print("Press Start Screen: ERROR - unknown post-login task!")
  end
end
function Update(movie)
  local deltaTime = RealDeltaTime()
  if LIB.IsPC(movie) and IsNull(gRegion) then
    movie:Close()
    return
  end
  local hasGameRules = not IsNull(gRegion:GetGameRules())
  local showingSysUI = Engine.GetPlayerProfileMgr():ShowingSysUI()
  if hasGameRules and presenceUpdateRequired then
    presenceUpdateRequired = false
    gRegion:GetGameRules():SetRichPresence()
  end
  if showingSysUI then
    attractModeTimer = attractModeRepeatDelay
  elseif gFlashMgr:FindMovie(confirmMovie) then
    attractModeTimer = attractModeRepeatDelay
    if attractVideoPlaying then
      if gRegion:GetGameRules():IsInAttractMode() then
        gRegion:GetGameRules():StopAttractMode()
        screenAlpha = 0
        movie:SetVariable("._alpha", screenAlpha)
      end
      gRegion:StartVideoTexture(binkTexture)
      LIB.PlayGlobalMusicTrack(music)
      attractVideoPlaying = false
    end
  end
  if hasGameRules and not gRegion:GetGameRules():IsInAttractMode() and not gClient:IsLoading() and not showingSysUI and popupMovie == nil and not loginInProgress then
    attractModeTimer = attractModeTimer - deltaTime
    if attractVideoPlaying then
      screenAlpha = 0
      movie:SetVariable("._alpha", screenAlpha)
      gRegion:StartVideoTexture(binkTexture)
      LIB.PlayGlobalMusicTrack(music)
      attractVideoPlaying = false
    elseif attractModeTimer <= 0 then
      attractModeTimer = attractModeRepeatDelay
      LIB.StopGlobalMusicTrack()
      gRegion:StopVideoTexture(binkTexture)
      gRegion:GetGameRules():StartAttractMode()
      attractVideoPlaying = true
    end
  elseif 0 <= loginTaskFrameDelay and not Engine.GetPlayerProfileMgr():WaitingForAsync() then
    loginTaskFrameDelay = loginTaskFrameDelay - 1
    if loginTaskFrameDelay < 0 then
      AdvancePostLoginTasks()
    end
  end
  if screenAlpha < 100 and not gRegion:IsVideoTextureAsyncLoadPending() then
    screenAlpha = Clamp(screenAlpha + deltaTime * 300, 0, 100)
    movie:SetVariable("._alpha", screenAlpha)
  end
end
local function BeginPostLogInTasks()
  currentPostLoginTask = POST_LOGIN_TASK_NONE
  loginTaskFrameDelay = 2
end
function OnLoginComplete(success)
  print("PressStart: OnLoginComplete " .. tostring(success))
  if success then
    presenceUpdateRequired = true
    BeginPostLogInTasks()
  else
    loginInProgress = false
    ClosePopup(movieInstance)
    local message = Engine.GetPlayerProfileMgr():GetLastError()
    if not LIB.IsPS3(movieInstance) and message == "" then
      message = "/D2/Language/Menu/Profile_LoadFailed_Windows"
    end
    print("The message is: " .. message)
    if message ~= "" then
      popupMovie = movieInstance:PushChildMovie(notificationPopupMovie)
      FlashMethod(popupMovie, "CreateOkCancel", message, "/D2/Language/Menu/Confirm_Item_Ok", "\t", "")
      popupMovie:Execute("SetRightItemText", "")
    end
    gFlashMgr:ClearExclusiveDevice()
    print("Clearing auto accept invite flag")
    Engine.GetPlayerProfileMgr():ScriptClearGameBootInvite()
    autoAcceptInvitePostlogin = false
  end
end
function OnValidateDeviceComplete(success)
  if success then
    AdvancePostLoginTasks()
  else
    FlashMethod(popupMovie, "CreateOkCancel", "/D2/Language/Menu/MainMenu_ValidationFailed", "", "", "")
  end
end
function OnCheckForSaveGamesComplete(success)
  AdvancePostLoginTasks()
end
function OnWriteInitialSettingsComplete(success)
  AdvancePostLoginTasks()
end
function OnPurchaseableDlcCheckComplete(success)
  AdvancePostLoginTasks()
end
local function DoPostDlcEnumerateLogin()
  if Engine.GetPlayerProfileMgr():IsLoggedIn() then
    BeginPostLogInTasks()
  else
    Engine.GetPlayerProfileMgr():LogIn(1, false, false, loginDeviceId, "OnLoginComplete")
  end
end
function OnEnumerateInstalledDlcComplete(success)
  print("OnEnumerateInstalledDlcComplete called")
  if success then
    DoPostDlcEnumerateLogin()
  else
    print("DLC enumeration failed, showing popup...")
    popupMovie = movieInstance:PushChildMovie(notificationPopupMovie)
    local finalStr
    local packageList = Engine.GetDownloadableContentMgr():GetFailedDlcList()
    if packageList == "" then
      finalStr = popupMovie:GetLocalized("/D2/Language/Menu/MainMenu_ErrorLoadingDLCNoList")
    else
      local formatStr = popupMovie:GetLocalized("/D2/Language/Menu/MainMenu_ErrorLoadingDLC")
      finalStr = string.format(formatStr, packageList)
    end
    FlashMethod(popupMovie, "CreateOkCancel", finalStr, "/D2/Language/Menu/Confirm_Item_Ok", "\t", "OnConfirmErrorLoadingDLC")
    popupMovie:Execute("SetRightItemText", "")
  end
end
function OnConfirmErrorLoadingDLC(movie)
  ClosePopup(movie)
  DoPostDlcEnumerateLogin()
end
function ChatDisabledConfirmed(movie)
  ClosePopup(movie)
  Engine.GetMatchingService():JoinSessionByInvite()
end
local function _LoginUser(movie, deviceId)
  if LIB.IsPC(movie) and deviceId == nil then
    deviceId = 0
  end
  loginDeviceId = deviceId
  loginInProgress = true
  popupMovie = movie:PushChildMovie(notificationPopupMovie)
  FlashMethod(popupMovie, "CreateOkCancel", "/D2/Language/Menu/Profile_PleaseWait", "", "", "")
  Engine.GetDownloadableContentMgr():EnumerateInstalledDlc("OnEnumerateInstalledDlcComplete")
end
function LoginUserForInvite(movie, deviceId, autoAccept)
  print("PressStart: LoginUserForInvite")
  if gRegion:GetGameRules():IsInAttractMode() then
    gRegion:GetGameRules():StopAttractMode()
  end
  if autoAccept == "1" then
    print("autoAcceptInvitePostlogin")
    autoAcceptInvitePostlogin = true
  end
  _LoginUser(movieInstance, tonumber(deviceId))
  return 1
end
local function OnStartPressed(movie, deviceId)
  if not readyForInput then
    return
  end
  attractModeTimer = attractModeInitialDelay
  if gRegion:GetGameRules():IsInAttractMode() then
    gRegion:GetGameRules():StopAttractMode()
  elseif gFlashMgr:FindMovie(confirmMovie) == nil then
    gRegion:PlaySound(pressSound, Vector(), false)
    _LoginUser(movie, deviceId)
  end
end
function ListButtonPressed(movie, buttonArg)
  OnStartPressed(movie, 0)
end
local function ProcessInput(movie, deviceID)
  local theDevice = tonumber(deviceID)
  if theDevice < 4 and not gRegion:GetGameRules():IsInAttractMode() then
    gFlashMgr:SetExclusiveDeviceID(theDevice)
  end
  if LIB.IsPC(movie) then
    deviceID = 0
    gFlashMgr:SetExclusiveDeviceID(deviceID)
  end
  OnStartPressed(movie, deviceID)
end
function onKeyDown_PRESS_START(movie, deviceID)
  ProcessInput(movie, deviceID)
  return 1
end
function onKeyDown_MENU_SELECT(movie, deviceID)
  ProcessInput(movie, deviceID)
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
  return LIB.ListClassVerticalScroll(movie, "OptionList", -1)
end
function onKeyDown_MENU_UP(movie)
  return LIB.ListClassVerticalScroll(movie, "OptionList", -1)
end
function onKeyDown_MENU_DOWN_FROM_ANALOG(movie)
  return LIB.ListClassVerticalScroll(movie, "OptionList", 1)
end
function onKeyDown_MENU_DOWN(movie)
  return LIB.ListClassVerticalScroll(movie, "OptionList", 1)
end
function RestartBackgroundVideo(movie)
  gRegion:StartVideoTexture(binkTexture)
end

local LIB = require("D2.Menus.SharedLibrary")
itemDisplayMovie = WeakResource()
itemDisplayPCMovie = WeakResource()
itemControlsMovie = WeakResource()
itemAudioMovie = WeakResource()
itemGameMovie = WeakResource()
itemSecretsMovie = WeakResource()
sndBack = Resource()
sndScroll = Resource()
sndSelect = Resource()
transitionMovie = WeakResource()
inGameBink = WeakResource()
demoGameRulesPAX = WeakResource()
binkTexture = Resource()
hudMovie = WeakResource()
lobbyHudMovie = WeakResource()
local itemDisplay = "/D2/Language/Menu/Options_Main_Display"
local itemControls = "/D2/Language/Menu/Options_Main_Controls"
local itemAudio = "/D2/Language/Menu/Options_Main_Audio"
local itemGame = "/D2/Language/Menu/Options_Main_Game"
local itemSecrets = "/D2/Language/Menu/Options_Main_Secrets"
local itemList = {
  itemDisplay,
  itemControls,
  itemAudio,
  itemGame
}
local itemListPAX = {
  itemDisplay,
  itemControls,
  itemAudio,
  itemGame
}
local statusSelect = "/D2/Language/Menu/Shared_Select"
local statusBack = "/D2/Language/Menu/Shared_Back"
local statusList = {statusSelect, statusBack}
local mBanner, mMovieInstance
local saveCallbackCompleted = false
local mIsInDemoPAX = false
local mPaxFrontendBinkName = "/D2/Videos/PauseMenu/PauseMenuA.bik"
local mPaxFrontendMenuName = "/D2/Menus/DemoPause.swf"
local mIsSecretsOptionVisible = false
local mIsQuitting = false
local mIsSaving = false
local timeDisplayedMax = 10
local timeDisplayed = 0
local mPrevDeviceId
function Initialize(movie)
  local hudInstance = gFlashMgr:FindMovie(hudMovie)
  local lobbyHudMovie = gFlashMgr:FindMovie(lobbyHudMovie)
  if (hudInstance == nil and lobbyHudMovie == nil or not gRegion:GetGameRules():IsPauseMenuShowing()) and not LIB.IsInFrontend() then
    movie:Close()
    return
  end
  mIsQuitting = false
  mBanner = LIB.BannerInitialize(movie)
  mMovieInstance = movie
  mIsInDemoPAX = not IsNull(demoGameRulesPAX) and gRegion:GetGameRules():IsA(demoGameRulesPAX)
  if LIB.IsInFrontend() then
    LIB.PlayBackgroundBink(movie, binkTexture)
  end
  if IsNull(Engine.GetPlayerProfileMgr():GetPlayerProfile(0)) then
    Engine.GetPlayerProfileMgr():LogIn(1, false, false, gFlashMgr:GetExclusiveDeviceID(), "")
  end
  movie:SetLocalized("Title.TxtHolder.Txt.text", "/D2/Language/Menu/Options_Main_Title")
  movie:SetVariable("Title.TxtHolder.Txt.textAlign", "left")
  if mIsInDemoPAX then
    for i = 1, #itemListPAX do
      FlashMethod(movie, "OptionList.ListClass.AddItem", itemListPAX[i], false)
    end
  else
    for i = 1, #itemList do
      FlashMethod(movie, "OptionList.ListClass.AddItem", itemList[i], false)
    end
  end
  FlashMethod(movie, "OptionList.ListClass.SetLetterSpacing", 2)
  FlashMethod(movie, "OptionList.ListClass.SetAlignment", "left")
  FlashMethod(movie, "OptionList.ListClass.SetPressedCallback", "ListButtonPressed")
  FlashMethod(movie, "OptionList.ListClass.SetSelectedCallback", "ListButtonChanged")
  FlashMethod(movie, "OptionList.ListClass.SetSelected", 0)
  for i = 1, #statusList do
    FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", statusList[i], statusList[i] ~= statusSelect)
  end
  FlashMethod(movie, "StatusBar.StatusBarClass.SetCallbackOnPress", "StatusButtonPressed")
end
function Shutdown(movie)
  if mPrevDeviceId ~= nil then
    mPrevDeviceId = nil
  end
end
function OnSaveCompleted(success)
  print("OptionsMain.lua: OnSaveCompleted(): save complete: " .. tostring(success))
  saveCallbackCompleted = true
end
local function SaveProfile()
  if Engine.GetPlayerProfileMgr():IsLoggedIn() then
    mIsSaving = true
    Engine.GetPlayerProfileMgr():ScriptSaveProfile(0, "OnSaveCompleted")
  else
    saveCallbackCompleted = true
  end
end
local PlaySound = function(sound)
  gRegion:PlaySound(sound, Vector(), false)
end
function OnMovieReady(childMovie)
  local platform = mMovieInstance:GetVariable("$platform")
  if platform == "WINDOWS" then
    mIsQuitting = false
  end
  if mPrevDeviceId ~= nil then
    mPrevDeviceId = nil
  end
  if not IsNull(childMovie) then
    if mIsInDemoPAX and gFlashMgr:FindMovie(WeakResource(mPaxFrontendMenuName)) then
      childMovie:SetTexture("BinkPlaceholder.png", Resource(mPaxFrontendBinkName))
    else
      childMovie:SetTexture("BinkPlaceholder.png", Resource(inGameBink:GetResourceName()))
      mMovieInstance:GetParent():Execute("SetWaitingForAsyncMovie", "0")
    end
  end
end
local function PlayTransition(movie, destinationMovie)
  if LIB.IsInFrontend() then
    if destinationMovie ~= nil then
      local childMovie = movie:PushChildMovie(destinationMovie)
      if childMovie ~= nil then
        childMovie:SetTexture("BinkPlaceholder.png", binkTexture)
      end
    else
      LIB.DoScreenTransition(movie, LIB.TRANSITION_DESTINATON_PARENT_SCREEN, transitionMovie, LIB.TRANSITON_VIDEO_OPTIONS_1)
    end
  else
    local platform = mMovieInstance:GetVariable("$platform")
    if platform == "WINDOWS" then
      mIsQuitting = true
    end
    mPrevDeviceId = gFlashMgr:GetExclusiveDeviceID()
    mMovieInstance:GetParent():Execute("SetWaitingForAsyncMovie", "1")
    movie:PushChildMovieAsync(destinationMovie, "OnMovieReady")
  end
end
local function Close(movie)
  if LIB.IsInFrontend() then
    PlayTransition(movie, nil)
  else
    movie:Close()
  end
end
local function Back(movie)
  if mIsQuitting then
    return
  end
  mIsQuitting = true
  PlaySound(sndBack)
  FlashMethod(movie, "OptionList.ListClass.SetEnabled", false)
  if (Engine.GetPlayerProfileMgr():GetPlayerProfile(0):Settings():IsDirty() or Engine.GetPlayerProfileMgr():GetPlayerProfile(0):GetGameSpecificData() and Engine.GetPlayerProfileMgr():GetPlayerProfile(0):GetGameSpecificData():IsDirty()) and Engine.GetPlayerProfileMgr():GetPlayerProfile(0):SavingEnabled() then
    mBanner.loc = "/D2/Language/Menu/Profile_SavingPleaseWait"
    mBanner.state = mBanner.STATE_Show
    mBanner.line = mBanner.LINE_Double
    mBanner.spinner = true
    LIB.BannerDisplay(movie, mBanner)
    SaveProfile()
  end
  if not mIsSaving then
    Close(movie)
  end
end
function Update(movie)
  if mIsSaving then
    local rt = RealDeltaTime()
    if timeDisplayed <= 1 then
      timeDisplayedMax = 1
    else
      timeDisplayedMax = 3
    end
    timeDisplayed = timeDisplayed + rt
    if saveCallbackCompleted and timeDisplayed > timeDisplayedMax then
      print(string.format("@@@ End Saving max=%f, spent=%f", timeDisplayedMax, timeDisplayed))
      mIsSaving = false
      Close(movie)
    end
  end
end
function onKeyDown_MENU_CANCEL(movie)
  Back(movie)
end
function StatusButtonPressed(movie, buttonArg)
  local index = tonumber(buttonArg) + 1
  if statusList[index] == statusBack then
    Back(movie)
  end
end
function ListButtonChanged(movie, buttonArg)
  if mIsQuitting then
    return
  end
  PlaySound(sndScroll)
end
function ListButtonPressed(movie, buttonArg)
  if mIsQuitting then
    return
  end
  local index = tonumber(buttonArg) + 1
  PlaySound(sndSelect)
  if itemList[index] == itemDisplay then
    if LIB.IsPC(movie) then
      PlayTransition(movie, itemDisplayPCMovie)
    else
      PlayTransition(movie, itemDisplayMovie)
    end
  elseif itemList[index] == itemControls then
    PlayTransition(movie, itemControlsMovie)
  elseif itemList[index] == itemAudio then
    PlayTransition(movie, itemAudioMovie)
  elseif itemList[index] == itemGame then
    PlayTransition(movie, itemGameMovie)
  elseif itemList[index] == itemSecrets then
    PlayTransition(movie, itemSecretsMovie)
  end
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
local function RevealSecretsMenu(movie)
  if not mIsInDemoPAX and not mIsSecretsOptionVisible then
    itemList[#itemList + 1] = itemSecrets
    FlashMethod(movie, "OptionList.ListClass.AddItem", itemSecrets, false)
    mIsSecretsOptionVisible = true
  end
end
function onKeyDown_MENU_LTRIGGER1(movie)
  if Engine.GameRules_CheatsEnabled() then
    RevealSecretsMenu(movie)
  end
  return 1
end
function onKeyDown_MENU_LTRIGGER2(movie)
  if Engine.GameRules_CheatsEnabled() then
    RevealSecretsMenu(movie)
  end
  return 1
end
function RestartBackgroundVideo(movie)
  LIB.PlayBackgroundBink(movie, binkTexture)
end

local LIB = require("D2.Menus.SharedLibrary")
sndBack = Resource()
sndSelected = Resource()
sndConfirm = Resource()
music = Resource()
binkTexture = Resource()
optionsMovie = Resource()
optionsSubMovies = {
  Resource()
}
local mGameRules, mIsMultiplayer, mIsHosting, mIsDisplayingDisclaimer, mIsDisplayingOptions, mStartButtonIsDown
local queueOptions = false
local PlaySound = function(sound)
  gRegion:PlaySound(sound, Vector(), false)
end
local SetPressStartState = function(movie)
  FlashMethod(movie, "OptionList.ListClass.EraseItems")
  FlashMethod(movie, "OptionList.ListClass.AddItem", "Press Start", false)
  movie:SetVariable("OptionList._y", 400)
  FlashMethod(movie, "OptionList.ListClass.SetAlignment", "center")
  FlashMethod(movie, "OptionList.ListClass.SetSelected", 0)
end
local SetOptionsState = function(movie)
  FlashMethod(movie, "OptionList.ListClass.EraseItems")
  FlashMethod(movie, "OptionList.ListClass.AddItem", "New Game")
  FlashMethod(movie, "OptionList.ListClass.AddItem", "Options")
  movie:SetVariable("OptionList._y", 425)
  FlashMethod(movie, "OptionList.ListClass.SetAlignment", "center")
  FlashMethod(movie, "OptionList.ListClass.SetSelected", 0)
end
function Initialize(movie)
  movie:SetTexture("BinkPlaceholder.png", binkTexture)
  gRegion:StartVideoTexture(binkTexture)
  if not Engine.GetPlayerProfileMgr():IsLoggedIn() then
    Engine.GetPlayerProfileMgr():LogIn(1, false, false, 0)
  end
  SetPressStartState(movie)
  mIsHosting = false
  if Engine.GetMatchingService():GetState() == 0 then
    mIsMultiplayer = false
    mGameRules = gRegion:GetGameRules()
  end
  mStartButtonIsDown = false
  mIsDisplayingDisclaimer = false
  mIsDisplayingOptions = false
  mGameRules:RequestPause()
  LIB.PlayGlobalMusicTrack(music)
end
function Update(movie)
end
local function StartDemo(movie)
  if not mIsDisplayingDisclaimer then
    LIB.StopGlobalMusicTrack(music)
    mIsDisplayingDisclaimer = true
    FlashMethod(movie, "gotoAndPlay", 2)
    if Engine.GetPlayerProfileMgr():IsLoggedIn() then
      Engine.GetPlayerProfileMgr():GetPlayerProfile(0):ClearGameSpecificData()
      gRegion:GetGameRules():InitializeGameSpecificProfileData()
    end
  end
end
function OnDisclaimerFinished(movie)
  mGameRules:RequestUnpause()
  movie:Close()
  gRegion:StopVideoTexture(binkTexture)
end
function onKeyDown_MENU_CANCEL(movie)
  if mIsDisplayingOptions and not mIsDisplayingDisclaimer then
    PlaySound(sndBack)
    mIsDisplayingOptions = false
    SetPressStartState(movie)
  end
end
local function OnOptionSelected(movie, index)
  if not mIsDisplayingDisclaimer then
    if mIsDisplayingOptions then
      index = tonumber(index)
      if index == 0 then
        StartDemo(movie)
      else
        queueOptions = true
      end
    else
      PlaySound(sndConfirm)
      mIsDisplayingOptions = true
      SetOptionsState(movie)
    end
  end
end
function onKeyDown_HIDE_PAUSE_MENU(movie)
  mStartButtonIsDown = true
end
function onKeyUp_HIDE_PAUSE_MENU(movie)
  if mStartButtonIsDown and not mIsDisplayingDisclaimer then
    if not mIsDisplayingOptions then
      PlaySound(sndConfirm)
      mIsDisplayingOptions = true
      SetOptionsState(movie)
    else
      PlaySound(sndConfirm)
      local index = movie:GetVariable("OptionList.ListClass.mCurrentSelection")
      OnOptionSelected(movie, index)
    end
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
  if mIsDisplayingOptions and not mIsDisplayingDisclaimer then
    PlaySound(sndSelected)
  end
  return LIB.ListClassVerticalScroll(movie, "OptionList", 1)
end
function onKeyDown_MENU_UP(movie)
  if mIsDisplayingOptions and not mIsDisplayingDisclaimer then
    PlaySound(sndSelected)
  end
  return LIB.ListClassVerticalScroll(movie, "OptionList", 1)
end
function onKeyDown_MENU_DOWN_FROM_ANALOG(movie)
  if mIsDisplayingOptions and not mIsDisplayingDisclaimer then
    PlaySound(sndSelected)
  end
  return LIB.ListClassVerticalScroll(movie, "OptionList", -1)
end
function onKeyDown_MENU_DOWN(movie)
  if mIsDisplayingOptions and not mIsDisplayingDisclaimer then
    PlaySound(sndSelected)
  end
  return LIB.ListClassVerticalScroll(movie, "OptionList", -1)
end
function onKeyUp_MENU_SELECT(movie)
  if queueOptions then
    queueOptions = false
    local options = movie:PushChildMovie(optionsMovie)
    options:SetTexture("BinkPlaceholder.png", binkTexture)
  end
end
function onKeyDown_MENU_SELECT(movie)
  if not mIsDisplayingDisclaimer then
    PlaySound(sndConfirm)
    local index = movie:GetVariable("OptionList.ListClass.mCurrentSelection")
    OnOptionSelected(movie, index)
  end
end

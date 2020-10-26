local LIB = require("D2.Menus.SharedLibrary")
optionsMovieWRes = WeakResource()
transitionMovie = WeakResource()
popupConfirmMovie = WeakResource()
sndBack = Resource()
sndScroll = Resource()
sndSelect = Resource()
local SELECTION_Invalid = -1
local mCurSelection, mPlayerProfile, mProfileSettings
local mIsOptionsFlow = false
local mMovie, mPopupMovie
local itemBrightness = "/D2/Language/Menu/Options_Display_Brightness"
local itemList = {itemBrightness}
local statusSelect = "/D2/Language/Menu/Shared_Select"
local statusHToggle = "/D2/Language/Menu/Shared_HToggle"
local statusDefault = "/D2/Language/Menu/Shared_Defaults"
local statusBack = "/D2/Language/Menu/Shared_Back"
local statusConfirm = "/D2/Language/Menu/Shared_Select"
local statusList = {
  statusHToggle,
  statusDefault,
  statusBack
}
local PlaySound = function(sound)
  gRegion:PlaySound(sound, Vector(), false)
end
local function SetBrightness(brightness)
  FlashMethod(mMovie, "setBrightness", brightness * 100)
  mProfileSettings:SetBrightness(brightness)
  return mProfileSettings:BrightnessPercent()
end
local function SetDefaults(movie)
  mProfileSettings:SetBrightnessDefaults()
  local brightness = mProfileSettings:BrightnessPercent() * 100
  FlashMethod(mMovie, "setBrightness", brightness)
  FlashMethod(movie, "BrightnessScroll.ScrollClass.SetScrubberPos", brightness)
  PlaySound(sndSelect)
end
function BrightnessB0Callback(movie, id)
  PlaySound(sndSelect)
  local v = movie:GetVariable("BrightnessScroll.ScrollClass.mPosition") / 100
  SetBrightness(v)
end
function BrightnessB1Callback(movie, id)
  PlaySound(sndSelect)
  local v = movie:GetVariable("BrightnessScroll.ScrollClass.mPosition") / 100
  SetBrightness(v)
end
function BrightnessScrubberMoveCallback(movie, id)
  local v = movie:GetVariable("BrightnessScroll.ScrollClass.mPosition") / 100
  SetBrightness(v)
end
local function adjustBrightness(movie, up)
  local currentBrightness = mProfileSettings:BrightnessPercent()
  if up then
    currentBrightness = currentBrightness + 0.1
  else
    currentBrightness = currentBrightness - 0.1
  end
  currentBrightness = SetBrightness(currentBrightness)
  FlashMethod(movie, "BrightnessScroll.ScrollClass.SetScrubberPos", currentBrightness * 100)
  PlaySound(sndSelect)
end
function Initialize(movie)
  mMovie = movie
  local foundMovie = gFlashMgr:FindMovie(optionsMovieWRes)
  if not IsNull(foundMovie) then
    mIsOptionsFlow = true
  else
    mIsOptionsFlow = false
  end
  movie:SetLocalized("Description.text", "/D2/Language/Menu/Brightness_Description")
  mPlayerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  mProfileSettings = mPlayerProfile:Settings()
  movie:SetLocalized("Title.TxtHolder.Txt.text", "/D2/Language/Menu/Options_Display_Title")
  for i = 1, #itemList do
    FlashMethod(movie, "OptionList.ListClass.AddItem", itemList[i], false)
  end
  FlashMethod(movie, "OptionList.ListClass.SetAlignment", "right")
  FlashMethod(movie, "OptionList.ListClass.SetPressedCallback", "ListButtonPressed")
  FlashMethod(movie, "OptionList.ListClass.SetSelectedCallback", "ListButtonSelected")
  mCurSelection = SELECTION_Invalid
  FlashMethod(movie, "OptionList.ListClass.SetSelected", 0)
  FlashMethod(movie, "OptionList.ListClass.SetupList")
  if not mIsOptionsFlow and LIB.IsPC(movie) then
    table.insert(statusList, 1, statusConfirm)
    movie:SetLocalized("continueBtn.label.text", "/D2/Language/Menu/MainMenu_Item_Continue")
  else
    table.insert(statusList, 1, statusSelect)
    movie:SetVariable("continueBtn._visible", false)
  end
  movie:SetVariable("continueBtn.noMenuSelection", true)
  for i = 1, #statusList do
    FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", statusList[i], statusList[i] ~= statusHToggle)
  end
  FlashMethod(movie, "StatusBar.StatusBarClass.SetCallbackOnPress", "StatusButtonPressed")
  if mIsOptionsFlow then
    FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByName", statusSelect, false)
  end
  FlashMethod(movie, "BrightnessScroll.ScrollClass.SetRange", 100)
  FlashMethod(movie, "BrightnessScroll.ScrollClass.SetScrubberPos", mProfileSettings:BrightnessPercent() * 100)
  FlashMethod(movie, "BrightnessScroll.ScrollClass.SetButton0PressedCallback", "BrightnessB0Callback")
  FlashMethod(movie, "BrightnessScroll.ScrollClass.SetButton1PressedCallback", "BrightnessB1Callback")
  FlashMethod(movie, "BrightnessScroll.ScrollClass.SetScrubberMoveCallback", "BrightnessScrubberMoveCallback")
  FlashMethod(movie, "setBrightness", mProfileSettings:BrightnessPercent() * 100)
end
local function Back(movie)
  local profile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  local profileData
  if not IsNull(profile) then
    profileData = profile:GetGameSpecificData()
  end
  if not IsNull(profileData) then
    profileData:SetStartingNewGamePlus(false)
  end
  PlaySound(sndBack)
  movie:Close()
end
function onKeyDown_MENU_GENERIC1(movie)
  SetDefaults(movie)
end
function onKeyDown_MENU_GENERIC2(movie)
  return 1
end
function onKeyDown_MENU_CANCEL(movie)
  Back(movie)
end
local function TransitionOut(movie)
  gRegion:PlaySound(sndSelect, Vector(), false)
  if not mIsOptionsFlow then
    local difficultyIdx = 0
    local parentMovie = movie:GetParent()
    if not IsNull(parentMovie) then
      difficultyIdx = parentMovie:GetVariable("_root.Difficulty")
    end
    local difficultyTable = LIB.GetDifficultyTable()
    local theLevel = difficultyTable[difficultyIdx + 1]
    mPlayerProfile:Settings():SetDifficulty(theLevel.difficulty)
    mPopupMovie = movie:PushChildMovie(popupConfirmMovie)
    mPopupMovie:Execute("SetTransitionInDoneCallback", "NewGameVideoPopupTransitionInDone")
  end
end
function NewGameVideoPopupTransitionInDone(movie)
  FlashMethod(mPopupMovie, "CreateList", "ConfirmNewGameVideo", "ConfirmListButtonSelected", "ConfirmListButtonUnselected")
  FlashMethod(mPopupMovie, "OptionList.ListClass.AddItem", "/D2/Language/Menu/Confirm_Item_Yes", false)
  FlashMethod(mPopupMovie, "OptionList.ListClass.AddItem", "/D2/Language/Menu/Confirm_Item_No", false)
  FlashMethod(mPopupMovie, "OptionList.ListClass.AddItem", "/D2/Language/Menu/Confirm_Item_Cancel", false)
  FlashMethod(mPopupMovie, "OptionList.ListClass.SetAlignment", "center")
  FlashMethod(mPopupMovie, "OptionList.ListClass.SetSelected", 0)
  mPopupMovie:Execute("SetDescription", "/D2/Language/Menu/Options_Display_NewGameVideoConfirm")
end
function ConfirmListButtonSelected(movie, buttonArg)
  gRegion:PlaySound(sndScroll, Vector(), false)
end
function ConfirmListButtonUnselected(movie, buttonArg)
end
function ConfirmNewGameVideo(movie, args)
  gRegion:PlaySound(sndSelect, Vector(), false)
  mPopupMovie:Close()
  mPopupMovie = nil
  local selection = tonumber(args)
  if selection == 0 then
    LIB.DoScreenTransition(movie, LIB.TRANSITION_DESTINATON_PLAY_NEW_GAME_VIDEO, transitionMovie, LIB.TRANSITON_VIDEO_MAIN_MENU)
  elseif selection == 1 then
    LIB.DoScreenTransition(movie, LIB.TRANSITION_DESTINATON_START_NEW_GAME, transitionMovie, LIB.TRANSITON_VIDEO_MAIN_MENU)
  end
  return 1
end
function StatusButtonPressed(movie, buttonArg)
  local index = tonumber(buttonArg) + 1
  if statusList[index] == statusDefault then
    SetDefaults(movie)
  elseif statusList[index] == statusBack then
    Back(movie)
  elseif statusList[index] == statusConfirm then
    TransitionOut(movie)
  end
end
function Confirm(movie)
  TransitionOut(movie)
end
local function AdjustBrightness(movie, up)
  adjustBrightness(movie, up)
end
function onKeyDown_MENU_LEFT_FROM_ANALOG(movie)
  AdjustBrightness(movie, false)
  return true
end
function onKeyDown_MENU_LEFT(movie)
  AdjustBrightness(movie, false)
  return true
end
function onKeyDown_MENU_RIGHT_FROM_ANALOG(movie)
  AdjustBrightness(movie, true)
  return true
end
function onKeyDown_MENU_RIGHT(movie)
  AdjustBrightness(movie, true)
  return true
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
function ListButtonSelected(movie, buttonArg)
  mCurSelection = tonumber(buttonArg) + 1
end
function ListButtonPressed(movie, buttonArg)
  TransitionOut(movie)
end
function onKeyDown_MENU_SELECT(movie, device)
  if not LIB.IsPCInputDevice(tonumber(device)) then
    TransitionOut(movie)
  end
end

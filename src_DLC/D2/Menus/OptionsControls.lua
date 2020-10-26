local LIB = require("D2.Menus.SharedLibrary")
sndBack = Resource()
sndScroll = Resource()
sndSelect = Resource()
movieCustomizeControls = WeakResource()
movieControllerLayout = WeakResource()
demoGameRulesPAX = WeakResource()
binkTexture = Resource()
local SELECTION_Invalid = -1
local mCurSelection = -1
local mStickLayout = {}
local mStickIndex, mPlayerProfile, mProfileSettings, hostSettings, sessionSettings, focusedOptionsItem, scrollableItems
local itemAimSensitivity = "/D2/Language/Menu/Options_Controls_AimSensitivity"
local itemAimAssist = "/D2/Language/Menu/Options_Controls_AimAssist"
local itemVibration = "/D2/Language/Menu/Options_Controls_Vibration"
local itemInvertY = "/D2/Language/Menu/Options_Controls_InvertY"
local itemSouthPawControls = "/D2/Language/Menu/Options_Controls_SouthPaw"
local itemSwapFireButtons = "/D2/Language/Menu/Options_Controls_SwapFireButtonsWhenDualWielding"
local itemCustomizeControls = "/D2/Language/Menu/Options_Controls_CustomizeControls"
local itemControllerLayout = "/D2/Language/Menu/Options_Controls_ControllerLayout"
local itemList = {
  itemAimSensitivity,
  itemAimAssist,
  itemVibration,
  itemInvertY,
  itemSouthPawControls
}
local statusSelect = "/D2/Language/Menu/Shared_Select"
local statusToggle = "/D2/Language/Menu/Shared_HToggle"
local statusDefault = "/D2/Language/Menu/Shared_Defaults"
local statusBack = "/D2/Language/Menu/Shared_Back"
local statusList = {
  statusSelect,
  statusToggle,
  statusDefault,
  statusBack
}
local mMovieInstance, mPrevDeviceId
local PlaySound = function(sound)
  gRegion:PlaySound(sound, Vector(), false)
end
local PopulateList = function(movie)
end
local function SetAimSensitivity(sensitivityPercent)
  mProfileSettings:SetAimSensitivity(sensitivityPercent)
  return mProfileSettings:AimSensitivityPercent()
end
function SensitivityB0Callback(movie, id)
  PlaySound(sndSelect)
  local v = tonumber(movie:GetVariable("SensitivityScroll.ScrollClass.mPosition")) / 100
  SetAimSensitivity(v)
end
function SensitivityB1Callback(movie, id)
  PlaySound(sndSelect)
  local v = tonumber(movie:GetVariable("SensitivityScroll.ScrollClass.mPosition")) / 100
  SetAimSensitivity(v)
end
function SensitivityScrubberMoveCallback(movie, id)
  local v = tonumber(movie:GetVariable("SensitivityScroll.ScrollClass.mPosition")) / 100
  SetAimSensitivity(v)
end
function Initialize(movie)
  local platform = movie:GetVariable("$platform")
  if platform == "WINDOWS" then
    itemAimAssist = "/D2/Language/Menu/Options_Controls_AimAssistPC"
  end
  itemList = {
    itemAimSensitivity,
    itemAimAssist,
    itemVibration,
    itemInvertY,
    itemSouthPawControls
  }
  mMovieInstance = movie
  mPlayerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  mProfileSettings = mPlayerProfile:Settings()
  if LIB.IsInFrontend() then
    movie:SetTexture("BinkPlaceholder.png", binkTexture)
    gRegion:StartVideoTexture(binkTexture)
  end
  movie:SetLocalized("Title.TxtHolder.Txt.text", "/D2/Language/Menu/Options_Controls_Title")
  movie:SetVariable("Title.TxtHolder.Txt.textAlign", "center")
  mStickLayout = {
    "/D2/Language/Menu/Options_Controls_StickLayout1",
    "/D2/Language/Menu/Options_Controls_StickLayout2"
  }
  mStickIndex = 1
  local currentAimSensitivity = mProfileSettings:AimSensitivityPercent()
  FlashMethod(movie, "SensitivityScroll.ScrollClass.SetRange", 100)
  FlashMethod(movie, "SensitivityScroll.ScrollClass.SetScrubberPos", currentAimSensitivity * 100)
  FlashMethod(movie, "SensitivityScroll.ScrollClass.SetButton0PressedCallback", "SensitivityB0Callback")
  FlashMethod(movie, "SensitivityScroll.ScrollClass.SetButton1PressedCallback", "SensitivityB1Callback")
  FlashMethod(movie, "SensitivityScroll.ScrollClass.SetScrubberMoveCallback", "SensitivityScrubberMoveCallback")
  FlashMethod(movie, "AimAssist.CheckBoxClass.SetChecked", mProfileSettings:AimAssist())
  FlashMethod(movie, "InvertY.CheckBoxClass.SetChecked", mProfileSettings:CameraInverted())
  FlashMethod(movie, "Vibration.CheckBoxClass.SetChecked", mProfileSettings:ForceFeedback())
  FlashMethod(movie, "SouthPaw.CheckBoxClass.SetChecked", mProfileSettings:SouthpawControlsEnabled())
  FlashMethod(movie, "DualWieldSwap.CheckBoxClass.SetChecked", mProfileSettings:SwapFireButtonsWhenDualWielding())
  movie:SetVariable("AimAssist.CheckBoxClass.mSelectedColor", LIB.SELECTED_COLOR)
  movie:SetVariable("InvertY.CheckBoxClass.mSelectedColor", LIB.SELECTED_COLOR)
  movie:SetVariable("Vibration.CheckBoxClass.mSelectedColor", LIB.SELECTED_COLOR)
  movie:SetVariable("SouthPaw.CheckBoxClass.mSelectedColor", LIB.SELECTED_COLOR)
  movie:SetVariable("DualWieldSwap.CheckBoxClass.mSelectedColor", LIB.SELECTED_COLOR)
  movie:SetVariable("DualWieldSwap._visible", false)
  mCurSelection = SELECTION_Invalid
  if IsNull(demoGameRulesPAX) or not gRegion:GetGameRules():IsA(demoGameRulesPAX) then
    itemList[#itemList + 1] = itemControllerLayout
    if LIB.IsPC(movie) then
      itemList[#itemList + 1] = itemCustomizeControls
    end
  end
  for i = 1, #itemList do
    FlashMethod(movie, "OptionList.ListClass.AddItem", itemList[i], false)
  end
  FlashMethod(movie, "OptionList.ListClass.SetAlignment", "right")
  FlashMethod(movie, "OptionList.ListClass.SetPressedCallback", "ListButtonPressed")
  FlashMethod(movie, "OptionList.ListClass.SetSelectedCallback", "ListButtonSelected")
  FlashMethod(movie, "OptionList.ListClass.SetUnselectedCallback", "ListButtonUnselected")
  FlashMethod(movie, "OptionList.ListClass.SetSelected", 0)
  for i = 1, #statusList do
    FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", statusList[i], statusList[i] ~= statusSelect and statusList[i] ~= statusToggle)
  end
  FlashMethod(movie, "StatusBar.StatusBarClass.SetCallbackOnPress", "StatusButtonPressed")
end
local function ToggleInvertY(movie)
  local newState = not mProfileSettings:CameraInverted()
  mProfileSettings:SetCameraInverted(newState)
  FlashMethod(movie, "InvertY.CheckBoxClass.SetChecked", newState)
  PlaySound(sndSelect)
end
local function ToggleVibration(movie)
  local newState = not mProfileSettings:ForceFeedback()
  mProfileSettings:SetForceFeedback(newState)
  FlashMethod(movie, "Vibration.CheckBoxClass.SetChecked", newState)
  PlaySound(sndSelect)
end
local function ToggleAimAssist(movie)
  local newState = not mProfileSettings:AimAssist()
  mProfileSettings:SetAimAssist(newState)
  FlashMethod(movie, "AimAssist.CheckBoxClass.SetChecked", newState)
  PlaySound(sndSelect)
end
local function ToggleSouthPaw(movie)
  local newState = not mProfileSettings:SouthpawControlsEnabled()
  mProfileSettings:SetSouthpawControlsEnabled(newState)
  PlaySound(sndSelect)
  FlashMethod(movie, "SouthPaw.CheckBoxClass.SetChecked", newState)
end
local function AdjustSwapFireButtons(movie)
  local newState = not mProfileSettings:SwapFireButtonsWhenDualWielding()
  mProfileSettings:SetSwapFireButtonsWhenDualWielding(newState)
  PlaySound(sndSelect)
  FlashMethod(movie, "DualWieldSwap.CheckBoxClass.SetChecked", newState)
end
function CheckBoxSelected(movie, cbName)
end
function CheckBoxUnselected(movie, cbName)
end
function CheckBoxPressed(movie, cbName)
  if cbName == "Vibration" then
    ToggleVibration(movie)
  elseif cbName == "InvertY" then
    ToggleInvertY(movie)
  elseif cbName == "SouthPaw" then
    ToggleSouthPaw(movie)
  elseif cbName == "DualWieldSwap" then
    AdjustSwapFireButtons(movie)
  elseif cbName == "AimAssist" then
    ToggleAimAssist(movie)
  end
end
local function adjustAimSensitivity(movie, up)
  local currentAimSensitivity = mProfileSettings:AimSensitivityPercent()
  if up then
    currentAimSensitivity = currentAimSensitivity + 0.1
  else
    currentAimSensitivity = currentAimSensitivity - 0.1
  end
  currentAimSensitivity = SetAimSensitivity(currentAimSensitivity)
  FlashMethod(movie, "SensitivityScroll.ScrollClass.SetScrubberPos", currentAimSensitivity * 100)
  PlaySound(sndSelect)
end
local function Adjust(movie, up)
  if mCurSelection == SELECTION_Invalid then
    return
  end
  if itemList[mCurSelection] == itemAimSensitivity then
    adjustAimSensitivity(movie, up)
  end
end
function onKeyDown_MENU_LEFT_FROM_ANALOG(movie)
  Adjust(movie, false)
  return true
end
function onKeyDown_MENU_LEFT(movie)
  Adjust(movie, false)
  return true
end
function onKeyDown_MENU_RIGHT_FROM_ANALOG(movie)
  Adjust(movie, true)
  return true
end
function onKeyDown_MENU_RIGHT(movie)
  Adjust(movie, true)
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
local function Back(movie)
  PlaySound(sndBack)
  mMovieInstance:Close()
end
local function SetDefaults(movie)
  mProfileSettings:SetControlsDefaults()
  FlashMethod(movie, "SensitivityScroll.ScrollClass.SetScrubberPos", mProfileSettings:AimSensitivityPercent() * 100)
  FlashMethod(movie, "AimAssist.CheckBoxClass.SetChecked", mProfileSettings:AimAssist())
  FlashMethod(movie, "InvertY.CheckBoxClass.SetChecked", mProfileSettings:CameraInverted())
  FlashMethod(movie, "Vibration.CheckBoxClass.SetChecked", mProfileSettings:ForceFeedback())
  FlashMethod(movie, "SouthPaw.CheckBoxClass.SetChecked", mProfileSettings:SouthpawControlsEnabled())
  PlaySound(sndSelect)
end
function onKeyDown_MENU_CANCEL(movie)
  Back(movie)
end
function StatusButtonPressed(movie, buttonArg)
  local index = tonumber(buttonArg) + 1
  if statusList[index] == statusDefault then
    SetDefaults(movie)
  elseif statusList[index] == statusBack then
    Back(movie)
  end
end
function onKeyDown_MENU_GENERIC1(movie)
  SetDefaults(movie)
end
local function HighlightControl(movie, index, on)
  local clip
  if itemList[index] == itemAimSensitivity then
    clip = "SensitivityScroll"
  elseif itemList[index] == itemAimAssist then
    clip = "AimAssist"
  elseif itemList[index] == itemVibration then
    clip = "Vibration"
  elseif itemList[index] == itemInvertY then
    clip = "InvertY"
  elseif itemList[index] == itemSouthPawControls then
    clip = "SouthPaw"
  end
  if not IsNull(clip) then
    local newColor = 16777215
    if on then
      newColor = LIB.SELECTED_COLOR
    end
    movie:SetVariable(clip .. "._color", newColor)
  end
end
function ListButtonUnselected(movie, buttonArg)
  local btn = tonumber(buttonArg) + 1
  HighlightControl(movie, btn, false)
end
function ListButtonSelected(movie, buttonArg)
  if 0 <= mCurSelection then
    PlaySound(sndScroll)
  end
  mCurSelection = tonumber(buttonArg) + 1
  FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByName", statusSelect, 1 < mCurSelection)
  FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByName", statusToggle, itemList[mCurSelection] == itemAimSensitivity)
  HighlightControl(movie, mCurSelection, true)
end
function OnMovieReady(newMovie)
  if mPrevDeviceId ~= nil then
  end
  if not IsNull(newMovie) then
    newMovie:SetTexture("BinkPlaceholder.png", binkTexture)
    PlaySound(sndSelect)
    if not LIB.IsInFrontend() then
      mMovieInstance:GetParent():GetParent():Execute("SetWaitingForAsyncMovie", "0")
    end
  end
end
function ListButtonPressed(movie, buttonArg)
  local index = tonumber(buttonArg) + 1
  if itemList[index] == itemAimAssist then
    ToggleAimAssist(movie)
  elseif itemList[index] == itemVibration then
    ToggleVibration(movie)
  elseif itemList[index] == itemInvertY then
    ToggleInvertY(movie)
  elseif itemList[index] == itemSouthPawControls then
    ToggleSouthPaw(movie)
  elseif itemList[index] == itemSwapFireButtons then
    AdjustSwapFireButtons(movie)
  elseif itemList[index] == itemControllerLayout then
    mPrevDeviceId = gFlashMgr:GetExclusiveDeviceID()
    if not LIB.IsInFrontend() then
      mMovieInstance:GetParent():GetParent():Execute("SetWaitingForAsyncMovie", "1")
    end
    movie:PushChildMovieAsync(movieControllerLayout, "OnMovieReady")
  elseif itemList[index] == itemCustomizeControls then
    mPrevDeviceId = gFlashMgr:GetExclusiveDeviceID()
    if not LIB.IsInFrontend() then
      mMovieInstance:GetParent():GetParent():Execute("SetWaitingForAsyncMovie", "1")
    end
    movie:PushChildMovieAsync(movieCustomizeControls, "OnMovieReady")
  end
end

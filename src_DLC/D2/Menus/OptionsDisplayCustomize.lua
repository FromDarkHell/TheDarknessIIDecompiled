local LIB = require("D2.Menus.SharedLibrary")
sndBack = Resource()
sndScroll = Resource()
sndSelect = Resource()
itemBrightnessMovie = WeakResource()
popupConfirmMovie = WeakResource()
binkTexture = Resource()
local mPlayerProfile, mProfileSettings
local mIsOptionsFlow = false
local mMovie, mPopupMovie, mDecals, mActiveDisplayMode
local mBestDisplayModes = {}
local mSelectedItem = -1
local mResolutionExpanded = false
local mHasChangedSettings = false
local mCurrentSettings, mPopupMovie, mCachedResolution
local mCachedFullscreen = false
local mRevertTimer
local mCloseAttempted = false
local mAspectRatioEnabled = true
local mFOVIdx = 0
local itemResolution = "/D2/Language/Menu/Options_DisplayCustomize_VideoResolution"
local itemDisplayMode = "/D2/Language/Menu/Options_DisplayCustomize_DisplayMode"
local itemAspectRatio = "/D2/Language/Menu/Options_DisplayCustomize_AspectRatio"
local itemFOV = "/D2/Language/Menu/Options_DisplayCustomize_FOV"
local itemTextureQuality = "/D2/Language/Menu/Options_DisplayCustomize_TextureQuality"
local itemShadowQuality = "/D2/Language/Menu/Options_DisplayCustomize_ShadowQuality"
local itemVerticalSync = "/D2/Language/Menu/Options_DisplayCustomize_VerticalSync"
local itemDecals = "/D2/Language/Menu/Options_DisplayCustomize_Decals"
local itemBrightness = "/D2/Language/Menu/Options_DisplayCustomize_Brightness"
local itemApply = "/D2/Language/Menu/Options_DisplayCustomize_Apply"
local itemList = {}
local itemKeepRes = "/D2/Language/Menu/Options_DisplayCustomize_KeepRes"
local itemRevertRes = "/D2/Language/Menu/Options_DisplayCustomize_RevertRes"
local itemResPopupQuestion = "/D2/Language/Menu/Options_DisplayCustomize_ResolutionPopupQuestion"
local itemResPopupTimer = "/D2/Language/Menu/Options_DisplayCustomize_ResolutionPopupTimer"
local itemLocCRLN = "/D2/Language/Menu/Shared_CRLN"
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
local popupItemApply = "/D2/Language/Menu/Options_DisplayCustomize_ApplyNow"
local popupItemDiscard = "/D2/Language/Menu/Options_DisplayCustomize_DiscardChanges"
local popupItemCancel = "/D2/Language/Menu/Confirm_Item_Cancel"
local confirmList = {
  popupItemApply,
  popupItemDiscard,
  popupItemCancel
}
local aspectRatios = {
  "/D2/Language/Menu/Options_DisplayCustomize_Auto",
  "4:3",
  "16:9",
  "16:10"
}
local BuildResolutionString = function(width, height, refreshRate, isWindowedOnly)
  local str = string.format("%i x %i", width, height)
  return str
end
local function BuildSupportedDisplayModeList(customDisplaySettings)
  local supportedDisplayMode = {}
  local graphicsSys = gClient:GetGraphicsSys()
  local numSupportedModes = customDisplaySettings:GetNumSupportedDisplayModes()
  for i = 1, numSupportedModes do
    local dm = customDisplaySettings:GetSupportedDisplayMode(i - 1)
    local idx = i - 1
    supportedDisplayMode[#supportedDisplayMode + 1] = {
      mode = dm,
      index = idx,
      isWindowedOnly = false
    }
  end
  local adm = customDisplaySettings:GetActiveDisplayMode()
  local admIdx = -1
  mBestDisplayModes = {}
  for i = 1, numSupportedModes do
    local sdm = supportedDisplayMode[i].mode
    local found = false
    for j = 1, #mBestDisplayModes do
      local bdm = mBestDisplayModes[j].mode
      if sdm.width == bdm.width and sdm.height == bdm.height then
        if sdm.refreshRate > bdm.refreshRate then
          mBestDisplayModes[j] = supportedDisplayMode[i]
        end
        found = true
        break
      end
    end
    if not found then
      mBestDisplayModes[#mBestDisplayModes + 1] = supportedDisplayMode[i]
    end
  end
  for j = 1, #mBestDisplayModes do
    local bdm = mBestDisplayModes[j].mode
    if bdm.width == adm.width and bdm.height == adm.height then
      admIdx = j - 1
      break
    end
  end
  if admIdx == -1 then
    admIdx = #mBestDisplayModes
    mBestDisplayModes[#mBestDisplayModes + 1] = {
      mode = adm,
      index = admIdx,
      isWindowedOnly = true
    }
  end
  mActiveDisplayMode = adm
  return tonumber(admIdx)
end
local PlaySound = function(sound)
  gRegion:PlaySound(sound, Vector(), false)
end
local function ToggleResolutionQuality(movie, dir)
  if dir == 1 then
    FlashMethod(movie, "ToggleResolution.ToggleListClass.NextItem")
  elseif dir == -1 then
    FlashMethod(movie, "ToggleResolution.ToggleListClass.PreviousItem")
  end
  PlaySound(sndSelect)
  mHasChangedSettings = true
end
local function ToggleWindowedSetting(movie)
  FlashMethod(movie, "ToggleWindowed.ToggleListClass.NextItem")
  PlaySound(sndSelect)
  mHasChangedSettings = true
end
local function ToggleAspectRatio(movie, dir)
  if dir == nil or dir == 1 then
    FlashMethod(movie, "ToggleAspectRatio.ToggleListClass.NextItem")
  elseif dir == -1 then
    FlashMethod(movie, "ToggleAspectRatio.ToggleListClass.PreviousItem")
  end
  PlaySound(sndSelect)
  mHasChangedSettings = true
end
function AspectRatioTextLabelPressed(movie)
  ToggleAspectRatio(movie, 1)
end
local function GetFOV()
  return (mProfileSettings:Fov() - 40) / 0.2
end
local function ToggleFOV(movie, dir)
  mFOVIdx = mFOVIdx + dir * 25
  FlashMethod(movie, "FOVScroll.ScrollClass.SetScrubberPos", mFOVIdx)
  mHasChangedSettings = true
end
function FOVScrubberB0Callback(movie, id)
  mHasChangedSettings = true
  mFOVIdx = tonumber(movie:GetVariable("FOVScroll.ScrollClass.mPosition"))
end
function FOVScrubberB1Callback(movie, id)
  mHasChangedSettings = true
  mFOVIdx = tonumber(movie:GetVariable("FOVScroll.ScrollClass.mPosition"))
end
function FOVScrubberMoveCallback(movie, id)
  mFOVIdx = tonumber(movie:GetVariable("FOVScroll.ScrollClass.mPosition"))
  if mFOVIdx % 25 > 12.5 then
    mFOVIdx = mFOVIdx + 25
  end
  mFOVIdx = math.floor(mFOVIdx / 25) * 25
  FlashMethod(movie, "FOVScroll.ScrollClass.SetScrubberMoveCallback", "")
  FlashMethod(movie, "FOVScroll.ScrollClass.SetScrubberPos", mFOVIdx)
  FlashMethod(movie, "FOVScroll.ScrollClass.SetScrubberMoveCallback", "FOVScrubberMoveCallback")
  mHasChangedSettings = true
end
local function ToggleTextureQuality(movie, dir)
  if dir == 1 then
    FlashMethod(movie, "ToggleTextureQuality.ToggleListClass.NextItem")
  elseif dir == -1 then
    FlashMethod(movie, "ToggleTextureQuality.ToggleListClass.PreviousItem")
  end
  PlaySound(sndSelect)
  mHasChangedSettings = true
end
local function ToggleShadowQuality(movie, dir)
  if dir == 1 then
    FlashMethod(movie, "ToggleShadowQuality.ToggleListClass.NextItem")
  elseif dir == -1 then
    FlashMethod(movie, "ToggleShadowQuality.ToggleListClass.PreviousItem")
  end
  PlaySound(sndSelect)
  mHasChangedSettings = true
end
local function ToggleVSync(movie, dir)
  if dir == nil or dir == 1 then
    FlashMethod(movie, "ToggleVSync.ToggleListClass.NextItem")
  elseif dir == -1 then
    FlashMethod(movie, "ToggleVSync.ToggleListClass.PreviousItem")
  end
  PlaySound(sndSelect)
  mHasChangedSettings = true
end
local function ToggleDecals(movie)
  mDecals = not mDecals
  FlashMethod(movie, "Decals.CheckBoxClass.SetChecked", mDecals)
  PlaySound(sndSelect)
  mHasChangedSettings = true
end
local function BrightnessPressed(movie)
  local childMovie = movie:PushChildMovie(itemBrightnessMovie)
  if childMovie ~= nil then
    childMovie:SetTexture("BinkPlaceholder.png", binkTexture)
    PlaySound(sndSelect)
  end
end
function CheckBoxPressed(movie, cbName)
  if cbName == "Decals" then
    ToggleDecals(movie)
  end
end
local function PopulateDisplaySettings(movie)
  local graphicsSys = gClient:GetGraphicsSys()
  local customDisplaySettings = graphicsSys:GetCustomDisplaySettings()
  local admIdx = BuildSupportedDisplayModeList(customDisplaySettings)
  local adm = customDisplaySettings:GetActiveDisplayMode()
  FlashMethod(movie, "ToggleResolution.ToggleListClass.Clear")
  for i = 1, #mBestDisplayModes do
    local resString = BuildResolutionString(mBestDisplayModes[i].mode.width, mBestDisplayModes[i].mode.height, mBestDisplayModes[i].mode.refreshRate, mBestDisplayModes[i].isWindowedOnly)
    FlashMethod(movie, "ToggleResolution.ToggleListClass.AddItem", resString)
  end
  FlashMethod(movie, "ToggleResolution.ToggleListClass.SetSelected", admIdx)
  local w = 1
  if adm.fullScreen then
    w = 0
  end
  FlashMethod(movie, "ToggleWindowed.ToggleListClass.SetSelected", w)
  FlashMethod(movie, "ToggleTextureQuality.ToggleListClass.SetSelected", customDisplaySettings.textureQuality)
  FlashMethod(movie, "ToggleShadowQuality.ToggleListClass.SetSelected", customDisplaySettings.shadowQuality)
  FlashMethod(movie, "ToggleVSync.ToggleListClass.SetSelected", customDisplaySettings.verticalSync)
  FlashMethod(movie, "ToggleAspectRatio.ToggleListClass.Clear")
  for i = 1, #aspectRatios do
    FlashMethod(movie, "ToggleAspectRatio.ToggleListClass.AddItem", aspectRatios[i])
  end
  FlashMethod(movie, "ToggleAspectRatio.ToggleListClass.SetSelected", customDisplaySettings.displayAspectRatio)
  mDecals = customDisplaySettings.enableDynamicDecals
  FlashMethod(movie, "Decals.CheckBoxClass.SetChecked", mDecals)
end
local function ApplySettings(movie)
  local curResolutionSelection = tonumber(movie:GetVariable("ToggleResolution.ToggleListClass.mCurSelection"))
  local isFullScreen = tonumber(movie:GetVariable("ToggleWindowed.ToggleListClass.mCurSelection")) == 0
  local textureQuality = tonumber(movie:GetVariable("ToggleTextureQuality.ToggleListClass.mCurSelection"))
  local shadowQuality = tonumber(movie:GetVariable("ToggleShadowQuality.ToggleListClass.mCurSelection"))
  local verticalSync = tonumber(movie:GetVariable("ToggleVSync.ToggleListClass.mCurSelection"))
  local aspectRatio = tonumber(movie:GetVariable("ToggleAspectRatio.ToggleListClass.mCurSelection"))
  local graphicsSys = gClient:GetGraphicsSys()
  local customDisplaySettings = graphicsSys:GetCustomDisplaySettings()
  if curResolutionSelection < #mBestDisplayModes then
    local idx = mBestDisplayModes[curResolutionSelection + 1].index
    customDisplaySettings.currentDisplayMode = customDisplaySettings:GetSupportedDisplayMode(idx)
  end
  customDisplaySettings.currentDisplayMode.fullScreen = isFullScreen
  customDisplaySettings.enableDynamicDecals = mDecals
  customDisplaySettings.textureQuality = textureQuality
  customDisplaySettings.shadowQuality = shadowQuality
  customDisplaySettings.verticalSync = verticalSync
  customDisplaySettings.displayAspectRatio = aspectRatio
  mProfileSettings:SetFov(mFOVIdx * 0.2 + 40)
  gClient:SetCustomDisplaySettings(customDisplaySettings)
  PopulateDisplaySettings(movie)
  mHasChangedSettings = false
  if curResolutionSelection ~= mCachedResolution or isFullScreen ~= mCachedFullscreen then
    mPopupMovie = movie:PushChildMovie(popupConfirmMovie)
    mPopupMovie:Execute("SetTransitionInDoneCallback", "RevertPopupTransitionInDone")
    FlashMethod(mPopupMovie, "CreateOkCancel", movie:GetLocalized(itemResPopupQuestion) .. movie:GetLocalized(itemLocCRLN) .. string.format(movie:GetLocalized(itemResPopupTimer), 15), itemKeepRes, itemRevertRes, "ResolutionChangeConfirm")
  elseif mCloseAttempted then
    movie:Close()
  end
end
local function UpdateCachedFullscreen()
  local graphicsSys = gClient:GetGraphicsSys()
  local customDisplaySettings = graphicsSys:GetCustomDisplaySettings()
  local adm = customDisplaySettings:GetActiveDisplayMode()
  mCachedFullscreen = adm.fullScreen
end
function RevertPopupTransitionInDone(movie)
  mRevertTimer = 15
end
local function _ResolutionChangeConfirm(movie, args)
  mRevertTimer = nil
  if tonumber(args) == 1 then
    local graphicsSys = gClient:GetGraphicsSys()
    local customDisplaySettings = graphicsSys:GetCustomDisplaySettings()
    local curResolutionSelection = mCachedResolution
    if curResolutionSelection < #mBestDisplayModes then
      local idx = mBestDisplayModes[curResolutionSelection + 1].index
      customDisplaySettings.currentDisplayMode = customDisplaySettings:GetSupportedDisplayMode(idx)
    end
    customDisplaySettings.currentDisplayMode.fullScreen = mCachedFullscreen
    graphicsSys:SetCustomDisplaySettings(customDisplaySettings)
    PopulateDisplaySettings(movie)
  else
    mCachedResolution = tonumber(movie:GetVariable("ToggleResolution.ToggleListClass.mCurSelection"))
    UpdateCachedFullscreen()
  end
  if mCloseAttempted then
    movie:Close()
  end
end
function ResolutionChangeConfirm(movie, args)
  _ResolutionChangeConfirm(movie, args)
end
local function UpdateResRevertTimer(movie)
  local delta = RealDeltaTime()
  mRevertTimer = mRevertTimer - delta
  if mRevertTimer <= 0 then
    mPopupMovie:Close()
    _ResolutionChangeConfirm(movie, 1)
    return
  end
  mPopupMovie:Execute("SetDescription", movie:GetLocalized(itemResPopupQuestion) .. movie:GetLocalized(itemLocCRLN) .. string.format(movie:GetLocalized(itemResPopupTimer), mRevertTimer + 1))
end
function Update(movie)
  if mRevertTimer ~= nil then
    UpdateResRevertTimer(movie)
  end
end
local function HighlightControl(movie, index, on)
  local clip
  if itemList[index] == itemResolution then
    clip = "ToggleResolution"
  elseif itemList[index] == itemDisplayMode then
    clip = "ToggleWindowed"
  elseif itemList[index] == itemTextureQuality then
    clip = "ToggleTextureQuality"
  elseif itemList[index] == itemShadowQuality then
    clip = "ToggleShadowQuality"
  elseif itemList[index] == itemVerticalSync then
    clip = "ToggleVSync"
  elseif itemList[index] == itemAspectRatio then
    clip = "ToggleAspectRatio"
  elseif itemList[index] == itemFOV then
    clip = "FOVScroll"
  elseif itemList[index] == itemDecals then
    clip = "Decals"
  end
  if not IsNull(clip) then
    local newColor = 16777215
    if on then
      newColor = LIB.SELECTED_COLOR
    end
    movie:SetVariable(clip .. "._color", newColor)
  end
end
function ListButtonSelected(movie, buttonArg)
  if 0 <= mSelectedItem then
    PlaySound(sndScroll)
  end
  mSelectedItem = tonumber(buttonArg) + 1
  HighlightControl(movie, mSelectedItem, true)
  local canToggle = mSelectedItem <= 5 or mSelectedItem == 7
  FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByName", statusToggle, canToggle)
  FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByName", statusSelect, not canToggle)
end
function ToggleListButtonSelected(movie, buttonArg)
  PlaySound(sndScroll)
end
function ListButtonUnselected(movie, buttonArg)
  local btn = tonumber(buttonArg) + 1
  HighlightControl(movie, btn, false)
end
function ListButtonPressed(movie, args)
  local idx = tonumber(args) + 1
  if itemList[idx] == itemResolution then
    ToggleResolutionQuality(movie, 1)
  elseif itemList[idx] == itemDisplayMode then
    ToggleWindowedSetting(movie)
  elseif itemList[idx] == itemAspectRatio then
    ToggleAspectRatio(movie, 1)
  elseif itemList[idx] == itemTextureQuality then
    ToggleTextureQuality(movie, 1)
  elseif itemList[idx] == itemShadowQuality then
    ToggleShadowQuality(movie, 1)
  elseif itemList[idx] == itemVerticalSync then
    ToggleVSync(movie)
  elseif itemList[idx] == itemFOV then
    ToggleFOV(movie, 1)
  elseif itemList[idx] == itemDecals then
    ToggleDecals(movie)
  elseif itemList[idx] == itemBrightness then
    BrightnessPressed(movie)
  elseif itemList[idx] == itemApply then
    ApplySettings(movie)
    PlaySound(sndSelect)
  end
end
local function AdjustToggle(movie, dir)
  if mSelectedItem == -1 then
    return true
  end
  if itemList[mSelectedItem] == itemResolution then
    ToggleResolutionQuality(movie, dir)
  elseif itemList[mSelectedItem] == itemDisplayMode then
    ToggleWindowedSetting(movie)
  elseif itemList[mSelectedItem] == itemAspectRatio then
    ToggleAspectRatio(movie, dir)
  elseif itemList[mSelectedItem] == itemTextureQuality then
    ToggleTextureQuality(movie, dir)
  elseif itemList[mSelectedItem] == itemShadowQuality then
    ToggleShadowQuality(movie, dir)
  elseif itemList[mSelectedItem] == itemVerticalSync then
    ToggleVSync(movie, dir)
  elseif itemList[mSelectedItem] == itemFOV then
    ToggleFOV(movie, dir)
  end
  return true
end
function onKeyDown_MENU_LEFT_FROM_ANALOG(movie)
  return AdjustToggle(movie, -1)
end
function onKeyDown_MENU_LEFT(movie)
  return AdjustToggle(movie, -1)
end
function onKeyDown_MENU_RIGHT_FROM_ANALOG(movie)
  return AdjustToggle(movie, 1)
end
function onKeyDown_MENU_RIGHT(movie)
  return AdjustToggle(movie, 1)
end
function onKeyDown_MENU_UP_FROM_ANALOG(movie)
  if mResolutionExpanded then
    return LIB.ListClassVerticalScroll(movie, "ToggleResolution.OptionList", -1)
  end
  return LIB.ListClassVerticalScroll(movie, "OptionList", -1)
end
function onKeyDown_MENU_UP(movie)
  if mResolutionExpanded then
    return LIB.ListClassVerticalScroll(movie, "ToggleResolution.OptionList", -1)
  end
  return LIB.ListClassVerticalScroll(movie, "OptionList", -1)
end
function onKeyDown_MENU_DOWN_FROM_ANALOG(movie)
  if mResolutionExpanded then
    return LIB.ListClassVerticalScroll(movie, "ToggleResolution.OptionList", 1)
  end
  return LIB.ListClassVerticalScroll(movie, "OptionList", 1)
end
function onKeyDown_MENU_DOWN(movie)
  if mResolutionExpanded then
    return LIB.ListClassVerticalScroll(movie, "ToggleResolution.OptionList", 1)
  end
  return LIB.ListClassVerticalScroll(movie, "OptionList", 1)
end
function ResolutionTextLabelPressed(movie)
  ToggleResolutionQuality(movie, 1)
  PlaySound(sndSelect)
end
function ResolutionListPressed(movie, args)
  mResolutionExpanded = false
  FlashMethod(movie, "ToggleResolution.ToggleListClass.SetExpanded", mResolutionExpanded)
  FlashMethod(movie, "ToggleResolution.ToggleListClass.SetSelected", tonumber(args))
  mHasChangedSettings = true
  PlaySound(sndSelect)
end
function ToggleButtonPressed(movie, args)
  mHasChangedSettings = true
  PlaySound(sndSelect)
end
function WindowedTextLabelPressed(movie)
  ToggleWindowedSetting(movie)
end
function TextureQualityTextLabelPressed(movie)
  ToggleTextureQuality(movie, 1)
end
function ShadowQualityTextLabelPressed(movie)
  ToggleShadowQuality(movie, 1)
end
function VSyncTextLabelPressed(movie)
  ToggleVSync(movie, 1)
end
function Initialize(movie)
  mMovie = movie
  mPlayerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  mProfileSettings = mPlayerProfile:Settings()
  movie:SetLocalized("Title.TxtHolder.Txt.text", "/D2/Language/Menu/Options_DisplayCustomize_Title")
  movie:SetVariable("Title.TxtHolder.Txt.textAlign", "center")
  local y_inc = 32
  local y = movie:GetVariable("ToggleResolution._y")
  local toggleB0 = 70
  local toggleB1 = 345
  FlashMethod(movie, "ToggleResolution.ToggleListClass.SetAlignment", "center")
  movie:SetVariable("ToggleResolution.Button0._x", toggleB0)
  movie:SetVariable("ToggleResolution.Button1._x", toggleB1)
  FlashMethod(movie, "ToggleResolution.ToggleListClass.SetTextLabelCallbackOnPress", "ResolutionTextLabelPressed")
  movie:SetVariable("ToggleResolution.OptionList._x", toggleB0 + 35)
  movie:SetVariable("ToggleResolution.OptionListBackground._x", toggleB0 - 80)
  FlashMethod(movie, "ToggleResolution.ToggleListClass.SetButton0PressedCallback", "ToggleButtonPressed")
  FlashMethod(movie, "ToggleResolution.ToggleListClass.SetButton1PressedCallback", "ToggleButtonPressed")
  FlashMethod(movie, "ToggleResolution.OptionList.ListClass.SetSelectedCallback", "ToggleListButtonSelected")
  FlashMethod(movie, "ToggleResolution.ListClass.SetAlignment", "left")
  FlashMethod(movie, "ToggleResolution.ListClass.SetPressedCallback", "ResolutionListPressed")
  y = y + y_inc
  movie:SetVariable("ToggleWindowed.Button0._x", toggleB0)
  movie:SetVariable("ToggleWindowed.Button1._x", toggleB1)
  FlashMethod(movie, "ToggleWindowed.ToggleListClass.SetAlignment", "center")
  FlashMethod(movie, "ToggleWindowed.ToggleListClass.SetTextLabelCallbackOnPress", "WindowedTextLabelPressed")
  FlashMethod(movie, "ToggleWindowed.ToggleListClass.SetButton0PressedCallback", "ToggleButtonPressed")
  FlashMethod(movie, "ToggleWindowed.ToggleListClass.SetButton1PressedCallback", "ToggleButtonPressed")
  FlashMethod(movie, "ToggleWindowed.ToggleListClass.AddItem", "/D2/Language/Menu/Options_DisplayCustomize_DisplayModeFullScreen")
  FlashMethod(movie, "ToggleWindowed.ToggleListClass.AddItem", "/D2/Language/Menu/Options_DisplayCustomize_DisplayModeWindowed")
  movie:SetVariable("ToggleWindowed._y", y)
  y = y + y_inc
  movie:SetVariable("ToggleTextureQuality.Button0._x", toggleB0)
  movie:SetVariable("ToggleTextureQuality.Button1._x", toggleB1)
  FlashMethod(movie, "ToggleTextureQuality.ToggleListClass.SetAlignment", "center")
  FlashMethod(movie, "ToggleTextureQuality.ToggleListClass.SetTextLabelCallbackOnPress", "TextureQualityTextLabelPressed")
  FlashMethod(movie, "ToggleTextureQuality.ToggleListClass.SetButton0PressedCallback", "ToggleButtonPressed")
  FlashMethod(movie, "ToggleTextureQuality.ToggleListClass.SetButton1PressedCallback", "ToggleButtonPressed")
  FlashMethod(movie, "ToggleTextureQuality.ToggleListClass.AddItem", "/D2/Language/Menu/Options_DisplayCustomize_Low")
  FlashMethod(movie, "ToggleTextureQuality.ToggleListClass.AddItem", "/D2/Language/Menu/Options_DisplayCustomize_Medium")
  FlashMethod(movie, "ToggleTextureQuality.ToggleListClass.AddItem", "/D2/Language/Menu/Options_DisplayCustomize_High")
  movie:SetVariable("ToggleTextureQuality._y", y)
  y = y + y_inc
  movie:SetVariable("ToggleShadowQuality.Button0._x", toggleB0)
  movie:SetVariable("ToggleShadowQuality.Button1._x", toggleB1)
  FlashMethod(movie, "ToggleShadowQuality.ToggleListClass.SetAlignment", "center")
  FlashMethod(movie, "ToggleShadowQuality.ToggleListClass.SetTextLabelCallbackOnPress", "ShadowQualityTextLabelPressed")
  FlashMethod(movie, "ToggleShadowQuality.ToggleListClass.SetButton0PressedCallback", "ToggleButtonPressed")
  FlashMethod(movie, "ToggleShadowQuality.ToggleListClass.SetButton1PressedCallback", "ToggleButtonPressed")
  FlashMethod(movie, "ToggleShadowQuality.ToggleListClass.AddItem", "/D2/Language/Menu/Options_DisplayCustomize_Low")
  FlashMethod(movie, "ToggleShadowQuality.ToggleListClass.AddItem", "/D2/Language/Menu/Options_DisplayCustomize_Medium")
  FlashMethod(movie, "ToggleShadowQuality.ToggleListClass.AddItem", "/D2/Language/Menu/Options_DisplayCustomize_High")
  movie:SetVariable("ToggleShadowQuality._y", y)
  y = y + y_inc
  movie:SetVariable("ToggleVSync.Button0._x", toggleB0)
  movie:SetVariable("ToggleVSync.Button1._x", toggleB1)
  FlashMethod(movie, "ToggleVSync.ToggleListClass.SetAlignment", "center")
  FlashMethod(movie, "ToggleVSync.ToggleListClass.SetTextLabelCallbackOnPress", "VSyncTextLabelPressed")
  FlashMethod(movie, "ToggleVSync.ToggleListClass.SetButton0PressedCallback", "ToggleButtonPressed")
  FlashMethod(movie, "ToggleVSync.ToggleListClass.SetButton1PressedCallback", "ToggleButtonPressed")
  FlashMethod(movie, "ToggleVSync.ToggleListClass.AddItem", "/D2/Language/Menu/Options_DisplayCustomize_Auto")
  FlashMethod(movie, "ToggleVSync.ToggleListClass.AddItem", "/D2/Language/Menu/Options_DisplayCustomize_On")
  FlashMethod(movie, "ToggleVSync.ToggleListClass.AddItem", "/D2/Language/Menu/Options_DisplayCustomize_Off")
  movie:SetVariable("ToggleVSync._y", y)
  y = y + y_inc
  movie:SetVariable("Decals.CheckBoxClass.mSelectedColor", LIB.SELECTED_COLOR)
  movie:SetVariable("Decals._y", y + 23)
  y = y + y_inc
  movie:SetVariable("ToggleAspectRatio.Button0._x", toggleB0)
  movie:SetVariable("ToggleAspectRatio.Button1._x", toggleB1)
  FlashMethod(movie, "ToggleAspectRatio.ToggleListClass.SetAlignment", "center")
  FlashMethod(movie, "ToggleAspectRatio.ToggleListClass.SetTextLabelCallbackOnPress", "AspectRatioTextLabelPressed")
  FlashMethod(movie, "ToggleAspectRatio.ToggleListClass.SetButton0PressedCallback", "ToggleButtonPressed")
  FlashMethod(movie, "ToggleAspectRatio.ToggleListClass.SetButton1PressedCallback", "ToggleButtonPressed")
  FlashMethod(movie, "ToggleAspectRatio.ToggleListClass.AddItem", "/D2/Language/Menu/Options_DisplayCustomize_Auto")
  FlashMethod(movie, "ToggleAspectRatio.ToggleListClass.AddItem", "/D2/Language/Menu/Options_DisplayCustomize_4x3")
  FlashMethod(movie, "ToggleAspectRatio.ToggleListClass.AddItem", "/D2/Language/Menu/Options_DisplayCustomize_16:9")
  FlashMethod(movie, "ToggleAspectRatio.ToggleListClass.AddItem", "/D2/Language/Menu/Options_DisplayCustomize_16:10")
  movie:SetVariable("ToggleAspectRatio._visible", mAspectRatioEnabled)
  if mAspectRatioEnabled then
    movie:SetVariable("ToggleAspectRatio._y", y)
    y = y + y_inc + 35
  end
  mFOVIdx = 0
  FlashMethod(movie, "FOVScroll.ScrollClass.SetRange", 100)
  mFOVIdx = GetFOV()
  FlashMethod(movie, "FOVScroll.ScrollClass.SetScrubberPos", mFOVIdx)
  FlashMethod(movie, "FOVScroll.ScrollClass.SetIncrement", 25)
  FlashMethod(movie, "FOVScroll.ScrollClass.SetButton0PressedCallback", "FOVScrubberB0Callback")
  FlashMethod(movie, "FOVScroll.ScrollClass.SetButton1PressedCallback", "FOVScrubberB1Callback")
  FlashMethod(movie, "FOVScroll.ScrollClass.SetScrubberPressedCallback", "FOVScrubberMoveCallback")
  FlashMethod(movie, "FOVScroll.ScrollClass.SetScrubberMoveCallback", "FOVScrubberMoveCallback")
  movie:SetVariable("FOVScroll._y", y)
  y = y + y_inc
  FlashMethod(movie, "OptionList.ListClass.EraseItems")
  local myList = {
    itemResolution,
    itemDisplayMode,
    itemTextureQuality,
    itemShadowQuality,
    itemVerticalSync,
    itemDecals,
    itemAspectRatio,
    itemFOV,
    itemBrightness,
    itemApply
  }
  for i = 1, #myList do
    if not mAspectRatioEnabled and myList[i] == itemAspectRatio then
    else
      FlashMethod(movie, "OptionList.ListClass.AddItem", myList[i], false)
      itemList[#itemList + 1] = myList[i]
    end
  end
  FlashMethod(movie, "OptionList.ListClass.SetAlignment", "right")
  FlashMethod(movie, "OptionList.ListClass.SetPressedCallback", "ListButtonPressed")
  FlashMethod(movie, "OptionList.ListClass.SetSelectedCallback", "ListButtonSelected")
  FlashMethod(movie, "OptionList.ListClass.SetUnselectedCallback", "ListButtonUnselected")
  FlashMethod(movie, "OptionList.ListClass.SetSelected", 0)
  movie:SetVariable("Decals.CheckBoxClass.mSelectedColor", LIB.SELECTED_COLOR)
  PopulateDisplaySettings(movie)
  mCachedResolution = tonumber(movie:GetVariable("ToggleResolution.ToggleListClass.mCurSelection"))
  UpdateCachedFullscreen()
  for i = 1, #statusList do
    FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", statusList[i], statusList[i] ~= statusSelect)
  end
  FlashMethod(movie, "StatusBar.StatusBarClass.SetCallbackOnPress", "StatusButtonPressed")
end
function ConfirmListButtonPressed(movie, args)
  local idx = tonumber(args) + 1
  mPopupMovie:Close()
  if confirmList[idx] == popupItemCancel then
    return
  elseif confirmList[idx] == popupItemApply then
    mCloseAttempted = true
    ApplySettings(movie)
  elseif confirmList[idx] == popupItemDiscard then
    movie:Close()
  end
end
function PopupTransitionInDone(movie)
  FlashMethod(mPopupMovie, "CreateList", "ConfirmListButtonPressed", "", "")
  for i = 1, #confirmList do
    FlashMethod(mPopupMovie, "OptionList.ListClass.AddItem", confirmList[i], false)
  end
  mPopupMovie:Execute("SetDescription", "/D2/Language/Menu/Options_DisplayCustomize_ApplyChangesQuestion")
  FlashMethod(mPopupMovie, "OptionList.ListClass.SetAlignment", "center")
  FlashMethod(mPopupMovie, "OptionList.ListClass.SetSelected", 0)
end
local function Back(movie)
  if mHasChangedSettings then
    mPopupMovie = movie:PushChildMovie(popupConfirmMovie)
    mPopupMovie:Execute("SetTransitionInDoneCallback", "PopupTransitionInDone")
  else
    movie:Close()
  end
  PlaySound(sndBack)
end
local function SetDefaults(movie)
  local graphicsSys = gClient:GetGraphicsSys()
  local customDisplaySettings = graphicsSys:GetSuggestedDeviceSettings()
  local admIdx = BuildSupportedDisplayModeList(customDisplaySettings)
  local adm = customDisplaySettings:GetActiveDisplayMode()
  FlashMethod(movie, "ToggleResolution.ToggleListClass.Clear")
  for i = 1, #mBestDisplayModes do
    local resString = BuildResolutionString(mBestDisplayModes[i].mode.width, mBestDisplayModes[i].mode.height, mBestDisplayModes[i].mode.refreshRate, mBestDisplayModes[i].isWindowedOnly)
    FlashMethod(movie, "ToggleResolution.ToggleListClass.AddItem", resString)
  end
  FlashMethod(movie, "ToggleResolution.ToggleListClass.SetSelected", admIdx)
  local w = 1
  if adm.fullScreen then
    w = 0
  end
  FlashMethod(movie, "ToggleWindowed.ToggleListClass.SetSelected", w)
  FlashMethod(movie, "ToggleTextureQuality.ToggleListClass.SetSelected", customDisplaySettings.textureQuality)
  FlashMethod(movie, "ToggleShadowQuality.ToggleListClass.SetSelected", customDisplaySettings.shadowQuality)
  FlashMethod(movie, "ToggleVSync.ToggleListClass.SetSelected", customDisplaySettings.verticalSync)
  FlashMethod(movie, "ToggleAspectRatio.ToggleListClass.SetSelected", customDisplaySettings.displayAspectRatio)
  FlashMethod(movie, "FOVScroll.ScrollClass.SetScrubberPos", 25)
  mDecals = customDisplaySettings.enableDynamicDecals
  FlashMethod(movie, "Decals.CheckBoxClass.SetChecked", mDecals)
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

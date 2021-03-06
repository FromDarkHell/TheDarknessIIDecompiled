local SCROLLDIR_Idle = 0
local SCROLLDIR_Up = 1
local SCROLLDIR_Down = -1
local statusScroll = "/D2/Language/Menu/RelicPopUp_Scroll"
local statusBack = "/D2/Language/Menu/Shared_Back"
local statusList = {statusScroll, statusBack}
local mDefaultY = 0
local mTextFieldHeight = 0
local mTextLines = 0
local mFontSize = 0
local mMaxY = 0
local mScrollBarSize = 0
local mScrollDir = SCROLLDIR_Idle
local mDeltaTime = -1
local mScrollPosition = 1
local mSharedCRLN = ""
function SetRelicText(movie, relicTag)
  movie:SetLocalized("PopupBackground.ScrollText.Title.text", string.format("/D2/Language/Relics/Relic_%s_Title", relicTag))
  local text = movie:GetLocalized(string.format("/D2/Language/Relics/Relic_%s", relicTag))
  text = text .. mSharedCRLN
  movie:SetLocalized("PopupBackground.ScrollText.Text.text", text)
  return true
end
function Initialize(movie)
  mSharedCRLN = movie:GetLocalized("/D2/Language/Menu/Shared_CRLN")
  mDeltaTime = -1
  mScrollPosition = 1
  mScrollDir = SCROLLDIR_Idle
  local s = movie:GetLocalized("/D2/Language/Credits/Credits_Main")
  movie:SetVariable("PopupBackground.ScrollText.Text.text", s)
  mDefaultY = tonumber(movie:GetVariable("PopupBackground.ScrollText.Text._y"))
  for i = 1, #statusList do
    FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", statusList[i], statusList[i] ~= statusScroll)
  end
  FlashMethod(movie, "StatusBar.StatusBarClass.SetCallbackOnPress", "StatusButtonPressed")
  FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByName", statusScroll, gFlashMgr:GetInputDeviceIconType() ~= DIT_PC)
  mScrollBarSize = 320
  FlashMethod(movie, "TextScroll.ScrollClass.SetSize", mScrollBarSize)
  FlashMethod(movie, "TextScroll.ScrollClass.SetRange", 100)
  FlashMethod(movie, "TextScroll.ScrollClass.SetScrubberPos", mScrollPosition)
  FlashMethod(movie, "TextScroll.ScrollClass.SetButton0PressedCallback", "TextScrubberMoveCallback")
  FlashMethod(movie, "TextScroll.ScrollClass.SetButton1PressedCallback", "TextScrubberMoveCallback")
  FlashMethod(movie, "TextScroll.ScrollClass.SetScrubberMoveCallback", "TextScrubberMoveCallback")
  FlashMethod(movie, "TextScroll.ScrollClass.SetFillerPressedCallback", "TextScrubberMoveCallback")
end
local function LazyInit(movie)
  if mTextFieldHeight == 0 then
    mTextFieldHeight = tonumber(movie:GetVariable("PopupBackground.ScrollText.Text._height"))
    mTextLines = movie:GetVariable("PopupBackground.ScrollText.Text.textLines")
    mFontSize = movie:GetVariable("PopupBackground.ScrollText.Text.fontSize")
    mMaxY = mTextLines * mFontSize - mTextFieldHeight
  end
end
local function UpdateScroll(movie, scrollDir)
  local deltaTime = mDeltaTime
  if scrollDir == SCROLLDIR_Idle then
    return
  end
  LazyInit(movie)
  local rate = 30
  local finalRate = rate * mDeltaTime * -scrollDir
  local newScrollPos = mScrollPosition + finalRate
  newScrollPos = Clamp(newScrollPos, 0, 100)
  FlashMethod(movie, "TextScroll.ScrollClass.SetScrubberPos", newScrollPos)
end
function TextScrubberMoveCallback(movie, id)
  mScrollPosition = tonumber(movie:GetVariable("TextScroll.ScrollClass.mPosition"))
  LazyInit(movie)
  local newY = mScrollPosition / 100 * (mMaxY + mDefaultY)
  movie:SetVariable("PopupBackground.ScrollText.Text._y", mDefaultY - newY)
end
function Update(movie)
  if mDeltaTime <= 0 then
    mDeltaTime = DeltaTime()
    return
  end
  mDeltaTime = DeltaTime()
  UpdateScroll(movie, mScrollDir)
end
local Back = function(movie)
  movie:Close()
end
function StatusButtonPressed(movie, buttonArg)
  local index = tonumber(buttonArg) + 1
  if statusList[index] == statusBack then
    Back(movie)
  end
end
function onKeyDown_MENU_CANCEL(movie)
  Back(movie)
end
function onKeyDown_MENU_UP(movie)
  if mScrollDir == SCROLLDIR_Idle then
    mScrollDir = SCROLLDIR_Up
  end
end
function onKeyUp_MENU_UP(movie)
  mScrollDir = SCROLLDIR_Idle
end
function onKeyUp_MENU_DOWN(movie)
  mScrollDir = SCROLLDIR_Idle
end
function onKeyDown_MENU_DOWN(movie)
  if mScrollDir == SCROLLDIR_Idle then
    mScrollDir = SCROLLDIR_Down
  end
end
function onKeyDown_MENU_RIGHT_Y(deviceId, id, yPos)
  yPos = tonumber(yPos)
  if 0 < yPos then
    mScrollDir = SCROLLDIR_Up
  else
    mScrollDir = SCROLLDIR_Down
  end
  return true
end
function onKeyUp_MENU_RIGHT_Y(deviceId, yPos)
  mScrollDir = SCROLLDIR_Idle
  return true
end

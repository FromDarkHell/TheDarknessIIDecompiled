local LIB = require("D2.Menus.SharedLibrary")
rollOverSound = Resource()
pressSound = Resource()
backSound = Resource()
transitionMovie = WeakResource()
lobbyTransitionMovie = WeakResource()
lobbyGameRules = WeakResource()
challengeUnlockedMovie = WeakResource()
binkTexture = Resource()
local statusSelect = "/D2/Language/Menu/Shared_Select"
local statusBack = "/D2/Language/Menu/Shared_Back"
local popupItemOk = "/D2/Language/Menu/Confirm_Item_Ok"
local statusList = {statusBack}
local mTextLines = {}
local mText = ""
local mTextStartIdx, mCurrentTextHeight
local mCurrentTextFrame = 1
local mCurrentColour = 16777215
local mStartY, mEndY
local mReadyToUpdate = false
local mMaxTemplates, mAvailableTemplates
local function GetTextLineEntry(movie)
  local actualText = ""
  local idx = string.find(mText, "\n", mTextStartIdx)
  if idx == nil then
    return nil
  end
  actualText = actualText .. string.sub(mText, mTextStartIdx, idx)
  mTextStartIdx = idx + 1
  local endPos = string.find(actualText, ">")
  if endPos ~= nil then
    local cmd = string.sub(actualText, 0, endPos)
    actualText = string.sub(actualText, endPos + 1)
    if cmd == "<h2>" then
      mCurrentTextFrame = 2
    elseif cmd == "<h3>" then
      mCurrentTextFrame = 3
    else
      mCurrentTextFrame = 1
    end
    mCurrentTextHeight = movie:GetVariable(string.format("Header%i.fontSize", mCurrentTextFrame))
  end
  local entry = {
    pos = 0,
    size = mCurrentTextHeight,
    text = actualText,
    frame = mCurrentTextFrame,
    isDone = false,
    sectionName = ""
  }
  return entry
end
local function InitializeTextLines(movie)
  mTextLines = {}
  mTextStartIdx = 0
  local textLine = GetTextLineEntry(movie)
  while textLine ~= nil do
    mTextLines[#mTextLines + 1] = textLine
    textLine = GetTextLineEntry(movie)
  end
  local y = mStartY
  local numTextLines = #mTextLines
  for i = 1, numTextLines do
    mTextLines[i].pos = y
    y = y + mTextLines[i].size
  end
end
function Initialize(movie)
  mCurrentTextFrame = 1
  mCurrentColour = 16777215
  mReadyToUpdate = false
  if LIB.IsInFrontend() then
    LIB.PlayBackgroundBink(movie, binkTexture)
  end
  mTextStartIdx = 0
  mText = movie:GetLocalized("/D2/Language/Credits/Credits_Main")
  mStartY = tonumber(movie:GetVariable("VisibleArea._height"))
  mEndY = 0
  mAvailableTemplates = {}
  mMaxTemplates = 50
  for i = 1, mMaxTemplates do
    local sectionName = string.format("Section%i", i - 1)
    FlashMethod(movie, "CreateSection", "TemplateShared", sectionName)
    mAvailableTemplates[#mAvailableTemplates + 1] = sectionName
  end
  InitializeTextLines(movie)
  movie:SetVariable("TemplateShared._visible", false)
  movie:SetLocalized("Title.TxtHolder.Txt.text", "/D2/Language/Credits/Credits_Title")
  for i = 1, #statusList do
    FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", statusList[i], statusList[i] ~= statusSelect)
  end
  FlashMethod(movie, "StatusBar.StatusBarClass.SetCallbackOnPress", "StatusButtonPressed")
  mReadyToUpdate = true
end
function ChallengePopupDone(movie, args)
  if tonumber(args) == 0 then
    movie:Close()
  end
end
local function Back(movie)
  if LIB.IsInFrontend() then
    gRegion:PlaySound(backSound, Vector(), false)
    LIB.DoScreenTransition(movie, LIB.TRANSITION_DESTINATON_PARENT_SCREEN, transitionMovie, LIB.TRANSITON_VIDEO_OPTIONS_1)
  elseif gRegion:GetGameRules():IsA(lobbyGameRules) then
    Engine.GetMatchingService():DisableSessionReconnect()
    Engine.Disconnect(true)
  else
    movie:Close()
  end
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
function Update(movie)
  local rate = RealDeltaTime() * 70
  local numTextLines = #mTextLines
  for i = 1, numTextLines do
    if mTextLines[i] == nil then
    else
      local y = mTextLines[i].pos
      y = y - rate
      mTextLines[i].pos = y
      if mTextLines[i].sectionName == "" and 0 < #mAvailableTemplates then
        mTextLines[i].sectionName = mAvailableTemplates[1]
        table.remove(mAvailableTemplates, 1)
        FlashMethod(movie, string.format("%s.gotoAndStop", mTextLines[i].sectionName), mTextLines[i].frame)
        movie:SetVariable(string.format("%s.Text.text", mTextLines[i].sectionName), mTextLines[i].text)
      elseif mTextLines[i].pos + mTextLines[i].size < -20 and mTextLines[i].sectionName ~= "" then
        mAvailableTemplates[#mAvailableTemplates + 1] = mTextLines[i].sectionName
        table.remove(mTextLines, i)
      end
      if mTextLines[i] == nil then
        Back(movie)
        return
      end
      if mTextLines[i].sectionName ~= "" then
        movie:SetVariable(string.format("%s._y", mTextLines[i].sectionName), y)
      end
    end
  end
end

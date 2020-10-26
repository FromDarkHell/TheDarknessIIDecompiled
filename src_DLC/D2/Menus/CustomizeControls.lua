local LIB = require("D2.Menus.SharedLibrary")
sndBack = Resource()
sndScroll = Resource()
sndSelect = Resource()
sndTime = Resource()
movieHUD = WeakResource()
inputPreWaitDuration = 0.25
inputWaitDuration = 5
popupConfirmMovie = WeakResource()
local mMovieInstance
local popupItemOk = "/D2/Language/Menu/Confirm_Item_Ok"
local popupItemCancel = "/D2/Language/Menu/Confirm_Item_Cancel"
local GRID_DimensionsW = 2
local GRID_DimensionsH = 11
local GRID_ClipDimensionsH = 10
local WAITSTATE_Idle = 0
local WAITSTATE_PreInputWait = 0.1
local WAITSTATE_InputWait = 2
local mStatusSelect = "/D2/Language/Menu/Shared_Select"
local mStatusRemove = "/D2/Language/Menu/CustomizeControls_Remove"
local mStatusDefaults = "/D2/Language/Menu/CustomizeControls_Defaults"
local mStatusBack = "/D2/Language/Menu/Shared_Back"
local mStatusList = {
  mStatusSelect,
  mStatusRemove,
  mStatusDefaults,
  mStatusBack
}
local mInput = {
  waitState = WAITSTATE_Idle,
  waitCountdown = 0,
  waitPrevCountdown = 0
}
local mKeyBinding = {
  action = "",
  loc = "",
  preText = "",
  postText = "",
  keyList = "",
  gridKeys = {}
}
local mKeyBindings = {}
local mKeyLabels = {}
local mCurSelectionX = -1
local mCurSelectionY = -1
local mBindings = {
  input = {}
}
local mPlatform = ""
local mInputDeviceType = -1
local mBanner
local mScrubberPosition = 0
local mScrubberRange = 0
local GetItemName = function(x, y)
  return string.format("InputGrid_Item%dx%d", x, y)
end
local function FindXFromIndex(index)
  return index % GRID_DimensionsW
end
local function FindYFromIndex(index)
  return math.floor(index / GRID_DimensionsW)
end
local function IsWaitingForInput()
  return mInput.waitState ~= WAITSTATE_Idle
end
local function UpdateSelectionButtons(movie)
  local vis = mInput.waitState == WAITSTATE_Idle
  FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByIndex", 0, vis)
  FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByIndex", 1, vis)
end
local function SetWaitState(movie, waitState)
  mInput.waitState = waitState
  if mInput.waitState == WAITSTATE_PreInputWait then
    mInput.waitCountdown = inputPreWaitDuration
  elseif mInput.waitState == WAITSTATE_InputWait then
    mInput.waitCountdown = inputWaitDuration
    gFlashMgr:SetRawInputEventEnabled(true)
    local strFmt = movie:GetLocalized("/D2/Language/Menu/CustomizeControls_WaitingForInput")
    mBanner.text = string.format(strFmt, mInput.waitCountdown)
    mBanner.state = mBanner.STATE_FadeIn
    LIB.BannerDisplay(movie, mBanner)
    FlashMethod(movie, "InputGrid.GridClass.SetVisible", false)
  else
    gFlashMgr:SetRawInputEventEnabled(false)
    mBanner.state = mBanner.STATE_FadeOut
    LIB.BannerDisplay(movie, mBanner)
    FlashMethod(movie, "InputGrid.GridClass.SetVisible", true)
  end
  local isVis = mInput.waitState == WAITSTATE_Idle
  for i = 1, #mStatusList do
    FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByIndex", i - 1, isVis)
  end
  UpdateSelectionButtons(movie)
  movie:SetVariable("VerticalScroll._visible", isVis)
  movie:SetVariable("PrimaryTitle._visible", isVis)
  movie:SetVariable("SecondaryTitle._visible", isVis)
end
function InputGridItemPressed(movie, arg)
  if IsWaitingForInput() then
    return
  end
  local idx = tonumber(arg)
  local x = FindXFromIndex(idx)
  if x == 0 then
    return
  end
  local y = FindYFromIndex(idx)
  SetWaitState(movie, WAITSTATE_PreInputWait)
end
local function SetSelectedState(movie, x, y, selected)
  if 0 < x then
    movie:SetVariable(string.format("%s.Selected._visible", GetItemName(x, y)), selected)
  end
end
function InputGridItemSelected(movie, arg)
  if IsWaitingForInput() then
    return
  end
  local idx = tonumber(arg)
  local x = FindXFromIndex(idx)
  local y = FindYFromIndex(idx)
  if y >= #mKeyBindings then
    return
  end
  mCurSelectionX = x
  mCurSelectionY = y
  gRegion:PlaySound(sndScroll, Vector(), false)
  SetSelectedState(movie, x, y, true)
  UpdateSelectionButtons(movie)
  local itemName = GetItemName(x, y)
end
function InputGridItemUnselected(movie, arg)
  if IsWaitingForInput() then
    return
  end
  local idx = tonumber(arg)
  local x = FindXFromIndex(idx)
  local y = FindYFromIndex(idx)
  SetSelectedState(movie, x, y, false)
  mCurSelectionX = -1
  mCurSelectionY = -1
  FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByIndex", 0, false)
  FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByIndex", 1, false)
end
local function SetKeyLabel(movie, x, y, key)
  if key == nil then
    key = ""
  end
  local itemName = GetItemName(x, y)
  if key ~= "" then
    gFlashMgr:SetInputDeviceIconType(DIT_PC)
    movie:SetLocalized(string.format("%s.Text.text", itemName), string.format(" <%s> ", key))
  end
  mKeyLabels[itemName] = key
end
local function PopulateActionKeys(movie, y, kb)
  kb.gridKeys = {}
  for i = 0, GRID_DimensionsW do
    SetKeyLabel(movie, 1 + i, y, "")
  end
  local tokenList = StringTokens(kb.keyList, " ")
  if tokenList == nil or #tokenList == 0 then
    return
  end
  local x = 0
  for idx = 0, #tokenList do
    repeat
      local token = tokenList[idx + 1]
      local str = ""
      if token ~= nil then
        if string.find(token, "XBOX") ~= nil or string.find(token, "PS3") ~= nil or string.find(token, "GAMEPAD") ~= nil then
          break -- pseudo-goto
        end
      else
        token = ""
      end
      local propertyList = StringTokens(token, ":")
      if propertyList ~= nil then
        if 1 < #propertyList and propertyList[2] == kb.post then
          str = propertyList[1]
        elseif #propertyList == 1 and kb.post == "" then
          str = token
        end
      end
      if str ~= "" then
        SetKeyLabel(movie, x + 1, y, str)
        kb.gridKeys[x + 1] = str
        x = x + 1
      end
    until true
  end
end
local BuildKeyBinding = function(pre, key, post)
  if key == nil or key == "" then
    return ""
  end
  local str = ""
  if pre ~= "" then
    str = str .. pre .. ":"
  end
  str = str .. key
  if post ~= "" then
    str = str .. ":" .. post
  end
  return str
end
local function ReplaceKeyBinding(movie, x, y, newInput)
  local kb = mKeyBindings[y + 1]
  local oldInput = ""
  if kb.gridKeys ~= nil then
    oldInput = kb.gridKeys[x]
  end
  local newInputIdx
  local oldKeyName = BuildKeyBinding(kb.pre, oldInput, kb.post)
  local newKeyName = BuildKeyBinding(kb.pre, newInput, kb.post)
  for i = 1, #mKeyBindings do
    local thisAction = mKeyBindings[i].action
    if thisAction == nil then
    else
      local theBindings = gFlashMgr:GetBindingsForAction(thisAction, true)
      if theBindings == nil then
      else
        local tokenList = StringTokens(theBindings, " ")
        local tokenListNum = 0
        if tokenList ~= nil then
          tokenListNum = #tokenList
        end
        if tokenListNum == 0 then
        else
          if mKeyBindings[i].context == kb.context then
            for j = 1, tokenListNum do
              local thisToken = tokenList[j]
              local potentialNewBinding = newInput
              if mKeyBindings[i].post ~= "" then
                potentialNewBinding = potentialNewBinding .. ":" .. mKeyBindings[i].post
              end
              if thisToken == newKeyName and y + 1 == i then
                return
              end
              if thisToken == potentialNewBinding then
                newInputIdx = i
                break
              end
            end
          end
          if newInputIdx ~= nil then
            break
          end
        end
      end
    end
  end
  gFlashMgr:ReplaceActionBindings(kb.action, oldKeyName, newKeyName)
  if newInputIdx ~= nil then
    if newInputIdx == y + 1 then
      return
    end
    local nkb = mKeyBindings[newInputIdx]
    oldKeyName = BuildKeyBinding(nkb.pre, newInput, nkb.post)
    gFlashMgr:ReplaceActionBindings(nkb.action, oldKeyName, "")
  end
end
local function InitGrid(movie)
  FlashMethod(movie, "InputGrid.GridClass.Clear", "")
  FlashMethod(movie, "InputGrid.GridClass.SetDimensions", GRID_DimensionsW, GRID_DimensionsH)
  FlashMethod(movie, "InputGrid.GridClass.SetClipDimensions", GRID_DimensionsW, GRID_ClipDimensionsH)
  FlashMethod(movie, "InputGrid.GridClass.SetItemSpacing", 0, 0)
  for y = 1, GRID_DimensionsH do
    for x = 1, GRID_DimensionsW do
      local itemName = GetItemName(x - 1, y - 1)
      local templateName = "TemplateNarrow"
      if x == 1 then
        templateName = "TemplateWide"
      end
      FlashMethod(movie, "InputGrid.GridClass.SetItem", x - 1, y - 1, templateName, false)
      movie:SetVariable(string.format("%s.Selected._visible", itemName), false)
      local alpha = 2
      if y % 2 == 1 then
        alpha = 1
      end
      movie:SetVariable(string.format("%s.Background._alpha", itemName), alpha)
    end
  end
  FlashMethod(movie, "InputGrid.GridClass.SetCallbackPressed", "InputGridItemPressed")
  FlashMethod(movie, "InputGrid.GridClass.SetCallbackSelected", "InputGridItemSelected")
  FlashMethod(movie, "InputGrid.GridClass.SetCallbackUnselected", "InputGridItemUnselected")
  movie:SetVariable("TemplateNarrow._visible", false)
  movie:SetVariable("TemplateWide._visible", false)
  movie:SetFocus(GetItemName(1, 0))
  local sharedCRLN = movie:GetLocalized("/D2/Language/Menu/Shared_CRLN")
  for i = 1, GRID_DimensionsH do
    local kb = mKeyBindings[i]
    if kb == nil then
    else
      local itemName = GetItemName(0, i - 1)
      local locString = string.format("/D2/Language/Menu/Action_%s", kb.loc)
      local text = movie:GetLocalized(locString)
      local textField = "Text2"
      if string.find(text, "\n") == nil then
        textField = "Text1"
      end
      movie:SetVariable(string.format("%s.%s.text", itemName, textField), text)
      movie:SetLocalized(string.format("%s.%s.textAlign", itemName, textField), "right")
      kb.keyList = gFlashMgr:GetBindingsForAction(kb.action, true)
      PopulateActionKeys(movie, i - 1, kb)
    end
  end
end
function onRawInputEvent(movie, deviceID, keyName, isDown)
  if mInput.waitState ~= WAITSTATE_InputWait then
    return true
  end
  if string.find(keyName, "XBOX") ~= nil or string.find(keyName, "PS3") ~= nil or string.find(keyName, "MOUSE_X") ~= nil or string.find(keyName, "MOUSE_Y") ~= nil or string.find(keyName, "KEY_SYSRQ") ~= nil or string.find(keyName, "KEY_ESCAPE") ~= nil or string.find(keyName, "KEY_APPS") ~= nil or string.find(keyName, "KEY_LWIN") ~= nil or string.find(keyName, "KEY_RWIN") ~= nil then
    return true
  end
  SetWaitState(movie, WAITSTATE_Idle)
  ReplaceKeyBinding(movie, mCurSelectionX, mCurSelectionY, keyName)
  InitGrid(movie)
  return true
end
local function ScrollByButton(movie, dir)
  gRegion:PlaySound(sndScroll, Vector(), false)
  mScrubberPosition = mScrubberPosition + dir
  mScrubberPosition = Clamp(mScrubberPosition, 0, mScrubberRange)
  movie:SetVariable("InputGrid.GridClass.mItemOffsetY", mScrubberPosition)
  LIB.GridClassScroll(movie, "InputGrid", 0, 0)
end
function ScrollButtonCallbackL(movie, id)
  ScrollByButton(movie, -1)
end
function ScrollButtonCallbackR(movie, id)
  ScrollByButton(movie, 1)
end
function ScrollScrubberMoveCallback(movie, id)
  local newScrubberPosition = movie:GetVariable("VerticalScroll.ScrollClass.mPosition")
  local roundedNumber = math.floor(newScrubberPosition + 0.5)
  if roundedNumber ~= mScrubberPosition then
    gRegion:PlaySound(sndScroll, Vector(), false)
    movie:SetVariable("InputGrid.GridClass.mItemOffsetY", roundedNumber)
    LIB.GridClassScroll(movie, "InputGrid", 0, 0)
    mScrubberPosition = roundedNumber
  end
end
function Initialize(movie)
  mMovieInstance = movie
  FlashMethod(movie, "Popup.gotoAndPlay", "Play")
  mBanner = LIB.BannerInitialize(movie)
  mBanner.state = mBanner.STATE_Show
  mBanner.line = mBanner.LINE_Double
  mBanner.spinner = true
  mInputDeviceType = gFlashMgr:GetInputDeviceIconType()
  gFlashMgr:SetInputDeviceIconType(DIT_PC)
  mKeyBindings[#mKeyBindings + 1] = {
    action = "MOVE_Z",
    loc = "WALK_FORWARD",
    pre = "",
    post = "",
    context = "gameplay"
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "MOVE_Z",
    loc = "WALK_BACKWARD",
    pre = "",
    post = "INVERT=1",
    context = "gameplay"
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "MOVE_X",
    loc = "STRAFE_LEFT",
    pre = "",
    post = "INVERT=1",
    context = "gameplay"
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "MOVE_X",
    loc = "STRAFE_RIGHT",
    pre = "",
    post = "",
    context = "gameplay"
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "PRE_ATTACK",
    loc = "PRE_ATTACK",
    pre = "",
    post = "",
    context = "gameplay"
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "ACTION",
    loc = "ACTION",
    pre = "",
    post = "",
    context = "gameplay"
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "AIM_WEAPON",
    loc = "AIM_WEAPON",
    pre = "",
    post = "",
    context = "gameplay"
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "MELEE",
    loc = "MELEE",
    pre = "",
    post = "",
    context = "gameplay"
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "PICKUP",
    loc = "CONTEXT_ACTION",
    pre = "",
    post = "",
    context = "gameplay"
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "RELOAD",
    loc = "RELOAD",
    pre = "",
    post = "",
    context = "gameplay"
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "CONTEXT_POWER",
    loc = "CONTEXT_POWER",
    pre = "",
    post = "",
    context = "gameplay"
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "POWER_HELD",
    loc = "POWER_HELD",
    pre = "",
    post = "",
    context = "gameplay"
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "JUMP",
    loc = "JUMP",
    pre = "",
    post = "",
    context = "gameplay"
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "CROUCH",
    loc = "CROUCH",
    pre = "",
    post = "",
    context = "gameplay"
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "RUN",
    loc = "RUN_CC",
    pre = "",
    post = "",
    context = "gameplay"
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "UBER_ATTACK",
    loc = "UBER_ATTACK",
    pre = "",
    post = "",
    context = "gameplay"
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "SUMMON_SLOT_0",
    loc = "SUMMON_SLOT_0",
    pre = "",
    post = "",
    context = "gameplay"
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "SUMMON_SLOT_1",
    loc = "SUMMON_SLOT_1",
    pre = "",
    post = "",
    context = "gameplay"
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "SUMMON_SLOT_2",
    loc = "SUMMON_SLOT_2",
    pre = "",
    post = "",
    context = "gameplay"
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "SUMMON_SLOT_3",
    loc = "SUMMON_SLOT_3",
    pre = "",
    post = "",
    context = "gameplay"
  }
  if LIB.IsPC(movie) then
    mKeyBindings[#mKeyBindings + 1] = {
      action = "NEXT_INV",
      loc = "NEXT_INV",
      pre = "",
      post = "",
      context = "gameplay"
    }
    mKeyBindings[#mKeyBindings + 1] = {
      action = "PREV_INV",
      loc = "PREV_INV",
      pre = "",
      post = "",
      context = "gameplay"
    }
    mKeyBindings[#mKeyBindings + 1] = {
      action = "PUSH_TO_TALK",
      loc = "PUSH_TO_TALK",
      pre = "",
      post = "",
      context = "gameplay"
    }
    mKeyBindings[#mKeyBindings + 1] = {
      action = "TOGGLE_CHAT_WINDOW",
      loc = "TOGGLE_CHAT_WINDOW",
      pre = "",
      post = "",
      context = "gameplay"
    }
  end
  mKeyBindings[#mKeyBindings + 1] = {
    action = "FINISHER_SELECT_1",
    loc = "FINISHER_SELECT_1",
    pre = "",
    post = "",
    context = "executions"
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "FINISHER_SELECT_2",
    loc = "FINISHER_SELECT_2",
    pre = "",
    post = "",
    context = "executions"
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "FINISHER_SELECT_3",
    loc = "FINISHER_SELECT_3",
    pre = "",
    post = "",
    context = "executions"
  }
  mKeyBindings[#mKeyBindings + 1] = {
    action = "FINISHER_SELECT_4",
    loc = "FINISHER_SELECT_4",
    pre = "",
    post = "",
    context = "executions"
  }
  for i = #mKeyBindings, 1, -1 do
    mKeyBindings[i].isReadyOnly = false
  end
  movie:SetLocalized("Title.TxtHolder.Txt.text", "/D2/Language/Menu/CustomizeControls_Title")
  movie:SetVariable("Title.TxtHolder.Txt.textAlign", "center")
  movie:SetLocalized("PrimaryTitle.text", "/D2/Language/Menu/CustomizeControls_Title_Primary")
  movie:SetLocalized("SecondaryTitle.text", "/D2/Language/Menu/CustomizeControls_Title_Secondary")
  GRID_ClipDimensionsH = 10
  GRID_DimensionsH = #mKeyBindings
  GRID_DimensionsW = 3
  mInput.waitState = WAITSTATE_Idle
  mInput.waitCountdown = 0
  mInput.waitPrevCountdown = 0
  mCurSelectionX = -1
  mCurSelectionY = -1
  InitGrid(movie)
  mScrubberRange = GRID_DimensionsH - GRID_ClipDimensionsH
  FlashMethod(movie, "VerticalScroll.ScrollClass.SetSize", 240)
  FlashMethod(movie, "VerticalScroll.ScrollClass.SetRange", mScrubberRange)
  FlashMethod(movie, "VerticalScroll.ScrollClass.SetScrubberPos", mScrubberPosition)
  FlashMethod(movie, "VerticalScroll.ScrollClass.SetButton0PressedCallback", "ScrollButtonCallbackL")
  FlashMethod(movie, "VerticalScroll.ScrollClass.SetButton1PressedCallback", "ScrollButtonCallbackR")
  FlashMethod(movie, "VerticalScroll.ScrollClass.SetScrubberMoveCallback", "ScrollScrubberMoveCallback")
  FlashMethod(movie, "VerticalScroll.ScrollClass.SetFillerPressedCallback", "ScrollScrubberMoveCallback")
  for i = 1, #mStatusList do
    FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", mStatusList[i], mStatusList[i] ~= mStatusSelect)
  end
  FlashMethod(movie, "StatusBar.StatusBarClass.SetCallbackOnPress", "StatusButtonPressed")
end
local function UpdateInputTimers(movie)
  local rt = RealDeltaTime()
  if mInput.waitState == WAITSTATE_PreInputWait then
    mInput.waitCountdown = mInput.waitCountdown - rt
    if mInput.waitCountdown < 0 then
      SetWaitState(movie, WAITSTATE_InputWait)
    end
  elseif mInput.waitState == WAITSTATE_InputWait then
    mInput.waitPrevCountdown = math.floor(mInput.waitCountdown)
    mInput.waitCountdown = mInput.waitCountdown - rt
    local s = ""
    if mInput.waitCountdown > 0 then
      local cd = math.floor(mInput.waitCountdown)
      local strFmt = movie:GetLocalized("/D2/Language/Menu/CustomizeControls_WaitingForInput")
      mBanner.text = string.format(strFmt, cd)
      LIB.BannerSetText(movie, mBanner)
      if mInput.waitPrevCountdown ~= cd then
        gRegion:PlaySound(sndTime, Vector(), false)
      end
    else
      SetWaitState(movie, WAITSTATE_Idle)
    end
  end
end
function Update(movie)
  if IsWaitingForInput() then
    UpdateInputTimers(movie)
  end
end
local function Back(movie)
  if IsWaitingForInput() then
    return
  end
  local confirmInstance = gFlashMgr:FindMovie(popupConfirmMovie)
  if not IsNull(confirmInstance) and confirmInstance:GetParent() == movie then
    return
  end
  local isMissing = false
  for i = 0, GRID_DimensionsH do
    local itemName = GetItemName(1, i)
    local keyLabel = mKeyLabels[itemName]
    if keyLabel == "" then
      isMissing = true
      break
    end
  end
  if isMissing then
    local popupMovie = movie:PushChildMovie(popupConfirmMovie)
    FlashMethod(popupMovie, "CreateOkCancel", "/D2/Language/Menu/CustomizeControls_MissingKeys", popupItemOk, popupItemCancel, "")
    popupMovie:Execute("SetRightItemText", "")
    return
  end
  local hudInstance = gFlashMgr:FindMovie(movieHUD)
  if not IsNull(hudInstance) then
    hudInstance:Execute("InvalidateActionTextFields", "")
  end
  gRegion:PlaySound(sndBack, Vector(), false)
  gFlashMgr:SetInputDeviceIconType(DIT_AUTO)
  mMovieInstance:Close()
end
local function RemoveKeyBinding(movie)
  if mCurSelectionX < 0 or mCurSelectionY < 0 then
    return
  end
  ReplaceKeyBinding(movie, mCurSelectionX, mCurSelectionY, "")
  InitGrid(movie)
end
function ResetToDefaultKeyBindings(movie, args)
  if tonumber(args) == 0 then
    gFlashMgr:ResetKeyBindings()
    InitGrid(movie)
  end
end
local function ResetToDefaults(movie)
  local confirmInstance = gFlashMgr:FindMovie(popupConfirmMovie)
  if not IsNull(confirmInstance) and confirmInstance:GetParent() == movie then
    return
  end
  local popupMovie = movie:PushChildMovie(popupConfirmMovie)
  FlashMethod(popupMovie, "CreateOkCancel", "/D2/Language/Menu/CustomizeControls_ResetKeyBindings", popupItemOk, popupItemCancel, "ResetToDefaultKeyBindings")
end
function StatusButtonPressed(movie, buttonArg)
  local index = tonumber(buttonArg) + 1
  if mStatusList[index] == mStatusDefaults then
    ResetToDefaults(movie)
  elseif mStatusList[index] == mStatusRemove then
    RemoveKeyBinding(movie)
  elseif mStatusList[index] == mStatusBack then
    Back(movie)
  end
end
function onKeyDown_MENU_CANCEL(movie)
  if IsWaitingForInput() then
    return
  end
  Back(movie)
end
function onKeyDown_MENU_GENERIC1(movie)
  if IsWaitingForInput() then
    return
  end
  ResetToDefaults(movie)
end
function onKeyDown_MENU_GENERIC2(movie)
  if IsWaitingForInput() then
    return
  end
  RemoveKeyBinding(movie)
end
local function Move(movie, x, y)
  local ret = LIB.GridClassScroll(movie, "InputGrid", x, y)
  local yOffset = tonumber(movie:GetVariable("InputGrid.GridClass.mItemOffsetY"))
  mScrubberPosition = Clamp(yOffset, 0, mScrubberRange)
  FlashMethod(movie, "VerticalScroll.ScrollClass.SetScrubberPos", mScrubberPosition)
  return ret
end
function onKeyDown_MENU_RIGHT_FROM_ANALOG(movie)
  if mInput.waitState == WAITSTATE_InputWait then
    return true
  end
  return Move(movie, 1, 0)
end
function onKeyDown_MENU_RIGHT(movie)
  if mInput.waitState == WAITSTATE_InputWait then
    return true
  end
  return Move(movie, 1, 0)
end
function onKeyDown_MENU_LEFT_FROM_ANALOG(movie)
  if mInput.waitState == WAITSTATE_InputWait then
    return true
  end
  if mCurSelectionX <= 1 then
    return true
  end
  return Move(movie, -1, 0)
end
function onKeyDown_MENU_LEFT(movie)
  if mInput.waitState == WAITSTATE_InputWait then
    return true
  end
  if mCurSelectionX <= 1 then
    return true
  end
  return Move(movie, -1, 0)
end
function onKeyDown_MENU_UP_FROM_ANALOG(movie)
  if mInput.waitState == WAITSTATE_InputWait then
    return true
  end
  return Move(movie, 0, -1)
end
function onKeyDown_MENU_UP(movie)
  if mInput.waitState == WAITSTATE_InputWait then
    return true
  end
  return Move(movie, 0, -1)
end
function onKeyDown_MENU_DOWN_FROM_ANALOG(movie)
  if mInput.waitState == WAITSTATE_InputWait then
    return true
  end
  return Move(movie, 0, 1)
end
function onKeyDown_MENU_DOWN(movie)
  if mInput.waitState == WAITSTATE_InputWait then
    return true
  end
  return Move(movie, 0, 1)
end

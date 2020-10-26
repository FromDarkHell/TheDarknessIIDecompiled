local LIB = require("D2.Menus.SharedLibrary")
movieHUD = WeakResource()
movieLobby = WeakResource()
moviePause = WeakResource()
movieFriends = WeakResource()
local mStatusBack = "/D2/Language/Menu/Shared_Back"
local mStatusList = {mStatusBack}
local mShiftDown, mCapsOn
local mMaxCharacterCount = 0
local mActiveTextString = ""
local mActiveCursorPos = 0
local mTextHistory = {}
local mTextHistoryIndex = 0
local mCharMap = {}
local mNumEventMessages
local mWaitBeforeInput = 0
local mHUDInstance
local function UpdateEventMessageList(movie)
  local maxDisplayableEvents = 8
  local numMessages = gClient:GetNumMessages()
  if numMessages ~= mNumEventMessages then
    numMessages = Clamp(numMessages, 0, maxDisplayableEvents)
    for i = 0, maxDisplayableEvents - 1 do
      local msg = ""
      if i < numMessages then
        local eventMessage = gClient:GetMessage(i)
        if eventMessage.mMessageType == Engine.MT_CHAT then
          msg = eventMessage.mMessage
        end
      end
      movie:SetVariable(string.format("Event%i.Txt.text", i), msg)
    end
    mNumEventMessages = numMessages
  end
end
function Update(movie)
  UpdateEventMessageList(movie)
  if 0 < mWaitBeforeInput then
    mWaitBeforeInput = mWaitBeforeInput - RealDeltaTime()
  end
end
local RemoveCharacter = function(str, idx)
  local temp = ""
  local length = string.len(str)
  for i = 1, length do
    if i ~= idx then
      temp = temp .. string.char(string.byte(str, i))
    end
  end
  return temp
end
function onRawInputEvent(movie, deviceID, keyName, isDown)
  if 0 < mWaitBeforeInput then
    return
  end
  isDown = tonumber(isDown) == 1
  local tokenList = LIB.StringTokenize(keyName, "_")
  if #tokenList == 0 then
    return
  end
  if tokenList[1] ~= "KEY" then
    return true
  end
  local keyName = tokenList[2]
  local userFriendlyKey = ""
  if 1 < string.len(keyName) then
    if isDown and (keyName == "RETURN" or keyName == "NUMPADENTER") then
      if mActiveTextString ~= "" then
        local gameRules = gRegion:GetGameRules()
        gameRules:BroadcastChatMessage("/Multiplayer/PlayerChatText", mActiveTextString)
      end
      mTextHistory[#mTextHistory + 1] = mActiveTextString
      mActiveTextString = ""
      mActiveCursorPos = string.len(mActiveTextString)
    elseif keyName == "DELETE" and isDown then
      mActiveTextString = RemoveCharacter(mActiveTextString, mActiveCursorPos + 1)
    elseif keyName == "BACK" and isDown then
      mActiveTextString = RemoveCharacter(mActiveTextString, mActiveCursorPos)
      mActiveCursorPos = mActiveCursorPos - 1
    elseif keyName == "LSHIFT" or keyName == "RSHIFT" then
      mShiftDown = isDown
    elseif keyName == "CAPITAL" and isDown then
      mCapsOn = not mCapsOn
    elseif keyName == "UP" and isDown then
      if 1 < #mTextHistory then
        mTextHistoryIndex = mTextHistoryIndex - 1
        if mTextHistoryIndex <= 0 then
          mTextHistoryIndex = #mTextHistory
        end
        mActiveTextString = mTextHistory[mTextHistoryIndex]
        mActiveCursorPos = string.len(mActiveTextString) + 1
      end
    elseif keyName == "DOWN" and isDown then
      mTextHistoryIndex = mTextHistoryIndex + 1
      if mTextHistoryIndex > #mTextHistory then
        mTextHistoryIndex = 1
      end
      mActiveTextString = mTextHistory[mTextHistoryIndex]
      if mActiveTextString == nil then
        mActiveTextString = ""
      end
      mActiveCursorPos = string.len(mActiveTextString) + 1
    elseif keyName == "RIGHT" and isDown then
      mActiveCursorPos = mActiveCursorPos + 1
    elseif keyName == "LEFT" and isDown then
      mActiveCursorPos = mActiveCursorPos - 1
    elseif keyName == "HOME" and isDown then
      mActiveCursorPos = 0
    elseif keyName == "END" and isDown then
      mActiveCursorPos = string.len(mActiveTextString) + 1
    end
  end
  local keyModifier = ""
  local nameLength = string.len(tokenList[2])
  local firstChar = string.byte(tokenList[2], 1)
  if mCapsOn and nameLength == 1 and 65 <= firstChar and firstChar <= 90 then
    keyModifier = "+SHIFT"
  elseif mShiftDown then
    keyModifier = "+SHIFT"
  end
  if isDown then
    local charMapName = keyName .. keyModifier
    if mCharMap[charMapName] ~= nil then
      userFriendlyKey = mCharMap[charMapName]
    elseif mCharMap[keyName] ~= nil then
      userFriendlyKey = mCharMap[keyName]
    end
    if string.len(mActiveTextString) >= mMaxCharacterCount then
      return
    end
    local temp = ""
    local maxLength = 0
    if mActiveTextString ~= nil then
      maxLength = string.len(mActiveTextString)
    end
    if mActiveCursorPos == 0 then
      temp = userFriendlyKey .. mActiveTextString
    else
      for i = 1, maxLength do
        temp = temp .. string.char(string.byte(mActiveTextString, i))
        if i == mActiveCursorPos then
          temp = string.format("%s%s", temp, userFriendlyKey)
        end
      end
    end
    if string.len(temp) == 0 then
      temp = userFriendlyKey
    end
    mActiveTextString = temp
    movie:SetVariable("ActiveCharacterCount.text", mMaxCharacterCount - string.len(mActiveTextString))
    FlashMethod(movie, "SetActiveText", mActiveTextString)
    if userFriendlyKey ~= "" then
      mActiveCursorPos = mActiveCursorPos + 1
    end
  end
  if mActiveCursorPos < 0 then
    mActiveCursorPos = 0
  elseif mActiveCursorPos > string.len(mActiveTextString) then
    mActiveCursorPos = string.len(mActiveTextString)
  end
  local hiddenText = ""
  for i = 1, mActiveCursorPos do
    hiddenText = hiddenText .. string.char(string.byte(mActiveTextString, i))
  end
  FlashMethod(movie, "SetHiddenText", hiddenText)
  local hiddenTextWidth = movie:GetVariable("HiddenText.textWidth")
  local activeTextX = movie:GetVariable("ActiveText._x")
  movie:SetVariable("Cursor._x", activeTextX + hiddenTextWidth)
  return true
end
function Initialize(movie)
  local pause = gFlashMgr:FindMovie(moviePause)
  local friends = gFlashMgr:FindMovie(movieFriends)
  if not IsNull(pause) or not IsNull(friends) then
    movie:Close()
    return
  end
  mActiveTextString = ""
  mActiveCursorPos = 0
  gFlashMgr:SetInputDeviceIconType(DIT_PC)
  mHUDInstance = gFlashMgr:FindMovie(movieHUD)
  if IsNull(mHUDInstance) then
    mHUDInstance = gFlashMgr:FindMovie(movieLobby)
  end
  mHUDInstance:SetVariable("_root._visible", false)
  movie:SetLocalized("Title.text", "/D2/Language/Menu/ChatWindow_Title")
  mMaxCharacterCount = 90
  movie:SetVariable("ActiveCharacterCount.text", mMaxCharacterCount)
  mActiveTextString = ""
  movie:SetVariable("ActiveText.text", mActiveTextString)
  FlashMethod(movie, "UpdateCursorPos")
  mActiveCursorPos = string.len(mActiveTextString)
  mShiftDown = false
  mCapsOn = false
  movie:SetVariable("HiddenText._visible", false)
  mCharMap.SPACE = " "
  mCharMap.GRAVE = "`"
  mCharMap["GRAVE+SHIFT"] = "~"
  mCharMap["1+SHIFT"] = "!"
  mCharMap["2+SHIFT"] = "@"
  mCharMap["3+SHIFT"] = "#"
  mCharMap["4+SHIFT"] = "$"
  mCharMap["5+SHIFT"] = "%"
  mCharMap["6+SHIFT"] = "^"
  mCharMap["7+SHIFT"] = "&"
  mCharMap["8+SHIFT"] = "*"
  mCharMap["9+SHIFT"] = "("
  mCharMap["0+SHIFT"] = ")"
  mCharMap.APOSTROPHE = "'"
  mCharMap["APOSTROPHE+SHIFT"] = "\""
  mCharMap.COMMA = ","
  mCharMap["COMMA+SHIFT"] = "<"
  mCharMap.PERIOD = "."
  mCharMap["PERIOD+SHIFT"] = ">"
  mCharMap.SLASH = "/"
  mCharMap["SLASH+SHIFT"] = "?"
  mCharMap.MINUS = "-"
  mCharMap["MINUS+SHIFT"] = "_"
  mCharMap.EQUALS = "="
  mCharMap["EQUALS+SHIFT"] = "+"
  mCharMap.LBRACKET = "["
  mCharMap["LBRACKET+SHIFT"] = "{"
  mCharMap.RBRACKET = "]"
  mCharMap["RBRACKET+SHIFT"] = "}"
  mCharMap.BACKSLASH = "\\"
  mCharMap["BACKSLASH+SHIFT"] = "|"
  mCharMap.SEMICOLON = ";"
  mCharMap["SEMICOLON+SHIFT"] = ":"
  mCharMap.ADD = "+"
  mCharMap.SUBTRACT = "-"
  mCharMap.DIVIDE = "/"
  mCharMap.MULTIPLY = "*"
  mCharMap.DECIMAL = "."
  for i = 0, 9 do
    local c = string.char(48 + i)
    mCharMap[c] = tostring(i)
    mCharMap[string.format("NUMPAD%i", i)] = tostring(i)
  end
  for i = 1, 26 do
    local upper_c = string.char(65 + i - 1)
    mCharMap[string.format("%s+SHIFT", upper_c)] = string.upper(upper_c)
    local lower_c = string.char(97 + i - 1)
    mCharMap[string.upper(lower_c)] = string.lower(lower_c)
  end
  local localPlayers = gRegion:ScriptGetLocalPlayers()
  for i = 1, #mStatusList do
    FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", mStatusList[i], true)
  end
  FlashMethod(movie, "StatusBar.StatusBarClass.SetCallbackOnPress", "StatusButtonPressed")
  mWaitBeforeInput = 0.25
  gFlashMgr:SetRawInputEventEnabled(true)
end
local function Back(movie)
  gFlashMgr:SetRawInputEventEnabled(false)
  gFlashMgr:SetInputDeviceIconType(DIT_AUTO)
  if not IsNull(mHUDInstance) then
    mHUDInstance:SetVariable("_root._visible", true)
  end
  movie:Close()
end
function StatusButtonPressed(movie, buttonArg)
  local index = tonumber(buttonArg) + 1
  if mStatusList[index] == mStatusBack then
    Back(movie)
  end
end
function onKeyDown_MENU_CANCEL(movie)
  Back(movie)
end

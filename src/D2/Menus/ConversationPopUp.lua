waitForInputActionType = Type()
local mInputToOptionMapping = {}
local mOptionToInputMapping = {}
local mOptionText = {}
local mInstigator
local mIsPC = false
local mIgnoreInput = false
local mTitle = ""
local function SetOptionText(movie, option, locString)
  local finalString = ""
  local button = ""
  local locText = movie:GetLocalized(locString)
  if not mIsPC then
    button = movie:GetLocalized(string.format("<%s>", mOptionToInputMapping[option]))
  end
  if locText ~= "" then
    finalString = button .. " " .. locText
  end
  movie:SetVariable(string.format("TextArea%i.Line.Text.text", option), finalString)
  if finalString == "" then
    movie:SetVariable(string.format("TextArea%i.enabled", option), false)
  end
  FlashMethod(movie, string.format("TextArea%i.gotoAndPlay", option), "FadeIn")
  mOptionText[option] = finalString
end
function FadeOutDone(movie)
  movie:Close()
end
local function _NotifyClose(movie)
  mIgnoreInput = true
  for i = 1, 4 do
    FlashMethod(movie, string.format("TextArea%i.gotoAndPlay", i), "FadeOut")
  end
end
function NotifyClose(movie)
  _NotifyClose(movie)
  return 1
end
function Initialize(movie)
  mInstigator = movie:GetInstigator()
  if IsNull(mInstigator) then
    print("Could not find instigator to show prompts! Something has gone horribly wrong; Aborting!")
    movie:Close()
    return
  end
  mIgnoreInput = false
  local optionA = ""
  local optionB = ""
  local optionC = ""
  local optionSkip = ""
  local optionTitle = ""
  if mInstigator:IsA(waitForInputActionType) then
    optionA = mInstigator:GetActionText(nil)
  else
    optionA = mInstigator:GetOptionText(Engine.BaseConversationNode_OPTION_A)
    optionB = mInstigator:GetOptionText(Engine.BaseConversationNode_OPTION_B)
    optionC = mInstigator:GetOptionText(Engine.BaseConversationNode_OPTION_C)
    optionSkip = mInstigator:GetOptionText(Engine.BaseConversationNode_OPTION_SKIP)
    optionTitle = mInstigator:GetOptionTitle()
  end
  mInputToOptionMapping.CONVO_OPTION_A = Engine.BaseConversationNode_OPTION_A
  mInputToOptionMapping.CONVO_OPTION_B = Engine.BaseConversationNode_OPTION_B
  mInputToOptionMapping.CONVO_OPTION_C = Engine.BaseConversationNode_OPTION_C
  mInputToOptionMapping.CONVO_OPTION_SKIP = Engine.BaseConversationNode_OPTION_SKIP
  for key, value in pairs(mInputToOptionMapping) do
    mOptionToInputMapping[value] = key
  end
  local platform = movie:GetVariable("$platform")
  mIsPC = false
  FlashMethod(movie, "Initialize")
  movie:SetVariable("_root._visible", true)
  movie:SetVariable("Background.enabled", false)
  movie:SetLocalized("Title.Text.text", optionTitle)
  SetOptionText(movie, Engine.BaseConversationNode_OPTION_A, optionA)
  SetOptionText(movie, Engine.BaseConversationNode_OPTION_B, optionB)
  SetOptionText(movie, Engine.BaseConversationNode_OPTION_C, optionC)
  SetOptionText(movie, Engine.BaseConversationNode_OPTION_SKIP, optionSkip)
end
local function ProcessInput(movie, option)
  if mOptionText[option] ~= "" then
    mInstigator:SetUserSelection(option)
    _NotifyClose(movie)
  end
end
function TextAreaPressed(movie, arg)
  if mIsPC then
    local idx = tonumber(arg)
    if mOptionText[idx] ~= "" then
      ProcessInput(movie, idx)
    end
  end
end
function TextAreaRollOver(movie, arg)
  if mIsPC then
    local idx = tonumber(arg)
    if mOptionText[idx] ~= "" then
      movie:SetVariable(string.format("TextArea%i.Highlight._visible", idx), true)
    end
  end
end
function TextAreaRollOut(movie, arg)
  if mIsPC then
    local idx = tonumber(arg)
    movie:SetVariable(string.format("TextArea%i.Highlight._visible", idx), false)
  end
end
function onKeyDown_CONVO_OPTION_A(movie)
  if not mIsPC and not mIgnoreInput then
    ProcessInput(movie, mInputToOptionMapping.CONVO_OPTION_A)
  end
end
function onKeyDown_CONVO_OPTION_B(movie)
  if not mIsPC and not mIgnoreInput then
    ProcessInput(movie, mInputToOptionMapping.CONVO_OPTION_B)
  end
end
function onKeyDown_CONVO_OPTION_C(movie)
  if not mIsPC and not mIgnoreInput then
    ProcessInput(movie, mInputToOptionMapping.CONVO_OPTION_C)
  end
end
function onKeyDown_CONVO_OPTION_SKIP(movie)
  if not mIsPC and not mIgnoreInput then
    ProcessInput(movie, mInputToOptionMapping.CONVO_OPTION_SKIP)
  end
end

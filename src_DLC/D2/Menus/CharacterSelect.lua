local LIB = require("D2.Menus.SharedLibrary")
popupConfirmMovie = WeakResource()
binkTexture = Resource()
local SESSIONSTATE_WaitingForPlayers = 5
local SESSIONSTATE_JoiningSession = 3
local SESSIONSTATE_CreatingSession = 1
local statusSelect = "/D2/Language/Menu/Shared_Select"
local statusToggle = "/D2/Language/Menu/Shared_HToggle"
local statusList = {statusSelect, statusToggle}
local mScreenState
local mMissionList = {""}
local mIsHost = false
local mGameRules, mActivePopupMovie, mCharacter
local mCharacterAvailable = {}
local mNumCharacters = 0
local mCharacterSpacing = 110
local UpdateDescription = function(movie, charIdx)
end
local function SetCharacterSelected(movie, charIdx, isSelected)
  if charIdx == nil then
    return
  end
  local frameName = "Unselected"
  if isSelected then
    frameName = "Selected"
  end
  FlashMethod(movie, string.format("Character%i.gotoAndPlay", charIdx), frameName)
  UpdateDescription(movie, charIdx)
end
local function UpdateAvailableStatus(movie, charIdx, available)
  movie:SetVariable(string.format("Character%i.Frame.CannotSelect._visible", charIdx), not available)
  mCharacterAvailable[charIdx + 1] = available
  UpdateDescription(movie, charIdx)
end
local function InitializeCharacters(movie)
  local templateX = movie:GetVariable("Template._x")
  mNumCharacters = 4
  FlashMethod(movie, "GenerateCharacters", mNumCharacters)
  for i = 0, mNumCharacters - 1 do
    local x = templateX + i * mCharacterSpacing
    local mcName = string.format("Character%i._x", i)
    movie:SetVariable(mcName, x)
    UpdateAvailableStatus(movie, i, true)
    FlashMethod(movie, string.format("Character%i.Frame.Image.gotoAndStop", i), i + 1)
    SetCharacterSelected(movie, i, mCharacter == i)
  end
  movie:SetVariable("Template._visible", false)
end
function Selected(movie, arg)
  SetCharacterSelected(movie, mCharacter, false)
  mCharacter = tonumber(arg)
  SetCharacterSelected(movie, mCharacter, true)
end
function Unselected(movie, arg)
end
local function SelectCharacter(movie)
  local isAvailable = mCharacterAvailable[mCharacter + 1]
  if isAvailable ~= nil and isAvailable then
    local gameRules = gRegion:GetGameRules()
    gameRules:SetLocalCharacter(mCharacter)
    FlashMethod(movie, "CleanCharacters")
    movie:Close()
  end
end
function Pressed(movie, arg)
  SelectCharacter(movie)
end
function StatusButtonPressed(movie, buttonArg)
  local index = tonumber(buttonArg) + 1
  if statusList[index] == statusSelect then
    SelectCharacter(movie)
  end
end
function onKeyDown_MENU_SELECT(movie)
  SelectCharacter(movie)
end
function Initialize(movie)
  movie:SetTexture("BinkPlaceholder.png", binkTexture)
  gRegion:StartVideoTexture(binkTexture)
  movie:SetLocalized("Title.text", "/D2/Language/Menu/CharacterSelect_Title")
  if not Engine.GetPlayerProfileMgr():IsLoggedIn() then
    Engine.GetPlayerProfileMgr():LogIn(1, false, false, 0)
  end
  FlashMethod(movie, "Initialize")
  for i = 1, #statusList do
    FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", statusList[i], statusList[i] == statusSelect)
  end
  FlashMethod(movie, "StatusBar.StatusBarClass.SetCallbackOnPress", "StatusButtonPressed")
  mCharacter = 0
  InitializeCharacters(movie)
end
function onKeyDown_MENU_UP_FROM_ANALOG(movie)
  return true
end
function onKeyDown_MENU_UP(movie)
  return true
end
function onKeyDown_MENU_DOWN_FROM_ANALOG(movie)
  return true
end
function onKeyDown_MENU_DOWN(movie)
  return true
end
function Update(movie)
  for i = 0, mNumCharacters - 1 do
    UpdateAvailableStatus(movie, i, true)
  end
  local humanPlayers = gRegion:GetHumanPlayers()
  if not IsNull(humanPlayers) then
    for i = 1, #humanPlayers do
      if IsNull(humanPlayers[i]) then
      else
        local theAvatar = humanPlayers[i]:GetAvatar()
        if IsNull(theAvatar) then
        else
          local charType = theAvatar:GetCharacterType()
          UpdateAvailableStatus(movie, charType, false)
        end
      end
    end
  end
  if mCharacter ~= nil then
    local isAvailable = mCharacterAvailable[mCharacter + 1] ~= nil and mCharacterAvailable[mCharacter + 1]
    FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByName", statusSelect, isAvailable)
  end
end
local function ChangeCharacter(movie, dir)
  if mCharacter == 0 and dir == 1 or mCharacter + 1 == mNumCharacters and dir == -1 then
    return true
  end
  movie:SetVariable("Description.text", "")
  SetCharacterSelected(movie, mCharacter, false)
  mCharacter = mCharacter + -dir
  SetCharacterSelected(movie, mCharacter, true)
  return true
end
function ScrollLeft(movie)
  ChangeCharacter(movie, 1)
end
function ScrollRight(movie)
  ChangeCharacter(movie, -1)
end
function onKeyDown_MENU_LEFT_FROM_ANALOG(movie)
  return ChangeCharacter(movie, 1)
end
function onKeyDown_MENU_LEFT(movie)
  return ChangeCharacter(movie, 1)
end
function onKeyDown_MENU_RIGHT_FROM_ANALOG(movie)
  return ChangeCharacter(movie, -1)
end
function onKeyDown_MENU_RIGHT(movie)
  return ChangeCharacter(movie, -1)
end
function onKeyDown_MENU_MOUSE_X(movie)
  return false
end
function onKeyDown_MENU_MOUSE_Y(movie)
  return false
end

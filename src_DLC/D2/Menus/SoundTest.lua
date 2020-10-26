local LIB = require("D2.Menus.SharedLibrary")
local soundList = {}
local filteredSoundList = {}
local soundInstance
local initialLookupFinished = false
local currentIndex = 1
local maxOperationsPerFrame = 1000
function Initialize(movie)
  if not IsNull(gRegion:GetGameRules()) then
    gRegion:GetGameRules():RequestPause()
  end
  FlashMethod(movie, "OptionList.ListClass.SetLetterSpacing", 2)
  FlashMethod(movie, "OptionList.ListClass.SetAlignment", "left")
  FlashMethod(movie, "OptionList.ListClass.SetPressedCallback", "ListButtonPressed")
  FlashMethod(movie, "OptionList.ListClass.SetSelectedCallback", "ListButtonChanged")
  FlashMethod(movie, "OptionList.ListClass.SetSelected", 0)
  FlashMethod(movie, "OptionList.ListClass.AddItem", "Preparing sounds. Please wait...", false)
end
function Shutdown(movie)
  if not IsNull(gRegion:GetGameRules()) then
    gRegion:GetGameRules():RequestUnpause()
  end
end
function Update(movie, delta)
  if initialLookupFinished then
    local count = 0
    for i = currentIndex, #soundList do
      local curSound = soundList[i]
      if string.find(curSound, "MPDialog") ~= nil or string.find(curSound, "SpCharacterBarks") ~= nil or string.find(curSound, "SPDialog") ~= nil or string.find(curSound, "SpLevelBarks") ~= nil or string.find(curSound, "VendettasBarks") ~= nil then
        FlashMethod(movie, "OptionList.ListClass.AddItem", soundList[i], false)
        filteredSoundList[#filteredSoundList + 1] = soundList[i]
      end
      currentIndex = currentIndex + 1
      count = count + 1
      if count > maxOperationsPerFrame then
        break
      end
    end
  else
    initialLookupFinished = true
    soundList = gRegion:GetLocalizedSounds()
    FlashMethod(movie, "OptionList.ListClass.Clear")
  end
end
local function PlaySound(sound)
  if not IsNull(soundInstance) then
    soundInstance:Stop(true)
    soundInstance = nil
  end
  soundInstance = gRegion:PlaySound(sound, gRegion:GetPlayerAvatar():GetPosition(), false)
end
local Back = function(movie)
  movie:Close()
end
function onKeyDown_MENU_CANCEL(movie)
  Back(movie)
end
function ListButtonPressed(movie, buttonArg)
  local index = tonumber(buttonArg) + 1
  local soundName = filteredSoundList[index]
  local soundRes = Resource(soundName)
  PlaySound(soundRes)
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

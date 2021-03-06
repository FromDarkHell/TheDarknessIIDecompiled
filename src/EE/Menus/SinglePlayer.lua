function Initialize(movie)
  local defaultGameRules = gGameConfig:GetDefaultGameRules()
  local demoLevels = defaultGameRules.mLevels
  local levelNames = demoLevels:GetLevelNames(true)
  FlashMethod(movie, "InitScreen", "/EE_Menus/SinglePlayer_Title")
  if levelNames ~= nil then
    for i = 1, #levelNames do
      local levelName = levelNames[i]
      FlashMethod(movie, "OptionList.ListClass.AddItem", levelName, true)
    end
  end
  FlashMethod(movie, "OptionList.ListClass.SetListItemsSeletable", true)
  FlashMethod(movie, "OptionList.ListClass.EnableArrows", false)
  FlashMethod(movie, "OptionList.ListClass.SetPressedCallback", "ListButtonPressed")
  FlashMethod(movie, "OptionList.ListClass.SetSelected", 0)
  FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", "/EE_Menus/Shared_Select")
  FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", "/EE_Menus/Shared_Back")
  movie:GetParent():SetVariable("_alpha", 0)
end
function ListButtonPressed(movie, buttonArg)
  local index = tonumber(buttonArg)
  local defaultGameRules = gGameConfig:GetDefaultGameRules()
  local demoLevels = defaultGameRules.mLevels
  local levelNames = demoLevels:GetLevelNames(true)
  local openArgs = Engine.OpenLevelArgs()
  openArgs:SetLevel(levelNames[index + 1])
  openArgs.saveOnStart = true
  openArgs.migrateServer = false
  gFlashMgr:CloseAllMovies()
  Engine.OpenLevel(openArgs)
end
function onKeyDown_MENU_CANCEL(movie)
  movie:GetParent():SetVariable("_alpha", 100)
  movie:Close()
end
local Scroll = function(movie, dir)
  local curScrollPos = tonumber(movie:GetVariable("OptionList.ListClass.mScrollPos"))
  local curSelection = tonumber(movie:GetVariable("OptionList.ListClass.mCurrentSelection"))
  local numLabels = tonumber(movie:GetVariable("OptionList.ListClass.numLabels"))
  local numElements = tonumber(movie:GetVariable("OptionList.ListClass.numElements"))
  local maxSize = math.min(numLabels, numElements)
  if dir == -1 then
    if curSelection == 0 then
      if 0 < curScrollPos then
        FlashMethod(movie, "OptionList.ListClass.ScrollUp")
      end
      return true
    end
  elseif dir == 1 and maxSize <= curSelection + 1 then
    FlashMethod(movie, "OptionList.ListClass.ScrollDown")
    return true
  end
  return false
end
function onKeyDown_MENU_UP_FROM_ANALOG(movie)
  return Scroll(movie, -1)
end
function onKeyDown_MENU_UP(movie)
  return Scroll(movie, -1)
end
function onKeyDown_MENU_DOWN_FROM_ANALOG(movie)
  local r = Scroll(movie, 1)
  return r
end
function onKeyDown_MENU_DOWN(movie)
  local r = Scroll(movie, 1)
  print("focus=", movie:GetFocus())
  return r
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

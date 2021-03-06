itemPressStartMovie = Resource()
local itemPressStart = "/EE_Menus/PressStart_Item_PressStart"
local itemList = {" "}
function Initialize(movie)
  if not Engine.GetPlayerProfileMgr():IsLoggedIn() then
    Engine.GetPlayerProfileMgr():LogIn(1, false, false, 0)
  end
  itemList = {itemPressStart}
  for i = 1, #itemList do
    FlashMethod(movie, "OptionList.ListClass.AddItem", itemList[i], false)
  end
  FlashMethod(movie, "OptionList.ListClass.SetPressedCallback", "ListButtonPressed")
  FlashMethod(movie, "OptionList.ListClass.SetSelected", 0)
end
local Advance = function(movie)
  movie:Close()
  gFlashMgr:GotoMovie(itemPressStartMovie)
end
function ListButtonPressed(movie, buttonArg)
  Advance(movie)
end
function onKeyDown_PRESS_START(movie)
  Advance(movie)
  return 1
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

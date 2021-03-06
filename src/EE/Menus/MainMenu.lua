itemSinglePlayerMovie = Resource()
itemMultiPlayerMovie = Resource()
itemOptionsMovie = Resource()
local itemSinglePlayer = "/EE_Menus/MainMenu_Item_SinglePlayer"
local itemMultiPlayer = "/EE_Menus/MainMenu_Item_MultiPlayer"
local itemOptions = "/EE_Menus/MainMenu_Item_Options"
local itemList = {" "}
local gameHosted = false
function Initialize(movie)
  if not Engine.GetPlayerProfileMgr():IsLoggedIn() then
    Engine.GetPlayerProfileMgr():LogIn(1, false, false, 0)
  end
  FlashMethod(movie, "InitScreen", "Evolution")
  itemList = {
    itemSinglePlayer,
    itemMultiPlayer,
    itemOptions
  }
  for i = 1, #itemList do
    FlashMethod(movie, "OptionList.ListClass.AddItem", itemList[i], false)
  end
  FlashMethod(movie, "OptionList.ListClass.SetPressedCallback", "ListButtonPressed")
  FlashMethod(movie, "OptionList.ListClass.SetSelected", 0)
  FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", "/EE_Menus/Shared_Select")
end
function ListButtonPressed(movie, buttonArg)
  local index = tonumber(buttonArg) + 1
  if itemList[index] == itemSinglePlayer then
    movie:PushChildMovie(itemSinglePlayerMovie)
  elseif itemList[index] == itemMultiPlayer then
    if not Engine.GetPlayerProfileMgr():IsLoggedIn() then
      Engine.GetPlayerProfileMgr():LogIn(1, false, false, 0)
    end
    movie:PushChildMovie(itemMultiPlayerMovie)
  elseif itemList[index] == itemOptions then
    movie:PushChildMovie(itemOptionsMovie)
  end
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

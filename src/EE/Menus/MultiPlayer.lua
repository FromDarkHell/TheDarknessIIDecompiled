itemHostMovie = Resource()
itemSearchMovie = Resource()
local itemHost = "/EE_Menus/MultiPlayer_Item_Host"
local itemSearch = "/EE_Menus/MultiPlayer_Item_Search"
local itemList = {" "}
function Initialize(movie)
  if not Engine.GetPlayerProfileMgr():IsLoggedIn() then
    Engine.GetPlayerProfileMgr():LogIn(1, false, false, 0)
  end
  FlashMethod(movie, "InitScreen", "/EE_Menus/MultiPlayer_Title")
  itemList = {itemSearch, itemHost}
  for i = 1, #itemList do
    FlashMethod(movie, "OptionList.ListClass.AddItem", itemList[i], false)
  end
  FlashMethod(movie, "OptionList.ListClass.SetPressedCallback", "ListButtonPressed")
  FlashMethod(movie, "OptionList.ListClass.SetSelected", 0)
  FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", "/EE_Menus/Shared_Select")
  FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", "/EE_Menus/Shared_Back")
  movie:GetParent():SetVariable("_alpha", 0)
end
function ListButtonPressed(movie, buttonArg)
  local index = tonumber(buttonArg) + 1
  if itemList[index] == itemHost then
    movie:PushChildMovie(itemHostMovie)
  elseif itemList[index] == itemSearch then
    movie:PushChildMovie(itemSearchMovie)
  end
end
function onKeyDown_MENU_CANCEL(movie)
  movie:GetParent():SetVariable("_alpha", 100)
  movie:Close()
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

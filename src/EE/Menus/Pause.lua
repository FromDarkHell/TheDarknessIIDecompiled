secretsMenuMovie = WeakResource()
popupConfirmMovie = WeakResource()
optionsMenuMovie = WeakResource()
itemChallengesMovie = Resource()
local itemResume = "/EE_Menus/Pause_Item_Resume"
local itemChallenges = "/EE_Menus/Pause_Item_Challenges"
local itemRestartChapter = "/EE_Menus/Pause_Item_RestartChapter"
local itemRestartCheckpoint = "/EE_Menus/Pause_Item_RestartCheckpoint"
local itemMainMenu = "/EE_Menus/Pause_Item_MainMenu"
local itemOptions = "/EE_Menus/MainMenu_Item_Options"
local itemSecrets = "/EE_Menus/Pause_Item_Secrets"
local itemConfig = "/EE_Menus/Pause_Item_Config"
local itemList = {" "}
local popupItemOk = "/EE_Menus/Confirm_Item_Ok"
local mGameRules, mIsMultiplayer, mStartButtonIsDown
function Initialize(movie)
  if Engine.GetMatchingService():GetState() == 0 then
    mIsMultiplayer = false
  else
    mIsMultiplayer = true
  end
  mGameRules = gRegion:GetGameRules()
  mStartButtonIsDown = false
  mGameRules:RequestPause()
  FlashMethod(movie, "InitScreen", "/EE_Menus/Pause_Title")
  itemList = {
    itemResume,
    itemRestartChapter,
    itemMainMenu,
    itemOptions,
    itemSecrets
  }
  for i = 1, #itemList do
    FlashMethod(movie, "OptionList.ListClass.AddItem", itemList[i], false)
  end
  FlashMethod(movie, "OptionList.ListClass.SetPressedCallback", "ListButtonPressed")
  FlashMethod(movie, "OptionList.ListClass.SetSelected", 0)
  FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", "/EE_Menus/Shared_Select")
  FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", "/EE_Menus/Shared_Back")
end
local function Close(movie)
  mGameRules:RequestUnpause()
  movie:Close()
end
function onKeyDown_MENU_CANCEL(movie)
  Close(movie)
end
function onKeyDown_HIDE_PAUSE_MENU(movie)
  mStartButtonIsDown = true
end
function onKeyUp_HIDE_PAUSE_MENU(movie)
  if mStartButtonIsDown then
    Close(movie)
  end
end
function RestartConfirm(movie, args)
  if args == popupItemOk then
    movie:RestartLevel()
    Close(movie)
  end
end
function RestartCheckpointConfirm(movie, args)
  if args == popupItemOk then
    movie:RestartCheckpoint()
    Close(movie)
  end
end
function MainMenuConfirm(movie, args)
  if args == popupItemOk then
    Engine.Disconnect(true)
    Close(movie)
  end
end
function ListButtonPressed(movie, buttonArg)
  local index = tonumber(buttonArg) + 1
  if itemList[index] == itemResume then
    Close(movie)
  elseif itemList[index] == itemRestartChapter then
    local popupMovie = movie:PushChildMovie(popupConfirmMovie)
    FlashMethod(popupMovie, "CreateOkCancel", "Menu/RestartConfirm", "", "", "RestartConfirm")
  elseif itemList[index] == itemRestartCheckpoint then
    local popupMovie = movie:PushChildMovie(popupConfirmMovie)
    FlashMethod(popupMovie, "CreateOkCancel", "Menu/RestartCheckpointConfirm", "", "", "RestartCheckpointConfirm")
  elseif itemList[index] == itemMainMenu then
    local popupMovie = movie:PushChildMovie(popupConfirmMovie)
    FlashMethod(popupMovie, "CreateOkCancel", "Menu/MainMenuConfirm", "", "", "MainMenuConfirm")
  elseif itemList[index] == itemOptions then
    movie:PushChildMovie(optionsMenuMovie)
  elseif itemList[index] == itemSecrets then
    movie:PushChildMovie(secretsMenuMovie)
  end
end
function onKeyDown_MENU_RIGHT_FROM_ANALOG(movie)
  return true
end
function onKeyDown_MENU_RIGHT(movie)
  return true
end
function onKeyDown_MENU_LEFT_FROM_ANALOG(movie)
  return true
end
function onKeyDown_MENU_LEFT(movie)
  return true
end

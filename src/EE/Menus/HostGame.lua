popupConfirmMovie = Resource()
itemGameTypeMovie = Resource()
itemMapListMovie = Resource()
local itemGameType = "/EE_Menus/HostGame_Item_GameType"
local itemMapList = "/EE_Menus/HostGame_Item_MapList"
local itemStartMatch = "/EE_Menus/HostGame_Item_StartMatch"
local itemList = {" "}
local popupItemOk = "/EE_Menus/Confirm_Item_Ok"
local popupItemCancel = "/EE_Menus/Confirm_Item_Cancel"
local _DisplayGameInfo = function(movie)
  local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  local profileSettings = playerProfile:Settings()
  local gameHostSettings = profileSettings:GetHostSettings()
  local multiplayerGameRules = gGameConfig:GetMultiplayerGameRules(gameHostSettings.gameModeId)
  local gameRulesName = ""
  local maps = gameHostSettings:GetMaps()
  local mapName = ""
  if multiplayerGameRules ~= nil and multiplayerGameRules.mFriendlyName ~= "" then
    gameRulesName = multiplayerGameRules.mFriendlyName
  end
  if maps ~= nil and maps[1] ~= nil then
    mapName = maps[1]
  end
  FlashMethod(movie, "SetSelectedGame", gameRulesName)
  FlashMethod(movie, "SetSelectedMap", mapName)
end
function DisplayGameInfo(movie)
  _DisplayGameInfo(movie)
end
function Initialize(movie)
  if not Engine.GetPlayerProfileMgr():IsLoggedIn() then
    Engine.GetPlayerProfileMgr():LogIn(1, false, false, 0)
  end
  FlashMethod(movie, "InitScreen", "/EE_Menus/HostGame_Title")
  itemList = {
    itemGameType,
    itemMapList,
    itemStartMatch
  }
  for i = 1, #itemList do
    FlashMethod(movie, "OptionList.ListClass.AddItem", itemList[i], false)
  end
  FlashMethod(movie, "OptionList.ListClass.SetAlignment", "right")
  FlashMethod(movie, "OptionList.ListClass.SetPressedCallback", "ListButtonPressed")
  FlashMethod(movie, "OptionList.ListClass.SetSelected", 0)
  FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", "/EE_Menus/Shared_Select")
  FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", "/EE_Menus/Shared_Back")
  movie:GetParent():SetVariable("_alpha", 0)
  _DisplayGameInfo(movie)
end
local StartLanGame = function(movie)
  local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  local profileSettings = playerProfile:Settings()
  local gameHostSettings = profileSettings:GetHostSettings()
  local multiplayerGameRules = gGameConfig:GetMultiplayerGameRules(gameHostSettings.gameModeId)
  local args = Engine.OpenLevelArgs()
  local multiplayerMaps = gameHostSettings.maps
  local gameRuleInfo = gGameConfig:GetMultiplayerGameRules(0)
  local multiplayerLevels = gGameConfig:GetMultiplayerLevels()
  local gameLevel = multiplayerLevels[1]
  local gameMapName = gameHostSettings:GetMaps()[1]
  gFlashMgr:CloseAllMovies()
  args:SetLevel(gameMapName)
  args.gameRules = multiplayerGameRules.mGameRules
  if gameRuleInfo.mLobbyMovie ~= nil then
    args.menuMovie = gameRuleInfo.mLobbyMovie
  end
  args.hostingMultiplayer = true
  args.migrateServer = false
  Engine.OpenLevel(args)
end
function CreateGameConfirmCallback(movie, args)
  if args == popupItemOk then
    if not Engine.GetPlayerProfileMgr():IsLoggedIn() then
      Engine.GetPlayerProfileMgr():LogIn(1, false, false, 0)
    end
    local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
    local profileSettings = playerProfile:Settings()
    local hostSettings = profileSettings:GetHostSettings()
    local settings = Engine.SessionSettings()
    settings.gameModeId = hostSettings.gameModeId
    settings.matchType = 2
    settings.maxPlayers = hostSettings.maxPlayers
    settings.minPlayers = 1
    local hostMaps = gGameConfig:GetMultiplayerLevels()
    settings.map = hostMaps[1]:GetResourceName()
    Engine.GetMatchingService():HostSession(playerProfile, settings)
    StartLanGame(movie)
  end
end
function onKeyDown_MENU_CANCEL(movie)
  movie:GetParent():SetVariable("_alpha", 100)
  movie:Close()
end
function ListButtonPressed(movie, buttonArg)
  local index = tonumber(buttonArg) + 1
  if itemList[index] == itemStartMatch then
    if not Engine.GetPlayerProfileMgr():IsLoggedIn() then
      Engine.GetPlayerProfileMgr():LogIn(1, false, false, 0)
    end
    local popupMovie = movie:PushChildMovie(popupConfirmMovie)
    FlashMethod(popupMovie, "CreateOkCancel", "/EE_Menus/HostGame_Popup_Description", "", "", "CreateGameConfirmCallback")
  elseif itemList[index] == itemGameType then
    movie:PushChildMovie(itemGameTypeMovie)
  elseif itemList[index] == itemMapList then
    movie:PushChildMovie(itemMapListMovie)
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

local UpdatePlayerList, EveryoneIsReady, TeamIsReady, localPlayers, gameRules
local itemReady = "/EE_Menus/TDMGameLobby_Item_Ready"
local itemStartGame = "/EE_Menus/TDMGameLobby_Item_StartGame"
local itemList = {" "}
function Initialize(movie)
  local isHost = false
  if Engine.GetMatchingService():IsHost() == true then
    isHost = true
  end
  localPlayers = gRegion:ScriptGetLocalPlayers()
  gameRules = gRegion:GetGameRules()
  FlashMethod(movie, "InitScreen", "/EE_Menus/FFAGameLobby_Title")
  itemList = {}
  if isHost then
    itemList[#itemList + 1] = itemStartGame
  end
  for i = 1, #itemList do
    FlashMethod(movie, "OptionList.ListClass.AddItem", itemList[i], false)
  end
  FlashMethod(movie, "OptionList.ListClass.SetPressedCallback", "ListButtonPressed")
  FlashMethod(movie, "OptionList.ListClass.SetSelected", 0)
  FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", "/EE_Menus/Shared_Select")
  FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", "/EE_Menus/Shared_Back")
  FlashMethod(movie, "PlayerList.ListClass.SetAlignment", "left")
end
function Update(movie)
  UpdatePlayerList(movie)
  local gameStarted = false
  localPlayers = gRegion:ScriptGetLocalPlayers()
  gameRules = gRegion:GetGameRules()
  if gameRules ~= nil then
    gameStarted = gameRules:GameStarted()
  end
  if gameStarted == true then
    gameRules:StopAttractMode()
    movie:Close()
  end
end
function UpdatePlayerList(movie)
  FlashMethod(movie, "PlayerList.ListClass.EraseItems")
  local teamOne = gRegion:GetHumanPlayers()
  if teamOne ~= nil then
    for i = 1, #teamOne do
      local player = teamOne[i]
      if player ~= nil then
        local name
        local teamId = player:GetTeam()
        if player:IsReady() == true then
          name = player:GetPlayerName() .. "... is Ready!"
        else
          name = player:GetPlayerName() .. "... is not Ready"
        end
        FlashMethod(movie, "PlayerList.ListClass.AddItem", name, true)
      end
    end
  end
end
function EveryoneIsReady()
  local result = true
  local playerList = gRegion:GetHumanPlayers()
  if playerList ~= nil then
    for i = 1, #playerList do
      local player = playerList[i]
      if player ~= nil and player:IsReady() ~= true then
        result = false
      end
    end
  end
  return result
end
local function StartGame(movie)
  local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  local profileSettings = playerProfile:Settings()
  if localPlayers ~= nil then
    for i = 1, #localPlayers do
      localPlayers[i]:SetPlayerIsReady(true)
    end
  end
  if Engine.GetMatchingService():IsHost() == true then
    local teamsAreReady = true
    if teamsAreReady == true then
      local playerToStart = localPlayers[1]
      gameRules:StartGame(playerToStart)
      gameRules:StopAttractMode()
      movie:Close()
    end
  end
end
function ListButtonPressed(movie, buttonArg)
  local index = tonumber(buttonArg) + 1
  if itemList[index] == itemStartGame then
    StartGame(movie)
  end
end
function onKeyDown_MENU_CANCEL(movie)
  Engine.Disconnect(true)
  movie:Close()
end

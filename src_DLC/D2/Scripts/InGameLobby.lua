local LIB = require("D2.Menus.SharedLibrary")
multiMenuMovie = Resource()
loadoutMovie = Resource()
mainMenuPopupConfirmMovie = Resource()
avatarModifier = Instance()
assignWeaponsToProfile = false
talentPointCost = 200
local popupItemOk = "/D2/Language/Menu/Confirm_Item_Ok"
local popupItemCancel = "/D2/Language/Menu/Confirm_Item_Cancel"
local gameInviteSubject = "/D2/Language/MPGame/GameInviteSubject"
local gameInviteMessage = "/D2/Language/MPGame/GameInviteMessage"
local stupidToggle = true
function Multiplayer()
  if gRegion:GetGameRules():Paused() == false then
    gRegion:GetGameRules():RequestPause()
    local multiMenu = gFlashMgr:PushMovie(multiMenuMovie)
  end
end
function MpTalents(avatar)
  if avatar:GetPlayer():IsLocal() then
    local showingPause = gRegion:GetGameRules():IsPauseMenuShowing()
    if showingPause then
      avatar:ScriptInventoryControl():RaiseWeapons()
    else
      local profileData = avatar:ScriptInventoryControl():GetProfileDataForTalents()
      if not IsNull(profileData) then
        local talentPointTotal = profileData:GetTalentPoints(avatar:GetCharacterType())
        if talentPointTotal >= talentPointCost then
          profileData:SetTalentPoints(avatar:GetCharacterType(), talentPointTotal - talentPointCost)
          gFlashMgr:PushMovie(loadoutMovie)
        end
      end
    end
  end
end
function Loadout(avatar)
  local loadout = gFlashMgr:PushMovie(loadoutMovie)
  while not IsNull(loadout) do
    Sleep(1)
  end
  if not IsNull(avatarModifier) then
    avatarModifier:FirePort("Activate")
  end
end
function MainMenuConfirm(movie, args)
  if tonumber(args) == 0 then
    Engine.GetMatchingService():DisableSessionReconnect()
    Engine.Disconnect(true)
  end
end
function MainMenu()
  Engine.GetMatchingService():DisableSessionReconnect()
  Engine.Disconnect(true)
end
function StartGame()
  if Engine.GetMatchingService():IsHost() then
    if stupidToggle then
      local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
      local profileSettings = playerProfile:Settings()
      local gameHostSettings = profileSettings:GetHostSettings()
      local multiplayerGameRules = gGameConfig:GetMultiplayerGameRules(gameHostSettings.gameModeId)
      local multiplayerMaps = gameHostSettings:GetMaps()
      if multiplayerMaps == nil or multiplayerMaps[1] == nil then
        return
      end
      local multiplayerLevels = gGameConfig:GetMultiplayerLevels()
      local gameMapName = gameHostSettings:GetMaps()[1]
      local args = Engine.OpenLevelArgs()
      args:SetLevel(gameMapName)
      args.gameRules = multiplayerGameRules.mGameRules
      if multiplayerGameRules.mLobbyMovie ~= nil then
        args.menuMovie = multiplayerGameRules.mLobbyMovie
      end
      args.hostingMultiplayer = true
      args.migrateServer = true
      Engine.OpenLevel(args)
    end
    stupidToggle = not stupidToggle
  end
end
function SendGameInvite()
  local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  Engine.GetMatchingService():ShowSystemGameInviteUI(playerProfile, gameInviteSubject, gameInviteMessage)
end

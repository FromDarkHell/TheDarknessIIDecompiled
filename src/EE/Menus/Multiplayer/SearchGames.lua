local gameSearching = false
local itemRefresh = "/EE_Menus/SearchGames_Item_Refresh"
local itemList = {" "}
local RefreshList = function(movie)
  FlashMethod(movie, "GameList.ListClass.EraseItems")
  FlashMethod(movie, "PlayersList.ListClass.EraseItems")
  FlashMethod(movie, "GameList.ListClass.SetPressedCallback", "GameListButtonPressed")
  local searchResults = Engine.GetMatchingService():GetSearchResults()
  if searchResults ~= nil then
    for i = 1, #searchResults do
      local mapname = movie:GetLocalized("/Multiplayer/" .. searchResults[i]:GetSettings().map)
      local filledSlots = searchResults[i]:GetFilledSlots()
      local host = searchResults[i]:GetHostName()
      FlashMethod(movie, "GameList.ListClass.AddItem", host, false)
      FlashMethod(movie, "PlayersList.ListClass.AddItem", filledSlots, false)
      if i == 1 then
        movie:SetFocus("GameList.ListClass.ButtonLabel0")
      end
    end
    FlashMethod(movie, "GameList.ListClass.SetSelected", 0)
  end
end
local function SearchForGames(movie)
  local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  local profileSettings = playerProfile:Settings()
  local hostSettings = profileSettings:GetHostSettings()
  local searchArgs = Engine.SessionSearch()
  searchArgs.matchType = 2
  searchArgs.gameModeId = hostSettings.gameModeId
  searchArgs.wantPlayers = false
  searchArgs.wantMap = false
  searchArgs.wantScoreLimit = false
  searchArgs.wantTimeLimit = false
  Engine.GetMatchingService():FindSessions(playerProfile, searchArgs)
  gameSearching = true
end
function Initialize(movie)
  SearchForGames(movie)
  FlashMethod(movie, "InitScreen", "/EE_Menus/SearchGames_Title")
  FlashMethod(movie, "GameList.ListClass.SetAlignment", "right")
  FlashMethod(movie, "GameList.ListClass.SetTitle", "/EE_Menus/SearchGames_Title_Game")
  FlashMethod(movie, "PlayersList.ListClass.SetAlignment", "left")
  FlashMethod(movie, "PlayersList.ListClass.SetTitle", "/EE_Menus/SearchGames_Title_Players")
  FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", "/EE_Menus/SearchGames_Status_Refresh")
  FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", "/EE_Menus/Shared_Select")
  FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", "/EE_Menus/Shared_Back")
  movie:GetParent():SetVariable("_alpha", 0)
end
function Update(movie)
  if gameSearching and Engine.GetMatchingService():GetState() == 0 then
    gameSearching = false
    RefreshList(movie)
  end
end
function GameListButtonPressed(movie, buttonArg)
  local index = tonumber(buttonArg)
  local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  local searchResults = Engine.GetMatchingService():GetSearchResults()
  local sessionToJoin = searchResults[index + 1]
  Engine.GetMatchingService():JoinSession(playerProfile, sessionToJoin, false)
  gFlashMgr:CloseAllMovies()
end
function onKeyDown_MENU_GENERIC1(movie)
  SearchForGames(movie)
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
  return r
end

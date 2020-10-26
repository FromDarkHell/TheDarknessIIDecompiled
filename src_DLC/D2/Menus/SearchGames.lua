local LIB = require("D2.Menus.SharedLibrary")
itemLobbyMovie = Resource()
popupConfirmMovie = Resource()
mainMenuMovie = WeakResource()
externalPartyRefreshWait = 4
pressSound = Resource()
sndScroll = Resource()
mapNames = {
  String()
}
mapDisplayNames = {
  String()
}
local MAX_PotentialGames = 20
local GRID_DimensionsW = 1
local GRID_DimensionsH = 20
local GRID_ClipDimensionsH = 20
local CLIP_Height = 0
local MATCH_TYPE = 0
local gameSearching = false
local gameJoining = false
local itemRefresh = "/D2/Language/Menu/SearchGames_Item_Refresh"
local itemCampaign = "/D2/Language/Menu/MultiPlayer_Item_Campaign"
local itemHitList = "/D2/Language/Menu/MultiPlayer_Item_HitList"
local itemHitListDLC = "/D2/Language/Menu/MultiPlayer_Item_HitListDLC"
local itemInviteExternalParty = "/D2/Language/MPGame/Shared_InviteExternalParty"
local itemJoinExternalParty = "/D2/Language/MPGame/Shared_JoinExternalParty"
local itemList = {}
local defaultItemList = {}
local statusSelect = "/D2/Language/Menu/Shared_Select"
local statusRefresh = "/D2/Language/Menu/SearchGames_Status_Refresh"
local statusInviteToParty = "/D2/Language/MPGame/Shared_InviteToParty"
local statusBack = "/D2/Language/Menu/Shared_Back"
local statusPlayerList = "/D2/Language/MPGame/Shared_Status_PlayerList_Windows"
local statusViewPlayer = "/D2/Language/MPGame/Shared_ViewPlayerAlt_Windows"
local statusPlayersList = "/D2/Language/MPGame/Shared_Status_PlayerList_Windows"
local statusPlayersListNoButton = "/D2/Language/MPGame/Shared_Status_PlayerListNoButton_Windows"
local statusPlayersListBack = "/D2/Language/MPGame/Shared_PlayerList_Back"
local statusList = {}
local mpConfirm = "/D2/Language/Menu/MultiPlayer_Confirm"
local popupItemOk = "/D2/Language/Menu/Confirm_Item_Ok"
local popupItemCancel = "/D2/Language/Menu/Confirm_Item_Cancel"
local gameInviteSubject = "/D2/Language/MPGame/GameInviteSubject"
local gameInviteMessage = "/D2/Language/MPGame/GameInviteMessage"
local queuedSearch = false
local requiresConfirm = false
local sessionToJoin
local mSelectedGameMode = D2_Game.GAME_MODE_CAMPAIGN
local mNumAvailableGames = 0
local mSelectedGame = 0
local mPartyList, mBanner
local SCREENSTATE_SelectGameType = 0
local SCREENSTATE_SearchGameType = 1
local SCREENSTATE_SearchPopup = 2
local SCREENSTATE_ViewGamerCard = 3
local SCREENSTATE_SelectingGame = 4
local mScreenStateStack, mListItemSelected
local mScrubberRange = 0
local mScrubberPosition = 0
local mPlatform = ""
local mPlayerListButtonEnabled = false
local mNumPlayers = -1
local mMovie, mPartyInviteVal, mPartyJoinVal
local mCachedPartySize = 0
local externalPartyTimer = 0
local function GetScreenState()
  if mScreenStateStack == nil then
    return nil
  end
  return mScreenStateStack[#mScreenStateStack]
end
local function UpdatePlayerListButton(movie)
  if mPartyList == nil then
    return
  end
  local canShowOptions = not gameSearching and not gameJoining
  local numPlayers = #mPartyList.members
  if mNumPlayers ~= numPlayers then
    canShowOptions = 0 < numPlayers and canShowOptions
    mNumPlayers = numPlayers
  end
  local allowSelect = false
  local screenState = GetScreenState()
  if screenState == SCREENSTATE_SelectGameType or screenState == SCREENSTATE_SelectingGame and 0 < mNumAvailableGames then
    allowSelect = true
  end
  FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByName", statusSelect, allowSelect)
  mPlayerListButtonEnabled = canShowOptions
  FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByName", statusInviteToParty, screenState == SCREENSTATE_SelectGameType)
  local allowViewPlayer = false
  if screenState == SCREENSTATE_SelectingGame and 0 <= mSelectedGame and 0 < mNumAvailableGames then
    allowViewPlayer = true
  end
  FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByName", statusViewPlayer, allowViewPlayer)
  local text = statusPlayersList
  if GetScreenState() == SCREENSTATE_ViewGamerCard then
    text = statusPlayersListNoButton
  end
  movie:SetLocalized("PartyList.Title.text", text)
  local allowBack = false
  if canShowOptions and (screenState == SCREENSTATE_SelectGameType or screenState == SCREENSTATE_SelectingGame) then
    allowBack = true
  end
  FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByName", statusBack, allowBack)
  local canViewList = screenState == SCREENSTATE_ViewGamerCard and mPlayerListButtonEnabled
  FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByName", statusPlayersListBack, canViewList)
end
local GetItemName = function(x, y)
  return string.format("GameGrid_Item%dx%d", x, y)
end
local function SetSelectedState(movie, x, y, isSelected)
  local mcName = GetItemName(x, y)
  movie:SetVariable(string.format("%s.Selected._visible", mcName), isSelected)
  if isSelected then
    mSelectedGame = y
  else
    mSelectedGame = 0
  end
end
local function ClearList(movie)
  FlashMethod(movie, "GameGrid.GridClass.SetEnabled", false)
  for i = 0, MAX_PotentialGames do
    movie:SetVariable(string.format("%s._visible", GetItemName(0, i)), false)
    movie:SetVariable(string.format("%s.enabled", GetItemName(0, i)), false)
  end
  mNumAvailableGames = 0
end
local function InitGrid(movie)
  GRID_ClipDimensionsH = Clamp(GRID_DimensionsH, 0, CLIP_Height)
  FlashMethod(movie, "GameGrid.GridClass.Clear", "")
  FlashMethod(movie, "GameGrid.GridClass.SetDimensions", GRID_DimensionsW, MAX_PotentialGames)
  FlashMethod(movie, "GameGrid.GridClass.SetClipDimensions", GRID_DimensionsW + 1, GRID_ClipDimensionsH)
  FlashMethod(movie, "GameGrid.GridClass.SetItemSpacing", 0, 0)
  FlashMethod(movie, "GameGrid.GridClass.SetCallbackPressed", "GameGridItemPressed")
  FlashMethod(movie, "GameGrid.GridClass.SetCallbackSelected", "GameGridItemSelected")
  FlashMethod(movie, "GameGrid.GridClass.SetCallbackUnselected", "GameGridItemUnselected")
  movie:SetVariable("GameGrid.enabled", false)
  for y = 1, MAX_PotentialGames do
    for x = 1, GRID_DimensionsW do
      FlashMethod(movie, "GameGrid.GridClass.SetItem", x - 1, y - 1, "Template", false)
      SetSelectedState(movie, x - 1, y - 1, false)
    end
  end
  movie:SetVariable("Template.enabled", false)
end
local function GetStatusOptions(movie)
  if GetScreenState() == SCREENSTATE_ViewGamerCard then
    local isPartyClient = false
    if not IsNull(Engine.GetMatchingService():GetPartySession()) and not Engine.GetMatchingService():IsPartyHost() then
      isPartyClient = true
    end
    return LIB.PartyListGetStatusOptions(isPartyClient)
  elseif LIB.IsPC(movie) then
    return {
      statusSelect,
      statusViewPlayer,
      statusRefresh,
      statusBack
    }
  else
    return {
      statusSelect,
      statusViewPlayer,
      statusRefresh,
      statusInviteToParty,
      statusBack
    }
  end
end
local GetMissionNameFromLevel = function(levelName)
  for i = 1, #mapNames do
    if mapNames[i] == levelName then
      return mapDisplayNames[i]
    end
  end
  return ""
end
local function PopulateStatusBar(movie)
  FlashMethod(movie, "StatusBar.StatusBarClass.Clear")
  statusList = GetStatusOptions(movie)
  for i = 1, #statusList do
    local canUseMouse = statusList[i] ~= statusSelect
    FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", statusList[i], canUseMouse)
  end
  FlashMethod(movie, "StatusBar.StatusBarClass.SetCallbackOnPress", "StatusButtonPressed")
  UpdatePlayerListButton(movie)
end
local function CanUseRefreshButton(state)
  return state == SCREENSTATE_SearchGameType or state == SCREENSTATE_SelectingGame
end
local function UpdatePartyOptions(movie)
  local newSelection
  if LIB.IsPC(movie) then
    return
  end
  local newInviteVal = Engine.GetMatchingService():CanInviteExternalParty()
  if mPartyInviteVal == nil or mPartyInviteVal ~= newInviteVal then
    if newInviteVal then
      FlashMethod(movie, "OptionList.ListClass.AddItem", itemInviteExternalParty, false)
      newSelection = #defaultItemList
    else
      FlashMethod(movie, "OptionList.ListClass.EraseItemByName", itemInviteExternalParty)
      newSelection = #defaultItemList
    end
    mPartyInviteVal = newInviteVal
  end
  local newJoinVal = Engine.GetMatchingService():IsExternalPartyGameSessionJoinable()
  if mPartyJoinVal == nil or mPartyJoinVal ~= newJoinVal then
    if newJoinVal then
      FlashMethod(movie, "OptionList.ListClass.AddItem", itemJoinExternalParty)
    else
      FlashMethod(movie, "OptionList.ListClass.EraseItemByName", itemJoinExternalParty)
      newSelection = #defaultItemList
    end
    mPartyJoinVal = newJoinVal
  end
  if newSelection ~= nil then
    FlashMethod(movie, "OptionList.ListClass.SetSelected", newSelection)
  end
end
local function PopulateOptionList(movie)
  FlashMethod(movie, "OptionList.ListClass.EraseItems")
  mPartyInviteVal = nil
  mPartyJoinVal = nil
  itemList = {itemCampaign, itemHitList}
  if Engine.GetDownloadableContentMgr():IsDlcInstalled(D2_Game.DLC_PACK_TRAINYARD) then
    itemList[#itemList + 1] = itemHitListDLC
  end
  for i = 1, #itemList do
    FlashMethod(movie, "OptionList.ListClass.AddItem", itemList[i], false)
  end
  defaultItemList = itemList
  itemList[#itemList + 1] = itemInviteExternalParty
  itemList[#itemList + 1] = itemJoinExternalParty
  UpdatePartyOptions(movie)
end
local function ActivateScreenState(movie, newState, oldState)
  movie:SetVariable("OptionList._visible", newState == SCREENSTATE_SelectGameType)
  movie:SetVariable("OptionList.SetEnabled", newState == SCREENSTATE_SelectGameType)
  movie:SetVariable("BackgroundStain._visible", newState == SCREENSTATE_SelectGameType)
  movie:SetVariable("Heading._visible", newState == SCREENSTATE_SelectingGame and 0 < MAX_PotentialGames)
  movie:SetVariable("VerticalScroll._visible", false)
  if newState == SCREENSTATE_SelectGameType then
    ClearList(movie)
    PopulateOptionList(movie)
    FlashMethod(movie, "GameGrid.GridClass.Clear", "")
    FlashMethod(movie, "GameGrid.GridClass.SetVisible", false)
    FlashMethod(movie, "GameGrid.GridClass.SetEnabled", false)
    FlashMethod(movie, "OptionList.ListClass.SetSelected", mListItemSelected)
  elseif newState == SCREENSTATE_SearchGameType then
    movie:SetFocus("")
    if oldState == SCREENSTATE_SelectGameType then
      InitGrid(movie)
    end
  elseif newState == SCREENSTATE_SelectingGame then
    FlashMethod(movie, "GameGrid.GridClass.Selected", mSelectedGame)
    FlashMethod(movie, "GameGrid.GridClass.SetEnabled", true)
  elseif newState == SCREENSTATE_ViewGamerCard then
    FlashMethod(movie, "GameGrid.GridClass.Selected", -1)
    FlashMethod(movie, "GameGrid.GridClass.SetEnabled", false)
    Sleep(0.1)
  end
  mPartyList = LIB.PartyListSetEnabled(movie, mPartyList, newState == SCREENSTATE_ViewGamerCard)
  mScreenStateStack[#mScreenStateStack] = newState
  PopulateStatusBar(movie)
  FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByName", statusRefresh, CanUseRefreshButton(newState))
end
local function PushScreenState(movie, newState)
  if mScreenStateStack == nil then
    mScreenStateStack = {}
  end
  local curState = mScreenStateStack[#mScreenStateStack]
  mScreenStateStack[#mScreenStateStack + 1] = curState
  ActivateScreenState(movie, newState, curState)
end
local function PopScreenState(movie)
  if mScreenStateStack == nil then
    return
  end
  local oldState = mScreenStateStack[#mScreenStateStack]
  table.remove(mScreenStateStack, #mScreenStateStack)
  ActivateScreenState(movie, mScreenStateStack[#mScreenStateStack], oldState)
end
local function SetupScroller(movie)
  mScrubberRange = GRID_DimensionsH - GRID_ClipDimensionsH
  FlashMethod(movie, "VerticalScroll.ScrollClass.SetRange", mScrubberRange)
  FlashMethod(movie, "VerticalScroll.ScrollClass.SetScrubberPos", mScrubberPosition)
  FlashMethod(movie, "VerticalScroll.ScrollClass.SetButton0PressedCallback", "ScrollButtonCallbackL")
  FlashMethod(movie, "VerticalScroll.ScrollClass.SetButton1PressedCallback", "ScrollButtonCallbackR")
  FlashMethod(movie, "VerticalScroll.ScrollClass.SetScrubberMoveCallback", "ScrollScrubberMoveCallback")
  FlashMethod(movie, "VerticalScroll.ScrollClass.SetFillerPressedCallback", "ScrollScrubberMoveCallback")
end
local function RefreshList(movie)
  local searchResults = Engine.GetMatchingService():GetSearchResults()
  movie:SetVariable("GameGrid.GridClass.mItemOffsetX", 0)
  movie:SetVariable("GameGrid.GridClass.mItemOffsetY", 0)
  movie:SetVariable("GameGrid.GridClass.mSelectedX", 0)
  movie:SetVariable("GameGrid.GridClass.mSelectedY", 0)
  FlashMethod(movie, "GameGrid.GridClass.Update", "")
  FlashMethod(movie, "GameGrid.GridClass.Clear", "")
  if searchResults ~= nil and 0 < #searchResults then
    GRID_DimensionsH = #searchResults + 1
    GRID_DimensionsH = Clamp(GRID_DimensionsH, 0, 20)
    MAX_PotentialGames = GRID_DimensionsH + 1
    InitGrid(movie)
  end
  local curState = mScreenStateStack[#mScreenStateStack]
  if curState ~= SCREENSTATE_SelectingGame then
    ActivateScreenState(movie, SCREENSTATE_SelectingGame, curState)
  end
  mNumAvailableGames = 0
  for i = 1, MAX_PotentialGames do
    local mcName = GetItemName(0, i - 1)
    local hasResult = searchResults ~= nil and i <= #searchResults
    if hasResult then
      local mapName = ""
      local maps = searchResults[i]:GetSettings():GetMaps()
      if not IsNull(maps) and 0 < #maps then
        local mapResourceName = maps[1]
        mapName = GetMissionNameFromLevel(mapResourceName)
      end
      local filledSlots = searchResults[i]:GetFilledSlots()
      local totalSlots = searchResults[i]:GetTotalSlots()
      local host = tostring(searchResults[i]:GetHostName())
      host = LIB.FormatPlayerName(movie, host)
      movie:SetVariable(string.format("%s.NumPlayers.text", mcName), string.format("%i/%i", filledSlots, totalSlots))
      FlashMethod(movie, "SetHostName", mcName, host)
      movie:SetVariable(string.format("%s.PlayerName.textAlign", mcName), "left")
      movie:SetLocalized(string.format("%s.Map.text", mcName), mapName)
      movie:SetVariable(string.format("%s.Map.textAlign", mcName), "left")
      mNumAvailableGames = mNumAvailableGames + 1
    end
    movie:SetVariable(string.format("%s._visible", mcName), hasResult)
  end
  movie:SetVariable("VerticalScroll._visible", mNumAvailableGames >= CLIP_Height)
  if 0 < mNumAvailableGames then
    FlashMethod(movie, "GameGrid.GridClass.SetVisible", true)
    FlashMethod(movie, "GameGrid.GridClass.SetEnabled", true)
    GRID_ClipDimensionsH = Clamp(mNumAvailableGames, 0, CLIP_Height)
    FlashMethod(movie, "GameGrid.GridClass.SetDimensions", GRID_DimensionsW, mNumAvailableGames)
    FlashMethod(movie, "GameGrid.GridClass.SetClipDimensions", GRID_DimensionsW + 1, GRID_ClipDimensionsH)
    SetupScroller(movie)
    mSelectedGame = 0
    FlashMethod(movie, "GameGrid.GridClass.Selected", mSelectedGame)
  end
  movie:SetVariable("Heading._visible", 0 < mNumAvailableGames)
  if mNumAvailableGames <= 0 then
    mBanner.state = mBanner.STATE_FadeIn
    mBanner.spinner = false
    mBanner.line = mBanner.LINE_Single
    mBanner.loc = "/D2/Language/Menu/SearchGames_NoGamesFound"
  else
    mBanner.state = mBanner.STATE_FadeOut
  end
  LIB.BannerDisplay(movie, mBanner)
  FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByName", statusRefresh, true)
end
local function SearchForGames(movie)
  if gameSearching or gameJoining then
    return
  end
  ClearList(movie)
  mBanner.state = mBanner.STATE_FadeIn
  mBanner.line = mBanner.LINE_Double
  mBanner.loc = "/D2/Language/Menu/SearchGames_Searching"
  mBanner.spinner = true
  LIB.BannerDisplay(movie, mBanner)
  FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByName", statusRefresh, false)
  movie:SetVariable("Heading._visible", false)
  movie:SetVariable("VerticalScroll._visible", false)
  if not IsNull(Engine.GetMatchingService():GetSession()) or Engine.GetMatchingService():GetState() ~= 0 then
    print("SearchForGames cannot start because we have not left the previous session yet, queuing a search. State=" .. Engine.GetMatchingService():GetState())
    queuedSearch = true
    return
  end
  queuedSearch = false
  local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  local profileSettings = playerProfile:Settings()
  local searchArgs = Engine.SessionSearch()
  searchArgs.matchType = MATCH_TYPE
  searchArgs.gameModeId = mSelectedGameMode
  searchArgs.wantPlayers = false
  searchArgs.wantMap = false
  searchArgs.wantScoreLimit = false
  searchArgs.wantTimeLimit = false
  searchArgs.wantReconnect = false
  Engine.GetMatchingService():FindSessions(playerProfile, searchArgs)
  gameSearching = true
end
function SearchCallback(movie)
  SearchForGames(movie)
end
local function FindXFromIndex(index)
  return index % GRID_DimensionsW
end
local function FindYFromIndex(index)
  return math.floor(index / GRID_DimensionsW)
end
function OnJoinLobbyComplete(success)
  print("SearchGames.lua: OnJoinLobbyComplete: success=" .. tostring(success))
  if success == false then
    gameJoining = false
    mBanner.state = mBanner.STATE_FadeOut
    LIB.BannerDisplay(mMovie, mBanner)
    SearchForGames(mMovie)
    local popupMovie = mMovie:PushChildMovie(popupConfirmMovie)
    FlashMethod(popupMovie, "CreateOkCancel", "/Multiplayer/ServerUnavailable", "/D2/Language/Menu/Confirm_Item_Ok", "\t", "")
    popupMovie:Execute("SetRightItemText", "")
  end
  return 1
end
local function JoinLobby(movie)
  if sessionToJoin == nil or gameJoining == true then
    return
  end
  gameJoining = true
  mBanner.state = mBanner.STATE_Show
  mBanner.line = mBanner.LINE_Double
  mBanner.loc = "/Multiplayer/JoiningSession"
  mBanner.spinner = true
  LIB.BannerDisplay(movie, mBanner)
  FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByName", statusRefresh, false)
  LIB.StopGlobalMusicTrack()
  local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  Engine.GetMatchingService():JoinSession(playerProfile, sessionToJoin, false, "OnJoinLobbyComplete")
  if not IsNull(itemLobbyMovie) then
    movie:PushChildMovie(itemLobbyMovie)
  end
end
function PartyListButtonSelected(movie, arg)
  mPartyList.curIndex = tonumber(arg)
end
function PartyListButtonUnselected(movie, arg)
  mPartyList.curIndex = -1
end
function PartyListButtonPressed(movie, arg)
  LIB.PartyListDisplayMemberInfo(mPartyList)
end
function GameGridItemPressed(movie, arg)
  if mNumAvailableGames <= 0 then
    return
  end
  gRegion:PlaySound(pressSound, Vector(), false)
  local index = FindYFromIndex(tonumber(arg))
  local searchResults = Engine.GetMatchingService():GetSearchResults()
  sessionToJoin = searchResults[mSelectedGame + 1]
  local profileData = Engine.GetPlayerProfileMgr():GetPlayerProfile(0):GetGameSpecificData()
  if not IsNull(profileData) then
    profileData:SetCharacterId(-1)
  end
  if requiresConfirm then
    local popupMovie = movie:PushChildMovie(popupConfirmMovie)
    FlashMethod(popupMovie, "CreateOkCancel", mpConfirm, popupItemOk, popupItemCancel, "MultiplayerConfirm")
  else
    JoinLobby(movie)
  end
end
function GameGridItemSelected(movie, arg)
  local y = tonumber(arg)
  y = FindYFromIndex(y)
  if y < 0 then
    return
  end
  if mNumAvailableGames <= 0 then
    return
  end
  y = Clamp(y, 0, mNumAvailableGames - 1)
  gRegion:PlaySound(sndScroll, Vector(), false)
  for i = 0, mNumAvailableGames do
    SetSelectedState(movie, 0, i, false)
  end
  if y <= mNumAvailableGames then
    SetSelectedState(movie, 0, y, true)
  end
end
function GameGridItemUnselected(movie, arg)
  local y = tonumber(arg)
  y = FindYFromIndex(y)
  SetSelectedState(movie, 0, y, false)
end
local function ScrollByButton(movie, dir)
  gRegion:PlaySound(sndScroll, Vector(), false)
  mScrubberPosition = mScrubberPosition + dir
  Clamp(mScrubberPosition, 0, GRID_ClipDimensionsH)
  movie:SetVariable("GameGrid.GridClass.mItemOffsetY", mScrubberPosition)
  LIB.GridClassScroll(movie, "GameGrid", 0, 0)
end
function ScrollButtonCallbackL(movie, id)
  ScrollByButton(movie, -1)
end
function ScrollButtonCallbackR(movie, id)
  ScrollByButton(movie, 1)
end
function ScrollScrubberMoveCallback(movie, id)
  local newScrubberPosition = movie:GetVariable("VerticalScroll.ScrollClass.mPosition")
  newScrubberPosition = math.floor(newScrubberPosition)
  movie:SetVariable("GameGrid.GridClass.mItemOffsetY", newScrubberPosition)
  LIB.GridClassScroll(movie, "GameGrid", 0, 0)
  mScrubberPosition = newScrubberPosition
end
function Initialize(movie)
  CLIP_Height = 8
  mScrubberRange = 0
  mScrubberPosition = 0
  mPlatform = movie:GetVariable("$platform")
  FlashMethod(movie, "Banner.setDepth", 60000)
  MATCH_TYPE = Engine.GetPlayerProfileMgr():GetPlayerProfile(0):GetDefaultMatchType()
  mListItemSelected = 0
  mNumAvailableGames = 0
  mSelectedGame = 0
  gameJoining = false
  movie:SetVariable("VerticalScroll._visible", false)
  FlashMethod(movie, "OptionList.ListClass.SetAlignment", "left")
  FlashMethod(movie, "OptionList.ListClass.SetPressedCallback", "ListButtonPressed")
  FlashMethod(movie, "OptionList.ListClass.SetSelectedCallback", "ListButtonSelected")
  FlashMethod(movie, "OptionList.ListClass.SetSelected", 0)
  movie:SetVariable("Template._visible", false)
  movie:SetLocalized("Title.TxtHolder.Txt.text", "/D2/Language/Menu/SearchGames_Title")
  movie:SetVariable("Title.TxtHolder.Txt.textAlign", "left")
  movie:SetVariable("Heading.Selected._visible", false)
  movie:SetLocalized("Heading.NumPlayers.text", "/D2/Language/Menu/SearchGames_Title_Players")
  local hostTitle = "/D2/Language/Menu/SearchGames_Title_Host"
  if LIB.IsXbox360(movie) then
    hostTitle = hostTitle .. "_XBOX360"
  end
  movie:SetLocalized("Heading.PlayerName.text", hostTitle)
  movie:SetLocalized("Heading.PlayerName.textAlign", "left")
  movie:SetLocalized("Heading.Map.text", "/D2/Language/Menu/SearchGames_Title_Map")
  movie:SetVariable("Heading.Map.textAlign", "left")
  mPartyList = LIB.PartyListInitialize(movie)
  mCachedPartySize = #mPartyList.members
  mBanner = LIB.BannerInitialize(movie)
  PushScreenState(movie, SCREENSTATE_SelectGameType)
  requiresConfirm = not gRegion:GetGameRules():IsBootLevel()
  mMovie = movie
end
function Shutdown(movie)
  while Engine.GetMatchingService():GetState() ~= 0 do
    Sleep(0.1)
  end
  return true
end
local function Refresh(movie)
  if gameSearching or gameJoining then
    return
  end
  if CanUseRefreshButton(GetScreenState()) then
    SearchForGames(movie)
  end
end
function RefreshStuff(movie)
  if GetScreenState() == SCREENSTATE_SelectGameType then
    mListItemSelected = 0
    FlashMethod(movie, "OptionList.ListClass.WrapToTop")
  end
end
function Update(movie)
  if gameSearching then
    if Engine.GetMatchingService():GetState() == 0 then
      gameSearching = false
      RefreshList(movie)
    end
  elseif queuedSearch then
    SearchForGames(movie)
  elseif gameJoining and Engine.GetMatchingService():GetState() == 0 then
    gameJoining = false
  end
  local delta = RealDeltaTime()
  if mPartyList == nil then
    return
  end
  mPartyList = LIB.PartyListUpdate(movie, delta, mPartyList)
  externalPartyTimer = externalPartyTimer - delta
  if externalPartyTimer < 0 then
    externalPartyTimer = externalPartyRefreshWait
    if IsNull(Engine.GetMatchingService():GetPartySession()) then
      if not LIB.IsPC(movie) then
        UpdatePartyOptions(movie)
      end
    else
      UpdatePartyOptions(movie)
    end
  end
  if #mPartyList.members ~= mCachedPartySize then
    if #mPartyList.members > mCachedPartySize and 0 < mNumAvailableGames then
      print("SearchGames::Update: refreshing search results due to party size increase")
      Refresh(movie)
    end
    mCachedPartySize = #mPartyList.members
  end
  UpdatePlayerListButton(movie)
end
function MultiplayerConfirm(movie, args)
  if tonumber(args) == 0 then
    if not requiresConfirm then
      gFlashMgr:CloseAllMovies()
      local mainMenu = gFlashMgr:PushMovie(Resource(mainMenuMovie:GetResourceName()))
      JoinLobby(mainMenu)
    else
      JoinLobby(movie)
    end
  end
end
local JoinExternalParty = function(movie)
  if Engine.GetMatchingService():IsExternalPartyGameSessionJoinable() then
    local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
    Engine.GetMatchingService():JoinExternalPartyGameSession(playerProfile)
  end
end
local InviteExternalParty = function(movie)
  print("InviteExternalParty")
  print("calling IsExternalPartyActive")
  if Engine.GetMatchingService():IsExternalPartyActive() then
    print("calling SendExternalPartyGameInvites")
    local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
    Engine.GetMatchingService():SendExternalPartyGameInvites(playerProfile)
  end
end
function ListButtonPressed(movie, buttonArg)
  local index = tonumber(buttonArg) + 1
  gRegion:PlaySound(pressSound, Vector(), false)
  if itemList[index] == itemCampaign then
    PushScreenState(movie, SCREENSTATE_SearchGameType)
    mSelectedGameMode = D2_Game.GAME_MODE_CAMPAIGN
    SearchForGames(movie)
  elseif itemList[index] == itemHitList then
    PushScreenState(movie, SCREENSTATE_SearchGameType)
    mSelectedGameMode = D2_Game.GAME_MODE_HITLIST
    SearchForGames(movie)
  elseif Engine.GetDownloadableContentMgr():IsDlcInstalled(D2_Game.DLC_PACK_TRAINYARD) and itemList[index] == itemHitListDLC then
    PushScreenState(movie, SCREENSTATE_SearchGameType)
    mSelectedGameMode = D2_Game.GAME_MODE_HITLIST_DLC
    SearchForGames(movie)
  elseif mPartyInviteVal and itemList[index] == itemInviteExternalParty then
    print("calling InviteExternalParty")
    InviteExternalParty(movie)
  elseif itemList[index] == itemJoinExternalParty or not mPartyInviteVal and itemList[index] == itemInviteExternalParty then
    JoinExternalParty(movie)
  end
end
function ListButtonSelected(movie, buttonArg)
  mListItemSelected = tonumber(buttonArg)
  gRegion:PlaySound(sndScroll, Vector(), false)
end
function onKeyDown_MENU_GENERIC1(movie)
  local screenState = GetScreenState()
  if screenState ~= SCREENSTATE_SearchGameType and screenState ~= SCREENSTATE_SelectingGame then
    return
  end
  if mSelectedGame < 0 then
    return
  end
  local searchResults = Engine.GetMatchingService():GetSearchResults()
  if not IsNull(searchResults) and mSelectedGame <= #searchResults then
    local session = searchResults[mSelectedGame + 1]
    if not IsNull(session) then
      local hostId = session:GetHostOnlineId()
      Engine.GetMatchingService():DisplayPlayerInfo(hostId)
    end
  end
end
function onKeyDown_MENU_GENERIC2(movie)
  if not LIB.IsPC(movie) and GetScreenState() == SCREENSTATE_SelectGameType then
    local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
    Engine.GetMatchingService():ShowSystemGameInviteUI(playerProfile, gameInviteSubject, gameInviteMessage)
  end
end
function onKeyDown_MENU_RTRIGGER2(movie)
  Refresh(movie)
end
local function Back(movie)
  if gameSearching or gameJoining or queuedSearch then
    return
  end
  local screenState = GetScreenState()
  if screenState == SCREENSTATE_SelectGameType then
    movie:Close()
  elseif screenState == SCREENSTATE_SearchGameType then
    if mBanner.state == mBanner.STATE_Show or mBanner.state == mBanner.STATE_FadeIn then
      mBanner.state = mBanner.STATE_FadeOut
      LIB.BannerDisplay(movie, mBanner)
    end
    PopScreenState(movie)
  elseif screenState == SCREENSTATE_ViewGamerCard or screenState == SCREENSTATE_SelectingGame then
    if LIB.BannerIsVisible(mBanner) then
      mBanner.state = mBanner.STATE_FadeOut
      LIB.BannerDisplay(movie, mBanner)
    end
    PopScreenState(movie)
  end
end
function onKeyDown_MENU_CANCEL(movie)
  Back(movie)
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
local function Move(movie, dir)
  if gameSearching or gameJoining then
    return true
  end
  local screenState = GetScreenState()
  if screenState == SCREENSTATE_SelectGameType then
    local curSelection = movie:GetVariable("OptionList.ListClass.mCurrentSelection")
    return LIB.ListClassVerticalScroll(movie, "OptionList", dir)
  elseif screenState == SCREENSTATE_SearchGameType or screenState == SCREENSTATE_SelectingGame then
    if 0 < dir and mSelectedGame <= mNumAvailableGames or dir < 0 and 1 <= mSelectedGame then
      local ret = LIB.GridClassScroll(movie, "GameGrid", 0, dir)
      local yOffset = tonumber(movie:GetVariable("GameGrid.GridClass.mItemOffsetY"))
      mScrubberPosition = Clamp(yOffset, 0, mScrubberRange)
      FlashMethod(movie, "VerticalScroll.ScrollClass.SetScrubberPos", mScrubberPosition)
      return ret
    end
    return true
  elseif screenState == SCREENSTATE_ViewGamerCard then
    return LIB.ListClassVerticalScroll(movie, "PartyList.OptionList", dir)
  end
  return false
end
function onKeyDown_MENU_UP_FROM_ANALOG(movie)
  return Move(movie, -1)
end
function onKeyDown_MENU_UP(movie)
  return Move(movie, -1)
end
function onKeyDown_MENU_DOWN_FROM_ANALOG(movie)
  return Move(movie, 1)
end
function onKeyDown_MENU_DOWN(movie)
  return Move(movie, 1)
end
function onKeyDown_MENU_LTRIGGER2(movie)
  if not mPlayerListButtonEnabled or LIB.IsPC(movie) or gameSearching or gameJoining or queuedSearch then
    return
  end
  local screenState = GetScreenState()
  if screenState == SCREENSTATE_ViewGamerCard then
    PopScreenState(movie)
    return
  end
  if #mPartyList.members == 0 then
    return
  end
  PushScreenState(movie, SCREENSTATE_ViewGamerCard)
end
function StatusButtonPressed(movie, buttonArg)
  local index = tonumber(buttonArg) + 1
  if statusList[index] == statusBack then
    Back(movie)
  elseif statusList[index] == statusRefresh then
    Refresh(movie)
  end
end

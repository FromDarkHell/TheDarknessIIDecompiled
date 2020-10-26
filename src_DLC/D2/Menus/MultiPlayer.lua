local LIB = require("D2.Menus.SharedLibrary")
itemHostMovie = Resource()
itemSearchMovie = Resource()
popupConfirmMovie = Resource()
mainMenuMovie = WeakResource()
lobbyLevel = WeakResource()
lobbyGameRules = WeakResource()
traditionalLobby = true
timeToWait = 10
maxPlayers = 4
externalPartyRefreshWait = 4
minBusyDuration = 1
rollOverSound = Resource()
pressSound = Resource()
transitionMovie = WeakResource()
binkTexture = Resource()
campaignStructure = Resource()
numCampaignMissions = 15
local mpConfirm = "/D2/Language/Menu/MultiPlayer_Confirm"
local itemCampaign = "/D2/Language/Menu/MultiPlayer_Item_Campaign"
local itemCampaignNew = "/D2/Language/Menu/MultiPlayer_Item_Campaign_New"
local itemCampaignContinue = "/D2/Language/Menu/MultiPlayer_Item_Campaign_Continue"
local itemHitList = "/D2/Language/Menu/MultiPlayer_Item_HitList"
local itemHitListDLC = "/D2/Language/Menu/MultiPlayer_Item_HitListDLC"
local itemSearch = "/D2/Language/Menu/MultiPlayer_Item_Search"
local itemInviteExternalParty = "/D2/Language/MPGame/Shared_InviteExternalParty"
local itemJoinExternalParty = "/D2/Language/MPGame/Shared_JoinExternalParty"
local itemQuickMatch = "/D2/Language/Menu/MultiPlayer_Item_QuickMatch"
local itemList = {}
local defaultItemList = {}
local statusSelect = "/D2/Language/Menu/Shared_Select"
local statusBack = "/D2/Language/Menu/Shared_Back"
local statusInviteToParty = "/D2/Language/MPGame/Shared_InviteToParty"
local statusPlayerList = "/D2/Language/MPGame/Shared_Status_PlayerList_Windows"
local statusCheckInvites = "/D2/Language/MPGame/Shared_CheckPendingInvites"
local statusPlayersList = "/D2/Language/MPGame/Shared_Status_PlayerList_Windows"
local statusPlayersListNoButton = "/D2/Language/MPGame/Shared_Status_PlayerListNoButton_Windows"
local statusPlayersListBack = "/D2/Language/MPGame/Shared_PlayerList_Back"
local statusList = {
  statusSelect,
  statusInviteToParty,
  statusPlayersListBack,
  statusBack
}
local statusListPS3 = {
  statusSelect,
  statusCheckInvites,
  statusInviteToParty,
  statusPlayersListBack,
  statusBack
}
local offlineStatusList = {statusSelect, statusBack}
local popupItemOk = "/D2/Language/Menu/Confirm_Item_Ok"
local popupItemCancel = "/D2/Language/Menu/Confirm_Item_Cancel"
local privacyOptionsTitle = "/D2/Language/Menu/MultiPlayer_PrivacyOptionsTitle"
local privacyOptionPublic = "/D2/Language/Menu/MultiPlayer_PrivacyOptionPublic"
local privacyOptionPrivate = "/D2/Language/Menu/MultiPlayer_PrivacyOptionPrivate"
local privacyOptionsCancel = "/D2/Language/Menu/MainMenu_Cancel"
local privacyOptionsList = {
  privacyOptionPublic,
  privacyOptionPrivate,
  privacyOptionsCancel
}
local requiresConfirm = false
local requiresGameStart = false
local timeWaited = 0
local mIsPartyClient = false
local externalPartyTimer = 0
local MATCH_TYPE = 0
local mShowingBusyPopup
local curBusyDuration = 0
local mSelectedItem = 0
local selectedGameMode = D2_Game.GAME_MODE_CAMPAIGN
local mIsStartingNewCampaign = false
local mPartyList, mBanner, mProfileData
local mIsOnline = false
local mIsSearchingForReconnectSession = false
local mReconnectPopup
local mDoneReconnectCheck = false
local mPartyDisconnectPopup
local SCREENSTATE_SelectingGameType = 1
local SCREENSTATE_ViewGamerCard = 2
local mScreenState, mPartyInviteVal, mPartyJoinVal, mMovieInstance
local mIsClosing = false
local mPrivacyPopup
local mIsPublicMatch = true
local QUICKMATCH_STATE_NONE = 0
local QUICKMATCH_STATE_SEARCHING = 1
local QUICKMATCH_STATE_JOINING = 2
local mQuickMatchPopup
local mQuickMatchState = QUICKMATCH_STATE_NONE
local mQuickMatchJoinIndex = 1
local mPlayerListButtonEnabled = false
local mHostLobbyStarted = false
local function UpdatePartyOptions(movie)
  if not mIsOnline then
    return
  end
  local newSelection
  local newInviteVal = Engine.GetMatchingService():CanInviteExternalParty()
  if mPartyInviteVal == nil or mPartyInviteVal ~= newInviteVal then
    if newInviteVal then
      FlashMethod(movie, "OptionList.ListClass.AddItem", itemInviteExternalParty)
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
local function InitOptionsList(movie)
  itemList = {}
  FlashMethod(movie, "OptionList.ListClass.Clear")
  if mIsPartyClient then
    movie:SetLocalized("WaitingForHost.text", "/D2/Language/Menu/MultiPlayer_Msg_WaitingForHost")
    local oy = movie:GetVariable("OptionList._y")
    movie:SetVariable("OptionList._y", oy + 55)
  else
    if mIsOnline then
      itemList[#itemList + 1] = itemQuickMatch
    end
    if not IsNull(mProfileData) then
      local curCampaignMissionNum = mProfileData:GetCampaignMissionNum()
      if 0 < curCampaignMissionNum and curCampaignMissionNum < numCampaignMissions then
        itemList[#itemList + 1] = itemCampaignContinue
      end
    end
    itemList[#itemList + 1] = itemCampaignNew
    itemList[#itemList + 1] = itemHitList
    if Engine.GetDownloadableContentMgr():IsDlcInstalled(D2_Game.DLC_PACK_TRAINYARD) then
      itemList[#itemList + 1] = itemHitListDLC
    end
    if mIsOnline then
      itemList[#itemList + 1] = itemSearch
    end
  end
  for i = 1, #itemList do
    FlashMethod(movie, "OptionList.ListClass.AddItem", itemList[i], false)
  end
  defaultItemList = itemList
  itemList[#itemList + 1] = itemInviteExternalParty
  itemList[#itemList + 1] = itemJoinExternalParty
  UpdatePartyOptions(movie)
end
local function GetStatusOptions()
  if mScreenState == SCREENSTATE_ViewGamerCard then
    return LIB.PartyListGetStatusOptions(false)
  elseif mIsOnline then
    if LIB.IsPC(mMovieInstance) then
      return offlineStatusList
    elseif LIB.IsPS3(mMovieInstance) then
      return statusListPS3
    else
      return statusList
    end
  else
    return offlineStatusList
  end
end
local function BusyPopupVisible(movie, v, loc)
  if mIsOnline and mShowingBusyPopup ~= v then
    if v then
      mBanner.state = mBanner.STATE_FadeIn
    else
      mBanner.state = mBanner.STATE_FadeOut
    end
    if loc ~= nil then
      mBanner.loc = loc
    else
      mBanner.loc = "/D2/Language/Menu/MultiPlayer_Msg_PleaseWait"
    end
    mBanner.spinner = true
    LIB.BannerDisplay(movie, mBanner)
    mShowingBusyPopup = v
  end
end
local function UpdatePlayerListButton(movie)
  local text = statusPlayersList
  if mScreenState == SCREENSTATE_ViewGamerCard then
    text = statusPlayersListNoButton
  end
  movie:SetLocalized("PartyList.Title.text", text)
  local canViewList = mScreenState == SCREENSTATE_ViewGamerCard and mPlayerListButtonEnabled
  FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByName", statusPlayersListBack, canViewList)
  FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByName", statusBack, not canViewList)
end
local function PopulateStatusBar(movie)
  local statusOptions = GetStatusOptions()
  FlashMethod(movie, "StatusBar.StatusBarClass.Clear")
  for i = 1, #statusOptions do
    FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", statusOptions[i], statusOptions[i] ~= statusSelect)
  end
  mPlayerListButtonEnabled = not LIB.IsPC(movie)
  UpdatePlayerListButton(movie)
  FlashMethod(movie, "StatusBar.StatusBarClass.SetCallbackOnPress", "StatusButtonPressed")
end
local function SetScreenState(movie, newState)
  mScreenState = newState
  PopulateStatusBar(movie)
  if newState == SCREENSTATE_SelectingGameType then
    FlashMethod(movie, "OptionList.ListClass.SetSelected", mSelectedItem)
  elseif newState == SCREENSTATE_ViewGamerCard then
  end
  FlashMethod(movie, "OptionList.ListClass.SetEnabled", newState == SCREENSTATE_SelectingGameType)
  mPartyList = LIB.PartyListSetEnabled(movie, mPartyList, newState == SCREENSTATE_ViewGamerCard)
end
local function _ConfirmBack(movie, args)
  if tonumber(args) == 0 then
    gRegion:PlaySound(pressSound, Vector(), false)
    BusyPopupVisible(movie, true)
    Engine.GetMatchingService():LeavePartySession()
    Engine.GetPlayerProfileMgr():SetOnlineConnectionRequired(false)
    mIsClosing = true
    LIB.DoScreenTransition(movie, LIB.TRANSITION_DESTINATON_PARENT_SCREEN, transitionMovie, LIB.TRANSITON_VIDEO_OPTIONS_1)
  end
end
function ConfirmBack(movie, args)
  _ConfirmBack(movie, args)
end
local function Back(movie, force)
  if (force == nil or not force) and mScreenState == SCREENSTATE_ViewGamerCard then
    mPartyList = LIB.PartyListSetEnabled(movie, mPartyList, false)
    SetScreenState(movie, SCREENSTATE_SelectingGameType)
    return
  end
  local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  local partyList = Engine.GetMatchingService():GetPartyMemberList()
  if not IsNull(playerProfile) and not IsNull(partyList) and 1 < #partyList then
    local popupMovie = movie:PushChildMovie(popupConfirmMovie)
    FlashMethod(popupMovie, "CreateOkCancel", "/D2/Language/Menu/Multiplayer_DestroyParty", popupItemOk, popupItemCancel, "ConfirmBack")
  else
    _ConfirmBack(movie, "0")
  end
end
function PartyListButtonSelected(movie, arg)
  mPartyList.curIndex = tonumber(arg)
end
function PartyListButtonUnselected(movie, arg)
end
function PartyListButtonPressed(movie, arg)
  LIB.PartyListDisplayMemberInfo(mPartyList)
end
local function _ResetState()
  requiresConfirm = not gRegion:GetGameRules():IsBootLevel()
  requiresGameStart = false
  timeWaited = 0
  curBusyDuration = 0
  mIsStartingNewCampaign = false
  mIsOnline = false
  mHostLobbyStarted = false
  mPartyInviteVal = nil
  mPartyJoinVal = nil
  local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  if not IsNull(playerProfile) then
    mProfileData = playerProfile:GetGameSpecificData()
    mIsOnline = playerProfile:IsOnline() and not IsNull(mProfileData) and not mProfileData:IsPlayingOfflineMP()
  end
  mIsPartyClient = false
  if mIsOnline then
    if not IsNull(Engine.GetMatchingService():GetPartySession()) then
      if not Engine.GetMatchingService():IsPartyHost() then
        mIsPartyClient = true
      end
    else
      Engine.GetMatchingService():HostPartySession(Engine.GetPlayerProfileMgr():GetPlayerProfile(0))
    end
  end
  Engine.GetMatchingService():EnableOnlinePresenceAutoUpdates(false)
  InitOptionsList(mMovieInstance)
  mPartyList = LIB.PartyListInitialize(mMovieInstance)
  if mIsPartyClient then
    SetScreenState(mMovieInstance, SCREENSTATE_ViewGamerCard)
  else
    SetScreenState(mMovieInstance, SCREENSTATE_SelectingGameType)
  end
  if not IsNull(mPrivacyPopup) then
    mPrivacyPopup:Close()
    mPrivacyPopup = nil
  end
  if not IsNull(mQuickMatchPopup) then
    mQuickMatchPopup:Close()
    mQuickMatchPopup = nil
  end
  if not IsNull(mReconnectPopup) then
    mReconnectPopup:Close()
    mReconnectPopup = nil
  end
  if not IsNull(mPartyDisconnectPopup) then
    mPartyDisconnectPopup:Close()
    mPartyDisconnectPopup = nil
  end
end
function Initialize(movie)
  mMovieInstance = movie
  mIsClosing = false
  mPartyInviteVal = false
  mPartyJoinVal = false
  mHostLobbyStarted = false
  local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  if not IsNull(playerProfile) then
    LIB.PlayBackgroundBink(movie, binkTexture)
    mProfileData = playerProfile:GetGameSpecificData()
    mIsOnline = playerProfile:IsOnline() and not IsNull(mProfileData) and not mProfileData:IsPlayingOfflineMP()
    MATCH_TYPE = playerProfile:GetDefaultMatchType()
    mBanner = LIB.BannerInitialize(movie)
    mBanner.state = mBanner.STATE_Show
    mBanner.line = mBanner.LINE_Double
    mBanner.spinner = true
    BusyPopupVisible(movie, false)
  else
    mIsOnline = false
    mProfileData = nil
  end
  movie:SetLocalized("Title.TxtHolder.Txt.text", "/D2/Language/Menu/MultiPlayer_Title")
  movie:SetVariable("Title.TxtHolder.Txt.textAlign", "left")
  FlashMethod(movie, "OptionList.ListClass.SetAlignment", "left")
  FlashMethod(movie, "OptionList.ListClass.SetPressedCallback", "ListButtonPressed")
  FlashMethod(movie, "OptionList.ListClass.SetSelectedCallback", "ListButtonSelected")
  if IsNull(playerProfile) then
    Back(movie)
    return
  end
  _ResetState()
end
local function StartGame(movie)
  local args = Engine.OpenLevelArgs()
  if selectedGameMode == D2_Game.GAME_MODE_CAMPAIGN then
    if mIsStartingNewCampaign and not IsNull(mProfileData) then
      mProfileData:SetCampaignMissionNum(0)
      mProfileData:SetCampaignCharacter(-1)
    end
    local mapIndex = mProfileData:GetCampaignMissionNum()
    args:SetLevel(campaignStructure:GetMapName(mapIndex))
    local mapRules = campaignStructure:GetMapRulesName(mapIndex)
    args:SetGameRules(mapRules)
  else
    args:SetLevel(lobbyLevel:GetResourceName())
    args:SetGameRules(lobbyGameRules:GetResourceName())
  end
  if not IsNull(mProfileData) then
    mProfileData:SetPlayingMPCampaign(selectedGameMode == D2_Game.GAME_MODE_CAMPAIGN)
  end
  args.hostingMultiplayer = true
  args.migrateServer = true
  LIB.StopGlobalMusicTrack()
  Engine.OpenLevel(args)
end
local function HostLobby(movie)
  mHostLobbyStarted = true
  local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  local profileSettings = playerProfile:Settings()
  local gameHostSettings = profileSettings:GetHostSettings()
  gameHostSettings.matchType = MATCH_TYPE
  if mIsSearchingForReconnectSession then
    local reconnectInfo = Engine.GetMatchingService():GetSessionReconnectInfo()
    gameHostSettings:SetReconnectInfo(reconnectInfo)
    selectedGameMode = gameHostSettings.gameModeId
  else
    gameHostSettings.gameModeId = selectedGameMode
  end
  if selectedGameMode == D2_Game.GAME_MODE_CAMPAIGN then
    local mapIndex = 0
    if not mIsStartingNewCampaign then
      mapIndex = mProfileData:GetCampaignMissionNum()
    end
    if mapIndex >= numCampaignMissions and mIsSearchingForReconnectSession then
      print("Own campaign done, resetting")
      mapIndex = 0
      mProfileData:SetCampaignMissionNum(0)
      mProfileData:SetCampaignCharacter(-1)
    end
    gameHostSettings:SetMap(campaignStructure:GetMapName(mapIndex))
  else
    gameHostSettings:SetMap(lobbyLevel:GetResourceName())
  end
  gameHostSettings.maxPlayers = maxPlayers
  if mIsPublicMatch then
    gameHostSettings.privateSlots = 0
  else
    gameHostSettings.privateSlots = maxPlayers - 1
  end
  BusyPopupVisible(movie, true)
  Engine.GetMatchingService():OpenLobby(playerProfile, gameHostSettings)
  if traditionalLobby and not requiresConfirm and not IsNull(itemHostMovie) then
    movie:PushChildMovie(itemHostMovie)
  else
    requiresGameStart = true
  end
end
function PrivacySettingsPopupTransitionInDone(movie)
  FlashMethod(mPrivacyPopup, "CreateList", "PrivacyListButtonPressed", "ListButtonSelected", "ListButtonUnselected")
  for i = 1, #privacyOptionsList do
    FlashMethod(mPrivacyPopup, "OptionList.ListClass.AddItem", privacyOptionsList[i], false)
  end
  mPrivacyPopup:Execute("SetDescription", "/D2/Language/Menu/MultiPlayer_PrivacyOptionsTitle")
  FlashMethod(mPrivacyPopup, "OptionList.ListClass.SetAlignment", "center")
  FlashMethod(mPrivacyPopup, "OptionList.ListClass.SetSelected", 0)
end
local function ShowPrivacySettingsPopup(movie)
  mPrivacyPopup = movie:PushChildMovie(popupConfirmMovie)
  mPrivacyPopup:Execute("SetTransitionInDoneCallback", "PrivacySettingsPopupTransitionInDone")
end
function PrivacyListButtonPressed(movie, buttonArg)
  local idx = tonumber(buttonArg)
  gRegion:PlaySound(pressSound, Vector(), false)
  if not IsNull(mPrivacyPopup) then
    if idx == 0 then
      mIsPublicMatch = true
      HostLobby(movie)
    elseif idx == 1 then
      mIsPublicMatch = false
      HostLobby(movie)
    else
      mIsStartingNewCampaign = false
    end
    mPrivacyPopup:Close()
    mPrivacyPopup = nil
  end
  return 1
end
function ListButtonUnselected(movie, buttonArg)
end
local function QuickMatchSearch(movie)
  if not (mIsOnline and IsNull(Engine.GetMatchingService():GetSession())) or Engine.GetMatchingService():GetState() ~= 0 then
    return
  end
  mQuickMatchState = QUICKMATCH_STATE_SEARCHING
  BusyPopupVisible(movie, true)
  local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  local searchArgs = Engine.SessionSearch()
  searchArgs.matchType = MATCH_TYPE
  searchArgs.gameModeId = selectedGameMode
  searchArgs.wantPlayers = false
  searchArgs.wantMap = false
  searchArgs.wantScoreLimit = false
  searchArgs.wantTimeLimit = false
  searchArgs.wantReconnect = false
  mQuickMatchJoinIndex = 1
  Engine.GetMatchingService():FindSessions(playerProfile, searchArgs)
end
function QuickMatchSearchAgainPopupTransitionInDone(movie)
  FlashMethod(mQuickMatchPopup, "CreateList", "QuickMatchSearchAgainButtonPressed", "ListButtonSelected", "ListButtonUnselected")
  FlashMethod(mQuickMatchPopup, "OptionList.ListClass.AddItem", "/D2/Language/Menu/MultiPlayer_QuickMatchHostOption", false)
  FlashMethod(mQuickMatchPopup, "OptionList.ListClass.AddItem", "/D2/Language/Menu/MultiPlayer_QuickMatchSearchOption", false)
  FlashMethod(mQuickMatchPopup, "OptionList.ListClass.AddItem", popupItemCancel, false)
  mQuickMatchPopup:Execute("SetDescription", "/D2/Language/Menu/MultiPlayer_QuickMatchSearchAgainTitle")
  FlashMethod(mQuickMatchPopup, "OptionList.ListClass.SetAlignment", "center")
  FlashMethod(mQuickMatchPopup, "OptionList.ListClass.SetSelected", 0)
end
local function ShowQuickMatchSearchAgainPopup(movie)
  if not IsNull(mQuickMatchPopup) then
    mQuickMatchPopup:Close()
    mQuickMatchPopup = nil
  end
  mQuickMatchPopup = movie:PushChildMovie(popupConfirmMovie)
  mQuickMatchPopup:Execute("SetTransitionInDoneCallback", "QuickMatchSearchAgainPopupTransitionInDone")
end
function QuickMatchListButtonPressed(movie, buttonArg)
  local idx = tonumber(buttonArg)
  gRegion:PlaySound(pressSound, Vector(), false)
  mQuickMatchPopup:Close()
  mQuickMatchPopup = nil
  if idx == 0 then
    selectedGameMode = D2_Game.GAME_MODE_CAMPAIGN
    QuickMatchSearch(movie)
  elseif idx == 1 then
    selectedGameMode = D2_Game.GAME_MODE_HITLIST
    QuickMatchSearch(movie)
  elseif idx == 2 and Engine.GetDownloadableContentMgr():IsDlcInstalled(D2_Game.DLC_PACK_TRAINYARD) then
    selectedGameMode = D2_Game.GAME_MODE_HITLIST_DLC
    QuickMatchSearch(movie)
  end
  return 1
end
function QuickMatchSearchAgainButtonPressed(movie, buttonArg)
  local idx = tonumber(buttonArg)
  gRegion:PlaySound(pressSound, Vector(), false)
  mQuickMatchPopup:Close()
  mQuickMatchPopup = nil
  if idx == 0 then
    mIsPublicMatch = true
    HostLobby(movie)
  elseif idx == 1 then
    QuickMatchSearch(movie)
  end
  return 1
end
local setOnce = false
function Update(movie)
  if mIsClosing then
    if LIB.IsPC(movie) and LIB.BannerIsVisible(mBanner) then
      BusyPopupVisible(movie, false)
    end
    return
  end
  if not IsNull(_T.gResetMultiplayerScreen) and _T.gResetMultiplayerScreen == true then
    _ResetState()
    _T.gResetMultiplayerScreen = false
  end
  local delta = RealDeltaTime()
  if not mDoneReconnectCheck then
    mDoneReconnectCheck = true
    if mIsOnline and Engine.GetMatchingService():IsSessionReconnectAvailable() then
      mReconnectPopup = movie:PushChildMovie(popupConfirmMovie)
      FlashMethod(mReconnectPopup, "CreateOkCancel", "/D2/Language/MPGame/Shared_ReconnectSession", popupItemOk, popupItemCancel, "ReconnectConfirm")
    end
  end
  if mIsOnline then
    mPartyList = LIB.PartyListUpdate(movie, delta, mPartyList)
    externalPartyTimer = externalPartyTimer - delta
    if externalPartyTimer < 0 then
      externalPartyTimer = externalPartyRefreshWait
      if IsNull(Engine.GetMatchingService():GetPartySession()) then
        if mIsPartyClient then
          if IsNull(mPartyDisconnectPopup) then
            mPartyDisconnectPopup = movie:PushChildMovie(popupConfirmMovie)
            FlashMethod(mPartyDisconnectPopup, "CreateOkCancel", "/Multiplayer/PartyHostDisconnected", "/D2/Language/Menu/Confirm_Item_Ok", "\t", "OnPartyDisconnectConfirm")
            mPartyDisconnectPopup:Execute("SetRightItemText", "")
          end
        elseif not LIB.IsPC(movie) then
          _ResetState()
        end
      else
        UpdatePartyOptions(movie)
      end
    end
    if mIsSearchingForReconnectSession and Engine.GetMatchingService():GetState() == 0 then
      local searchResults = Engine.GetMatchingService():GetSearchResults()
      if IsNull(searchResults) or #searchResults == 0 then
        print("Multiplayer: reconnect session not found, hosting it ourselves")
        HostLobby(movie)
      else
        BusyPopupVisible(movie, true)
        print("Multiplayer: FOUND reconnect session, joining")
        local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
        Engine.GetMatchingService():JoinSession(playerProfile, searchResults[1], false)
      end
      mIsSearchingForReconnectSession = false
    end
    if mQuickMatchState == QUICKMATCH_STATE_SEARCHING and Engine.GetMatchingService():GetState() == 0 then
      local searchResults = Engine.GetMatchingService():GetSearchResults()
      if IsNull(searchResults) or #searchResults == 0 then
        mQuickMatchState = QUICKMATCH_STATE_NONE
        ShowQuickMatchSearchAgainPopup(movie)
      else
        local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
        local profileData = playerProfile:GetGameSpecificData()
        if not IsNull(profileData) then
          profileData:SetCharacterId(-1)
        end
        mQuickMatchState = QUICKMATCH_STATE_JOINING
        Engine.GetMatchingService():JoinSession(playerProfile, searchResults[mQuickMatchJoinIndex], false, "JoinQuickMatchComplete")
      end
      mIsSearchingForReconnectSession = false
    end
  end
  if requiresGameStart then
    timeWaited = timeWaited + 1
    if timeWaited > timeToWait and not Engine.GetMatchingService():IsBlockingDialogShowing() then
      if IsNull(mProfileData) then
        local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
        mProfileData = playerProfile:GetGameSpecificData()
      else
        StartGame(movie)
      end
    end
  end
  if mShowingBusyPopup then
    curBusyDuration = curBusyDuration + delta
  end
  local needBusyPopup = mHostLobbyStarted or Engine.GetMatchingService():IsBlockingTaskPending() or mQuickMatchState ~= QUICKMATCH_STATE_NONE
  if needBusyPopup and not mShowingBusyPopup then
    BusyPopupVisible(movie, true, "/D2/Language/Menu/MultiPlayer_Msg_PleaseWait")
  elseif not needBusyPopup and mShowingBusyPopup and not mIsSearchingForReconnectSession and curBusyDuration > minBusyDuration and LIB.BannerIsVisible(mBanner) then
    BusyPopupVisible(movie, false)
  end
end
function JoinQuickMatchComplete(success)
  print("Multiplayer.lua: JoinQuickMatchComplete: success=" .. tostring(success))
  if success and not IsNull(Engine.GetMatchingService():GetSession()) then
    LIB.StopGlobalMusicTrack()
  else
    local searchResults = Engine.GetMatchingService():GetSearchResults()
    if IsNull(searchResults) or #searchResults == 0 or mQuickMatchJoinIndex >= #searchResults then
      mQuickMatchState = QUICKMATCH_STATE_NONE
      ShowQuickMatchSearchAgainPopup(mMovieInstance)
    else
      mQuickMatchJoinIndex = mQuickMatchJoinIndex + 1
      local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
      Engine.GetMatchingService():JoinSession(playerProfile, searchResults[mQuickMatchJoinIndex], false, "JoinQuickMatchComplete")
    end
  end
  return 1
end
local function SearchForReconnectableGame(movie)
  if not (mIsOnline and IsNull(Engine.GetMatchingService():GetSession()) and Engine.GetMatchingService():IsSessionReconnectAvailable()) or Engine.GetMatchingService():GetState() ~= 0 then
    return
  end
  BusyPopupVisible(movie, true)
  mIsSearchingForReconnectSession = true
  local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  local searchArgs = Engine.GetMatchingService():GetSessionReconnectInfo()
  print("Multiplayer: SearchForReconnectableGame starting reconnect search for session with reconnectID=" .. tostring(searchArgs.reconnectId) .. ", gameModeId=" .. tostring(searchArgs.gameModeId))
  Engine.GetMatchingService():FindSessions(playerProfile, searchArgs)
end
function StatusButtonPressed(movie, buttonArg)
  if mShowingBusyPopup or mIsPartyClient or mQuickMatchState ~= QUICKMATCH_STATE_NONE then
    return
  end
  local index = tonumber(buttonArg) + 1
  local statusOptions = GetStatusOptions()
  if statusOptions[index] == statusBack then
    Back(movie)
  elseif statusOptions[index] == statusPlayerList then
    if mPlayerListButtonEnabled then
      SetScreenState(movie, SCREENSTATE_ViewGamerCard)
    end
  elseif statusOptions[index] == statusInviteToParty then
    LIB.InviteFriends()
  end
end
function MultiplayerConfirm(movie, args)
  if tonumber(args) == 0 then
    if traditionalLobby and not requiresConfirm then
      gFlashMgr:CloseAllMovies()
      local mainMenu = gFlashMgr:PushMovie(Resource(mainMenuMovie:GetResourceName()))
      HostLobby(mainMenu)
    else
      HostLobby(movie)
    end
  end
end
function ReconnectConfirm(movie, args)
  if tonumber(args) == 0 then
    SearchForReconnectableGame(movie)
  else
    Engine.GetMatchingService():DisableSessionReconnect()
  end
  if not IsNull(mReconnectPopup) then
    mReconnectPopup:Close()
    mReconnectPopup = nil
  end
end
function ListButtonSelected(movie, buttonArg)
  gRegion:PlaySound(rollOverSound, Vector(), false)
  mSelectedItem = tonumber(buttonArg)
end
local function HostInit(movie, gameMode)
  selectedGameMode = gameMode
  if not IsNull(mProfileData) then
    local isCampaign = selectedGameMode == D2_Game.GAME_MODE_CAMPAIGN
    mProfileData:SetPlayingMPCampaign(isCampaign)
  end
  if mIsOnline then
    if requiresConfirm then
      local popupMovie = movie:PushChildMovie(popupConfirmMovie)
      FlashMethod(popupMovie, "CreateOkCancel", mpConfirm, popupItemOk, popupItemCancel, "MultiplayerConfirm")
    else
      ShowPrivacySettingsPopup(movie)
    end
  else
    local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
    local profileSettings = playerProfile:Settings()
    local gameHostSettings = profileSettings:GetHostSettings()
    gameHostSettings.gameModeId = selectedGameMode
    StartGame(movie)
  end
end
local function StartNewCampaign(movie, args)
  mIsStartingNewCampaign = true
  HostInit(movie, D2_Game.GAME_MODE_CAMPAIGN)
end
function NewCampaignDestroyOldConfirm(movie, args)
  if tonumber(args) == 0 then
    StartNewCampaign(movie)
  else
    mIsStartingNewCampaign = false
  end
end
local function JoinExternalParty(movie)
  if mShowingBusyPopup or not mIsOnline then
    return 1
  end
  if Engine.GetMatchingService():IsExternalPartyGameSessionJoinable() then
    local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
    Engine.GetMatchingService():JoinExternalPartyGameSession(playerProfile)
  end
end
local function InviteExternalParty(movie)
  print("InviteExternalParty")
  if mShowingBusyPopup or not mIsOnline then
    print("mShowingBusyPopup or mIsOnline")
    return 1
  end
  print("calling IsExternalPartyActive")
  if Engine.GetMatchingService():IsExternalPartyActive() then
    print("calling SendExternalPartyGameInvites")
    local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
    Engine.GetMatchingService():SendExternalPartyGameInvites(playerProfile)
  end
end
function QuickMatchPopupTransitionInDone(movie)
  FlashMethod(mQuickMatchPopup, "CreateList", "QuickMatchListButtonPressed", "ListButtonSelected", "ListButtonUnselected")
  FlashMethod(mQuickMatchPopup, "OptionList.ListClass.AddItem", itemCampaign, false)
  FlashMethod(mQuickMatchPopup, "OptionList.ListClass.AddItem", itemHitList, false)
  if Engine.GetDownloadableContentMgr():IsDlcInstalled(D2_Game.DLC_PACK_TRAINYARD) then
    FlashMethod(mQuickMatchPopup, "OptionList.ListClass.AddItem", itemHitListDLC, false)
  end
  FlashMethod(mQuickMatchPopup, "OptionList.ListClass.AddItem", popupItemCancel, false)
  mQuickMatchPopup:Execute("SetDescription", "/D2/Language/Menu/MultiPlayer_QuickMatchOptionsTitle")
  FlashMethod(mQuickMatchPopup, "OptionList.ListClass.SetAlignment", "center")
  FlashMethod(mQuickMatchPopup, "OptionList.ListClass.SetSelected", 0)
end
function ListButtonPressed(movie, buttonArg)
  print("ListButtonPressed")
  if mShowingBusyPopup or mQuickMatchState ~= QUICKMATCH_STATE_NONE then
    return
  end
  local index = tonumber(buttonArg) + 1
  gRegion:PlaySound(pressSound, Vector(), false)
  print("index=" .. index)
  print("itemList[index]=" .. itemList[index])
  print("itemInviteExternalParty=" .. itemInviteExternalParty)
  if itemList[index] == itemQuickMatch then
    if not IsNull(mQuickMatchPopup) then
      mQuickMatchPopup:Close()
      mQuickMatchPopup = nil
    end
    mQuickMatchPopup = movie:PushChildMovie(popupConfirmMovie)
    mQuickMatchPopup:Execute("SetTransitionInDoneCallback", "QuickMatchPopupTransitionInDone")
  elseif itemList[index] == itemCampaignNew then
    if not IsNull(mProfileData) and mProfileData:GetCampaignMissionNum() > 0 then
      local popupMovie = movie:PushChildMovie(popupConfirmMovie)
      FlashMethod(popupMovie, "CreateOkCancel", "/D2/Language/Menu/Multiplayer_NewCampaignConfirm", popupItemOk, popupItemCancel, "NewCampaignDestroyOldConfirm")
      return
    end
    StartNewCampaign(movie)
  elseif itemList[index] == itemCampaignContinue then
    HostInit(movie, D2_Game.GAME_MODE_CAMPAIGN)
  elseif itemList[index] == itemHitList then
    HostInit(movie, D2_Game.GAME_MODE_HITLIST)
  elseif Engine.GetDownloadableContentMgr():IsDlcInstalled(D2_Game.DLC_PACK_TRAINYARD) and itemList[index] == itemHitListDLC then
    HostInit(movie, D2_Game.GAME_MODE_HITLIST_DLC)
  elseif itemList[index] == itemSearch then
    local childMovie = movie:PushChildMovie(itemSearchMovie)
    if childMovie ~= nil then
      childMovie:SetTexture("BinkPlaceholder.png", binkTexture)
    end
  elseif mPartyInviteVal and itemList[index] == itemInviteExternalParty then
    print("calling InviteExternalParty")
    InviteExternalParty(movie)
  elseif itemList[index] == itemJoinExternalParty or not mPartyInviteVal and itemList[index] == itemInviteExternalParty then
    JoinExternalParty(movie)
  end
end
function OnPartyDisconnectConfirm(movie)
  Back(movie, true)
end
function onKeyDown_MENU_CANCEL(movie)
  if mShowingBusyPopup or mQuickMatchState ~= QUICKMATCH_STATE_NONE then
    return 1
  end
  Back(movie)
end
function onKeyDown_MENU_GENERIC1(movie)
  if not mIsOnline or mQuickMatchState ~= QUICKMATCH_STATE_NONE then
    return 1
  end
  if LIB.IsPS3(movie) then
    Engine.GetMatchingService():ShowSystemPendingInvitesUI()
  end
end
function onKeyDown_MENU_GENERIC2(movie)
  if mShowingBusyPopup or not mIsOnline then
    return 1
  end
  LIB.InviteFriends()
end
function onKeyDown_MENU_LTRIGGER2(movie)
  if not mPlayerListButtonEnabled or mQuickMatchState ~= QUICKMATCH_STATE_NONE then
    return
  end
  if mScreenState == SCREENSTATE_ViewGamerCard then
    mPartyList = LIB.PartyListSetEnabled(movie, mPartyList, false)
    SetScreenState(movie, SCREENSTATE_SelectingGameType)
    return
  end
  if mScreenState == SCREENSTATE_SelectingGameType and #mPartyList.members == 0 then
    return
  end
  SetScreenState(movie, SCREENSTATE_ViewGamerCard)
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
  if mShowingBusyPopup or mQuickMatchState ~= QUICKMATCH_STATE_NONE then
    return 1
  end
  if mScreenState == SCREENSTATE_SelectingGameType then
    return LIB.ListClassVerticalScroll(movie, "OptionList", dir)
  elseif mScreenState == SCREENSTATE_ViewGamerCard then
    return LIB.ListClassVerticalScroll(movie, "PartyList.OptionList", dir)
  end
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
function RestartBackgroundVideo(movie)
  gRegion:StartVideoTexture(binkTexture)
end

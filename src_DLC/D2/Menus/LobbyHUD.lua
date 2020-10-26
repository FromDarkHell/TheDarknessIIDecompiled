local LIB = require("D2.Menus.SharedLibrary")
tvAvatar = Type()
movieSubTitleRes = Resource()
chatWindowMovieRes = Resource()
progressMovieWRes = WeakResource()
progressMovie = Resource()
missionMovie = Resource()
popupConfirmMovie = Resource()
popupConfirmMovieWRes = WeakResource()
avatarLobbyAvatar = WeakResource()
campaignStructure = Resource()
externalPartyRefreshWait = 4
hideStatusBarTime = 0.5
lobbyLevelName = String()
sndBack = Resource()
sndScroll = Resource()
sndSelect = Resource()
local popupItemOk = "/D2/Language/Menu/Confirm_Item_Ok"
local popupItemYes = "/D2/Language/Menu/Confirm_Item_Yes"
local popupItemNo = "/D2/Language/Menu/Confirm_Item_No"
local statusChatWindow = "/D2/Language/MPGame/LobbyHUD_ChatWindow"
local statusPushToTalk = "/D2/Language/MPGame/LobbyHUD_PushToTalk"
local statusCycleCharacter = "/D2/Language/MPGame/LobbyHUD_CycleCharacter"
local statusChooseCharacter = "/D2/Language/MPGame/LobbyHUD_SelectCharacter"
local statusCurrentCharacter = "/D2/Language/MPGame/LobbyHUD_CurrentCharacter"
local statusConfirmCharacter = "/D2/Language/MPGame/LobbyHUD_ConfirmCharacter"
local statusCancelCharacter = "/D2/Language/MPGame/LobbyHUD_CancelCharacter"
local statusBeginMission = "/D2/Language/MPGame/LobbyHUD_ButtonToStart"
local statusDeselectCharacter = "/D2/Language/MPGame/LobbyHUD_DeselectCharacter"
local statusChooseMap = "/D2/Language/MPGame/ChooseMap"
local statusInviteFriends = "/D2/Language/MPGame/Shared_InviteToParty"
local statusPlayersList = "/D2/Language/MPGame/Shared_Status_PlayerList_Windows"
local statusPlayersListNoButton = "/D2/Language/MPGame/Shared_Status_PlayerListNoButton_Windows"
local statusPlayersListView = "/D2/Language/MPGame/Shared_ViewPlayer_Windows"
local statusPlayersListKick = "/D2/Language/MPGame/Lobby_PlayerList_Kick"
local statusPlayersListBack = "/D2/Language/MPGame/Shared_PlayerList_Back"
local statusBack = "/D2/Language/MPGame/LobbyHUD_Back"
local statusAdvance = "/D2/Language/Menu/Shared_Advance"
local popupItemOk = "/D2/Language/Menu/Confirm_Item_Ok"
local popupItemCancel = "/D2/Language/Menu/Confirm_Item_Cancel"
local gameInviteSubject = "/D2/Language/MPGame/GameInviteSubject"
local gameInviteMessage = "/D2/Language/MPGame/GameInviteMessage"
local mLocalPlayers = {}
local mCurrentCharacterDescription = ""
local mCurrentCharacterName = ""
local mGameRules, mMovieSubTitle
local mIsMultiplayer = false
local mIsHost = false
local mMaxDisplayableEvents, mNumEventMessages, mMaxDisplayableTeamNames
local mDisplayedTeamNames = {}
local mConfirmPopup, mChatWindowMovie
local mReceivedUpgrade = false
local mReceivedWeapon = false
local mProfileData, mDifficultyPopupMovie
local mCCTVVisible = false
local mLooking = 0
local mLocCRLN = "/D2/Language/Menu/Shared_CRLN"
local SCREENSTATE_SelectCharacter = 0
local SCREENSTATE_ConfirmCharacter = 1
local SCREENSTATE_WaitingToStart = 2
local SCREENSTATE_ViewGamerCard = 3
local mScreenState = -1
local mIsReady
local mMorePlayersMessage = ""
local mHasAvatarOnInit = true
local mCanBeginMission, mCanInviteFriends
local mBadgeInfo = {}
local externalPartyTimer = 0
local hideStatusBarTimer = 0
local mEnableDifficulty = false
local mPartyList, mOldState
local mExtraCallouts = {}
local mMaxExtraCallouts = 4
local mFrameName = ""
local EXTRA_CALLOUT_DIFFICULTY = 1
local EXTRA_CALLOUT_INVITE = 2
local EXTRA_CALLOUT_CHAT = 3
local EXTRA_CALLOUT_TALK = 4
local mDelayBackingOutOfLobbyTimer = 0
local mDelayBackingOutOfLobbyTime = 1
local IsValueInTable = function(table, value)
  for i, v in pairs(table) do
    if v == value then
      return true
    end
  end
  return false
end
local function UpdatePlayerListButton(movie)
  local text = statusPlayersList
  if mScreenState == SCREENSTATE_ViewGamerCard then
    text = statusPlayersListNoButton
  end
  movie:SetLocalized("PartyList.Title.text", text)
end
local function UpdateExtraCallouts(movie)
  local difficultyText = ""
  if not IsNull(mExtraCallouts[EXTRA_CALLOUT_DIFFICULTY]) then
    difficultyText = mExtraCallouts[EXTRA_CALLOUT_DIFFICULTY]
  end
  movie:SetLocalized("ExtraCallout1.label.text", difficultyText)
  local startOffsetIdx = 3
  for i = 2, mMaxExtraCallouts do
    local idx = startOffsetIdx + i - 1
    if not IsNull(mExtraCallouts[i]) then
      local oldType
      if (i == EXTRA_CALLOUT_CHAT or i == EXTRA_CALLOUT_TALK) and LIB.IsPC(movie) then
        oldType = gFlashMgr:GetInputDeviceIconType()
        gFlashMgr:SetInputDeviceIconType(DIT_PC)
      end
      movie:SetLocalized(string.format("PartyList.OptionList.ButtonLabel%i.TxtHolder.Txt.text", idx), mExtraCallouts[i])
      if not IsNull(oldType) then
        gFlashMgr:SetInputDeviceIconType(oldType)
      end
    else
      movie:SetLocalized(string.format("PartyList.OptionList.ButtonLabel%i.TxtHolder.Txt.text", idx), "")
    end
  end
end
local function AddPCChatButton(movie)
  if not IsNull(mGameRules) and mGameRules:IsPlayingOffline() then
    return
  end
  if LIB.IsPC(movie) then
    mExtraCallouts[EXTRA_CALLOUT_CHAT] = statusChatWindow
    mExtraCallouts[EXTRA_CALLOUT_TALK] = ""
  end
end
local function IsChangeCharacterAvailable()
  if IsNull(mLocalPlayers) or #mLocalPlayers == 0 then
    return false
  end
  local avatar = mLocalPlayers[1]:GetAvatar()
  if (IsNull(avatar) or avatar:GetCharacterType() ~= D2_Game.JACKIE) and not IsNull(mGameRules) and mGameRules:IsPlayingMPCampaign() then
    return (mGameRules:CanChangeAvatar())
  end
  return true
end
local function CanStartGame()
  local players = 0
  local ready = 0
  local isReady = false
  if mGameRules:IsPlayingOffline() or mIsHost then
    if not mGameRules:CanBeginMission() then
      return isReady
    end
    local players = 0
    local ready = 0
    local humanPlayers = gRegion:GetHumanPlayers()
    for i = 1, #humanPlayers do
      if humanPlayers[i]:IsLocal() then
      else
        players = players + 1
        if humanPlayers[i]:IsReady() then
          ready = ready + 1
        end
      end
    end
    if not IsChangeCharacterAvailable() then
      isReady = true
      if mGameRules:IsPlayingMPCampaign() then
        local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
        if not IsNull(playerProfile) then
          local profileData = playerProfile:GetGameSpecificData()
          if not IsNull(profileData) and profileData:GetCampaignMissionNum() == 0 then
            isReady = players == ready
          end
        end
      end
    else
      local requiredPlayers = mGameRules:GetMinimumRequiredPlayers()
      if players < requiredPlayers - 1 then
        isReady = false
      elseif players >= requiredPlayers - 1 and players ~= ready then
        isReady = false
      else
        isReady = true
      end
    end
  elseif not IsNull(mLocalPlayers) and 0 < #mLocalPlayers and mLocalPlayers[1]:IsReady() then
    isReady = false
  else
    isReady = true
  end
  return isReady
end
local function ResetBadge()
  mBadgeInfo = {
    curIndex = -1,
    data = {}
  }
end
local function DisplayBadge(movie)
  mBadgeInfo.curIndex = mBadgeInfo.curIndex + 1
  if mBadgeInfo.curIndex >= #mBadgeInfo.data then
    ResetBadge()
    return
  end
  local thisBadge = mBadgeInfo.data[mBadgeInfo.curIndex + 1]
  movie:SetVariable("Badge.Container.Name.text", thisBadge.name)
  movie:SetVariable("Badge.Container.Description.text", thisBadge.description)
  movie:SetVariable("Badge.Container.Player.text", LIB.FormatPlayerName(movie, thisBadge.player))
  FlashMethod(movie, "Badge.gotoAndPlay", "FadeIn")
end
function BadgeReady(movie)
  DisplayBadge(movie)
end
local function AddInviteFriendsButton(movie)
  if gRegion:GetGameRules():CanInviteFriends() and not IsNull(Engine.GetMatchingService():GetSession()) and not IsNull(mGameRules) and not mGameRules:IsPlayingOffline() then
    mExtraCallouts[EXTRA_CALLOUT_INVITE] = statusInviteFriends
  end
end
local function CanViewPlayerList()
  local ret = not IsNull(mGameRules) and not mGameRules:IsPlayingOffline()
  return ret
end
local function SetupWaitingOptions(movie)
  if mScreenState ~= SCREENSTATE_WaitingToStart then
    return
  end
  FlashMethod(movie, "StatusBar.StatusBarClass.Clear")
  if mIsHost then
    if mIsReady and gRegion:GetGameRules():CanBeginMission() then
      FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", statusBeginMission, false)
    end
    if not gRegion:GetGameRules():IsPlayingMPCampaign() then
      FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", statusChooseMap, false)
    end
  end
  AddInviteFriendsButton(movie)
  AddPCChatButton(movie)
  if IsChangeCharacterAvailable() then
    FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", statusDeselectCharacter, false)
  end
end
local function UpdateLocalReadyText(movie)
  if IsNull(mLocalPlayers) or #mLocalPlayers == 0 or mGameRules == nil then
    return
  end
  local COLOR_Enabled = 16777215
  local COLOR_Disabled = 7829367
  local color = COLOR_Disabled
  mMorePlayersMessage = ""
  local isReady = false
  local readyText = ""
  if mGameRules:IsPlayingOffline() or mIsHost then
    local players = 0
    local ready = 0
    local humanPlayers = gRegion:GetHumanPlayers()
    for i = 1, #humanPlayers do
      if humanPlayers[i]:IsLocal() then
      else
        players = players + 1
        if humanPlayers[i]:IsReady() then
          ready = ready + 1
        end
      end
    end
    if players == ready then
      color = COLOR_Enabled
    end
    if not IsChangeCharacterAvailable() then
      isReady = true
    else
      local requiredPlayers = mGameRules:GetMinimumRequiredPlayers()
      if players < requiredPlayers - 1 then
        readyText = movie:GetLocalized("/D2/Language/MPGame/LobbyHUD_RequiresMorePlayers")
        readyText = string.format(readyText, requiredPlayers)
        mMorePlayersMessage = readyText
      elseif players >= requiredPlayers - 1 and players ~= ready then
        isReady = false
      else
        isReady = true
      end
    end
  else
    color = COLOR_Enabled
    if not IsNull(mLocalPlayers) and 0 < #mLocalPlayers and mLocalPlayers[1]:IsReady() then
      isReady = false
    else
      isReady = true
    end
  end
  local canBeginMission = mGameRules:CanBeginMission()
  local canInviteFriends = mGameRules:CanInviteFriends() and not IsNull(Engine.GetMatchingService():GetSession())
  if mIsReady == nil or mIsReady ~= isReady or mCanBeginMission == nil or mCanBeginMission ~= canBeginMission or mCanInviteFriends == nil or mCanInviteFriends ~= canInviteFriends then
    mIsReady = isReady
    SetupWaitingOptions(movie)
  end
  mCanBeginMission = canBeginMission
  mCanInviteFriends = canInviteFriends
  local cctv = false
  local avatar
  if not IsNull(mLocalPlayers) and 0 < #mLocalPlayers then
    avatar = mLocalPlayers[1]:GetAvatar()
  end
  local txt = ""
  if IsNull(avatar) or avatar:IsA(tvAvatar) then
    color = COLOR_Enabled
    if avatar and avatar:IsCloseFocus() then
      local focusCharacter = avatar:GetFocusCharacter()
      local characterIsFree = true
      local humanPlayers = gRegion:GetHumanPlayers()
      for i = 1, #humanPlayers do
        if not IsNull(humanPlayers[i]) and not IsNull(humanPlayers[i]:GetAvatar()) and humanPlayers[i]:GetAvatar():GetCharacterType() == focusCharacter then
          characterIsFree = false
        end
      end
    end
  end
end
function OnSaveProfileComplete(success)
end
local function HideStatusBar(movie)
  FlashMethod(movie, "StatusBar.StatusBarClass.Clear")
  mExtraCallouts = {}
  hideStatusBarTimer = hideStatusBarTime
end
local function SetScreenState(movie, newState)
  mOldState = mScreenState
  local localPlayers = gRegion:ScriptGetLocalPlayers()
  local avatar = localPlayers[1]:GetAvatar()
  mIsReady = nil
  if newState == SCREENSTATE_SelectCharacter then
    FlashMethod(movie, "StatusBar.StatusBarClass.Clear")
    if not IsNull(mGameRules) and mGameRules:IsInLobbySpectateMode() then
      FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", statusAdvance, false)
    else
      if not IsNull(avatar) and avatar:GetFocusCharacter() ~= D2_Game.JACKIE then
        FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", statusChooseCharacter, false)
      end
      FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", statusCycleCharacter, false)
    end
    AddInviteFriendsButton(movie)
    AddPCChatButton(movie)
    FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", statusBack, false)
  elseif newState == SCREENSTATE_ConfirmCharacter then
    FlashMethod(movie, "StatusBar.StatusBarClass.Clear")
    FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", statusConfirmCharacter, false)
    AddInviteFriendsButton(movie)
    AddPCChatButton(movie)
    FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", statusCancelCharacter, false)
  elseif newState == SCREENSTATE_WaitingToStart then
    mScreenState = newState
    UpdateLocalReadyText(movie)
    mHasAvatarOnInit = true
  elseif newState == SCREENSTATE_ViewGamerCard then
    FlashMethod(movie, "StatusBar.StatusBarClass.Clear")
    FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", statusPlayersListView, false)
    if mIsHost then
      FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", statusPlayersListKick, false)
    end
    AddInviteFriendsButton(movie)
    AddPCChatButton(movie)
    FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", statusPlayersListBack, false)
  end
  mScreenState = newState
  UpdatePlayerListButton(movie)
end
local function UpdateLocalReadyState(movie)
  if mScreenState == SCREENSTATE_WaitingToStart and mIsHost and mConfirmPopup and not IsNull(mConfirmPopup) and not CanStartGame() then
    mConfirmPopup:Close()
    mConfirmPopup = nil
    mGameRules:DisableChangeAvatar(false)
  end
end
local function GetDifficultyIndex()
  local difficultyTable = LIB.GetDifficultyTable()
  if not mIsHost then
    local settings = mGameRules:GetMpSettings()
    return settings.difficulty
  end
  local d = mProfileData:GetHitListDifficulty()
  if mGameRules:IsPlayingMPCampaign() then
    d = mProfileData:GetCampaignDifficulty()
  end
  for i = 1, #difficultyTable do
    local name = difficultyTable[i].name
    if d == difficultyTable[i].difficulty then
      return i
    end
  end
  return 0
end
local function _SetDifficultyIndex(difficultyIndex)
  difficultyIndex = tonumber(difficultyIndex)
  local difficultyTable = LIB.GetDifficultyTable()
  if mGameRules:IsPlayingMPCampaign() then
    mProfileData:SetCampaignDifficulty(difficultyTable[difficultyIndex].difficulty)
  else
    mProfileData:SetHitListDifficulty(difficultyTable[difficultyIndex].difficulty)
  end
  local settings = mGameRules:GetMpSettings()
  settings.difficulty = difficultyIndex
  mGameRules:UpdateSettings(settings)
end
function SetDifficultyIndex(movie, difficultyIndex)
  _SetDifficultyIndex(difficultyIndex)
end
local function CycleDifficulty(dir)
  local difficultyTable = LIB.GetDifficultyTable()
  local difficultyIndex = GetDifficultyIndex()
  difficultyIndex = difficultyIndex + dir
  if difficultyIndex > #difficultyTable then
    difficultyIndex = 1
  end
  _SetDifficultyIndex(difficultyIndex)
end
function Initialize(movie)
  D2_Game.D2SecurityMgr_GetD2SecurityMgr():ValidateWith2K()
  mFrameName = ""
  mLooking = 0
  mConfirmPopup = nil
  mHasAvatarOnInit = true
  mLocCRLN = movie:GetLocalized(mLocCRLN)
  mMovieSubTitle = gFlashMgr:GotoMovie(movieSubTitleRes)
  local y = mMovieSubTitle:GetVariable("SubTitleRegular._y")
  mMovieSubTitle:SetVariable("SubTitleRegular._y", y - 65)
  ResetBadge()
  movie:SetVariable("CharacterTitle._visible", false)
  local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  if playerProfile ~= nil and not IsNull(playerProfile) then
    mProfileData = playerProfile:GetGameSpecificData()
    if not IsNull(mProfileData) then
      local sessionInfo = mProfileData:GetLastMPSessionInfo()
      if sessionInfo ~= nil then
        local IsVisible = sessionInfo.visible
        sessionInfo.returnedFromMission = IsVisible
        sessionInfo.visible = false
        if IsVisible then
          local badgeString = ""
          local numBadges = sessionInfo:GetNumBadges()
          if 0 < numBadges then
            for i = 1, numBadges do
              local badgeTitle = movie:GetLocalized(sessionInfo:GetBadgeTitle(i - 1))
              local badgeDesc = movie:GetLocalized(sessionInfo:GetBadgeDesc(i - 1))
              local badgeWinner = sessionInfo:GetBadgeWinner(i - 1)
              mBadgeInfo.data[#mBadgeInfo.data + 1] = {
                name = badgeTitle,
                description = badgeDesc,
                player = badgeWinner
              }
            end
            DisplayBadge(movie)
          end
          Engine.GetPlayerProfileMgr():ScriptSaveProfile(0, "OnSaveProfileComplete")
        end
        mProfileData:SetLastMPSessionInfo(sessionInfo)
      end
    end
  end
  mIsMultiplayer = true
  mLocalPlayers = gRegion:ScriptGetLocalPlayers()
  mGameRules = gRegion:GetGameRules()
  mPartyList = LIB.PartyListInitialize(movie, not mGameRules:IsPlayingOffline())
  movie:SetVariable("PartyList.Title.enabled", false)
  UpdatePlayerListButton(movie)
  movie:SetLocalized("PartyList.Title._y", -105)
  movie:SetLocalized("CharacterTitle.Container.label.text", statusCurrentCharacter)
  if Engine.GetMatchingService():IsHost() == true or mGameRules:IsPlayingOffline() then
    mIsHost = true
    local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
    local profileSettings = playerProfile:Settings()
    local gameHostSettings = profileSettings:GetHostSettings()
    local multiplayerMaps = gameHostSettings:GetMaps()
    local theGameMode = gameHostSettings.gameModeId
    local theMap = ""
    if mGameRules:IsPlayingMPCampaign() then
      local nextMap = mGameRules:GetNextCampaignMap()
      theMap = campaignStructure:GetMapName(nextMap)
    elseif multiplayerMaps ~= nil and multiplayerMaps[1] ~= nil then
      theMap = multiplayerMaps[1]
    else
      theGameMode = mGameRules:GetDefaultGameRules()
      theMap = mGameRules:GetDefaultLevel()
    end
    CycleDifficulty(0)
    local settings = mGameRules:GetMpSettings()
    settings:SetMap(theMap)
    settings.gameModeId = theGameMode
    mGameRules:UpdateSettings(settings)
    if Engine.GetMatchingService():IsHost() then
      local session = Engine.GetMatchingService():GetSession()
      if not IsNull(session) then
        local sessionSettings = session:GetSettings()
        sessionSettings:SetMap(lobbyLevelName)
        Engine.GetMatchingService():UpdateSessionSettings(sessionSettings)
      end
    end
  else
    mIsHost = false
  end
  local localPlayers = gRegion:ScriptGetLocalPlayers()
  local avatar = localPlayers[1]:GetAvatar()
  if (avatar == nil or avatar ~= nil and avatar:IsA(tvAvatar)) and IsChangeCharacterAvailable() then
    if avatar ~= nil and avatar:IsCloseFocus() then
      SetScreenState(movie, SCREENSTATE_ConfirmCharacter)
    else
      mHasAvatarOnInit = false
      SetScreenState(movie, SCREENSTATE_SelectCharacter)
    end
  else
    SetScreenState(movie, SCREENSTATE_WaitingToStart)
  end
  gChallengeMgr:NotifyTag(localPlayers[1], Symbol("HIT_LIST_MISSION_CHECK"))
  mCCTVVisible = -1
  mCurrentCharacterDescription = ""
  mCurrentCharacterName = ""
  mMaxDisplayableEvents = 0
  mNumEventMessages = 0
  mMaxDisplayableTeamNames = 0
  gClient:EnableDrawMessage(false)
  FlashMethod(movie, "InitializeMovie")
  mMaxDisplayableEvents = tonumber(movie:GetVariable("mMaxDisplayableEvents"))
  local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  local profileData = playerProfile:GetGameSpecificData()
  if profileData == nil then
    return -1
  end
  UpdateLocalReadyText(movie)
  local title = "/D2/Language/Menu/MultiPlayer_Item_HitList"
  if mGameRules:IsPlayingMPCampaign() then
    title = "/D2/Language/Menu/MultiPlayer_Item_Campaign"
  end
  movie:SetLocalized("Title.TxtHolder.Txt.text", title)
  movie:SetVariable("Title.TxtHolder.Txt.textAlign", "left")
  if LIB.IsPC(movie) then
    local y = movie:GetVariable("EventPane._y")
    movie:SetVariable("EventPane._y", y + 50)
  end
  mDelayBackingOutOfLobbyTimer = 0
end
local function UpdateEventMessageList(movie)
  local numMessages = gClient:GetNumMessages()
  if numMessages ~= mNumEventMessages then
    if numMessages >= mMaxDisplayableEvents then
      numMessages = mMaxDisplayableEvents
    end
    FlashMethod(movie, "ShowEventMessages", 0 < numMessages)
    for i = 0, mMaxDisplayableEvents - 1 do
      local msg = ""
      if numMessages > i then
        msg = gClient:GetMessage(i).mMessage
      end
      FlashMethod(movie, "SetEventMessage", i + 1, msg)
    end
    mNumEventMessages = numMessages
  end
end
local function UpdateContextAction(movie, thisAvatar, hudStatus)
  local gridLeftAlign = 90
  local gridRightAlign = 700
  local gridAlign = gridLeftAlign
  local characterName = ""
  local characterDescription = ""
  local textDescription = ""
  local frameName = "Default"
  if not IsNull(mGameRules) and mGameRules:IsInLobbySpectateMode() then
    return
  end
  if not IsNull(thisAvatar) then
    local characterType = thisAvatar:GetFocusCharacter()
    if characterType == D2_Game.INUGAMI then
      characterName = movie:GetLocalized("/D2/Language/MPGame/LobbyHUD_Inugami_Name")
      characterDescription = movie:GetLocalized("/D2/Language/MPGame/LobbyHUD_Inugami_Description")
      frameName = "Inugami"
    elseif characterType == D2_Game.SHOSHANNA then
      characterName = movie:GetLocalized("/D2/Language/MPGame/LobbyHUD_Shoshanna_Name")
      characterDescription = movie:GetLocalized("/D2/Language/MPGame/LobbyHUD_Shoshanna_Description")
      frameName = "Shoshanna"
    elseif characterType == D2_Game.JP_DUMOND then
      characterName = movie:GetLocalized("/D2/Language/MPGame/LobbyHUD_JPDumond_Name")
      characterDescription = movie:GetLocalized("/D2/Language/MPGame/LobbyHUD_JPDumond_Description")
      frameName = "JPDumond"
    elseif characterType == D2_Game.JIMMY_WILSON then
      characterName = movie:GetLocalized("/D2/Language/MPGame/LobbyHUD_JimmyWilson_Name")
      characterDescription = movie:GetLocalized("/D2/Language/MPGame/LobbyHUD_JimmyWilson_Description")
      frameName = "JimmyWilson"
    end
    if not thisAvatar:IsCloseFocus() then
      characterDescription = ""
    end
  end
  if mCurrentCharacterDescription ~= characterDescription then
    movie:SetVariable("CharacterInfo.Description.Container.text", characterDescription)
    mCurrentCharacterDescription = characterDescription
    movie:SetVariable("CharacterInfo._visible", mCurrentCharacterDescription ~= "")
  end
  if mCurrentCharacterName ~= characterName then
    mCurrentCharacterName = characterName
  end
  if mFrameName ~= frameName then
    FlashMethod(movie, "CharacterStyle.gotoAndStop", frameName)
    mFrameName = frameName
  end
end
function SetMaxDisplayableTeamNames(movie, maxDisplayableTeamNames)
  mMaxDisplayableTeamNames = maxDisplayableTeamNames
  for i = 1, mMaxDisplayableTeamNames do
    mDisplayedTeamNames[i] = true
  end
end
function ConfirmLoot(movie, args)
  if tonumber(args) == 0 and IsNull(mProfileData) then
    return
  end
end
local function CheckForInitialPlaythrough(movie)
  if IsNull(mProfileData) or gRegion:GetGameRules():IsPlayingMPCampaign() then
    return
  end
  local foundProgressMovie = gFlashMgr:FindMovie(progressMovieWRes)
  local foundMovie = gFlashMgr:FindMovie(popupConfirmMovieWRes)
  if foundMovie or foundProgressMovie then
    return
  end
  local avatar
  if not IsNull(mLocalPlayers) and 0 < #mLocalPlayers then
    avatar = mLocalPlayers[1]:GetAvatar()
  end
  local s = mProfileData:GetLobbyVisitState()
  if s == 0 then
    movie:SetMouseVisible(false)
    mProfileData:SetLobbyVisitState(s + 1)
  end
  movie:SetVariable("StatusBar._visible", IsNull(mConfirmPopup))
  movie:SetVariable("StatusBarBackground._visible", IsNull(mConfirmPopup))
end
local function UpdateMapLocation(movie)
  local difficultyLabel
  if mIsHost then
    difficultyLabel = movie:GetLocalized("/D2/Language/MPGame/LobbyHUD_DifficultyLabelHost")
  else
    difficultyLabel = movie:GetLocalized("/D2/Language/MPGame/LobbyHUD_DifficultyLabelClient")
  end
  mEnableDifficulty = false
  if IsNull(mGameRules) then
    return
  end
  if gRegion:GetGameRules():IsPlayingMPCampaign() then
    local difficultyTable = LIB.GetDifficultyTable()
    local difficultyIndex = GetDifficultyIndex()
    local str = difficultyLabel
    if difficultyIndex ~= nil and 0 < difficultyIndex then
      str = str .. movie:GetLocalized(difficultyTable[difficultyIndex].name)
      mEnableDifficulty = true
    end
    mEnableDifficulty = mEnableDifficulty and not IsNull(mGameRules) and not mGameRules:IsInLobbySpectateMode()
    if mEnableDifficulty then
      mExtraCallouts[EXTRA_CALLOUT_DIFFICULTY] = str
    else
      mExtraCallouts[EXTRA_CALLOUT_DIFFICULTY] = nil
    end
    return
  end
  local settings = mGameRules:GetMpSettings()
  local maps = settings:GetMaps()
  local mapName = ""
  if maps ~= nil and 1 <= #maps then
    mapName = maps[1]
  end
  local workingMission
  local numRegions = mGameRules:NumRegions()
  for i = 0, numRegions - 1 do
    local thisRegion = mGameRules:GetRegion(i)
    local numMissions = thisRegion:NumMissions()
    if numMissions <= 0 then
    else
      for j = 0, numMissions - 1 do
        local thisMission = thisRegion:GetMission(j)
        local missionMap = thisMission:GetLevelFile()
        if missionMap == mapName then
          local canPlay = true
          if mGameRules:IsPlayingOffline() then
            canPlay = 1 >= mGameRules:GetMinimumRequiredPlayers(i, j)
          end
          if canPlay then
            local locMissionID = string.format("/D2/Language/MPGame/MissionName_%s_%s", thisRegion.regionName, thisMission.missionName)
            local str = "\"" .. movie:GetLocalized(locMissionID) .. "\""
            movie:SetLocalized("MissionTitle.Container.label.text", "/D2/Language/MPGame/LobbyHUD_CurrentMission")
            local difficultyTable = LIB.GetDifficultyTable()
            local difficultyIndex = GetDifficultyIndex()
            local difficultyStr = difficultyLabel
            if 0 < difficultyIndex then
              difficultyStr = difficultyStr .. movie:GetLocalized(difficultyTable[difficultyIndex].name)
              mEnableDifficulty = true
            end
            if not IsNull(mGameRules) and not mGameRules:IsInLobbySpectateMode() then
              mExtraCallouts[EXTRA_CALLOUT_DIFFICULTY] = difficultyStr
            end
            movie:SetVariable("MissionInfo.Container.Label.text", str .. mMorePlayersMessage)
            workingMission = thisMission
            break
          end
        end
      end
      if workingMission ~= nil then
        break
      end
    end
  end
  local challengeText = ""
  if workingMission ~= nil then
    local numChallenges = gChallengeMgr:GetNumChallenges()
    if 0 < numChallenges then
      for i = 1, numChallenges do
        local theChallenge = gChallengeMgr:GetChallengeByIndex(i - 1)
        if IsNull(theChallenge) or theChallenge:GetLevel():GetResourceName() ~= mapName then
        else
          local theChallengeName = theChallenge:GetName()
          local locChallengeName = movie:GetLocalized(string.format("/D2/Language/Challenges/Challenge_%s_Name", theChallengeName))
          if gChallengeMgr:GetChallengeProgress(theChallengeName) < theChallenge:GetRequiredCount() then
            challengeText = movie:GetLocalized("/D2/Language/MPGame/LobbyHUD_ActiveChallenge") .. locChallengeName
            break
          end
          challengeText = movie:GetLocalized("/D2/Language/MPGame/LobbyHUD_CompletedChallenge") .. locChallengeName
          break
        end
      end
    end
  end
  movie:SetVariable("ChallengeInfo.text", challengeText)
end
local function ValidateCurrentScreenState(movie)
  local avatar
  if not IsNull(mLocalPlayers) and 0 < #mLocalPlayers then
    avatar = mLocalPlayers[1]:GetAvatar()
  end
  if IsNull(avatar) then
    return
  end
  if 0 < hideStatusBarTimer then
    hideStatusBarTimer = hideStatusBarTimer - DeltaTime()
    if hideStatusBarTimer <= 0 then
      SetScreenState(movie, mScreenState)
    end
    return
  end
  if mScreenState == SCREENSTATE_ViewGamerCard then
  elseif mScreenState == SCREENSTATE_SelectCharacter then
    if not avatar:IsA(tvAvatar) or avatar:GetCharacterType() ~= D2_Game.JACKIE then
      SetScreenState(movie, SCREENSTATE_WaitingToStart)
    elseif avatar:IsCloseFocus() then
      SetScreenState(movie, SCREENSTATE_ConfirmCharacter)
    end
  elseif mScreenState == SCREENSTATE_ConfirmCharacter then
    if not avatar:IsA(tvAvatar) or avatar:GetCharacterType() ~= D2_Game.JACKIE then
      SetScreenState(movie, SCREENSTATE_WaitingToStart)
    elseif not avatar:IsCloseFocus() then
      SetScreenState(movie, SCREENSTATE_SelectCharacter)
    end
  elseif mScreenState == SCREENSTATE_WaitingToStart and (avatar:IsA(tvAvatar) or avatar:GetCharacterType() == D2_Game.JACKIE) then
    SetScreenState(movie, SCREENSTATE_SelectCharacter)
  end
end
function Update(movie)
  if not IsNull(gClient:GetVignette()) then
    mDelayBackingOutOfLobbyTimer = mDelayBackingOutOfLobbyTime
  elseif 0 < mDelayBackingOutOfLobbyTimer then
    mDelayBackingOutOfLobbyTimer = mDelayBackingOutOfLobbyTimer - DeltaTime()
  end
  local delta = RealDeltaTime()
  if IsNull(mLocalPlayers) or #mLocalPlayers == 0 or IsNull(mLocalPlayers[1]) then
    return
  end
  local thisAvatar = mLocalPlayers[1]:GetAvatar()
  if not mHasAvatarOnInit and not IsNull(thisAvatar) and not thisAvatar:IsA(tvAvatar) then
    SetScreenState(movie, SCREENSTATE_WaitingToStart)
    mHasAvatarOnInit = true
  end
  local hudStatus = mLocalPlayers[1]:GetHudStatus()
  if hudStatus:VisibilityChanged() then
    movie:SetVisible(hudStatus:IsVisible())
  end
  ValidateCurrentScreenState(movie)
  UpdateContextAction(movie, thisAvatar, hudStatus)
  UpdateEventMessageList(movie)
  mPartyList = LIB.PartyListUpdate(movie, delta, mPartyList)
  UpdateLocalReadyText(movie)
  UpdateMapLocation(movie)
  CheckForInitialPlaythrough(movie)
  if mScreenState == SCREENSTATE_ConfirmCharacter then
    FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByName", statusConfirmCharacter, 0 < hudStatus:GetNumContextActions())
  elseif mScreenState == SCREENSTATE_WaitingToStart then
    UpdateLocalReadyState(movie)
  end
  UpdateExtraCallouts(movie)
end
local function StartGame()
  if mGameRules == nil or not CanStartGame() then
    return
  end
  if mGameRules:IsPlayingOffline() or Engine.GetMatchingService():IsHost() then
    local gameRules = gRegion:GetGameRules()
    local settings = gameRules:GetMpSettings()
    local multiplayerGameRules = gGameConfig:GetMultiplayerGameRules(settings.gameModeId)
    local gameMapName = ""
    local gameRulesName = ""
    if gameRules:IsPlayingMPCampaign() then
      local nextMap = mGameRules:GetNextCampaignMap()
      mProfileData:SetCampaignMissionNum(nextMap)
      gameMapName = campaignStructure:GetMapName(nextMap)
      gameRulesName = campaignStructure:GetMapRulesName(nextMap)
    else
      local mapList = settings:GetMaps()
      if mapList == nil then
        return
      end
      gameMapName = mapList[1]
    end
    gameRules:MasterOnMissionStarted()
    if Engine.GetMatchingService():IsHost() then
      local session = Engine.GetMatchingService():GetSession()
      if not IsNull(session) then
        local settings = session:GetSettings()
        settings:SetMap(gameMapName)
        Engine.GetMatchingService():UpdateSessionSettings(settings)
      end
    end
    local args = Engine.OpenLevelArgs()
    args:SetLevel(gameMapName)
    if gameRulesName == nil or gameRulesName == "" then
      args.gameRules = settings:GetGameRules()
    else
      args:SetGameRules(gameRulesName)
    end
    if multiplayerGameRules.mLobbyMovie ~= nil then
      args.menuMovie = multiplayerGameRules.mLobbyMovie
    end
    args.hostingMultiplayer = true
    args.migrateServer = true
    Engine.OpenLevel(args)
  end
end
function ConfirmStartGame(movie, args)
  if not IsNull(mConfirmPopup) then
    mConfirmPopup:SetMouseVisible(false)
  end
  if tonumber(args) == 0 then
    mConfirmPopup:Close()
    mConfirmPopup = nil
    StartGame()
  else
    mGameRules:DisableChangeAvatar(false)
  end
end
function PartyListButtonSelected(movie, arg)
  if mPartyList == nil then
    return
  end
  gRegion:PlaySound(sndScroll, Vector(), false)
  mPartyList.curIndex = tonumber(arg)
  LIB.PartyListUpdateKickStatus(mPartyList, movie)
end
function ConfirmKick(movie, arg)
  if not IsNull(mConfirmPopup) then
    mConfirmPopup:SetMouseVisible(false)
  end
  if tonumber(arg) == 0 then
    LIB.PartyListKick(mPartyList)
  end
end
function onKeyDown_LOBBY_READY(movie)
  if not IsNull(gClient:GetVignette()) then
    return
  end
  if mScreenState == SCREENSTATE_ViewGamerCard and mIsHost and LIB.PartyListCanKick(mPartyList) then
    gRegion:PlaySound(sndSelect, Vector(), false)
    mConfirmPopup = movie:PushChildMovie(popupConfirmMovie)
    FlashMethod(mConfirmPopup, "CreateOkCancel", "/D2/Language/MPGame/KickPlayerMessage", popupItemYes, popupItemNo, "ConfirmKick")
    return
  end
  if mScreenState ~= SCREENSTATE_WaitingToStart then
    return
  end
  if mIsHost and not gRegion:GetGameRules():IsPlayingMPCampaign() and (IsNull(mConfirmPopup) or not mConfirmPopup:IsVisible()) then
    gRegion:PlaySound(sndSelect, Vector(), false)
    movie:PushChildMovie(missionMovie)
  end
end
function onKeyDown_LOBBY_CYCLE(movie, deviceId, data)
  if not IsNull(gClient:GetVignette()) then
    return
  end
  if not IsNull(mGameRules) and mGameRules:IsInLobbySpectateMode() then
    return
  end
  if mScreenState == SCREENSTATE_ViewGamerCard then
    return
  end
  local localPlayers = gRegion:ScriptGetLocalPlayers()
  local avatar = localPlayers[1]:GetAvatar()
  if avatar ~= nil then
    if avatar:IsA(tvAvatar) and not avatar:IsCloseFocus() then
      gRegion:PlaySound(sndScroll, Vector(), false)
      if tonumber(data) < 0 then
        avatar:PrevCharacter()
      else
        avatar:NextCharacter()
      end
    end
    SetScreenState(movie, SCREENSTATE_SelectCharacter)
  end
end
local function ChangeCharacter(movie, dir)
  if not IsNull(gClient:GetVignette()) then
    return
  end
  if not IsNull(mGameRules) and mGameRules:IsInLobbySpectateMode() then
    return
  end
  if mScreenState ~= SCREENSTATE_SelectCharacter then
    return
  end
  local localPlayers = gRegion:ScriptGetLocalPlayers()
  local avatar = localPlayers[1]:GetAvatar()
  if avatar ~= nil and avatar:IsA(tvAvatar) and not avatar:IsCloseFocus() then
    gRegion:PlaySound(sndScroll, Vector(), false)
    if dir == -1 then
      avatar:PrevCharacter()
    elseif dir == 1 then
      avatar:NextCharacter()
    end
    SetScreenState(movie, SCREENSTATE_SelectCharacter)
  end
end
function onKeyDown_MENU_LEFT_FROM_ANALOG(movie)
  ChangeCharacter(movie, -1)
end
function onKeyDown_MENU_RIGHT_FROM_ANALOG(movie)
  ChangeCharacter(movie, 1)
end
function onKeyDown_MENU_UP(movie)
  if not IsNull(gClient:GetVignette()) then
    return
  end
  if mScreenState == SCREENSTATE_ViewGamerCard then
    gRegion:PlaySound(sndScroll, Vector(), false)
    return LIB.ListClassVerticalScroll(movie, "PartyList.OptionList", -1)
  end
  return true
end
function onKeyDown_MENU_UP_FROM_ANALOG(movie)
  if not IsNull(gClient:GetVignette()) then
    return
  end
  if mScreenState == SCREENSTATE_ViewGamerCard then
    gRegion:PlaySound(sndScroll, Vector(), false)
    return LIB.ListClassVerticalScroll(movie, "PartyList.OptionList", -1)
  end
  return true
end
function onKeyDown_MENU_DOWN(movie)
  if not IsNull(gClient:GetVignette()) then
    return
  end
  if mScreenState == SCREENSTATE_ViewGamerCard then
    gRegion:PlaySound(sndScroll, Vector(), false)
    return LIB.ListClassVerticalScroll(movie, "PartyList.OptionList", 1)
  end
  return true
end
function onKeyDown_MENU_DOWN_FROM_ANALOG(movie)
  if not IsNull(gClient:GetVignette()) then
    return
  end
  if mScreenState == SCREENSTATE_ViewGamerCard then
    gRegion:PlaySound(sndScroll, Vector(), false)
    return LIB.ListClassVerticalScroll(movie, "PartyList.OptionList", 1)
  end
  return true
end
function onKeyDown_MENU_GENERIC2(movie)
  if not IsNull(gClient:GetVignette()) then
    return
  end
  if not IsNull(Engine.GetMatchingService():GetSession()) then
    gRegion:PlaySound(sndSelect, Vector(), false)
    local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
    Engine.GetMatchingService():ShowSystemGameInviteUI(playerProfile, gameInviteSubject, gameInviteMessage)
  end
end
function onKeyDown_LOBBY_SELECT(movie)
  if not IsNull(gClient:GetVignette()) then
    return
  end
  gRegion:PlaySound(sndSelect, Vector(), false)
  if not IsNull(mGameRules) and mGameRules:IsInLobbySpectateMode() and mScreenState ~= SCREENSTATE_ViewGamerCard then
    mGameRules:StopLobbySpectateMode()
    SetScreenState(movie, SCREENSTATE_SelectCharacter)
    return
  end
  local localPlayers = gRegion:ScriptGetLocalPlayers()
  local avatar = localPlayers[1]:GetAvatar()
  if mScreenState == SCREENSTATE_SelectCharacter then
    if not IsNull(avatar) and avatar:IsA(tvAvatar) and avatar:GetFocusCharacter() ~= D2_Game.JACKIE then
      avatar:DoCloseFocus()
      SetScreenState(movie, SCREENSTATE_ConfirmCharacter)
    end
  elseif mScreenState == SCREENSTATE_ConfirmCharacter then
    local hudStatus = mLocalPlayers[1]:GetHudStatus()
    if hudStatus:GetNumContextActions() > 0 then
      SetScreenState(movie, SCREENSTATE_WaitingToStart)
    end
    HideStatusBar(movie)
  elseif mScreenState == SCREENSTATE_WaitingToStart then
    if 0 < hideStatusBarTimer then
      return
    end
    if (mIsHost or mGameRules:IsPlayingOffline()) and CanStartGame() then
      mGameRules:DisableChangeAvatar(true)
      movie:SetMouseVisible(false)
      mConfirmPopup = movie:PushChildMovie(popupConfirmMovie)
      FlashMethod(mConfirmPopup, "CreateOkCancel", "/D2/Language/MPGame/LobbyHUD_Confirm_Start", popupItemYes, popupItemNo, "ConfirmStartGame")
    end
  elseif mScreenState == SCREENSTATE_ViewGamerCard then
    LIB.PartyListDisplayMemberInfo(mPartyList)
    return 1
  end
end
local function TogglePlayerListPC(movie, val)
  if LIB.IsPC(movie) then
    movie:SetMouseVisible(not val)
    local localPlayers = gRegion:ScriptGetLocalPlayers()
    local avatar = localPlayers[1]:GetAvatar()
    if avatar ~= nil and not avatar:IsA(tvAvatar) and not avatar:IsCloseFocus() then
      avatar:SetFreeLook(val)
    end
  end
end
local function TogglePlayerListScreenState(movie)
  local defaultRet = true
  if not CanViewPlayerList() then
    return defaultRet
  end
  if 0 < hideStatusBarTimer then
    return defaultRet
  end
  gRegion:PlaySound(sndSelect, Vector(), false)
  mPartyList = LIB.PartyListSetEnabled(movie, mPartyList, not mPartyList.enabled)
  if mPartyList.enabled then
    SetScreenState(movie, SCREENSTATE_ViewGamerCard)
    TogglePlayerListPC(movie, false)
  else
    SetScreenState(movie, mOldState)
    TogglePlayerListPC(movie, true)
  end
  return defaultRet
end
function onKeyDown_MENU_LTRIGGER2(movie)
  if not IsNull(gClient:GetVignette()) then
    return
  end
  return TogglePlayerListScreenState(movie)
end
function DifficultyPopupListSelected(movie, arg)
end
function DifficultyPopupListUnselected(movie, arg)
end
function DifficultyPopupListButtonPressed(movie, arg)
  local newDifficultyIndex = tonumber(arg) + 1
  _SetDifficultyIndex(newDifficultyIndex)
  mDifficultyPopupMovie:Close()
end
function DifficultyPopupTransitionInDone(movie)
  FlashMethod(mDifficultyPopupMovie, "CreateList", "DifficultyPopupListButtonPressed", "DifficultyPopupListSelected", "DifficultyPopupListButtonUnselected")
  local difficultyTable = LIB.GetDifficultyTable()
  for i = 1, #difficultyTable do
    local dtName = difficultyTable[i].name
    FlashMethod(mDifficultyPopupMovie, "OptionList.ListClass.AddItem", dtName, false)
  end
  FlashMethod(mDifficultyPopupMovie, "OptionList.ListClass.SetAlignment", "center")
  FlashMethod(mDifficultyPopupMovie, "OptionList.ListClass.SetSelected", 0)
  mDifficultyPopupMovie:Execute("SetDescription", "/D2/Language/Menu/MainMenu_SelectDifficulty")
end
local function DisplayDifficultyPopup(movie)
  mDifficultyPopupMovie = movie:PushChildMovie(popupConfirmMovie)
  mDifficultyPopupMovie:Execute("SetTransitionInDoneCallback", "DifficultyPopupTransitionInDone")
end
function onKeyDown_MENU_RTRIGGER2(movie)
  if not IsNull(gClient:GetVignette()) then
    return
  end
  if not IsNull(mGameRules) and mGameRules:IsInLobbySpectateMode() then
    return
  end
  if not mIsHost then
    return
  end
  gRegion:PlaySound(sndSelect, Vector(), false)
  if mEnableDifficulty ~= nil and mEnableDifficulty then
    DisplayDifficultyPopup(movie)
  end
end
function onKeyDown_LOBBY_CANCEL(movie)
  if not IsNull(gClient:GetVignette()) or 0 < mDelayBackingOutOfLobbyTimer then
    return
  end
  if mScreenState == SCREENSTATE_ViewGamerCard then
    return TogglePlayerListScreenState(movie)
  end
  if not IsNull(mGameRules) and mGameRules:IsInLobbySpectateMode() and mScreenState ~= SCREENSTATE_ViewGamerCard then
    movie:SetMouseVisible(false)
    mConfirmPopup = movie:PushChildMovie(popupConfirmMovie)
    local text = "/D2/Language/Menu/MainMenuConfirm"
    if not mGameRules:IsPlayingOffline() and mIsHost then
      text = "/D2/Language/Menu/MainMenuMPConfirm"
    end
    FlashMethod(mConfirmPopup, "CreateOkCancel", text, popupItemOk, popupItemCancel, "MainMenuConfirm")
    return
  end
  if not IsChangeCharacterAvailable() then
    return
  end
  local localPlayers = gRegion:ScriptGetLocalPlayers()
  local avatar = localPlayers[1]:GetAvatar()
  if avatar ~= nil and avatar:IsA(tvAvatar) and avatar:IsCloseFocus() and avatar:GetFocusCharacter() ~= D2_Game.JACKIE then
    avatar:CancelCloseFocus()
  end
  gRegion:PlaySound(sndBack, Vector(), false)
  if mScreenState == SCREENSTATE_ConfirmCharacter then
    SetScreenState(movie, SCREENSTATE_SelectCharacter)
  elseif (mScreenState == SCREENSTATE_WaitingToStart or mScreenState == SCREENSTATE_ViewGamerCard) and IsChangeCharacterAvailable() then
    if mPartyList.enabled then
      mPartyList = LIB.PartyListSetEnabled(movie, mPartyList, false)
    end
    if mScreenState == SCREENSTATE_ViewGamerCard then
      SetScreenState(movie, mOldState)
    else
      mGameRules:DisableChangeAvatar(false)
      SetScreenState(movie, SCREENSTATE_SelectCharacter)
      HideStatusBar(movie)
    end
  elseif mScreenState == SCREENSTATE_SelectCharacter and IsNull(gClient:GetVignette()) then
    movie:SetMouseVisible(false)
    mConfirmPopup = movie:PushChildMovie(popupConfirmMovie)
    local text = "/D2/Language/Menu/MainMenuConfirm"
    if not mGameRules:IsPlayingOffline() and mIsHost then
      text = "/D2/Language/Menu/MainMenuMPConfirm"
    end
    FlashMethod(mConfirmPopup, "CreateOkCancel", text, popupItemOk, popupItemCancel, "MainMenuConfirm")
  end
  ResetBadge()
end
function MainMenuConfirm(movie, args)
  if not IsNull(mConfirmPopup) then
    mConfirmPopup:SetMouseVisible(false)
  end
  if tonumber(args) == 0 then
    Engine.GetMatchingService():DisableSessionReconnect()
    if mIsHost then
      mGameRules:EndGame(Engine.GameRules_GS_INTERRUPTED, 0)
    end
    Engine.Disconnect(true)
  end
end
function SetHudAlpha(movie, a)
  movie:SetVariable("_root._alpha", tonumber(a))
end

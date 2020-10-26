local LIB = require("D2.Menus.SharedLibrary")
popupConfirmMovie = Resource()
optionsMenuMovie = WeakResource()
lobbyLevel = WeakResource()
lobbyGameRules = WeakResource()
relicBrowserMovie = WeakResource()
objectivesPopupMovie = WeakResource()
sndBack = Resource()
sndScroll = Resource()
sndSelect = Resource()
multiplayerGameRules = WeakResource()
hudMovie = WeakResource()
lobbyHudMovie = WeakResource()
chatMovie = WeakResource()
binkTexture = Resource()
demoGameRulesPAX = WeakResource()
demoMainMenuLevelPAX = WeakResource()
externalPartyRefreshWait = 4
checkpointType = Type()
backgroundBinkAlpha = 98
soundTestMovie = WeakResource()
avatarTransitional = WeakResource()
avatarLobbyJackieTV = WeakResource()
local SCREENSTATE_SelectingOption = 0
local SCREENSTATE_SelectingPartyMember = 1
local itemResume = "/D2/Language/Menu/Pause_Item_Resume"
local itemRestartChapter = "/D2/Language/Menu/Pause_Item_RestartChapter"
local itemRestartCheckpoint = "/D2/Language/Menu/Pause_Item_RestartCheckpoint"
local itemMainMenu = "/D2/Language/Menu/Pause_Item_MainMenu"
local itemQuitToLobby = "/D2/Language/Menu/Pause_Item_QuitToLobby"
local itemOptions = "/D2/Language/Menu/MainMenu_Item_Options"
local itemInvite = "/D2/Language/Menu/Pause_Item_Invite"
local itemCheckInvites = "/D2/Language/MPGame/Shared_CheckPendingInvitesMenu"
local itemInviteExternalParty = "/D2/Language/MPGame/Shared_InviteExternalParty"
local itemJoinExternalParty = "/D2/Language/MPGame/Shared_JoinExternalParty"
local itemRelicBrowser = "/D2/Language/Menu/Pause_Item_Relic_Browser"
local itemList = {}
local defaultItemList = {}
local statusSelect = "/D2/Language/Menu/Shared_Select"
local statusInvite = "/D2/Language/MPGame/Shared_InviteToParty"
local statusPlayerList = "/D2/Language/MPGame/Shared_Status_PlayerList_Windows"
local statusPlayersBack = "/D2/Language/MPGame/Shared_PlayerList_Back"
local statusBack = "/D2/Language/Menu/Shared_Back"
local statusList = {}
local popupItemOk = "/D2/Language/Menu/Confirm_Item_Ok"
local popupItemCancel = "/D2/Language/Menu/Confirm_Item_Cancel"
local popupItemYes = "/D2/Language/Menu/Confirm_Item_Yes"
local popupItemNo = "/D2/Language/Menu/Confirm_Item_No"
local mGameRules
local mInLobbyGameRules = false
local mInTurfWarsGameRules = false
local mInDemoGameRulesPAX = false
local mIsMultiplayer = false
local mIsHosting = false
local mWaitingForAsyncMovie = false
local mStartButtonIsDown = false
local mSelectedItem, mPartyList, mScreenState, mPartyJoinVal, mPartyInviteVal, mConfirmPopup, mBanner, mMovie
local mChapter = 0
local mPrevDeviceId
local externalPartyTimer = 0
local screenAlpha = 0
local mRestartCheckpointPopup
local mRestartCheckpointPending = false
local mAllowedToClosePC = false
local function CanViewPlayerList()
  local ret = not IsNull(mGameRules) and not mGameRules:IsPlayingOffline()
  return ret
end
local function UpdateObjectives(movie)
  if mGameRules == nil or IsNull(mGameRules) then
    return
  end
  gameState = mGameRules:GetGameState(0)
  if IsNull(gameState) then
    return
  end
  local numActive = tonumber(gameState:GetNumObjectives(0))
  local levelInfo = gRegion:GetLevelInfo()
  if IsNull(levelInfo) then
    return
  end
  mChapter = levelInfo:GetChapterNumber()
  local locString
  if mIsMultiplayer then
    locString = string.format("/D2/Language/Menu/Chapter_Coop_%i", mChapter)
  else
    locString = string.format("/D2/Language/Menu/Chapter_Single_%i", mChapter)
  end
  if 0 < mChapter then
    movie:SetLocalized("ObjectiveTitle.text", string.format("%s_Name", locString))
  end
  movie:SetLocalized("ObjectiveGlobalText.text", string.format("%s_Objective", locString))
  local CRLN = movie:GetLocalized("/D2/Language/Menu/Shared_CRLN")
  local finalStr = ""
  for i = 1, numActive do
    local thisObjective = tostring(gameState:GetObjectiveByIndex(0, i - 1))
    finalStr = finalStr .. movie:GetLocalized(thisObjective) .. CRLN
  end
  movie:SetVariable("ObjectiveText.text", finalStr)
end
local DisplayChallenges = function(movie)
  if gChallengeMgr == nil then
    return
  end
  local numChallenges = gChallengeMgr:GetNumChallenges()
  for i = 1, numChallenges do
    local thisChallenge = gChallengeMgr:GetChallengeByIndex(i - 1)
    if gChallengeMgr:IsActiveChallenge(thisChallenge) then
      local challengeName = thisChallenge:GetName()
      movie:SetLocalized("Challenge.text", "/D2/Language/Menu/Pause_ActiveChallenge")
      movie:SetLocalized("ChallengeTitle.text", string.format("/D2/Language/Challenges/Challenge_%s_Name", challengeName))
      local curProgress = gChallengeMgr:GetChallengeProgress(challengeName)
      local maxProgress = thisChallenge:GetRequiredCount()
      local challengeDesc = movie:GetLocalized(string.format("/D2/Language/Challenges/Challenge_%s_Description", challengeName))
      if curProgress < 0 then
        challengeDesc = challengeDesc .. " - " .. movie:GetLocalized("/D2/Language/MPGame/Challenge_Failed")
      elseif 0 < maxProgress then
        challengeDesc = challengeDesc .. string.format(" (%i/%i)", curProgress, maxProgress)
      end
      movie:SetVariable("ChallengeText.text", challengeDesc)
      break
    end
  end
end
local function DisplayRelics(movie)
  local curRelicsInLevel = mGameRules:GetRelicsInLevel()
  local curRelicsFound = mGameRules:GetRelicsFound()
  if 0 < curRelicsInLevel then
    local strFmt = movie:GetLocalized("/D2/Language/Menu/Pause_RelicsFound")
    local strFinal = string.format(strFmt, curRelicsFound, curRelicsInLevel)
    movie:SetVariable("Relics.text", strFinal)
  end
end
local function SetScreenState(movie, newState)
  mPartyList = LIB.PartyListSetEnabled(movie, mPartyList, newState == SCREENSTATE_SelectingPartyMember)
  FlashMethod(movie, "OptionList.ListClass.SetEnabled", newState == SCREENSTATE_SelectingOption)
  if newState == SCREENSTATE_SelectingOption then
    FlashMethod(movie, "OptionList.ListClass.SetSelected", mSelectedItem)
    if mGameRules:IsPlayingOffline() then
      statusList = {statusSelect, statusBack}
    else
      statusList = {
        statusSelect,
        statusInvite,
        statusPlayerList,
        statusBack
      }
    end
  elseif newState == SCREENSTATE_SelectingPartyMember then
    statusList = LIB.PartyListGetStatusOptions(false, mIsHosting)
  end
  FlashMethod(movie, "StatusBar.StatusBarClass.Clear")
  for i = 1, #statusList do
    FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", statusList[i], statusList[i] == statusBack or statusList[i] == statusPlayerList or statusList[i] == statusPlayersBack)
  end
  FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByName", statusPlayerList, mIsMultiplayer)
  FlashMethod(movie, "StatusBar.StatusBarClass.SetCallbackOnPress", "StatusButtonPressed")
  if newState == SCREENSTATE_SelectingPartyMember then
    mPartyList.curIndex = 0
    LIB.PartyListUpdateKickStatus(mPartyList, movie)
  end
  mScreenState = newState
end
local function UpdatePartyOptions(movie)
  local newSelection
  local newInviteVal = Engine.GetMatchingService():GetState() ~= 0 and Engine.GetMatchingService():CanInviteExternalParty()
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
    FlashMethod(movie, "OptionList.ListClass.SetSelected", newSelection - 1)
  end
end
local function DisplayEssence(movie)
  if not mIsMultiplayer and mChapter <= 1 or mInLobbyGameRules and mGameRules:IsInLobbySpectateMode() then
    return true
  end
  local players = gRegion:ScriptGetLocalPlayers()
  local avatar = players[1]:GetAvatar()
  if not IsNull(avatar) then
    if not IsNull(avatarTransitional) and avatar:IsA(avatarTransitional) then
      return true
    end
    if not IsNull(avatarLobbyJackieTV) and avatar:IsA(avatarLobbyJackieTV) then
      return true
    end
    local activeCharacterType = avatar:GetCharacterType()
    local inventoryController = avatar:ScriptInventoryControl()
    local profileData = inventoryController:GetProfileDataForTalents()
    local talentPoints = profileData:GetTalentPoints(activeCharacterType)
    local strFmt = movie:GetLocalized("/D2/Language/Menu/Pause_Essence")
    movie:SetVariable("Essence.text", string.format(strFmt, talentPoints))
    return true
  end
  return false
end
function Initialize(movie)
  local chat = gFlashMgr:FindMovie(chatMovie)
  if not IsNull(chat) then
    print("Found a chat window, so closing pause menu...")
    movie:Close()
    return
  end
  mMovie = movie
  local objectivesInstance = gFlashMgr:FindMovie(objectivesPopupMovie)
  if not IsNull(objectivesInstance) then
    objectivesInstance:Execute("GamePausedHideObjectives", "")
  end
  mRestartCheckpointPopup = nil
  mRestartCheckpointPending = false
  mBanner = LIB.BannerInitialize(movie)
  mBanner.line = mBanner.LINE_Double
  mBanner.spinner = true
  mBanner.loc = "D2/Language/Menu/Profile_PleaseWait"
  mChapter = 0
  mPartyInviteVal = false
  mPartyJoinVal = false
  mGameRules = gRegion:GetGameRules()
  if IsNull(mGameRules) then
    print("Could not find GameRules, so closing pause menu...")
    movie:Close()
    return
  end
  local hudInstance = gFlashMgr:FindMovie(hudMovie)
  local lobbyHudInstance = gFlashMgr:FindMovie(lobbyHudMovie)
  if hudInstance == nil and lobbyHudInstance == nil then
    print("Could not find a HUD, so closing pause menu...")
    movie:Close()
    return
  end
  externalPartyTimer = 0
  mInLobbyGameRules = mGameRules:IsA(lobbyGameRules)
  mInTurfWarsGameRules = mGameRules:IsA(multiplayerGameRules)
  mInDemoGameRulesPAX = not IsNull(demoGameRulesPAX) and mGameRules:IsA(demoGameRulesPAX)
  if mInDemoGameRulesPAX and not IsNull(gRegion:GetPlayingCinematic()) then
    movie:Close()
    return
  end
  mIsHosting = false
  if Engine.GetMatchingService():GetState() ~= 0 or mInLobbyGameRules or mInTurfWarsGameRules then
    mIsMultiplayer = true
    if Engine.GetMatchingService():IsHost() == true then
      mIsHosting = true
    end
  else
    mIsMultiplayer = false
    if not IsNull(demoGameRulesPAX) and mGameRules:IsA(demoGameRulesPAX) then
      movie:SetBackgroundAlpha(0.15)
    end
  end
  mStartButtonIsDown = false
  mPartyList = LIB.PartyListInitialize(movie, not mGameRules:IsPlayingOffline())
  movie:SetLocalized("Title.TxtHolder.Txt.text", "/D2/Language/Menu/Pause_Title")
  movie:SetVariable("Title.TxtHolder.Txt.textAlign", "left")
  if not mInLobbyGameRules and not mInDemoGameRulesPAX then
    UpdateObjectives(movie)
    if mIsMultiplayer then
      DisplayChallenges(movie)
    else
      DisplayRelics(movie)
    end
  end
  if not DisplayEssence(movie) then
    print("DisplayEssence failed, so closing pause menu...")
    movie:Close()
    return
  end
  if hudInstance ~= nil then
    hudInstance:SetVisible(false)
  end
  if lobbyHudInstance ~= nil then
    lobbyHudInstance:SetVisible(false)
  end
  movie:SetVariable("._alpha", screenAlpha)
  movie:SetBackgroundAlpha(0)
  movie:SetVariable("BinkPlaceholder._alpha", backgroundBinkAlpha)
  if mIsMultiplayer then
    if mIsHosting and not mInLobbyGameRules then
      if mGameRules:IsPlayingMPCampaign() then
        if not mGameRules:IsEnding() then
          itemList = {
            itemResume,
            itemRestartCheckpoint,
            itemInvite,
            itemOptions,
            itemMainMenu
          }
        else
          itemList = {
            itemResume,
            itemInvite,
            itemOptions,
            itemMainMenu
          }
        end
      elseif not IsNull(checkpointType) and IsNull(gRegion:FindNearest(checkpointType, Vector(), INF)) then
        if LIB.IsPS3(movie) then
          itemList = {
            itemResume,
            itemInvite,
            itemCheckInvites,
            itemOptions,
            itemQuitToLobby
          }
        else
          itemList = {
            itemResume,
            itemInvite,
            itemOptions,
            itemQuitToLobby
          }
        end
      else
        itemList = {
          itemResume,
          itemRestartCheckpoint,
          itemInvite,
          itemOptions,
          itemQuitToLobby
        }
      end
    elseif mGameRules:IsPlayingOffline() then
      if mInLobbyGameRules then
        itemList = {
          itemResume,
          itemOptions,
          itemMainMenu
        }
      elseif mGameRules:IsPlayingMPCampaign() then
        itemList = {
          itemResume,
          itemRestartCheckpoint,
          itemOptions,
          itemMainMenu
        }
      else
        itemList = {
          itemResume,
          itemRestartCheckpoint,
          itemOptions,
          itemQuitToLobby
        }
      end
    elseif LIB.IsPS3(movie) then
      itemList = {
        itemResume,
        itemInvite,
        itemCheckInvites,
        itemOptions,
        itemMainMenu
      }
    else
      itemList = {
        itemResume,
        itemInvite,
        itemOptions,
        itemMainMenu
      }
    end
  elseif mInDemoGameRulesPAX then
    itemList = {
      itemResume,
      itemRestartCheckpoint,
      itemOptions,
      itemMainMenu
    }
  elseif not IsNull(checkpointType) and IsNull(gRegion:FindNearest(checkpointType, Vector(), INF)) then
    itemList = {
      itemResume,
      itemRestartChapter,
      itemRelicBrowser,
      itemOptions,
      itemMainMenu
    }
  else
    itemList = {
      itemResume,
      itemRestartChapter,
      itemRestartCheckpoint,
      itemRelicBrowser,
      itemOptions,
      itemMainMenu
    }
  end
  for i = 1, #itemList do
    FlashMethod(movie, "OptionList.ListClass.AddItem", itemList[i])
  end
  defaultItemList = itemList
  UpdatePartyOptions(movie)
  FlashMethod(movie, "OptionList.ListClass.AddItem", "test")
  FlashMethod(movie, "OptionList.ListClass.EraseItemByName", "test")
  FlashMethod(movie, "OptionList.ListClass.SetAlignment", "left")
  FlashMethod(movie, "OptionList.ListClass.SetSelectedCallback", "ListButtonChanged")
  FlashMethod(movie, "OptionList.ListClass.SetPressedCallback", "ListButtonPressed")
  FlashMethod(movie, "OptionList.ListClass.SetSelected", 0)
  mSelectedItem = 0
  SetScreenState(movie, SCREENSTATE_SelectingOption)
  mGameRules:RequestPause()
  movie:SetTexture("BinkPlaceholder.png", binkTexture)
  gRegion:StartVideoTexture(binkTexture)
end
function Shutdown(movie)
  if mPrevDeviceId ~= nil then
    mPrevDeviceId = nil
  end
  local objectivesInstance = gFlashMgr:FindMovie(objectivesPopupMovie)
  if not IsNull(objectivesInstance) then
    objectivesInstance:Execute("GameResumedShowObjectives", "")
  end
end
function Update(movie)
  local delta = RealDeltaTime()
  mPartyList = LIB.PartyListUpdate(movie, delta, mPartyList)
  if screenAlpha < 100 and not gRegion:IsVideoTextureAsyncLoadPending() then
    screenAlpha = Clamp(screenAlpha + delta * 400, 0, 100)
    movie:SetVariable("._alpha", screenAlpha)
  end
  if mIsMultiplayer then
    externalPartyTimer = externalPartyTimer - delta
    if externalPartyTimer <= 0 then
      UpdatePartyOptions(movie)
      externalPartyTimer = externalPartyRefreshWait
    end
  end
  if mRestartCheckpointPending then
    movie:RestartCheckpoint()
    mRestartCheckpointPending = false
  end
end
local PlaySound = function(sound)
  gRegion:PlaySound(sound, Vector(), false)
end
local function _SetWaitingForAsyncMovie(waiting)
  mWaitingForAsyncMovie = waiting
  if not IsNull(binkTexture) then
    binkTexture:SetAllowPlayDuringPause(not waiting)
  end
end
function SetWaitingForAsyncMovie(movie, waiting)
  local param = tonumber(waiting) == 1
  _SetWaitingForAsyncMovie(param)
end
local function Back(movie)
  if mWaitingForAsyncMovie then
    return
  end
  local players = gRegion:ScriptGetLocalPlayers()
  if not IsNull(players) then
    local avatar = players[1]:GetAvatar()
    if not IsNull(avatar) then
      avatar:InputControl():ReturnToGame()
    end
  end
  mGameRules:RequestUnpause()
  PlaySound(sndBack)
  movie:Close()
  gRegion:StopVideoTexture(binkTexture)
  local hudInstance = gFlashMgr:FindMovie(hudMovie)
  if hudInstance ~= nil then
    hudInstance:SetVisible(true)
  end
  hudInstance = gFlashMgr:FindMovie(lobbyHudMovie)
  if hudInstance ~= nil then
    hudInstance:SetVisible(true)
  end
end
function onKeyDown_MENU_CANCEL(movie)
  if mScreenState == SCREENSTATE_SelectingOption then
    if not LIB.IsPC(movie) then
      Back(movie)
    else
      mAllowedToClosePC = true
    end
  elseif mScreenState == SCREENSTATE_SelectingPartyMember then
    mPartyList = LIB.PartyListSetEnabled(movie, mPartyList, false)
    SetScreenState(movie, SCREENSTATE_SelectingOption)
  end
end
function onKeyUp_MENU_CANCEL(movie)
  if mScreenState == SCREENSTATE_SelectingOption and LIB.IsPC(movie) and mAllowedToClosePC then
    Back(movie)
  end
  mAllowedToClosePC = false
end
function onKeyDown_MENU_GENERIC2(movie)
  if not mIsMultiplayer or not IsNull(mGameRules) and mGameRules:IsPlayingOffline() then
    return 1
  end
  LIB.InviteFriends()
end
function StatusButtonPressed(movie, buttonArg)
  local index = tonumber(buttonArg) + 1
  if statusList[index] == statusBack then
    Back(movie)
  elseif statusList[index] == statusPlayerList then
    SetScreenState(movie, SCREENSTATE_SelectingPartyMember)
  elseif statusList[index] == statusPlayersBack then
    SetScreenState(movie, SCREENSTATE_SelectingOption)
  elseif statusList[index] == statusInvite then
    LIB.InviteFriends()
  end
end
function onKeyDown_HIDE_PAUSE_MENU(movie)
  mStartButtonIsDown = true
end
function onKeyUp_HIDE_PAUSE_MENU(movie)
  if mStartButtonIsDown then
    Back(movie)
  end
end
function RestartConfirm(movie, args)
  if tonumber(args) == 0 then
    PlaySound(sndBack)
    movie:RestartLevel()
    local popupMovie = movie:PushChildMovie(popupConfirmMovie)
    FlashMethod(popupMovie, "CreateOkCancel", "/D2/Language/Menu/RestartWait", "", "", "")
  end
end
function RestartCheckpointPopupTransitionDone(movie)
  mRestartCheckpointPending = true
  mRestartCheckpointPopup:Execute("SetDescription", "D2/Language/Menu/Profile_PleaseWait")
end
function RestartCheckpointConfirm(movie, args)
  if tonumber(args) == 0 and not mGameRules:IsEnding() then
    PlaySound(sndBack)
    if not IsNull(mRestartCheckpointPopup) then
      mRestartCheckpointPopup:Close()
      mRestartCheckpointPopup = nil
    end
    mRestartCheckpointPopup = movie:PushChildMovie(popupConfirmMovie)
    mRestartCheckpointPopup:Execute("SetTransitionInDoneCallback", "RestartCheckpointPopupTransitionDone")
  end
end
local ClearSessionInfoOnMissionQuit = function(missionQuit)
  local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  if playerProfile ~= nil and not IsNull(playerProfile) then
    local profileData = playerProfile:GetGameSpecificData()
    if profileData ~= nil and not IsNull(profileData) then
      local sessionInfo = profileData:GetLastMPSessionInfo()
      if sessionInfo ~= nil then
        sessionInfo.missionQuit = missionQuit
        sessionInfo.visible = false
        profileData:SetLastMPSessionInfo(sessionInfo)
      end
    end
  end
end
function MainMenuConfirm(movie, args)
  if tonumber(args) == 0 then
    Engine.GetMatchingService():DisableSessionReconnect()
    if mInLobbyGameRules then
      if mIsHosting then
        mGameRules:EndGame(Engine.GameRules_GS_INTERRUPTED, 0)
      end
      Engine.Disconnect(true)
    elseif mIsMultiplayer and (mIsHosting or mGameRules:IsPlayingOffline()) then
      ClearSessionInfoOnMissionQuit(not mGameRules:IsPlayingMPCampaign())
      mGameRules:EndGame(Engine.GameRules_GS_INTERRUPTED, 0)
    elseif mInDemoGameRulesPAX and not IsNull(demoMainMenuLevelPAX) then
      local openArgs = Engine.OpenLevelArgs()
      openArgs:SetLevel(demoMainMenuLevelPAX:GetResourceName())
      openArgs:SetGameRules(demoGameRulesPAX:GetResourceName())
      openArgs.migrateServer = false
      Engine.OpenLevel(openArgs)
    else
      PlaySound(sndBack)
      Engine.Disconnect(true)
      local popupMovie = movie:PushChildMovie(popupConfirmMovie)
      FlashMethod(popupMovie, "CreateOkCancel", "/D2/Language/Menu/RestartWait", "", "", "")
    end
  end
end
function ListButtonChanged(movie, buttonArg)
  PlaySound(sndScroll)
  mSelectedItem = tonumber(buttonArg)
end
function PartyListButtonSelected(movie, arg)
  mPartyList.curIndex = tonumber(arg)
  LIB.PartyListUpdateKickStatus(mPartyList, movie)
end
function PartyListButtonPressed(movie, arg)
  LIB.PartyListDisplayMemberInfo(mPartyList)
end
local JoinExternalParty = function(movie)
  if Engine.GetMatchingService():IsExternalPartyGameSessionJoinable() then
    local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
    Engine.GetMatchingService():JoinExternalPartyGameSession(playerProfile)
  end
end
local InviteExternalParty = function(movie)
  if Engine.GetMatchingService():IsExternalPartyActive() then
    local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
    Engine.GetMatchingService():SendExternalPartyGameInvites(playerProfile)
  end
end
function OnOptionsMovieReady(options)
  if mMovie ~= nil then
    mBanner.state = mBanner.STATE_FadeOut
    LIB.BannerDisplay(mMovie, mBanner)
  end
  if mPrevDeviceId ~= nil then
    mPrevDeviceId = nil
  end
  if not IsNull(options) then
    options:SetTexture("BinkPlaceholder.png", binkTexture)
    if mInDemoGameRulesPAX then
      options:SetBackgroundAlpha(0.15)
    else
      options:SetBackgroundAlpha(0)
      options:SetVariable("BinkPlaceholder._alpha", backgroundBinkAlpha)
    end
  end
  _SetWaitingForAsyncMovie(false)
end
function OnRelicBrowserMovieReady(relicsBrowser)
  print("OnRelicBrowserMovieReady()")
  if mPrevDeviceId ~= nil then
    print("Restoring exclusive device id mPrevDeviceId=" .. tostring(mPrevDeviceId))
    mPrevDeviceId = nil
  end
  if not IsNull(relicsBrowser) then
    relicsBrowser:SetTexture("BinkPlaceholder.png", binkTexture)
    if mInDemoGameRulesPAX then
      relicsBrowser:SetBackgroundAlpha(0.15)
    else
      relicsBrowser:SetBackgroundAlpha(0)
      relicsBrowser:SetVariable("BinkPlaceholder._alpha", backgroundBinkAlpha)
    end
  end
  _SetWaitingForAsyncMovie(false)
end
function ListButtonPressed(movie, buttonArg)
  local index = tonumber(buttonArg) + 1
  PlaySound(sndSelect)
  if index > #itemList then
    print("ListButtonPressed: " .. tostring(index))
    local externalIndex = index - #itemList
    if externalIndex == 1 then
      if mPartyInviteVal then
        InviteExternalParty(movie)
      elseif mPartyJoinVal then
        JoinExternalParty(movie)
      end
    elseif externalIndex == 2 then
      JoinExternalParty(movie)
    end
    return
  end
  if itemList[index] == itemResume then
    Back(movie)
  elseif itemList[index] == itemRestartChapter then
    local popupMovie = movie:PushChildMovie(popupConfirmMovie)
    FlashMethod(popupMovie, "CreateOkCancel", "/D2/Language/Menu/RestartConfirm", popupItemOk, popupItemCancel, "RestartConfirm")
  elseif itemList[index] == itemRestartCheckpoint then
    if not mGameRules:IsEnding() then
      local popupMovie = movie:PushChildMovie(popupConfirmMovie)
      FlashMethod(popupMovie, "CreateOkCancel", "/D2/Language/Menu/RestartCheckpointConfirm", popupItemOk, popupItemCancel, "RestartCheckpointConfirm")
    end
  elseif itemList[index] == itemMainMenu or itemList[index] == itemQuitToLobby then
    local popupMovie = movie:PushChildMovie(popupConfirmMovie)
    local locString = "/D2/Language/Menu/MainMenuConfirm"
    if mInLobbyGameRules or mInTurfWarsGameRules then
      local isOffline = not IsNull(mGameRules) and mGameRules:IsPlayingOffline()
      local playingCampaign = mGameRules:IsPlayingMPCampaign()
      if isOffline then
        if not playingCampaign and not mInLobbyGameRules then
          locString = "/D2/Language/Menu/LobbyConfirm"
        end
      elseif mIsHosting then
        if mInLobbyGameRules or playingCampaign then
          locString = "/D2/Language/Menu/MainMenuMPConfirm"
        else
          locString = "/D2/Language/Menu/LobbyConfirm"
        end
      end
    end
    FlashMethod(popupMovie, "CreateOkCancel", locString, popupItemOk, popupItemCancel, "MainMenuConfirm")
  elseif itemList[index] == itemOptions then
    if not mWaitingForAsyncMovie then
      mPrevDeviceId = gFlashMgr:GetExclusiveDeviceID()
      mBanner.state = mBanner.STATE_FadeIn
      LIB.BannerDisplay(movie, mBanner)
      _SetWaitingForAsyncMovie(true)
      movie:PushChildMovieAsync(optionsMenuMovie, "OnOptionsMovieReady")
    end
  elseif itemList[index] == itemRelicBrowser then
    if not mWaitingForAsyncMovie then
      mPrevDeviceId = gFlashMgr:GetExclusiveDeviceID()
      print("Opening relic screen mPrevDeviceId=" .. tostring(mPrevDeviceId))
      _SetWaitingForAsyncMovie(true)
      movie:PushChildMovieAsync(relicBrowserMovie, "OnRelicBrowserMovieReady")
    end
  elseif itemList[index] == itemInvite then
    LIB.InviteFriends()
  elseif itemList[index] == itemCheckInvites then
    Engine.GetMatchingService():ShowSystemPendingInvitesUI()
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
local function Move(movie, dir)
  if mScreenState == SCREENSTATE_SelectingOption then
    return LIB.ListClassVerticalScroll(movie, "OptionList", dir)
  elseif mScreenState == SCREENSTATE_SelectingPartyMember then
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
function ConfirmKick(movie, arg)
  if tonumber(arg) == 0 then
    LIB.PartyListKick(mPartyList)
  end
end
function onKeyDown_MENU_LTRIGGER2(movie)
  if not mIsMultiplayer or not IsNull(mGameRules) and mGameRules:IsPlayingOffline() then
    return
  end
  if not CanViewPlayerList() then
    return
  end
  if mScreenState == SCREENSTATE_SelectingPartyMember then
    mPartyList = LIB.PartyListSetEnabled(movie, mPartyList, false)
    SetScreenState(movie, SCREENSTATE_SelectingOption)
    return
  end
  if mScreenState == SCREENSTATE_SelectingOption and #mPartyList.members == 0 then
    return
  end
  SetScreenState(movie, SCREENSTATE_SelectingPartyMember)
end
function onKeyDown_MENU_GENERIC1(movie)
  if mScreenState ~= SCREENSTATE_SelectingPartyMember then
    if Engine.GameRules_CheatsEnabled() then
      movie:PushChildMovie(soundTestMovie)
    end
    return
  end
  if mIsHosting and LIB.PartyListCanKick(mPartyList) then
    mConfirmPopup = movie:PushChildMovie(popupConfirmMovie)
    FlashMethod(mConfirmPopup, "CreateOkCancel", "/D2/Language/MPGame/KickPlayerMessage", popupItemYes, popupItemNo, "ConfirmKick")
    return
  end
end

local LIB = require("D2.Menus.SharedLibrary")
popupConfirmMovie = WeakResource()
binkTexture = Resource()
sndBack = Resource()
sndScroll = Resource()
sndScrollTarget = Resource()
sndSelect = Resource()
local SESSIONSTATE_WaitingForPlayers = 5
local SESSIONSTATE_JoiningSession = 3
local SESSIONSTATE_CreatingSession = 1
local statusSelect = "/D2/Language/Menu/Shared_Select"
local statusToggle = "/D2/Language/Menu/Shared_HToggle"
local statusBack = "/D2/Language/Menu/Shared_Back"
local statusList = {
  statusSelect,
  statusToggle,
  statusBack
}
local mScreenState
local mMissionList = {""}
local mIsHost = false
local mGameRules
local mProgressColour = 16711680
local originalScreenBlur = 0
local originalFocalDepth = 0
local mActivePopupMovie
local popupItemOk = "/D2/Language/Menu/Confirm_Item_Ok"
local popupItemCancel = "/D2/Language/Menu/Confirm_Item_Cancel"
local mNumRegions = 0
local mSelectedRegion
local mMissionToSelect = -1
local mActiveRegionIdx = -1
local mActiveMissionIdx = -1
local mAnimation = {}
local mRegions = {}
local mRegionImage = {}
local mCardSpacing = 256
local mOriginalCompletMarkerX
local mActiveRegionCompletionStates = {}
local SetRegionSelected = function(movie, regionIdx, isSelected)
  local frameName = "Unselected"
  if isSelected then
    frameName = "Selected"
  end
  FlashMethod(movie, string.format("Target%i.gotoAndPlay", regionIdx), frameName)
end
local function SnapRegionPositions(movie)
  local templateX = movie:GetVariable("Template._x")
  for i = 1, mNumRegions do
    mRegions[i].x = templateX - mSelectedRegion * mCardSpacing + (i - 1) * mCardSpacing
    if i > mSelectedRegion + 1 then
      mRegions[i].x = mRegions[i].x + 550
    end
    movie:SetVariable(string.format("Target%i._x", i - 1), mRegions[i].x)
  end
end
local function FindActiveRegionAndMission()
  mActiveRegionIdx = -1
  mActiveMissionIdx = -1
  if IsNull(Engine.GetMatchingService():GetSession()) and not mGameRules:IsPlayingOffline() then
    return
  end
  local settings = mGameRules:GetMpSettings()
  local maps = settings:GetMaps()
  local mapName = ""
  if maps == nil or #maps ~= 1 then
    return
  end
  mapName = maps[1]
  local numRegions = mGameRules:NumRegions()
  for i = 0, numRegions - 1 do
    local thisRegion = mGameRules:GetRegion(i)
    local numMissions = thisRegion:NumMissions()
    if 0 < numMissions then
      for j = 0, numMissions - 1 do
        local thisMission = thisRegion:GetMission(j)
        local missionMap = thisMission:GetLevelFile()
        if missionMap == mapName then
          mActiveRegionIdx = i
          mActiveMissionIdx = j
          return
        end
      end
    end
  end
  mActiveRegionIdx = 0
  mActiveMissionIdx = 0
  return
end
local function PopulateRegionList(movie)
  local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  local profileSettings = playerProfile:Settings()
  local gameHostSettings = profileSettings:GetHostSettings()
  local gameMode = gameHostSettings.gameModeId
  local dlcOnly = gameMode == D2_Game.GAME_MODE_HITLIST_DLC
  mNumRegions = mGameRules:SetupRegions(dlcOnly)
  local n = 0
  for i = 1, mNumRegions do
    local thisRegion = mGameRules:GetRegion(i - 1)
    if not mGameRules:IsRegionUnlocked(i - 1) then
    else
      n = n + 1
    end
  end
  mNumRegions = n
  FlashMethod(movie, "GenerateTargets", mNumRegions)
  local templateX = movie:GetVariable("Template._x")
  for i = 1, mNumRegions do
    local thisRegion = mGameRules:GetRegion(i - 1)
    local thisRegionName = thisRegion.regionName
    local regionTargetImage = "Default"
    if not mGameRules:IsRegionUnlocked(i - 1) then
    else
      if mRegionImage[thisRegionName] ~= nil then
        regionTargetImage = mRegionImage[thisRegionName]
      end
      local frameName = "UnselectedIdle"
      if i - 1 == mSelectedRegion then
        frameName = "SelectedIdle"
      end
      FlashMethod(movie, string.format("Target%i.gotoAndStop", i - 1), frameName)
      FlashMethod(movie, string.format("Target%i.Frame.RegionImage.gotoAndStop", i - 1), regionTargetImage)
      mRegions[#mRegions + 1] = {x = 0, idx = i}
    end
  end
  SnapRegionPositions(movie)
  movie:SetVariable("Template._visible", false)
  movie:SetVariable("DescFrameTemplate._visible", false)
end
local ClearMissionList = function(movie)
  FlashMethod(movie, "OptionList.ListClass.EraseItems", "")
  movie:SetVariable("SelectedMission._visible", false)
  for i = 0, 7 do
    movie:SetVariable(string.format("Strikes.ObjStrike%i._visible", i), false)
  end
end
local function UpdateStrikeAlpha(movie, missionIdx, isSelected)
  if mActiveRegionCompletionStates[missionIdx + 1] ~= nil and mActiveRegionCompletionStates[missionIdx + 1] then
    local animToPlay = "FadeIn"
    if isSelected then
      animToPlay = "FadeOut"
    end
    FlashMethod(movie, string.format("Strikes.ObjStrike%i.gotoAndPlay", missionIdx), animToPlay)
  end
end
local function UpdateDescriptionPane(movie, missionIdx)
  local missionText = movie:GetLocalized("/D2/Language/MPGame/MissionDesc_Locked")
  local theRegion = mGameRules:GetRegion(mSelectedRegion)
  if not IsNull(theRegion) then
    local thisRegionName = theRegion.regionName
    if missionIdx < theRegion:NumMissions() then
      local challenge = ""
      local thisMission = mGameRules:GetRegion(mSelectedRegion):GetMission(missionIdx)
      if mGameRules:IsMissionAvailable(mSelectedRegion, missionIdx) then
        local locMissionID = string.format("/D2/Language/MPGame/MissionDesc_%s_%s", thisRegionName, thisMission.missionName)
        missionText = movie:GetLocalized(locMissionID)
        local numChallenges = gChallengeMgr:GetNumChallenges()
        if 0 < numChallenges then
          missionText = missionText .. movie:GetLocalized("/D2/Language/Menu/Shared_CRLN") .. movie:GetLocalized("/D2/Language/Menu/Shared_CRLN") .. movie:GetLocalized("/D2/Language/MPGame/MissionSelect_ChallengesAvailable")
          local mapName = thisMission:GetLevelFile()
          for i = 1, numChallenges do
            local theChallenge = gChallengeMgr:GetChallengeByIndex(i - 1)
            if IsNull(theChallenge) or theChallenge:GetLevel():GetResourceName() ~= mapName then
            else
              local theChallengeName = theChallenge:GetName()
              local locChallengeName = movie:GetLocalized(string.format("/D2/Language/Challenges/Challenge_%s_Name", theChallengeName))
              missionText = missionText .. movie:GetLocalized("/D2/Language/Menu/Shared_CRLN") .. locChallengeName
              if gChallengeMgr:GetChallengeProgress(theChallengeName) >= theChallenge:GetRequiredCount() then
                missionText = missionText .. movie:GetLocalized("/D2/Language/Menu/Shared_CRLN") .. movie:GetLocalized("/D2/Language/Menu/MissionSelect_Completed")
              end
            end
          end
        end
      elseif mGameRules:IsPlayingOffline() and 1 < mGameRules:GetMinimumRequiredPlayers(mSelectedRegion, missionIdx) then
        missionText = movie:GetLocalized("/D2/Language/MPGame/MissionDesc_OnlineOnly")
      else
        local thisMission = mGameRules:GetRegion(mSelectedRegion):GetMission(missionIdx)
        local numMissionsNeeded = thisMission.minimumClearedMissions - mGameRules:GetNumCompletedMissions()
        if 0 < numMissionsNeeded then
          missionText = string.format(movie:GetLocalized("/D2/Language/MPGame/MissionDesc_LockedNotEnoughMissions"), numMissionsNeeded)
        end
      end
      if mGameRules:IsMissionCompleted(mSelectedRegion, missionIdx) then
        movie:SetVariable("objectiveComplete" .. missionIdx .. "._color", 10223616)
      end
    end
  end
  UpdateStrikeAlpha(movie, missionIdx, true)
  movie:SetVariable("Description.text", missionText)
  movie:SetVariable("TargetDescFrame.TargetDescription.text", movie:GetLocalized(string.format("/D2/Language/MPGame/RegionDesc_%s", theRegion.regionName)))
  movie:SetVariable("TargetDescFrame._visible", true)
end
local function PopulateMissionList(movie)
  if IsNull(Engine.GetMatchingService():GetSession()) and not mGameRules:IsPlayingOffline() then
    return
  end
  ClearMissionList(movie)
  FlashMethod(movie, "OptionList.ListClass.SetAlignment", "right")
  if mNumRegions == 0 then
    return
  end
  local theRegion = mGameRules:GetRegion(mSelectedRegion)
  local theRegionName = theRegion.regionName
  local numMissions = theRegion:NumMissions()
  if not mGameRules:IsRegionUnlocked(mSelectedRegion) then
    numMissions = 0
  end
  mActiveRegionCompletionStates = {}
  if 0 < numMissions then
    for i = 0, numMissions - 1 do
      mActiveRegionCompletionStates[i + 1] = false
      local thisMission = theRegion:GetMission(i)
      if not mGameRules:IsMissionAvailable(mSelectedRegion, i) then
        FlashMethod(movie, "OptionList.ListClass.AddItem", "/D2/Language/MPGame/MissionSelect_Locked")
      else
        FlashMethod(movie, "OptionList.ListClass.AddItem", string.format("/D2/Language/MPGame/MissionName_%s_%s", theRegion.regionName, thisMission.missionName))
        local isCompleted = mGameRules:IsMissionCompleted(mSelectedRegion, i)
        if isCompleted then
          movie:SetVariable(string.format("Strikes.ObjStrike%i._visible", i), true)
          local textWidth = movie:GetVariable(string.format("OptionList.ButtonLabel%i.TxtHolder.Txt.textWidth", i))
          movie:SetVariable(string.format("Strikes.ObjStrike%i._width", i), textWidth)
        end
        mActiveRegionCompletionStates[i + 1] = isCompleted
      end
    end
  end
  FlashMethod(movie, "OptionList.ListClass.SetPressedCallback", "ListButtonPressed")
  FlashMethod(movie, "OptionList.ListClass.SetUnselectedCallback", "ListButtonUnselected")
  FlashMethod(movie, "OptionList.ListClass.SetSelectedCallback", "ListButtonSelected")
  FlashMethod(movie, "OptionList.ListClass.SetSelected", 0)
  if mSelectedRegion == mActiveRegionIdx then
    local optionListY = movie:GetVariable("OptionList._y")
    local itemY = movie:GetVariable(string.format("OptionList.ButtonLabel%i._y", mActiveMissionIdx))
    local selectedMissionY = optionListY + itemY + 22
    movie:SetVariable("SelectedMission._y", selectedMissionY)
    movie:SetVariable("SelectedMission._visible", true)
  end
  UpdateDescriptionPane(movie, 0)
end
local function UpdateScrollButtons(movie, dir)
  movie:SetVariable("ScrollRight._visible", mSelectedRegion + -dir + 1 < mNumRegions)
  movie:SetVariable("ScrollLeft._visible", 1 <= mSelectedRegion + -dir)
end
function Initialize(movie)
  movie:SetTexture("BinkPlaceholder.png", binkTexture)
  gRegion:StartVideoTexture(binkTexture)
  if not Engine.GetPlayerProfileMgr():IsLoggedIn() then
    Engine.GetPlayerProfileMgr():LogIn(1, false, false, LIB.GetActiveControllerIndex(movie))
  end
  FlashMethod(movie, "Initialize")
  mGameRules = gRegion:GetGameRules()
  mMissionToSelect = -1
  mActiveRegionIdx = -1
  mActiveMissionIdx = -1
  FindActiveRegionAndMission(movie)
  mSelectedRegion = mActiveRegionIdx
  mAnimation = {
    speed = 825,
    direction = 0,
    remaining = 0
  }
  mRegionImage.NorthSideProjects = "Luigi"
  mRegionImage.FranksJunkyard = "FrankMarshall"
  mRegionImage.BroadsidePaperworks = "CedroV"
  mRegionImage.NewsWatch6Building = "NewsTeam"
  mRegionImage.AbandonedTrainDepot = "AlexanderDrakos"
  mRegionImage.OldEastDocks = "JeanLucEmilie"
  mRegionImage.GentlemensClub = "Mario"
  mRegionImage.ManhattanTrust = "Graves"
  if Engine.GetMatchingService():IsHost() == true or mGameRules:IsPlayingOffline() then
    mIsHost = true
  else
    mIsHost = false
  end
  FlashMethod(movie, "MenuBackgroundClip.gotoAndStop", "SideMenuPosition")
  PopulateRegionList(movie)
  PopulateMissionList(movie)
  UpdateScrollButtons(movie, 0)
  for i = 1, #statusList do
    FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", statusList[i], statusList[i] == statusBack)
  end
  FlashMethod(movie, "StatusBar.StatusBarClass.SetCallbackOnPress", "StatusButtonPressed")
  local levelInfo = gRegion:GetLevelInfo()
  local postProcess = levelInfo.postProcess
  originalScreenBlur = postProcess.focalNearPlane
  postProcess.focalNearPlane = 500
end
local function Exit(movie)
  gRegion:PlaySound(sndBack, Vector(), false)
  local levelInfo = gRegion:GetLevelInfo()
  local postProcess = levelInfo.postProcess
  postProcess.focalNearPlane = originalScreenBlur
  gRegion:StopVideoTexture(binkTexture)
  movie:SetMouseVisible(false)
  movie:Close()
end
local function Back(movie)
  Exit(movie)
end
local function SelectMission(movie)
  if not IsNull(mActivePopupMovie) then
    mActivePopupMovie:Close()
    mActivePopupMovie = nil
  end
  if 0 < mNumRegions then
    local theRegion = mGameRules:GetRegion(mSelectedRegion)
    local theMission = theRegion:GetMission(mMissionToSelect)
    local theMapName = theMission.level:GetResourceName()
    local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
    local profileSettings = playerProfile:Settings()
    local gameHostSettings = profileSettings:GetHostSettings()
    gameHostSettings:SetGameRules(theMission.gameRules)
    gameHostSettings:SetMap(theMapName)
    profileSettings:SetHostSettings(gameHostSettings)
    local mpSettings = mGameRules:GetMpSettings()
    mpSettings:SetGameRules(theMission.gameRules)
    mpSettings:SetMap(theMapName)
    mGameRules:UpdateSettings(mpSettings)
    PopulateRegionList(movie)
    PopulateMissionList(movie)
  end
  mMissionToSelect = -1
end
function MissionSelectionConfirmed(movie, args)
  if tonumber(args) == 0 then
    SelectMission(movie)
    Exit(movie)
  end
end
function ListButtonPressed(movie, buttonArg)
  local mission = tonumber(buttonArg)
  mMissionToSelect = mission
  if not mGameRules:IsMissionAvailable(mSelectedRegion, mission) then
    return
  end
  gRegion:PlaySound(sndSelect, Vector(), false)
  SelectMission(movie)
  Exit(movie)
end
function ListButtonUnselected(movie, buttonArg)
  if mSelectedRegion == nil then
    return
  end
  local missionIdx = tonumber(buttonArg)
  if mGameRules:IsMissionCompleted(mSelectedRegion, missionIdx) then
    movie:SetVariable("objectiveComplete" .. missionIdx .. "._color", 16777215)
  end
  UpdateStrikeAlpha(movie, missionIdx, false)
end
function ListButtonSelected(movie, buttonArg)
  gRegion:PlaySound(sndScroll, Vector(), false)
  if mSelectedRegion == nil or mNumRegions == 0 then
    return
  end
  local activeMissionIdx = -1
  local missionIdx = tonumber(buttonArg)
  UpdateDescriptionPane(movie, missionIdx)
end
function StatusButtonPressed(movie, buttonArg)
  local index = tonumber(buttonArg) + 1
  if statusList[index] == statusBack then
    Back(movie)
  end
end
function onKeyDown_MENU_CANCEL(movie)
  Back(movie)
end
local function Scroll(movie, dir)
  return LIB.ListClassVerticalScroll(movie, "OptionList", dir)
end
function onKeyDown_MENU_UP_FROM_ANALOG(movie)
  return Scroll(movie, -1)
end
function onKeyDown_MENU_UP(movie)
  return Scroll(movie, -1)
end
function onKeyDown_MENU_DOWN_FROM_ANALOG(movie)
  return Scroll(movie, 1)
end
function onKeyDown_MENU_DOWN(movie)
  return Scroll(movie, 1)
end
function Update(movie)
  if mAnimation == nil or mAnimation.speed == nil or mAnimation.direction == 0 then
    return
  end
  local rt = RealDeltaTime()
  local rate = mAnimation.direction * (mAnimation.speed * rt)
  local longMover = mSelectedRegion + 2
  if mAnimation.direction == 1 then
    longMover = mSelectedRegion + 1
  end
  for i = 1, mNumRegions do
    mRegions[i].x = mRegions[i].x + rate
    if i == longMover then
      mRegions[i].x = mRegions[i].x + rate * 2
    end
    movie:SetVariable(string.format("Target%i._x", i - 1), mRegions[i].x)
  end
  mAnimation.remaining = mAnimation.remaining - math.abs(rate)
  if 0 >= mAnimation.remaining then
    mSelectedRegion = mSelectedRegion + -mAnimation.direction
    SnapRegionPositions(movie)
    PopulateMissionList(movie)
    mAnimation.direction = 0
  end
end
local function ChangeRegion(movie, dir)
  if mAnimation.direction ~= 0 then
    return true
  end
  gRegion:PlaySound(sndScrollTarget, Vector(), false)
  UpdateScrollButtons(movie, dir)
  if mSelectedRegion == 0 and dir == 1 then
    return true
  elseif mSelectedRegion + 1 == mNumRegions and dir == -1 then
    return true
  end
  ClearMissionList(movie)
  movie:SetVariable("Description.text", "")
  movie:SetVariable("TargetDescFrame._visible", false)
  movie:SetVariable("TargetDescFrame.TargetDescription.text", "")
  SetRegionSelected(movie, mSelectedRegion, false)
  mAnimation.direction = dir
  mAnimation.remaining = mCardSpacing
  SetRegionSelected(movie, mSelectedRegion + -dir, true)
  return true
end
function ScrollLeft(movie)
  ChangeRegion(movie, 1)
end
function ScrollRight(movie)
  ChangeRegion(movie, -1)
end
function onKeyDown_MENU_LEFT_FROM_ANALOG(movie)
  return ChangeRegion(movie, 1)
end
function onKeyDown_MENU_LEFT(movie)
  return ChangeRegion(movie, 1)
end
function onKeyDown_MENU_RIGHT_FROM_ANALOG(movie)
  return ChangeRegion(movie, -1)
end
function onKeyDown_MENU_RIGHT(movie)
  return ChangeRegion(movie, -1)
end

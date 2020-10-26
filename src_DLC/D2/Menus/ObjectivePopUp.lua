local LIB = require("D2.Menus.SharedLibrary")
objectiveDuration = 7
objectiveWaitBeforeRedisplay = 30
mObjectiveRedisplayAfterWait = false
mpNameClip = 45
mpNameX = 450
mpNameY = 290
movieHUD = WeakResource()
avatarRandomized = WeakResource()
loadingMovie = WeakResource()
popupSound = Resource()
enemyFactions = {
  Symbol()
}
local OBJECTIVETYPE_Active = 1
local OBJECTIVETYPE_Completed = 2
local OBJECTIVETYPE_Ignore = 3
local OBJECTIVESTATE_Hide = 0
local OBJECTIVESTATE_FadeIn = 1
local OBJECTIVESTATE_Show = 2
local OBJECTIVESTATE_FadeOut = 3
local OBJECTIVE_Colour = 16777215
local OBJECTIVE_Name = "/D2/Language/Menu/HUD_Objective"
local ARROWTYPE_TeamMember = 0
local ARROWTYPE_Objective = 1
local ARROWTYPE_ObjectiveCoop = 2
local ARROWTYPE_TrackedNPC = 4
local COLOR_Reviving = 16711680
local STAGE_Width = 1280
local STAGE_Height = 720
local STAGE_Centre = Vector(STAGE_Width / 2, STAGE_Height / 2, 0)
local STATE_None = 0
local STATE_ReviveStart = 1
local STATE_ReviveReset = 2
local STATE_ReviveFadeOut = 3
local STATE_ReviveWaiting = 4
local mLocalPlayers = {}
local mMaxHumanPlayersLastFrame = 0
local mGameRules
local mLastDamageTimeLeft = {0}
local mLastDamagePos = {
  Vector()
}
local mLastDamageVisibleEntries = 0
local mIsMultiplayer = false
local mIsHost = false
local mInPauseMenu = false
local mMaxDisplayableObjectives = 0
local mObjectiveList = {}
local mObjectiveField = {}
local mObjectiveDisplayQueue = {}
local mObjectiveTotalVisible = 0
local mNeedObjectiveArrowUpdate = false
local mNeedNpcObjectiveArrowUpdate = false
local mForceObjectivesVisible = true
local mNumTrackedObjects = 0
local mObjectiveTitle
local mObjective3DArrowScrPos = {}
local mObjective3DCoopArrowScrPos = {}
local mTeam3DArrowScrPos = {}
local mMaxDisplayableTeamNames = 0
local mGameOptionHudVisible
local mVisibleStates = {}
local mLocRiviving = "/D2/Language/Menu/HUD_Reviving"
local mMPList = {}
local mHUDInstance
local mZeroVector = Vector()
local mCoopVis
local mLoadingScreenVisible = false
local mPopupSoundInstance
local mIsTrackingAliveAvatars = false
local mAvatarProcessListSize = 0
local mFrameCount = 0
local mMetreStrFormat = ""
local TRACKED_NPC_ARROW_ID = 4
local PlaySound = function(sound)
  gRegion:PlaySound(sound, Vector(), false)
end
local function InitializeObjectiveData()
  mMaxDisplayableObjectives = 0
  mObjectiveField = {}
  mObjectiveDisplayQueue = {}
  mObjectiveTotalVisible = 0
  mObjectiveList = {}
end
function SetMaxDisplayableTeamNames(movie, maxDisplayableTeamNames)
  mMaxDisplayableTeamNames = maxDisplayableTeamNames
end
function Initialize(movie)
  mMetreStrFormat = movie:GetLocalized("/D2/Language/MPGame/HUD_Metre")
  mInPauseMenu = false
  mObjectiveTitle = nil
  mAvatarProcessListSize = 0
  mVisibleStates[ARROWTYPE_TeamMember] = {
    list = {}
  }
  mVisibleStates[ARROWTYPE_Objective] = {
    list = {}
  }
  mVisibleStates[ARROWTYPE_ObjectiveCoop] = {
    list = {}
  }
  mVisibleStates[ARROWTYPE_TrackedNPC] = {
    list = {}
  }
  mFrameCount = 0
  if Engine.GetMatchingService():GetState() == 0 then
    mIsMultiplayer = false
  else
    mIsMultiplayer = true
    if Engine.GetMatchingService():IsHost() == true then
      mIsHost = true
    else
      mIsHost = false
    end
  end
  mLocalPlayers = gRegion:ScriptGetLocalPlayers()
  mGameRules = gRegion:GetGameRules()
  mLoadingScreenVisible = not IsNull(loadingMovie) and not IsNull(gFlashMgr:FindMovie(loadingMovie))
  mMaxHumanPlayersLastFrame = 0
  InitializeObjectiveData()
  mObjective3DArrowScrPos = {}
  mObjective3DCoopArrowScrPos = {}
  mTeam3DArrowScrPos = {}
  mMaxDisplayableTeamNames = 0
  mMPList = {}
  mZeroVector = Vector(0, 0, 0)
  mCoopVis = nil
  mLocRiviving = movie:GetLocalized(mLocRiviving)
  movie:SetLocalized("ObjectivePane.ObjectiveTitle.Container.Text.text", movie:GetLocalized("/D2/Language/Menu/HUD_ObjectivesTitle"))
  FlashMethod(movie, "InitializeMovie")
  for i = 1, 9 do
    FlashMethod(movie, "InitArrowNamePos", ARROWTYPE_Objective, i, false, OBJECTIVE_Colour, false, false, 0, OBJECTIVE_Name)
  end
  mMaxDisplayableObjectives = tonumber(movie:GetVariable("mMaxDisplayableObjectives"))
  for i = 1, mMaxDisplayableObjectives do
    mObjectiveField[i] = {
      state = OBJECTIVESTATE_Hide,
      timeLeft = 0,
      key = "",
      objectiveState = -1
    }
  end
  FlashMethod(movie, "SetObjectiveVisible", true)
  mForceObjectivesVisible = true
end
function ObjectiveTitleFadeIn(movie)
  mObjectiveTitle = OBJECTIVESTATE_FadeIn
end
function ObjectiveTitleShow(movie)
  mObjectiveTitle = OBJECTIVESTATE_Show
end
function ObjectiveTitleFadeOut(movie)
  mObjectiveTitle = OBJECTIVESTATE_FadeOut
end
function ObjectiveTitleHide(movie)
  mObjectiveTitle = OBJECTIVESTATE_Hide
end
function GamePausedHideObjectives(movie)
  movie:SetVariable("ObjectivePane._visible", false)
  mInPauseMenu = true
end
function GameResumedShowObjectives(movie)
  movie:SetVariable("ObjectivePane._visible", true)
  mInPauseMenu = false
end
function ObjectiveAnimationIdle(movie, index)
  local idx = tonumber(index)
  if mObjectiveField[idx].state == OBJECTIVESTATE_FadeIn then
    mObjectiveField[idx].state = OBJECTIVESTATE_Show
    for j = 1, #mObjectiveField do
      if mObjectiveField[j].state == OBJECTIVESTATE_Show then
        mObjectiveField[j].timeLeft = objectiveDuration
      end
    end
    FlashMethod(movie, "ObjectiveAnimationIdle", idx)
  end
end
function ObjectiveAnimationDone(movie, index)
  local idx = tonumber(index)
  mObjectiveField[idx].state = OBJECTIVESTATE_Hide
  mObjectiveField[idx].key = ""
end
function ForceShowCurrentObjective(movie)
  mForceObjectivesVisible = true
  return true
end
local function UpdateDisplayArrow(movie, myAvatar, arrowType, slotIdx, worldPos, clampToEllipse, name, nameColor, text, show)
  if IsNull(myAvatar) then
    return
  end
  local myPos = myAvatar:GetSimPosition()
  local myFacingView = myAvatar:GetView()
  local vis = false
  local arrowVis = false
  local screenPos = Vector()
  local arrowAngle = 0
  local distX = worldPos.x - myPos.x
  local distY = worldPos.z - myPos.z
  local planarDistance = distX * distX + distY * distY
  if planarDistance < 1.0E-4 then
    return
  end
  local dir = AngleTo(myPos, myFacingView, worldPos)
  if math.abs(dir) < mpNameClip then
    vis = show
  end
  screenPos = movie:ProjectPosition(worldPos)
  local wasClampedToEdges = false
  if clampToEllipse then
    arrowVis = show
    vis = show
    if dir < -90 and -180 < dir then
      screenPos.x = 0
      screenPos.y = STAGE_Centre.y
    elseif 90 < dir and dir <= 180 then
      screenPos.x = STAGE_Width
      screenPos.y = STAGE_Centre.y
    end
    local centreToScreenLocation = screenPos - STAGE_Centre
    local xRatio = centreToScreenLocation.x * centreToScreenLocation.x / (mpNameX * mpNameX)
    local yRatio = centreToScreenLocation.y * centreToScreenLocation.y / (mpNameY * mpNameY)
    if 1 < xRatio + yRatio then
      local radial = math.sqrt(1 / (xRatio + yRatio))
      local newX = STAGE_Centre.x + centreToScreenLocation.x * radial
      local newY = STAGE_Centre.y + centreToScreenLocation.y * radial
      if math.abs(newX - STAGE_Centre.x) < math.abs(screenPos.x - STAGE_Centre.x) then
        screenPos.x = newX
        wasClampedToEdges = true
      end
      if math.abs(newY - STAGE_Centre.y) < math.abs(screenPos.y - STAGE_Centre.y) then
        screenPos.y = newY
        wasClampedToEdges = true
      end
      arrowAngle = math.deg(math.atan2(screenPos.x - STAGE_Centre.x, STAGE_Centre.y - screenPos.y))
    else
      arrowAngle = 180
    end
  end
  screenPos.x = math.floor(screenPos.x)
  screenPos.y = math.floor(screenPos.y)
  screenPos.z = 0
  local state = 0
  local prevPos
  if arrowType == ARROWTYPE_Objective then
    prevPos = mObjective3DArrowScrPos[slotIdx + 1]
    if wasClampedToEdges then
      text = ""
    else
      local d = Distance(worldPos, myPos)
      d = Clamp(d, 1, 999)
      text = string.format(mMetreStrFormat, d)
    end
  elseif arrowType == ARROWTYPE_TeamMember then
    prevPos = mTeam3DArrowScrPos[slotIdx + 1]
    state = mMPList[name].state
    if mMPList[name].isPreDeath then
      if state == STATE_None then
        state = STATE_ReviveWaiting
        mMPList[name].state = STATE_ReviveWaiting
      end
    else
      mMPList[name].state = STATE_None
    end
    if wasClampedToEdges then
      text = ""
    end
  elseif arrowType == ARROWTYPE_ObjectiveCoop then
    prevPos = mObjective3DCoopArrowScrPos[slotIdx + 1]
    if wasClampedToEdges then
      text = ""
    end
  elseif arrowType == ARROWTYPE_TrackedNPC then
    prevPos = mObjective3DArrowScrPos[slotIdx + 1]
    text = ""
  end
  local prevVis = mVisibleStates[arrowType].list[slotIdx]
  if prevVis == nil then
    mVisibleStates[arrowType].list[slotIdx] = vis
    prevVis = not vis
  end
  local prevVisDiff = vis ~= prevVis
  local prevPosDiff = prevPos ~= screenPos
  if prevPosDiff or prevVisDiff then
    mVisibleStates[arrowType].list[slotIdx] = vis
    FlashMethod(movie, "SetArrowNamePos", arrowType, slotIdx, vis, screenPos.x, screenPos.y, nameColor, arrowAngle, arrowVis, text, wasClampedToEdges, state)
    local d = math.sqrt(planarDistance)
    local mcName
    if arrowType == 0 then
      mcName = "Team0"
    else
      mcName = "ObjectiveArrow"
    end
    movie:SetVariable(string.format("_root.%s.Member%i._z", mcName, slotIdx), d)
    if arrowType == ARROWTYPE_Objective then
      mObjective3DArrowScrPos[slotIdx + 1] = screenPos
    elseif arrowType == ARROWTYPE_TeamMember then
      mTeam3DArrowScrPos[slotIdx + 1] = screenPos
    elseif arrowType == ARROWTYPE_ObjectiveCoop then
      mObjective3DCoopArrowScrPos[slotIdx + 1] = screenPos
    elseif arrowType == ARROWTYPE_TrackedNPC then
      mObjective3DArrowScrPos[slotIdx + 1] = screenPos
    end
  end
end
local _IsEnemy = function(faction)
  for _, value in ipairs(enemyFactions) do
    if value == faction then
      return true
    end
  end
  return false
end
local function _UpdateTrackedObjectives(movie, gameState, teamId, onlyUpdateAvatars, show)
  show = tonumber(show)
  if show == 1 then
    show = true
  else
    show = false
  end
  local myAvatar = mLocalPlayers[1]:GetAvatar()
  if IsNull(myAvatar) then
    return
  end
  local numTrackedPoints = gameState:GetNumTrackedObjects()
  local objectiveForPoint
  local hadAnyTrackedNpc = false
  if not onlyUpdateAvatars then
    for i = 1, numTrackedPoints do
      local trackedObject = gameState:GetTrackedObject(i - 1)
      local objectiveArrowType = ARROWTYPE_Objective
      if not IsNull(trackedObject) then
        local trackedPos = myAvatar:GetTrackedPosition(trackedObject)
        local showThis = show
        if trackedPos == mZeroVector then
          showThis = false
        end
        UpdateDisplayArrow(movie, myAvatar, objectiveArrowType, i, trackedPos, showThis, OBJECTIVE_Name, OBJECTIVE_Colour, OBJECTIVE_Name, showThis)
      else
        UpdateDisplayArrow(movie, myAvatar, objectiveArrowType, i, Vector(), false, OBJECTIVE_Name, OBJECTIVE_Colour, "", false)
      end
    end
  end
  if gameState:IsTrackingAllAliveAvatars() then
    local avatars = gRegion:GetAvatars()
    local lastSlotIndex = numTrackedPoints
    local numTrackedAvatars = 0
    for i = 1, #avatars do
      local av = avatars[i]
      if not av or IsNull(av) or av:IsKilled() or not _IsEnemy(av:GetFaction()) then
      else
        local showThis = true
        local trackedPos = av:EyePosition()
        local slotIndex = TRACKED_NPC_ARROW_ID + numTrackedAvatars
        numTrackedAvatars = numTrackedAvatars + 1
        lastSlotIndex = slotIndex
        UpdateDisplayArrow(movie, myAvatar, ARROWTYPE_TrackedNPC, slotIndex, trackedPos, showThis, OBJECTIVE_Name, OBJECTIVE_Colour, OBJECTIVE_Name, showThis)
        hadAnyTrackedNpc = true
      end
    end
    numTrackedPoints = lastSlotIndex
  end
  local maxTrackedPoints = 16
  for i = numTrackedPoints + 1, maxTrackedPoints do
    UpdateDisplayArrow(movie, myAvatar, ARROWTYPE_Objective, i, Vector(), false, OBJECTIVE_Name, OBJECTIVE_Colour, OBJECTIVE_Name, false)
  end
  mNeedNpcObjectiveArrowUpdate = hadAnyTrackedNpc
  return true
end
local function UpdateObjectives(movie, teamId, deltaTime)
  if IsNull(mGameRules) then
    return
  end
  gameState = mGameRules:GetGameState(teamId)
  if IsNull(gameState) then
    return
  end
  local objectiveCurCount = {active = 0, completed = 0}
  objectiveCurCount.active = tonumber(gameState:GetNumObjectives(OBJECTIVETYPE_Active - 1))
  objectiveCurCount.completed = tonumber(gameState:GetNumObjectives(OBJECTIVETYPE_Completed - 1))
  if mLoadingScreenVisible then
    mLoadingScreenVisible = not IsNull(loadingMovie) and not IsNull(gFlashMgr:FindMovie(loadingMovie))
    return
  end
  local totalVisible = 0
  local availableIdx = 1
  local availableFields = {}
  for i = 1, mMaxDisplayableObjectives do
    local thisField = mObjectiveField[i]
    if thisField.state == OBJECTIVESTATE_Hide then
      availableFields[#availableFields + 1] = i
    elseif thisField.state == OBJECTIVESTATE_Show then
      mObjectiveField[i].timeLeft = mObjectiveField[i].timeLeft - deltaTime
      if 0 >= mObjectiveField[i].timeLeft then
        mObjectiveField[i].state = OBJECTIVESTATE_FadeOut
        FlashMethod(movie, "RemoveObjective", i)
      end
    end
    if thisField.state == OBJECTIVESTATE_Show or thisField.state == OBJECTIVESTATE_FadeIn then
      totalVisible = totalVisible + 1
    end
  end
  local maxObjectives = objectiveCurCount.active
  if maxObjectives < objectiveCurCount.completed then
    maxObjectives = objectiveCurCount.completed
  end
  for i = 1, maxObjectives do
    local thisObjective
    if objectiveCurCount.active > 0 and i <= objectiveCurCount.active then
      thisObjective = tostring(gameState:GetObjectiveByIndex(OBJECTIVETYPE_Active - 1, i - 1))
      if IsNull(mObjectiveList[thisObjective]) then
        mObjectiveList[thisObjective] = {state = OBJECTIVETYPE_Active, timeLeft = 0}
        mObjectiveDisplayQueue[thisObjective] = OBJECTIVETYPE_Active
      elseif mObjectiveList[thisObjective].state == OBJECTIVETYPE_Active then
        mObjectiveList[thisObjective].timeLeft = mObjectiveList[thisObjective].timeLeft - deltaTime
        if mForceObjectivesVisible or 0 >= mObjectiveList[thisObjective].timeLeft and mObjectiveRedisplayAfterWait then
          mObjectiveList[thisObjective].timeLeft = objectiveWaitBeforeRedisplay
          mObjectiveDisplayQueue[thisObjective] = OBJECTIVETYPE_Active
        end
      end
    end
    if 0 < objectiveCurCount.completed and i <= objectiveCurCount.completed then
      thisObjective = tostring(gameState:GetObjectiveByIndex(OBJECTIVETYPE_Completed - 1, i - 1))
      local objectiveSymbol = Symbol(thisObjective)
      if IsNull(mObjectiveList[thisObjective]) then
      elseif mObjectiveList[thisObjective].state ~= OBJECTIVETYPE_Completed and gameState:GetVariable(objectiveSymbol) == 0 then
        mObjectiveList[thisObjective].state = OBJECTIVETYPE_Completed
        mObjectiveDisplayQueue[thisObjective] = OBJECTIVETYPE_Completed
        gameState:SetVariable(objectiveSymbol, 1)
      end
    end
  end
  local visibleFieldIdx = 1
  local playedSound = false
  for key, value in pairs(mObjectiveDisplayQueue) do
    local screenVisibleFieldIdx = -1
    if value == OBJECTIVETYPE_Ignore then
    else
      if visibleFieldIdx > #availableFields then
        break
      end
      local alreadyAdded = false
      for i = 1, #mObjectiveField do
        if key == mObjectiveField[i].key then
          if mObjectiveList[key].state ~= mObjectiveField[i].objectiveState then
            screenVisibleFieldIdx = i
            break
          end
          alreadyAdded = true
          break
        end
      end
      if not alreadyAdded then
        if screenVisibleFieldIdx < 0 then
          screenVisibleFieldIdx = availableFields[visibleFieldIdx]
          visibleFieldIdx = visibleFieldIdx + 1
        end
        mObjectiveField[screenVisibleFieldIdx].state = OBJECTIVESTATE_FadeIn
        mObjectiveField[screenVisibleFieldIdx].timeLeft = 0
        mObjectiveField[screenVisibleFieldIdx].key = key
        mObjectiveField[screenVisibleFieldIdx].objectiveState = mObjectiveList[key].state
        FlashMethod(movie, "AddObjective", screenVisibleFieldIdx, key, value == OBJECTIVETYPE_Completed)
        mObjectiveDisplayQueue[key] = OBJECTIVETYPE_Ignore
        totalVisible = totalVisible + 1
        if not IsNull(popupSound) and IsNull(mPopupSoundInstance) and not playedSound then
          playedSound = true
          mPopupSoundInstance = gRegion:PlaySound(popupSound, Vector(), false)
        end
      end
    end
  end
  local numTrackedPoints = gameState:GetNumTrackedObjects()
  local trackingAvatars = gameState:IsTrackingAllAliveAvatars()
  mNeedNpcObjectiveArrowUpdate = trackingAvatars ~= mIsTrackingAliveAvatars or mIsTrackingAliveAvatars
  mIsTrackingAliveAvatars = trackingAvatars
  if totalVisible ~= mObjectiveTotalVisible then
    mNeedObjectiveArrowUpdate = 0 < totalVisible
    local show = 0
    if 0 < totalVisible then
      show = 1
    end
    _UpdateTrackedObjectives(movie, gameState, 0, false, show)
    local objectivesVis
    if totalVisible == 0 then
      objectivesVis = "0"
      if mObjectiveTitle ~= OBJECTIVESTATE_FadeOut and mObjectiveTitle ~= OBJECTIVESTATE_Hide then
        FlashMethod(movie, "ObjectivePane.ObjectiveTitle.gotoAndPlay", "FadeOut")
      end
    elseif mObjectiveTitle ~= OBJECTIVESTATE_FadeIn and mObjectiveTitle ~= OBJECTIVESTATE_Show then
      objectivesVis = "1"
      FlashMethod(movie, "ObjectivePane.ObjectiveTitle.gotoAndPlay", "FadeIn")
    end
    if IsNull(mHUDInstance) then
      mHUDInstance = gFlashMgr:FindMovie(movieHUD)
    end
    mHUDInstance:Execute("NotifyObjectivesPopupVisible", objectivesVis)
    mObjectiveTotalVisible = totalVisible
  elseif mNeedObjectiveArrowUpdate or mNeedNpcObjectiveArrowUpdate then
    _UpdateTrackedObjectives(movie, gameState, 0, not mNeedObjectiveArrowUpdate, 1)
  end
  mForceObjectivesVisible = false
end
local NewMPListEntry = function()
  return {isPreDeath = false, state = 0}
end
local function UpdateMpNameList(movie, myAvatar, inputControl, hudStatus)
  local humanPlayers = gRegion:GetHumanPlayers()
  local myPos = myAvatar:GetSimPosition()
  local myFacingView = myAvatar:GetView()
  local COLOR_LIVING = 16777215
  local COLOR_DEAD = 16711680
  local worldPos = Vector()
  if mMaxHumanPlayersLastFrame ~= #humanPlayers then
    FlashMethod(movie, "HideArrowNamePos", ARROWTYPE_TeamMember)
    mMaxHumanPlayersLastFrame = #humanPlayers
    for i = 1, mMaxDisplayableTeamNames do
      local show = true
      local name = ""
      local col = COLOR_LIVING
      if i > mMaxHumanPlayersLastFrame or humanPlayers[i]:IsLocal() then
        show = false
        col = nil
      else
        name = humanPlayers[i]:GetPlayerName()
      end
      FlashMethod(movie, "InitArrowNamePos", ARROWTYPE_TeamMember, i, show, col, false, false, 0, name)
      mMPList[name] = NewMPListEntry()
    end
    return
  end
  local avatarProcessList = {}
  local numHumans = #humanPlayers
  for i = 1, numHumans do
    local thisHP = humanPlayers[i]
    if thisHP:IsLocal() then
    else
      avatarProcessList[#avatarProcessList + 1] = {
        name = thisHP:GetPlayerName(),
        avatar = thisHP:GetAvatar()
      }
    end
  end
  local ic = myAvatar:ScriptInventoryControl()
  local weaponMode = ic:GetWeaponMode()
  local mainHandWeapon = ic:GetWeaponInHand(Engine.MAIN_HAND)
  local offHandWeapon = ic:GetWeaponInHand(Engine.OFF_HAND)
  local hasWeapons = not IsNull(mainHandWeapon) or not IsNull(offHandWeapon)
  local avatarProcessListSize = #avatarProcessList
  if 0 < avatarProcessListSize and avatarProcessListSize < mAvatarProcessListSize then
    for i = avatarProcessListSize, mAvatarProcessListSize do
      if i > avatarProcessListSize then
        FlashMethod(movie, "SetArrowNamePos", ARROWTYPE_TeamMember, i, false, 0, 0, 16777215, 0, false, " ", false, 0)
      end
    end
  end
  mAvatarProcessListSize = avatarProcessListSize
  for i = 1, avatarProcessListSize do
    local colour = COLOR_LIVING
    local toProcess = avatarProcessList[i]
    if IsNull(toProcess.avatar) then
    else
      local show = true
      local worldPos = toProcess.avatar:GetSimPosition()
      worldPos.y = worldPos.y + toProcess.avatar:GetHeight()
      local progVis = false
      local dc = toProcess.avatar:DamageControl()
      local isPreDeath = dc:IsPreDeath()
      local hasPreDeathStateChanged = mMPList[toProcess.name].isPreDeath ~= isPreDeath
      if isPreDeath then
        colour = COLOR_DEAD
      end
      if 0 >= toProcess.avatar:GetHealth() then
        show = false
      end
      if IsNull(mMPList[toProcess.name]) then
      else
        if hasPreDeathStateChanged then
          if isPreDeath then
            mMPList[toProcess.name].state = STATE_ReviveStart
          else
            mMPList[toProcess.name].state = STATE_ReviveReset
          end
          mMPList[toProcess.name].isPreDeath = isPreDeath
        end
        local visibleName = toProcess.name
        if isPreDeath then
          local d = Distance(worldPos, myPos)
          d = Clamp(d, 1, 999)
          visibleName = visibleName .. string.format(" %3.0fm", d)
        end
        UpdateDisplayArrow(movie, myAvatar, ARROWTYPE_TeamMember, i, worldPos, isPreDeath, toProcess.name, colour, visibleName, show)
      end
    end
  end
  if mIsMultiplayer then
    local COOP_ARROW_ID = 8
    local coOpObjectivePos = hudStatus:GetCoopObjectivePosition()
    local coopVis = coOpObjectivePos ~= mZeroVector
    local d = Distance(coOpObjectivePos, myPos)
    d = Clamp(d, 1, 999)
    local visibleName = string.format("%3.0fm", d)
    if coopVis ~= mCoopVis or coopVis then
      UpdateDisplayArrow(movie, myAvatar, ARROWTYPE_ObjectiveCoop, COOP_ARROW_ID, coOpObjectivePos, coopVis, "ObjectiveCoop", 16777215, visibleName, coopVis)
    end
    mCoopVis = coopVis
  end
end
function Update(movie)
  local deltaTime = DeltaTime()
  if mLocalPlayers == nil or IsNull(mLocalPlayers[1]) then
    return
  end
  if mFrameCount == 0 and not mNeedObjectiveArrowUpdate then
    mFrameCount = mFrameCount + 1
    return
  end
  mFrameCount = 0
  local myAvatar = mLocalPlayers[1]:GetAvatar()
  UpdateObjectives(movie, mLocalPlayers[1]:GetTeam(), deltaTime)
  if not IsNull(myAvatar) then
    local inputControl = myAvatar:InputControl()
    local hudStatus = mLocalPlayers[1]:GetHudStatus()
    UpdateMpNameList(movie, myAvatar, inputControl, hudStatus)
  end
end

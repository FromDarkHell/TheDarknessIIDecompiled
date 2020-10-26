local LIB = require("D2.Menus.SharedLibrary")
npcAgent = WeakResource()
avatarCrawling = WeakResource()
avatarD2Avatar = WeakResource()
avatarJackie = WeakResource()
avatarJackieCinematic = WeakResource()
avatarWalkInAvatar = WeakResource()
avatarLightSensitive = WeakResource()
avatarRandomized = WeakResource()
avatarDarkling = WeakResource()
d2Shotgun = WeakResource()
d2InventoryController = WeakResource()
hitProxyUnbreakableLight = WeakResource()
neutralFaction = Symbol()
pickupAction = WeakResource()
timeTrackActions = {
  WeakResource()
}
DemonArmGrabTapXToBreakAction = WeakResource()
weaponEx = WeakResource()
weaponMelee = WeakResource()
demoGameRulesPAX = WeakResource()
movieObjectives = Resource()
movieConversation = Resource()
movieExecution = Resource()
movieSubTitle = Resource()
movieDialogPopupW = WeakResource()
movieChatWindowW = WeakResource()
healthOverlayBloodRangeMin = 0
healthOverlayBloodRangeMax = 100
healthOverlayBloodAlphaMin = 50
healthOverlayBloodAlphaMax = 100
healthOverlayTintRangeMin = 0
healthOverlayTintRangeMax = 100
healthOverlayTintAlphaMin = 50
healthOverlayTintAlphaMax = 100
damageIndicatorDuration = 2
damageIndicatorTotalUsed = 5
mEssenceOffsetX = 0
mEssenceOffsetY = -30
sndEssenceReceived = Resource()
sndView = Resource()
local WEAPONHAND_Left = 0
local WEAPONHAND_Right = 1
local LIGHTSTATE_Invalid = -1
local LIGHTSTATE_InDarkness = 0
local LIGHTSTATE_InLight = 1
local POWERSTATE_Invalid = -1
local POWERSTATE_NotEnoughPower = 0
local POWERSTATE_Activated = 1
local POWERSTATE_Deactivating = 2
local POWER_Invalid = -1
local HEALTH_Invalid = -1
local RETICULETYPE_Invalid = -2
local RETICULETYPE_Dynamic = -1
local RETICULETYPE_DemonArm = 0
local RETICULETYPE_Unbreakable = 1
local RETICULETYPE_Grab = 2
local RETICULETYPE_Friendly = 3
local COLOR_Reviving = 16711680
local STAGE_Width = 1120
local STAGE_Height = 584
local STAGE_Centre = Vector(STAGE_Width / 2, STAGE_Height / 2, 1)
local DAMAGEINDICATOR_Total = 8
local WEAPONS_INVALID = -1
local WEAPONS_ENABLE = 0
local WEAPONS_DISABLE = 1
local WEAPONS_LOWERED = 2
local POSTURE_Zoom = 1
local mLocalPlayers = {}
local mHudStatus, mMovieObjective, mMovieSubTitle, mMovieChatWindow, mTargetEntity
local mTargetEntityValid = false
local mMaxHumanPlayersLastFrame = 0
local mContextActions = {}
local mGameRules
local mHasDarkArmour = false
local mHasIronHeart = false
local mIsJP = false
local mAvatar
local mAvatarIsValid = false
local mAvatarIsD2Avatar = false
local mAvatarIsLightSensitive = false
local mAvatarIsJackie = false
local mAvatarIsInugami = false
local mAvatarIsJimmy = false
local mAvatarIsShoshanna = false
local mAvatarIsJPDumond = false
local mAvatarIsCrawling = false
local mAvatarIsWalkInAvatar = false
local mAvatarIsCinematicJackie = false
local mAvatarIsDarkling = false
local mInventoryController
local mAvatarProperties = {}
local mICIsD2 = false
local mCombo = {}
local mActiveGameState = {}
local mEssence = {}
local mLastDamageTimeLeft = {0}
local mLastDamagePos = {
  Vector()
}
local mLastDamageVisibleEntries = 0
local mIsMultiplayer = false
local mIsHost = false
local mMaxDisplayableEvents, mNumEventMessages
local mDarknessPowers = {}
local mDarknessPowerOff = false
local mDarknessAuraString = ""
local mDarknessAuraY = 0
local mAdaptiveTraining = {}
local mGunChannelingState = 0
local mGunChannelingPrevState = 0
local mPower
local mPowerModifierDown = false
local mPowersForcedOff = false
local mLightState = LIGHTSTATE_Invalid
local mLivingStatus = {}
local mGlobalFade = {}
local mWeaponInfo = {}
local mIsDualWield
local mWeaponInventory = {
  state,
  isSwitching,
  isContextAction,
  ca = {
    item,
    queuedItem,
    queuedPickUp
  },
  selectedIndex,
  queuedIndex,
  weaponSlot0Icon,
  weaponSlot0Name,
  weaponSlot1Icon,
  weaponSlot1Name,
  weaponSlot2Icon,
  weaponSlot2Name,
  weaponSlot3Icon,
  weaponSlot3Name,
  history = {},
  forceUpdate
}
local mReticule = {}
local mWeapons = {}
local mWeaponAmmoCounterVis
local mHasWeapons = false
local mHealth = {}
local mBossHealth = {}
local mBossHealthNumActive = 0
local mPreDeathRevive = {
  percent = -1,
  timeLeft = 666,
  isPreDeath = false,
  isDead = false
}
local mLastActionProgress = 0
local mReviving = {is = false, percent = 0}
local mLastUpdateTime = 0
local mHUDVisible = true
local mPopups = {}
local mBanner
local mLocCRLN = ""
local mLocGiveEssence = ""
local mLocKillCount = ""
local mLocBankedPowerButton = "/D2/Language/Menu/HUD_UseBankedPower"
local mLocPreDeathRevivingMessage = "/D2/Language/Menu/HUD_PreDeathRevivingMessage"
local mLocDeathMessage = "/D2/Language/Menu/HUD_PreDeathMessage"
local mLocDualWield = "/D2/Language/Menu/HUD_DualWield"
local mLocGrab = "/D2/Language/Weapons/ContextAction_Grab"
local mLocComicBook = "/D2/Language/Menu/HUD_PickedUpComicBook"
local mHandsEmpty = "/D2/Language/Weapons/ContextAction_PickupWeapon_HandsEmpty"
local mTwoHandsMain = "/D2/Language/Weapons/ContextAction_PickupWeapon_BothHands_Main"
local mTwoHandsOff = "/D2/Language/Weapons/ContextAction_PickupWeapon_BothHands_Offhand"
local mPrevGenericMessage = ""
local mProfileData, mTalentBreadcrumb
local mFrameNumber = 0
local mItemCollection = {}
local mPlatform = ""
local mPlatformIsPS3, mPlatformIsPC
local mTRC = {}
local mMovie, mInputDeviceType, mPlayerProfile, mProfileSettings
local mGameOptionHudVisible = true
local mNeedsUnpause = false
local pickUpCode
local mCrossFadeActive = false
local function InitializeLocalPlayer()
  mLocalPlayers = gRegion:ScriptGetLocalPlayers()
  if mLocalPlayers ~= nil and not IsNull(mLocalPlayers[1]) then
    mHudStatus = mLocalPlayers[1]:GetHudStatus()
  end
  mIsJP = gRegion:GetLanguageSuffix() == Symbol("_jp")
end
local function _UpdateHeartIcons(movie)
  local colourHealthRegular = 16711680
  local colourHealthHighlight = 16724787
  local frameName = "Default"
  if mAvatarIsDarkling then
    frameName = "Darkling"
  elseif mHasIronHeart then
  elseif mHasDarkArmour and not mAvatar:IsInLight() then
    colourHealthRegular = 10780671
    colourHealthHighlight = 14188543
  end
  movie:SetVariable("HealthBar.FillPulse.Fill.Grad._color", colourHealthRegular)
  movie:SetVariable("HealthBar.FillPulseBackground.Fill.Grad._color", colourHealthHighlight)
  FlashMethod(movie, "HealthBar.HeartType.Image.gotoAndStop", frameName)
  movie:SetVariable("HealthBar.HeartType._color", colourHealthHighlight)
  movie:SetVariable("HealthBar.HeartType.Image._visible", false)
end
function NotifyGrabRelic(movie, targetName)
  mContextActions.grabTarget.name = "RelicPickupAction"
  if targetName ~= nil then
    mContextActions.grabTarget.locName = movie:GetLocalized(targetName)
    mContextActions.grabTarget.text = string.format(mLocGrab, mContextActions.grabTarget.locName, "")
  end
  return 1
end
function NotifyGrabTarget(movie, targetName)
  mContextActions.grabTarget.name = targetName
  if targetName == nil then
    return 1
  end
  if targetName == "AmmoPickUp" then
    mContextActions.grabTarget.icon = ""
    mContextActions.grabTarget.name = "D2AmmoCrateAction"
  else
    mContextActions.grabTarget.icon = movie:GetLocalized(string.format("<%s>", targetName))
  end
  mContextActions.grabTarget.locName = movie:GetLocalized(string.format("/D2/Language/Weapons/WeaponName_%s", targetName))
  mContextActions.grabTarget.text = string.format(mLocGrab, mContextActions.grabTarget.locName, mContextActions.grabTarget.icon)
  return 1
end
function NotifyUpgradeChange(movie, upgradeName, on)
  on = tonumber(on)
  if upgradeName == "IRON_HEART" then
    mHasIronHeart = on == 1
    _UpdateHeartIcons(movie)
  end
  return true
end
local function _UpdateTalentStates(movie)
  if IsNull(mInventoryController) then
    return
  end
  mHasDarkArmour = false
  mHasIronHeart = false
  if mAvatarIsJackie then
    local darkArmourRes = mInventoryController:GetTalentByResName("DarkLife")
    if not IsNull(darkArmourRes) then
      mHasDarkArmour = mInventoryController:GetTalentLevel(darkArmourRes) > 0 and not mAvatar:PowersForcedOff()
    end
  end
  _UpdateHeartIcons(movie)
end
function UpdateTalentStates(movie)
  _UpdateTalentStates(movie)
end
local function InitializeAura(movie)
  mDarknessAuraY = tonumber(movie:GetVariable("Aura._y"))
end
local function InitializeDarknessPowers(movie)
  InitializeAura(movie)
  for i = 0, 1 do
    movie:SetVariable(string.format("BankedPower%i._visible", i), false)
    movie:SetVariable(string.format("BankedPower%i.ActionButton.Action.TxtHolder.Txt.fontScaling", i), false)
  end
  if not mAvatarIsJackie then
    return
  end
  mDarknessPowers = {}
  if mAvatar:GetCharacterType() == D2_Game.JACKIE then
    mDarknessPowers[#mDarknessPowers + 1] = {
      arm = D2_Game.LEFT_ARM,
      mcName = "BankedPower0",
      iconText = "",
      iconBinding = "",
      progress = -1,
      vis = false,
      state = -1,
      colourCharging = 16777215,
      colourReleasing = 16777215
    }
    mDarknessPowers[#mDarknessPowers + 1] = {
      arm = D2_Game.RIGHT_ARM,
      mcName = "BankedPower1",
      iconText = "",
      iconBinding = "",
      progress = -1,
      vis = false,
      state = -1,
      colourCharging = 16777215,
      colourReleasing = 16777215
    }
  else
    mDarknessPowers[#mDarknessPowers + 1] = {
      arm = D2_Game.RIGHT_ARM,
      mcName = "BankedPower0",
      iconText = "",
      iconBinding = "",
      progress = -1,
      vis = false,
      state = -1,
      colourCharging = 16777215,
      colourReleasing = 16777215
    }
    if mAvatarIsJimmy then
      mDarknessPowers[1].colourReleasing = 16724787
    end
  end
  mDarknessPowerOff = false
end
local function InitializeHealthBar(movie)
  mHealth = {
    visible = true,
    value = -666,
    eatHeart = false,
    invincibilityTimer = -666,
    overlayPulseThreshold = 0.15,
    overlayPreFadeTimeLeft = -1,
    overlayPreFadeDuration = 5,
    overlayFadeTimeLeft = -1,
    overlayFadeDuration = 2,
    overlayFadeAlpha = 0,
    overlayStage1HealthRange = healthOverlayBloodRangeMax - healthOverlayBloodRangeMin,
    overlayStage1AlphaRange = healthOverlayBloodAlphaMax - healthOverlayBloodAlphaMin,
    overlayStage1Final = 0,
    overlayStage2HealthRange = healthOverlayTintRangeMax - healthOverlayTintRangeMin,
    overlayStage2AlphaRange = healthOverlayTintAlphaMax - healthOverlayTintAlphaMin,
    overlayStage2Final = 0
  }
  local healthBarFrame = 1
  if mAvatarIsDarkling then
    healthBarFrame = 2
  end
  FlashMethod(movie, "HealthBar.gotoAndStop", healthBarFrame)
  FlashMethod(movie, "SetHealthOverlayInfo", false, 0, 0)
  movie:SetVariable("HealthOverlay._alpha", mHealth.overlayFadeAlpha)
  _UpdateTalentStates(movie)
end
local function InitializeAvatar()
  mAvatar = mLocalPlayers[1]:GetAvatar()
  mAvatarIsValid = not IsNull(mAvatar)
  mAvatarIsD2Avatar = false
  mAvatarIsJackie = false
  mAvatarIsLightSensitive = false
  mAvatarIsCrawling = false
  mAvatarIsWalkInAvatar = false
  mAvatarIsCinematicJackie = false
  mAvatarIsDarkling = false
  mInventoryController = nil
  mICIsD2 = false
  if mAvatarIsValid then
    mAvatarIsD2Avatar = mAvatar:IsA(avatarD2Avatar)
    mAvatarIsJackie = not IsNull(avatarJackie) and mAvatar:IsA(avatarJackie)
    mAvatarIsLightSensitive = not IsNull(avatarLightSensitive)
    mAvatarIsInugami = mAvatarIsJackie and mAvatar:GetCharacterType() == D2_Game.INUGAMI
    mAvatarIsJimmy = mAvatarIsJackie and mAvatar:GetCharacterType() == D2_Game.JIMMY_WILSON
    mAvatarIsShoshanna = mAvatarIsJackie and mAvatar:GetCharacterType() == D2_Game.SHOSHANNA
    mAvatarIsJPDumond = mAvatarIsJackie and mAvatar:GetCharacterType() == D2_Game.JP_DUMOND
    mAvatarIsCrawling = not IsNull(avatarCrawling) and mAvatar:IsA(avatarCrawling)
    mAvatarIsWalkInAvatar = not IsNull(avatarWalkInAvatar) and mAvatar:IsA(avatarWalkInAvatar)
    mAvatarIsCinematicJackie = not IsNull(avatarJackieCinematic) and mAvatar:IsA(avatarJackieCinematic)
    mAvatarIsDarkling = not IsNull(avatarDarkling) and mAvatar:IsA(avatarDarkling)
    mInventoryController = mAvatar:ScriptInventoryControl()
    if not IsNull(mInventoryController) and not IsNull(d2InventoryController) then
      mICIsD2 = mInventoryController:IsA(d2InventoryController)
    end
  end
  InitializeDarknessPowers(mMovie)
  InitializeHealthBar(mMovie)
  mAdaptiveTraining.enabled = mAvatarIsD2Avatar and mAvatar:AdapativeTrainingHintsVisible()
  mAdaptiveTraining.text = ""
end
local ClearWeaponInfo = function(movie, hand)
  FlashMethod(movie, "UpdateWeaponInfoClips", hand, false)
end
local PlaySound = function(sound)
  gRegion:PlaySound(sound, Vector(), false)
end
local function ActiveGameStateSetState(newState)
  if newState == mActiveGameState.STATE_FadeIn then
    if mActiveGameState.state == mActiveGameState.STATE_Hide then
      mActiveGameState.fadeDuration = mActiveGameState.fadeInDuration
      mActiveGameState.fadeTimeLeft = mActiveGameState.fadeDuration
      mActiveGameState.preFadeWait = -1
    elseif mActiveGameState.state == mActiveGameState.STATE_FadeIn and mActiveGameState.preFadeWait >= 0 then
      mActiveGameState.preFadeWait = mActiveGameState.preFadeDuration
    end
  elseif newState == mActiveGameState.STATE_FadeOut then
    mActiveGameState.fadeDuration = mActiveGameState.fadeOutDuration
    mActiveGameState.fadeTimeLeft = mActiveGameState.fadeDuration
    mActiveGameState.preFadeWait = -1
  elseif newState == mActiveGameState.STATE_Show then
    mActiveGameState.preFadeWait = mActiveGameState.preFadeDuration
    mActiveGameState.preFadeNextState = mActiveGameState.STATE_FadeOut
  end
  mActiveGameState.state = newState
end
function NotifyFireWeapon(movie)
  ActiveGameStateSetState(mActiveGameState.STATE_FadeIn)
  return 1
end
local function UpdateActiveGameState(movie, dt)
  if mActiveGameState.preFadeWait >= 0 then
    mActiveGameState.preFadeWait = mActiveGameState.preFadeWait - dt
    if mActiveGameState.preFadeWait > 0 then
      return
    end
    ActiveGameStateSetState(mActiveGameState.preFadeNextState)
    return
  end
  if 0 >= mActiveGameState.fadeTimeLeft then
    return
  end
  mActiveGameState.fadeTimeLeft = Clamp(mActiveGameState.fadeTimeLeft - dt, 0, mActiveGameState.fadeDuration)
  local pct = mActiveGameState.fadeTimeLeft / mActiveGameState.fadeDuration
  local newAlpha = pct * 100
  if mActiveGameState.state == mActiveGameState.STATE_FadeIn then
    newAlpha = 100 - newAlpha
  end
  if pct <= 0 then
    local newState = 0
    if mActiveGameState.state == mActiveGameState.STATE_FadeIn then
      newState = mActiveGameState.STATE_Show
    elseif mActiveGameState.state == mActiveGameState.STATE_FadeOut then
      newState = mActiveGameState.STATE_Hide
    end
    ActiveGameStateSetState(newState)
  end
  newAlpha = Clamp(newAlpha, 0, 100)
  movie:SetVariable("WeaponInfo._alpha", newAlpha)
  movie:SetVariable("HealthBar._alpha", newAlpha)
  movie:SetVariable("BankedPower0._alpha", newAlpha)
  movie:SetVariable("BankedPower1._alpha", newAlpha)
end
function ExecuteAction(movie)
  FlashMethod(movie, "HealthBar.HeartType.gotoAndPlay", "Grow")
  mHealth.eatHeart = true
  ActiveGameStateSetState(mActiveGameState.STATE_FadeIn)
  return true
end
function ComboFadeInDone(movie)
  FlashMethod(movie, "ComboEvent.gotoAndPlay", "Showing")
end
function ComboShowingDone(movie)
  mCombo.state = mCombo.STATE_Showing
  mCombo.timeLeft = mCombo.duration
end
function ComboFadeOutDone(movie)
  mCombo.state = mCombo.STATE_Hidden
  table.remove(mCombo.list, 1)
end
local function _NotifyCombo(movie, textMsg, essenceMsg, essenceAmount)
  local newItem = {
    title = string.format(movie:GetLocalized(textMsg), essenceAmount)
  }
  if mCombo.list == nil then
    mCombo.list = {}
  end
  mCombo.list[#mCombo.list + 1] = newItem
  return true
end
function NotifyCombo(movie, textMsg, essenceMsg, essenceAmount)
  return _NotifyCombo(movie, textMsg, essenceMsg, essenceAmount)
end
local function UpdateComboState(movie, dt)
  if mCombo.state == mCombo.STATE_Hidden and #mCombo.list > 0 then
    FlashMethod(movie, "ComboEvent.gotoAndPlay", "FadeIn")
    movie:SetVariable("ComboEvent.ContainerDark.Text.text", mCombo.list[1].title)
    movie:SetVariable("ComboEvent.ContainerLight.Text.text", mCombo.list[1].title)
    mCombo.state = mCombo.STATE_FadeIn
  elseif mCombo.state == mCombo.STATE_Showing then
    mCombo.timeLeft = mCombo.timeLeft - dt
    if 0 > mCombo.timeLeft then
      FlashMethod(movie, "ComboEvent.gotoAndPlay", "FadeOut")
      mCombo.state = mCombo.STATE_FadeOut
    end
  end
end
local function InitializeCombo(movie)
  mCombo = {
    list = {},
    timeleft = -1,
    duration = 1,
    state = 0,
    STATE_Hidden = 0,
    STATE_FadeIn = 1,
    STATE_Showing = 2,
    STATE_FadeOut = 3
  }
end
local function InitializeEssence()
  mEssence = {
    timeLeft = 0,
    duration = 2,
    queue = {}
  }
end
function GiveEssence(movie, xp, numKills, locString)
  PlaySound(sndEssenceReceived)
  local xpList = LIB.StringTokenize(xp, ";")
  local locStringList = LIB.StringTokenize(locString, ";")
  for i = 1, #xpList do
    local theLocString
    if not IsNull(locStringList[i]) then
      theLocString = locStringList[i]
    else
      theLocString = mLocGiveEssence
    end
    if string.find(theLocString, "PickedUpRelic") ~= nil then
      _NotifyCombo(movie, theLocString, "", tonumber(xpList[i]))
    else
      mEssence.queue[#mEssence.queue + 1] = {
        loc = theLocString,
        value = tonumber(xpList[i])
      }
    end
  end
  return true
end
function GiveEssenceAnimComplete(movie)
end
local function UpdateEssence(movie, dt)
  if mEssence.timeLeft <= 0 then
    if 0 < #mEssence.queue then
      local locString = movie:GetLocalized(mEssence.queue[1].loc)
      local s = string.format(locString, mEssence.queue[1].value)
      table.remove(mEssence.queue, 1)
      FlashMethod(movie, "PlayEssenceAnim", s)
      mEssence.timeLeft = mEssence.duration
    end
  else
    mEssence.timeLeft = mEssence.timeLeft - dt
  end
end
local NewCollectedItem = function(theText, theAmmo, theAmmoType)
  local collectedItem = {
    text = theText,
    ammo = theAmmo,
    ammoType = theAmmoType
  }
  if theAmmo ~= nil then
    collectedItem.ammo = tonumber(collectedItem.ammo)
  end
  return collectedItem
end
function CollectionInfoAddComplete(movie, idx)
  idx = tonumber(idx)
  mItemCollection.state = mItemCollection.STATE_Updating
end
function CollectionInfoShiftComplete(movie, idx)
  idx = tonumber(idx)
  mItemCollection.displayList[idx - 1].text = mItemCollection.displayList[idx].text
  movie:SetVariable(string.format("ItemCollection.Item%i.TxtHolder.Txt.text", idx - 1), mItemCollection.displayList[idx].text)
  FlashMethod(movie, string.format("ItemCollection.Item%i.gotoAndStop", idx - 1), "Default")
  mItemCollection.shiftsLeft = mItemCollection.shiftsLeft - 1
  if mItemCollection.shiftsLeft <= 0 then
    mItemCollection.displayList[idx].text = ""
    mItemCollection.displayList[idx].ammoType = nil
    movie:SetVariable(string.format("ItemCollection.Item%i.TxtHolder.Txt.text", idx), mItemCollection.displayList[idx].text)
    mItemCollection.state = mItemCollection.STATE_Updating
    mItemCollection.prevNumEvents = mItemCollection.prevNumEvents - 1
  end
end
local function _CollectionInfoRemoveComplete(movie, idx)
  idx = tonumber(idx)
  mItemCollection.displayList[idx].text = ""
  mItemCollection.state = mItemCollection.STATE_Shifting
  mItemCollection.numVisibleItems = mItemCollection.numVisibleItems - 1
  local numDisplayListVisible = #mItemCollection.displayList
  for i = 1, numDisplayListVisible do
    if i ~= idx and mItemCollection.displayList[i].text ~= "" then
      FlashMethod(movie, string.format("ItemCollection.Item%i.gotoAndPlay", i), "Shift")
      mItemCollection.shiftsLeft = mItemCollection.shiftsLeft + 1
    end
  end
  if mItemCollection.shiftsLeft == 0 then
    mItemCollection.state = mItemCollection.STATE_Updating
  end
end
function CollectionInfoRemoveComplete(movie, idx)
  _CollectionInfoRemoveComplete(movie, idx)
end
local function InitializeCollectionInfo(movie)
  mItemCollection = {
    timeLeft = nil,
    duration = 1,
    prevNumEvents = 0,
    eventQueue = {},
    state = 3,
    STATE_Adding = 1,
    STATE_Shifting = 2,
    STATE_Updating = 3,
    STATE_Removing = 4,
    shiftsLeft = 0,
    numVisibleItems = 0,
    displayList = {}
  }
  mItemCollection.timeLeft = mItemCollection.duration
  mItemCollection.state = mItemCollection.STATE_Updating
  mItemCollection.displayList[#mItemCollection.displayList + 1] = NewCollectedItem("")
  mItemCollection.displayList[#mItemCollection.displayList + 1] = NewCollectedItem("")
  mItemCollection.displayList[#mItemCollection.displayList + 1] = NewCollectedItem("")
  for i = 1, #mItemCollection.displayList do
    movie:SetVariable(string.format("ItemCollection.Item%i._index", i), i)
  end
end
local function UpdateCollectionInfo(movie, rd)
  if mItemCollection.state ~= mItemCollection.STATE_Updating then
    return
  end
  if mItemCollection.numVisibleItems > 0 then
    mItemCollection.timeLeft = mItemCollection.timeLeft - rd
    if 0 >= mItemCollection.timeLeft then
      mItemCollection.timeLeft = mItemCollection.duration
      mItemCollection.state = mItemCollection.STATE_Removing
      FlashMethod(movie, "ItemCollection.Item1.gotoAndPlay", "Remove")
      return
    end
  end
  local numQueuedItems = #mItemCollection.eventQueue
  if mItemCollection.prevNumEvents ~= numQueuedItems then
    local maxVisible = #mItemCollection.displayList
    for i = 1, maxVisible do
      if mItemCollection.displayList[i].text == "" and 0 < numQueuedItems then
        mItemCollection.state = mItemCollection.STATE_Adding
        mItemCollection.displayList[i] = mItemCollection.eventQueue[1]
        mItemCollection.numVisibleItems = mItemCollection.numVisibleItems + 1
        FlashMethod(movie, string.format("ItemCollection.Item%i.gotoAndPlay", i), "Add")
        movie:SetVariable(string.format("ItemCollection.Item%i.TxtHolder.Txt.text", i), mItemCollection.displayList[i].text)
        table.remove(mItemCollection.eventQueue, 1)
        numQueuedItems = #mItemCollection.eventQueue
      end
    end
  end
  mItemCollection.prevNumEvents = numQueuedItems
end
local function AddToCollectionList(movie, c)
  if not mAvatarIsD2Avatar or not mAvatar:AmmoCountersVisible() then
    return
  end
  local numEvents = #mItemCollection.eventQueue
  if c.ammoType ~= nil then
    local locAmmoName = movie:GetLocalized(string.format("/D2/Language/Weapons/AmmoName_%s", c.ammoType))
    local locFmt = movie:GetLocalized(string.format("/D2/Language/Menu/HUD_NewAmmoReceived"))
    local locFinal = string.format(locFmt, c.ammo, locAmmoName)
    c.text = locFinal
    local maxVisible = #mItemCollection.displayList
    for i = 1, maxVisible do
      if c.ammoType ~= nil and c.ammoType == mItemCollection.displayList[i].ammoType and mItemCollection.displayList[i].text ~= "" then
        mItemCollection.displayList[i].ammo = mItemCollection.displayList[i].ammo + c.ammo
        locFinal = string.format(locFmt, mItemCollection.displayList[i].ammo, locAmmoName)
        mItemCollection.displayList[i].text = locFinal
        movie:SetVariable(string.format("ItemCollection.Item%i.TxtHolder.Txt.text", i), locFinal)
        return
      end
    end
    for i = 1, numEvents do
      if c.ammoType ~= nil and c.ammoType == mItemCollection.eventQueue[i].ammoType then
        mItemCollection.eventQueue[i].ammo = mItemCollection.eventQueue[i].ammo + c.ammo
        locFinal = string.format(locFmt, mItemCollection.eventQueue[i].ammo, locAmmoName)
        mItemCollection.eventQueue[i].text = locFinal
        return
      end
    end
  end
  mItemCollection.eventQueue[numEvents + 1] = c
end
function GiveWeapon(movie, weaponName)
  if mWeaponInventory.history[weaponName] == nil then
    local locWeaponName = movie:GetLocalized(string.format("/D2/Language/Weapons/WeaponName_%s", weaponName))
    local locFmt = movie:GetLocalized(string.format("/D2/Language/Menu/HUD_NewWeaponReceived"))
    local locFinal = string.format(locFmt, locWeaponName)
    mWeaponInventory.history[weaponName] = true
    AddToCollectionList(movie, NewCollectedItem(locFinal, nil, nil))
  end
  return true
end
function GiveAmmo(movie, ammo, ammoType)
  AddToCollectionList(movie, NewCollectedItem("", ammo, ammoType))
  return true
end
local _ReticuleHubShow = function(movie, vis)
  vis = tonumber(vis) ~= 0
  movie:SetVariable("ReticuleHub._visible", vis)
end
function ReticuleHubShow(movie, vis)
  _ReticuleHubShow(movie, vis)
end
local function InitializeReticule(movie)
  mReticule = {
    target = nil,
    iconType = RETICULETYPE_Invalid,
    iconSubType = RETICULETYPE_Invalid,
    visible = {false, false},
    colour = 16777215,
    zoomScale = 1,
    zoomDuration = 0.3,
    prevPixelSize = 0,
    pixelSize = {0, 0},
    scale = {RETICULETYPE_Invalid, RETICULETYPE_Invalid},
    limits = {
      Range(),
      Range()
    },
    grabCompletion = 0,
    queuedGrabCompletion = 0
  }
  movie:SetVariable("ReticuleImpact._color", 16711680)
  _ReticuleHubShow(movie, 0)
end
function SetWeaponWheelVisible(movie, v)
  local b = tonumber(v) ~= 0
  movie:SetVariable("WeaponWheel._visible", b)
end
local function InitializeWeaponInventory(movie)
  movie:SetVariable("WeaponWheel.Weapon0.Container.Txt.fontScaling", false)
  movie:SetVariable("WeaponWheel.Weapon0.Container.Txt.textAlign", "center")
  movie:SetVariable("WeaponWheel.WeaponLabel0.TxtHolder.Txt.fontScaling", false)
  movie:SetVariable("WeaponWheel.Weapon1.Container.Txt.fontScaling", false)
  movie:SetVariable("WeaponWheel.Weapon1.Container.Txt.textAlign", "left")
  movie:SetVariable("WeaponWheel.WeaponLabel1.TxtHolder.Txt.fontScaling", false)
  movie:SetVariable("WeaponWheel.WeaponLabel2.TxtHolder.Txt.fontScaling", false)
  movie:SetVariable("WeaponWheel.Weapon3.Container.Txt.fontScaling", false)
  movie:SetVariable("WeaponWheel.Weapon3.Container.Txt.textAlign", "center")
  movie:SetVariable("WeaponWheel.WeaponLabel3.TxtHolder.Txt.fontScaling", false)
  FlashMethod(movie, "WeaponWheel.DPad.gotoAndStop", mPlatform)
  mIsDualWield = nil
  mWeaponInventory.state = 0
  mWeaponInventory.isSwitching = false
  mWeaponInventory.isContextAction = false
  mWeaponInventory.ca.item = nil
  mWeaponInventory.ca.queuedItem = nil
  mWeaponInventory.ca.queuedPickUp = nil
  mWeaponInventory.selectedIndex = 0
  mWeaponInventory.queuedIndex = 0
  mWeaponInventory.weaponSlot0Icon = ""
  mWeaponInventory.weaponSlot0Name = ""
  mWeaponInventory.weaponSlot1Icon = ""
  mWeaponInventory.weaponSlot1Name = ""
  mWeaponInventory.weaponSlot2Icon = ""
  mWeaponInventory.weaponSlot2Name = ""
  mWeaponInventory.weaponSlot3Icon = ""
  mWeaponInventory.weaponSlot3Name = ""
  mWeaponInventory.forceUpdate = false
end
local function AdjustAuraPositionForBossBars(movie, adjustForBossBars)
  local y = mDarknessAuraY
  if adjustForBossBars then
    y = y + 40
  end
  movie:SetVariable("Aura._y", y)
end
local function UpdateBossHealth(movie, deltaTime)
  local visData = {}
  local isDirty = false
  for k, v in pairs(mBossHealth) do
    local bossName = k
    local bossData = v
    if bossData.health > 0 and bossData.visible then
      local shouldFadeOut = false
      if 0 < bossData.previousHealthTimeLeft then
        bossData.previousHealthTimeLeft = bossData.previousHealthTimeLeft - deltaTime
        if 0 >= bossData.previousHealthTimeLeft then
          bossData.previousHealthFrame = bossData.healthFrame
          shouldFadeOut = true
          isDirty = true
        end
      end
      visData[#visData + 1] = {
        name = bossName,
        curHealthFrame = bossData.healthFrame,
        prevHealthFrame = bossData.previousHealthFrame,
        fadeOut = shouldFadeOut,
        visible = bossData.visible
      }
    end
    if bossData.isDirty or bossData.isFirstUpdate then
      isDirty = true
    end
    if not bossData.isDirty then
    else
      bossData.isFirstUpdate = false
      bossData.isDirty = false
      mBossHealth[bossName] = bossData
    end
  end
  local numVis = #visData
  local diffSize = mBossHealthNumActive ~= numVis
  if mBossHealthNumActive == nil or diffSize or isDirty then
    AdjustAuraPositionForBossBars(movie, 0 < numVis)
    if diffSize then
      local anim = ""
      if diffSize and mBossHealthNumActive ~= 0 and math.abs(mBossHealthNumActive - numVis) < 2 then
        anim = string.format("Active%i%i", mBossHealthNumActive, numVis)
        FlashMethod(movie, "BossHealthBar.gotoAndPlay", anim)
      else
        anim = string.format("Active%i", numVis)
        FlashMethod(movie, "BossHealthBar.gotoAndStop", anim)
      end
    end
    mBossHealthNumActive = numVis
    for i = 1, 3 do
      local vData = visData[i]
      if diffSize then
        movie:SetVariable(string.format("_root.BossHealthBar.Boss%i.HealthBar._visible", i), numVis >= i)
        if vData == nil then
        else
          movie:SetVariable(string.format("BossHealthBar.Boss%i.HealthBar.BossName.text", i), vData.name)
          if vData == nil then
          else
            FlashMethod(movie, string.format("BossHealthBar.Boss%i.HealthBar.Foreground.gotoAndStop", i), vData.curHealthFrame)
            if vData.fadeOut then
              FlashMethod(movie, string.format("BossHealthBar.Boss%i.HealthBar.gotoAndPlay", i), "FadeOut")
              mBossHealth[vData.name].isDirty = true
            elseif 0 < vData.prevHealthFrame then
              FlashMethod(movie, string.format("BossHealthBar.Boss%i.HealthBar.Background.gotoAndStop", i), vData.prevHealthFrame)
            end
          end
        end
      end
    end
  end
end
local function _SetBossHealthInfo(movie, vis, healthPct, name)
  healthPct = tonumber(healthPct)
  vis = vis == "true"
  local theBoss = mBossHealth[name]
  if theBoss == nil then
    local newHealthFrame = math.floor(healthPct / 100 * 200 + 1)
    theBoss = {
      health = healthPct,
      healthFrame = newHealthFrame,
      previousHealthFrame = -1,
      previousHealthTimeLeft = 0,
      previousHealthDuration = 2,
      visible = vis,
      isDirty = true,
      isFirstUpdate = true
    }
  else
    local newHealthFrame = math.floor(healthPct / 100 * 200 + 1)
    theBoss.isDirty = theBoss.visible ~= vis or theBoss.healthFrame ~= newHealthFrame
    theBoss.isFirstUpdate = false
    theBoss.visible = vis
    theBoss.health = healthPct
    if theBoss.previousHealthTimeLeft <= 0 then
      theBoss.previousHealthFrame = theBoss.healthFrame
      theBoss.previousHealthTimeLeft = theBoss.previousHealthDuration
    end
    theBoss.healthFrame = newHealthFrame
  end
  mBossHealth[name] = theBoss
end
function SetBossHealthInfo(movie, vis, healthPct, name)
  _SetBossHealthInfo(movie, vis, healthPct, name)
  return true
end
local InitializeBossHealthInfo = function(movie)
  for i = 1, 3 do
    FlashMethod(movie, string.format("BossHealthBar.Boss%i.HealthBar.Foreground.gotoAndStop", i), 200)
    FlashMethod(movie, string.format("BossHealthBar.Boss%i.HealthBar.Background.gotoAndStop", i), 200)
  end
end
local function InitializeWeaponInfo(movie)
  mWeaponInfo[1] = {
    areaInPixels = 150,
    clip = 0,
    clipSize = 0,
    backPack = 0,
    weaponRes = nil,
    weaponName = "",
    isShotgun = false,
    forceUpdate = false,
    mcActiveX = 0,
    mcActiveY = 0,
    mcX = 0,
    mcY = 0
  }
  mWeaponInfo[2] = {
    areaInPixels = 150,
    clip = 0,
    clipSize = 0,
    backPack = 0,
    weaponRes = nil,
    weaponName = "",
    isShotgun = false,
    forceUpdate = false,
    mcActiveX = 0,
    mcActiveY = 0,
    mcX = 0,
    mcY = 0
  }
  for i = 1, 2 do
    if i == 2 then
      FlashMethod(movie, string.format("WeaponInfo.WeaponInfo%i.gotoAndPlay", i - 1), "Bottom")
    end
    FlashMethod(movie, "GenerateWeaponInfoClipImages", i - 1, 50, mWeaponInfo[i].areaInPixels)
    movie:SetVariable(string.format("WeaponInfo.WeaponInfo%i.WeaponIcon.TxtHolder.Txt.fontScaling", i - 1), false)
    FlashMethod(movie, string.format("WeaponInfo.WeaponInfo%i.WeaponIcon.gotoAndPlay", i - 1), "Small")
    mWeaponInfo[i].clip = 0
    mWeaponInfo[i].clipSize = 50
    mWeaponInfo[i].mcX = movie:GetVariable(string.format("WeaponInfo.WeaponInfo%i._x", i - 1))
    mWeaponInfo[i].mcY = movie:GetVariable(string.format("WeaponInfo.WeaponInfo%i._y", i - 1))
    mWeaponInfo[i].mcActiveX = mWeaponInfo[i].mcX
    mWeaponInfo[i].mcActiveY = mWeaponInfo[i].mcY
  end
end
local _SetDarklingHelperVisible = function(movie, v)
  v = tonumber(v) ~= 0
  if v then
    FlashMethod(movie, "DarklingHelper.gotoAndPlay", "FadeIn")
  else
    FlashMethod(movie, "DarklingHelper.gotoAndPlay", "FadeOut")
  end
end
function SetDarklingHelperVisible(movie, v)
  _SetDarklingHelperVisible(movie, v)
end
local function InitializeCachedLocStrings(movie)
  mLocCRLN = movie:GetLocalized("/D2/Language/Menu/Shared_CRLN")
  mLocGiveEssence = movie:GetLocalized("/D2/Language/Menu/HUD_ReceivedEssence")
  mLocKillCount = movie:GetLocalized("/D2/Language/Menu/HUD_KillCounter")
  mLocPreDeathRevivingMessage = movie:GetLocalized("/D2/Language/Menu/HUD_PreDeathRevivingMessage")
  mLocDeathMessage = movie:GetLocalized("/D2/Language/Menu/HUD_PreDeathMessage")
  mLocDualWield = movie:GetLocalized("/D2/Language/Menu/HUD_DualWield")
  mLocGrab = movie:GetLocalizedWithoutConvertingIcons("/D2/Language/Weapons/ContextAction_Grab")
  mLocComicBook = movie:GetLocalized("/D2/Language/Menu/HUD_PickedUpComicBook")
  movie:SetLocalized("DarklingHelper.Container.Text.text", "<SUMMON_DARKLING>")
end
function Shutdown(movie)
  FlashMethod(movie, "Shutdown")
end
local function InitializeWeapons()
  mWeapons = {
    mode = WEAPONS_INVALID,
    hand = {
      {weapon = nil, weaponIsNull = false},
      {weapon = nil, weaponIsNull = false}
    }
  }
  mWeaponAmmoCounterVis = nil
  mHasWeapons = false
end
local function InitializeActiveGameState()
  mActiveGameState = {
    preFadeWait = 0,
    preFadeDuration = 7.5,
    preFadeNextState = 0,
    fadeInDuration = 0.2,
    fadeOutDuration = 0.35,
    fadeTimeLeft = -1,
    fadeDuration = 1,
    state = 3,
    STATE_Hide = 1,
    STATE_FadeIn = 2,
    STATE_Show = 3,
    STATE_FadeOut = 4
  }
  ActiveGameStateSetState(mActiveGameState.STATE_Show)
end
local function _NotifyGameSettingsChange(movie)
  if mProfileSettings ~= nil then
    mGameOptionHudVisible = mProfileSettings:HUD()
  end
end
function NotifyGameSettingsChange(movie)
  _NotifyGameSettingsChange(movie)
end
local function InitializeContextActions(movie)
  mContextActions = {
    list = nil,
    grabTarget = {
      name = nil,
      text = "",
      locName = nil,
      icon = nil,
      displayIdx = 0
    },
    calloutStartX = nil,
    state = 0,
    STATE_Show = 0,
    STATE_FadeOut = 1,
    STATE_FadeIn = 2,
    STATE_Hide = 3
  }
end
function Initialize(movie)
  mMovie = movie
  movie:SetVariable("Reticule._z", 30.5)
  movie:SetVariable("HealthBar.", 1.25)
  movie:SetVariable("HealthBar.HeartType._z", 0.975)
  movie:SetVariable("ItemCollection._z", 2)
  mPlayerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  if not IsNull(mPlayerProfile) then
    mProfileSettings = mPlayerProfile:Settings()
    local profileData = mPlayerProfile:GetGameSpecificData()
    if profileData ~= nil then
      profileData:SetLoadingScreenTint(0)
    end
  end
  D2_Game.D2SecurityMgr_GetD2SecurityMgr():ValidateWith2K()
  mPlatform = movie:GetVariable("$platform")
  if LIB.IsPC(movie) then
    mPlatform = "XBOX360"
  end
  mPlatformIsPS3 = LIB.IsPS3(movie)
  mPlatformIsPC = LIB.IsPC(movie)
  mTRC = {isDisplayingControllerDisconnect = false}
  mBanner = LIB.BannerInitialize(movie)
  movie:SetVariable("BannerBackground._alpha", 0)
  mInputDeviceType = gFlashMgr:GetInputDeviceIconType()
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
  mFrameNumber = 0
  mMovieObjective = movie:PushChildMovie(movieObjectives)
  mMovieSubTitle = movie:PushChildMovie(movieSubTitle)
  InitializeLocalPlayer()
  mGameRules = gRegion:GetGameRules()
  mProfileData = nil
  InitializeAvatar()
  _NotifyGameSettingsChange(movie)
  pickUpCode = mHudStatus:GetPickUpInputCode()
  movie:SetVariable("pickUpProgress._alpha", 0)
  mAvatarProperties = {inLight = false}
  mMaxHumanPlayersLastFrame = 0
  InitializeWeaponInventory(movie)
  InitializeWeaponInfo(movie)
  InitializeEssence(movie)
  InitializeBossHealthInfo(movie)
  InitializeCollectionInfo(movie)
  InitializeCombo(movie)
  InitializeWeapons()
  mAdaptiveTraining = {
    enabled = true,
    text = "",
    timer = 0
  }
  mGunChannelingState = POWERSTATE_Invalid
  mGunChannelingPrevState = POWERSTATE_Invalid
  mPopups = {
    executionsVisible = false,
    objectivesVisible = false,
    weaponWheelVisible = false
  }
  InitializeContextActions(movie)
  mPower = POWER_Invalid
  mPowerModifierDown = false
  mPowersForcedOff = false
  InitializeReticule(movie)
  mPreDeathRevive = {
    percent = -1,
    timeLeft = 666,
    isPreDeath = false,
    isDead = false,
    animState = 0
  }
  mReviving = {is = false, percent = 0}
  mMaxDisplayableEvents = 0
  mNumEventMessages = 0
  mLastDamageVisibleEntries = 0
  for i = 1, DAMAGEINDICATOR_Total do
    mLastDamageTimeLeft[i] = 0
    mLastDamagePos[i] = Vector()
    FlashMethod(movie, "SetDamageIndicator", i, 0, 0)
    movie:SetVariable(string.format("DamageIndicator.Arrow%i.Image._color", i), 12255232)
  end
  mLocalPlayers[1]:GetHudStatus():ClearDamageInfoList()
  mTalentBreadcrumb = nil
  InitializeCachedLocStrings(movie)
  gClient:EnableDrawMessage(false)
  FlashMethod(movie, "InitializeMovie")
  InitializeDarknessPowers(movie)
  InitializeHealthBar(movie)
  mMovieSubTitle:Execute("OnAvatarChange", "")
  FlashMethod(movie, "Progress.gotoAndStop", 1)
  movie:SetVariable("Progress._visible", false)
  movie:SetVariable("mReticuleXOffset", mEssenceOffsetX)
  movie:SetVariable("mReticuleYOffset", mEssenceOffsetY)
  InitializeActiveGameState()
  mMaxDisplayableEvents = tonumber(movie:GetVariable("mMaxDisplayableEvents"))
  if not IsNull(mGameRules) and not IsNull(demoGameRulesPAX) and mGameRules:IsA(demoGameRulesPAX) then
    movie:SetVariable("EventPane._visible", false)
  end
  mGlobalFade = {
    state = 0,
    duration = 0,
    STATE_Idle = 0,
    STATE_In = 1,
    STATE_Out = 2
  }
  ClearWeaponInfo(movie, WEAPONHAND_Left)
  ClearWeaponInfo(movie, WEAPONHAND_Right)
end
local function CanDisplayReticule(avatar, handIdx)
  local handInfo = mWeapons.hand[handIdx]
  local weapon = handInfo.weapon
  if not (not handInfo.weaponIsNull and weapon:IsEquipped()) or avatar:IsDoingFinisher() or avatar:IsDoingStruggle() or avatar:GameActionControl():IsBlocking() then
    return false
  end
  local posture = avatar:GetPostureModifiers()
  return weapon:ShouldDisplayUIReticule(posture)
end
local function UpdateWeaponInfo(movie, avatar, hand, weaponMode)
  local handInfo = mWeapons.hand[hand + 1]
  if handInfo.weaponIsNull or mAvatarIsDarkling then
    if not handInfo.weaponIsNull or mReticule.pixelSize[hand + 1] ~= 0 then
      movie:SetVariable("WeaponInfo._visible", false)
      mWeaponAmmoCounterVis = false
    end
    mWeapons.hand[hand + 1].weapon = nil
    mReticule.pixelSize[hand + 1] = 0
    return
  end
  local weapon = handInfo.weapon
  local weaponClipSize = weapon:GetClipSize()
  if weaponClipSize <= 0 then
    return
  end
  local vis = mAvatarIsLightSensitive and mAvatar:AmmoCountersVisible()
  local visIdx = hand
  local isDualWield = mWeaponInventory.selectedIndex == 2
  if mAvatarIsJimmy or mAvatarIsInugami or mAvatarIsJPDumond then
    isDualWield = false
  end
  if isDualWield then
    if mIsDualWield ~= nil and mIsDualWield == false then
      FlashMethod(movie, "WeaponInfo.gotoAndPlay", "SingleToDual")
      mMovieSubTitle:Execute("NameTagLayoutChange", "SingleToDual")
    end
    if hand == 0 then
      visIdx = 1
    else
      visIdx = 0
    end
  else
    visIdx = 0
    if mIsDualWield ~= nil and mIsDualWield == true then
      FlashMethod(movie, "WeaponInfo.gotoAndPlay", "DualToSingle")
      mMovieSubTitle:Execute("NameTagLayoutChange", "DualToSingle")
    end
  end
  if mIsDualWield == nil then
    FlashMethod(movie, "WeaponInfo.gotoAndPlay", "NoGun")
    mMovieSubTitle:Execute("NameTagLayoutChange", "NoGun")
  end
  mIsDualWield = isDualWield
  local curWeaponInfo = {
    areaInPixels = mWeaponInfo[hand + 1].areaInPixels,
    clip = weapon:GetAmmoInClip(),
    clipSize = weaponClipSize,
    backPack = weapon:GetAmmoCount(),
    weaponRes = weapon,
    weaponName = "",
    isShotgun = mWeaponInfo[hand + 1].isShotgun,
    forceUpdate = false,
    mcActiveX = mWeaponInfo[hand + 1].mcX,
    mcActiveY = mWeaponInfo[hand + 1].mcY,
    mcX = mWeaponInfo[hand + 1].mcX,
    mcY = mWeaponInfo[hand + 1].mcY
  }
  if not handInfo.weaponIsNull then
    curWeaponInfo.weaponName = weapon:GetResourceName()
  end
  local forceUpdate = mWeaponInfo[hand + 1].forceUpdate
  local isDifferentWeapon = curWeaponInfo.weaponName ~= mWeaponInfo[hand + 1].weaponName or forceUpdate
  if weapon:InfiniteClipsForPlayers() then
    curWeaponInfo.backPack = ""
  end
  if isDifferentWeapon then
    curWeaponInfo.isShotgun = weapon:IsA(d2Shotgun)
  end
  local weaponModeIsDifferent = weaponMode ~= mWeapons.mode or curWeaponInfo.clipSize ~= mWeaponInfo[hand + 1].clipSize
  local clipDiff = curWeaponInfo.clip - mWeaponInfo[hand + 1].clip
  local isBackPackDiff = curWeaponInfo.backPack ~= mWeaponInfo[hand + 1].backPack
  if isDifferentWeapon or isBackPackDiff or curWeaponInfo.clip == 0 then
    ActiveGameStateSetState(mActiveGameState.STATE_FadeIn)
  end
  if isDifferentWeapon or clipDiff ~= 0 or isBackPackDiff or mGunChannelingState ~= mGunChannelingPrevState or weaponModeIsDifferent or vis ~= mWeaponAmmoCounterVis then
    local specialAnimState = 0
    if mGunChannelingState ~= mGunChannelingPrevState then
      specialAnimState = mGunChannelingState
    end
    if visIdx == 0 and mWeaponAmmoCounterVis ~= vis then
      movie:SetVariable("WeaponInfo._visible", vis)
      movie:SetVariable("ItemCollection._visible", vis)
    end
    if mWeaponAmmoCounterVis then
      mWeaponInfo[hand + 1] = curWeaponInfo
    end
    local wasDifferentVis = mWeaponAmmoCounterVis ~= vis
    mWeaponAmmoCounterVis = vis
    local pulsePct = 0.25
    local pulseThreshold = math.ceil(curWeaponInfo.clipSize * pulsePct)
    if clipDiff ~= 0 or forceUpdate or wasDifferentVis then
      if forceUpdate then
        clipDiff = curWeaponInfo.clip
        curWeaponInfo.clip = 0
      end
      FlashMethod(movie, "UpdateWeaponInfoClips", visIdx, vis, curWeaponInfo.clip, curWeaponInfo.clipSize, clipDiff, curWeaponInfo.backPack, pulseThreshold, isDifferentWeapon, curWeaponInfo.isShotgun, string.format("<%s>", weapon:GetName()))
    elseif isBackPackDiff then
      movie:SetVariable(string.format("WeaponInfo.WeaponInfo%i.BackpackAmmo.text", visIdx), curWeaponInfo.backPack)
    end
  end
end
local function UpdateDamageIndicators(movie, avatar, hudStatus, deltaTime)
  local numDamageInfoEntries = hudStatus:NumDamageInfoEntries()
  if numDamageInfoEntries ~= mLastDamageVisibleEntries then
    FlashMethod(movie, "ClearDamageIndicators")
    mLastDamageVisibleEntries = numDamageInfoEntries
  end
  if numDamageInfoEntries == 0 then
    return
  end
  local aPos = avatar:GetSimPosition()
  aPos.y = 0
  local removedEntry = false
  local index = 1
  for i = 1, numDamageInfoEntries do
    local di = hudStatus:GetDamageInfoEntry(i - 1)
    if di.state == 0 then
      mLastDamagePos[i] = di:GetDamagePosition()
      mLastDamageTimeLeft[i] = damageIndicatorDuration
      di.state = 1
      ActiveGameStateSetState(mActiveGameState.STATE_FadeIn)
    elseif di.state == 1 then
      if 0 < mLastDamageTimeLeft[i] then
        mLastDamageTimeLeft[i] = mLastDamageTimeLeft[i] - deltaTime
        if index <= damageIndicatorTotalUsed then
          local tPos = mLastDamagePos[i]
          tPos.y = 0
          if aPos ~= tPos then
            local facing = avatar:GetView()
            local damageDir = AngleTo(aPos, facing, tPos)
            local damageAlpha = 100 * (mLastDamageTimeLeft[i] / damageIndicatorDuration)
            local hSize = 350
            local vSize = 200
            local r = math.pi / 180 * damageDir
            local x = STAGE_Width / 2 + math.sin(r) * hSize
            local y = STAGE_Height / 2 - math.cos(r) * vSize
            FlashMethod(movie, "UpdateDamageIndicator", i, x, y, damageAlpha, damageDir)
          end
          index = index + 1
        end
      else
        di.state = 2
        removedEntry = true
      end
    end
  end
  if removedEntry then
    hudStatus:RemoveDeletedEntries()
  end
end
local function UpdateEventMessageList(movie)
  local numMessages = gClient:GetNumMessages()
  if numMessages ~= mNumEventMessages then
    numMessages = Clamp(numMessages, 0, mMaxDisplayableEvents)
    for i = 0, mMaxDisplayableEvents - 1 do
      local msg
      if i < numMessages then
        msg = gClient:GetMessage(i).mMessage
      end
      FlashMethod(movie, "SetEventMessage", i + 1, msg)
    end
    mNumEventMessages = numMessages
  end
end
local function GetContextActionText(movie, hudStatus, rawIdx, rawCaList)
  local ca = rawCaList[rawIdx]
  local text = ""
  if ca.isGrabTarget then
    return mContextActions.grabTarget.text
  end
  if ca.textIdx > 0 then
    text = hudStatus:GetContextActionText(ca.textIdx - 1)
  end
  if not ca.isPickupAction then
    return text
  end
  if not mAvatarIsJackie or not ca.isWeaponPickup then
    return text
  end
  local itemIcon = movie:GetLocalized(string.format("<%s>", ca.itemResourceName))
  local itemTag = movie:GetLocalized(string.format("/D2/Language/Weapons/WeaponName_%s", ca.itemResourceName))
  if ca.item:IsOneHanded() then
    local thisWeapon = mInventoryController:ScriptSmallArmsMainHand()
    if IsNull(thisWeapon) then
      text = string.format(movie:GetLocalizedWithoutConvertingIcons(mHandsEmpty), itemTag, itemIcon)
    else
      local itemName = thisWeapon:GetResourceName()
      local thisWeaponTag = movie:GetLocalized(string.format("/D2/Language/Weapons/WeaponName_%s", itemName))
      if itemTag == thisWeaponTag then
        text = string.format(movie:GetLocalizedWithoutConvertingIcons(mTwoHandsOff), itemTag, itemIcon)
      else
        text = string.format(movie:GetLocalizedWithoutConvertingIcons(mTwoHandsMain), itemTag, itemIcon)
      end
    end
  else
    text = string.format(movie:GetLocalizedWithoutConvertingIcons(mHandsEmpty), itemTag, itemIcon)
  end
  return text
end
local ContextActionCreate = function()
  local ca = {
    textIdx = 0,
    name = "",
    action = nil,
    text = "",
    item = nil,
    itemResourceName = "",
    isPickupAction = false,
    trackProgress = false,
    isDemonArmGrabTapXToBreakAction = false,
    isWeaponPickup = false,
    isOffHandPickup = false,
    isGrabTarget = false,
    updateText = false,
    touched = false,
    state = 0,
    STATE_Idle = 0,
    STATE_Add = 1,
    STATE_Update = 2,
    STATE_Remove = 3
  }
  return ca
end
function ContextActionsFadeOutComplete(movie)
  mContextActions.state = mContextActions.STATE_Hide
end
function ContextActionsFadeInComplete(movie)
  mContextActions.state = mContextActions.STATE_Show
end
local function _SetContextActionsVisible(movie, visible)
  if not visible and mContextActions.state == mContextActions.STATE_Show then
    mContextActions.state = mContextActions.STATE_FadeOut
    FlashMethod(movie, "ContextActionPane.gotoAndPlay", "FadeOut")
  elseif visible and mContextActions.state == mContextActions.STATE_Hide then
    mContextActions.state = mContextActions.STATE_FadeIn
    FlashMethod(movie, "ContextActionPane.gotoAndPlay", "FadeIn")
  end
end
function SetContextActionsVisible(movie, visible)
  _SetContextActionsVisible(movie, visible)
end
function NotifyExecutionsPopupVisible(movie, value)
  mPopups.executionsVisible = tonumber(value) ~= 0
end
function NotifyObjectivesPopupVisible(movie, value)
  value = tonumber(value) ~= 0
  if value ~= mPopups.objectivesVisible then
    local anim = "FadeIn"
    if value then
      anim = "FadeOut"
    end
    for i = 0, 2 do
      FlashMethod(movie, string.format("BossHealthBar.Boss%i.gotoAndPlay", i), anim)
    end
    FlashMethod(movie, "Aura.gotoAndPlay", anim)
    mPopups.objectivesVisible = value
  end
end
local SetContextActionItem = function(movie, id, playFrame, contextAction)
  local actionClip = "ContextActionPane.Action" .. tostring(id)
  local clipPath = actionClip .. ".Container"
  local trackProgress = contextAction.trackProgress and gFlashMgr:GetInputDeviceIconType() ~= DIT_PC
  if trackProgress then
    if playFrame ~= "" then
      FlashMethod(movie, actionClip .. ".gotoAndPlay", playFrame)
    end
    local label = contextAction.text
    local firstBracketIndex = string.find(label, "<")
    if not IsNull(firstBracketIndex) then
      local secondBracketIndex = string.find(label, ">", firstBracketIndex)
      if not IsNull(secondBracketIndex) then
        local leftText = string.sub(label, 0, firstBracketIndex - 1)
        local rightText = string.sub(label, secondBracketIndex + 1)
        local actionTag = string.sub(label, firstBracketIndex, secondBracketIndex)
        FlashMethod(movie, clipPath .. ".gotoAndStop", "ProgressTrack")
        movie:SetLocalized(clipPath .. ".LeftText.text", leftText)
        movie:SetLocalized(clipPath .. ".RightText.text", rightText)
        movie:SetLocalized(clipPath .. ".Callout.tf.text", actionTag)
        local totalWidth = tonumber(movie:GetVariable(clipPath .. ".LeftText.textWidth")) + 24
        movie:SetVariable(clipPath .. ".Callout._x", totalWidth)
        movie:SetVariable(clipPath .. ".RightText._x", totalWidth + 16)
        totalWidth = totalWidth + tonumber(movie:GetVariable(clipPath .. ".RightText.textWidth"))
        local diffX = math.floor((780 - totalWidth) / 2)
        movie:SetVariable(clipPath .. "._x", diffX)
      end
    end
  else
    FlashMethod(movie, "SetContextActionItem", id, playFrame, contextAction.text)
    movie:SetVariable(clipPath .. "._x", 0)
  end
end
local function UpdateContextAction(movie, hudStatus)
  local textDescription
  local numAdded = 0
  local weaponInventoryContextAction = false
  local caVisible = not mPopups.weaponWheelVisible and not mPopups.executionsVisible
  _SetContextActionsVisible(movie, caVisible)
  local _caRawList = {}
  if mContextActions.grabTarget.name ~= nil and mContextActions.grabTarget.name ~= "" then
    local newCA = ContextActionCreate()
    newCA.name = mContextActions.grabTarget.name
    newCA.isGrabTarget = true
    _caRawList[#_caRawList + 1] = newCA
  end
  local numContextActions = hudStatus:GetNumContextActions()
  for i = 1, numContextActions do
    local theAction = hudStatus:GetContextActionAction(i - 1)
    if IsNull(theAction) then
    else
      local theItem
      local theActionName = theAction:GetName()
      local _isPickupAction = theAction:IsA(pickupAction)
      local _isDemonArmGrabTapXToBreakAction = theAction:IsA(DemonArmGrabTapXToBreakAction)
      local _isWeaponPickup = hudStatus:IsContextActionWeaponPickup(i - 1)
      local _isOffHandPickup = hudStatus:isContextActionOffhandPickup(i - 1)
      if _isPickupAction then
        local thePickUp = theAction:GetParentPickUp()
        theItem = thePickUp:GetPickUpItem()
        theActionName = theItem:GetResourceName()
      end
      if _isOffHandPickup then
        theActionName = theActionName .. "OffHand"
      end
      local ignore = false
      for j = 1, numContextActions do
        if j ~= i and _caRawList ~= nil and _caRawList[j] ~= nil and not IsNull(_caRawList[j].action) and theActionName == _caRawList[j].action:GetName() then
          ignore = true
          break
        end
      end
      if ignore then
      else
        local newCA = ContextActionCreate()
        newCA.textIdx = i
        newCA.name = theActionName
        newCA.action = theAction
        newCA.item = theItem
        if not IsNull(theItem) then
          newCA.itemResourceName = theItem:GetResourceName()
        end
        newCA.isPickupAction = _isPickupAction
        newCA.isDemonArmGrabTapXToBreakAction = _isDemonArmGrabTapXToBreakAction
        newCA.isWeaponPickup = _isWeaponPickup
        newCA.isOffHandPickup = _isOffHandPickup
        newCA.isGrabTarget = false
        local trackProgress = false
        for i, v in pairs(timeTrackActions) do
          if theAction:IsA(v) then
            trackProgress = true
            break
          end
        end
        newCA.trackProgress = trackProgress
        _caRawList[#_caRawList + 1] = newCA
      end
    end
  end
  if mContextActions.list == nil then
    mContextActions.list = {}
    for i = 1, 4 do
      mContextActions.list[i] = ContextActionCreate()
    end
  end
  local addQueue = {}
  for rawIdx = 1, #_caRawList do
    local emptySlot = 0
    local inList = false
    for caIdx = #mContextActions.list, 1, -1 do
      local theCA = mContextActions.list[caIdx]
      local theRaw = _caRawList[rawIdx]
      if emptySlot == 0 and theCA.name == "" then
        emptySlot = caIdx
      end
      if theCA.name ~= "" and theCA.name == _caRawList[rawIdx].name then
        mContextActions.list[caIdx].updateText = false
        if _caRawList[rawIdx].isGrabTarget then
          mContextActions.list[caIdx].trackProgress = false
        end
        local newText = GetContextActionText(movie, hudStatus, rawIdx, _caRawList)
        if theRaw.action ~= nil and theRaw.action:NeedActionTextUpdate() or theCA.text ~= newText then
          mContextActions.list[caIdx].text = newText
          mContextActions.list[caIdx].updateText = true
          if not IsNull(theRaw.action) then
            local trackProgress = false
            for i, v in pairs(timeTrackActions) do
              if theRaw.action:IsA(v) then
                trackProgress = true
                break
              end
            end
            mContextActions.list[caIdx].trackProgress = trackProgress
          end
        end
        mContextActions.list[caIdx].state = theCA.STATE_Update
        mContextActions.list[caIdx].touched = true
        inList = true
        break
      end
    end
    if not inList and 0 < emptySlot then
      local theText = GetContextActionText(movie, hudStatus, rawIdx, _caRawList)
      local newCA = _caRawList[rawIdx]
      newCA.text = theText
      newCA.state = newCA.STATE_Add
      newCA.touched = true
      addQueue[#addQueue + 1] = newCA
    end
  end
  for i = #mContextActions.list, 1, -1 do
    if mContextActions.list[i].state ~= mContextActions.list[i].STATE_Idle and not mContextActions.list[i].touched then
      mContextActions.list[i].state = mContextActions.list[i].STATE_Remove
      mContextActions.list[i].name = ""
      if mContextActions.list[i].isDemonArmGrabTapXToBreakAction then
        SetContextActionItem(movie, 2, "FadeOut", mContextActions.list[i])
      else
        SetContextActionItem(movie, i + 2, "FadeOut", mContextActions.list[i])
      end
    end
  end
  local queuedIdx = 1
  for i = #mContextActions.list, 1, -1 do
    if mContextActions.list[i].name == "" then
      local theQueue = addQueue[queuedIdx]
      if theQueue ~= nil then
        mContextActions.list[i] = theQueue
      end
      queuedIdx = queuedIdx + 1
    end
  end
  local displayOrderIdx = 6
  for i = #mContextActions.list, 1, -1 do
    local thisCA = mContextActions.list[i]
    local displayIdx = displayOrderIdx
    if thisCA.isDemonArmGrabTapXToBreakAction then
      displayIdx = 2
    end
    if thisCA.state == thisCA.STATE_Add then
      SetContextActionItem(movie, displayIdx, "FadeIn", mContextActions.list[i])
      if thisCA.trackProgress and gFlashMgr:GetInputDeviceIconType() ~= DIT_PC then
        local clipPath = "ContextActionPane.Action" .. tostring(displayIdx) .. ".Container"
        FlashMethod(movie, clipPath .. ".Callout.fill.Mask.gotoAndStop", 1)
        movie:SetVariable(clipPath .. ".Callout.Bg._visible", false)
      end
    elseif thisCA.state == thisCA.STATE_Update then
      if thisCA.updateText then
        SetContextActionItem(movie, displayIdx, "", mContextActions.list[i])
      end
      if thisCA.trackProgress and gFlashMgr:GetInputDeviceIconType() ~= DIT_PC then
        local clipPath = "ContextActionPane.Action" .. tostring(displayIdx) .. ".Container"
        local isDemuxInputActive = mHudStatus:IsDemuxInputActive(pickUpCode)
        if isDemuxInputActive then
          movie:SetVariable(clipPath .. ".Callout.Bg._visible", true)
          movie:SetVariable(clipPath .. ".Callout.fill._visible", true)
          local progress = mHudStatus:GetDemuxInputProgress(pickUpCode)
          FlashMethod(movie, clipPath .. ".Callout.fill.Mask.gotoAndStop", math.floor(progress * 100))
        else
          movie:SetVariable(clipPath .. ".Callout.Bg._visible", false)
          movie:SetVariable(clipPath .. ".Callout.fill._visible", false)
        end
      end
    elseif thisCA.state == thisCA.STATE_Remove then
      mContextActions.list[i].state = thisCA.STATE_Idle
    end
    mContextActions.list[i].touched = false
    displayOrderIdx = displayOrderIdx - 1
  end
  if mWeaponInventory.isContextAction ~= weaponInventoryContextAction then
    mWeaponInventory.isContextAction = weaponInventoryContextAction
    mWeaponInventory.ca.queuedPickUp = nil
    mWeaponInventory.ca.queuedItem = nil
  end
end
local function UpdateGenericMessage(movie, hudStatus)
  local msg = hudStatus:GetGenericMessage()
  if msg ~= mPrevGenericMessage then
    movie:SetLocalized("GenericMessage.text", msg)
    mPrevGenericMessage = msg
  end
end
function WeaponWheelOpened(movie)
  mPopups.weaponWheelVisible = true
end
function WeaponWheelClosed(movie)
  mPopups.weaponWheelVisible = false
end
local function UpdateWeaponInventory(movie, ic)
  if mAvatarIsCinematicJackie then
    return
  end
  local wis = mWeaponInventory.state
  local state = 0
  if mWeaponInventory.isContextAction then
    state = 2
  elseif mWeaponInventory.isSwitching then
    state = 1
  end
  if state ~= mWeaponInventory.state or mWeaponInventory.queuedIndex ~= mWeaponInventory.selectedIndex or mWeaponInventory.ca.queuedItem ~= mWeaponInventory.ca.item or mWeaponInventory.forceUpdate then
    if mPlatformIsPC then
      local showDPad = gFlashMgr:GetInputDeviceIconType() ~= DIT_PC
      movie:SetVariable("WeaponWheel.DPad._visible", showDPad)
    end
    mWeaponInventory.forceUpdate = false
    local slotIdx
    local item = ""
    slotIdx = mWeaponInventory.queuedIndex
    local weaponLocked = ic:UniqueWeaponLockedToOffhand()
    local canSingleWield = ic:CanSingleWieldSmallArms()
    local weaponVisibilityFlags = 0
    if state == 1 and weaponLocked then
      weaponVisibilityFlags = 2
      if canSingleWield then
        weaponVisibilityFlags = 1
      end
    end
    local dualWieldText = ""
    if mWeaponInventory.weaponSlot1Name ~= "" and mWeaponInventory.weaponSlot2Name ~= "" then
      dualWieldText = mLocDualWield
    end
    FlashMethod(movie, "SetWeaponInventory", state, weaponVisibilityFlags, slotIdx, mWeaponInventory.weaponSlot0Icon, mWeaponInventory.weaponSlot0Name, mWeaponInventory.weaponSlot1Icon, mWeaponInventory.weaponSlot1Name, mWeaponInventory.weaponSlot2Icon, mWeaponInventory.weaponSlot2Name, dualWieldText)
    mWeaponInventory.state = state
    mWeaponInventory.selectedIndex = mWeaponInventory.queuedIndex
    mWeaponInventory.ca.item = mWeaponInventory.ca.queuedItem
    if state ~= 0 then
      mWeaponInfo[1].weaponName = ""
      mWeaponInfo[1].forceUpdate = true
      mWeaponInfo[2].weaponName = ""
      mWeaponInfo[2].forceUpdate = true
    end
  end
end
local GetStringFromTag = function(tag)
  if tag == nil then
    return ""
  end
  local startIdx = string.find(tag, "<")
  if tag == nil then
    return tag
  end
  local endIdx = string.find(tag, ">")
  if endIdx == nil then
    return tag
  end
  local s = string.sub(tag, startIdx + 1, endIdx - 1)
  return s
end
function DisplayWeaponInventory(movie, vis, selectedIndex, weaponSlot0, weaponSlot1, weaponSlot2, weaponSlot3)
  mWeaponInventory.isSwitching = tonumber(vis) == 1
  if mWeaponInventory.isSwitching then
    mWeaponInventory.queuedIndex = tonumber(selectedIndex)
    mWeaponInventory.forceUpdate = mWeaponInventory.weaponSlot0Icon ~= weaponSlot0 or mWeaponInventory.weaponSlot1Icon ~= weaponSlot1 or mWeaponInventory.weaponSlot2Icon ~= weaponSlot2 or mWeaponInventory.weaponSlot3Icon ~= weaponSlot3
    mWeaponInventory.weaponSlot0Icon = weaponSlot0
    if weaponSlot0 == "!" then
      mWeaponInventory.weaponSlot0Name = ""
      mWeaponInventory.weaponSlot0Icon = ""
    else
      mWeaponInventory.weaponSlot0Name = movie:GetLocalized(string.format("/D2/Language/Weapons/WeaponName_%s", GetStringFromTag(mWeaponInventory.weaponSlot0Icon)))
    end
    mWeaponInventory.weaponSlot1Icon = weaponSlot1
    if weaponSlot1 == "!" then
      mWeaponInventory.weaponSlot1Name = ""
      mWeaponInventory.weaponSlot1Icon = ""
    else
      mWeaponInventory.weaponSlot1Name = movie:GetLocalized(string.format("/D2/Language/Weapons/WeaponName_%s", GetStringFromTag(mWeaponInventory.weaponSlot1Icon)))
    end
    mWeaponInventory.weaponSlot2Icon = weaponSlot2
    if weaponSlot2 == "!" then
      mWeaponInventory.weaponSlot2Name = ""
      mWeaponInventory.weaponSlot2Icon = ""
    else
      mWeaponInventory.weaponSlot2Name = movie:GetLocalized(string.format("/D2/Language/Weapons/WeaponName_%s", GetStringFromTag(mWeaponInventory.weaponSlot2Icon)))
    end
    mWeaponInventory.weaponSlot3Icon = weaponSlot3
    if weaponSlot3 == "!" then
      mWeaponInventory.weaponSlot3Name = ""
      mWeaponInventory.weaponSlot3Icon = ""
    else
      mWeaponInventory.weaponSlot3Name = movie:GetLocalized(string.format("/D2/Language/Weapons/WeaponName_%s", GetStringFromTag(mWeaponInventory.weaponSlot3Icon)))
    end
  end
  return 1
end
local function _InvalidateActionTextFields(movie)
  for i = 1, #mDarknessPowers do
    mDarknessPowers[i].iconBinding = ""
  end
end
function InvalidateActionTextFields(movie)
  _InvalidateActionTextFields(movie)
end
function NotifyWeaponReload(movie)
  if mAvatarIsJackie and mAvatar:AmmoCountersVisible() then
    ActiveGameStateSetState(mActiveGameState.STATE_FadeIn)
  end
  return 1
end
local function UpdatePowerBar(movie, avatar, inventoryController, deltaTime, isJackie)
  local powersChanged = inventoryController:PowersChanged()
  local pfo = avatar:PowersForcedOff()
  local isInLight = mAvatar:IsInLight()
  for i = 1, #mDarknessPowers do
    local darknessPower = mDarknessPowers[i]
    local hand = darknessPower.arm
    local iconText = inventoryController:GetPowerText(hand)
    local iconBinding = inventoryController:GetPowerBinding(hand)
    local vis = pfo == false and iconText ~= "" and mAvatarIsJackie and mAvatar:AmmoCountersVisible()
    local iconTextDiff = darknessPower.iconText ~= iconText
    local iconBindingDiff = darknessPower.iconBinding ~= iconBinding
    local forceDiff = mDarknessPowerOff ~= pfo
    if iconTextDiff or iconBindingDiff or forceDiff then
      mDarknessPowers[i].iconText = iconText
      mDarknessPowers[i].iconBinding = iconBinding
      local finalStr = ""
      if iconText ~= "" and not pfo then
        finalStr = movie:GetLocalized(iconText)
      end
      iconBinding = movie:GetLocalized(string.format("<%s>", iconBinding))
      movie:SetLocalized(string.format("%s.TxtHolder.Image.text", darknessPower.mcName), finalStr)
      movie:SetVariable(string.format("%s.ActionButton.Action.TxtHolder.Txt.text", darknessPower.mcName), iconBinding)
    end
    local STATE_Charging = 0
    local STATE_Releasing = 1
    local state, progress, fillColour
    if inventoryController:IsPowerActive(hand) then
      progress = math.floor(inventoryController:GetPowerRemainingProgress(hand) * 100)
      state = STATE_Releasing
      fillColour = darknessPower.colourReleasing
    else
      progress = math.floor(inventoryController:GetPowerCooldownProgress(hand) * 100)
      state = STATE_Charging
      fillColour = darknessPower.colourCharging
    end
    progress = Clamp(progress, 0, 100)
    if progress ~= darknessPower.progress or state ~= darknessPower.state then
      FlashMethod(movie, string.format("%s.FillPulse.Fill.Mask.gotoAndStop", darknessPower.mcName), progress + 1)
      if 100 <= progress and progress > mDarknessPowers[i].progress then
        FlashMethod(movie, string.format("%s.FillPulse.gotoAndPlay", darknessPower.mcName), "Pulse")
        FlashMethod(movie, string.format("%s.ActionButton.gotoAndPlay", darknessPower.mcName), "Available")
        movie:SetVariable(string.format("%s.TxtHolder._alpha", darknessPower.mcName), 100)
      elseif state ~= mDarknessPowers[i].state and state == STATE_Releasing then
        FlashMethod(movie, string.format("%s.FillPulse.gotoAndStop", darknessPower.mcName), "Default")
        FlashMethod(movie, string.format("%s.ActionButton.gotoAndPlay", darknessPower.mcName), "Used")
        movie:SetVariable(string.format("%s.TxtHolder._alpha", darknessPower.mcName), 25)
        ActiveGameStateSetState(mActiveGameState.STATE_FadeIn)
      end
      if state ~= darknessPower.state then
        movie:SetVariable(string.format("%s.FillPulse.Fill.Grad._color", darknessPower.mcName), fillColour)
      end
      if state == STATE_Charging and progress ~= darknessPower.progress then
        ActiveGameStateSetState(mActiveGameState.STATE_FadeIn)
      end
      mDarknessPowers[i].state = state
      mDarknessPowers[i].progress = progress
    end
    if mAvatarProperties.isInLight ~= isInLight then
      if isInLight then
        FlashMethod(movie, string.format("%s.Smoke.gotoAndPlay", darknessPower.mcName), "Play")
        FlashMethod(movie, string.format("%s.ActionButton.Action.gotoAndPlay", darknessPower.mcName), "InLight")
        movie:SetVariable(string.format("%s.TxtHolder._visible", darknessPower.mcName), false)
      else
        FlashMethod(movie, string.format("%s.Smoke.gotoAndStop", darknessPower.mcName), "Default")
        FlashMethod(movie, string.format("%s.ActionButton.Action.gotoAndPlay", darknessPower.mcName), "OutLight")
        movie:SetVariable(string.format("%s.TxtHolder._visible", darknessPower.mcName), true)
      end
      movie:SetVariable(string.format("%s.Frame._visible", darknessPower.mcName), not isInLight)
      movie:SetVariable(string.format("%s.FillPulse._visible", darknessPower.mcName), not isInLight)
      darknessPower.iconBinding = ""
    end
    if vis ~= darknessPower.vis then
      movie:SetVariable(string.format("%s._visible", darknessPower.mcName), vis)
      mDarknessPowers[i].vis = vis
    end
  end
  if mAvatarProperties.isInLight ~= isInLight then
    _UpdateHeartIcons(movie)
  end
  mDarknessPowerOff = pfo
  mAvatarProperties.isInLight = isInLight
  if not isJackie or pfo then
    if mPower ~= POWER_Invalid then
      mPower = POWER_Invalid
    end
    return
  end
  local auraString = inventoryController:GetAuraString()
  if mDarknessAuraString ~= auraString then
    mDarknessAuraString = auraString
    movie:SetLocalized("Aura.TxtHolder.Text.text", auraString)
  end
end
local function UpdateHealth(movie, dt, avatar)
  if not mAvatarIsD2Avatar then
    return
  end
  local healthVis = avatar:HealthBarVisible()
  local curHealth = avatar:GetHealth() / avatar:GetMaxHealth()
  if curHealth < 0 then
    curHealth = 0
  end
  if curHealth < 1 then
    ActiveGameStateSetState(mActiveGameState.STATE_FadeIn)
  end
  if curHealth ~= mHealth.value or healthVis ~= mHealth.visible then
    if mHealth.overlayFadeAlpha < 100 and mHealth.value ~= -666 then
      mHealth.overlayFadeAlpha = 100
      movie:SetVariable("HealthOverlay._alpha", mHealth.overlayFadeAlpha)
    end
    local stage1ClampedHealth = Clamp(curHealth, healthOverlayBloodRangeMin, healthOverlayBloodRangeMax)
    local stage1HealthPct = (stage1ClampedHealth - healthOverlayBloodRangeMin) / mHealth.overlayStage1HealthRange
    local stage1HealthAlpha = stage1HealthPct * mHealth.overlayStage1AlphaRange + healthOverlayBloodAlphaMin
    local prevOverlayStage1Final = mHealth.overlayStage1Final
    mHealth.overlayStage1Final = Clamp(healthOverlayBloodAlphaMax - stage1HealthAlpha, 0, 100)
    if mHealth.eatHeart and curHealth > healthOverlayBloodRangeMax and mHealth.value <= healthOverlayBloodRangeMax then
      mHealth.overlayPreFadeTimeLeft = 0
    end
    FlashMethod(movie, "SetHealthOverlayInfo", healthVis, curHealth * 100 + 1, mHealth.overlayStage1Final)
    mHealth.eatHeart = false
    if 0 < mHealth.overlayStage1Final then
      mHealth.overlayPreFadeTimeLeft = mHealth.overlayPreFadeDuration
    end
    local stage2ClampedHealth = Clamp(curHealth, healthOverlayTintRangeMin, healthOverlayTintRangeMax)
    local stage2HealthPct = (stage2ClampedHealth - healthOverlayTintRangeMin) / mHealth.overlayStage2HealthRange
    local stage2HealthAlpha = stage2HealthPct * mHealth.overlayStage2AlphaRange + healthOverlayTintAlphaMin
    mHealth.overlayStage2Final = Clamp(healthOverlayTintAlphaMax - stage2HealthAlpha, 0, 99)
    movie:SetVariable("HealthOverlay.Tint.Container._alpha", mHealth.overlayStage2Final)
    FlashMethod(movie, "HealthBar.FillPulseBackground.Fill.Mask.gotoAndStop", mHealth.value * 100 + 1)
    if curHealth < mHealth.value then
      FlashMethod(movie, "HealthBar.FillPulseBackground.gotoAndPlay", "PulseOut")
    elseif curHealth > mHealth.value then
      FlashMethod(movie, "HealthBar.FillPulseBackground.gotoAndPlay", "PulseIn")
    end
    if curHealth <= mHealth.overlayPulseThreshold and mHealth.value > mHealth.overlayPulseThreshold then
      FlashMethod(movie, "HealthOverlay.gotoAndPlay", "Play")
    elseif curHealth >= mHealth.overlayPulseThreshold and mHealth.value < mHealth.overlayPulseThreshold then
      FlashMethod(movie, "HealthOverlay.gotoAndStop", "Default")
    end
    mHealth.value = curHealth
    mHealth.visible = healthVis
  end
  if mAvatarIsJackie then
    local dc = avatar:DamageControl()
    local invincibilityTimer = dc:GetInvincibleTimer()
    if invincibilityTimer ~= mHealth.invincibilityTimer then
      if 0 < invincibilityTimer and 0 >= mHealth.invincibilityTimer then
        local currentFrame = movie:GetVariable("HealthOverlay._currentframe")
        FlashMethod(movie, "HealthBar.HeartType.gotoAndPlay", currentFrame)
      elseif 0 > mHealth.invincibilityTimer and invincibilityTimer < 0 then
        FlashMethod(movie, "HealthBar.HeartType.gotoAndStop", "Default")
      end
      mHealth.invincibilityTimer = invincibilityTimer
    end
  end
  if 0 <= mHealth.overlayPreFadeTimeLeft then
    mHealth.overlayPreFadeTimeLeft = mHealth.overlayPreFadeTimeLeft - dt
    if 0 >= mHealth.overlayPreFadeTimeLeft then
      mHealth.overlayFadeTimeLeft = mHealth.overlayFadeDuration
      mHealth.overlayFadeAlpha = 100
    end
  elseif 0 <= mHealth.overlayFadeTimeLeft then
    mHealth.overlayFadeTimeLeft = mHealth.overlayFadeTimeLeft - dt
    mHealth.overlayFadeAlpha = Clamp(mHealth.overlayFadeAlpha - 50 * dt, 0, 100)
    movie:SetVariable("HealthOverlay._alpha", mHealth.overlayFadeAlpha)
  end
end
local ClearHitIndicator = function(movie, hudStatus)
  FlashMethod(movie, "ClearDamageIndicators")
  for i = 1, damageIndicatorTotalUsed do
    FlashMethod(movie, "SetDamageIndicator", i, 0, 0)
  end
  local numDamageInfoEntries = hudStatus:NumDamageInfoEntries()
  if numDamageInfoEntries ~= 0 then
    for i = 1, numDamageInfoEntries do
      local di = hudStatus:GetDamageInfoEntry(i - 1)
      di.state = 2
    end
    hudStatus:RemoveDeletedEntries()
  end
end
local function UpdateLocalDeathStatus(movie, avatar, hudStatus)
  local dc = avatar:DamageControl()
  local preDeath = dc:IsPreDeath()
  local deathTimeLeft = dc:GetPreDeathTimeLeft()
  local revivePct = math.floor(avatar:GetReviveProgress() * 100)
  if preDeath ~= mPreDeathRevive.isPreDeath and preDeath then
    ClearHitIndicator(movie, hudStatus)
  end
  local health = 0
  if not IsNull(avatar) then
    health = avatar:GetHealth()
  end
  local isDead = health <= 0
  if isDead then
    preDeath = mPreDeathRevive.isPreDeath
    deathTimeLeft = mPreDeathRevive.timeLeft
    revivePct = mPreDeathRevive.percent
  end
  local reviveDiff = revivePct ~= mPreDeathRevive.percent
  local timeDiff = deathTimeLeft ~= mPreDeathRevive.timeLeft
  local preDeathDiff = preDeath ~= mPreDeathRevive.isPreDeath
  local deathDiff = isDead ~= mPreDeathRevive.isDead
  if reviveDiff or timeDiff or preDeathDiff or deathDiff then
    local ANIMSTATE_StartFlash = 1
    local ANIMSTATE_StopFlash = 2
    local animState = 0
    if deathDiff and isDead then
      animState = ANIMSTATE_StopFlash
    elseif preDeathDiff then
      if preDeath then
        animState = ANIMSTATE_StartFlash
      else
        animState = ANIMSTATE_StopFlash
      end
    end
    local str
    if preDeath and 0 < deathTimeLeft and 0 < health then
      local theTime = LIB.StringTimeFormat(deathTimeLeft, "ms")
      str = string.format("%s\r\n%s", mLocPreDeathRevivingMessage, theTime)
    elseif isDead then
      str = mLocDeathMessage
    end
    if not preDeath and not isDead then
      FlashMethod(movie, "SetHealthOverlayInfo", true, 100, 0)
      mHealth.value = 1
    end
    FlashMethod(movie, "SetDeathProgress", preDeath and 1 < revivePct and health <= 1, revivePct, 16777215, animState, str)
    mPreDeathRevive.percent = revivePct
  end
  mPreDeathRevive.isPreDeath = preDeath
  mPreDeathRevive.isDead = isDead
  mPreDeathRevive.timeLeft = deathTimeLeft
  mPreDeathRevive.percent = revivePct
end
local function UpdateDynamicReticuleData(avatar)
  local numHands = #mWeapons.hand
  for i = 1, numHands do
    local handInfo = mWeapons.hand[i]
    if handInfo.weaponIsNull then
      mReticule.pixelSize[i] = 0
      mReticule.visible[i] = false
    elseif not handInfo.weapon:IsEquipped() then
    else
      local curReticuleLimits = handInfo.weapon:GetUIReticuleMaxSize()
      curReticuleLimits.maxValue = curReticuleLimits.maxValue * 0.5 * STAGE_Height
      local curReticuleScale = handInfo.weapon:GetUIReticuleCurrentSize()
      mReticule.pixelSize[i] = Lerp(curReticuleLimits.minValue, curReticuleLimits.maxValue, curReticuleScale)
      mReticule.limits[i] = curReticuleLimits
      mReticule.scale[i] = curReticuleScale
    end
  end
end
function OnDamageTarget(movie)
  FlashMethod(movie, "ReticuleImpact.gotoAndPlay", "Play")
  return true
end
local function UpdateReticuleType(movie, dt, ic, avatar, hasWeapons, inputControl, reticuleTargetIsNull, reticuleTarget, isJackie, isPreDeath)
  local reticuleIconType = RETICULETYPE_Invalid
  local isDifferentTarget = false
  local isDirty = false
  local vis = isJackie and mAvatar:ReticuleIsVisible()
  local colour = 16777215
  local alpha = 100
  local scale = 1
  local minSize = 1
  local maxSize = 5
  local reticuleTargetIsNPCAgent = false
  if not reticuleTargetIsNull then
    reticuleTargetIsNPCAgent = reticuleTarget:IsA(npcAgent)
    if reticuleTargetIsNPCAgent and reticuleTarget:IsKilled() then
      reticuleTarget = nil
      reticuleTargetIsNull = true
    end
  end
  if IsNull(mReticule.target) then
    isDifferentTarget = not reticuleTargetIsNull
  elseif mReticule.target:IsA(npcAgent) and mReticule.target:IsKilled() then
    isDifferentTarget = true
  else
    isDifferentTarget = inputControl:IsCurrentTargetDifferent(mReticule.target)
  end
  if isDifferentTarget then
    isDirty = true
  end
  local largestReticuleIndex = WEAPONHAND_Right + 1
  if mReticule.pixelSize[WEAPONHAND_Left + 1] > mReticule.pixelSize[largestReticuleIndex] then
    largestReticuleIndex = WEAPONHAND_Left + 1
  end
  if not hasWeapons then
    vis = vis and not avatar:IsDoingFinisher() and not avatar:IsDoingStruggle() and not avatar:GameActionControl():IsBlocking()
    if vis and not mAvatarIsWalkInAvatar and not mAvatarIsCinematicJackie then
      reticuleIconType = RETICULETYPE_Dynamic
    end
    if vis ~= mReticule.visible[largestReticuleIndex] then
      mReticule.visible[largestReticuleIndex] = vis
      isDirty = true
    end
  else
    reticuleIconType = RETICULETYPE_Dynamic
    UpdateDynamicReticuleData(avatar)
    local curReticulePixelSize = mReticule.pixelSize[largestReticuleIndex]
    scale = mReticule.scale[largestReticuleIndex]
    minSize = mReticule.limits[largestReticuleIndex].minValue
    maxSize = mReticule.limits[largestReticuleIndex].maxValue
    vis = vis and CanDisplayReticule(avatar, largestReticuleIndex)
    local isZoom = not vis and avatar:GetPostureModifiers() % (POSTURE_Zoom + POSTURE_Zoom) >= POSTURE_Zoom and mWeaponInventory.selectedIndex ~= 2
    if isZoom then
      vis = true
    end
    local zoomScale = mReticule.zoomScale
    local zoomDelta = dt / mReticule.zoomDuration
    if isZoom then
      zoomScale = zoomScale - zoomDelta
    else
      zoomScale = zoomScale + zoomDelta
    end
    zoomScale = Clamp(zoomScale, 0, 1)
    scale = zoomScale * scale
    alpha = zoomScale * 100
    curReticulePixelSize = scale * curReticulePixelSize
    local prev = mReticule.prevPixelSize
    if curReticulePixelSize ~= mReticule.prevPixelSize or vis ~= mReticule.visible[largestReticuleIndex] then
      mReticule.visible[largestReticuleIndex] = vis
      isDirty = true
      mReticule.prevPixelSize = curReticulePixelSize
      mReticule.zoomScale = zoomScale
    end
  end
  if mHasWeapons ~= hasWeapons then
    mHasWeapons = hasWeapons
    isDirty = true
  end
  if vis and not reticuleTargetIsNull and inputControl:IsCurrentTargetAtCentre() then
    if reticuleTarget:IsA(hitProxyUnbreakableLight) then
      reticuleIconType = RETICULETYPE_Unbreakable
    elseif reticuleTargetIsNPCAgent then
      local agent = reticuleTarget:GetAgent()
      local faction = reticuleTarget:GetFaction()
      if faction == avatar:GetFaction() or faction == neutralFaction or not IsNull(agent) and agent:IsPlayerAlly() or not IsNull(agent) and not IsNull(agent:GetAvatar()) and agent:GetAvatar():DamageControl():IsCensored() then
        reticuleIconType = RETICULETYPE_Friendly
      end
    end
  end
  local iconSubType = reticuleIconType
  if not reticuleTargetIsNull and (iconSubType ~= RETICULETYPE_Unbreakable and iconSubType ~= RETICULETYPE_Friendly and inputControl:IsCurrentTargetAtCentre() or iconSubType == RETICULETYPE_Grab) then
    colour = 16711680
  end
  if isPreDeath then
    isDirty = true
    vis = false
  end
  if 0 >= mHealth.value then
    alpha = 0
    isDirty = true
  end
  local isReticuleTypeDifferent = reticuleIconType ~= mReticule.iconType
  local isSubTypeDifferent = iconSubType ~= mReticule.iconSubType
  local isColorDifferent = colour ~= mReticule.colour
  if isReticuleTypeDifferent or isSubTypeDifferent or isColorDifferent or isDirty then
    local isVisible = (reticuleIconType == RETICULETYPE_Dynamic or reticuleIconType == RETICULETYPE_Friendly) and vis
    FlashMethod(movie, "SetDynamicReticuleState", isVisible, colour, alpha, scale, 0, maxSize, iconSubType)
    mReticule.iconType = reticuleIconType
    mReticule.iconSubType = iconSubType
    mReticule.colour = colour
  end
  mReticule.target = reticuleTarget
end
local function _SetAdaptiveTrainingText(movie, text)
  if IsNull(Engine.GetPlayerProfileMgr():GetPlayerProfile(0)) then
    return
  end
  local allowed = mAvatarIsD2Avatar and mAvatar:AdapativeTrainingHintsVisible() and not IsNull(mProfileSettings) and mProfileSettings:TutorialEnabled()
  if not allowed then
    text = ""
  end
  LIB.StyleTextSet(movie, text)
  mAdaptiveTraining.text = text
end
function SetAdaptiveTrainingEnabled(movie, enabled)
  mAdaptiveTraining.enabled = tonumber(enabled) ~= 0
  _SetAdaptiveTrainingText(movie, "")
  return 1
end
local function UpdateAdaptiveTraining(movie, avatar, ic, delta)
  if not mAdaptiveTraining.enabled then
    return
  end
  if mAdaptiveTraining.timer > 0 then
    mAdaptiveTraining.timer = mAdaptiveTraining.timer - delta
    if mAdaptiveTraining.timer <= 0 then
      _SetAdaptiveTrainingText(movie, "")
    end
  else
    local curString = tostring(ic:GetHint())
    if curString ~= mAdaptiveTraining.text then
      _SetAdaptiveTrainingText(movie, curString)
    end
  end
end
function ShowAdaptiveTrainingHint(movie, message, duration)
  if not mAdaptiveTraining.enabled then
    return
  end
  mAdaptiveTraining.timer = tonumber(duration)
  _SetAdaptiveTrainingText(movie, message)
end
function SetAdaptiveTrainingVisible(movie, visible)
  visible = tonumber(visible) ~= 0
  movie:SetVariable("StyleText._visible", visible)
  return 1
end
function ShowComicBookFound(movie, issueNumber, maxIssueNumber)
  mAdaptiveTraining.timer = 2
  _SetAdaptiveTrainingText(movie, string.format(mLocComicBook, issueNumber + 1, maxIssueNumber))
  return true
end
local function UpdateLocalRevivingStatus(movie, avatar)
  if not mAvatarIsLightSensitive then
    return
  end
  local reviveTarget = avatar:GetReviveTarget()
  local isReviving = not IsNull(reviveTarget)
  local revivePct = 0
  if not IsNull(reviveTarget) then
    revivePct = math.floor(reviveTarget:GetReviveProgress() * 100)
  end
  if isReviving ~= mReviving.is or revivePct ~= mReviving.percent then
    FlashMethod(movie, "SetRevivingProgress", isReviving, revivePct, 16777215)
    mReviving.is = isReviving
    mReviving.percent = revivePct
  end
end
local function UpdateTeamLivingStates(movie, delta)
  local humanPlayers = gRegion:GetHumanPlayers()
  local numHumans = #humanPlayers
  local FRIENDSTATE_Ignore = 0
  local FRIENDSTATE_PreDeath = 1
  local FRIENDSTATE_Dead = 2
  for i = 1, numHumans do
    local thisHP = humanPlayers[i]
    if thisHP:IsLocal() then
    else
      local name = thisHP:GetPlayerName()
      local avatar = thisHP:GetAvatar()
      if mLivingStatus[name] == nil then
        mLivingStatus[name] = {
          isPreDeath = false,
          isDead = false,
          processedMsgState = FRIENDSTATE_Ignore,
          processedMsg = "",
          updated = false
        }
      end
      local textToDisplay = ""
      local isDead = true
      local isPreDeath = false
      local preDeathTime = 0
      if not IsNull(avatar) then
        local dc = avatar:DamageControl()
        isPreDeath = dc:IsPreDeath()
        preDeathTime = dc:GetPreDeathTimeLeft()
        isDead = 0 >= avatar:GetHealth()
      end
      mLivingStatus[name].isPreDeath = isPreDeath
      mLivingStatus[name].isDead = isDead
      mLivingStatus[name].updated = true
      if isDead and mLivingStatus[name].processedMsgState == FRIENDSTATE_PreDeath then
        mLivingStatus[name].processedMsgState = FRIENDSTATE_Dead
        FlashMethod(movie, "DeathTeamMate.gotoAndPlay", "Play")
        textToDisplay = string.format("%s%s", name, movie:GetLocalized("/D2/Language/Menu/HUD_FriendDied"))
        movie:SetVariable("DeathTeamMate.Text.text", textToDisplay)
        mLivingStatus[name].processedMsg = textToDisplay
      elseif isPreDeath and not isDead then
        local strFmt = movie:GetLocalized("/D2/Language/Menu/HUD_FriendBleeding")
        local deathTimeLeft = LIB.StringTimeFormat(preDeathTime, "ms")
        if mLivingStatus[name].processedMsgState == FRIENDSTATE_PreDeath and (preDeathTime <= 60 and 55 <= preDeathTime or preDeathTime <= 35 and 30 <= preDeathTime or preDeathTime <= 5 and 0 < preDeathTime) then
          FlashMethod(movie, "DeathTeamMate.gotoAndStop", "Show")
          textToDisplay = string.format(strFmt, name, deathTimeLeft)
        end
        mLivingStatus[name].processedMsgState = FRIENDSTATE_PreDeath
        if textToDisplay ~= mLivingStatus[name].processedMsg then
          movie:SetVariable("DeathTeamMate.Text.text", textToDisplay)
          mLivingStatus[name].processedMsg = textToDisplay
        end
      elseif not isDead and not isPreDeath then
        if mLivingStatus[name].processedMsgState ~= nil and mLivingStatus[name].processedMsgState ~= FRIENDSTATE_Ignore then
          movie:SetVariable("DeathTeamMate.Text.text", "")
        end
        mLivingStatus[name].processedMsgState = FRIENDSTATE_Ignore
      end
    end
  end
  for k, v in pairs(mLivingStatus) do
    if not mLivingStatus[k].updated then
      if mLivingStatus[k].processedMsgState ~= nil and mLivingStatus[k].processedMsgState ~= FRIENDSTATE_Ignore then
        movie:SetVariable("DeathTeamMate.Text.text", "")
      end
      mLivingStatus[k] = nil
    else
      mLivingStatus[k].updated = false
    end
  end
end
local function UpdateGlobalFade(movie, dt)
  if mGlobalFade.state ~= mGlobalFade.STATE_Idle then
    local val = 0
    mGlobalFade.elapsed = mGlobalFade.elapsed + dt
    if mGlobalFade.state == mGlobalFade.STATE_In then
      val = mGlobalFade.elapsed / mGlobalFade.duration
    else
      val = 1 - mGlobalFade.elapsed / mGlobalFade.duration
    end
    if mGlobalFade.elapsed >= mGlobalFade.duration then
      mGlobalFade.state = mGlobalFade.STATE_Idle
      mGlobalFade.elapsed = 0
    end
    movie:SetVariable("_root._alpha", math.floor(val * 100))
  end
end
function SetGlobalFade(movie, duration, shouldFadeIn)
  mGlobalFade.elapsed = 0
  mGlobalFade.duration = tonumber(duration)
  if tonumber(shouldFadeIn) ~= 0 then
    mGlobalFade.state = mGlobalFade.STATE_In
  else
    mGlobalFade.state = mGlobalFade.STATE_Out
  end
end
local _MiniGameSetVisible = function(movie, v)
  movie:SetVariable("MiniGame._visible", tonumber(v) ~= 0)
end
function MiniGameSetVisible(movie, v)
  _MiniGameSetVisible(movie, v)
end
local function _MiniGameSetTime(movie, t)
  local strFmt = movie:GetLocalized("/D2/Language/Menu/HUD_MiniGameTime")
  local strTime = LIB.StringTimeFormat(t, "ms.")
  movie:SetVariable("MiniGame.Time.text", string.format(strFmt, strTime))
end
function MiniGameSetTime(movie, t)
  _MiniGameSetTime(movie, t)
end
local function _MiniGameSetBestTime(movie, bestTime)
  local strTime
  if bestTime == nil then
    strTime = "--.--"
  else
    strTime = LIB.StringTimeFormat(bestTime, "ms.")
  end
  local strFmt = movie:GetLocalized("/D2/Language/Menu/HUD_MiniGameBestTime")
  movie:SetVariable("MiniGame.BestTime.text", string.format(strFmt, strTime))
end
function MiniGameSetBestTime(movie, bestTime)
  _MiniGameSetBestTime(movie, bestTime)
end
local _MiniGameSetBestScore = function(movie, bestScore)
  local strScore
  if bestScore == nil then
    strScore = "--"
  else
    strScore = bestScore
  end
  local strFmt = movie:GetLocalized("/D2/Language/Menu/HUD_MiniGameBestScore")
  movie:SetVariable("MiniGame.BestTime.text", string.format(strFmt, strScore))
end
function MiniGameSetBestScore(movie, bestScore)
  _MiniGameSetBestScore(movie, bestScore)
end
local _MiniGameSetScore = function(movie, score, maxScore)
  local strFmt = movie:GetLocalized("/D2/Language/Menu/HUD_MiniGameScore")
  local strScore = string.format(strFmt, tonumber(score), tonumber(maxScore))
  movie:SetVariable("MiniGame.Score.text", strScore)
end
function MiniGameSetScore(movie, score, maxScore)
  _MiniGameSetScore(movie, score, maxScore)
end
local function UpdateTRC(movie)
  if not mPlatformIsPS3 then
    return
  end
  local iconType = gFlashMgr:GetInputDeviceIconType()
  if iconType == DIT_INVALID then
    if IsNull(gClient:GetVignette()) and not mTRC.isDisplayingControllerDisconnect and not DrawingOSMenu() and mHUDVisible then
      mBanner.loc = "/D2/Language/Menu/ControllerDisconnected"
      mBanner.state = tostring(mBanner.STATE_FadeIn)
      LIB.BannerDisplay(movie, mBanner)
      mTRC.isDisplayingControllerDisconnect = true
      movie:SetVariable("BannerBackground._alpha", 75)
      if not mGameRules:Paused() then
        mGameRules:RequestPause()
        mNeedsUnpause = true
      end
    end
  elseif mTRC.isDisplayingControllerDisconnect then
    mBanner.text = " "
    mBanner.state = tostring(mBanner.STATE_FadeOut)
    LIB.BannerDisplay(movie, mBanner)
    mTRC.isDisplayingControllerDisconnect = false
    movie:SetVariable("BannerBackground._alpha", 0)
    if mNeedsUnpause then
      mGameRules:RequestUnpause()
      mNeedsUnpause = false
    end
  end
end
function Update(movie)
  local deltaTime = DeltaTime()
  UpdateTRC(movie)
  if mLocalPlayers == nil or IsNull(mLocalPlayers[1]) then
    return
  end
  if not mAvatarIsValid or IsNull(mAvatar) then
    InitializeAvatar()
    if not mAvatarIsValid or mAvatarIsCrawling then
      mHealth = HEALTH_Invalid
      return
    end
  end
  local hudVisible = mHudStatus:IsVisible()
  if hudVisible and mGameOptionHudVisible then
    local conversation = mAvatar:GetConversation()
    if not IsNull(conversation) then
      hudVisible = conversation:ShowHUD()
    end
  end
  if hudVisible ~= mHUDVisible or hudVisible ~= mGameOptionHudVisible then
    mHUDVisible = hudVisible and mGameOptionHudVisible
    if mHUDVisible then
      movie:SetVariable("_root._alpha", 100)
      movie:SetVariable("ContextActionPane._alpha", 100)
    else
      movie:SetVariable("_root._alpha", 0.1)
      movie:SetVariable("ContextActionPane._alpha", 100000)
    end
  end
  UpdateBossHealth(movie, deltaTime)
  local inputControl = mAvatar:InputControl()
  mTargetEntity = inputControl:GetCurrentTargetEntity()
  mTargetEntityValid = not IsNull(mTargetEntity)
  if IsNull(mProfileData) and mICIsD2 then
    mProfileData = mInventoryController:GetProfileDataForTalents()
  end
  local weaponMode = mInventoryController:GetWeaponMode()
  mWeapons.hand[WEAPONHAND_Right + 1].weapon = mInventoryController:GetWeaponInHand(Engine.MAIN_HAND)
  mWeapons.hand[WEAPONHAND_Right + 1].weaponIsNull = IsNull(mWeapons.hand[2].weapon)
  mWeapons.hand[WEAPONHAND_Left + 1].weapon = mInventoryController:GetWeaponInHand(Engine.OFF_HAND)
  mWeapons.hand[WEAPONHAND_Left + 1].weaponIsNull = IsNull(mWeapons.hand[1].weapon)
  local hasWeapons = not mWeapons.hand[2].weaponIsNull or not mWeapons.hand[2].weaponIsNull
  UpdateReticuleType(movie, deltaTime, mInventoryController, mAvatar, hasWeapons, inputControl, mTargetEntityValid == false, mTargetEntity, mAvatarIsJackie, mPreDeathRevive.isPreDeath)
  UpdateContextAction(movie, mHudStatus)
  if mFrameNumber == 0 then
    UpdateWeaponInfo(movie, mAvatar, WEAPONHAND_Right, weaponMode)
    UpdateWeaponInfo(movie, mAvatar, WEAPONHAND_Left, weaponMode)
    mWeapons.mode = weaponMode
    UpdateWeaponInventory(movie, mInventoryController)
    UpdateGenericMessage(movie, mHudStatus)
    UpdateGlobalFade(movie, deltaTime)
  elseif mFrameNumber == 1 then
    if mAvatarIsJackie then
      UpdatePowerBar(movie, mAvatar, mInventoryController, deltaTime, mAvatarIsJackie)
      UpdateAdaptiveTraining(movie, mAvatar, mInventoryController, deltaTime * 2)
    end
    if mIsMultiplayer and mGameRules ~= nil then
      UpdateLocalDeathStatus(movie, mAvatar, mHudStatus)
      UpdateLocalRevivingStatus(movie, mAvatar)
      UpdateTeamLivingStates(movie, deltaTime)
    end
    local progressBarAction = mHudStatus.mProgress
    if progressBarAction ~= mLastActionProgress then
      mLastActionProgress = progressBarAction
      if 0 < progressBarAction then
        FlashMethod(movie, "SetRevivingProgress", true, progressBarAction * 100, 16777215)
      else
        FlashMethod(movie, "SetRevivingProgress", false, 0, 16777215)
      end
    end
    UpdateEventMessageList(movie)
  end
  UpdateEssence(movie, deltaTime)
  UpdateComboState(movie, deltaTime)
  UpdateHealth(movie, deltaTime, mAvatar)
  UpdateDamageIndicators(movie, mAvatar, mHudStatus, deltaTime)
  UpdateActiveGameState(movie, deltaTime)
  UpdateCollectionInfo(movie, deltaTime)
  mFrameNumber = mFrameNumber + 1
  if 2 <= mFrameNumber then
    mFrameNumber = 0
  end
  local newInputDeviceType = gFlashMgr:GetInputDeviceIconType()
  if mInputDeviceType ~= newInputDeviceType then
    mInputDeviceType = newInputDeviceType
    _InvalidateActionTextFields(movie)
  end
  local postProcess = mAvatar:CameraControl():GetPostProcessInfo()
  if postProcess.fade ~= 0 then
    mCrossFadeActive = true
    local alpha = 100 * (1 - math.abs(postProcess.fade))
    movie:SetVariable("_root._alpha", alpha)
    mMovieObjective:SetVariable("_root._alpha", alpha)
    mMovieSubTitle:SetVariable("ConversationHeader._alpha", alpha)
  elseif mCrossFadeActive then
    mCrossFadeActive = false
    movie:SetVariable("_root._alpha", 100)
    mMovieObjective:SetVariable("_root._alpha", 100)
    mMovieSubTitle:SetVariable("ConversationHeader._alpha", 100)
  end
end
function OnAvatarChange(movie)
  InitializeAvatar()
  InitializeReticule(movie)
  _UpdateTalentStates(movie)
  ClearWeaponInfo(mMovie, WEAPONHAND_Left)
  ClearWeaponInfo(mMovie, WEAPONHAND_Right)
  if mICIsD2 then
    UpdateAdaptiveTraining(movie, mAvatar, mInventoryController, 0)
    mAdaptiveTraining.text = ""
  end
  mMovieSubTitle:Execute("OnAvatarChange", "")
  return true
end
function SetHudAlpha(movie, a)
  if mGameOptionHudVisible then
    movie:SetVariable("_root._alpha", tonumber(a))
  end
end
function onKeyDown_TOGGLE_CHAT_WINDOW(movie)
  if not IsNull(mMovieChatWindow) then
    mMovieChatWindow = gFlashMgr:PushMovie(movieChatWindowW)
  end
end

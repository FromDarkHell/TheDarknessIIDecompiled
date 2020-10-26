local LIB = require("D2.Menus.SharedLibrary")
local interpolator = require("D2.Menus.Interpolator")
local CalloutBarLibrary = require("D2.Menus.CalloutBar")
soundFocus = Resource()
soundBuyTalent = Resource()
soundCannotBuyTalent = Resource()
soundZoomIn = Resource()
soundZoomOut = Resource()
soundTalentAvailable = Resource()
soundBackground = Resource()
soundBackOut = Resource()
popupConfirmMovie = WeakResource()
hudMovie = WeakResource()
binkTexture = Resource()
forcePurchaseTalent = WeakResource()
purchaseTalentTag = Symbol()
movieFadeInRate = 100
smokeTexture = Resource()
scrollTalentTreesHintDelay = 2
local STATE_Locked = 0
local STATE_CantAfford = 1
local STATE_Available = 2
local STATE_Purchased = 3
local statusSelect = "/D2/Language/Talents/Talents_Status_Purchase"
local groupSelect = "/D2/Language/Talents/Browse_Talent_Group"
local groupSelectBrief = "/D2/Language/Talents/Browse_Talent_Group_Brief"
local statusBack = "/D2/Language/Menu/Shared_Back"
local statusRespec = "/D2/Language/Talents/Talents_Status_Respec"
local nextGroup = "/D2/Language/Talents/Talents_Next_Group"
local prevGroup = "/D2/Language/Talents/Talents_Previous_Group"
local changeGroup = "/D2/Language/Talents/Talents_ChangeGroup"
local tutorialText = "/D2/Language/Talents/Talents_Tutorial_Text"
local backFailText = "/D2/Language/Talents/Talents_Tutorial_BackFail_Text"
local cycleGroupsText = "/D2/Language/Talents/Talents_Tutorial_CycleGroups_Text"
local popupItemOk = "/D2/Language/Menu/Confirm_Item_Ok"
local popupItemCancel = "/D2/Language/Menu/Confirm_Item_Cancel"
local mLocCRLN = "/D2/Language/Menu/Shared_CRLN"
local mLocalPlayers = {}
local mAvatar, mInventoryController, mProfileData
local unpauseOnExit = false
local mSoundInstance, mTutorialMovie
local mWaitingForForcePurchaseTalent = false
local mScrollTalentTreesHintTimer = -1
local mScreenAlpha = 0
local mMovie
local inputBlocked = true
local mActiveTalent, mActiveGroupInfo, mGroupOnTop, mGroupsToToggle
local mDefaultTalent = ""
local mDefaultGroup = ""
local mTalentGroups = {}
local mGroupingInfo = {}
local mFadeInComplete = false
local mActiveCharacterType
local mHasPurchasedTalent = false
local mOneLineTitleHeight, mOriginalTitleY
local mPopupClips = {}
local mOriginalBackgroundHeight = 0
local mCalloutBar
local mMaxLines = 0
local mIsCalloutFocused = false
local mItemHovered
local mPrevDiff = 0
local platform
local function CallFunctionOnEachTalent(tree, _function)
  local done
  for k, v in pairs(tree.childList) do
    done = _function(v)
    if not done then
      CallFunctionOnEachTalent(v, _function)
    end
  end
end
local function _GetTalentByName(talentName, tree)
  for k, v in pairs(tree.childList) do
    if v.name == talentName then
      return v
    else
      local childrenResult = _GetTalentByName(talentName, v)
      if not IsNull(childrenResult) then
        return childrenResult
      end
    end
  end
  return nil
end
local function GetTalentByName(talentName)
  return (_GetTalentByName(talentName, mTalentGroups))
end
local function GetGroupRootTalent(talent)
  while not IsNull(talent.parent) and talent.parent.name ~= mDefaultTalent and talent.parent.name ~= "Main" do
    talent = talent.parent
  end
  return talent
end
local function ShouldDisplayDLC()
  if not Engine.GetDownloadableContentMgr():IsDlcInstalled(D2_Game.DLC_PACK_DARKLING_AND_TALENTS) then
    return false
  end
  local dlcTalents = {
    "RelicHunter",
    "GourmetHearts"
  }
  for i = 1, #dlcTalents do
    if IsNull(mInventoryController:GetTalentByResName(dlcTalents[i])) then
      return false
    end
  end
  return true
end
local function CanReclaim()
  local reclaimAllowed = false
  local function reclaimCheckFunction(talent)
    if talent.purchased and not IsNull(talent.res) and talent.res:AllowRefunds() and not mInventoryController:IsDefaultTalent(talent.res) then
      reclaimAllowed = true
      return true
    end
  end
  CallFunctionOnEachTalent(mTalentGroups, reclaimCheckFunction)
  return reclaimAllowed
end
local function UpdatePopupText()
  if not IsNull(mActiveTalent) then
    if IsNull(mOneLineTitleHeight) then
      mOneLineTitleHeight = tonumber(mMovie:GetVariable("Popup.title.textHeight"))
      mOriginalTitleY = tonumber(mMovie:GetVariable("Popup.title._y"))
    end
    mMovie:SetLocalized("Popup.Title.text", string.format("/D2/Language/Talents/Talent_%s_Name", mActiveTalent.name))
    local titleHeight = tonumber(mMovie:GetVariable("Popup.Title.textHeight"))
    local newTitleY = mOriginalTitleY
    if titleHeight > mOneLineTitleHeight + 5 then
      newTitleY = math.floor(mOriginalTitleY - 15)
    end
    mMovie:SetVariable("Popup.title._y", newTitleY)
    FlashMethod(mMovie, "Popup.icon.gotoAndStop", mActiveTalent.name)
    mMovie:SetLocalized("Popup.Description.text", string.format("/D2/Language/Talents/Talent_%s_Description", mActiveTalent.name))
    local descriptionHeight = tonumber(mMovie:GetVariable("Popup.Description.textHeight")) + 30
    local minimumHeight = 60
    if descriptionHeight < minimumHeight then
      descriptionHeight = minimumHeight
    end
    local diff = descriptionHeight - minimumHeight
    if 5 < math.abs(mPrevDiff - diff) then
      mPrevDiff = diff
      interpolator:Interpolate(mMovie, "Popup", interpolator.EASE_OUT, {"_x", "_y"}, {
        240,
        74 - diff * 0.5
      }, 0.1)
      for i = 1, #mPopupClips do
        interpolator:Interpolate(mMovie, mPopupClips[i].Clip, interpolator.EASE_OUT, {"_y"}, {
          math.floor(mPopupClips[i].OriginalY + diff)
        }, 0.1)
      end
      interpolator:Interpolate(mMovie, "Popup.Background", interpolator.EASE_OUT, {"_height"}, {
        mOriginalBackgroundHeight + diff
      }, 0.1)
    end
    local workingString = ""
    local theRes = mActiveTalent.res
    local talentPoints = mProfileData:GetTalentPoints(mActiveCharacterType)
    local fmt = mMovie:GetLocalized("/D2/Language/Talents/Talents_Currency")
    mMovie:SetVariable("Popup.Essence.text", string.format(fmt, talentPoints))
    local costColour = 13421772
    if not IsNull(theRes) and mInventoryController:GetTalentLevel(theRes) > 0 then
    else
      local hasEnoughEssence = true
      if not IsNull(theRes) then
        local fmt = mMovie:GetLocalized("/D2/Language/Talents/Talents_Cost")
        local talentCost = theRes:GetCost()
        if talentPoints < talentCost then
          costColour = 16711680
        end
        workingString = workingString .. string.format(fmt, talentCost) .. mLocCRLN
      end
    end
    mMovie:SetVariable("Popup.Requirements.text", workingString)
    mMovie:SetVariable("Popup.Requirements.textColor", costColour)
  end
end
local function IsForcedTalentPurchased()
  if not IsNull(forcePurchaseTalent) then
    local talent = mInventoryController:GetTalentByResName(forcePurchaseTalent:GetResourceName())
    if not IsNull(talent) and mInventoryController:GetTalentLevel(talent) == 0 then
      return false
    end
  end
  return true
end
local function NewTalent(_n, _clipname, _m, _lines)
  local struct = {
    name = _n,
    parentName = nil,
    level = 0,
    movement = _m,
    childList = {},
    res = nil,
    isVisible = false,
    clipname = _clipname,
    wasJustPurchased = false,
    state = STATE_Locked,
    lines = _lines
  }
  struct.res = mInventoryController:GetTalentByResName(struct.name)
  return struct
end
local function NewChildTalent(group, _n, _clipname, _m, _lines)
  local newTalent = NewTalent(_n, _clipname, _m, _lines)
  newTalent.parentName = group.name
  newTalent.parent = group
  group.childList[_n] = newTalent
  return newTalent
end
local function UpdateLineVisibility()
  for l = 0, mMaxLines do
    mMovie:SetVariable("DrawingArea.lineMasks.line" .. l .. "._visible", false)
  end
  local function visibilityFunction(talent)
    if talent.state == STATE_Purchased and not IsNull(talent.lines) and (IsNull(mActiveTalent) or mActiveTalent.name == mDefaultTalent or mGroupingInfo[talent.root.name] == mGroupingInfo[mActiveTalent.root.name]) then
      for i, v in pairs(talent.lines) do
        mMovie:SetVariable("DrawingArea.lineMasks." .. v .. "._visible", true)
      end
    end
  end
  CallFunctionOnEachTalent(mTalentGroups, visibilityFunction)
end
local function SetGroupOnTop(newGroupOnTop, callback)
  if type(newGroupOnTop) == "string" then
    local index
    for i, v in ipairs(mGroupsToToggle) do
      if v == newGroupOnTop then
        index = i
        break
      end
    end
    if not IsNull(index) then
      newGroupOnTop = index
    else
      return
    end
  end
  print("SetGroupOnTop(" .. tostring(newGroupOnTop) .. ")")
  mGroupOnTop = newGroupOnTop
  local rootTalent = GetTalentByName(mGroupsToToggle[mGroupOnTop])
  local currentRotation = tonumber(mMovie:GetVariable("DrawingArea._rotation"))
  local newRotation = mGroupingInfo[rootTalent.name].rotation
  if 180 < newRotation - currentRotation then
    newRotation = newRotation - 360
  end
  local groupingInfo = mGroupingInfo[rootTalent.name]
  if mActiveTalent.name == mDefaultTalent then
    groupingInfo = mGroupingInfo[mDefaultTalent]
    gRegion:PlaySound(soundZoomOut, Vector(), false)
  else
    gRegion:PlaySound(soundZoomIn, Vector(), false)
  end
  inputBlocked = true
  local function fullCallback()
    if not IsNull(callback) then
      callback()
    end
    inputBlocked = false
  end
  interpolator:Interpolate(mMovie, "DrawingArea", interpolator.EASE_IN, {
    "_rotation",
    "_xscale",
    "_yscale",
    "_x",
    "_y",
    "_alpha"
  }, {
    newRotation,
    groupingInfo.scale,
    groupingInfo.scale,
    groupingInfo.zoomedX,
    groupingInfo.zoomedY,
    100
  }, 0.35, 0, nil, false)
  local iconRotation = -newRotation
  local function iconFunction(talent)
    local iconCallback
    if talent.name == mDefaultTalent then
      iconCallback = fullCallback
    end
    local currentIconRotation = tonumber(mMovie:GetVariable("DrawingArea." .. talent.clipname .. "._rotation"))
    local newIconRotation = iconRotation
    if 180 < newIconRotation - currentIconRotation then
      newIconRotation = newIconRotation - 360
    end
    interpolator:Interpolate(mMovie, "DrawingArea." .. talent.clipname, interpolator.EASE_IN, {"_rotation"}, {newIconRotation}, 0.35, 0, iconCallback)
  end
  CallFunctionOnEachTalent(mTalentGroups, iconFunction)
end
local function SwitchActiveTalent(newTalent)
  local defaultTalent = GetTalentByName(mDefaultTalent)
  if newTalent.name ~= mDefaultTalent and not IsNull(defaultTalent.res) and defaultTalent.state ~= STATE_Purchased then
    return
  end
  if mActiveTalent == newTalent then
    return
  end
  print("SwitchActiveTalent active talent " .. tostring(newTalent.name))
  local previousTalent = mActiveTalent
  mActiveTalent = newTalent
  if not IsNull(newTalent) then
    gRegion:PlaySound(soundFocus, Vector(), false)
    interpolator:Interpolate(mMovie, "DrawingArea.Hilight", interpolator.EASE_OUT, {"_x", "_y"}, {
      tonumber(mMovie:GetVariable("DrawingArea." .. mActiveTalent.clipname .. "._x")),
      tonumber(mMovie:GetVariable("DrawingArea." .. mActiveTalent.clipname .. "._y"))
    }, 0.15)
    UpdatePopupText()
    print("New active talent " .. tostring(mActiveTalent.name))
    do
      local rootTalent = GetGroupRootTalent(mActiveTalent)
      if IsForcedTalentPurchased() then
        mMovie:SetVariable("callouts._visible", true)
      end
      if not IsNull(rootTalent) and mGroupingInfo[rootTalent.name] ~= nil and mGroupingInfo[rootTalent.name] ~= mActiveGroupInfo then
        mActiveGroupInfo = mGroupingInfo[rootTalent.name]
        inputBlocked = true
        local function finalCallback()
          if not IsForcedTalentPurchased() then
            mTutorialMovie = mMovie:PushChildMovie(popupConfirmMovie)
            if not IsNull(mTutorialMovie) then
              FlashMethod(mTutorialMovie, "CreateOkCancel", tutorialText, popupItemOk, "-", "TutorialCallback")
              mTutorialMovie:Execute("SetRightItemText", "")
            end
          else
            mMovie:SetFocus("focusDraw")
            inputBlocked = false
          end
        end
        local newGroupOnTop = mActiveTalent.root.name
        if mActiveTalent.name == mDefaultTalent then
          newGroupOnTop = mGroupOnTop
          mGroupOnTop = 0
        end
        SetGroupOnTop(newGroupOnTop, finalCallback)
        local function iconFunction(talent)
          local newColor = 4473924
          local flareVisibility = false
          if mGroupingInfo[talent.root.name] == mGroupingInfo[rootTalent.name] or rootTalent.name == mDefaultTalent or talent.name == mDefaultTalent then
            newColor = 16777215
            flareVisibility = true
          end
          mMovie:SetVariable("DrawingArea." .. talent.clipname .. ".ItemIcon._color", newColor)
          if talent.state == STATE_Available or talent.state == STATE_Purchased then
            mMovie:SetVariable("DrawingArea." .. talent.clipname .. ".ring._color", newColor)
            mMovie:SetVariable("DrawingArea." .. talent.clipname .. ".flare._visible", flareVisibility)
          end
        end
        CallFunctionOnEachTalent(mTalentGroups, iconFunction)
        UpdateLineVisibility()
      end
    end
  end
end
local function ToggleGroupOnTop(direction)
  if IsForcedTalentPurchased() then
    local newGroupOnTop = mGroupOnTop
    while IsNull(mGroupsToToggle[newGroupOnTop]) or mGroupingInfo[mGroupsToToggle[mGroupOnTop]] == mGroupingInfo[mGroupsToToggle[newGroupOnTop]] do
      newGroupOnTop = newGroupOnTop + direction
      if direction == 1 and newGroupOnTop > #mGroupsToToggle then
        newGroupOnTop = 1
      elseif direction == -1 and newGroupOnTop < 1 then
        newGroupOnTop = #mGroupsToToggle
      end
    end
    if mActiveTalent.name == mDefaultTalent then
      SetGroupOnTop(Clamp(newGroupOnTop, 1, #mGroupsToToggle))
    else
      SwitchActiveTalent(GetTalentByName(mGroupsToToggle[newGroupOnTop]))
    end
  end
end
function Update(mMovie)
  local rt = RealDeltaTime()
  interpolator:Update(mMovie, rt)
  if not mFadeInComplete then
    if mScreenAlpha < 100 then
      mScreenAlpha = mScreenAlpha + rt * movieFadeInRate
      if 100 < mScreenAlpha then
        mScreenAlpha = 100
      end
      mMovie:SetVariable("_alpha", mScreenAlpha)
      mMovie:SetBackgroundAlpha(mScreenAlpha * 0.01)
    else
      mFadeInComplete = true
      local talent = GetTalentByName(mDefaultTalent)
      if not IsNull(talent) and talent.purchased then
        SwitchActiveTalent(GetTalentByName(mDefaultGroup))
      else
        SwitchActiveTalent(GetTalentByName(mDefaultTalent))
      end
    end
  end
  if IsNull(mSoundInstance) then
    mSoundInstance = gRegion:PlaySound(soundBackground, Vector(), false)
  end
  if not IsForcedTalentPurchased() then
    mWaitingForForcePurchaseTalent = true
  end
  if mWaitingForForcePurchaseTalent and IsForcedTalentPurchased() then
    mScrollTalentTreesHintTimer = scrollTalentTreesHintDelay
    mWaitingForForcePurchaseTalent = false
  end
  if 0 <= mScrollTalentTreesHintTimer then
    mScrollTalentTreesHintTimer = mScrollTalentTreesHintTimer - rt
    if mScrollTalentTreesHintTimer < 0 then
      mTutorialMovie = mMovie:PushChildMovie(popupConfirmMovie)
      if not IsNull(mTutorialMovie) then
        FlashMethod(mTutorialMovie, "CreateOkCancel", cycleGroupsText, popupItemOk, "-", "")
        mTutorialMovie:Execute("SetRightItemText", "")
      end
    end
  end
  if not IsNull(mCalloutBar) then
    local callouts = {}
    if not IsNull(mActiveTalent) then
      if mActiveTalent.name == mDefaultTalent and mActiveTalent.state == STATE_Purchased then
        table.insert(callouts, {
          Label = groupSelect,
          Callback = "callout_MENU_SELECT"
        })
      elseif mActiveTalent.state == STATE_Available then
        table.insert(callouts, {
          Label = statusSelect,
          Callback = "callout_MENU_SELECT"
        })
      end
    end
    if IsForcedTalentPurchased() then
      table.insert(callouts, {
        Label = changeGroup,
        Callback = "onKeyDown_MENU_RTRIGGER2"
      })
    end
    if CanReclaim() then
      table.insert(callouts, {
        Label = statusRespec,
        Callback = "onKeyDown_MENU_GENERIC1"
      })
    end
    table.insert(callouts, {
      Label = statusBack,
      Callback = "onKeyDown_MENU_CANCEL"
    })
    mCalloutBar:SetCallouts(callouts)
  end
  mMovie:SetVariable("callouts._x", tonumber(mMovie:GetVariable("DrawingArea._x")))
  mMovie:SetVariable("callouts._y", tonumber(mMovie:GetVariable("DrawingArea._y")))
  mMovie:SetVariable("callouts._xscale", tonumber(mMovie:GetVariable("DrawingArea._xscale")) * 1.6666)
  mMovie:SetVariable("callouts._yscale", tonumber(mMovie:GetVariable("DrawingArea._yscale")) * 1.6666)
  mMovie:SetVariable("callouts._alpha", tonumber(mMovie:GetVariable("DrawingArea._alpha")))
end
local function UpdateTalentStates(firstTime)
  local queueChangesToAvailable = {}
  local function stateFunction(talent)
    local frame = "Available"
    local state = STATE_Available
    if not IsNull(talent.res) then
      talent.level = mInventoryController:GetTalentLevel(talent.res)
      talent.isLocked = mInventoryController:IsTalentLocked(talent.res)
      talent.canBuy = mInventoryController:CanBuyTalent(talent.res)
      talent.cost = talent.res:GetCost()
    else
      print("Talent:" .. talent.name .. " has no res!")
      talent.level = 1
      talent.isLocked = false
      talent.canBuy = false
      talent.cost = 0
    end
    talent.purchased = talent.level > 0
    local availableTalentPoints = mProfileData:GetTalentPoints(mActiveCharacterType)
    if talent.purchased then
      frame = "Purchased"
      state = STATE_Purchased
    elseif talent.isLocked or availableTalentPoints < talent.cost or not talent.canBuy then
      frame = "Locked"
      state = STATE_Locked
    end
    if talent.state ~= state then
      if not firstTime and state == STATE_Available then
        table.insert(queueChangesToAvailable, talent.clipname)
      end
      talent.state = state
      print("Updating state for talent " .. tostring(talent.name) .. " level=" .. tostring(talent.level) .. " isLocked=" .. tostring(talent.isLocked) .. " canBuy=" .. tostring(talent.canBuy) .. " state=" .. tostring(talent.state))
      FlashMethod(mMovie, "DrawingArea." .. talent.clipname .. ".gotoAndStop", frame)
      FlashMethod(mMovie, "DrawingArea." .. talent.clipname .. ".ItemIcon.gotoAndStop", talent.name)
    end
  end
  CallFunctionOnEachTalent(mTalentGroups, stateFunction)
  for i, v in ipairs(queueChangesToAvailable) do
    local ring = "DrawingArea." .. v .. ".ring"
    local flare = "DrawingArea." .. v .. ".flare"
    mMovie:SetVariable(ring .. "._alpha", 0)
    mMovie:SetVariable(flare .. "._alpha", 0)
    mMovie:SetVariable(ring .. "._rotation", -50)
    local function ringCallback()
      gRegion:PlaySound(soundTalentAvailable, Vector(), false)
      interpolator:Interpolate(mMovie, ring, interpolator.EASE_OUT, {"_rotation", "_alpha"}, {0, 100}, 0.3)
      interpolator:Interpolate(mMovie, flare, interpolator.EASE_OUT, {"_alpha"}, {100}, 0.3)
    end
    interpolator:Interpolate(mMovie, ring, interpolator.LINEAR, {"_alpha"}, {0}, 0.4 + 0.4 * i, 0, ringCallback)
  end
  UpdateLineVisibility()
end
local function InitJackie(mMovie)
  mGroupingInfo.EatHeartTalent = {
    scale = 60,
    zoomedX = 365,
    zoomedY = 290,
    rotation = 0
  }
  mGroupingInfo.HangTime = {
    scale = 100,
    zoomedX = 365,
    zoomedY = 470,
    rotation = 180
  }
  mGroupingInfo.Swarm = {
    scale = 100,
    zoomedX = 365,
    zoomedY = 470,
    rotation = 90
  }
  mGroupingInfo.GunChanneling = mGroupingInfo.Swarm
  mGroupingInfo.CombatBelt = {
    scale = 100,
    zoomedX = 365,
    zoomedY = 470,
    rotation = 0
  }
  mGroupingInfo.HealthExecutions = {
    scale = 100,
    zoomedX = 365,
    zoomedY = 470,
    rotation = 270
  }
  mDefaultTalent = "EatHeartTalent"
  mDefaultGroup = "HangTime"
  mGroupsToToggle = {
    "CombatBelt",
    "HealthExecutions",
    "HangTime",
    "Swarm",
    "GunChanneling"
  }
  local shouldDisplayDLC = ShouldDisplayDLC()
  if shouldDisplayDLC then
    mGroupingInfo.GourmetHearts = mGroupingInfo.HealthExecutions
    table.insert(mGroupsToToggle, 3, "GourmetHearts")
  end
  mGroupOnTop = 1
  mTalentGroups = NewTalent("Main")
  NewChildTalent(mTalentGroups, "EatHeartTalent", "icon0")
  local group = mTalentGroups.childList.EatHeartTalent
  NewChildTalent(group, "HangTime", "icon9", {
    left = "EatHeartHealing",
    right = "GrabDarkling",
    up = "GroundPound"
  }, {"line11"})
  NewChildTalent(group.childList.HangTime, "GrabDarkling", "icon10", {
    down = "HangTime",
    up = "DarkBlast",
    left = "GroundPound"
  }, {"line12", "line13"})
  NewChildTalent(group.childList.HangTime.childList.GrabDarkling, "DarkBlast", "icon12", {
    down = "GrabDarkling",
    left = "DemonArmTalent",
    up = "BlackHoleSize",
    right = "DarkLife"
  }, {"line15"})
  NewChildTalent(group.childList.HangTime.childList.GrabDarkling.childList.DarkBlast, "DarkLife", "icon36", {
    down = "GrabDarkling",
    up = "BlackHoleSize",
    left = "DarkBlast"
  }, {"line46"})
  NewChildTalent(group.childList.HangTime, "EatHeartHealing", "icon34", {
    down = "HangTime",
    up = "DemonArmTalent",
    right = "GroundPound"
  }, {
    "line12",
    "line14",
    "line44"
  })
  NewChildTalent(group.childList.HangTime.childList.EatHeartHealing, "DemonArmTalent", "icon13", {
    left = "BlackHole",
    up = "BlackHoleSize",
    down = "GroundPound",
    right = "DarkBlast"
  }, {"line16"})
  NewChildTalent(group.childList.HangTime.childList.EatHeartHealing.childList.DemonArmTalent, "BlackHole", "icon14", {
    down = "EatHeartHealing",
    right = "DemonArmTalent",
    up = "BlackHoleSize"
  }, {"line17"})
  NewChildTalent(group.childList.HangTime.childList.EatHeartHealing.childList.DemonArmTalent.childList.BlackHole, "BlackHoleSize", "icon35", {
    down = "DemonArmTalent",
    left = "BlackHole",
    right = "DarkLife"
  }, {"line45"})
  NewChildTalent(group.childList.HangTime, "GroundPound", "icon11", {
    down = "HangTime",
    left = "EatHeartHealing",
    right = "GrabDarkling",
    up = "DemonArmTalent"
  }, {
    "line12",
    "line14",
    "line43"
  })
  NewChildTalent(group, "Swarm", "icon15", {
    right = "SuperSwarmCooldown",
    up = "SwarmStun",
    left = "GunChanneling"
  }, {"line18", "line19"})
  NewChildTalent(group.childList.Swarm, "SuperSwarmCooldown", "icon17", {
    down = "Swarm",
    up = "SwarmTargets",
    left = "SwarmStun",
    right = "SwarmTargets"
  }, {"line27", "line29"})
  NewChildTalent(group.childList.Swarm.childList.SuperSwarmCooldown, "SwarmTargets", "icon21", {
    down = "SuperSwarmCooldown",
    left = "SwarmDamage"
  }, {"line30"})
  NewChildTalent(group.childList.Swarm, "SwarmStun", "icon18", {
    down = "Swarm",
    up = "SwarmDamage",
    right = "SuperSwarmCooldown",
    left = "GcDuration"
  }, {"line27", "line28"})
  NewChildTalent(group.childList.Swarm.childList.SwarmStun, "SwarmDamage", "icon22", {
    down = "SwarmStun",
    right = "SwarmTargets",
    left = "GcHod"
  }, {"line31"})
  NewChildTalent(group, "GunChanneling", "icon16", {
    right = "Swarm",
    left = "SuperGcCooldown",
    up = "GcDuration"
  }, {"line18", "line20"})
  NewChildTalent(group.childList.GunChanneling, "SuperGcCooldown", "icon20", {
    down = "GunChanneling",
    up = "GcAutoTarget",
    right = "GcDuration"
  }, {"line21", "line22"})
  NewChildTalent(group.childList.GunChanneling.childList.SuperGcCooldown, "GcAutoTarget", "icon24", {
    down = "SuperGcCooldown",
    right = "GcHod"
  }, {"line24"})
  NewChildTalent(group.childList.GunChanneling, "GcDuration", "icon19", {
    down = "GunChanneling",
    up = "GcHod",
    left = "SuperGcCooldown",
    right = "SwarmStun"
  }, {"line21", "line23"})
  NewChildTalent(group.childList.GunChanneling.childList.GcDuration, "GcHod", "icon23", {
    down = "GcDuration",
    left = "GcAutoTarget",
    right = "SwarmDamage"
  }, {"line26"})
  NewChildTalent(group, "CombatBelt", "icon25", {
    up = "ActivePump",
    right = "WeaponHandling",
    left = "ActivePump"
  }, {"line32"})
  NewChildTalent(group.childList.CombatBelt, "WeaponHandling", "icon26", {
    down = "CombatBelt",
    left = "ActivePump",
    up = "DarknessPistol",
    right = "DarknessSmg"
  }, {"line33", "line34"})
  NewChildTalent(group.childList.CombatBelt, "ActivePump", "icon28", {
    down = "CombatBelt",
    right = "WeaponHandling",
    up = "DarknessShotgun",
    left = "DarknessAssaultRifle"
  }, {
    "line33",
    "line36",
    "line38"
  })
  NewChildTalent(group.childList.CombatBelt, "DarknessPistol", "icon37", {
    down = "WeaponHandling",
    up = "SmallArmsDamage",
    left = "DarknessShotgun",
    right = "DarknessSmg"
  }, {
    "line33",
    "line36",
    "line39",
    "line47"
  })
  NewChildTalent(group.childList.CombatBelt.childList.DarknessPistol, "DarknessSmg", "icon29", {
    down = "WeaponHandling",
    up = "SmallArmsDamage",
    left = "DarknessPistol"
  }, {"line35"})
  NewChildTalent(group.childList.CombatBelt.childList.DarknessPistol.childList.DarknessSmg, "SmallArmsDamage", "icon38", {
    left = "2HWeaponDamage",
    down = "DarknessSmg"
  }, {"line49"})
  NewChildTalent(group.childList.CombatBelt, "DarknessShotgun", "icon27", {
    right = "DarknessPistol",
    left = "DarknessAssaultRifle",
    down = "ActivePump",
    up = "2HWeaponDamage"
  }, {
    "line33",
    "line36",
    "line39",
    "line37"
  })
  NewChildTalent(group.childList.CombatBelt.childList.DarknessShotgun, "DarknessAssaultRifle", "icon30", {
    right = "DarknessShotgun",
    down = "ActivePump",
    up = "2HWeaponDamage",
    left = "2HWeaponDamage"
  }, {"line25"})
  NewChildTalent(group.childList.CombatBelt.childList.DarknessShotgun.childList.DarknessAssaultRifle, "2HWeaponDamage", "icon31", {
    right = "SmallArmsDamage",
    down = "DarknessAssaultRifle"
  }, {"line40"})
  NewChildTalent(group, "HealthExecutions", "icon1", {
    left = "HealthExecutionUpgrade",
    up = "HealthExecutionUpgrade",
    right = "AmmoExecutions"
  }, {"line0"})
  NewChildTalent(group.childList.HealthExecutions, "AmmoExecutions", "icon3", {
    up = "ExpertGrabber",
    down = "HealthExecutions",
    left = "HealthExecutionUpgrade",
    right = "DemonicExecutions"
  }, {"line1", "line2"})
  NewChildTalent(group.childList.HealthExecutions.childList.AmmoExecutions, "AmmoExecutionUpgrade", "icon5", {
    left = "PowerExecutions",
    right = "ExpertGrabber",
    down = "HealthExecutionUpgrade",
    up = "PowerExecutionUpgrade"
  }, {
    "line4",
    "line7",
    "line48",
    "line50"
  })
  NewChildTalent(group.childList.HealthExecutions.childList.AmmoExecutions, "ExpertGrabber", "icon39", {
    left = "AmmoExecutionUpgrade",
    down = "AmmoExecutions",
    right = "DemonicExecutions",
    up = "DemonicExecutionUpgrade"
  }, {
    "line4",
    "line7",
    "line8"
  })
  NewChildTalent(group.childList.HealthExecutions.childList.AmmoExecutions, "PowerExecutions", "icon6", {
    up = "PowerExecutionUpgrade",
    left = "PowerExecutionUpgrade",
    down = "HealthExecutionUpgrade",
    right = "AmmoExecutionUpgrade"
  }, {
    "line4",
    "line7",
    "line48",
    "line9"
  })
  NewChildTalent(group.childList.HealthExecutions.childList.AmmoExecutions.childList.PowerExecutions, "PowerExecutionUpgrade", "icon8", {
    left = "PowerExecutions",
    down = "PowerExecutions",
    right = "DemonicExecutionUpgrade"
  }, {"line10"})
  NewChildTalent(group.childList.HealthExecutions.childList.AmmoExecutions, "DemonicExecutions", "icon4", {
    left = "ExpertGrabber",
    down = "AmmoExecutions",
    up = "DemonicExecutionUpgrade",
    right = "DemonicExecutionUpgrade"
  }, {"line4", "line5"})
  NewChildTalent(group.childList.HealthExecutions.childList.AmmoExecutions.childList.DemonicExecutions, "DemonicExecutionUpgrade", "icon7", {
    left = "PowerExecutionUpgrade",
    down = "DemonicExecutions",
    right = "DemonicExecutions"
  }, {"line6"})
  NewChildTalent(group.childList.HealthExecutions, "HealthExecutionUpgrade", "icon2", {
    right = "AmmoExecutions",
    down = "HealthExecutions",
    up = "AmmoExecutionUpgrade",
    left = "PowerExecutions"
  }, {"line1", "line3"})
  if shouldDisplayDLC then
    NewChildTalent(group, "GourmetHearts", "icon32", {
      right = "HealthExecutionUpgrade",
      up = "RelicHunter"
    }, {"line41"})
    NewChildTalent(group.childList.GourmetHearts, "RelicHunter", "icon33", {
      down = "GourmetHearts",
      right = "PowerExecutions"
    }, {"line42"})
    group.childList.HealthExecutions.childList.HealthExecutionUpgrade.movement.left = "GourmetHearts"
    group.childList.HealthExecutions.childList.AmmoExecutions.childList.PowerExecutions.movement.left = "RelicHunter"
  end
end
local function InitJimmy(mMovie)
  mGroupingInfo.Darklings = {
    scale = 100,
    zoomedX = 365,
    zoomedY = 470,
    rotation = 115
  }
  mGroupingInfo.BaseAuraJimmy = {
    scale = 100,
    zoomedX = 365,
    zoomedY = 470,
    rotation = 0
  }
  mGroupingInfo.DarknessOneHandedGuns = {
    scale = 100,
    zoomedX = 365,
    zoomedY = 470,
    rotation = 258
  }
  mGroupingInfo.VendettaDarknessJimmy = {
    scale = 60,
    zoomedX = 365,
    zoomedY = 290,
    rotation = 0
  }
  mDefaultTalent = "VendettaDarknessJimmy"
  mDefaultGroup = "BaseAuraJimmy"
  mGroupsToToggle = {
    "BaseAuraJimmy",
    "DarknessOneHandedGuns",
    "Darklings"
  }
  mGroupOnTop = 1
  mTalentGroups = NewTalent("Main")
  NewChildTalent(mTalentGroups, "VendettaDarknessJimmy", "icon0")
  group = mTalentGroups.childList.VendettaDarknessJimmy
  NewChildTalent(group, "Darklings", "icon3", {
    up = "StrongDarklings",
    left = "DarklingKiller",
    right = "StrongDarklings"
  }, {"line11"})
  NewChildTalent(group.childList.Darklings, "DarklingKiller", "icon4", {
    up = "DarklingExplode",
    down = "Darklings",
    right = "StrongDarklings"
  }, {"line12", "line13"})
  NewChildTalent(group.childList.Darklings.childList.DarklingKiller, "DarklingExplode", "icon6", {
    right = "SuperStrongDarklings",
    down = "DarklingKiller"
  }, {"line15"})
  NewChildTalent(group.childList.Darklings, "StrongDarklings", "icon5", {
    up = "SuperStrongDarklings",
    down = "Darklings",
    left = "DarklingKiller"
  }, {"line12", "line14"})
  NewChildTalent(group.childList.Darklings.childList.StrongDarklings, "SuperStrongDarklings", "icon7", {
    down = "StrongDarklings",
    left = "DarklingExplode"
  }, {"line16"})
  NewChildTalent(group, "BaseAuraJimmy", "icon8", {
    left = "EnergyAura",
    right = "FastHatchet",
    up = "AlwaysFinisher"
  }, {"line0"})
  NewChildTalent(group.childList.BaseAuraJimmy, "EnergyAura", "icon9", {
    down = "BaseAuraJimmy",
    right = "AlwaysFinisher",
    up = "SuperEnergyAura"
  }, {
    "line1",
    "line3",
    "line5"
  })
  NewChildTalent(group.childList.BaseAuraJimmy.childList.EnergyAura, "SuperEnergyAura", "icon12", {
    down = "EnergyAura",
    right = "FinisherInvul"
  }, {"line8"})
  NewChildTalent(group.childList.BaseAuraJimmy, "AlwaysFinisher", "icon10", {
    right = "FastHatchet",
    left = "EnergyAura",
    up = "FinisherInvul",
    down = "BaseAuraJimmy"
  }, {
    "line1",
    "line3",
    "line4"
  })
  NewChildTalent(group.childList.BaseAuraJimmy.childList.AlwaysFinisher, "FinisherInvul", "icon13", {
    right = "AxeKillCooldown",
    down = "AlwaysFinisher",
    left = "SuperEnergyAura"
  }, {"line7"})
  NewChildTalent(group.childList.BaseAuraJimmy, "FastHatchet", "icon11", {
    left = "AlwaysFinisher",
    down = "BaseAuraJimmy",
    up = "AxeKillCooldown"
  }, {"line1", "line2"})
  NewChildTalent(group.childList.BaseAuraJimmy.childList.FastHatchet, "AxeKillCooldown", "icon14", {
    down = "FastHatchet",
    left = "FinisherInvul"
  }, {"line19", "line6"})
  NewChildTalent(group, "DarknessOneHandedGuns", "icon1", {
    up = "DarknessTwoHandedGuns",
    right = "DarknessTwoHandedGuns",
    left = "ActivePumpMP"
  }, {"line9"})
  NewChildTalent(group.childList.DarknessOneHandedGuns, "DarknessTwoHandedGuns", "icon2", {
    down = "DarknessOneHandedGuns",
    left = "ActivePumpMP"
  }, {"line10", "line21"})
  NewChildTalent(group.childList.DarknessOneHandedGuns.childList.DarknessTwoHandedGuns, "ActivePumpMP", "icon17", {
    down = "DarknessOneHandedGuns",
    right = "DarknessTwoHandedGuns"
  }, {"line10", "line20"})
end
local function InitJP(mMovie)
  mGroupingInfo.BaseAuraJp = {
    scale = 100,
    zoomedX = 365,
    zoomedY = 470,
    rotation = 0
  }
  mGroupingInfo.DarknessOneHandedGuns = {
    scale = 100,
    zoomedX = 365,
    zoomedY = 470,
    rotation = 258
  }
  mGroupingInfo.BlackHoleJP = {
    scale = 100,
    zoomedX = 365,
    zoomedY = 470,
    rotation = 115
  }
  mGroupingInfo.VendettaDarknessJP = {
    scale = 60,
    zoomedX = 365,
    zoomedY = 290,
    rotation = 0
  }
  mDefaultTalent = "VendettaDarknessJP"
  mDefaultGroup = "BaseAuraJp"
  mGroupsToToggle = {
    "BaseAuraJp",
    "DarknessOneHandedGuns",
    "BlackHoleJP"
  }
  mGroupOnTop = 1
  mTalentGroups = NewTalent("Main")
  NewChildTalent(mTalentGroups, "VendettaDarknessJP", "icon0")
  group = mTalentGroups.childList.VendettaDarknessJP
  NewChildTalent(group, "BlackHoleJP", "icon3", {
    up = "BlackHoleMPDuration",
    left = "BlackHoleMPDuration",
    right = "BlackHoleSize"
  }, {"line11"})
  NewChildTalent(group.childList.BlackHoleJP, "BlackHoleMPDuration", "icon4", {
    up = "BlackHoleKiller",
    down = "BlackHoleJP",
    right = "BlackHoleSize"
  }, {"line12", "line13"})
  NewChildTalent(group.childList.BlackHoleJP.childList.BlackHoleMPDuration, "BlackHoleKiller", "icon6", {
    down = "BlackHoleMPDuration",
    right = "SuperBlackHoleSize"
  }, {"line15"})
  NewChildTalent(group.childList.BlackHoleJP, "BlackHoleSize", "icon5", {
    up = "SuperBlackHoleSize",
    down = "BlackHoleJP",
    left = "BlackHoleMPDuration"
  }, {"line12", "line14"})
  NewChildTalent(group.childList.BlackHoleJP.childList.BlackHoleSize, "SuperBlackHoleSize", "icon7", {
    down = "BlackHoleSize",
    left = "BlackHoleKiller"
  }, {"line16"})
  NewChildTalent(group, "BaseAuraJp", "icon8", {
    right = "Rebirth",
    left = "HealthAura",
    up = "FastRevive"
  }, {"line0"})
  NewChildTalent(group.childList.BaseAuraJp, "HealthAura", "icon9", {
    down = "BaseAuraJp",
    right = "FastRevive",
    up = "SuperHealthAura"
  }, {
    "line1",
    "line3",
    "line5"
  })
  NewChildTalent(group.childList.BaseAuraJp.childList.HealthAura, "SuperHealthAura", "icon12", {
    down = "HealthAura",
    right = "ReviveInvul"
  }, {"line8"})
  NewChildTalent(group.childList.BaseAuraJp, "FastRevive", "icon10", {
    down = "BaseAuraJp",
    up = "ReviveInvul",
    left = "HealthAura",
    right = "Rebirth"
  }, {
    "line1",
    "line3",
    "line4"
  })
  NewChildTalent(group.childList.BaseAuraJp.childList.FastRevive, "ReviveInvul", "icon13", {
    down = "FastRevive",
    left = "SuperHealthAura",
    right = "StaffKillCooldown"
  }, {"line7"})
  NewChildTalent(group.childList.BaseAuraJp, "Rebirth", "icon11", {
    down = "BaseAuraJp",
    left = "FastRevive",
    up = "StaffKillCooldown"
  }, {"line1", "line2"})
  NewChildTalent(group.childList.BaseAuraJp.childList.Rebirth, "StaffKillCooldown", "icon14", {
    down = "Rebirth",
    left = "ReviveInvul"
  }, {"line19", "line6"})
  NewChildTalent(group, "DarknessOneHandedGuns", "icon1", {
    up = "DarknessTwoHandedGuns",
    right = "DarknessTwoHandedGuns",
    left = "ActivePumpMP"
  }, {"line9"})
  NewChildTalent(group.childList.DarknessOneHandedGuns, "DarknessTwoHandedGuns", "icon2", {
    down = "DarknessOneHandedGuns",
    left = "ActivePumpMP"
  }, {"line10", "line21"})
  NewChildTalent(group.childList.DarknessOneHandedGuns.childList.DarknessTwoHandedGuns, "ActivePumpMP", "icon17", {
    down = "DarknessOneHandedGuns",
    right = "DarknessTwoHandedGuns"
  }, {"line10", "line20"})
end
local function InitShoshanna(mMovie)
  mGroupingInfo.GunChanneling = {
    scale = 100,
    zoomedX = 365,
    zoomedY = 470,
    rotation = 115
  }
  mGroupingInfo.BaseAuraShoshanna = {
    scale = 100,
    zoomedX = 365,
    zoomedY = 470,
    rotation = 0
  }
  mGroupingInfo.DarknessOneHandedGuns = {
    scale = 100,
    zoomedX = 365,
    zoomedY = 470,
    rotation = 258
  }
  mGroupingInfo.VendettaDarknessShoshanna = {
    scale = 60,
    zoomedX = 365,
    zoomedY = 290,
    rotation = 0
  }
  mDefaultTalent = "VendettaDarknessShoshanna"
  mDefaultGroup = "BaseAuraShoshanna"
  mGroupsToToggle = {
    "BaseAuraShoshanna",
    "DarknessOneHandedGuns",
    "GunChanneling"
  }
  mGroupOnTop = 1
  mTalentGroups = NewTalent("Main")
  NewChildTalent(mTalentGroups, "VendettaDarknessShoshanna", "icon0")
  group = mTalentGroups.childList.VendettaDarknessShoshanna
  NewChildTalent(group, "GunChanneling", "icon3", {
    left = "GcPuncture",
    up = "GcPuncture",
    right = "GcDuration"
  }, {"line11"})
  NewChildTalent(group.childList.GunChanneling, "GcPuncture", "icon4", {
    right = "GcDuration",
    down = "GunChanneling",
    up = "GcExplode"
  }, {"line12", "line13"})
  NewChildTalent(group.childList.GunChanneling.childList.GcPuncture, "GcExplode", "icon6", {
    right = "SuperGcDuration",
    down = "GcPuncture"
  }, {"line15"})
  NewChildTalent(group.childList.GunChanneling, "GcDuration", "icon5", {
    left = "GcPuncture",
    down = "GunChanneling",
    up = "SuperGcDuration"
  }, {"line12", "line14"})
  NewChildTalent(group.childList.GunChanneling.childList.GcDuration, "SuperGcDuration", "icon7", {left = "GcExplode", down = "GcDuration"}, {"line16"})
  NewChildTalent(group, "BaseAuraShoshanna", "icon8", {
    right = "AmmoHoarder",
    left = "StunAura",
    up = "FastDarkGun"
  }, {"line0"})
  NewChildTalent(group.childList.BaseAuraShoshanna, "StunAura", "icon9", {
    down = "BaseAuraShoshanna",
    right = "FastDarkGun",
    up = "SuperStunAura"
  }, {
    "line1",
    "line3",
    "line5"
  })
  NewChildTalent(group.childList.BaseAuraShoshanna.childList.StunAura, "SuperStunAura", "icon12", {
    down = "StunAura",
    right = "HeadShotInvul"
  }, {"line8"})
  NewChildTalent(group.childList.BaseAuraShoshanna, "FastDarkGun", "icon10", {
    down = "BaseAuraShoshanna",
    up = "HeadShotInvul",
    left = "StunAura",
    right = "AmmoHoarder"
  }, {
    "line1",
    "line3",
    "line4"
  })
  NewChildTalent(group.childList.BaseAuraShoshanna.childList.FastDarkGun, "HeadShotInvul", "icon13", {
    down = "FastDarkGun",
    left = "SuperStunAura",
    right = "GunKillCooldown"
  }, {"line7"})
  NewChildTalent(group.childList.BaseAuraShoshanna, "AmmoHoarder", "icon11", {
    down = "BaseAuraShoshanna",
    left = "FastDarkGun",
    up = "GunKillCooldown"
  }, {"line1", "line2"})
  NewChildTalent(group.childList.BaseAuraShoshanna.childList.AmmoHoarder, "GunKillCooldown", "icon14", {
    down = "AmmoHoarder",
    left = "HeadShotInvul"
  }, {"line19", "line6"})
  NewChildTalent(group, "DarknessOneHandedGuns", "icon1", {
    up = "DarknessTwoHandedGuns",
    right = "DarknessTwoHandedGuns",
    left = "ActivePumpMP"
  }, {"line9"})
  NewChildTalent(group.childList.DarknessOneHandedGuns, "DarknessTwoHandedGuns", "icon2", {
    down = "DarknessOneHandedGuns",
    left = "ActivePumpMP"
  }, {"line10", "line21"})
  NewChildTalent(group.childList.DarknessOneHandedGuns.childList.DarknessTwoHandedGuns, "ActivePumpMP", "icon17", {
    down = "DarknessOneHandedGuns",
    right = "DarknessTwoHandedGuns"
  }, {"line10", "line20"})
end
local function InitInugami(mMovie)
  mGroupingInfo.SwarmMP = {
    scale = 100,
    zoomedX = 365,
    zoomedY = 470,
    rotation = 115
  }
  mGroupingInfo.BaseAuraInugami = {
    scale = 100,
    zoomedX = 365,
    zoomedY = 470,
    rotation = 0
  }
  mGroupingInfo.DarknessOneHandedGuns = {
    scale = 100,
    zoomedX = 365,
    zoomedY = 470,
    rotation = 258
  }
  mGroupingInfo.VendettaDarknessInugami = {
    scale = 60,
    zoomedX = 365,
    zoomedY = 290,
    rotation = 0
  }
  mDefaultTalent = "VendettaDarknessInugami"
  mDefaultGroup = "BaseAuraInugami"
  mGroupsToToggle = {
    "BaseAuraInugami",
    "DarknessOneHandedGuns",
    "SwarmMP"
  }
  mGroupOnTop = 1
  mTalentGroups = NewTalent("Main")
  NewChildTalent(mTalentGroups, "VendettaDarknessInugami", "icon0")
  group = mTalentGroups.childList.VendettaDarknessInugami
  NewChildTalent(group, "SwarmMP", "icon3", {
    left = "SwarmStun",
    up = "SwarmStun",
    right = "SwarmTargets"
  }, {"line11"})
  NewChildTalent(group.childList.SwarmMP, "SwarmStun", "icon4", {
    up = "SwarmDamage",
    down = "SwarmMP",
    right = "SwarmTargets"
  }, {"line12", "line13"})
  NewChildTalent(group.childList.SwarmMP.childList.SwarmStun, "SwarmDamage", "icon6", {
    down = "SwarmStun",
    right = "SuperSwarmTargets"
  }, {"line15"})
  NewChildTalent(group.childList.SwarmMP, "SwarmTargets", "icon5", {
    up = "SuperSwarmTargets",
    down = "SwarmMP",
    left = "SwarmStun"
  }, {"line12", "line14"})
  NewChildTalent(group.childList.SwarmMP.childList.SwarmTargets, "SuperSwarmTargets", "icon7", {
    down = "SwarmTargets",
    left = "SwarmDamage"
  }, {"line16"})
  NewChildTalent(group, "BaseAuraInugami", "icon8", {
    right = "MeleeDamage",
    left = "SprintDamageResist",
    up = "MeleeAura"
  }, {"line0"})
  NewChildTalent(group.childList.BaseAuraInugami, "SprintDamageResist", "icon9", {
    down = "BaseAuraInugami",
    right = "MeleeAura",
    up = "HeartDestroyer"
  }, {
    "line1",
    "line3",
    "line5"
  })
  NewChildTalent(group.childList.BaseAuraInugami.childList.SprintDamageResist, "HeartDestroyer", "icon12", {
    down = "SprintDamageResist",
    right = "SuperMeleeAura"
  }, {"line8"})
  NewChildTalent(group.childList.BaseAuraInugami, "MeleeAura", "icon10", {
    down = "BaseAuraInugami",
    up = "SuperMeleeAura",
    left = "SprintDamageResist",
    right = "MeleeDamage"
  }, {
    "line1",
    "line3",
    "line4"
  })
  NewChildTalent(group.childList.BaseAuraInugami.childList.MeleeAura, "SuperMeleeAura", "icon13", {
    down = "MeleeAura",
    left = "HeartDestroyer",
    right = "MeleeCooldown"
  }, {"line7"})
  NewChildTalent(group.childList.BaseAuraInugami, "MeleeDamage", "icon11", {
    down = "BaseAuraInugami",
    left = "MeleeAura",
    up = "MeleeCooldown"
  }, {"line1", "line2"})
  NewChildTalent(group.childList.BaseAuraInugami.childList.MeleeDamage, "MeleeCooldown", "icon14", {
    down = "MeleeDamage",
    left = "SuperMeleeAura"
  }, {"line19", "line6"})
  NewChildTalent(group, "DarknessOneHandedGuns", "icon1", {
    up = "DarknessTwoHandedGuns",
    right = "DarknessTwoHandedGuns",
    left = "ActivePumpMP"
  }, {"line9"})
  NewChildTalent(group.childList.DarknessOneHandedGuns, "DarknessTwoHandedGuns", "icon2", {
    down = "DarknessOneHandedGuns",
    left = "ActivePumpMP"
  }, {"line10", "line21"})
  NewChildTalent(group.childList.DarknessOneHandedGuns.childList.DarknessTwoHandedGuns, "ActivePumpMP", "icon17", {
    down = "DarknessOneHandedGuns",
    right = "DarknessTwoHandedGuns"
  }, {"line10", "line20"})
end
local function InitTalentGroups()
  local drawingAreaFrame = ""
  if mActiveCharacterType == D2_Game.JACKIE then
    InitJackie()
    if ShouldDisplayDLC() then
      drawingAreaFrame = "JackieDLC"
    else
      drawingAreaFrame = "Jackie"
    end
  elseif mActiveCharacterType == D2_Game.JIMMY_WILSON then
    InitJimmy()
    drawingAreaFrame = "Jimmy"
  elseif mActiveCharacterType == D2_Game.JP_DUMOND then
    InitJP()
    drawingAreaFrame = "JP"
  elseif mActiveCharacterType == D2_Game.SHOSHANNA then
    InitShoshanna()
    drawingAreaFrame = "Shoshanna"
  elseif mActiveCharacterType == D2_Game.INUGAMI then
    InitInugami()
    drawingAreaFrame = "Inugami"
  end
  FlashMethod(mMovie, "DrawingArea.gotoAndStop", drawingAreaFrame)
  local function iconFunction(talent)
    FlashMethod(mMovie, "DrawingArea." .. talent.clipname .. ".ItemIcon.gotoAndStop", talent.name)
    mMovie:SetVariable("DrawingArea." .. talent.clipname .. ".talentName", talent.name)
    talent.root = GetGroupRootTalent(talent)
  end
  CallFunctionOnEachTalent(mTalentGroups, iconFunction)
  local line
  mMaxLines = 0
  while true do
    line = mMovie:GetVariable("DrawingArea.lineMasks.line" .. mMaxLines)
    if IsNull(line) or line == "undefined" then
      print("couldn't find line " .. tostring(mMaxLines))
      mMaxLines = mMaxLines - 1
      break
    else
      mMaxLines = mMaxLines + 1
    end
  end
  UpdateTalentStates(true)
end
function TutorialCallback()
  mTutorialMovie:Close()
  mMovie:SetFocus("focusDraw")
  inputBlocked = false
end
local function PurchaseTalent(talent)
  if IsNull(talent) then
    return
  end
  print("PurchaseTalent(" .. tostring(talent.name) .. ")")
  if not IsNull(talent.res) then
    if mInventoryController:CanBuyTalent(talent.res) then
      gRegion:PlaySound(soundBuyTalent, Vector(), false)
      mInventoryController:BuyTalent(talent.res)
      talent.wasJustPurchased = true
      local humans = gRegion:ScriptGetLocalPlayers()
      gChallengeMgr:NotifyTag(humans[1], purchaseTalentTag)
      UpdateTalentStates()
      mActiveTalent = nil
      SwitchActiveTalent(talent)
    elseif talent.state ~= STATE_Purchased then
      local thisTalentName = mMovie:GetLocalized(string.format("/D2/Language/Talents/Talent_%s_Name", talent.name))
      gRegion:PlaySound(soundCannotBuyTalent, Vector(), false)
      local workingString = ""
      local prerequisiteList = ""
      if not IsNull(talent.res) then
        local numPrerequisites = talent.res:GetNumPrerequisites()
        local neededTalentName = ""
        if 0 < numPrerequisites then
          for i = 1, numPrerequisites do
            local prerequisiteName = talent.res:GetPrerequisiteNameByIndex(i - 1)
            local prerequisiteRes = mInventoryController:GetTalentByResName(prerequisiteName)
            if mInventoryController:GetTalentLevel(prerequisiteRes) == 0 then
              neededTalentName = mMovie:GetLocalized(string.format("/D2/Language/Talents/Talent_%s_Name", prerequisiteName))
              local strFmt = mMovie:GetLocalized("/D2/Language/Talents/Talents_Popup_NeedPrerequisites")
              workingString = workingString .. string.format(strFmt, neededTalentName, thisTalentName)
              break
            end
          end
        end
      end
      if workingString == "" then
        local c = talent.res:GetCost()
        local e = mProfileData:GetTalentPoints(mActiveCharacterType)
        local diff = c - e
        if not IsNull(talent.res) and c > e then
          local strFmt = mMovie:GetLocalized("/D2/Language/Talents/Talents_Popup_NeedEssence")
          workingString = workingString .. string.format(strFmt, diff, thisTalentName)
        end
      end
      local popupMovie = mMovie:PushChildMovie(popupConfirmMovie)
      FlashMethod(popupMovie, "CreateOkCancel", workingString, popupItemOk, "", "")
      popupMovie:SetVariable("Description.textAlign", "left")
    end
  end
end
local function Pressed()
  if IsNull(mActiveTalent) then
    print("Pressed prevented! There is no active talent")
    return
  end
  if mActiveTalent.name == mDefaultTalent and IsForcedTalentPurchased() then
    SwitchActiveTalent(GetTalentByName(mGroupsToToggle[mGroupOnTop]))
  else
    PurchaseTalent(mActiveTalent)
  end
end
function ItemPressed(movie, arg)
  if not inputBlocked then
    local defaultTalent = GetTalentByName(mDefaultTalent)
    if not IsNull(mActiveTalent) and mActiveTalent.name == arg then
      Pressed()
    elseif arg ~= defaultTalent.name or not defaultTalent.purchased then
      SwitchActiveTalent(GetTalentByName(arg))
    end
  end
end
function ItemSelected(movie, arg)
  if not inputBlocked and not IsNull(arg) then
    local selectedTalent = GetTalentByName(arg)
    local rootTalent = selectedTalent.root
    if not IsNull(rootTalent) and mGroupingInfo[rootTalent.name] ~= nil and mGroupingInfo[rootTalent.name] == mActiveGroupInfo then
      SwitchActiveTalent(selectedTalent)
    end
  end
  mItemHovered = arg
end
function Shutdown(movie)
  if not IsNull(mTutorialMovie) then
    mTutorialMovie:Close()
  end
  if not IsNull(gRegion:GetLocalPlayer()) then
    gRegion:GetLocalPlayer():ScriptInventoryControl():RaiseWeapons()
  end
end
function Initialize(movie)
  mMovie = movie
  mActiveTalent = nil
  mLocCRLN = mMovie:GetLocalized(mLocCRLN)
  platform = movie:GetVariable("$platform")
  mMovie:SetTexture("BinkPlaceholder.png", binkTexture)
  gRegion:StartVideoTexture(binkTexture)
  mMovie:SetVariable("_alpha", 0)
  mMovie:SetBackgroundAlpha(0)
  mScreenAlpha = 0
  mSoundInstance = nil
  if not gRegion:GetGameRules():Paused() then
    gRegion:GetGameRules():RequestPause()
    unpauseOnExit = true
  end
  if not IsNull(smokeTexture) then
    mMovie:SetTexture("smokePlaceholder.png", smokeTexture)
  end
  local players = gRegion:ScriptGetLocalPlayers()
  mAvatar = players[1]:GetAvatar()
  mActiveCharacterType = mAvatar:GetCharacterType()
  mInventoryController = mAvatar:ScriptInventoryControl()
  mProfileData = mInventoryController:GetProfileDataForTalents()
  table.insert(mPopupClips, {
    Clip = "Popup.llCorner"
  })
  table.insert(mPopupClips, {
    Clip = "Popup.lrCorner"
  })
  table.insert(mPopupClips, {
    Clip = "Popup.Essence"
  })
  table.insert(mPopupClips, {
    Clip = "Popup.Requirements"
  })
  table.insert(mPopupClips, {
    Clip = "Popup.Callouts"
  })
  for i = 1, #mPopupClips do
    mPopupClips[i].OriginalY = tonumber(mMovie:GetVariable(mPopupClips[i].Clip .. "._y"))
  end
  mOriginalBackgroundHeight = tonumber(mMovie:GetVariable("Popup.Background._height"))
  mCalloutBar = CalloutBarLibrary.CreateCalloutBar(mMovie, interpolator, "Popup.Callouts")
  FlashMethod(mMovie, "callouts.prevContainer.gotoAndStop", 2)
  FlashMethod(mMovie, "callouts.nextContainer.gotoAndStop", 2)
  mMovie:SetVariable("callouts._visible", false)
  mMovie:SetVariable("DrawingArea.targetX", tonumber(mMovie:GetVariable("DrawingArea._x")))
  mMovie:SetVariable("DrawingArea.targetY", tonumber(mMovie:GetVariable("DrawingArea._y")))
  InitTalentGroups()
  mFadeInComplete = false
  local talent = GetTalentByName(mDefaultTalent)
  local initialRotation = -35
  local initialScale = 75
  if not IsNull(talent) and talent.purchased then
    initialRotation = mGroupingInfo[mDefaultGroup].rotation + 60
    initialScale = mGroupingInfo[mDefaultGroup].scale
    mMovie:SetVariable("DrawingArea._x", mGroupingInfo[mDefaultGroup].zoomedX)
    mMovie:SetVariable("DrawingArea._y", mGroupingInfo[mDefaultGroup].zoomedY)
  end
  mMovie:SetVariable("DrawingArea._alpha", 0)
  mMovie:SetVariable("DrawingArea._rotation", initialRotation)
  mMovie:SetVariable("DrawingArea._xscale", initialScale)
  mMovie:SetVariable("DrawingArea._yscale", initialScale)
  mScrollTalentTreesHintTimer = -1
end
local function HandleMovement(dir)
  if inputBlocked then
    return
  end
  if not IsNull(mActiveTalent) and mActiveTalent.name == mDefaultTalent and IsForcedTalentPurchased() then
    if dir == "up" then
      Pressed()
      return true
    elseif dir == "left" then
      ToggleGroupOnTop(-1)
      return true
    elseif dir == "right" then
      ToggleGroupOnTop(1)
      return true
    end
  end
  local newTalent = ""
  if mActiveTalent == nil then
    newTalent = mDefaultTalent
  end
  if mActiveTalent.movement == nil then
    return true
  end
  if mActiveTalent.movement[dir] ~= nil then
    newTalent = mActiveTalent.movement[dir]
  else
    newTalent = mActiveTalent.name
  end
  local talent = GetTalentByName(newTalent)
  if not IsNull(talent) then
    SwitchActiveTalent(talent)
  else
    print("ERROR: Couldn't find talent by name : " .. tostring(newTalent))
  end
  return true
end
function onKeyDown_MENU_DOWN_FROM_ANALOG()
  return HandleMovement("down")
end
function onKeyDown_MENU_DOWN()
  return HandleMovement("down")
end
function onKeyDown_MENU_UP_FROM_ANALOG()
  return HandleMovement("up")
end
function onKeyDown_MENU_UP()
  return HandleMovement("up")
end
function onKeyDown_MENU_RIGHT_FROM_ANALOG()
  return HandleMovement("right")
end
function onKeyDown_MENU_RIGHT(mMovie)
  return HandleMovement("right")
end
function onKeyDown_MENU_LEFT_FROM_ANALOG(mMovie)
  return HandleMovement("left")
end
function onKeyDown_MENU_LEFT(mMovie)
  return HandleMovement("left")
end
local function Back()
  local canBuyTalent = false
  if not IsNull(forcePurchaseTalent) then
    local talent = mInventoryController:GetTalentByResName(forcePurchaseTalent:GetResourceName())
    if not IsNull(talent) then
      canBuyTalent = mInventoryController:CanBuyTalent(talent)
    end
  end
  if IsForcedTalentPurchased() or not canBuyTalent then
    inputBlocked = true
    local function exitCallback()
      gRegion:StopVideoTexture(binkTexture)
      mMovie:Close()
      if not IsNull(mAvatar) then
        mAvatar:InputControl():ReturnToGame()
      end
      if not IsNull(mSoundInstance) then
        mSoundInstance:Stop(true)
      end
      gRegion:GetGameRules():RequestUnpause()
      local hudInstance = gFlashMgr:FindMovie(hudMovie)
      if not IsNull(hudInstance) then
        hudInstance:Execute("UpdateTalentStates", "")
      end
    end
    gRegion:PlaySound(soundBackOut, Vector(), false)
    interpolator:Interpolate(mMovie, "callouts", interpolator.EASE_OUT, {"_alpha"}, {0}, 0.15)
    interpolator:Interpolate(mMovie, "Popup", interpolator.EASE_OUT, {"_x"}, {700}, 0.35)
    interpolator:Interpolate(mMovie, "DrawingArea", interpolator.EASE_IN, {"_rotation", "_alpha"}, {
      tonumber(mMovie:GetVariable("DrawingArea._rotation")) + 90,
      0
    }, 0.35, 0, exitCallback, false)
  else
    local popupMovie = mMovie:PushChildMovie(popupConfirmMovie)
    FlashMethod(popupMovie, "CreateOkCancel", backFailText, popupItemOk, "", "")
  end
end
local function RequestReclaim()
  if CanReclaim() then
    local popupMovie = mMovie:PushChildMovie(popupConfirmMovie)
    local respecValue = mInventoryController:GetRespecTalentsValue() * (1 - mInventoryController:GetRespectConvenienceChargeValue())
    local strFmt = mMovie:GetLocalized("/D2/Language/Talents/Talents_Reclaim")
    local text = string.format(strFmt, respecValue)
    FlashMethod(popupMovie, "CreateOkCancel", text, popupItemOk, popupItemCancel, "Reclaim")
  end
end
function Reclaim(movie, args)
  if tonumber(args) == 0 then
    inputBlocked = true
    local function callback()
      mMovie:SetVariable("DrawingArea._alpha", 0)
      mMovie:SetVariable("DrawingArea._xscale", 55)
      mMovie:SetVariable("DrawingArea._yscale", 55)
      mMovie:SetVariable("DrawingArea._x", mGroupingInfo[mDefaultTalent].zoomedX)
      mMovie:SetVariable("DrawingArea._y", mGroupingInfo[mDefaultTalent].zoomedY)
      mInventoryController:RespecTalents()
      UpdateTalentStates()
      mActiveTalent = nil
      mActiveGroupInfo = nil
      SwitchActiveTalent(GetTalentByName(mDefaultTalent))
    end
    interpolator:Interpolate(mMovie, "DrawingArea", interpolator.EASE_IN, {"_alpha"}, {0}, 0.2, 0, callback, false)
  end
end
function onKeyDown_MENU_SELECT(movie, device)
  if inputBlocked or mIsCalloutFocused then
    print("Blocking MENU_SELECT inputBlocked=" .. tostring(inputBlocked) .. " mIsCalloutFocused=" .. tostring(mIsCalloutFocused))
    return
  end
  if LIB.IsPCInputDevice(tonumber(device)) then
    print("Blocking MENU_SELECT mItemHovered=" .. tostring(mItemHovered))
    return
  end
  Pressed()
end
function callout_MENU_SELECT()
  if not inputBlocked then
    Pressed()
  end
end
function onKeyDown_MENU_GENERIC1()
  if not inputBlocked then
    RequestReclaim()
  end
end
function onKeyDown_MENU_LTRIGGER2()
  if not inputBlocked then
    ToggleGroupOnTop(-1)
  end
end
function onKeyDown_MENU_RTRIGGER2()
  if not inputBlocked then
    ToggleGroupOnTop(1)
  end
end
function DoToggleGroupOnTop(movie, direction)
  if not inputBlocked then
    ToggleGroupOnTop(tonumber(direction))
  end
end
function onKeyDown_MENU_CANCEL()
  if not inputBlocked then
    Back()
  end
end
function CalloutFocused()
  mIsCalloutFocused = true
end
function CalloutUnfocused()
  mIsCalloutFocused = false
end

local LIB = require("D2.Menus.SharedLibrary")
popupConfirmMovie = Resource()
talentsScreen = Resource()
sndGoBack = Resource()
sndEquipWeapon = Resource()
sndToggleUpgrade = Resource()
sndScroll = Resource()
sndGenericSelect = Resource()
sndError = Resource()
statList = {
  Resource()
}
weaponOrder1Hand = {
  Resource()
}
weaponOrder2Hand = {
  Resource()
}
exitLoadoutScreenChallenge = Resource()
binkTexture = Resource()
transitionMovie = WeakResource()
local SESSIONSTATE_WaitingForPlayers = 5
local SESSIONSTATE_JoiningSession = 3
local SESSIONSTATE_CreatingSession = 1
local STATSLOT_Weapon = 1
local STATSLOT_Upgrade = 2
local SCREENSTATE_SelectingSlot = 0
local SCREENSTATE_SelectingPiece = 1
local SCREENSTATE_SelectingItem = 2
local ITEMTYPE_Weapon = 1
local ITEMTYPE_Upgrade = 2
local GRID_Slot = "SlotGrid"
local GRID_Piece = "PieceGrid"
local GRID_Item = "ItemGrid"
local statusSelect = "/D2/Language/Menu/Shared_Select"
local statusBack = "/D2/Language/Menu/Shared_Back"
local statusTalents = "/D2/Language/Menu/Loadout_Status_Talents"
local statusEquip = "/D2/Language/Menu/Loadout_Status_Equip"
local statusRemove = "/D2/Language/Menu/Loadout_Status_Remove"
local statusChangeSkin = "/D2/Language/Menu/Loadout_Status_ChangeSkin"
local statusList = {
  statusSelect,
  statusEquip,
  statusRemove,
  statusChangeSkin,
  statusBack
}
local mActiveStatsList = {}
local mLocalPlayers = {}
local mAvatar, mCharId
local mIsMultiplayer = true
local originalScreenBlur = 0
local originalFocalDepth = 0
local mScreenState = SCREENSTATE_SelectingSlot
local mSlotList = {
  weapon = "",
  weaponRes = nil,
  skinRes = nil,
  isReplaceable = true,
  numHands = 0,
  upgradeResList = {}
}
local mCollectibleList = {}
local mItemList = {}
local mGridInfo = {}
local mMovieInstance, mSavePopup
local mButtonMap = {}
local function GetScreenState()
  return mScreenState
end
local GetItemMCName = function(baseName, x, y)
  return string.format("%s_Item%dx%d", baseName, x, y)
end
local function EnableButton(movie, button, enabled)
  FlashMethod(movie, "StatusBar.StatusBarClass.SetItemVisibleByName", button, enabled)
  mButtonMap[button] = enabled
end
local function IsButtonEnabled(button)
  return mButtonMap[button]
end
local InitializeWeaponStats = function(movie, mcName)
  for i = 1, 5 do
    movie:SetLocalized(string.format("%s.Stats.Stat%i.StatName.text", mcName, i), string.format("/D2/Language/Menu/Loadout_StatName%i", i))
    FlashMethod(movie, string.format("%s.Stats.Stat%i.StatProgress.gotoAndStop", mcName, i), 1)
  end
end
local NewWeaponSlot = function()
  return {
    weaponName = "",
    weaponRes = nil,
    skinIdx = 0,
    skinResList = {nil},
    isReplaceable = false,
    numHands = 0,
    upgradeResList = {nil}
  }
end
local function GetProfileData()
  local inventoryController = mAvatar:ScriptInventoryControl()
  local profileData = inventoryController:GetProfileDataForTalents()
  return profileData
end
local function GetWeaponCollection()
  local profileData = GetProfileData()
  if profileData == nil then
    return nil
  end
  local weaponCollection = profileData:GetWeaponCollection()
  return weaponCollection
end
local FindWeaponStats = function(name)
  for i = 1, #statList do
    local ws = statList[i]
    if not IsNull(ws) and ws.obj == name then
      return ws
    end
  end
  return nil
end
local function UpdateItemIcon(movie, mcOwner, y, filterType, thisCollectible)
  local mcName = GetItemMCName(mcOwner, 0, y)
  local imageName = "Placeholder"
  local locked = true
  if not IsNull(thisCollectible) then
    locked = thisCollectible.isLocked
    if locked then
      imageName = "Locked"
    else
      imageName = thisCollectible.res:GetName()
    end
  end
  local filterImagePrefix = "WeaponImages"
  if filterType == ITEMTYPE_Upgrade then
    filterImagePrefix = "UpgradeImages"
    if not locked then
      local ws = FindWeaponStats(imageName)
      if ws ~= nil then
        local val = -1
        if val < ws.reloadTime then
          val = ws.reloadTime
          imageName = "Reload"
        end
        if val < ws.range then
          val = ws.range
          imageName = "Range"
        end
        if val < ws.fireRate then
          val = ws.fireRate
          imageName = "FireRate"
        end
        if val < ws.damage then
          val = ws.damage
          imageName = "Damage"
        end
        if val < ws.accuracy then
          val = ws.val
          imageName = "Accuracy"
        end
      end
    end
  end
  FlashMethod(movie, string.format("%s.IconBackground.IconContents.%s.gotoAndStop", mcName, filterImagePrefix), imageName)
  movie:SetVariable(string.format("%s.IconBackground.IconContents.WeaponImages._visible", mcName), filterType == ITEMTYPE_Weapon)
  movie:SetVariable(string.format("%s.IconBackground.IconContents.UpgradeImages._visible", mcName), filterType == ITEMTYPE_Upgrade)
end
local function UpdateSlotImage(movie, y)
  local mcName = GetItemMCName(GRID_Slot, 0, y)
  FlashMethod(movie, string.format("%s.IconBackground.IconContents.WeaponImages.gotoAndStop", mcName), mSlotList[y + 1].weaponName)
end
local function InitializeReplaceableWeaponSlot(slotIdx, weaponRes)
  local profileData = GetProfileData()
  mSlotList[slotIdx] = NewWeaponSlot()
  mSlotList[slotIdx].isReplaceable = true
  mSlotList[slotIdx].weaponRes = weaponRes
  mSlotList[slotIdx].weaponName = mSlotList[slotIdx].weaponRes:GetName()
  local wc = GetWeaponCollection()
  local numSkins = wc:GetNumCollectedSkins(mSlotList[slotIdx].weaponRes)
  for j = 1, numSkins do
    mSlotList[slotIdx].skinResList[j] = wc:GetCollectedSkin(mSlotList[slotIdx].weaponRes, j - 1)
    if profileData:GetSelectedSkin(mCharId, slotIdx - 1) == mSlotList[slotIdx].skinResList[j] then
      mSlotList[slotIdx].skinIdx = j
    end
  end
  if slotIdx == 1 then
    mSlotList[slotIdx].numHands = 2
  else
    mSlotList[slotIdx].numHands = 1
  end
  local maxUpgradeSlots = profileData:GetNumUpgradeSlots(mCharId)
  if 0 < maxUpgradeSlots then
    local thisSlot = mSlotList[slotIdx]
    for i = 1, maxUpgradeSlots do
      mSlotList[slotIdx].upgradeResList[i] = ""
    end
  end
  local numUpgrades = profileData:GetNumSelectedUpgrades(mCharId, slotIdx - 1)
  for j = 1, numUpgrades do
    local u = profileData:GetSelectedUpgrade(mCharId, slotIdx - 1, j - 1)
    mSlotList[slotIdx].upgradeResList[j] = u
  end
end
local function SetIconSelected(movie, mc, slotIdx, vis)
  local frameLabel = "Unselected"
  if vis then
    frameLabel = "Selected"
  end
  FlashMethod(movie, string.format("%s.IconBackground.gotoAndStop", GetItemMCName(mc, 0, slotIdx)), frameLabel)
end
local function UpdateWeaponStats(movie, vis, mcName)
  local totalStats = FindWeaponStats("Empty")
  if totalStats == nil then
    movie:SetVariable(string.format("%s.Stats._visible", mcName), false)
    return
  end
  local reloadTime = 0
  local range = 0
  local fireRate = 0
  local damage = 0
  local accuracy = 0
  for key, value in pairs(mActiveStatsList) do
    if not IsNull(value) then
      reloadTime = reloadTime + value.reloadTime
      range = range + value.range
      fireRate = fireRate + value.fireRate
      damage = damage + value.damage
      accuracy = accuracy + value.accuracy
    end
  end
  reloadTime = Clamp(reloadTime, 0, 100)
  range = Clamp(range, 0, 100)
  fireRate = Clamp(fireRate, 0, 100)
  damage = Clamp(damage, 0, 100)
  accuracy = Clamp(accuracy, 0, 100)
  if reloadTime + range + fireRate + damage + accuracy <= 0 then
  end
  FlashMethod(movie, string.format("%s.Stats.Stat1.StatProgress.gotoAndStop", mcName), reloadTime + 1)
  FlashMethod(movie, string.format("%s.Stats.Stat2.StatProgress.gotoAndStop", mcName), range + 1)
  FlashMethod(movie, string.format("%s.Stats.Stat3.StatProgress.gotoAndStop", mcName), fireRate + 1)
  FlashMethod(movie, string.format("%s.Stats.Stat4.StatProgress.gotoAndStop", mcName), damage + 1)
  FlashMethod(movie, string.format("%s.Stats.Stat5.StatProgress.gotoAndStop", mcName), accuracy + 1)
  movie:SetVariable(string.format("%s.Stats._visible", mcName), vis)
end
local function SetScreenState(movie, newState)
  movie:SetVariable("WeaponInfo.ErrorMessage.text", "")
  movie:SetVariable("SlotBackground._visible", newState == SCREENSTATE_SelectingSlot)
  movie:SetVariable("SlotInfo._visible", newState == SCREENSTATE_SelectingSlot)
  FlashMethod(movie, "SlotGrid.GridClass.SetVisible", newState == SCREENSTATE_SelectingSlot)
  movie:SetVariable("WeaponInfo._visible", newState ~= SCREENSTATE_SelectingSlot)
  movie:SetVariable("ItemBackground._visible", newState ~= SCREENSTATE_SelectingSlot)
  FlashMethod(movie, "PieceGrid.GridClass.SetVisible", newState ~= SCREENSTATE_SelectingSlot)
  FlashMethod(movie, "ItemGrid.GridClass.SetVisible", newState ~= SCREENSTATE_SelectingSlot)
  EnableButton(movie, statusTalents, newState == SCREENSTATE_SelectingSlot)
  EnableButton(movie, statusEquip, newState == SCREENSTATE_SelectingPiece)
  EnableButton(movie, statusSelect, newState ~= SCREENSTATE_SelectingPiece)
  local curSlotIdx = mGridInfo[GRID_Slot].selectionIdx
  EnableButton(movie, statusRemove, newState == SCREENSTATE_SelectingPiece and #mSlotList[curSlotIdx + 1].upgradeResList > 0)
  EnableButton(movie, statusChangeSkin, newState == SCREENSTATE_SelectingPiece)
  EnableButton(movie, statusTalents, newState == SCREENSTATE_SelectingSlot)
  if newState == SCREENSTATE_SelectingItem then
    FlashMethod(movie, "PieceGrid.GridClass.SetEnabled", false)
    FlashMethod(movie, "ItemGrid.GridClass.SetEnabled", true)
    local selectionIdx = mGridInfo[GRID_Item].selectionIdx
    movie:SetFocus(GetItemMCName(GRID_Item, 0, selectionIdx))
  elseif newState == SCREENSTATE_SelectingPiece then
    FlashMethod(movie, "ItemGrid.GridClass.SetEnabled", false)
    FlashMethod(movie, "PieceGrid.GridClass.SetEnabled", true)
    mActiveStatsList = {}
    local slotIdx = mGridInfo[GRID_Slot].selectionIdx
    local weaponName = mSlotList[slotIdx + 1].weaponName
    UpdateItemIcon(movie, GRID_Piece, 0, ITEMTYPE_Weapon, mCollectibleList[weaponName])
    mActiveStatsList[1] = FindWeaponStats(weaponName)
    local emptyStats = FindWeaponStats("Empty")
    local thisSlot = mSlotList[slotIdx + 1]
    local numUpgrades = #mSlotList[slotIdx + 1].upgradeResList
    for i = 1, numUpgrades do
      local upgradeRes = mSlotList[slotIdx + 1].upgradeResList[i]
      local theCollectible
      mActiveStatsList[i + 1] = emptyStats
      if not IsNull(upgradeRes) and upgradeRes ~= "" then
        local upgradeName = upgradeRes:GetName()
        theCollectible = mCollectibleList[upgradeName]
        mActiveStatsList[i + 1] = FindWeaponStats(upgradeName)
      end
      UpdateItemIcon(movie, GRID_Piece, i, ITEMTYPE_Upgrade, theCollectible)
    end
    UpdateWeaponStats(movie, true, "WeaponInfo")
    local selectionIdx = mGridInfo[GRID_Piece].selectionIdx
    movie:SetFocus(GetItemMCName(GRID_Piece, 0, selectionIdx))
  elseif newState == SCREENSTATE_SelectingSlot then
    local pieceIdx = mGridInfo[GRID_Piece].selectionIdx
    SetIconSelected(movie, GRID_Piece, pieceIdx, false)
    mGridInfo[GRID_Piece].selectionIdx = 0
    for i = 1, 3 do
      UpdateSlotImage(movie, i - 1)
    end
    local selectionIdx = mGridInfo[GRID_Slot].selectionIdx
    movie:SetFocus(GetItemMCName(GRID_Slot, 0, selectionIdx))
  end
  mScreenState = newState
end
local UpdateWeaponImage = function(movie, mcName, wn)
  FlashMethod(movie, string.format("%s.Image.gotoAndStop", mcName), wn)
end
local SetGridSelectedState = function(movie, grid, slot, selected)
  movie:SetVariable(string.format("%s_Item%dx%d.Selection._visible", grid, 0, slot), selected)
end
function OnSaveCompleted(success)
  mSavePopup:Close()
  gRegion:StopVideoTexture(binkTexture)
  mMovieInstance:Close()
end
local SaveProfile = function()
  if Engine.GetPlayerProfileMgr():IsLoggedIn() then
    Engine.GetPlayerProfileMgr():ScriptSaveProfile(0, "OnSaveCompleted")
  end
end
local function UpdateUpgradeInfo(movie, slotIdx, un)
  local mcName = GetItemMCName("UpgradeGrid", 0, slotIdx)
  local isBreadcrumb = false
  local isEquipped = false
  local locName = "/D2/Language/Menu/Loadout_Upgrade_Available"
  if un ~= "" then
    locName = string.format("/D2/Language/Weapons/UpgradeName_%s", un)
  end
  movie:SetVariable(string.format("%s.Breadcrumb._visible", mcName), isBreadcrumb)
  movie:SetVariable(string.format("%s.Equipped._visible", mcName), isEquipped)
  movie:SetLocalized(string.format("%s.Text.text", mcName), locName)
end
function SlotGridItemSelected(movie, arg)
  if mSavePopup ~= nil then
    return
  end
  local slotIdx = tonumber(arg)
  mGridInfo[GRID_Slot].selectionIdx = tonumber(arg)
  local thisSlot = mSlotList[slotIdx + 1]
  gRegion:PlaySound(sndScroll, Vector(), false)
  local handed = "Two"
  local vis = false
  mActiveStatsList = {}
  if not IsNull(thisSlot.weaponRes) then
    vis = true
    mActiveStatsList[#mActiveStatsList + 1] = FindWeaponStats(thisSlot.weaponName)
  end
  if thisSlot.numHands == 1 then
    handed = "One"
  end
  UpdateWeaponStats(movie, vis, "SlotInfo")
  movie:SetLocalized("SlotInfo.NameValue.text", string.format("/D2/Language/Weapons/WeaponName_%s", thisSlot.weaponName))
  movie:SetLocalized("SlotInfo.TypeValue.text", string.format("/D2/Language/Menu/Loadout_SlotInfo_Handed_%s", handed))
  movie:SetLocalized("SlotInfo.DescriptionValue.text", string.format("/D2/Language/Weapons/WeaponDsc_%s", thisSlot.weaponName))
  SetIconSelected(movie, GRID_Slot, slotIdx, true)
end
function SlotGridItemUnselected(movie, arg)
  local slotIdx = tonumber(arg)
  SetIconSelected(movie, GRID_Slot, slotIdx, false)
end
local function UpdateItemInfo(movie, itemType, itemName)
  if itemType == ITEMTYPE_Weapon then
    InitializeWeaponStats(movie, itemName)
    UpdateWeaponImage(movie, "WeaponInfo", itemName)
    movie:SetLocalized("WeaponInfo.Description.text", string.format("/D2/Language/Weapon/WeaponDsc_%s", itemName))
  else
    movie:SetLocalized("WeaponInfo.Description.text", string.format("/D2/Language/Weapons/UpgradeDsc_%s", itemName))
  end
  FlashMethod(movie, "WeaponInfo.Image.gotoAndStop", itemName)
end
local function BuildFilteredItemList(movie, highlightName)
  local filterType = ITEMTYPE_Upgrade
  local filterNamePrefix = "UpgradeName"
  local numHands = 0
  local ownerRes
  if mGridInfo[GRID_Piece].selectionIdx == 0 then
    filterType = ITEMTYPE_Weapon
    filterNamePrefix = "WeaponName"
    local selectedSlotIdx = mGridInfo[GRID_Slot].selectionIdx
    numHands = mSlotList[selectedSlotIdx + 1].numHands
  else
    local selectedSlotIdx = mGridInfo[GRID_Slot].selectionIdx
    ownerRes = mSlotList[selectedSlotIdx + 1].weaponRes
  end
  local h = mGridInfo[GRID_Item].height
  for i = 1, h do
    FlashMethod(movie, "ItemGrid.GridClass.SetItemVisible", 0, i - 1, false)
  end
  local activeOrderList
  if numHands == 1 then
    activeOrderList = weaponOrder1Hand
  else
    activeOrderList = weaponOrder2Hand
  end
  mItemList = {}
  local height = 0
  for k, v in pairs(mCollectibleList) do
    if IsNull(k) or k == "" then
    elseif v.itemType ~= filterType then
    elseif v.numHands ~= numHands then
    elseif ownerRes ~= v.ownerRes then
    else
      local i = mCollectibleList[k].visibleIndex + 1
      mItemList[i] = k
    end
  end
  local height = 0
  for i = 1, #mItemList do
    local k = mItemList[i]
    local mcName = GetItemMCName(GRID_Item, 0, i - 1)
    FlashMethod(movie, "ItemGrid.GridClass.SetItemVisible", 0, i - 1, true)
    movie:SetLocalized(string.format("%s.Selected.text", mcName), string.format("/D2/Language/Weapons/%s_%s", filterNamePrefix, k))
    movie:SetLocalized(string.format("%s.Unselected.text", mcName), string.format("/D2/Language/Weapons/%s_%s", filterNamePrefix, k))
    movie:SetVariable(string.format("%s.Selected._visible", mcName), k == highlightName)
    movie:SetVariable(string.format("%s.Unselected._visible", mcName), k ~= highlightName)
    local thisCollectible = mCollectibleList[k]
    UpdateItemIcon(movie, GRID_Item, i - 1, filterType, thisCollectible)
    local color = 6710886
    if k == highlightName then
      color = 16777215
    end
    movie:SetVariable(string.format("%s.Text.textColor", mcName), color)
  end
  height = #mItemList + 1
  mGridInfo[GRID_Item].height = height - 1
  local thisGrid = mGridInfo[GRID_Item]
  FlashMethod(movie, "ItemGrid.GridClass.SetDimensions", thisGrid.width, thisGrid.height)
  FlashMethod(movie, "ItemGrid.GridClass.SetClipDimensions", thisGrid.width + 1, thisGrid.height + 1)
end
local function UpdateSkinName(movie)
  local slotIdx = mGridInfo[GRID_Slot].selectionIdx
  local skinName = ""
  if mSlotList[slotIdx + 1].skinIdx > 0 then
    local wr = mSlotList[slotIdx + 1].weaponRes
    local wc = GetWeaponCollection()
    local skinRes = wc:GetCollectedSkin(wr, mSlotList[slotIdx + 1].skinIdx - 1)
    if not IsNull(skinRes) then
      skinName = movie:GetLocalized(string.format("/D2/Language/Weapons/WeaponSkin_%s", skinRes:GetName()))
    end
  end
  movie:SetVariable("WeaponInfo.Skin.text", skinName)
end
function PieceGridItemSelected(movie, arg)
  local pieceIdx = tonumber(arg)
  if GetScreenState() ~= SCREENSTATE_SelectingPiece then
    return
  end
  mGridInfo[GRID_Piece].selectionIdx = pieceIdx
  gRegion:PlaySound(sndScroll, Vector(), false)
  SetIconSelected(movie, GRID_Piece, pieceIdx, true)
  local enableSkinsButton = false
  if pieceIdx == 0 then
    local curSlotIdx = mGridInfo[GRID_Slot].selectionIdx
    local wr = mSlotList[curSlotIdx + 1].weaponRes
    local wc = GetWeaponCollection()
    local numSkins = wc:GetNumCollectedSkins(wr)
    enableSkinsButton = 0 < numSkins
  end
  EnableButton(movie, statusChangeSkin, enableSkinsButton)
  local highlightName = ""
  if pieceIdx == 0 then
    local curSlotIdx = mGridInfo[GRID_Slot].selectionIdx
    local skinIdx = mSlotList[curSlotIdx + 1].skinIdx
    highlightName = mSlotList[curSlotIdx + 1].weaponName
    UpdateSkinName(movie)
    local skinName = highlightName
    if 0 < skinIdx and not IsNull(mSlotList[curSlotIdx + 1].skinResList[skinIdx]) then
      skinName = mSlotList[curSlotIdx + 1].skinResList[skinIdx]:GetName()
    end
    UpdateWeaponImage(movie, "WeaponInfo", skinName)
    UpdateWeaponStats(movie, true, "WeaponInfo")
  else
    local curSlotIdx = mGridInfo[GRID_Slot].selectionIdx
    local upgradeRes = mSlotList[curSlotIdx + 1].upgradeResList[pieceIdx]
    if not IsNull(upgradeRes) and upgradeRes ~= "" then
      highlightName = upgradeRes:GetName()
    end
  end
  BuildFilteredItemList(movie, highlightName)
  if #mItemList == 0 then
    movie:SetLocalized("WeaponInfo.ErrorMessage.text", "/D2/Language/Menu/Loadout_Error_NoItemsAvailable")
  else
    movie:SetVariable("WeaponInfo.ErrorMessage.text", "")
  end
end
function PieceGridItemUnselected(movie, arg)
  local slotIdx = tonumber(arg)
  if GetScreenState() ~= SCREENSTATE_SelectingPiece then
    return
  end
  SetIconSelected(movie, GRID_Piece, slotIdx, false)
end
function PieceGridItemPressed(movie, arg)
  if mSavePopup ~= nil then
    return
  end
  if GetScreenState() ~= SCREENSTATE_SelectingPiece then
    return
  end
  if #mItemList == 0 then
    return
  end
  local pieceIdx = tonumber(arg)
  mGridInfo[GRID_Piece].selectionIdx = pieceIdx
  mGridInfo[GRID_Item].selectionIdx = 0
  gRegion:PlaySound(sndGenericSelect, Vector(), false)
  local profileData = GetProfileData()
  if pieceIdx > profileData:GetNumUpgradeSlots(mCharId) then
    return
  end
  SetScreenState(movie, SCREENSTATE_SelectingItem)
end
local function IsUpgradeEquipped(curSlotIdx, upgradeRes)
  local numUpgrades = #mSlotList[curSlotIdx + 1].upgradeResList
  for i = 1, numUpgrades do
    local thisUpgradeRes = mSlotList[curSlotIdx + 1].upgradeResList[i]
    if not IsNull(thisUpgradeRes) and thisUpgradeRes == upgradeRes then
      return true
    end
  end
  return false
end
local function SetItemTextHighlight(movie, slotIdx)
  local numItems = #mItemList
  for i = 1, numItems do
    local mcName = GetItemMCName(GRID_Item, 0, i - 1)
    movie:SetVariable(string.format("%s.Selected._visible", mcName), i - 1 == slotIdx)
    movie:SetVariable(string.format("%s.Unselected._visible", mcName), i - 1 ~= slotIdx)
  end
end
function ItemGridItemSelected(movie, arg)
  if mSavePopup ~= nil then
    return
  end
  local slotIdx = tonumber(arg)
  mGridInfo[GRID_Item].selectionIdx = slotIdx
  if GetScreenState() ~= SCREENSTATE_SelectingItem then
    return
  end
  gRegion:PlaySound(sndScroll, Vector(), false)
  SetIconSelected(movie, GRID_Item, slotIdx, true)
  local thisItem = mItemList[slotIdx + 1]
  if IsNull(thisItem) then
    return
  end
  local thisCollectible = mCollectibleList[thisItem]
  UpdateItemInfo(movie, thisCollectible.itemType, thisCollectible.name)
  SetItemTextHighlight(movie, slotIdx)
  local gridSlotIdx = mGridInfo[GRID_Slot].selectionIdx
  local thisSlot = mSlotList[gridSlotIdx + 1]
  local weaponRes = thisSlot.weaponRes
  mActiveStatsList = {}
  local ws_weapon = FindWeaponStats(weaponRes:GetName())
  if ws_weapon ~= nil then
    mActiveStatsList[#mActiveStatsList + 1] = ws_weapon
  end
  local ws_upgrade = FindWeaponStats(thisItem)
  if ws_upgrade ~= nil then
    mActiveStatsList[#mActiveStatsList + 1] = ws_upgrade
  end
  UpdateWeaponStats(movie, true, "WeaponInfo")
  if thisCollectible.isLocked then
    movie:SetLocalized("WeaponInfo.ErrorMessage.text", "/D2/Language/Menu/Loadout_Error_ItemLocked")
  elseif IsUpgradeEquipped(mGridInfo[GRID_Slot].selectionIdx, thisCollectible.res) then
    movie:SetLocalized("WeaponInfo.ErrorMessage.text", "/D2/Language/Menu/Loadout_Error_ItemAlreadyEquipped")
  else
    movie:SetVariable("WeaponInfo.ErrorMessage.text", "")
  end
end
function ItemGridItemUnselected(movie, arg)
  local slotIdx = tonumber(arg)
  SetItemTextHighlight(movie, -1)
  SetIconSelected(movie, GRID_Item, slotIdx, false)
end
function ItemGridItemPressed(movie, arg)
  if mSavePopup ~= nil then
    return
  end
  local curItemIdx = tonumber(arg)
  mGridInfo[GRID_Item].selectionIdx = curItemIdx
  gRegion:PlaySound(sndGenericSelect, Vector(), false)
  local selectedName = mItemList[curItemIdx + 1]
  local newCollectible = mCollectibleList[selectedName]
  if IsNull(newCollectible) then
    return
  end
  if newCollectible.isLocked then
    return
  end
  local mcName = GetItemMCName(GRID_Item, 0, curItemIdx)
  movie:SetVariable(string.format("%s.Unselected._visible", mcName), true)
  movie:SetVariable(string.format("%s.Selected._visible", mcName), false)
  local curSlotIdx = mGridInfo[GRID_Slot].selectionIdx
  local curPieceIdx = mGridInfo[GRID_Piece].selectionIdx
  if curPieceIdx == 0 then
    InitializeReplaceableWeaponSlot(curSlotIdx + 1, newCollectible.res)
    local profileData = GetProfileData()
    profileData:SetSelectedWeapon(mCharId, curSlotIdx, newCollectible.res)
  else
    if IsUpgradeEquipped(curSlotIdx, newCollectible.res) then
      return
    end
    local profileData = GetProfileData()
    local thisSlot = mSlotList[curSlotIdx + 1]
    local curUpgradeRes = thisSlot.upgradeResList[curPieceIdx]
    if not IsNull(curUpgradeRes) and curUpgradeRes ~= "" then
      local upgradeName = curUpgradeRes:GetName()
      if not IsNull(upgradeName) then
        profileData:RemoveUpgrade(mCharId, curSlotIdx, curUpgradeRes)
      end
    end
    mSlotList[curSlotIdx + 1].upgradeResList[curPieceIdx] = newCollectible.res
    profileData:AddUpgrade(mCharId, curSlotIdx, newCollectible.res)
  end
  SetIconSelected(movie, GRID_Item, curItemIdx, false)
  SetScreenState(movie, SCREENSTATE_SelectingPiece)
end
function SlotGridItemPressed(movie, arg)
  if mSavePopup ~= nil then
    return
  end
  local selectedSlot = tonumber(arg)
  mGridInfo[GRID_Slot].selectionIdx = selectedSlot
  gRegion:PlaySound(sndGenericSelect, Vector(), false)
  local thisSlot = mSlotList[selectedSlot + 1]
  if thisSlot.isReplaceable then
    SetScreenState(movie, SCREENSTATE_SelectingPiece)
  end
end
local function InitializePieceGrid(movie)
  mGridInfo[GRID_Piece] = {
    width = 1,
    height = 0,
    spacingW = 0,
    spacingH = 0,
    selectionIdx = 0
  }
  local profileData = GetProfileData()
  mGridInfo[GRID_Piece].height = profileData:GetNumUpgradeSlots(mCharId) + 1
  local thisGrid = mGridInfo[GRID_Piece]
  FlashMethod(movie, "PieceGrid.GridClass.SetDimensions", thisGrid.width, thisGrid.height)
  FlashMethod(movie, "PieceGrid.GridClass.SetClipDimensions", thisGrid.width + 1, thisGrid.height + 1)
  FlashMethod(movie, "PieceGrid.GridClass.SetItem", 0, 0, "ItemTemplateBig")
  FlashMethod(movie, "PieceGrid.GridClass.SetItemVisible", 0, 0, true)
  SetIconSelected(movie, GRID_Piece, 0, false)
  for y = 1, thisGrid.height - 1 do
    FlashMethod(movie, "PieceGrid.GridClass.SetItem", 0, y, "ItemTemplateSmall")
    FlashMethod(movie, "PieceGrid.GridClass.SetItemVisible", 0, y, true)
    local mcName = GetItemMCName(GRID_Piece, 0, y - 1)
    movie:SetVariable(string.format("%s.Lock._visible", mcName), y - 1 > profileData:GetNumUpgradeSlots(mCharId))
    SetIconSelected(movie, GRID_Piece, y, false)
  end
  FlashMethod(movie, "PieceGrid.GridClass.SetCallbackSelected", "PieceGridItemSelected")
  FlashMethod(movie, "PieceGrid.GridClass.SetCallbackUnselected", "PieceGridItemUnselected")
  FlashMethod(movie, "PieceGrid.GridClass.SetCallbackPressed", "PieceGridItemPressed")
end
local function InitializeItemGrid(movie)
  mGridInfo[GRID_Item] = {
    width = 1,
    height = 6,
    spacingW = 0,
    spacingH = -15,
    selectionIdx = 0
  }
  local thisGrid = mGridInfo[GRID_Item]
  FlashMethod(movie, "ItemGrid.GridClass.SetDimensions", thisGrid.width, thisGrid.height)
  FlashMethod(movie, "ItemGrid.GridClass.SetClipDimensions", thisGrid.width + 1, thisGrid.height + 1)
  FlashMethod(movie, "ItemGrid.GridClass.SetItemSpacing", thisGrid.spacingW, thisGrid.spacingH)
  for y = 1, thisGrid.height do
    FlashMethod(movie, "ItemGrid.GridClass.SetItem", 0, y - 1, "ItemTemplateSmall")
    FlashMethod(movie, "ItemGrid.GridClass.SetItemVisible", 0, y - 1, true)
    SetIconSelected(movie, GRID_Item, y - 1, false)
  end
  FlashMethod(movie, "ItemGrid.GridClass.SetCallbackSelected", "ItemGridItemSelected")
  FlashMethod(movie, "ItemGrid.GridClass.SetCallbackUnselected", "ItemGridItemUnselected")
  FlashMethod(movie, "ItemGrid.GridClass.SetCallbackPressed", "ItemGridItemPressed")
end
local function InitializeSlotGrid(movie)
  mGridInfo[GRID_Slot] = {
    width = 1,
    height = 3,
    spacingW = 0,
    spacingH = -10,
    selectionIdx = 0
  }
  local thisGrid = mGridInfo[GRID_Slot]
  FlashMethod(movie, "SlotGrid.GridClass.SetDimensions", thisGrid.width, thisGrid.height)
  FlashMethod(movie, "SlotGrid.GridClass.SetClipDimensions", thisGrid.width + 1, thisGrid.height + 1)
  FlashMethod(movie, "SlotGrid.GridClass.SetItemSpacing", thisGrid.spacingW, thisGrid.spacingH)
  for y = 1, thisGrid.height do
    for x = 1, thisGrid.width do
      FlashMethod(movie, "SlotGrid.GridClass.SetItem", x - 1, y - 1, "ItemTemplateBig")
      FlashMethod(movie, "SlotGrid.GridClass.SetItemVisible", x - 1, y - 1, true)
      UpdateSlotImage(movie, y - 1)
      SetIconSelected(movie, GRID_Slot, y - 1, false)
    end
  end
  FlashMethod(movie, "SlotGrid.GridClass.SetCallbackSelected", "SlotGridItemSelected")
  FlashMethod(movie, "SlotGrid.GridClass.SetCallbackUnselected", "SlotGridItemUnselected")
  FlashMethod(movie, "SlotGrid.GridClass.SetCallbackPressed", "SlotGridItemPressed")
  FlashMethod(movie, "SlotGrid.GridClass.Selected", 0)
end
local function NewCollectible()
  return {
    name = Symbol(),
    res = nil,
    ownerRes = nil,
    itemType = ITEMTYPE_Weapon,
    isLocked = false,
    numHands = 2,
    visibleIndex = -1
  }
end
local function InitializeLoadout()
  local profileData = GetProfileData()
  local wc = GetWeaponCollection()
  wc:UnlockAvailableDLC()
  local numSelectedWeapons = profileData:GetNumSelectedWeapons(mCharId)
  if numSelectedWeapons < 1 then
    return
  end
  local maxWeaponsInLoadout = 2
  if mCharId == D2_Game.JACKIE then
    maxWeaponsInLoadout = 3
  end
  for i = 1, numSelectedWeapons do
    if i > maxWeaponsInLoadout then
      break
    end
    local theWeaponRes = profileData:GetSelectedWeapon(mCharId, i - 1)
    InitializeReplaceableWeaponSlot(i, theWeaponRes)
  end
  if maxWeaponsInLoadout == 2 then
    mSlotList[3] = NewWeaponSlot()
    mSlotList[3].isReplaceable = false
    mSlotList[3].numHands = 1
    if mAvatar:GetCharacterType() == D2_Game.INUGAMI then
      mSlotList[3].weaponName = "D2Katana"
    elseif mAvatar:GetCharacterType() == D2_Game.JP_DUMOND then
      mSlotList[3].weaponName = "D2Staff"
    elseif mAvatar:GetCharacterType() == D2_Game.SHOSHANNA then
      mSlotList[3].weaponName = "DarknessPistol"
    elseif mAvatar:GetCharacterType() == D2_Game.JIMMY_WILSON then
      mSlotList[3].weaponName = "D2Hatchet"
    end
  end
  local visibleIndex1Hand = 0
  local visibleIndex2Hand = 0
  local numCollectedWeapons = wc:GetNumCollectedWeapons()
  for i = 1, numCollectedWeapons do
    local res = wc:GetCollectedWeapon(i - 1, true)
    if IsNull(res) then
    else
      local name = tostring(res:GetName())
      mCollectibleList[name] = NewCollectible()
      mCollectibleList[name].name = name
      mCollectibleList[name].res = res
      mCollectibleList[name].itemType = ITEMTYPE_Weapon
      mCollectibleList[name].isLocked = wc:ActuallyHasWeapon(i - 1) == false
      if mCollectibleList[name].res:IsOneHanded() then
        mCollectibleList[name].numHands = 1
        mCollectibleList[name].visibleIndex = visibleIndex1Hand
        visibleIndex1Hand = visibleIndex1Hand + 1
      else
        mCollectibleList[name].numHands = 2
        mCollectibleList[name].visibleIndex = visibleIndex2Hand
        visibleIndex2Hand = visibleIndex2Hand + 1
      end
      local weaponUpgradeRules = res:GetUpgradeRules()
      if not IsNull(weaponUpgradeRules) then
        local n = weaponUpgradeRules:GetNumUpgrades()
        for j = 1, n do
          local thisUpgrade = tostring(weaponUpgradeRules:GetUpgradeNameByIndex(j - 1))
          if not IsNull(thisUpgrade) and thisUpgrade ~= "" then
            mCollectibleList[thisUpgrade] = NewCollectible()
            mCollectibleList[thisUpgrade].visibleIndex = j - 1
            mCollectibleList[thisUpgrade].name = thisUpgrade
            mCollectibleList[thisUpgrade].res = nil
            mCollectibleList[thisUpgrade].ownerRes = res
            mCollectibleList[thisUpgrade].itemType = ITEMTYPE_Upgrade
            mCollectibleList[thisUpgrade].isLocked = true
            mCollectibleList[thisUpgrade].numHands = 0
          end
        end
      end
      local numCollectedUpgrades = wc:GetNumCollectedUpgrades(res)
      for j = 1, numCollectedUpgrades do
        local upgradeRes = wc:GetCollectedUpgrade(res, j - 1)
        local name = tostring(upgradeRes:GetName())
        mCollectibleList[name].res = upgradeRes
        mCollectibleList[name].isLocked = false
      end
    end
  end
end
function Initialize(movie)
  movie:SetTexture("BinkPlaceholder.png", binkTexture)
  gRegion:StartVideoTexture(binkTexture)
  if not Engine.GetPlayerProfileMgr():IsLoggedIn() then
    Engine.GetPlayerProfileMgr():LogIn(1, false, false, 0)
  end
  mMovieInstance = movie
  mIsMultiplayer = not IsNull(Engine.GetMatchingService():GetSession())
  local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  local profileData = playerProfile:GetGameSpecificData()
  if profileData == nil then
    return -1
  end
  movie:SetLocalized("Title.TxtHolder.Txt.text", "/D2/Language/Menu/Loadout_Title")
  FlashMethod(movie, "MenuBackgroundClip.gotoAndStop", "LoadoutMenuPosition")
  movie:SetVariable("MenuBackgroundClip.CityBackground._visible", false)
  InitializeWeaponStats(movie, "SlotInfo")
  InitializeWeaponStats(movie, "WeaponInfo")
  movie:SetLocalized("SlotInfo.NameTitle.text", "/D2/Language/Menu/Loadout_SlotInfo_NameTitle")
  movie:SetLocalized("SlotInfo.TypeTitle.text", "/D2/Language/Menu/Loadout_SlotInfo_TypeTitle")
  movie:SetLocalized("SlotInfo.DescriptionTitle.text", "/D2/Language/Menu/Loadout_SlotInfo_DescriptionTitle")
  local weaponCollection = profileData:GetWeaponCollection()
  weaponCollection:ClearUpgradeNotice()
  weaponCollection:ClearWeaponNotice()
  mLocalPlayers = gRegion:ScriptGetLocalPlayers()
  mAvatar = mLocalPlayers[1]:GetAvatar()
  mCharId = mAvatar:GetCharacterType()
  FlashMethod(movie, "Initialize")
  InitializeLoadout()
  InitializeSlotGrid(movie)
  InitializePieceGrid(movie)
  InitializeItemGrid(movie)
  movie:SetVariable("ItemTemplateBig._visible", false)
  movie:SetVariable("ItemTemplateSmall._visible", false)
  for i = 1, #statusList do
    FlashMethod(movie, "StatusBar.StatusBarClass.AddItem", statusList[i], true)
  end
  FlashMethod(movie, "StatusBar.StatusBarClass.SetCallbackOnPress", "StatusButtonPressed")
  SetScreenState(movie, SCREENSTATE_SelectingSlot)
  local levelInfo = gRegion:GetLevelInfo()
  local postProcess = levelInfo.postProcess
  originalScreenBlur = postProcess.blur
  originalFocalDepth = postProcess.focalDepth
  postProcess.blur = 1
  postProcess.focalDepth = 0
end
function Update(movie)
  if mIsMultiplayer == true and Engine.GetMatchingService():IsHost() == false then
    local curMatchState = Engine.GetMatchingService():GetState()
    if curMatchState ~= SESSIONSTATE_WaitingForPlayers and curMatchState ~= SESSIONSTATE_JoiningSession and curMatchState ~= SESSIONSTATE_CreatingSession then
      movie:Close()
      return
    end
    if IsNull(Engine.GetMatchingService():GetSession()) then
      movie:Close()
      return
    end
  end
end
function OnChallengeUnlocked()
end
local function Back(movie)
  if mSavePopup ~= nil then
    return
  end
  gRegion:PlaySound(sndGoBack, Vector(), false)
  if GetScreenState() == SCREENSTATE_SelectingItem then
    SetScreenState(movie, SCREENSTATE_SelectingPiece)
    return
  elseif GetScreenState() == SCREENSTATE_SelectingPiece then
    SetScreenState(movie, SCREENSTATE_SelectingSlot)
    return
  end
  if not IsNull(exitLoadoutScreenChallenge) then
    local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
    playerProfile:Unlock(exitLoadoutScreenChallenge, "OnChallengeUnlocked")
  end
  local levelInfo
  levelInfo = gRegion:GetLevelInfo()
  local postProcess = levelInfo.postProcess
  postProcess.blur = originalScreenBlur
  postProcess.focalDepth = originalFocalDepth
  mSavePopup = movie:PushChildMovie(popupConfirmMovie)
  FlashMethod(mSavePopup, "CreateOkCancel", "/D2/Language/Menu/Profile_SavingPleaseWait", "", "", "")
  SaveProfile()
end
function StatusButtonPressed(movie, buttonArg)
  if mSavePopup ~= nil then
    return
  end
  local index = tonumber(buttonArg) + 1
  gRegion:PlaySound(sndGenericSelect, Vector(), false)
  if statusList[index] == statusBack then
    Back(movie)
  elseif statusList[index] == statusTalents then
    movie:PushChildMovie(talentsScreen)
  end
end
function onKeyDown_MENU_CANCEL(movie)
  Back(movie)
  return true
end
local function GetActiveGridName()
  if GetScreenState() == SCREENSTATE_SelectingItem then
    return GRID_Item
  elseif GetScreenState() == SCREENSTATE_SelectingPiece then
    return GRID_Piece
  else
    return GRID_Slot
  end
end
function onKeyDown_MENU_RIGHT_FROM_ANALOG(movie)
  return false
end
function onKeyDown_MENU_RIGHT(movie)
  return false
end
function onKeyDown_MENU_LEFT_FROM_ANALOG(movie)
  return false
end
function onKeyDown_MENU_LEFT(movie)
  return false
end
function onKeyDown_MENU_UP_FROM_ANALOG(movie)
  return false
end
function onKeyDown_MENU_UP(movie)
  return LIB.GridClassScroll(movie, GetActiveGridName(), 0, -1)
end
function onKeyDown_MENU_DOWN_FROM_ANALOG(movie)
  return false
end
function onKeyDown_MENU_DOWN(movie)
  return LIB.GridClassScroll(movie, GetActiveGridName(), 0, 1)
end
local function ChangeSkin(movie)
  local slotIdx = mGridInfo[GRID_Slot].selectionIdx
  local wr = mSlotList[slotIdx + 1].weaponRes
  local wc = GetWeaponCollection()
  local profile = GetProfileData()
  mSlotList[slotIdx + 1].skinIdx = mSlotList[slotIdx + 1].skinIdx + 1
  if mSlotList[slotIdx + 1].skinIdx > wc:GetNumCollectedSkins(wr) then
    mSlotList[slotIdx + 1].skinIdx = 0
  end
  local skinName = wr:GetName()
  if mSlotList[slotIdx + 1].skinIdx > 0 then
    local newSkin = wc:GetCollectedSkin(wr, mSlotList[slotIdx + 1].skinIdx - 1)
    profile:SetSelectedSkin(mCharId, slotIdx, newSkin)
    skinName = newSkin:GetName()
  else
    profile:ClearSkin(mCharId, slotIdx)
  end
  UpdateSkinName(movie)
  UpdateWeaponImage(movie, "WeaponInfo", skinName)
  gRegion:PlaySound(sndScroll, Vector(), false)
end
function onKeyDown_MENU_GENERIC1(movie)
  if mSavePopup ~= nil then
    return
  end
  if IsButtonEnabled(statusRemove) then
    local profileData = GetProfileData()
    local curSlotIdx = mGridInfo[GRID_Slot].selectionIdx
    local curPieceIdx = mGridInfo[GRID_Piece].selectionIdx
    local curUpgradeRes = mSlotList[curSlotIdx + 1].upgradeResList[curPieceIdx]
    if not IsNull(curUpgradeRes) and curUpgradeRes ~= "" then
      profileData:RemoveUpgrade(mCharId, curSlotIdx, curUpgradeRes)
      mSlotList[curSlotIdx + 1].upgradeResList[curPieceIdx] = ""
      BuildFilteredItemList(movie, "")
      SetScreenState(movie, SCREENSTATE_SelectingPiece)
    end
  end
end
function onKeyDown_MENU_GENERIC2(movie)
  if mSavePopup ~= nil then
    return
  end
  if IsButtonEnabled(statusTalents) then
  elseif IsButtonEnabled(statusChangeSkin) then
    ChangeSkin(movie)
  end
end

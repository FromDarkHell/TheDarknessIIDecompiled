local initialWeaponsRetrieved = false
local mainHandWeapon, offHandWeapon
local challengeFailed = false
function Initialize()
  challengeFailed = false
end
function Update(player, delta)
  if not initialWeaponsRetrieved and not IsNull(player) then
    local avatar = player:GetAvatar()
    local ic = avatar:ScriptInventoryControl()
    if ic == nil or IsNull(ic) then
      return 0
    end
    mainHandWeapon = ic:GetWeaponInHand(Engine.MAIN_HAND)
    offHandWeapon = ic:GetWeaponInHand(Engine.OFF_HAND)
    initialWeaponsRetrieved = true
  end
  if challengeFailed then
    return -1
  end
  return 0
end
function MatchAttackEvent(scriptDamageData, player)
  local sourceObject = scriptDamageData:GetSourceObject()
  if not IsNull(sourceObject) and sourceObject == mainHandWeapon or sourceObject == offHandWeapon then
    challengeFailed = true
  end
  return false
end
function MatchTagEvent(player, tag)
  if challengeFailed then
    return false
  end
  if tag == "ENDMISSION" then
    return true
  end
  return false
end

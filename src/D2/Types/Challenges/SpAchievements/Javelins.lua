needsImpaleCheck = true
multiKillCount = 2
local lastJavelin, lastPlayer
local killCount = 0
function MatchAttackEvent(damageData, player)
  local newJavelin = damageData:GetSourceObject()
  if IsNull(newJavelin) then
    killCount = 0
  elseif IsNull(lastJavelin) or IsNull(lastPlayer) then
    killCount = 1
  elseif lastJavelin == newJavelin then
    killCount = killCount + 1
  else
    killCount = 1
  end
  lastJavelin = newJavelin
  lastPlayer = player
  if needsImpaleCheck then
    return false
  else
    return killCount >= multiKillCount
  end
end
function Update(player, delta)
  local playerAvatar = gRegion:GetLocalPlayer()
  if not IsNull(playerAvatar) and not IsNull(playerAvatar:GetCarriedEntity()) then
    killCount = 0
  end
  if not IsCensored() then
  end
  if needsImpaleCheck and not IsNull(lastJavelin) and lastPlayer == player and lastJavelin:PinningEnabled() and killCount >= multiKillCount then
    repeat
      lastJavelin = nil
      lastPlayer = nil
      do return multiKillCount end
      do break end -- pseudo-goto
      if lastJavelin:GetNumberOfPinnedRagdolls() >= multiKillCount then
        lastJavelin = nil
        lastPlayer = nil
        return multiKillCount
      end
    until true
  end
  return 0
end

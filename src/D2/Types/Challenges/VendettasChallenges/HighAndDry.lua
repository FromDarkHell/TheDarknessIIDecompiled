containerLevel = 1
local finalWaveStage = false
local challengeFailed = false
local timeToJumpOnContainer = 5
function Initialize()
end
function Update(player, delta)
  if not finalWaveStage then
    return 0
  end
  local avatar = player:GetAvatar()
  if IsNull(avatar) then
    return 0
  end
  if 0 < timeToJumpOnContainer then
    timeToJumpOnContainer = timeToJumpOnContainer - delta
  end
  if 0 < timeToJumpOnContainer then
    return 0
  end
  local pos = avatar:GetPosition()
  if pos.y < containerLevel - 0.1 then
    challengeFailed = true
  end
  return 0
end
function MatchTagEvent(player, tag)
  if challengeFailed then
    return false
  end
  if tag == "FINALWAVEDONE" then
    return true
  end
  if tag == "FINALWAVESTART" then
    finalWaveStage = true
  end
  return false
end

timeToReachVan = 10
local timeLeft = 0
function Update(player, delta)
  if 0 < timeLeft then
    timeLeft = timeLeft - delta
    if timeLeft <= 0 then
      return -1
    end
  end
  return 0
end
function MatchTagEvent(player, tag)
  if tag == "VANSTART" then
    timeLeft = timeToReachVan
  elseif tag == "TRIGGERREACHED" and 0 < timeLeft then
    return true
  end
  return false
end

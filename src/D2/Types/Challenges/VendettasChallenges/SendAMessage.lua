wantedPart = 1
wantedRatio = 50
local goodHits = 0
local badHits = 0
function MatchAttackEvent(scriptDamageData, player)
  if scriptDamageData:GetHitPart() == wantedPart then
    goodHits = goodHits + 1
  else
    badHits = badHits + 1
  end
  return false
end
function MatchTagEvent(player, tag)
  if tag == "ENDMISSION" then
    local ratio = goodHits * 100 / (goodHits + badHits)
    return ratio > wantedRatio
  end
  return false
end

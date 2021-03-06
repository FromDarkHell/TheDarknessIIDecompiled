barrelTag = Symbol()
local craneRideStartTag = "CRANESTART"
local craneRideEndTag = "CRANEEND"
local onCrane = false
local barrelDestroyed = false
function Initialize()
  onCrane = false
  barrelDestroyed = false
end
function Update(player, delta)
  if barrelDestroyed and onCrane then
    return -1
  end
  return 0
end
function MatchTagEvent(player, tag)
  if tag == craneRideStartTag then
    onCrane = true
    barrelDestroyed = false
    return false
  elseif tag == craneRideEndTag then
    onCrane = false
    return not barrelDestroyed
  end
  return false
end
function MatchDecorationDestructionEvent(player, entity)
  if entity:GetTag() == barrelTag then
    barrelDestroyed = true
  end
  return false
end

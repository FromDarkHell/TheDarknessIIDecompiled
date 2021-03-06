doorDirTrigger = Instance()
doorPanelHint = Instance()
doorWireHint = Instance()
doorPanel = Instance()
doorWireHitProxy = Instance()
wireHintDelay = 10
local panelGrabbed = false
local wiresDestroyed = false
local wireHintEnabled = false
local playerInArea = false
function DoorHint()
  if not IsNull(doorDirTrigger) then
    ObjectPortHandler(doorDirTrigger, "OnPassedThrough")
    ObjectPortHandler(doorDirTrigger, "OnPassedBack")
  end
  if not IsNull(doorPanel) then
    ObjectPortHandler(doorPanel, "OnPickedUp")
  end
  if not IsNull(doorWireHitProxy) then
    ObjectPortHandler(doorWireHitProxy, "OnDamaged")
  end
  if IsNull(doorPanelHint) then
  end
  if IsNull(doorWireHint) then
  end
  while wiresDestroyed == false do
    if playerInArea == true then
      if panelGrabbed == true then
        doorPanelHint:FirePort("Close")
      end
      if wireHintEnabled == false then
        doorWireHint:FirePort("Close")
      end
    else
      doorPanelHint:FirePort("Close")
      doorWireHint:FirePort("Close")
    end
    Sleep(0.5)
  end
  doorPanelHint:FirePort("Close")
  doorWireHint:FirePort("Close")
end
function OnPassedThrough(entity)
  playerInArea = true
  if panelGrabbed == false then
    doorPanelHint:FirePort("Open")
  elseif wireHintEnabled == true then
    doorWireHint:FirePort("Open")
  end
end
function OnPassedBack(entity)
  playerInArea = false
end
function OnPickedUp(entity)
  panelGrabbed = true
  local t = 0
  while wiresDestroyed == false and t < wireHintDelay do
    Sleep(1)
    t = t + 1
  end
  if wiresDestroyed == false then
    wireHintEnabled = true
    if playerInArea == true then
      doorWireHint:FirePort("Open")
    end
  end
end
function OnDamaged(entity)
  wiresDestroyed = true
  wireHintEnabled = false
end

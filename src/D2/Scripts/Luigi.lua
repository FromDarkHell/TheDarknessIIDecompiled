phoneAnim = Resource()
panicAnims = {
  Resource()
}
tauntAnims = {
  Resource()
}
staggerDeathAnim = Resource()
trailerDestinationStart = Instance()
trailerDestinationEnd = Instance()
trailerGlassHitProxy = Instance()
exitDestination = Instance()
spawner = Instance()
windowDecoration = Instance()
trailer = Instance()
burntAvatarModifier = Instance()
c4 = Instance()
c4Pickup = Instance()
c4PlantContextAction = Instance()
skeletalFire = Type()
run = false
align = false
exitOnAlert = false
exitOnCombat = false
exitOnDamage = false
exitOnEnemySeen = false
exitOnEnemySeenRadius = 10
local c4PickedUp = false
local c4Planted = false
local currentSound, agentDamageController
function OnDestroyed(object)
  if object == c4Pickup then
    c4PickedUp = true
  elseif object == windowDecoration then
    agentDamageController:SetDamageMultiplier(1)
  end
end
function OnFinished(object)
  if object == c4PlantContextAction then
    c4Planted = true
  end
end
local setAgent = function(agent)
  if IsNull(agent) == false then
    agent:SetExitOnAlertAwareness(exitOnAlert)
    agent:SetExitOnCombatAwareness(exitOnCombat)
    agent:SetExitOnDamage(exitOnDamage)
    agent:SetExitOnEnemySeen(exitOnEnemySeen, exitOnEnemySeenRadius)
  end
end
function Luigi(agent)
  setAgent(agent)
  local avatar = agent:GetAvatar()
  local damageControl = avatar:DamageControl()
  agentDamageController = damageControl
  damageControl:SetDamageMultiplier(0)
  agent:SetIdleAnimation(phoneAnim)
  c4PickedUp = false
  c4Planted = false
  if IsNull(c4Pickup) == false then
    ObjectPortHandler(c4Pickup, "OnDestroyed")
  else
    c4PickedUp = true
  end
  if not IsNull(windowDecoration) then
    ObjectPortHandler(windowDecoration, "OnDestroyed")
  end
  if IsNull(c4PlantContextAction) == false then
    ObjectPortHandler(c4PlantContextAction, "OnFinished")
  end
  agent:MoveTo(trailerDestinationStart, false, align, true)
  Sleep(0.5)
  while c4PickedUp == false do
    Sleep(0)
  end
  agent:MoveTo(trailerDestinationEnd, false, align, true)
  agent:SetIdleAnimation(panicAnims[1])
  while c4Planted == false do
    Sleep(0)
  end
  Sleep(4)
  damageControl:SetDamageMultiplier(1)
  trailer:Destroy()
  Sleep(1)
  avatar:Attach(skeletalFire, Symbol(), Vector(), Rotation())
  burntAvatarModifier:FirePort("Activate")
  agent:MoveTo(exitDestination, true, align, false)
  Sleep(2.5)
  agent:PlayAnimation(staggerDeathAnim, true)
  spawner:FirePort("Kill Agents")
end

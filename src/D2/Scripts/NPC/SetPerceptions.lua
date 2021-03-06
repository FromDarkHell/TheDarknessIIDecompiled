exitOnCombatAwareness = true
exitOnAlert = false
exitOnDamage = true
exitOnEnemySeen = true
enemySeenRadius = 10
perceptionDistance = 200
perceptionDarkDist = 50
perceptionFov = 170
perceptionVertFov = 45
tintMaterial = Resource()
headDeco = Type()
animation = Resource()
local SetAgent = function(agent)
  agent:SetExitOnEnemySeen(exitOnEnemySeen, enemySeenRadius)
  agent:SetExitOnCombatAwareness(exitOnCombatAwareness)
  agent:SetExitOnAlertAwareness(exitOnAlert)
  agent:SetExitOnDamage(exitOnDamage)
end
local SetSuit = function(agent)
  local avatar = agent:GetAvatar()
  if IsNull(headDeco) == false then
    avatar:Attach(headDeco, Symbol())
  end
  if IsNull(tintMaterial) == false then
    avatar:SetOverrideMaterial(0, tintMaterial)
  end
end
function SetViewPerceptions(agent)
  SetAgent(agent)
  SetSuit(agent)
  agent:SetIdleViewPerception(perceptionDistance, perceptionDarkDist, perceptionFov, perceptionVertFov)
  if IsNull(animation) == false then
    agent:LoopAnimation(animation)
  end
end

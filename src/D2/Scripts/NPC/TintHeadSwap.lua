tintMaterial = Resource()
headDeco = Type()
animation = Resource()
exitOnDamage = true
exitOnAlert = true
exitOnCombat = true
maxViewDistance = 1
maxDarkDistance = 0
hFov = 60
vFov = 15
local SetSuit = function(agent)
  local avatar = agent:GetAvatar()
  if IsNull(headDeco) == false then
    avatar:Attach(headDeco, Symbol())
  end
  if IsNull(tintMaterial) == false then
    avatar:SetOverrideMaterial(0, tintMaterial)
  end
end
function SetAppearence(agent)
  SetSuit(agent)
  agent:SetExitOnDamage(exitOnDamage)
  agent:SetExitOnAlertAwareness(exitOnAlert)
  agent:SetExitOnCombatAwareness(exitOnCombat)
  if IsNull(animation) == false then
    agent:LoopAnimation(animation)
  end
end
function SetAppearenceOnSleepingAgent(agent)
  SetSuit(agent)
  agent:SetExitOnDamage(exitOnDamage)
  agent:SetExitOnAlertAwareness(exitOnAlert)
  agent:SetExitOnCombatAwareness(exitOnCombat)
  agent:SetIdleViewPerception(maxViewDistance, maxDarkDistance, hFov, vFov)
  if IsNull(animation) == false then
    agent:LoopAnimation(animation)
  end
end

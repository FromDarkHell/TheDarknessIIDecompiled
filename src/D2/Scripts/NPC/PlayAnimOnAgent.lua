anim = Resource()
exitOnDamage = true
exitOnAlert = true
exitOnCombat = true
portInObject = Instance()
portToFire = String()
StopScriptedMode = false
OriginalPerceptionViewDistance = 30
OriginalPerceptionDarkViewDistance = 15
OriginalPerceptionHFOV = 60
OriginalPerceptionVFOV = 15
OriginalHearingSensitivity = -36
function PlaySimpleAnim(agent)
  agent:SetExitOnDamage(exitOnDamage)
  agent:SetExitOnAlertAwareness(exitOnAlert)
  agent:SetExitOnCombatAwareness(exitOnCombat)
  agent:PlayAnimation(anim, true)
  if StopScriptedMode then
    agent:StopScriptedMode()
  end
end
function PlaySimpleLoopingAnim(agent)
  agent:SetExitOnDamage(exitOnDamage)
  agent:SetExitOnAlertAwareness(exitOnAlert)
  agent:SetExitOnCombatAwareness(exitOnCombat)
  agent:LoopAnimation(anim)
end
function PlaySimpleAnimAvatar(agent)
  local avatar = agent:GetAvatar()
  agent:SetExitOnDamage(exitOnDamage)
  agent:SetExitOnAlertAwareness(exitOnAlert)
  agent:SetExitOnCombatAwareness(exitOnCombat)
  avatar:PlayAnimation(anim, true, true)
  if not IsNull(portInObject) then
    portInObject:FirePort(portToFire)
  end
end
function PlaySimpleLoopingAnimWithoutPerceptions(agent)
  agent:SetExitOnDamage(exitOnDamage)
  agent:SetExitOnAlertAwareness(exitOnAlert)
  agent:SetExitOnCombatAwareness(exitOnCombat)
  agent:SetIdleViewPerception(1, 1, 1, 1)
  agent:SetHearingSensitivity(300)
  agent:LoopAnimation(anim)
  local InitialHealth = agent:GetAvatar():GetHealth()
  if IsNull(_T.gAgentLowPerc) then
    _T.gAgentLowPerc = true
  end
  while _T.gAgentLowPerc do
    agent:GetAvatar():SetHealth(InitialHealth)
    Sleep(0.1)
  end
  agent:SetIdleViewPerception(OriginalPerceptionViewDistance, OriginalPerceptionDarkViewDistance, OriginalPerceptionHFOV, OriginalPerceptionVFOV)
  agent:SetHearingSensitivity(OriginalHearingSensitivity)
  if StopScriptedMode then
    agent:StopScriptedMode()
  end
end
function DisableAgentsLowPerceptions()
  _T.gAgentLowPerc = false
end

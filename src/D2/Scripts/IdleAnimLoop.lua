StopAnimPlayerDistance = 15
Anims = {
  Resource()
}
Anim = Resource()
function RandomAnimationLoop(agent)
  agent:SetExitOnEnemySeen(true, StopAnimPlayerDistance)
  agent:SetExitOnCombatAwareness(true)
  agent:SetExitOnAlertAwareness(true)
  agent:SetExitOnDamage(true)
  local npcAvatar = agent:GetAvatar()
  local startingHealth = npcAvatar:GetHealth()
  while startingHealth == npcAvatar:GetHealth() do
    local animnum = RandomInt(1, #Anims)
    agent:PlayAnimation(Anims[animnum], true)
    Sleep(0)
  end
  agent:StopScriptedMode()
end
function LoopAnimation(agent)
  agent:LoopAnimation(Anim)
  agent:SetExitOnEnemySeen(true, StopAnimPlayerDistance)
  agent:SetExitOnCombatAwareness(true)
  agent:SetExitOnAlertAwareness(true)
  agent:SetExitOnDamage(true)
end

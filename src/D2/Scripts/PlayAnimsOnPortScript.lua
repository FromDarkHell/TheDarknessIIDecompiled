animSequence = {
  Resource()
}
loopLastAnim = true
setAllExits = true
setExitOnSeen = false
setExitOnAlert = false
setExitOnCombat = false
function PlayAnimSequence(agent)
  agent:SetAllExits(setAllExits)
  agent:SetExitOnEnemySeen(setExitOnSeen, 20)
  agent:SetExitOnAlertAwareness(setExitOnAlert)
  agent:SetExitOnCombatAwareness(setExitOnCombat)
  local npcAvatar = agent:GetAvatar()
  if #animSequence > 1 then
    for i = 1, #animSequence - 1 do
      agent:PlayAnimation(animSequence[i], true)
    end
  end
  if loopLastAnim == true then
    agent:LoopAnimation(animSequence[#animSequence])
  else
    agent:PlayAnimation(animSequence[#animSequence], true)
    agent:StopScriptedMode()
  end
end

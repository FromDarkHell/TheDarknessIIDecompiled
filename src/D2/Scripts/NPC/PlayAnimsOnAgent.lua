anims = {
  Resource()
}
exitOnDamage = true
exitOnAlert = true
exitOnCombat = true
loopLastAnim = false
function PlaySimpleLoopingAnim(agent)
  agent:SetExitOnDamage(exitOnDamage)
  agent:SetExitOnAlertAwareness(exitOnAlert)
  agent:SetExitOnCombatAwareness(exitOnCombat)
  for i = 1, #anims do
    if loopLastAnim == true and anims[i + 1] == nil then
      if not IsNull(agent) then
        agent:LoopAnimation(anims[i])
      end
      return
    elseif not IsNull(agent) then
      agent:PlayAnimation(anims[i], true)
    end
  end
end

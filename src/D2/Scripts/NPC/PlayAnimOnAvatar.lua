delay = 0
agentName = String()
npcAvatarType = Type()
animSequence = {
  Resource()
}
loopLastAnim = false
pushOthers = false
function PlayAnim()
  Sleep(delay)
  local agent, avatar
  if agentName ~= "" and agentName ~= nil then
    agent = _T.agentArray[agentName]
  else
    avatar = gRegion:FindNearest(npcAvatarType, Vector())
    agent = avatar:GetAgent()
  end
  if IsNull(avatar) then
    avatar = agent:GetAvatar()
  end
  avatar:PushOtherControllers(pushOthers)
  if IsNull(agent) == false then
    for i = 1, #animSequence do
      if loopLastAnim == true and animSequence[i + 1] == nil then
        agent:LoopAnimation(animSequence[i])
      else
        agent:PlayAnimation(animSequence[i], true)
        avatar:PushOtherControllers(pushOthers)
      end
    end
  else
    Broadcast("No Agent Found!")
  end
end

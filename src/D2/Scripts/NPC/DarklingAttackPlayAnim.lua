darklingAvatarType = Type()
targetAvatarType = Type()
finalAnim = Resource()
function Attack()
  local player = gRegion:GetPlayerAvatar()
  local darklingAvatar, darklingAgent, targetAvatar
  while IsNull(darklingAvatar) == true do
    darklingAvatar = gRegion:FindNearest(darklingAvatarType, Vector())
    Sleep(0)
  end
  while IsNull(targetAvatar) == true do
    targetAvatar = gRegion:FindNearest(targetAvatarType, darklingAvatar:GetPosition())
    Sleep(0)
  end
  darklingAgent = darklingAvatar:GetAgent()
  darklingAgent:SetAllExits(false)
  darklingAgent:DoFinisher(targetAvatar, true)
  darklingAgent:PlayAnimation(finalAnim, true)
  darklingAgent:StopScriptedMode()
end

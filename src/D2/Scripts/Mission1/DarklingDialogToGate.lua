npcAvatarType = Type()
destination = Instance()
damageMultiplier = 0
delay = 0
sound = Resource()
run = false
returnToAiControlAfterMoving = false
function GetDarklingToGate()
  Sleep(0)
  local avatar, agent
  local playerPosition = gRegion:GetPlayerAvatar():GetPosition()
  while IsNull(avatar) do
    avatar = gRegion:FindNearest(npcAvatarType, Vector(), INF)
    Sleep(0)
  end
  agent = avatar:GetAgent()
  local darklingDamageController = avatar:DamageControl()
  darklingDamageController:SetDamageMultiplier(damageMultiplier)
  Sleep(delay)
  if not IsNull(avatar) then
    agent:PlaySpeech(sound, true)
  end
  if not IsNull(avatar) then
    local agent = avatar:GetAgent()
    agent:MoveTo(destination, run, true, true)
    Sleep(0)
    if returnToAiControlAfterMoving and not IsNull(agent) then
      agent:ReturnToAiControl()
    end
  else
  end
end

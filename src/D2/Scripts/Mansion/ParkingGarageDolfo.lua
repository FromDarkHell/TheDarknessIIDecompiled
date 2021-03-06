woundAnimation = Resource()
idleAnimation = Resource()
darknessVO = Resource()
vinnieConvo = Instance()
vinnieType = Type()
brotherhoodType = Type()
dest = Instance()
targetType = Type()
targetIsPlayer = false
function DolfoWounded(agent)
  local avatar = agent:GetAvatar()
  agent:ClearScriptActions()
  agent:SetAllExits(false)
  agent:ExitCover()
  agent:SetIdleAnimation(idleAnimation)
  agent:PlayAnimation(woundAnimation, true)
end
function VinnieElevator()
  local player = gRegion:GetPlayerAvatar()
  player:PlaySound(darknessVO, true)
  vinnieConvo:FirePort("Enable")
end
function VinnieLeaveElevator()
  local player = gRegion:GetPlayerAvatar(0)
  local avatar = gRegion:FindNearest(vinnieType, player:GetPosition(), 10)
  local agent = avatar:GetAgent()
  agent:MoveTo(dest, false, true, true)
  avatar:FaceTo(player:GetPosition())
end
function VinnieEnterElevator()
  local player = gRegion:GetPlayerAvatar(0)
  local avatar = gRegion:FindNearest(vinnieType, player:GetPosition(), 10)
  local agent = avatar:GetAgent()
  agent:MoveTo(dest, false, true, true)
  avatar:FaceTo(player:GetPosition())
end
function StopScriptAndShootTarget(agent)
  local target
  agent:ClearScriptActions()
  if not IsNull(targetType) then
    target = gRegion:FindNearest(targetType, agent:GetAvatar():GetPosition(), 20)
  elseif targetIsPlayer then
    target = gRegion:GetPlayerAvatar()
  end
  agent:MoveTo(dest, true, true, false)
  agent:SetTarget(target)
  agent:ShootTarget(target, 3, true, true)
  agent:StopScriptedMode()
end

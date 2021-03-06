darklingAvatarType = Type()
targetAvatarType = Type()
darklingPickupRes = Resource()
giveGunAnim = Resource()
giveGunAnimLoop = Resource()
giveGunPosition = Instance()
gunPickupType = Type()
giveGunDistance = 1
jackieModifier = Instance()
trigger = Instance()
darklingBark = Resource()
jackieBark = Resource()
darklingSeq = Instance()
weaponSwitchDialog = Instance()
jackieModifierNormal = Instance()
blockingVolume = Instance()
local darklingWaiting = false
local TurnToPlayer = function(agent, entity)
  local avatar = agent:GetAvatar()
  local view = avatar:GetView()
  local newView = LookTo(avatar:EyePosition(), entity:EyePosition())
  while math.abs(view.heading - newView.heading) > 10 do
    avatar:SetView(newView)
    Sleep(0.5)
    view = avatar:GetView()
  end
end
function AttackTarget()
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
  TurnToPlayer(darklingAgent, player)
  local gunAttachment = darklingAvatar:Attach(gunPickupType, Symbol("GAME_R1_WEAPON1"))
  darklingAgent:PlayAnimation(giveGunAnim, false)
  Sleep(1.1)
  darklingAgent:LoopAnimation(giveGunAnimLoop)
  darklingAvatar:PlaySound(darklingBark, false)
  while Distance(player:GetPosition(), darklingAvatar:GetPosition()) > giveGunDistance do
    Sleep(0)
  end
  if IsNull(darklingAgent) == false then
    gunAttachment:Destroy()
  end
  jackieModifier:FirePort("Activate")
  Sleep(0.4)
  if not IsNull(jackieBark) then
    player:PlaySound(jackieBark, false)
  end
end
function MoveTo(agent)
  local darklingAvatar = agent:GetAvatar()
  local player = gRegion:GetPlayerAvatar()
  local darklingDmgControl = darklingAvatar:DamageControl()
  local timeElapsed = 0
  local gunAttachment, gunPosition, gunRotation
  darklingDmgControl:SetDamageMultiplier(0)
  agent:MoveTo(giveGunPosition, true, true, true)
  agent:PlayAnimation(giveGunAnim, false)
  agent:SetIdleAnimation(giveGunAnimLoop)
  Sleep(0.2)
  darklingWaiting = true
  gunAttachment = darklingAvatar:Attach(gunPickupType, Symbol("GAME_R1_WEAPON1"), Vector(-0.01, -0.15, -0.1), Rotation(25, 170, 160))
  gunPosition = gunAttachment:GetPosition()
  gunRotation = gunAttachment:GetRotation()
  ObjectPortHandler(gunAttachment, "OnPickedUp")
  darklingSeq:FirePort("Enable")
  Sleep(1.3)
  while darklingWaiting do
    Sleep(0)
    if 0 > darklingAvatar:GetHealth() or IsNull(darklingAvatar) then
      darklingWaiting = false
      gRegion:CreateEntity(gunPickupType, gunPosition, gunRotation)
    end
  end
  darklingDmgControl:SetDamageMultiplier(1)
  darklingSeq:FirePort("Disable")
  agent:SetIdleAnimation(nil)
  if not IsNull(agent) then
    gunAttachment:Destroy()
    agent:StopScriptedMode()
  end
  if not IsNull(jackieModifier) then
    jackieModifier:FirePort("Activate")
  end
  Sleep(0.4)
  if not IsNull(jackieBark) then
    player:PlaySound(jackieBark, false)
  end
end
function OnPickedUp(entity)
  darklingWaiting = false
  local dualWielding = false
  Sleep(0)
  weaponSwitchDialog:FirePort("Open")
  local player = gRegion:GetPlayerAvatar()
  local inventory = player:ScriptInventoryControl()
  dualWielding = inventory:DualWielding()
  while dualWielding == false do
    Sleep(0)
    dualWielding = inventory:DualWielding()
  end
  weaponSwitchDialog:FirePort("Close")
  jackieModifierNormal:FirePort("Activate")
  blockingVolume:FirePort("Disable")
end

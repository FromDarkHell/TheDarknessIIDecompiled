tankSpawnDelay = 5
maxTossDistance = 50
propaneWaypoint = Instance()
gateWaypoints = {
  Instance()
}
gateAnims = {
  Resource()
}
gate = Instance()
enableObjectOfInterestTrigger = Instance()
disableObjectOfInterestTrigger = Instance()
objectiveTrigger = Instance()
disableDarklingObjectOfInterestTrigger = Instance()
barkWaitTime = 15
tankSpawnerType = Type()
tankType = Type()
darklingCarryAnim = Resource()
darklingCarryIdleAnim = Resource()
darklingTankAvailableCallouts = {
  Resource()
}
darklingGateCallout = Resource()
local gateDestroyed = false
local playerGrabbedTank = false
local DarklingGate = function(darklingAgent)
  local darklingAvatar = darklingAgent:GetAvatar()
  darklingAgent:MoveTo(gateWaypoints[1], true, true, true)
  darklingAgent:PlayAnimation(gateAnims[1], true)
  darklingAvatar:PlaySound(darklingGateCallout, false)
  Sleep(3)
  darklingAgent:MoveTo(propaneWaypoint, true, true, true)
  Sleep(3)
  objectiveTrigger:FirePort("Execute")
end
function DarklingGiveTank(darklingAgent)
  local avatar = darklingAgent:GetAvatar()
  local tank
  local loopingIdle = false
  local damageController, tankSpawner
  local player = gRegion:GetPlayerAvatar()
  local objectOfInterestEnabled = false
  local carriedEntity
  local carryingTank = false
  local timeElapsed = 0
  local index, soundInstance
  damageController = avatar:DamageControl()
  damageController:SetDamageMultiplier(0)
  DarklingGate(darklingAgent)
  ObjectPortHandler(gate, "OnDamaged")
  while not gateDestroyed do
    tankSpawner = avatar:Attach(tankSpawnerType, Symbol("GAME_L1_WEAPON1"), Vector(0.134, -0.395, 0), Rotation(0, 0, -5))
    ObjectPortHandler(tankSpawner, "OnObjectSpawned")
    darklingAgent:PlayAnimation(darklingCarryAnim, false)
    darklingAgent:SetIdleAnimation(darklingCarryIdleAnim)
    darklingAgent:PlaySpeech(darklingTankAvailableCallouts[1], false)
    while not playerGrabbedTank do
      Sleep(0)
      timeElapsed = timeElapsed + DeltaTime()
      if timeElapsed > barkWaitTime then
        timeElapsed = 0
        index = math.random(1, #darklingTankAvailableCallouts)
        soundInstance = darklingAgent:PlaySpeech(darklingTankAvailableCallouts[index], false)
      end
      if not IsNull(soundInstance) then
        timeElapsed = 0
      end
    end
    disableDarklingObjectOfInterestTrigger:FirePort("Execute")
    darklingAgent:PlayAnimation(nil, false)
    darklingAgent:SetIdleAnimation(nil)
    darklingAgent:MoveTo(propaneWaypoint, true, true, false)
    playerGrabbedTank = false
    tank = gRegion:FindNearest(tankType, Vector())
    if not IsNull(tank) then
      tank:ScriptRunChildScript(Symbol("DistanceCheck"), false)
    end
    Sleep(0.5)
    while not IsNull(tank) do
      carriedEntity = player:GetCarriedEntity()
      if IsNull(carriedEntity) or not carriedEntity:IsA(tankType) then
        carryingTank = false
      else
        carryingTank = true
      end
      if not carryingTank and not IsNull(tank) and not objectOfInterestEnabled then
        objectOfInterestEnabled = true
      elseif (carryingTank or IsNull(tank)) and objectOfInterestEnabled then
        objectOfInterestEnabled = false
      end
      Sleep(0)
    end
    Sleep(tankSpawnDelay)
  end
  damageController:SetDamageMultiplier(1)
end
function OnObjectSpawned(entity)
  playerGrabbedTank = true
  entity:Destroy()
end
function OnDamaged(entity)
  gateDestroyed = true
end
function DistanceCheck(entity)
  local avatar = gRegion:GetPlayerAvatar()
  local playerPos = avatar:GetPosition()
  local tankPos = entity:GetPosition()
  local dist = 0
  while not IsNull(entity) and dist < maxTossDistance do
    playerPos = avatar:GetPosition()
    tankPos = entity:GetPosition()
    dist = Distance(playerPos, tankPos)
    Sleep(0)
  end
  if not IsNull(entity) then
    entity:Destroy()
  end
end

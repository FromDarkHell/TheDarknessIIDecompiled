darklingAvatarType = Type()
hitProxyType = Type()
shieldType = Type()
destination = Instance()
shieldDecoration = Instance()
shieldOffsetPosition = Vector(-0.58, -0.02, -0.4)
shieldOffsetRotation = Rotation(-128, -15, -15)
pickUpShieldAnim = Resource()
moveWithShieldAnim = Resource()
loopingShieldAnim = Resource()
enemyShootingAtDarkling = Instance()
shieldPickupLookTrigger = Instance()
shieldPickupBackupTrigger = Instance()
startPickUpInstantly = false
darklingDialog = Resource()
encounterSpawnController = Instance()
remainingEnemies = 1
attachShieldDelay = 0.3
delayBeforeMoveAnim = 1
enemyShootDelay = 3
darklingWalkTime = 10
local pickupTriggerActivated = startPickUpInstantly
function DarklingShieldSequence()
  if IsNull(shieldPickupLookTrigger) == false then
    ObjectPortHandler(shieldPickupLookTrigger, "Activated")
  end
  if IsNull(shieldPickupBackupTrigger) == false then
    ObjectPortHandler(shieldPickupBackupTrigger, "OnTouched")
  end
  local darkling = gRegion:FindNearest(darklingAvatarType, Vector())
  while IsNull(darkling) do
    darkling = gRegion:FindNearest(darklingAvatarType, Vector())
    Sleep(0)
  end
  local darklingDamageController = darkling:DamageControl()
  local darklingAgent = darkling:GetAgent()
  local boneToAttachTo = Symbol("GAME_R1_WEAPON1")
  if not IsNull(darklingAgent) then
    darklingDamageController:SetDamageMultiplier(0)
    darklingAgent:MoveTo(destination, true, true, true)
    Sleep(0)
    while pickupTriggerActivated == false do
      Sleep(0)
    end
    darklingAgent:MoveTo(destination, true, true, true)
    darklingAgent:PlayAnimation(pickUpShieldAnim, false)
    Sleep(attachShieldDelay)
    darkling:Attach(shieldType, boneToAttachTo, shieldOffsetPosition, shieldOffsetRotation)
    shieldDecoration:Destroy()
    Sleep(0)
    darklingAgent:SetBlockVoiceBarks(true, Engine.BLOCK_SOLO)
    darkling:PlaySpeech(darklingDialog, false)
    Sleep(delayBeforeMoveAnim)
    darklingAgent:LoopAnimation(moveWithShieldAnim)
    local shield = darkling:GetAttachment(shieldType)
    local t = 0
    while t < enemyShootDelay do
      Sleep(0)
      t = t + DeltaTime()
      shield = darkling:GetAttachment(shieldType)
      if IsNull(shield) then
        break
      end
    end
    enemyShootingAtDarkling:FirePort("Start Script")
    t = 0
    while t < darklingWalkTime - enemyShootDelay do
      Sleep(0)
      t = t + DeltaTime()
      shield = darkling:GetAttachment(shieldType)
      if IsNull(shield) then
        break
      end
    end
    darklingAgent:SetBlockVoiceBarks(false, Engine.BLOCK_SOLO)
    darklingAgent:LoopAnimation(loopingShieldAnim)
    shield = darkling:GetAttachment(shieldType)
    if not IsNull(shield) then
      shield:Attach(hitProxyType, Symbol())
      while encounterSpawnController:GetActiveCount() > remainingEnemies and not IsNull(gRegion:FindNearest(hitProxyType, Vector())) do
        Sleep(0)
      end
      local heldShield = gRegion:FindNearest(shieldType, darkling:GetPosition(), 2)
      if not IsNull(heldShield) then
        heldShield:Destroy()
      end
      local heldHitProxy = gRegion:FindNearest(hitProxyType, darkling:GetPosition(), 2)
      if not IsNull(heldHitProxy) then
        heldHitProxy:Destroy()
      end
    end
    if not IsNull(darklingAgent) then
      darklingAgent:StopScriptedMode()
    end
    darklingDamageController:SetDamageMultiplier(1)
  end
end
function Activated(entity)
  pickupTriggerActivated = true
end
function OnTouched(entity)
  pickupTriggerActivated = true
end

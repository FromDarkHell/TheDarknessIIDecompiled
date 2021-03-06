propaneMaxHealth = 4000
GasLeakHealthThreshold = 0.95
GasPlumeFX = Type()
gasFxPosOffsetX = 0
gasFxPosOffsetY = 1.65
BurningGasLeakHealthThreshold = 0.9
TimeAfterBurningGasLeakBeforeExplosion = 20
BurningGasLeakSound = Resource()
BurningGasLeakFX = Type()
BurningGasLight = Type()
BlastLightA = Type()
BlastLightBDelay = 0.25
BlastLightB = Type()
BlastLightTurnoffDelay = 0.99
BlastFXA = Type()
BlastFXB = Type()
BlastSmoke = Type()
hideOnDestruction = false
function Destruction()
end
local DamageStart = function(entity)
  local propaneHealth = entity:GetHealth()
  local propanePosition = entity:GetPosition()
  local gasPosition = propanePosition
  gasPosition.y = gasPosition.y
  print("Current Health: " .. propaneHealth)
  print("Max Health: " .. propaneMaxHealth)
  local healthPercent = propaneHealth / propaneMaxHealth
  if healthPercent <= GasLeakHealthThreshold then
    gRegion:CreateEntity(GasPlumeFX, gasPosition, Rotation())
  elseif healthPercent <= BurningGasLeakHealthThreshold and not BurningGasLeakFX == nil then
    gRegion:CreateEntity(BurningGasLeakFX, gasPosition, Rotation())
  end
end
function OnDamaged(entity)
  Sleep(0)
  local propaneHealth = entity:GetHealth()
  local propanePosition = entity:GetPosition()
  local propaneRotation = entity:GetRotation()
  local gasPosition = Vector(propanePosition.x + gasFxPosOffsetX, propanePosition.y + gasFxPosOffsetY, propanePosition.z)
  local t = 0
  local bla, blb, bfxa, bfxb, bglfx, bsmoke, gpfx
  local maxHealth = entity:GetDefaultHealth()
  local healthPercent = propaneHealth / maxHealth
  if healthPercent >= GasLeakHealthThreshold then
    return
  end
  if IsNull(GasPlumeFX) == false then
    gpfx = gRegion:CreateEntity(GasPlumeFX, gasPosition, propaneRotation)
  end
  while healthPercent >= BurningGasLeakHealthThreshold do
    healthPercent = entity:GetHealth() / maxHealth
    Sleep(0)
  end
  local bgls = gRegion:PlaySound(BurningGasLeakSound, propanePosition, false)
  if IsNull(BurningGasLeakFX) == false then
    bglfx = gRegion:CreateEntity(BurningGasLeakFX, gasPosition, propaneRotation)
  end
  while 0 <= healthPercent and t < TimeAfterBurningGasLeakBeforeExplosion do
    healthPercent = entity:GetHealth() / maxHealth
    t = t + DeltaTime()
    Sleep(0)
  end
  if IsNull(gpfx) == false then
    gpfx:Destroy()
  end
  if IsNull(bglfx) == false then
    bglfx:Destroy()
  end
  entity:Destroy()
  propanePosition.y = propanePosition.y + 0.33
  if IsNull(BlastLightA) == false then
    bla = gRegion:CreateEntity(BlastLightA, propanePosition, Rotation())
  end
  if IsNull(BlastSmoke) == false then
    bsmoke = gRegion:CreateEntity(BlastSmoke, propanePosition, Rotation())
  end
  if IsNull(BlastFXA) == false then
    bfxa = gRegion:CreateEntity(BlastFXA, propanePosition, Rotation())
  end
  if IsNull(bfxa) == false then
    bfxa:FirePort("Enable")
  end
  if IsNull(bsmoke) == false then
    bsmoke:FirePort("Enable")
  end
  Sleep(BlastLightBDelay)
  if IsNull(BlastLightB) == false then
    blb = gRegion:CreateEntity(BlastLightB, propanePosition, Rotation())
  end
  if IsNull(BlastFXB) == false then
    bfxb = gRegion:CreateEntity(BlastFXB, propanePosition, Rotation())
  end
  if IsNull(bfxb) == false then
    bfxb:FirePort("Enable")
  end
  Sleep(BlastLightTurnoffDelay)
  if IsNull(bla) == false then
    bla:FirePort("TurnOff")
  end
  if IsNull(blb) == false then
    blb:FirePort("TurnOff")
  end
end
function EntityStart(entity)
  local propaneHealth = entity:GetHealth()
  local propanePosition = entity:GetPosition()
  local propaneRotation = entity:GetRotation()
  local gasPosition = Vector(propanePosition.x + gasFxPosOffsetX, propanePosition.y + gasFxPosOffsetY, propanePosition.z)
  local t = 0
  local bla, blb, bfxa, bfxb, bglfx, bgll, bsmoke, gpfx
  if propaneHealth < 0 then
    return
  end
  local healthPercent = propaneHealth / propaneMaxHealth
  while healthPercent >= GasLeakHealthThreshold do
    healthPercent = entity:GetHealth() / propaneMaxHealth
    Sleep(0)
  end
  if IsNull(GasPlumeFX) == false then
    gpfx = gRegion:CreateEntity(GasPlumeFX, gasPosition, propaneRotation)
  end
  while healthPercent >= BurningGasLeakHealthThreshold do
    healthPercent = entity:GetHealth() / propaneMaxHealth
    Sleep(0)
  end
  local bgls = gRegion:PlaySound(BurningGasLeakSound, propanePosition, false)
  if IsNull(BurningGasLeakFX) == false then
    bglfx = gRegion:CreateEntity(BurningGasLeakFX, gasPosition, propaneRotation)
  end
  if IsNull(BurningGasLight) == false then
    propanePosition.y = propanePosition.y + 0.4
    bgll = gRegion:CreateEntity(BurningGasLight, propanePosition, Rotation())
  end
  while 0 <= healthPercent and t < TimeAfterBurningGasLeakBeforeExplosion do
    healthPercent = entity:GetHealth() / propaneMaxHealth
    t = t + DeltaTime()
    Sleep(0)
  end
  if IsNull(gpfx) == false then
    gpfx:Destroy()
  end
  if IsNull(bglfx) == false then
    bglfx:Destroy()
  end
  if IsNull(bgll) == false then
    bgll:TurnOff()
  end
  if hideOnDestruction then
    entity:SetVisibility(false)
  end
  entity:Destroy()
  propanePosition.y = propanePosition.y + 0.33
  if IsNull(BlastLightA) == false then
    bla = gRegion:CreateEntity(BlastLightA, propanePosition, Rotation())
  end
  if IsNull(BlastSmoke) == false then
    bsmoke = gRegion:CreateEntity(BlastSmoke, propanePosition, Rotation())
  end
  if IsNull(BlastFXA) == false then
    bfxa = gRegion:CreateEntity(BlastFXA, propanePosition, Rotation())
  end
  if IsNull(bfxa) == false then
    bfxa:Enable()
  end
  if IsNull(bsmoke) == false then
    bsmoke:Enable()
  end
  Sleep(BlastLightBDelay)
  if IsNull(BlastLightB) == false then
    blb = gRegion:CreateEntity(BlastLightB, propanePosition, Rotation())
  end
  if IsNull(BlastFXB) == false then
    bfxb = gRegion:CreateEntity(BlastFXB, propanePosition, Rotation())
  end
  if IsNull(bfxb) == false then
    bfxb:Enable()
  end
  Sleep(BlastLightTurnoffDelay)
  if IsNull(bla) == false then
    bla:TurnOff()
  end
  if IsNull(blb) == false then
    blb:TurnOff()
  end
end

healthThreshold = 75
function DestroyCover_OnDamaged(instigator)
  Sleep(0)
  local cover = gRegion:FindInScope(instigator:GetScope(), Type("/EE/Types/Engine/CoverPoint"))
  if cover ~= nil then
    local decoHealth = instigator:GetHealth()
    if decoHealth <= healthThreshold then
      for i = 1, #cover do
        cover[i]:FirePort("Destroy")
      end
    end
  end
end
function DestroyCover_StateChange(instigator)
  local cover = gRegion:FindInScope(instigator:GetScope(), Type("/EE/Types/Engine/CoverPoint"))
  local instigatorDestroyed = true
  if instigator:GetHealth() >= 0 then
    instigatorDestroyed = false
  end
  if cover ~= nil then
    for i = 1, #cover do
      if instigatorDestroyed then
        cover[i]:FirePort("Disable")
      else
        cover[i]:FirePort("Enable")
      end
    end
  end
end

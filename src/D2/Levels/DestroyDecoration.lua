function DestroyDecoration(instigator)
  if instigator:GetHealth() >= 0 then
    return
  end
  local decoration = gRegion:FindInScope(instigator:GetScope(), Type("/EE/Types/Engine/Decoration"))
  for i = 1, #decoration do
    decoration[i]:FirePort("Destroy")
  end
end

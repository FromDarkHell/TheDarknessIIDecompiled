glowEffectsToHide = {
  Type()
}
function HideGlowEffects()
  for i = 1, #glowEffectsToHide do
    if not IsNull(glowEffectsToHide[i]) then
      local entities = gRegion:FindAll(glowEffectsToHide[i], Vector(0, 0, 0), 0, INF)
      if not IsNull(entities) then
        for j = 1, #entities do
          entities[j]:SetVisibility(false, true)
        end
      end
    end
  end
end
function ShowGlowEffects()
  for i = 1, #glowEffectsToHide do
    if not IsNull(glowEffectsToHide[i]) then
      local entities = gRegion:FindAll(glowEffectsToHide[i], Vector(0, 0, 0), 0, INF)
      if not IsNull(entities) then
        for j = 1, #entities do
          entities[j]:SetVisibility(true, true)
        end
      end
    end
  end
end

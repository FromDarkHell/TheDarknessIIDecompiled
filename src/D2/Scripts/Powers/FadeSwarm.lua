swarmLength = 5
function SwarmFade(deco)
  local t = 0
  local toFade
  while t < swarmLength do
    toFade = Abs(swarmLength / 2 - t) - swarmLength / 2 + 1
    if toFade < 0 then
      toFade = 0
    end
    toFade = 1 - toFade + (1 - toFade) * math.sin(t * 3) / 3
    deco:SetMaterialParam("fadeOut", toFade)
    t = t + DeltaTime()
    Sleep(0)
  end
end

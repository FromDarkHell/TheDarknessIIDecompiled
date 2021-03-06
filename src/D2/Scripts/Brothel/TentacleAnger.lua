angerLength = 2
darknessStream = Instance()
function AngerFlicker()
  local t = 0
  local toFade
  while t < angerLength do
    if t < angerLength / 4 then
      toFade = 4 * t / angerLength
    elseif t > angerLength / 2 then
      toFade = (angerLength - t) / (angerLength / 2)
    else
      toFade = 1
    end
    if IsNull(darknessStream) == true then
      break
    end
    toFade = toFade + Noise(Time() * 1) * 0.1
    darknessStream:SetMaterialParam("angerLevel", toFade)
    t = t + DeltaTime()
    Sleep(0)
  end
end

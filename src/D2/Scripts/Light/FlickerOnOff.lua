delay = 0
flickerLight = Instance()
lightDeco = Instance()
transitionTime = 1
flickerBrightness = 0.2
flickerBrightnessMultiplier = 20
maxBrightness = 1
flickerEmissiveness = 0.2
maxEmissiveness = 1
local localFlickerLight = function(light, deco, loop)
  while true do
    local t = 0
    while t < 1 do
      local b = Abs(Noise(t))
      local v = flickerBrightness + math.pow(0.1, b)
      light:SetBrightness(v * flickerBrightnessMultiplier)
      if IsNull(deco) == false then
        deco:SetMaterialParam("EmissiveMapAtten", v)
      end
      t = t + DeltaTime() / transitionTime
      Sleep(0)
    end
    if loop == false then
      break
    end
  end
end
function FlickerOn()
  Sleep(delay)
  localFlickerLight(flickerLight, lightDeco, false)
  flickerLight:SetBrightness(maxBrightness)
  flickerLight:TurnOn()
  if IsNull(lightDeco) == false then
    lightDeco:SetMaterialParam("EmissiveMapAtten", maxEmissiveness)
  end
end
function FlickerOff()
  Sleep(delay)
  localFlickerLight(flickerLight, lightDeco, false)
  flickerLight:SetBrightness(0)
  flickerLight:TurnOff()
  if IsNull(lightDeco) == false then
    lightDeco:SetMaterialParam("EmissiveMapAtten", 0)
  end
end
function FlickerLoop()
  Sleep(delay)
  localFlickerLight(flickerLight, lightDeco, true)
end

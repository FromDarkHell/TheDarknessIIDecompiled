syphon = Instance()
initialValue = 1
finalValue = 0.2
drainTime = 1.2
Param = String()
ParamUVScale = String()
finalUVScale = 0.1
ParamAtten = String()
initialAtten = 2
finalAtten = 10
function DrainVials()
  local t = 0
  local val
  if not IsNull(syphon) then
    while t < drainTime do
      val = Lerp(initialValue, finalValue, t / drainTime)
      syphon:SetMaterialParam(Param, val)
      val = Lerp(1, finalUVScale, t / drainTime)
      syphon:SetMaterialParam(ParamUVScale, 1, val)
      val = Lerp(initialAtten, finalAtten, t / drainTime)
      syphon:SetMaterialParam(ParamAtten, val)
      t = t + DeltaTime()
      Sleep(0)
    end
  end
end

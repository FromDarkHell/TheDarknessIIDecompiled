OriginalValue = 1
NewValue = 2
TimeLength = 1
Peak = 0.5
PeakEnd = 0.8
PeakValue = 1
ValleyValue = 0
ValleyEndValue = 0
Param = String()
TargetDeco = Instance()
Delay = 0
function MaterialFade(deco)
  Sleep(Delay)
  local t = 0
  local val
  while t < TimeLength do
    val = Lerp(OriginalValue, NewValue, t / TimeLength)
    deco:SetMaterialParam(Param, val)
    t = t + DeltaTime()
    Sleep(0)
  end
end
function MaterialFadePeak(deco)
  Sleep(Delay)
  local t = 0
  local fading, val
  while t < TimeLength do
    if t < Peak then
      fading = t / Peak
    else
      fading = 1 - (t - Peak) / (TimeLength - Peak)
    end
    if fading < 0 then
      fading = 0
    end
    val = Lerp(ValleyValue, PeakValue, fading)
    deco:SetMaterialParam(Param, val)
    t = t + DeltaTime()
    Sleep(0)
  end
end
function MaterialFadeTargetted()
  Sleep(Delay)
  local t = 0
  local val
  while t < TimeLength do
    val = Lerp(OriginalValue, NewValue, t / TimeLength)
    if not IsNull(TargetDeco) then
      TargetDeco:SetMaterialParam(Param, val)
    end
    t = t + DeltaTime()
    Sleep(0)
  end
end
function DissolveFade(deco)
  Sleep(Delay)
  local t = 0
  local val
  while t < TimeLength do
    val = Lerp(OriginalValue, NewValue, t / TimeLength)
    deco:SetDissolve(val)
    t = t + DeltaTime()
    Sleep(0)
  end
  deco:SetDissolve(NewValue)
end
function MaterialFadeFlatPeak(deco)
  Sleep(Delay)
  local t = 0
  local fading, val
  local v = ValleyValue
  while t < TimeLength do
    if t < Peak then
      fading = t / Peak
    elseif t < PeakEnd then
      fading = 1
    else
      v = ValleyEndValue
      fading = 1 - (t - PeakEnd) / (TimeLength - PeakEnd)
    end
    if fading < 0 then
      fading = 0
    end
    val = Lerp(v, PeakValue, fading)
    deco:SetMaterialParam(Param, val)
    t = t + DeltaTime()
    Sleep(0)
  end
end

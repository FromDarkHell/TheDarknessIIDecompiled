crossFadeRate = 0.2
crossDeco = Instance()
function CrossFade(deco)
  local t = 0
  while t < 1 do
    deco:SetMaterialParam("CrossFade", t)
    t = t + DeltaTime() * crossFadeRate
    Sleep(0)
  end
end
function CrossFadeDeco()
  local t = 0
  while t < 1 do
    crossDeco:SetMaterialParam("CrossFade", t)
    t = t + DeltaTime() * crossFadeRate
    Sleep(0)
  end
end

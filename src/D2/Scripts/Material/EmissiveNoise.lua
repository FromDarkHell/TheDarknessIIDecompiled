deco = Instance()
scalarExponent = 1
function Start()
  while true do
    local t = Time() * 1.2
    local b = Noise(t)
    b = Abs(b)
    deco:SetMaterialParam("EmissiveMapAtten", 0.2 + math.pow(b, scalarExponent))
    Sleep(0)
  end
end

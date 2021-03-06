deco = Instance()
local lastMorph
local morphs = {
  Symbol("Morphs.Alert"),
  Symbol("Morphs.Rage"),
  Symbol("Morphs.Fear"),
  Symbol("Morphs.Dead"),
  Symbol("Morphs.Smug"),
  Symbol("Morphs.Pain")
}
local BlendMorph = function(morph, from, to)
  local t = 0
  while t < 1 do
    local v = Lerp(from, to, t)
    deco:SetMorphValue(morph, v)
    t = t + DeltaTime()
    Sleep(0)
  end
  deco:SetMorphValue(morph, to)
end
function TestFaceMorphs()
  while true do
    local i = RandomInt(1, #morphs)
    local morph = morphs[i]
    local t = Random(0.5, 1.3)
    BlendMorph(morph, 0, t)
    local waitTime = 4
    local lastT = t
    while 0 < waitTime do
      local noise = Noise(Time() * 0.3) * 0.3
      lastT = t + noise
      deco:SetMorphValue(morph, lastT)
      waitTime = waitTime - DeltaTime()
      Sleep(0)
    end
    BlendMorph(morph, lastT, 0)
  end
end

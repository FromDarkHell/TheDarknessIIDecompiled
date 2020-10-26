Walkers = Symbol()
entityA = Instance()
entityB = Instance()
delay = 15
function WalkBackAndForth()
  local tableStreetWalkers = gRegion:FindTagged(Walkers)
  while true do
    for t = 1, #tableStreetWalkers do
      local deco = tableStreetWalkers[t]
      if Mod(t, 2) == 0 then
        deco:FaceTo(entityB:GetPosition())
      else
        deco:FaceTo(entityA:GetPosition())
      end
    end
    Sleep(delay)
    for t = 1, #tableStreetWalkers do
      local deco = tableStreetWalkers[t]
      if Mod(t, 2) == 0 then
        deco:FaceTo(entityB:GetPosition())
      else
        deco:FaceTo(entityA:GetPosition())
      end
    end
    Sleep(delay)
  end
end

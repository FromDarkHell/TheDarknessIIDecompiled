fountainEffectA = Type()
fountainEffectB = Type()
sleepAmt = 20
fountain = Instance()
function FountainWaterJet(fountain)
  while true do
    fountain:Attach(fountainEffectA, Symbol(), Vector(), Rotation())
    fountain:Attach(fountainEffectB, Symbol(), Vector(), Rotation(180, 0, 0))
    Sleep(sleepAmt)
  end
end

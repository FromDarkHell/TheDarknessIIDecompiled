vinnieCin = Instance()
dualiesModifier = Instance()
removeModifier = Instance()
finalSpawnControl = Instance()
function PlayVinnieCin()
  vinnieCin:FirePort("StartPlaying")
end
function GiveDualies()
  dualiesModifier:FirePort("Activate")
end
function RemoveGuns()
  removeModifier:FirePort("Activate")
end
function SpawnFinalFight()
  finalSpawnControl:FirePort("Start")
end

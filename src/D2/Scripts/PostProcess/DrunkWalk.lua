shakeFactorRotation = Rotation(5, 2.5, 2.5)
shakeAmbient = 1
shakeSpeed = 0.075
function Start()
  local levelInfo = gRegion:GetLevelInfo()
  local postProcess = levelInfo.postProcess
  postProcess.viewShake.mShakeFactorRot.heading = 5
  postProcess.viewShake.mShakeFactorRot.pitch = 2.5
  postProcess.viewShake.mShakeFactorRot.bank = 2.5
  postProcess.viewShake.mShakeAmbient = 1
  postProcess.viewShake.mshakeSpeed = 0.075
end

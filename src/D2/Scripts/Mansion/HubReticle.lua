hudSwf = WeakResource()
reticleShow = 1
function HubReticle()
  local movieInstance
  while IsNull(movieInstance) do
    Sleep(0)
    movieInstance = gFlashMgr:FindMovie(hudSwf)
  end
  movieInstance:Execute("ReticuleHubShow", tonumber(reticleShow))
end

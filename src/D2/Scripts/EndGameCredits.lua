initialDelay = 0
creditsMovie = Resource()
creditsMusic = Resource()
creditsSequencer = Instance()
shouldUnlockNewGamePlus = true
achievementTag = Symbol()
popupConfirmMovie = WeakResource()
fakeCredits = false
function Start()
  Sleep(initialDelay)
  local movie = gFlashMgr:PushMovie(creditsMovie)
  local creditsMusicInstance
  if not IsNull(creditsSequencer) then
    creditsSequencer:FirePort("Enable")
  else
  end
  if shouldUnlockNewGamePlus then
    local humans = gRegion:GetHumanPlayers()
    for i = 1, #humans do
      gChallengeMgr:NotifyTag(humans[i], achievementTag)
    end
    Sleep(0.3)
  end
  while not IsNull(movie) do
    Sleep(0.3)
  end
  if fakeCredits == false then
    local avatar = gRegion:GetPlayerAvatar(0)
    if not IsNull(avatar) then
      gRegion:GetGameRules():SaveEndGameProgress()
    end
    local pop = gFlashMgr:FindMovie(popupConfirmMovie)
    while IsNull(pop) == false do
      pop = gFlashMgr:FindMovie(popupConfirmMovie)
      Sleep(0)
    end
    if IsNull(creditsMusicInstance) == false then
      creditsMusicInstance:Stop(true)
    end
  else
    Engine.Disconnect(true)
  end
end

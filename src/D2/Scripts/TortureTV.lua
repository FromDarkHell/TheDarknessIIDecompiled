tv = Instance()
tvScreenSlot = 3
leftMaterial = Resource()
leftBinkTexture = Resource()
rightMaterial = Resource()
rightBinkTexture = Resource()
tvDeathCinematic = Instance()
victorNoneSound = Resource()
killBinkScript = Instance()
refuseToCooperateTag = Symbol()
killFrankSubtitleScript = Instance()
killEddieSubtitleScript = Instance()
function Start()
  Sleep(0)
  local playerAvatar = gRegion:GetPlayerAvatar()
  while _T.decision == "" do
    Sleep(0)
  end
  local playingCinematic = gRegion:GetPlayingCinematic()
  killBinkScript:FirePort("Execute")
  if IsNull(playingCinematic) == false then
    playingCinematic:FirePort("StopPlaying")
  end
  if IsNull(tvDeathCinematic) == false then
    tvDeathCinematic:FirePort("StartPlaying")
  end
  if _T.decision == "LEFT" then
    playerAvatar:SetQuestTokenState(Symbol("BrothelKilledFrank"), Engine.QTS_COMPLETE)
    tv:SetOverrideMaterial(tvScreenSlot, leftMaterial)
    gRegion:StartVideoTexture(leftBinkTexture)
    killFrankSubtitleScript:FirePort("Execute")
  elseif _T.decision == "RIGHT" then
    playerAvatar:SetQuestTokenState(Symbol("BrothelKilledEddie"), Engine.QTS_COMPLETE)
    tv:SetOverrideMaterial(tvScreenSlot, rightMaterial)
    gRegion:StartVideoTexture(rightBinkTexture)
    killEddieSubtitleScript:FirePort("Execute")
  elseif _T.decision == "NONE" then
    playerAvatar:SetQuestTokenState(Symbol("BrothelKilledEddie"), Engine.QTS_COMPLETE)
    tv:SetOverrideMaterial(tvScreenSlot, rightMaterial)
    killEddieSubtitleScript:FirePort("Execute")
    gRegion:StartVideoTexture(rightBinkTexture)
    local humans = gRegion:GetHumanPlayers()
    for i = 1, #humans do
      gChallengeMgr:NotifyTag(humans[i], refuseToCooperateTag)
    end
  end
end

creditsMovie = Resource()
creditsMusic = Resource()
challengePopupMovie = Resource()
function VendettasDone()
  Sleep(3)
  gFlashMgr:PushMovie(creditsMovie)
  gRegion:PlaySound(creditsMusic, Vector(), false)
end
function ChallengeModeUnlocked()
end

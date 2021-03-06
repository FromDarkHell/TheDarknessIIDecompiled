local mTCRSpinnerDuration = 3
local mCurrentTime = 0
local mFinishRequested = false
local mIsClosing = false
function SetMessage(movie, msg)
  movie:SetLocalized("Message.text", msg)
  return true
end
function Initialize(movie)
  mCurrentTime = 0
  mFinishRequested = false
  mIsClosing = false
  FlashMethod(movie, "Spinner.gotoAndPlay", "Play")
end
function Finished(movie)
  mFinishRequested = true
  if mCurrentTime <= 1 then
    mTCRSpinnerDuration = 1
  elseif mCurrentTime <= 3 then
    mTCRSpinnerDuration = 3
  else
    mTCRSpinnerDuration = 0
  end
  return true
end
function FinishedAnimation(movie)
  movie:Close()
end
function Update(movie)
  mCurrentTime = mCurrentTime + RealDeltaTime()
  if mFinishRequested and not mIsClosing and mCurrentTime >= mTCRSpinnerDuration then
    mIsClosing = true
    movie:Close()
  end
end

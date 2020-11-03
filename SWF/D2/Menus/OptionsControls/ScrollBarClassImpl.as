class ScrollBarClassImpl
{
   var mThisMC = null;
   var mID = "";
   var mIsEnabled = true;
   var mIncrementValue = 1;
   var mRange = 0;
   var mPosition = 0;
   var mRightButtonOffsetFromFillerX = 0;
   var mRightButtonOffsetFromFillerY = 0;
   function ScrollBarClassImpl(mc)
   {
      this.mThisMC = mc;
      this.mID = this.mThisMC._name;
      this.mThisMC.ScrollClass = this;
      this.mRightButtonOffsetFromFillerY = this.mThisMC.Button1._y - (this.mThisMC.Filler._y + this.mThisMC.Filler._height);
      this.SetupButton0(this.mThisMC.Button0);
      this.SetupButton1(this.mThisMC.Button1);
      this.SetupScrubber(this.mThisMC.Scrubber);
      this.SetupFiller(this.mThisMC.Filler);
      this.SetRange(0);
      this.ClampScrubberPos();
   }
   function ClampScrubberPos(forceUpdate)
   {
      var _loc2_ = this.mThisMC.Scrubber._y;
      var _loc4_ = 18;
      var _loc3_ = this.mThisMC.Filler._y;
      var _loc7_ = this.mThisMC.Filler._height - _loc4_;
      var _loc6_ = this.mPosition;
      if(this.mPosition == undefined)
      {
         this.mPosition = 0;
      }
      if(this.mPosition > this.mRange)
      {
         this.mPosition = this.mRange;
      }
      _loc2_ = this.mPosition / this.mRange * _loc7_ + _loc3_;
      if(_loc2_ - _loc3_ < 0)
      {
         this.mThisMC.Scrubber._y = _loc3_;
      }
      else
      {
         this.mThisMC.Scrubber._y = _loc2_;
      }
      var _loc5_ = forceUpdate != undefined and forceUpdate;
      if(this.mScrubberMoveCallback != "" && (this.mPosition != _loc6_ || _loc5_))
      {
         getURL("FSCommand:" add this.mScrubberMoveCallback,this.mID);
      }
   }
   function AdjustScrubberPosByValue(byValue)
   {
      this.mPosition = this.mPosition + byValue;
      this.ClampScrubberPos();
   }
   function SetScrubberPos(byValue)
   {
      this.mPosition = byValue;
      this.ClampScrubberPos(true);
   }
   function SetRange(r)
   {
      this.mRange = r;
      if(this.mRange <= 0)
      {
         this.mRange = this.mThisMC.Filler._height;
      }
      this.ClampScrubberPos();
   }
   function ScrollUp()
   {
      this.AdjustScrubberPosByValue(- this.mIncrementValue);
   }
   function ScrollDown()
   {
      this.AdjustScrubberPosByValue(this.mIncrementValue);
   }
   function SetupButton0(mc)
   {
      mc.noMenuSelection = true;
      mc.onPress = function()
      {
         this._parent.ScrollClass.ScrollUp();
         if(this._parent.ScrollClass.mButton0PressedCallback != "")
         {
            getURL("FSCommand:" add this._parent.ScrollClass.mButton0PressedCallback,this._parent.ScrollClass.mID);
         }
         gotoAndStop("Pressed");
         play();
      };
      mc.onRollOver = function()
      {
         if(this._parent.ScrollClass.mButton0SelectedCallback != "")
         {
            getURL("FSCommand:" add this._parent.ScrollClass.mButton0SelectedCallback,this._parent.ScrollClass.mID);
         }
         gotoAndStop("Selected");
         play();
      };
      mc.onRollOut = function()
      {
         if(this._parent.ScrollClass.mButton0UnselectedCallback != "")
         {
            getURL("FSCommand:" add this._parent.ScrollClass.mButton0UnselectedCallback,this._parent.ScrollClass.mID);
         }
         gotoAndStop("Unselected");
         play();
      };
   }
   function SetupButton1(mc)
   {
      mc.noMenuSelection = true;
      mc.onPress = function()
      {
         this._parent.ScrollClass.ScrollDown();
         if(this._parent.ScrollClass.mButton1PressedCallback != "")
         {
            getURL("FSCommand:" add this._parent.ScrollClass.mButton1PressedCallback,this._parent.ScrollClass.mID);
         }
         gotoAndStop("Pressed");
         play();
      };
      mc.onRollOver = function()
      {
         if(this._parent.ScrollClass.mButton1SelectedCallback != "")
         {
            getURL("FSCommand:" add this._parent.ScrollClass.mButton1SelectedCallback,this._parent.ScrollClass.mID);
         }
         gotoAndStop("Selected");
         play();
      };
      mc.onRollOut = function()
      {
         if(this._parent.ScrollClass.mButton1UnselectedCallback != "")
         {
            getURL("FSCommand:" add this._parent.ScrollClass.mButton1UnselectedCallback,this._parent.ScrollClass.mID);
         }
         gotoAndStop("Unselected");
         play();
      };
   }
   function SetupScrubber(mc)
   {
      mc.noMenuSelection = true;
      mc.onRollOver = function()
      {
         if(this._parent.ScrollClass.mScrubberSelectedCallback != "")
         {
            getURL("FSCommand:" add this._parent.ScrollClass.mScrubberSelectedCallback,this._parent.ScrollClass.mID);
         }
         gotoAndStop("Selected");
         play();
      };
      mc.onRollOut = function()
      {
         if(this._parent.ScrollClass.mScrubberUnselectedCallback != "")
         {
            getURL("FSCommand:" add this._parent.ScrollClass.mScrubberUnselectedCallback,this._parent.ScrollClass.mID);
         }
         gotoAndStop("Unselected");
         play();
      };
      mc.onPress = function()
      {
         if(this._parent.ScrollClass.mScrubberPressedCallback != "")
         {
            getURL("FSCommand:" add this._parent.ScrollClass.mScrubberPressedCallback,this._parent.ScrollClass.mID);
         }
         gotoAndStop("Pressed");
         play();
         this._parent.Scrubber.onMouseMove = function()
         {
            var _loc5_ = this._parent.ScrollClass.mRange;
            var _loc4_ = this._parent.Filler._height;
            var _loc3_ = this._parent._ymouse - this._parent.Filler._y;
            if(_loc3_ < 0)
            {
               _loc3_ = 0;
            }
            else if(_loc3_ > _loc4_)
            {
               _loc3_ = _loc4_;
            }
            var _loc2_ = _loc3_ / _loc4_ * _loc5_;
            if(_loc2_ < 0)
            {
               _loc2_ = 0;
            }
            else if(_loc2_ >= _loc5_)
            {
               _loc2_ = _loc5_;
            }
            this._parent.ScrollClass.mPosition = _loc2_;
            this._parent.ScrollClass.ClampScrubberPos(true);
         };
      };
      mc.onRelease = function()
      {
         this._parent.Scrubber.onMouseMove = null;
         if(this._parent.ScrollClass.mScrubberReleasedCallback != "")
         {
            getURL("FSCommand:" add this._parent.ScrollClass.mScrubberReleasedCallback,this._parent.ScrollClass.mID);
         }
         gotoAndStop("Selected");
         play();
      };
      mc.onReleaseOutside = function()
      {
         this._parent.Scrubber.onMouseMove = null;
         if(this._parent.ScrollClass.mScrubberReleasedCallback != "")
         {
            getURL("FSCommand:" add this._parent.ScrollClass.mScrubberReleasedCallback,this._parent.ScrollClass.mID);
         }
         gotoAndStop("Unselected");
         play();
      };
   }
   function SetupFiller(mc)
   {
      mc.noMenuSelection = true;
      mc.onRollOver = function()
      {
         if(this._parent.ScrollClass.mFillerSelectedCallback != "")
         {
            getURL("FSCommand:" add this._parent.ScrollClass.mFillerSelectedCallback,this._parent.ScrollClass.mID);
         }
      };
      mc.onRollOut = function()
      {
         if(this._parent.ScrollClass.mFillerUnselectedCallback != "")
         {
            getURL("FSCommand:" add this._parent.ScrollClass.mFillerUnselectedCallback,this._parent.ScrollClass.mID);
         }
      };
      mc.onPress = function()
      {
         var _loc2_ = this._parent.Scrubber._y - this._parent.Filler._y;
         if(_ymouse < _loc2_)
         {
            this._parent.ScrollClass.ScrollUp();
         }
         else if(_ymouse > _loc2_)
         {
            this._parent.ScrollClass.ScrollDown();
         }
         if(this._parent.ScrollClass.mFillerPressedCallback != "")
         {
            getURL("FSCommand:" add this._parent.ScrollClass.mFillerPressedCallback,this._parent.ScrollClass.mID);
         }
      };
   }
   function SetSize(n)
   {
      this.mThisMC.Filler._height = n;
      this.mThisMC.Button1._y = this.mThisMC.Filler._y + this.mThisMC.Filler._height + this.mRightButtonOffsetFromFillerY;
      this.ClampScrubberPos();
   }
   function SetIncrement(n)
   {
      this.mIncrementValue = n;
   }
   function SetButton0SelectedCallback(c)
   {
      this.mButton0SelectedCallback = c;
   }
   function SetButton0UnselectedCallback(c)
   {
      this.mButton0UnselectedCallback = c;
   }
   function SetButton0PressedCallback(c)
   {
      this.mButton0PressedCallback = c;
   }
   function SetButton1SelectedCallback(c)
   {
      this.mButton1SelectedCallback = c;
   }
   function SetButton1UnselectedCallback(c)
   {
      this.mButton1UnselectedCallback = c;
   }
   function SetButton1PressedCallback(c)
   {
      this.mButton1PressedCallback = c;
   }
   function SetScrubberSelectedCallback(c)
   {
      this.mScrubberSelectedCallback = c;
   }
   function SetScrubberUnselectedCallback(c)
   {
      this.mScrubberUnselectedCallback = c;
   }
   function SetScrubberPressedCallback(c)
   {
      this.mScrubberPressedCallback = c;
   }
   function SetScrubberReleasedCallback(c)
   {
      this.mScrubberReleasedCallback = c;
   }
   function SetScrubberMoveCallback(c)
   {
      this.mScrubberMoveCallback = c;
   }
   function SetFillerSelectedCallback(c)
   {
      this.mFillerSelectedCallback = c;
   }
   function SetFillerUnselectedCallback(c)
   {
      this.mFillerUnselectedCallback = c;
   }
   function SetFillerPressedCallback(c)
   {
      this.mFillerPressedCallback = c;
   }
   function SetEnabled(isEnabled)
   {
      this.mIsEnabled = isEnabled;
      this.mThisMC.enabled = isEnabled;
   }
   function SetID(newID)
   {
      this.mID = newID;
   }
}

class ListClassImpl
{
   var FRAME_Pressed = "Pressed";
   var FRAME_NoFocus = "NoFocus";
   var FRAME_MousedOver = "MousedOver";
   var MOVIENAME_UpButton = "UpButton";
   var MOVIENAME_DownButton = "DownButton";
   var mAlignment = "";
   var numElements = 0;
   var numLabels = 0;
   var mShowArrows = true;
   var mScrollPos = 0;
   var mPressedCallback = "";
   var mSelectedCallback = "";
   var mUnselectedCallback = "";
   var listItemsAreSelectable = false;
   var mCurrentSelection = -1;
   var mKeyUpPressed = false;
   var mKeyDownPressed = false;
   function ListClassImpl(mc)
   {
      this.thisMC = mc;
      this.mElements = new Array();
      this.mElementsHint = new Array();
      this.mLabels = new Array();
      this.mArrows = new Array();
      this.mScrollChildren = new Array();
      this.ClearArrowButtonEvents(this.MOVIENAME_UpButton);
      this.ClearArrowButtonEvents(this.MOVIENAME_DownButton);
      var _loc2_ = 0;
      while(this.thisMC["ButtonLabel" + _loc2_])
      {
         this.numLabels = this.numLabels + 1;
         this.mLabels[_loc2_] = this.thisMC["ButtonLabel" + _loc2_];
         this.mLabels[_loc2_].btnValue = _loc2_;
         this.mLabels[_loc2_].listClass = this;
         this.mLabels[_loc2_].onPress = function()
         {
            this.listClass.Pressed(this.btnValue);
            this.gotoAndPlay(this.FRAME_NoFocus);
         };
         this.mLabels[_loc2_].onRollOver = function()
         {
            this.listClass.RollOver(this.btnValue);
         };
         this.mLabels[_loc2_].onRollOut = function()
         {
            this.listClass.RollOut(this.btnValue);
         };
         this.mLabels[_loc2_].onSetFocus = function()
         {
            this.listClass.RollOver(this.btnValue);
         };
         this.mLabels[_loc2_].onKeyDown = function()
         {
            this.listClass.KeyDown(this.btnValue);
            Key.removeListener(this);
         };
         this.mLabels[_loc2_].onKeyUp = function()
         {
            this.listClass.KeyUp(this.btnValue);
         };
         _loc2_ = _loc2_ + 1;
      }
      this.SetTitle("");
      this.mArrows[0] = this.thisMC[this.MOVIENAME_UpButton];
      this.mArrows[1] = this.thisMC[this.MOVIENAME_DownButton];
      this.UpdateList();
   }
   function GetNumLabels()
   {
      return this.numLabels;
   }
   function GetScrollPos()
   {
      return this.mScrollPos;
   }
   function RollOut(buttonIdx)
   {
      this.Unselected(buttonIdx);
      this.mLabels[buttonIdx].gotoAndStop(this.FRAME_NoFocus);
      Key.removeListener(this.mLabels[buttonIdx]);
   }
   function RollOver(buttonIdx)
   {
      var _loc2_ = 0;
      while(_loc2_ < this.numLabels)
      {
         this.mLabels[_loc2_].gotoAndStop(this.FRAME_NoFocus);
         _loc2_ = _loc2_ + 1;
      }
      this.Selected(buttonIdx);
      this.mLabels[buttonIdx].gotoAndPlay(this.FRAME_MousedOver);
      Key.addListener(this.mLabels[buttonIdx]);
   }
   function SetupArrowButtonEvents(s)
   {
      var _loc2_ = this.thisMC[s];
      _loc2_.listClass = this;
      if(s == this.MOVIENAME_UpButton)
      {
         _loc2_.onPress = function()
         {
            this.listClass.ScrollUp();
            this.gotoAndPlay(this.FRAME_Pressed);
         };
      }
      else
      {
         _loc2_.onPress = function()
         {
            this.listClass.ScrollDown();
            this.gotoAndPlay(this.FRAME_Pressed);
         };
      }
      _loc2_.onRollOver = function()
      {
         this.gotoAndPlay("MousedOver");
      };
      _loc2_.onSetFocus = function()
      {
         this.gotoAndStop("MousedOver");
      };
      _loc2_.onRollOut = function()
      {
         this.gotoAndStop("NoFocus");
      };
   }
   function ClearArrowButtonEvents(s)
   {
      var _loc2_ = this.thisMC[s];
      _loc2_.listClass = this;
      _loc2_.onPress = null;
      _loc2_.onRollOver = null;
      _loc2_.onRollOut = null;
      _loc2_.onSetFocus = null;
   }
   function SetSelected(buttonIdx)
   {
      var _loc2_ = "_root." + this.thisMC._name + ".ButtonLabel" + buttonIdx;
      Selection.setFocus(_loc2_);
   }
   function KeyDown(buttonIdx)
   {
   }
   function KeyUp(buttonIdx)
   {
   }
   function Selected(buttonIdx)
   {
      if(this.mSelectedCallback != "")
      {
         getURL("FSCommand:" add this.mSelectedCallback,buttonIdx + this.mScrollPos);
      }
      this.mCurrentSelection = buttonIdx;
   }
   function Unselected(buttonIdx)
   {
      if(this.mUnselectedCallback != "")
      {
         getURL("FSCommand:" add this.mUnselectedCallback,buttonIdx + this.mScrollPos);
      }
      this.mCurrentSelection = -1;
   }
   function SetCaption(c)
   {
      this.thisMC.CaptionText.text = c;
   }
   function SetPressedCallback(c)
   {
      this.mPressedCallback = c;
   }
   function SetSelectedCallback(c)
   {
      this.mSelectedCallback = c;
   }
   function SetUnselectedCallback(c)
   {
      this.mUnselectedCallback = c;
   }
   function EnableArrows(b)
   {
      this.mShowArrows = b;
   }
   function AddItem(c, b)
   {
      this.mElements.push(c);
      this.mElementsHint.push(b);
      this.numElements = this.numElements + 1;
      this.UpdateList();
   }
   function SetItem(i, c, b)
   {
      this.mElements[i] = c;
      this.mElementsHint[i] = b;
      this.UpdateList();
   }
   function EraseItems()
   {
      this.mElements = new Array();
      this.mElementsHint = new Array();
      this.numElements = 0;
      this.UpdateList();
   }
   function GetNumElements()
   {
      return this.numElements;
   }
   function Clear()
   {
      this.mElements.length = 0;
      this.UpdateList();
   }
   function ScrollUp()
   {
      if(this.mScrollPos <= 0)
      {
         return undefined;
      }
      this.ScrollChildren(false);
      this.mScrollPos = this.mScrollPos - 1;
      this.UpdateList();
   }
   function ScrollDown()
   {
      var _loc2_ = this.numElements - this.numLabels;
      if(_loc2_ < 0)
      {
         _loc2_ = 0;
      }
      if(this.mScrollPos >= _loc2_)
      {
         return undefined;
      }
      this.ScrollChildren(true);
      this.mScrollPos = this.mScrollPos + 1;
      this.UpdateList();
   }
   function ScrollChildren(down)
   {
      var _loc2_ = 0;
      while(_loc2_ < this.mScrollChildren.length)
      {
         if(down)
         {
            this.mScrollChildren[_loc2_].ScrollDown();
         }
         else
         {
            this.mScrollChildren[_loc2_].ScrollUp();
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   function Pressed(i)
   {
      if(this.mPressedCallback != "")
      {
         getURL("FSCommand:" add this.mPressedCallback,i + this.mScrollPos);
      }
   }
   function SetAlignment(a)
   {
      if(a == "")
      {
         return undefined;
      }
      this.mAlignment = a;
      var _loc4_ = new TextFormat();
      _loc4_.align = this.mAlignment;
      if(this.thisMC.TitleLabel.TxtHolder.Txt)
      {
         this.thisMC.TitleLabel.TxtHolder.Txt.setTextFormat(_loc4_);
      }
      var _loc2_ = 0;
      while(_loc2_ < this.mLabels.length)
      {
         var _loc3_ = this.mLabels[_loc2_];
         if(_loc3_.TxtHolder.Txt)
         {
            _loc3_.TxtHolder.Txt.setTextFormat(_loc4_);
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   function SetTitle(s)
   {
      if(this.thisMC.TitleLabel.Txt)
      {
         this.thisMC.TitleLabel.Txt.text = s;
      }
      else
      {
         this.thisMC.TitleLabel.TxtHolder.Txt.text = s;
      }
   }
   function ShowTitle(b)
   {
      this.thisMC.TitleLabel._visible = b;
   }
   function fillText(thisClip, entryContent)
   {
      if(thisClip.Txt)
      {
         thisClip.Txt.text = entryContent;
      }
      else
      {
         thisClip.TxtHolder.Txt.text = entryContent;
      }
   }
   function EnableScrolling(b)
   {
      this.thisMC[this.MOVIENAME_UpButton]._visible = b;
      this.thisMC[this.MOVIENAME_DownButton]._visible = b;
      if(b)
      {
         this.SetupArrowButtonEvents(this.MOVIENAME_UpButton);
         this.SetupArrowButtonEvents(this.MOVIENAME_DownButton);
      }
      else
      {
         this.ClearArrowButtonEvents(this.MOVIENAME_UpButton);
         this.ClearArrowButtonEvents(this.MOVIENAME_DownButton);
      }
   }
   function AddScrollingChild(m)
   {
      this.mScrollChildren.push(m);
   }
   function SetListItemsSeletable(b)
   {
      this.listItemsAreSelectable = b;
   }
   function UpdateList()
   {
      var _loc3_ = this.mScrollPos;
      if(this.mElements.length > this.GetNumLabels())
      {
         this.EnableScrolling(true);
      }
      else
      {
         this.EnableScrolling(false);
      }
      var _loc2_ = 0;
      while(_loc2_ < this.mLabels.length)
      {
         if(_loc2_ + this.mScrollPos < this.mElements.length)
         {
            this.mLabels[_loc2_]._visible = true;
            this.fillText(this.mLabels[_loc2_],this.mElements[_loc2_ + this.mScrollPos]);
            this.mLabels[_loc2_].variable = this.mElements[_loc2_ + this.mScrollPos];
            if(this.mElementsHint[_loc2_ + this.mScrollPos])
            {
               this.mLabels[_loc2_].textColor = 16777215;
            }
            else
            {
               this.mLabels[_loc2_].textColor = 9408399;
            }
         }
         else
         {
            this.mLabels[_loc2_]._visible = false;
         }
         _loc2_ = _loc2_ + 1;
      }
      this.SetAlignment(this.mAlignment);
   }
}

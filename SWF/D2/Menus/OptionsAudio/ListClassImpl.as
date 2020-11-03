class ListClassImpl
{
   var FRAME_Pressed = "Pressed";
   var FRAME_NoFocus = "NoFocus";
   var FRAME_MousedOver = "MousedOver";
   var MOVIENAME_UpButton = "UpButton";
   var MOVIENAME_DownButton = "DownButton";
   var mAlignment = "";
   var mLetterSpacing = 0;
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
   var mIsEnabled = true;
   var mIsVisible = true;
   var mIsWrapEnabled = true;
   function ListClassImpl(mc)
   {
      this.thisMC = mc;
      this.mElements = new Array();
      this.mElementsHint = new Array();
      this.mLabels = new Array();
      this.mArrows = new Array();
      this.mScrollChildren = new Array();
      this.mTextFormat = new TextFormat();
      this.ClearArrowButtonEvents(this.MOVIENAME_UpButton);
      this.ClearArrowButtonEvents(this.MOVIENAME_DownButton);
      var _loc3_ = 0;
      while(this.thisMC["ButtonLabel" + _loc3_])
      {
         this.numLabels = this.numLabels + 1;
         this.mLabels[_loc3_] = this.thisMC["ButtonLabel" + _loc3_];
         this.mLabels[_loc3_].btnValue = _loc3_;
         this.mLabels[_loc3_].listClass = this;
         this.mLabels[_loc3_].Btn.noMenuSelection = true;
         this.mLabels[_loc3_].Btn.onPress = function()
         {
            _parent.listClass.Pressed(_parent.btnValue);
            this.gotoAndPlay(this.FRAME_NoFocus);
         };
         this.mLabels[_loc3_].Btn.onRollOver = function()
         {
            _parent.listClass.RollOver(_parent.btnValue);
         };
         this.mLabels[_loc3_].Btn.onRollOut = this.mLabels[_loc3_].Btn.onReleaseOutside = function()
         {
            _parent.listClass.RollOut(_parent.btnValue);
         };
         this.mLabels[_loc3_].Btn.onSetFocus = function()
         {
            var _loc2_ = Selection.getFocusedObject();
            if(_parent == _loc2_._parent)
            {
               _parent.listClass.RollOver(_parent.btnValue);
            }
         };
         this.mLabels[_loc3_].Btn.onKeyDown = function()
         {
            _parent.listClass.KeyDown(_parent.btnValue);
            Key.removeListener(this);
         };
         this.mLabels[_loc3_].Btn.onKeyUp = function()
         {
            _parent.listClass.KeyUp(_parent.btnValue);
         };
         this.mLabels[_loc3_].HiddenBtn.onPress = function()
         {
         };
         _loc3_ = _loc3_ + 1;
      }
      this.SetTitle("");
      this.mArrows[0] = this.thisMC[this.MOVIENAME_UpButton];
      this.mArrows[1] = this.thisMC[this.MOVIENAME_DownButton];
      this.UpdateList();
   }
   function SetEnabled(isEnabled)
   {
      this.mIsEnabled = isEnabled;
      this.thisMC.enabled = isEnabled;
   }
   function SetVisible(isVisible)
   {
      this.mIsVisible = isVisible;
      this.thisMC._visible = isVisible;
   }
   function SetWrapEnabled(isWrapEnabled)
   {
      this.mIsWrapEnabled = isWrapEnabled;
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
      _loc2_.noMenuSelection = true;
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
   function RemoveSelection()
   {
      var _loc2_ = 0;
      while(_loc2_ < this.mLabels.length)
      {
         this.mLabels[_loc2_].onRollOut();
         _loc2_ = _loc2_ + 1;
      }
      Selection.setFocus("");
   }
   function SetSelected(buttonIdx)
   {
      if(buttonIdx >= this.numElements)
      {
         return undefined;
      }
      var _loc5_ = this.thisMC["ButtonLabel" + buttonIdx];
      var _loc4_ = _loc5_._name;
      var _loc3_ = _loc5_._parent;
      while(_loc3_ != _root && _loc3_ != null)
      {
         _loc4_ = _loc3_._name + "." + _loc4_;
         _loc3_ = _loc3_._parent;
      }
      _loc4_ = "_root." + _loc4_ + ".HiddenBtn";
      Selection.setFocus(_loc4_);
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
      this.AddItemBack(c,b);
   }
   function AddItemBack(c, b)
   {
      this.mElements.push(c);
      this.mElementsHint.push(b);
      this.numElements = this.numElements + 1;
      this.UpdateList();
   }
   function AddItemFront(c, b)
   {
      this.mElements.unshift(c);
      this.mElementsHint.unshift(b);
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
      this.mScrollPos = 0;
      this.mElements.splice(0);
      this.mElements.length = 0;
      this.mElements = new Array();
      this.mElementsHint.splice(0);
      this.mElementsHint.length = 0;
      this.mElementsHint = new Array();
      this.numElements = 0;
      this.UpdateList();
   }
   function Clear()
   {
      this.EraseItems();
   }
   function EraseItemByIndex(idx)
   {
      this.mElements.splice(idx,1);
      this.mElementsHint.splice(idx,1);
      this.numElements = this.numElements - 1;
      this.UpdateList();
   }
   function EraseItemByName(itemName)
   {
      var _loc2_ = 0;
      while(_loc2_ < this.mElements.length)
      {
         if(this.mElements[_loc2_] == itemName)
         {
            this.EraseItemByIndex(_loc2_);
            break;
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   function GetNumElements()
   {
      return this.numElements;
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
      this.Selected(this.mCurrentSelection);
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
      this.Selected(this.mCurrentSelection);
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
   function SetLetterSpacing(a)
   {
      this.mLetterSpacing = a;
   }
   function SetAlignment(a)
   {
      if(a == "")
      {
         return undefined;
      }
      this.mAlignment = a;
      this.mTextFormat.align = this.mAlignment;
      this.mTextFormat.letterSpacing = this.mLetterSpacing;
      var _loc6_ = this.thisMC.TitleLabel.TxtHolder.Txt;
      if(_loc6_)
      {
         _loc6_.setTextFormat(this.mTextFormat);
      }
      var _loc2_ = 0;
      while(_loc2_ < this.mLabels.length)
      {
         var _loc5_ = this.mLabels[_loc2_].TxtHolder.Txt;
         if(_loc5_)
         {
            _loc5_.setTextFormat(this.mTextFormat);
         }
         var _loc3_ = this.mLabels[_loc2_].Btn;
         var _loc4_ = this.mLabels[_loc2_].HiddenBtn;
         if(this.mAlignment == "left")
         {
            _loc3_._x = _loc4_._x = 0;
         }
         else if(this.mAlignment == "center")
         {
            _loc3_._x = this.mLabels[_loc2_].TxtHolder._width / 2 - _loc3_._width / 2;
            _loc4_._x = this.mLabels[_loc2_].TxtHolder._width / 2 - _loc4_._width / 2;
         }
         else if(this.mAlignment == "right")
         {
            _loc3_._x = this.mLabels[_loc2_].TxtHolder._width - _loc3_._width;
            _loc4_._x = this.mLabels[_loc2_].TxtHolder._width - _loc4_._width;
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   function SetTitle(s)
   {
      var _loc2_ = this.thisMC.TitleLabel.Txt;
      if(_loc2_)
      {
         _loc2_.text = s;
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
      var _loc4_ = thisClip.TxtHolder.Txt;
      var _loc2_ = thisClip.Btn;
      if(thisClip.Txt)
      {
         _loc4_ = thisClip.Txt;
      }
      _loc4_.text = entryContent;
      var _loc5_ = _loc4_.textWidth;
      if(this.mAlignment == "center")
      {
         _loc2_._x = thisClip.TxtHolder._x + thisClip.TxtHolder._width / 2 - _loc5_ / 2;
         _loc2_._width = _loc5_;
      }
      else
      {
         _loc2_._x = 0;
         _loc2_._width = _loc5_;
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
   function WrapToTop()
   {
      this.mScrollPos = 0;
      this.UpdateList();
      this.SetSelected(0);
   }
   function WrapToBottom()
   {
      if(this.mElements.length > this.GetNumLabels())
      {
         this.mScrollPos = this.mElements.length - this.GetNumLabels();
      }
      else
      {
         this.mScrollPos = 0;
      }
      this.UpdateList();
      if(this.mElements.length > this.GetNumLabels())
      {
         this.SetSelected(this.GetNumLabels() - 1);
      }
      else
      {
         this.SetSelected(this.mElements.length - 1);
      }
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

class ToggleListClassImpl
{
   var mAlignment = "right";
   var mCurSelection = -1;
   var mIsExpanded = false;
   var mTextLabelCallbackOnPress = "";
   var mTextLabelCallbackOnSelected = "";
   var mTextLabelCallbackOnUnselected = "";
   var mButton0CallbackOnPress = "";
   var mButton0CallbackOnSelected = "";
   var mButton0CallbackOnUnselected = "";
   var mButton1CallbackOnPress = "";
   var mButton1CallbackOnSelected = "";
   var mButton1CallbackOnUnselected = "";
   function ToggleListClassImpl(mc)
   {
      this.mThisMC = mc;
      this.mThisMC.ToggleListClass = this;
      this.mThisMC.ListClass = new ListClassImpl(this.mThisMC.OptionList);
      this.mThisMC.OptionList.ListClass = this.mThisMC.ListClass;
      this.SetExpanded(false);
      this.SetupLabel(this.mThisMC.TextLabel);
      this.SetupButton0(this.mThisMC.Button0);
      this.SetupButton1(this.mThisMC.Button1);
      this.mElements = new Array();
      this.UpdateList();
   }
   function SetExpanded(b)
   {
      this.mIsExpanded = b;
      this.mThisMC.OptionList._visible = b;
      this.mThisMC.OptionListBackground._visible = b;
      this.mThisMC.Button0.enabled = !b;
      this.mThisMC.Button1.enabled = !b;
      this.mThisMC.ListClass.EraseItems();
      if(b)
      {
         var _loc2_ = 0;
         while(_loc2_ < this.mElements.length)
         {
            this.mThisMC.ListClass.AddItem(this.mElements[_loc2_],false);
            _loc2_ = _loc2_ + 1;
         }
      }
   }
   function SetupLabel(mc)
   {
      mc.noMenuSelection = true;
      mc.onPress = function()
      {
         if(this._parent.ToggleListClass.mTextLabelCallbackOnPress != "")
         {
            getURL("FSCommand:" add this._parent.ToggleListClass.mTextLabelCallbackOnPress,this._parent.ToggleListClass.mCurrentSelection);
         }
      };
      mc.onRollOver = function()
      {
         if(this._parent.ToggleListClass.mTextLabelCallbackOnSelected != "")
         {
            getURL("FSCommand:" add this._parent.ToggleListClass.mTextLabelCallbackOnSelected,this._parent.ToggleListClass.mCurrentSelection);
         }
      };
      mc.onRollOut = function()
      {
         if(this._parent.ToggleListClass.mTextLabelCallbackOnUnselected != "")
         {
            getURL("FSCommand:" add this._parent.ToggleListClass.mTextLabelCallbackOnUnselected,this._parent.ToggleListClass.mCurrentSelection);
         }
      };
   }
   function SetupButton0(mc)
   {
      mc.noMenuSelection = true;
      mc.onPress = function()
      {
         this._parent.ToggleListClass.PreviousItem();
         if(this._parent.ToggleListClass.mButton0CallbackOnPress != "")
         {
            getURL("FSCommand:" add this._parent.ToggleListClass.mButton0CallbackOnPress,this._parent.ToggleListClass.mCurrentSelection);
         }
         gotoAndStop("Pressed");
         play();
      };
      mc.onRollOver = function()
      {
         if(this._parent.ToggleListClass.mButton0CallbackOnSelected != "")
         {
            getURL("FSCommand:" add this._parent.ToggleListClass.mButton0CallbackOnSelected,this._parent.ToggleListClass.mCurrentSelection);
         }
         gotoAndStop("Selected");
         play();
      };
      mc.onRollOut = function()
      {
         if(this._parent.ToggleListClass.mButton0CallbackOnUnselected != "")
         {
            getURL("FSCommand:" add this._parent.ToggleListClass.mButton0CallbackOnUnselected,this._parent.ToggleListClass.mCurrentSelection);
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
         this._parent.ToggleListClass.NextItem();
         if(this._parent.ToggleListClass.mButton1CallbackOnPress != "")
         {
            getURL("FSCommand:" add this._parent.ToggleListClass.mButton1CallbackOnPress,this._parent.ToggleListClass.mCurrentSelection);
         }
         gotoAndStop("Pressed");
         play();
      };
      mc.onRollOver = function()
      {
         if(this._parent.ToggleListClass.mButton1CallbackOnSelected != "")
         {
            getURL("FSCommand:" add this._parent.ToggleListClass.mButton1CallbackOnSelected,this._parent.ToggleListClass.mCurrentSelection);
         }
         gotoAndStop("Selected");
         play();
      };
      mc.onRollOut = function()
      {
         if(this._parent.ToggleListClass.mButton1CallbackOnUnselected != "")
         {
            getURL("FSCommand:" add this._parent.ToggleListClass.mButton1CallbackOnUnselected,this._parent.ToggleListClass.mCurrentSelection);
         }
         gotoAndStop("Unselected");
         play();
      };
   }
   function NextItem()
   {
      this.mCurSelection = this.mCurSelection + 1;
      if(this.mCurSelection >= this.mElements.length)
      {
         this.mCurSelection = 0;
      }
      this.UpdateList();
   }
   function PreviousItem()
   {
      this.mCurSelection = this.mCurSelection - 1;
      if(this.mCurSelection < 0)
      {
         this.mCurSelection = this.mElements.length - 1;
      }
      this.UpdateList();
   }
   function SetSelected(idx)
   {
      this.mCurSelection = idx;
      this.UpdateList();
   }
   function ItemExists(c)
   {
      var _loc2_ = 0;
      while(_loc2_ < this.mElements.length)
      {
         if(this.mElements[_loc2_] == c)
         {
            return true;
         }
         _loc2_ = _loc2_ + 1;
      }
      return false;
   }
   function AddItem(c)
   {
      this.mElements.push(c);
      if(this.mCurSelection < 0)
      {
         this.mCurSelection = 0;
      }
      this.UpdateList();
   }
   function SetItem(idx, c)
   {
      this.mElements[idx] = c;
      this.UpdateList();
   }
   function FindItemIndexByName(s)
   {
      var _loc2_ = 0;
      while(_loc2_ < this.mElements.length)
      {
         if(this.mElements[_loc2_] == s)
         {
            return _loc2_;
         }
         _loc2_ = _loc2_ + 1;
      }
      return -1;
   }
   function EraseItemByIndex(idx)
   {
      var _loc2_ = this.mElements[idx];
      this.mElements.splice(idx,1);
      this.UpdateList();
   }
   function EraseItemByName(s)
   {
      var _loc2_ = this.FindItemIndexByName(s);
      this.EraseItemByIndex(_loc2_);
   }
   function Clear()
   {
      this.mElements.splice(0);
      this.mElements.length = 0;
      this.mElements = new Array();
      this.UpdateList();
   }
   function UpdateList()
   {
      this.mThisMC.TextLabel.TxtHolder.Txt.textAlign = this.mAlignment;
      this.mThisMC.TextLabel.TxtHolder.Txt.text = this.mElements[this.mCurSelection];
   }
   function SetAlignment(a)
   {
      this.mAlignment = a;
      this.UpdateList();
   }
   function SetTextLabelCallbackOnPress(c)
   {
      this.mTextLabelCallbackOnPress = c;
   }
   function SetTextLabelCallbackOnSelected(c)
   {
      this.mTextLabelCallbackOnSelected = c;
   }
   function SetTextLabelCallbackOnUnselected(c)
   {
      this.mTextLabelCallbackOnUnselected = c;
   }
   function SetButton0SelectedCallback(c)
   {
      this.mButton0CallbackOnSelected = c;
   }
   function SetButton0UnselectedCallback(c)
   {
      this.mButton0CallbackOnUnselected = c;
   }
   function SetButton0PressedCallback(c)
   {
      this.mButton0CallbackOnPress = c;
   }
   function SetButton1SelectedCallback(c)
   {
      this.mButton1CallbackOnSelected = c;
   }
   function SetButton1UnselectedCallback(c)
   {
      this.mButton1CallbackOnUnselected = c;
   }
   function SetButton1PressedCallback(c)
   {
      this.mButton1CallbackOnPress = c;
   }
}

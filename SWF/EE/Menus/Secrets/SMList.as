class SMList extends MovieClip
{
   var _valid = false;
   var _maxDisplayItems = 12;
   var _scroll = 0;
   var _selector = 0;
   var itemSpacing = 24;
   var callbackTarget = null;
   var onItemSelect = null;
   var onItemFocus = null;
   var onItemLoseFocus = null;
   var _enabled = true;
   function SMList()
   {
      super();
      this._items = [];
      var _loc4_ = 0;
      while(_loc4_ < this._maxDisplayItems)
      {
         this._items[_loc4_] = null;
         _loc4_ = _loc4_ + 1;
      }
      this._displayItems = [this._maxDisplayItems];
      var _loc5_ = 0;
      var _loc3_ = undefined;
      _loc4_ = 0;
      while(_loc4_ < this._maxDisplayItems)
      {
         _loc3_ = (SMListItem)this.attachMovie("SMListItem","li_" + _loc4_,this.getNextHighestDepth());
         _loc3_.focusEnabled = false;
         _loc3_.master = this;
         _loc3_._y = _loc5_;
         _loc3_._visible = false;
         _loc3_.index = _loc4_;
         _loc5_ = _loc3_.getBounds(this).yMax + this.itemSpacing;
         this._displayItems[_loc4_] = _loc3_;
         _loc4_ = _loc4_ + 1;
      }
      this.avatar.enabled = false;
      this.avatar._visible = false;
      this.topArrow = this.attachMovie("BigArrow","topArrow",this.getNextHighestDepth());
      this.bottomArrow = this.attachMovie("BigArrow","bottomArrow",this.getNextHighestDepth());
      var _loc6_ = 24;
      this.topArrow._y = - _loc6_;
      this.bottomArrow._y = _loc5_ - this.itemSpacing + _loc6_;
      this.bottomArrow.gotoAndStop(2);
      this.topArrow._visible = false;
      this.bottomArrow._visible = false;
      this.topArrow._alpha = 64;
      this.bottomArrow._alpha = 64;
      this.invalidate();
   }
   function clearList()
   {
      var _loc2_ = 0;
      while(_loc2_ < this._maxDisplayItems)
      {
         this._items[_loc2_] = null;
         this._displayItems[_loc2_]._visible = false;
         _loc2_ = _loc2_ + 1;
      }
   }
   function invalidate()
   {
      this._valid = false;
      this.validate();
   }
   function validate()
   {
      if(this._valid)
      {
         return undefined;
      }
      this.draw();
   }
   function selectItem(index)
   {
      this._displayItems[index].press();
   }
   function setArrowVisible(arrow, visible)
   {
      trace("Setting arrow " + arrow + " to: " + visible);
      if(arrow == 0)
      {
         this.topArrow._visible = visible;
      }
      else if(arrow == 1)
      {
         this.bottomArrow._visible = visible;
      }
   }
   function itemSelect(item)
   {
      if(this.onItemSelect)
      {
         this.onItemSelect.call(this.callbackTarget,item);
      }
   }
   function itemFocus(item)
   {
      if(this.onItemFocus)
      {
         this.onItemFocus.call(this.callbackTarget,item);
      }
   }
   function itemLoseFocus(item)
   {
      if(this.onItemLoseFocus)
      {
         this.onItemLoseFocus.call(this.callbackTarget,item);
      }
   }
   function draw()
   {
      this._valid = true;
      var _loc3_ = undefined;
      var _loc2_ = undefined;
      _loc2_ = 0;
      while(_loc2_ < this._maxDisplayItems)
      {
         if(this._items[_loc2_] == undefined || this._items[_loc2_] == null || this._items[_loc2_] == "")
         {
            break;
         }
         _loc3_ = this._displayItems[_loc2_];
         _loc3_.setText(this._items[_loc2_]);
         _loc3_._visible = true;
         _loc2_ = _loc2_ + 1;
      }
      if(_loc2_ < this._maxDisplayItems)
      {
         _loc2_;
         while(_loc2_ < this._maxDisplayItems)
         {
            if(!this._displayItems[_loc2_]._visible)
            {
               break;
            }
            this._displayItems[_loc2_]._visible = false;
            _loc2_ = _loc2_ + 1;
         }
      }
   }
   function onUpdate()
   {
      this.validate();
   }
   function setEnabled(value)
   {
      if(value == this._enabled)
      {
         return undefined;
      }
      this._enabled = value;
      var _loc3_ = undefined;
      var _loc2_ = 0;
      while(_loc2_ < this._maxDisplayItems.length)
      {
         _loc3_ = this._displayItems[_loc2_];
         _loc3_.setEnabled(this._enabled);
         _loc2_ = _loc2_ + 1;
      }
   }
   function setItem(label, index, type, data)
   {
      if(index < 0 || index >= this._maxDisplayItems)
      {
         return undefined;
      }
      var _loc3_ = this._displayItems[index];
      _loc3_.data = data;
      _loc3_.setType(type);
      this._items[index] = label;
   }
   function setItems(value)
   {
      this.clearList();
      var _loc4_ = Math.max(this._maxDisplayItems,value.length);
      var _loc2_ = 0;
      while(_loc2_ < value.length)
      {
         this.setItem(value[_loc2_],_loc2_,2,true);
         _loc2_ = _loc2_ + 1;
      }
      this.invalidate();
   }
   function getItems()
   {
      return this._displayItems;
   }
   function getItemAt(index)
   {
      if(index < 0 || index >= this._maxDisplayItems)
      {
         return null;
      }
      return this._displayItems[index];
   }
   function count()
   {
      return this._items.length;
   }
}

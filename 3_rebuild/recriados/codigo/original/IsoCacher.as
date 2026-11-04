package com.playfish.games.cooking
{
   import away3d.containers.View3D;
   import away3d.core.base.Object3D;
   import away3d.core.math.Number3D;
   import away3d.lights.DirectionalLight3D;
   import com.playfish.games.cooking.ui.WorldPopUp;
   import flash.display.*;
   import flash.events.Event;
   import flash.geom.*;
   import flash.utils.*;
   
   public class IsoCacher
   {
      
      private var callback:Function;
      
      private var isoMode:Boolean;
      
      private var model:Object3D;
      
      private var view:View3D;
      
      private var curYaw:Number = 0;
      
      private var light:DirectionalLight3D;
      
      private var resolutionBoost:Number;
      
      public function IsoCacher(param1:Avatar3D, param2:Function, param3:Boolean = true, param4:Boolean = true, param5:int = 0)
      {
         super();
         this.model = param1.model;
         this.callback = param2;
         this.isoMode = param4;
         this.view = GameWorld.view3d;
         this.light = GameWorld.light;
         this.reset();
         this.setRotation(param5);
         this.resolutionBoost = 1;
         if(param3)
         {
            this.view.addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
         }
         else
         {
            this.cache();
         }
      }
      
      public function setRotation(param1:Number) : void
      {
         this.model.yaw(this.curYaw - param1);
         this.curYaw = param1;
      }
      
      public function destroy() : void
      {
         if(this.view != null)
         {
            if(this.model.parent == this.view.scene)
            {
               this.view.scene.removeChild(this.model);
            }
            this.view.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
            if(this.view.parent == Engine.instance)
            {
               Engine.instance.stage.removeChild(this.view);
            }
            this.view = null;
         }
      }
      
      private function cache() : void
      {
         var _loc1_:* = undefined;
         do
         {
            _loc1_ = this.renderShape();
         }
         while(this.callback(_loc1_));
         this.destroy();
      }
      
      private function reset() : void
      {
         this.view.visible = false;
         this.view.x = 320;
         this.view.y = 480;
         this.view.scene.addChild(this.model);
         Engine.instance.stage.addChild(this.view);
         if(this.isoMode)
         {
            this.view.camera.x = 0;
            this.view.camera.y = 0;
            this.view.camera.z = -80000;
            this.view.camera.lookAt(new Number3D(0,0,0));
            this.model.lookAt(Number3D.FORWARD);
            this.model.pitch(-30);
         }
         else
         {
            this.view.camera.x = 0;
            this.view.camera.y = 0;
            this.view.camera.z = -55000;
            this.view.camera.lookAt(new Number3D(0,0,0));
            this.model.lookAt(Number3D.FORWARD);
         }
         this.light.position = new Number3D(-100000,9000,-84000);
         this.light.lookAt(new Number3D(0,0,0));
      }
      
      private function renderShape() : Object
      {
         this.view.visible = true;
         this.view.render();
         var _loc1_:DisplayObjectContainer = this.view.session.getContainer(this.view) as DisplayObjectContainer;
         var _loc2_:DisplayObject = _loc1_.getChildAt(0);
         var _loc3_:Rectangle = _loc2_.getRect(null);
         var _loc4_:Rectangle = _loc2_.getRect(_loc2_);
         var _loc5_:BitmapData = new BitmapData(Math.max(1,_loc3_.width),Math.max(1,_loc3_.height),true,0);
         _loc5_.draw(_loc2_,new Matrix(1,0,0,1,-_loc4_.left,-_loc4_.top));
         this.view.clear();
         this.view.visible = false;
         var _loc6_:Object = new Object();
         _loc6_.bitmapData = _loc5_;
         _loc6_.x = _loc3_.left;
         _loc6_.y = _loc3_.top;
         return _loc6_;
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         var _loc2_:int = 0;
         var _loc3_:* = undefined;
         if(this.model.parent != this.view.scene)
         {
            this.reset();
            this.setRotation(this.curYaw);
         }
         if(WorldPopUp.activePopUp.length == 0)
         {
            _loc2_ = getTimer();
            do
            {
               _loc3_ = this.renderShape();
               if(!this.callback(_loc3_))
               {
                  break;
               }
            }
            while(getTimer() - _loc2_ < 15);
         }
      }
      
      public function setResolutionBoost(param1:Number) : void
      {
         this.resolutionBoost = param1;
      }
   }
}


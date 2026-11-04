package com.playfish.games.cooking
{
   import flash.display.*;
   import flash.geom.*;
   import flash.utils.*;
   
   public class AnimatedObject extends BaseObject
   {
      
      public var nextAnimations:Array = new Array();
      
      public var nextAnimationsLoop:Array = new Array();
      
      public var frameDelay:int = 33;
      
      public var curLabelIndex:int = 0;
      
      public var frameTimer:int;
      
      public var finishAtFirstFrame:Boolean = false;
      
      public var numLoops:int = -1;
      
      public var pause:Boolean = false;
      
      public function AnimatedObject(param1:String = null)
      {
         super(param1);
         super.stop();
         this.frameTimer = this.frameDelay;
      }
      
      public function setSequence(param1:String) : void
      {
         var _loc2_:Number = 0;
         while(_loc2_ < content.currentLabels.length)
         {
            if(content.currentLabels[_loc2_].name == param1)
            {
               content.gotoAndStop(content.currentLabels[_loc2_].frame);
               this.frameTimer = this.frameDelay;
               this.curLabelIndex = _loc2_;
               return;
            }
            _loc2_++;
         }
      }
      
      override public function stop() : void
      {
         super.stop();
         this.pause = true;
      }
      
      private function loopBackToStart() : void
      {
         if(content.currentLabels.length > 0)
         {
            content.gotoAndStop(content.currentLabels[this.curLabelIndex].name);
         }
         else
         {
            content.gotoAndStop(1);
         }
      }
      
      public function setFrameDelay(param1:int) : void
      {
         this.frameDelay = param1;
      }
      
      override public function tick(param1:uint) : void
      {
         if(this.pause)
         {
            return;
         }
         this.frameTimer -= param1;
         while(this.numLoops != 0 && this.frameTimer < 0)
         {
            if(this.hasReachedAnimationEnd())
            {
               if(this.numLoops > 0)
               {
                  --this.numLoops;
               }
               if(this.numLoops != 0)
               {
                  this.loopBackToStart();
               }
               else if(this.nextAnimations.length > 0)
               {
                  this.nextAnimations.splice(0,1);
                  this.nextAnimationsLoop.splice(0,1);
               }
               else if(this.finishAtFirstFrame)
               {
                  this.loopBackToStart();
               }
            }
            else
            {
               content.nextFrame();
            }
            this.frameTimer += this.frameDelay;
         }
      }
      
      public function getCurrentSequence() : String
      {
         if(content.currentLabels.length == 0)
         {
            return null;
         }
         return content.currentLabels[this.curLabelIndex].name;
      }
      
      public function getFrameCount() : int
      {
         return content.totalFrames;
      }
      
      public function setFrame(param1:int) : void
      {
         var _loc2_:int = param1;
         if(content.currentLabels.length > 0)
         {
            _loc2_ = content.currentLabels[this.curLabelIndex].frame + param1 - 1;
         }
         if(_loc2_ != content.currentFrame)
         {
            content.gotoAndStop(_loc2_);
         }
         this.frameTimer = this.frameDelay;
      }
      
      public function resume() : void
      {
         this.pause = false;
      }
      
      private function hasReachedAnimationEnd() : Boolean
      {
         var _loc1_:int = this.curLabelIndex + 1;
         if(_loc1_ < content.currentLabels.length)
         {
            return content.currentFrame >= content.currentLabels[_loc1_].frame - 1;
         }
         return content.currentFrame >= content.totalFrames;
      }
      
      public function getFrame() : int
      {
         if(content.currentLabels.length > 0)
         {
            return content.currentFrame - content.currentLabels[this.curLabelIndex].frame + 1;
         }
         return content.currentFrame;
      }
      
      public function nextFrame() : void
      {
         if(this.hasReachedAnimationEnd())
         {
            this.loopBackToStart();
         }
         else
         {
            content.nextFrame();
         }
      }
      
      public function hasSequence(param1:String) : Boolean
      {
         var _loc2_:Number = 0;
         while(_loc2_ < content.currentLabels.length)
         {
            if(content.currentLabels[_loc2_].name == param1)
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
   }
}


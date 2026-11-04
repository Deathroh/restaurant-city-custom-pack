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
         while(_loc2_ < this.rcrLabels().length)
         {
            if(this.rcrLabels()[_loc2_].name == param1)
            {
               content.gotoAndStop(this.rcrLabels()[_loc2_].frame);
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
      
      // RCR (2026-11-03), desempenho. Medido no navegador: as 46 arvores/gramas/hidrantes da rua (RoadTrees)
      // gastavam ~97% do tempo de logica do jogo. Tres causas, corrigidas aqui:
      // 1. content.currentLabels cria uma lista nova a cada chamada; era chamado varias vezes por passo.
      //    Agora a lista e lida uma vez por clip (rcrLabels).
      // 2. Animacao de um quadro so (idle das arvores, grama) voltava ao inicio com gotoAndStop no quadro em
      //    que ja estava. No Flash e nada; no Ruffle refaz o clip inteiro. Agora so vai se o quadro mudar.
      // 3. Quadro atrasado fazia cada objeto recuperar todos os passos perdidos de uma vez (com dt de 600 ms,
      //    18 passos por objeto), o que atrasava mais o quadro seguinte. Agora no maximo 3 passos por quadro;
      //    o resto do atraso e descartado (a animacao so fica um pouco mais lenta quando o jogo engasga).
      // Original em recriados/codigo/original/AnimatedObject.as.
      private var rcrLab:Array = null;

      private var rcrLabDe:MovieClip = null;

      private function rcrLabels() : Array
      {
         if(this.rcrLabDe != content)
         {
            this.rcrLabDe = content;
            this.rcrLab = content.currentLabels;
         }
         return this.rcrLab;
      }

      private function loopBackToStart() : void
      {
         var _loc1_:int = this.rcrLabels().length > 0 ? int(this.rcrLabels()[this.curLabelIndex].frame) : 1;
         if(content.currentFrame != _loc1_)
         {
            content.gotoAndStop(_loc1_);
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
         var _loc2_:int = 0;
         while(this.numLoops != 0 && this.frameTimer < 0)
         {
            if(++_loc2_ > 3)
            {
               this.frameTimer = this.frameDelay;
               break;
            }
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
         if(this.rcrLabels().length == 0)
         {
            return null;
         }
         return this.rcrLabels()[this.curLabelIndex].name;
      }
      
      public function getFrameCount() : int
      {
         return content.totalFrames;
      }
      
      public function setFrame(param1:int) : void
      {
         var _loc2_:int = param1;
         if(this.rcrLabels().length > 0)
         {
            _loc2_ = this.rcrLabels()[this.curLabelIndex].frame + param1 - 1;
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
         if(_loc1_ < this.rcrLabels().length)
         {
            return content.currentFrame >= this.rcrLabels()[_loc1_].frame - 1;
         }
         return content.currentFrame >= content.totalFrames;
      }
      
      public function getFrame() : int
      {
         if(this.rcrLabels().length > 0)
         {
            return content.currentFrame - this.rcrLabels()[this.curLabelIndex].frame + 1;
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
         while(_loc2_ < this.rcrLabels().length)
         {
            if(this.rcrLabels()[_loc2_].name == param1)
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
   }
}


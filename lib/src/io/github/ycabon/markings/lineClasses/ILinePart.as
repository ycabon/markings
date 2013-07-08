///////////////////////////////////////////////////////////////////////////
// Copyright (c) 2013 Esri. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
///////////////////////////////////////////////////////////////////////////

package io.github.ycabon.markings.lineClasses
{

import flash.display.Sprite;
import flash.events.IEventDispatcher;

import io.github.ycabon.markings.supportClasses.SegmentsView;
import io.github.ycabon.markings.supportClasses.SpritePool;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the value of the part changes
 *  as a result of its properties modifications.
 *
 *  @eventType flash.events.Event.CHANGE
 */
[Event(name="change", type="flash.events.Event")]

/**
 *  The ILinePart interface is used to define objects that can be used as
 *  part of a collection in an AdvancedLineSymbol.
 *
 *  @see io.github.ycabon.markings.AdvancedLineSymbol
 */
public interface ILinePart extends IEventDispatcher
{
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  depth
    //----------------------------------
    
    /**
     * Determines the order in which the line part is processed.
     * <p>This value is set automatically by the AdvancedLineSymbol.</p>
     */ 
    function get depth():int;
    
    /**
     * @private
     */ 
    function set depth(value:int):void;
    
    
    //--------------------------------------------------------------------------
    //
    //  Public functions
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Initialize the drawing of the line.
     *  <p>This function is called by the AdvancedLineSymbol before draw() is called.</p>
     *  <p>One typical implementation is to clear the sprite.</p>
     * 
     *  @param sprite The sprite object that will be drawn.
     */
    function beginDraw(sprite:Sprite):void;
    
    /**
     *  Function called by the AdvancedLineSymbol to draw the polyline on the <code>sprite</code>.
     * 
     *  @param sprite The sprite object that will be drawn.
     *  @param attributes The object containing the attributes of the Graphic.
     *  @param polylineView The helper object containing the screen coordinates of the Polyline.
     *  @param pool A pool of sprites to easily add and remove sub-sprites to the sprite.
     */
    function draw(sprite:Sprite, attributes:Object, polylineView:SegmentsView, pool:SpritePool):void;
    
    /**
     *  End the drawing of the line.
     * 
     *  @param sprite The sprite object that will be drawn.
     */
    function endDraw(sprite:Sprite):void;
    
    // function drawSwatch(sprite:Sprite, width:Number, height:Number):void;
}

}

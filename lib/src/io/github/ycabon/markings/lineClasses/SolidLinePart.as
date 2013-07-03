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

import flash.display.Graphics;
import flash.display.GraphicsPath;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import io.github.ycabon.markings.supportClasses.SegmentsView;
import io.github.ycabon.markings.supportClasses.SpritePool;

import mx.events.PropertyChangeEvent;
import mx.graphics.IStroke;

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

//--------------------------------------
//  Other Metadatas
//--------------------------------------

[DefaultProperty("stroke")]

/**
 *  The SolidLinePart can be used as a part of an AdvancedLineSymbol.
 *  <p>
 *  This part is very efficient and draws the line using strokes from the Flex SDK:
 *  </p>
 *  <ul>
 *  <li>
 *  <code>SolidColorStroke</code> - lets you specify a solid filled stroke.
 *  </li> 
 *  <li>
 *  <code>LinearGradientStroke</code> - lets you specify a linear gradient filled stroke.
 *  </li>
 *  <li>
 *  <code>RadialGradientStroke</code> - lets you specify a radial gradient filled stroke. 
 *  </li>
 *  </ul>
 *  
 *  <pre>
 *  ...
 *  &lt;mk:AdvancedLineSymbol&gt;
 *      &lt;s:ArrayList&gt;
 *          &lt;mk:SolidLinePart yOffset="5"&gt;
 *              &lt;s:SolidColorStroke alpha="1"
 *                                  color="0xDD0000"
 *                                  weight="6"/&gt;
 *          &lt;/mk:SolidLinePart&gt;
 *      &lt;/s:ArrayList&gt;
 *  &lt;/mk:AdvancedLineSymbol&gt;
 *  ...
 *  </pre>
 *
 *  @mxml
 *
 *  <p>The <code>&lt;mk:SolidLinePart&gt;</code> tag inherits all the tag attributes
 *  of its superclass, and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;mk:SolidLinePart
 *    <b>Properties</b>
 *    stroke="null"
 *    xOffset="0"
 *    yOffset="0"
 *  /&gt;
 *  </pre>
 *
 *  @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/mx/graphics/SolidColorStroke.html mx.graphics.SolidColorStroke
 *  @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/mx/graphics/LinearGradientStroke.html mx.graphics.LinearGradientStroke
 *  @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/mx/graphics/RadialGradientStroke.html mx.graphics.RadialGradientStroke
 * 
 */
public class SolidLinePart extends EventDispatcher implements ILinePart
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     * Constructor.
     * 
     * @param stroke The stroke used by this part.
     * @param xOffset The offset on the x-axis in pixel to apply to the projected line.
     * @param yOffset The offset on the y-axis in pixel to apply to the projected line.
     */
    public function SolidLinePart(stroke:IStroke = null,
                                  xOffset:int = 0,
                                  yOffset:int = 0)
    {
        this.stroke = stroke;
        this.xOffset = xOffset;
        this.yOffset = yOffset;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  depth
    //----------------------------------
    
    private var _depth:int;
    
    /**
     * @private
     */
    public function get depth():int
    {
        return _depth;
    }
    
    /**
     * @private
     */
    public function set depth(value:int):void
    {
        _depth = value;
    }
    
    //----------------------------------
    //  stroke
    //----------------------------------
    
    private var _stroke:IStroke;
    
    [Bindable(event="change")]
    
    /**
     * The stroke used by this part.
     */
    public function get stroke():IStroke
    {
        return _stroke;
    }
    
    /**
     * @private
     */
    public function set stroke(value:IStroke):void
    {
        if (_stroke !== value)
        {
            if (_stroke && _stroke is IEventDispatcher)
            {
                (_stroke as IEventDispatcher).removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, strokeChangeHandler);
            }
            _stroke = value;
            if (_stroke && _stroke is IEventDispatcher)
            {
                (_stroke as IEventDispatcher).addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, strokeChangeHandler);
            }
            dispatchChangeEvent();
        }
    }

    //----------------------------------
    //  xOffset
    //----------------------------------

    private var _xOffset:int = 0;
    
    [Bindable(event="change")]
    
    /**
     * The offset on the x-axis in pixel to apply to the projected line.
     */
    public function get xOffset():int
    {
        return _xOffset;
    }
    
    /**
     * @private
     */
    public function set xOffset(value:int):void
    {
        if (_xOffset !== value)
        {
            _xOffset = value;
            dispatchChangeEvent();
        }
    }

    //----------------------------------
    //  yOffset
    //----------------------------------

    private var _yOffset:int = 0;
    
    [Bindable(event="change")]
    
    /**
     * The offset on the y-axis in pixel to apply to the projected line.
     */
    public function get yOffset():int
    {
        return _yOffset;
    }
    
    /**
     * @private
     */
    public function set yOffset(value:int):void
    {
        if (_yOffset !== value)
        {
            _yOffset = value;
            dispatchChangeEvent();
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     * @private
     */
    public function beginDraw(sprite:Sprite):void
    {
        if (!stroke)
        {
            return;
        }
        stroke.apply(sprite.graphics, null, null);
    }
    
    /**
     * @private
     */
    public function draw(sprite:Sprite, attributes:Object, polylineView:SegmentsView, pool:SpritePool):void
    {
        if (!stroke)
        {
            return;
        }

        // Apply the offsets to the data
        var path:GraphicsPath = polylineView.graphicsPath;
        var data:Vector.<Number> = path.data;

        if (_xOffset != 0 || _yOffset != 0)
        {
            data = data.concat();
            for (var i:int = 0, len:int = path.commands.length; i < len; i++)
            {
                data[i * 2] += _xOffset;
                data[i * 2 + 1] += _yOffset;
            }
        }

        var graphics:Graphics = sprite.graphics;
        graphics.drawPath(path.commands, data);
    }
    
    /**
     * @private
     */
    public function endDraw(sprite:Sprite):void
    {
        if (!stroke)
        {
            return;
        }
        sprite.graphics.lineStyle();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     * @private
     */
    private function dispatchChangeEvent():void
    {
        if (hasEventListener("change"))
        {
            dispatchEvent(new Event("change"));
        }
    }
    
    /**
     * @private
     */
    private function strokeChangeHandler(event:PropertyChangeEvent):void
    {
        dispatchChangeEvent();
    }
    
}
}

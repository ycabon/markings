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
import flash.geom.Point;

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
 *  The DashedLinePart can be used as a part of an AdvancedLineSymbol.
 *  <p>
 *  This part draws the line using blank gaps and strokes from the Flex SDK:
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
 *          &lt;mk:DashedLinePart pattern"[10, 5]"&gt;
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
 *  <p>The <code>&lt;mk:DashedLinePart&gt;</code> tag inherits all the tag attributes
 *  of its superclass, and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;mk:DashedLinePart
 *    <b>Properties</b>
 *    stroke="null"
 *    xOffset="0"
 *    yOffset="0"
 *    pattern="[5, 5]"
 *    inverse="false"
 *  /&gt;
 *  </pre>
 *
 *  @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/mx/graphics/SolidColorStroke.html mx.graphics.SolidColorStroke
 *  @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/mx/graphics/LinearGradientStroke.html mx.graphics.LinearGradientStroke
 *  @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/mx/graphics/RadialGradientStroke.html mx.graphics.RadialGradientStroke
 * 
 */
public class DashedLinePart extends EventDispatcher implements ILinePart
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
     * @param pattern The pattern used to draw dashes, in pixels.
     * @param inverse if <code>true</code> the pattern begin by a gap.
     */
    public function DashedLinePart(stroke:IStroke = null,
                                   xOffset:int = 0,
                                   yOffset:int = 0,
                                   pattern:Array = null,
                                   inverse:Boolean = false)
    {
        super();
        this.stroke = stroke;
        this.xOffset = xOffset;
        this.yOffset = yOffset;
        this.pattern = pattern ? pattern : [ 5, 5 ];
        this.inverse = inverse;
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    private var _drawPattern:DrawPattern = new DrawPattern();

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
     *  The stroke used by this part.
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
            if (_stroke)
            {
                _drawPattern.strokeWeight = _stroke.weight;
            }
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
     *  The offset on the x-axis in pixel to apply to the projected line.
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
     *  The offset on the y-axis in pixel to apply to the projected line.
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

    //----------------------------------
    //  pattern
    //----------------------------------

    private var _pattern:Array;

    [ArrayElementType("Number")]
    [Bindable(event="change")]
    
    /**
     * The pattern used to draw dashes, in pixels.
     * <p>The part draw the first value in pixels, then apply a gap of the length of the second value, and so on.
     * This behavior can be changed using the <code>inverse</code> property.</p>
     * 
     * <p>The default value is <code>[5, 5]</code>.</p>
     * 
     * @default [5, 5]
     * 
     * @see #inverse
     */
    public function get pattern():Array
    {
        return _pattern;
    }
    
    /**
     * @private
     */
    public function set pattern(value:Array):void
    {
        if (_pattern !== value)
        {
            _pattern = value;
            _drawPattern.pattern = _pattern;
            dispatchChangeEvent();
        }
    }

    //----------------------------------
    //  inverse
    //----------------------------------

    private var _inverse:Boolean = false;

    [Bindable(event="change")]
    
    /**
     * Indicates if the pattern begin by a dash or by a gap.
     * 
     * <p>The default value is <code>false</code>, which means that the pattern begins by a dash.</p>
     * 
     * @default false
     * 
     * @see #pattern
     */
    public function get inverse():Boolean
    {
        return _inverse;
    }
    
    /**
     * @private
     */
    public function set inverse(value:Boolean):void
    {
        if (_inverse !== value)
        {
            _inverse = value;
            _drawPattern.inverse = _inverse;
            dispatchChangeEvent();
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Public Methods: ILInePart
    //
    //--------------------------------------------------------------------------
    
    /**
     * @private
     */
    public function beginDraw(sprite:Sprite):void
    {
        if (!stroke || stroke.weight <= 0)
        {
            return;
        }
        _drawPattern.validate();
    }
    
    /**
     * @private
     */
    public function draw(sprite:Sprite, attributes:Object, polylineView:SegmentsView, pool:SpritePool):void
    {
        if (!stroke || stroke.weight <= 0)
        {
            return;
        }
        drawPath(sprite, polylineView.graphicsPath)
    }
    
    /**
     * @private
     */
    public function endDraw(sprite:Sprite):void
    {
        if (!stroke || stroke.weight == 0)
        {
            return;
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
    private function drawPath(sprite:Sprite, graphicsPath:GraphicsPath):void
    {
        var commands:Vector.<int> = graphicsPath.commands;
        var data:Vector.<Number> = graphicsPath.data;
        var graphics:Graphics = sprite.graphics;
        var d:int = 0; // Data index

        for (var cmdIndex:int = 0, numCommands:int = commands.length; cmdIndex < numCommands; )
        {
            // GraphicsPathCommand.MOVE_TO
            if (commands[cmdIndex] == 1)
            {
                cmdIndex += drawNextSegment(graphics, commands, data, cmdIndex);
            }
            else
            {
                cmdIndex++;
            }
        }
    }
    
    /**
     * @private
     */
    private function drawNextSegment(graphics:Graphics, commands:Vector.<int>, data:Vector.<Number>, cmdIndex:int):int
    {
        var drawState:DrawState = new DrawState();
        drawState.isDrawing = !inverse;

        // calculate the number of command to execute
        var endIndex:int = commands.indexOf(1, cmdIndex + 1); // GraphicsPathCommand.MOVE_TO
        endIndex = endIndex == -1 ? commands.length - 1 : endIndex - 1;

        var startDataIndex:int = cmdIndex * 2;
        var endDataIndex:int = endIndex * 2 - 2;

        var numConsumedCommands:int = endIndex - cmdIndex + 1;

        // Transform the pattern to make it take to whole line
        var segmentLength:Number = calculateSegmentLength(data, startDataIndex, endDataIndex);
        var numCompletePattern:uint = uint(segmentLength / _drawPattern.length);

        //
        // INIT
        //

        _drawPattern.applyGapOffset((segmentLength - numCompletePattern * _drawPattern.length) / numCompletePattern);

        // What has been done before ?
        var elementLengthOffset:Number;
        // Apply the pattern until we reach x and y (the total length)
        var finished:Boolean;
        // part of the line already drawn
        var lengthDrawn:Number;
        var lengthToDraw:Number;
        // 
        var patternValue:Number;

        //
        // DRAW
        //

        // move to start;
        var pen:Point = new Point(data[startDataIndex] + xOffset, data[startDataIndex + 1] + yOffset);
        graphics.moveTo(pen.x, pen.y);

        for (; startDataIndex <= endDataIndex; startDataIndex += 2)
        {
            // Apply the pattern until we reach x and y (the total length)
            finished = false;
            lengthDrawn = 0;

            var dX:Number = data[startDataIndex + 2] - data[startDataIndex];
            var dY:Number = data[startDataIndex + 3] - data[startDataIndex + 1];
            var len:Number = Math.sqrt(Math.pow(dX, 2) + Math.pow(dY, 2));

            if (len > 0)
            {
                while (!finished)
                {
                    patternValue = _drawPattern.getElementAt(drawState.elementIndex);
                    elementLengthOffset = drawState.elementLengthOffset;

                    // apply the pattern
                    if (!drawState.elementPrepared)
                    {
                        drawState.elementPrepared = true;
                        if (drawState.isDrawing && stroke.weight != 0)
                        {
                            stroke.apply(graphics, null, null);
                        }
                        else
                        {
                            graphics.lineStyle(0, 0, 0);
                        }
                    }

                    // what has to be drawn from the pattern
                    lengthToDraw = patternValue - elementLengthOffset;

                    // what if the length to draw exceed the total length
                    if (lengthDrawn + lengthToDraw >= len)
                    {
                        // correct the length to draw
                        lengthToDraw = len - lengthDrawn;

                        // then apply the offset for the next call
                        drawState.elementLengthOffset += lengthToDraw;

                        // the line is nearly finished
                        finished = true;
                    }
                    else
                    {
                        // if the pattern has entierely been consumed, move to the next
                        drawState.elementLengthOffset = 0;
                        drawState.elementPrepared = false;
                        drawState.isDrawing = !drawState.isDrawing;
                        drawState.elementIndex = (drawState.elementIndex + 1) % _drawPattern.numElements;
                    }

                    // total length drawn
                    lengthDrawn += lengthToDraw;

                    // update the new pen coords
                    pen.offset(lengthToDraw * dX / len, lengthToDraw * dY / len);
                    graphics.lineTo(pen.x, pen.y);
                }
            }
        }

        return numConsumedCommands;
    }
    
    /**
     * @private
     */
    private function calculateSegmentLength(data:Vector.<Number>, startDataIndex:int, endDataIndex:int):Number
    {
        var len:Number = 0;
        var dX:Number, dY:Number;
        for (var i:int = startDataIndex; i <= endDataIndex; i += 2)
        {
            dX = data[i + 2] - data[i];
            dY = data[i + 3] - data[i + 1];
            len += Math.sqrt(dX * dX + dY * dY);
        }
        return len;
    }
    
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

    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     * @private
     */
    private function strokeChangeHandler(event:PropertyChangeEvent):void
    {
        if (event.property == "weight")
        {
            _drawPattern.strokeWeight = _stroke.weight;
        }
        if (hasEventListener("change"))
        {
            dispatchEvent(new Event("change"));
        }
    }

}
}
import mx.graphics.IStroke;

class DrawState
{
    public var elementPrepared:Boolean = false;
    public var isDrawing:Boolean = true;
    public var elementIndex:uint = 0;
    public var elementLengthOffset:Number = 0;
}


class DrawPattern
{

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    private var _weight:Number;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  pattern
    //----------------------------------

    private var _pattern:Array;
    private var _outlinedPattern:Array;
    private var _offsetPattern:Array;
    private var _invalidated:Boolean = false;

    public function get pattern():Array
    {
        return _pattern;
    }

    public function set pattern(value:Array):void
    {
        _pattern = value;
        _invalidated = true;
    }
    
    //----------------------------------
    //  strokeWeight
    //----------------------------------
    
    private var _strokeWeight:Number;
    
    public function get strokeWeight():Number
    {
        return _strokeWeight;
    }
    
    public function set strokeWeight(value:Number):void
    {
        _strokeWeight = value;
        _invalidated = true;
    }
    
    //----------------------------------
    //  inverse
    //----------------------------------
    
    private var _inverse:Boolean;
    
    public function get inverse():Boolean
    {
        return _inverse;
    }
    
    public function set inverse(value:Boolean):void
    {
        _inverse = value;
        _invalidated = true;
    }

    //----------------------------------
    //  length
    //----------------------------------

    private var _length:Number;

    public function get length():Number
    {
        return _length;
    }

    //----------------------------------
    //  numElement
    //----------------------------------

    public function get numElements():uint
    {
        return _pattern.length;
    }

    //----------------------------------
    //  gapLength
    //----------------------------------

    private var _gapLength:Number;

    public function get gapLength():Number
    {
        return _gapLength;
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    public function getElementAt(index:uint):Number
    {
        return _offsetPattern[index];
    }

    public function applyGapOffset(offset:Number):void
    {
        const gapRatio:Number = offset / _gapLength;
        var gap:Boolean = false;
        _offsetPattern = _outlinedPattern.concat();
        for (var i:int = 0; i < _offsetPattern.length; i++)
        {
            if (gap)
            {
                _offsetPattern[i] += _offsetPattern[i] * gapRatio;
            }
            gap = !gap;
        }
    }

    public function validate():void
    {
        if (_invalidated)
        {
            _invalidated = false;

            _length = 0;
            _gapLength = 0;

            _outlinedPattern = _pattern.concat()
            var gap:Boolean = !_inverse;
            var value:Number;
            for (var i:int = 0; i < _outlinedPattern.length; i++)
            {
                value = _outlinedPattern[i];

                if (gap)
                {
                    _outlinedPattern[i] = value = value + _strokeWeight - 1;
                    _gapLength += value;
                }
                else
                {
                    _outlinedPattern[i] = value = value > 1 ? value + _strokeWeight : value;
                }
                _length += value;
                gap = !gap;
            }
        }
    }
}

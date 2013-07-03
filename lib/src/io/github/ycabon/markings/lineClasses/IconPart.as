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

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Matrix;

import io.github.ycabon.markings.supportClasses.DrawInfo;
import io.github.ycabon.markings.supportClasses.SegmentsView;
import io.github.ycabon.markings.supportClasses.SpritePool;
import io.github.ycabon.utils.MatrixUtil;

import spark.core.DisplayObjectSharingMode;
import spark.core.IGraphicElement;
import spark.core.IGraphicElementContainer;
import spark.core.ISharedDisplayObject;
import spark.primitives.supportClasses.GraphicElement;

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

[DefaultProperty("graphicElement")]


/**
 *  The IconPart can be used as a part of an AdvancedLineSymbol.
 *  <p>
 *  This part creates and places markers along the line using Spark primitives from the Flex SDK:
 *  </p>
 *  <ul>
 *  <li>
 *  <code>BitmapImage</code> - draws a bitmap data from a source file or source URL.
 *  </li>
 *  <li>
 *  <code>Ellipse</code> - draws an ellipse.
 *  </li>
 *  <li>
 *  <code>Line</code> - draws a line between two points.
 *  </li>
 *  <li>
 *  <code>Path</code> - draws a series of path segments.
 *  </li>
 *  <li>
 *  <code>Rect</code> - draws a rectangle.
 *  </li>
 *  </ul>
 *
 *  <pre>
 *  ...
 *  &lt;mk:AdvancedLineSymbol&gt;
 *      &lt;s:ArrayList&gt;
 *          &lt;mk:IconPart repeat="15"&gt;
 *              &lt;s:Ellipse width="10" height="10"&gt;
 *                  &lt;s:fill&gt;
 *                      &lt;s:SolidColor color="0xFD7F00"/&gt;
 *                  &lt;/s:fill&gt;
 *                  &lt;s:stroke&gt;
 *                      &lt;s:SolidColorStroke color="0xFFD92F" weight="2"/&gt;
 *                  &lt;/s:stroke&gt;
 *              &lt;/s:Ellipse&gt;
 *          &lt;/mk:IconPart&gt;
 *      &lt;/s:ArrayList&gt;
 *  &lt;/mk:AdvancedLineSymbol&gt;
 *  ...
 *  </pre>
 *
 *  @mxml
 *
 *  <p>The <code>&lt;mk:IconPart&gt;</code> tag inherits all the tag attributes
 *  of its superclass, and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;mk:IconPart
 *    <b>Properties</b>
 *    graphicElement="null"
 *    offset="NaN"
 *    repeat="NaN"
 *    rotate="false"
 *  /&gt;
 *  </pre>
 *
 *  @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/spark/primitives/BitmapImage.html spark.primitives.BitmapImage
 *  @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/spark/primitives/Ellipse.html spark.primitives.Ellipse
 *  @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/spark/primitives/Line.html spark.primitives.Line
 *  @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/spark/primitives/Path.html spark.primitives.Path
 *  @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/spark/primitives/Rect.html spark.primitives.Rect
 *
 */
public class IconPart extends Sprite implements ILinePart, IGraphicElementContainer
{

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     * Constructor.
     *
     * @param graphicElement
     * @param offset
     * @param percentOffset
     * @param repeat
     * @param percentRepeat
     * @param rotate
     */
    public function IconPart(graphicElement:GraphicElement = null,
                             offset:Number = NaN,
                             percentOffset:Number = NaN,
                             repeat:Number = NaN,
                             percentRepeat:Number = NaN,
                             rotate:Boolean = false)
    {
        this.graphicElement = graphicElement;
        this.offset = offset;
        this.percentOffset = percentOffset;
        this.repeat = repeat;
        this.percentRepeat = percentRepeat;
        this.rotate = rotate;
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    private var _sizeChanged:Boolean;

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
    //  graphicElement
    //----------------------------------

    private var _graphicElement:GraphicElement;

    [Bindable(event="change")]

    /**
     *  The element that will be repeated along the line.
     *  The element must not have filters, blend mode, transformations defined to be properly render.
     * 
     *  @default null
     * 
     *  @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/spark/primitives/BitmapImage.html spark.primitives.BitmapImage
     *  @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/spark/primitives/Ellipse.html spark.primitives.Ellipse
     *  @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/spark/primitives/Line.html spark.primitives.Line
     *  @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/spark/primitives/Path.html spark.primitives.Path
     *  @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/spark/primitives/Rect.html spark.primitives.Rect
     */
    public function get graphicElement():GraphicElement
    {
        return _graphicElement;
    }

    /**
     * @private
     */
    public function set graphicElement(value:GraphicElement):void
    {
        if (_graphicElement !== value)
        {
            if (_graphicElement)
            {
                _graphicElement.parentChanged(null);
            }
            _graphicElement = value;
            if (_graphicElement)
            {
                _graphicElement.parentChanged(this);

                _graphicElement.alwaysCreateDisplayObject = false;
                _graphicElement.validateProperties();
                _graphicElement.validateSize();
            }
            dispatchChangeEvent();
        }
    }

    //----------------------------------
    //  _rotate
    //----------------------------------

    private var _rotate:Boolean = false;

    [Bindable(event="change")]

    /**
     *  Whether or not the graphic element is rotated to make in look like it follows it.
     *  Setting this flag to <code>true</code> has some impact on performances if a lot of objects are render.
     * 
     *  @default false 
     */
    public function get rotate():Boolean
    {
        return _rotate;
    }

    /**
     * @private
     */
    public function set rotate(value:Boolean):void
    {
        if (_rotate !== value)
        {
            _rotate = value;
            dispatchChangeEvent();
        }
    }


    //----------------------------------
    //  offset
    //----------------------------------

    private var _offset:Number = NaN;

    [Bindable(event="change")]
    [PercentProxy("percentOffset")]

    /**
     *  Number that specifies the distance from the start of the Polyline.
     *  One typical use of this property is for giving the impression of movement.
     * 
     *  <p>Note: You can specify a percentage value in the MXML
     *  <code>offset</code> attribute, such as <code>offset="100%"</code>,
     *  but you cannot use a percentage value in the <code>offset</code>
     *  property in ActionScript.
     *  Use the <code>percentOffset</code> property instead.</p>
     * 
     *  <p>Setting the <code>percentOffset</code> property
     *  resets this property to NaN.</p>
     *  
     *  @default NaN
     * 
     *  @see #percentOffset
     */
    public function get offset():Number
    {
        return _offset;
    }

    /**
     * @private
     */
    public function set offset(value:Number):void
    {
        if (_offset !== value)
        {
            _offset = value == 0 ? NaN : value;
            _percentOffset = NaN;
            dispatchChangeEvent();
        }
    }

    //----------------------------------
    //  percentOffset
    //----------------------------------

    private var _percentOffset:Number = NaN;

    [Bindable(event="change")]
    
    /**
     *  Number that specifies the distance from the start of the Polyline.
     *  One typical use of this property is for giving the impression of movement.
     * 
     *  <p>Setting the <code>offset</code> property
     *  resets this property to NaN.</p>
     *  
     *  @default NaN
     * 
     *  @see #offset
     */
    public function get percentOffset():Number
    {
        return _percentOffset;
    }

    /**
     * @private
     */
    public function set percentOffset(value:Number):void
    {
        if (_percentOffset !== value)
        {
            _percentOffset = value == 0 ? NaN : value;
            _offset = NaN;
            dispatchChangeEvent();
        }
    }

    //----------------------------------
    //  repeat
    //----------------------------------

    private var _repeat:Number = NaN;

    [Bindable(event="change")]
    [PercentProxy("percentRepeat")]
    
    /**
     *  Number that specifies the distance between to repetitions of the <code>graphicElement</code>.
     *  If the value is <code>NaN</code>, the element is not repeated.
     * 
     *  <p>Note: You can specify a percentage value in the MXML
     *  <code>repeat</code> attribute, such as <code>repeat="100%"</code>,
     *  but you cannot use a percentage value in the <code>repeat</code>
     *  property in ActionScript.
     *  Use the <code>percentRepeat</code> property instead.</p>
     * 
     *  <p>Setting the <code>percentRepeat</code> property
     *  resets this property to NaN.</p>
     *  
     *  @default NaN
     * 
     *  @see #percentRepeat
     */
    public function get repeat():Number
    {
        return _repeat;
    }

    /**
     * @private
     */
    public function set repeat(value:Number):void
    {
        if (_repeat !== value)
        {
            _repeat = value == 0 ? NaN : value;
            _percentRepeat = NaN;
            dispatchChangeEvent();
        }
    }

    //----------------------------------
    //  percentRepeat
    //----------------------------------

    private var _percentRepeat:Number = NaN;

    [Bindable(event="change")]
    
    /**
     *  Number that specifies the distance between to repetitions of the <code>graphicElement</code>.
     *  If the value is <code>NaN</code>, the element is not repeated.
     * 
     *  <p>Setting the <code>repeat</code> property
     *  resets this property to NaN.</p>
     *  
     *  @default NaN
     * 
     *  @see #repeat
     */
    public function get percentRepeat():Number
    {
        return _percentRepeat;
    }

    /**
     * @private
     */
    public function set percentRepeat(value:Number):void
    {
        if (_percentRepeat !== value)
        {
            _percentRepeat = value == 0 ? NaN : value;
            _repeat = NaN;
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
        if (!graphicElement)
        {
            return;
        }
    }

    /**
     * @private
     */
    public function draw(sprite:Sprite, attributes:Object, polylineView:SegmentsView, pool:SpritePool):void
    {
        if (!graphicElement)
        {
            return;
        }

        if (!polylineView.clippedLength)
        {
            if (rotate)
            {
                pool.getSprites(this, 0);
            }
            return;
        }

        var elementXOffset:Number = graphicElement.horizontalCenter !== null ? Number(graphicElement.horizontalCenter) : NaN;
        var elementYOffset:Number = graphicElement.verticalCenter !== null ? Number(graphicElement.verticalCenter) : NaN;
        _graphicElement.validateProperties();
        _graphicElement.validateSize();
        _graphicElement.setLayoutBoundsSize(_graphicElement.getPreferredBoundsWidth(),
                                            _graphicElement.getPreferredBoundsHeight(),
                                            false);

        var drawInfo:DrawInfo;
        var drawInfos:Vector.<DrawInfo> = polylineView.getDrawInfos(this.offset,
                                                                    this.percentOffset,
                                                                    this.repeat,
                                                                    this.percentRepeat);
        var i:int = 0, n:int = drawInfos.length;

        if (rotate)
        {
            if (isNaN(elementXOffset))
            {
                elementXOffset = _graphicElement.measuredWidth * .5 || _graphicElement.getPreferredBoundsWidth() * .5;
            }
            if (isNaN(elementYOffset))
            {
                elementYOffset = _graphicElement.measuredHeight * .5 || _graphicElement.getPreferredBoundsHeight() * .5;
            }

            var m:Matrix = new Matrix();
            var sprites:Vector.<ISharedDisplayObject> = pool.getSprites(this, n);
            var sharedDisplayObject:ISharedDisplayObject;
            _graphicElement.displayObjectSharingMode = DisplayObjectSharingMode.OWNS_UNSHARED_OBJECT;

            for (; i < n; i++)
            {
                drawInfo = drawInfos[i];
                sharedDisplayObject = sprites[i];
                (sharedDisplayObject as DisplayObject).transform.matrix = m;

                if (_sizeChanged || sharedDisplayObject.redrawRequested)
                {
                    // Handle if the graphicElement doesn't support shared display object.
                    if (!_graphicElement.setSharedDisplayObject(sharedDisplayObject as DisplayObject))
                    {
                        pool.disposeSprites(this);
                        throw new Error("Filters, blend modes and transformations are not supported on Spark Primitives by the Markings library");
                        return;
                    }
                    _graphicElement.validateProperties();
                    _graphicElement.validateDisplayList();
                    sharedDisplayObject.redrawRequested = false;
                }
                (sharedDisplayObject as Sprite).x = drawInfo.x - elementXOffset;
                (sharedDisplayObject as Sprite).y = drawInfo.y - elementYOffset;
                MatrixUtil.rotate(sharedDisplayObject as DisplayObject, drawInfo.angle, elementXOffset, elementYOffset);
            }
        }
        else
        {
            pool.disposeSprites(this);

            if (isNaN(elementXOffset))
            {
                elementXOffset = _graphicElement.getPreferredBoundsWidth() * .5;
            }
            if (isNaN(elementYOffset))
            {
                elementYOffset = _graphicElement.getPreferredBoundsHeight() * .5;
            }

            _graphicElement.displayObjectSharingMode = DisplayObjectSharingMode.USES_SHARED_OBJECT;
            _graphicElement.setSharedDisplayObject(sprite);
            _graphicElement.validateProperties();
            for (; i < n; i++)
            {
                drawInfo = drawInfos[i];
                graphicElement.setLayoutBoundsPosition(drawInfo.x - elementXOffset, drawInfo.y - elementYOffset, false);
                graphicElement.validateDisplayList();
            }
        }
        _sizeChanged = false;
    }

    /**
     * @private
     */
    public function endDraw(sprite:Sprite):void
    {
        if (!graphicElement)
        {
            return;
        }
    }


    //--------------------------------------------------------------------------
    //
    //  Methods: IGraphicElementContainer
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    public function invalidateGraphicElementSharing(element:IGraphicElement):void
    {
    }

    /**
     * @private
     */
    public function invalidateGraphicElementProperties(element:IGraphicElement):void
    {
    }

    /**
     * @private
     */
    public function invalidateGraphicElementSize(element:IGraphicElement):void
    {
        _sizeChanged = true;
        dispatchChangeEvent();
    }

    /**
     * @private
     */
    public function invalidateGraphicElementDisplayList(element:IGraphicElement):void
    {
    }


    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    private function dispatchChangeEvent():void
    {
        if (hasEventListener("change"))
        {
            dispatchEvent(new Event("change"));
        }
    }

}
}












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

package io.github.ycabon.markings
{

import com.esri.ags.Graphic;
import com.esri.ags.Map;
import com.esri.ags.geometry.Extent;
import com.esri.ags.geometry.Geometry;
import com.esri.ags.geometry.Polyline;
import com.esri.ags.layers.Layer;
import com.esri.ags.symbols.LineSymbol;
import com.esri.ags.symbols.SimpleLineSymbol;
import com.esri.ags.utils.IJSONSupport;

import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import flash.utils.Dictionary;

import io.github.ycabon.markings.lineClasses.ILinePart;
import io.github.ycabon.markings.supportClasses.SegmentsView;
import io.github.ycabon.markings.supportClasses.SpritePool;
import io.github.ycabon.markings.supportClasses.SymbolValidationManager;

import mx.collections.ArrayList;
import mx.collections.IList;
import mx.core.IMXMLObject;
import mx.core.UIComponent;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;

//--------------------------------------
//  Events
//--------------------------------------

[DefaultProperty("lineParts")]

/**
 *  The AdvancedLineSymbol is a symbol used to draw Polyline Graphics from a GraphicsLayer.
 *  It delegates the drawing to its lineParts.
 *
 *  Printing appearence is defined by the <code>fallback</code> symbol property.
 * 
 *  <pre>
 *  ...
 *  &lt;mk:AdvancedLineSymbol&gt;
 *      &lt;s:ArrayList&gt;
 *          &lt;mk:SolidLinePart&gt;
 *              &lt;s:SolidColorStroke alpha="0.25"
 *                                  color="0x000000"
 *                                  weight="6"/&gt;
 *          &lt;/mk:SolidLinePart&gt;
 *          &lt;mk:SolidLinePart&gt;
 *              &lt;s:SolidColorStroke color="0xBB0000" weight="5"/&gt;
 *          &lt;/mk:SolidLinePart&gt;
 *          &lt;mk:SolidLinePart&gt;
 *              &lt;s:SolidColorStroke color="0xCC0000" weight="4"/&gt;
 *          &lt;/mk:SolidLinePart&gt;
 *          &lt;mk:SolidLinePart&gt;
 *              &lt;s:SolidColorStroke color="0xDD0000" weight="3"/&gt;
 *          &lt;/mk:SolidLinePart&gt;
 *          &lt;mk:SolidLinePart&gt;
 *              &lt;s:SolidColorStroke color="0xEE0000" weight="2"/&gt;
 *          &lt;/mk:SolidLinePart&gt;
 *          &lt;mk:SolidLinePart&gt;
 *              &lt;s:SolidColorStroke color="0xFF0000" weight="1"/&gt;
 *          &lt;/mk:SolidLinePart&gt;
 *      &lt;/s:ArrayList&gt;
 *  &lt;/mk:AdvancedLineSymbol&gt;
 *  ...
 *  </pre>
 *
 *  @mxml
 *
 *  <p>The <code>&lt;mk:AdvancedLineSymbol&gt;</code> tag inherits all the tag attributes
 *  of its superclass, and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;mk:AdvancedLineSymbol
 *    <b>Properties</b>
 *    lineParts="null"
 *    fallback="null"
 *  /&gt;
 *  </pre>
 *
 *  @see io.github.ycabon.markings.lineClasses.ILinePart
 *  @see io.github.ycabon.markings.lineClasses.SolidLinePart
 *  @see io.github.ycabon.markings.lineClasses.DashedLinePart
 *  @see io.github.ycabon.markings.lineClasses.IconPart
 * 
 *  @see http://developers.arcgis.com/en/flex/api-reference/com/esri/ags/symbols/LineSymbol.html com.esri.ags.symbols.LineSymbol
 * 
 */
public class AdvancedLineSymbol extends LineSymbol implements IMXMLObject, IJSONSupport
{

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     * Constructor.
     *
     * @param lineParts A collection of line parts.
     * The default value is null.
     * 
     * @param fallback A SimpleLineSymbol for printing support.
     * The default value is null.
     */
    public function AdvancedLineSymbol(lineParts:IList = null, fallback:SimpleLineSymbol = null)
    {
        super();
        this.lineParts = lineParts;
        this.fallback = fallback;
    }


    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    private var _graphics:Vector.<Graphic> = new Vector.<Graphic>();

    private var _graphicsViews:Dictionary = new Dictionary(true);

    private var _graphicsPools:Dictionary = new Dictionary(true);

    private var _validationManager:SymbolValidationManager;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  lineParts
    //----------------------------------

    private var _lineParts:IList;

    [Inspectable(arrayType="io.github.ycabon.markings.lineClasses.ILinePart")]
    [Bindable(event="change")]

    /**
     *  A collection of line parts objects in charge of drawing the Polyline on screen.
     * 
     *  <p>
     *  A line part object must implement the <code>io.github.ycabon.markings.lineClasses.ILinePart</code> interface.
     *  Three implementations are provided out of the box:
     *  </p>
     *  <ul>
     *  <li>
     *  <code>SolidLinePart</code> - draws a solid style line.
     *  </li> 
     *  <li>
     *  <code>DashedLinePart</code> - draws a dashed style line.
     *  </li>
     *  <li>
     *  <code>IconPart</code> - draws markers along the line using spark primitives.
     *  </li>
     *  </ul>
     * 
     *  @see io.github.ycabon.markings.lineClasses.ILinePart
     *  @see io.github.ycabon.markings.lineClasses.SolidLinePart
     *  @see io.github.ycabon.markings.lineClasses.DashedLinePart
     *  @see io.github.ycabon.markings.lineClasses.IconPart
     */
    public function get lineParts():IList
    {
        if (!_lineParts)
        {
            _lineParts = new ArrayList();
            _lineParts.addEventListener(CollectionEvent.COLLECTION_CHANGE, linePartsCollectionChangeHandler);
        }
        return _lineParts;
    }

    /**
     * @private
     */
    public function set lineParts(value:IList):void
    {
        if (_lineParts !== value)
        {
            var i:int;
            var linePart:ILinePart;

            if (_lineParts)
            {
                for (i = 0; i < _lineParts.length; i++)
                {
                    linePart = lineParts.getItemAt(i) as ILinePart;
                    linePart.depth = -1;
                    linePart.removeEventListener(Event.CHANGE, partChangedHandler);
                }
            }
            
            _lineParts = value;
            dispatchEvent(new Event("change"));

            if (_lineParts)
            {
                _lineParts.addEventListener(CollectionEvent.COLLECTION_CHANGE, linePartsCollectionChangeHandler);
                for (i = 0; i < _lineParts.length; i++)
                {
                    linePart = lineParts.getItemAt(i) as ILinePart;
                    linePart.depth = i;
                    linePart.addEventListener(Event.CHANGE, partChangedHandler);
                }
            }
        }
    }

    //----------------------------------
    //  fallback
    //----------------------------------

    /**
     * The line symbol sent to the server when using the print task.
     * 
     *  <pre>
     *  ...
     *  &lt;mk:AdvancedLineSymbol id="lineSymbolRed"&gt;
     *      &lt;mk:fallback&gt;
     *          &lt;esri:SimpleLineSymbol color="0xFF0000" style="solid" width="4" /&gt;
     *      &lt;/mk:fallback&gt;
     *      &lt;s:ArrayList&gt;
     *          &lt;mk:SolidLinePart&gt;
     *              &lt;s:SolidColorStroke color="0xCC0000" weight="4"/&gt;
     *          &lt;/mk:SolidLinePart&gt;
     *      &lt;/s:ArrayList&gt;
     *  &lt;/mk:AdvancedLineSymbol&gt;
     *  ...
     *  </pre>
     *
     * @see http://developers.arcgis.com/en/flex/api-reference/com/esri/ags/symbols/SimpleLineSymbol.html com.esri.ags.symbols.SimpleLineSymbol
     */
    public var fallback:SimpleLineSymbol;

    //--------------------------------------------------------------------------
    //
    //  Overridden Methods : Symbol
    //
    //--------------------------------------------------------------------------
    
    /**
     * @private
     */
    override public function initialize(sprite:Sprite, geometry:Geometry, attributes:Object, map:Map):void
    {
        initialized(null, null);
        var graphic:Graphic = sprite as Graphic;
        if (_graphics.lastIndexOf(graphic) == -1)
        {
            _graphics.push(graphic);
            _graphicsPools[graphic] = new SpritePool(graphic);
            if (map.wrapAround180)
            {
                _graphicsViews[graphic] = new Vector.<SegmentsView>();
            }
            else
            {
                _graphicsViews[graphic] = new Vector.<SegmentsView>(1, true);
            }
        }
    }
    
    /**
     * @private
     */
    override public function draw(sprite:Sprite, geometry:Geometry, attributes:Object, map:Map):void
    {
        var graphic:Graphic = sprite as Graphic;
        graphic.move(0, 0);

        var extentExpanded:Extent = map.extent.expand(3);

        if (!lineParts)
        {
            return;
        }

        if (geometry is Polyline)
        {
            var view:SegmentsView;
            var mapExtent:Extent = extentExpanded;
            var screenPoints:Vector.<Vector.<Point>>;

            if (!map.wrapAround180)
            {
                if (_graphicsViews[graphic].length == 0 || !_graphicsViews[graphic][0])
                {
                    _graphicsViews[graphic][0] = new SegmentsView();
                }
                view = _graphicsViews[graphic][0];
                view.initialize((geometry as Polyline).paths, map);
                process(graphic);
            }
            else
            {
                var geometries:Vector.<Geometry> = getWrapAroundGeometries(map, geometry);
                var i:int,
                    len:int = geometries.length;
                if (_graphicsViews[graphic].length < len)
                {
                    for (i = _graphicsViews[graphic].length; i < len; i++)
                    {
                        _graphicsViews[graphic][i] = new SegmentsView();
                    }
                }
                else if (_graphicsViews[graphic].length > len)
                {
                    _graphicsViews[graphic].splice(0, _graphicsViews[graphic].length - len);
                        // Each projected segment is no processed by the line parts
                    /*for (k = 0, numParts = lineParts.length; k < numParts; k++)
                    {
                        linePart = lineParts.getItemAt(k) as ILinePart;
                        (graphicsPools[graphic] as SpritePool).getSprites(linePart, 0);
                    }*/
                }

                for (i = 0; i < len; i++)
                {
                    view = _graphicsViews[graphic][i];
                    view.initialize((geometries[i] as Polyline).paths, map);
                }

                process(graphic);
            }
        }
    }
    
    /**
     * @private
     */
    override public function clear(sprite:Sprite):void
    {
        sprite.graphics.clear();
    }

    /**
     * @private
     */
    override public function destroy(sprite:Sprite):void
    {
        clear(sprite);
        _graphics.splice(_graphics.lastIndexOf(sprite), 1);
        (_graphicsPools[sprite] as SpritePool).destroy();
        _graphicsPools[sprite] = null;
        delete _graphicsPools[sprite];
        sprite.x = sprite.y = 0;
    }

    /**
     * @private
     * TODO: Not implemented
     */
    override public function createSwatch(width:Number = 50,
                                          height:Number = 50,
                                          shape:String = null):UIComponent
    {
        var swatch:UIComponent = new UIComponent();
        swatch.width = width;
        swatch.height = height;
        swatch.graphics.beginFill(0xFF0000);
        swatch.graphics.drawRect(0, 0, width, height);

        if (lineParts)
        {
            var view:SegmentsView = new SegmentsView();
            // view.initialize();
            var spritePool:SpritePool = new SpritePool(swatch);
            var k:int,
                numParts:int,
                linePart:ILinePart;
            for (k = 0, numParts = lineParts.length; k < numParts; k++)
            {
                linePart = lineParts.getItemAt(k) as ILinePart;
                linePart.beginDraw(swatch);
                linePart.draw(swatch, null, view, spritePool);
                linePart.endDraw(swatch);
            }

            spritePool.destroy();
        }

        return swatch;
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    private var _initialized:Boolean;
    
    /**
     * @private
     */
    public function initialized(document:Object, id:String):void
    {
        if (!_initialized)
        {
            _initialized = true;
            _validationManager = SymbolValidationManager.getInstance();
        }
    }

    /**
     * @private
     *
     * Printing support.
     */
    public function toJSON(key:String = null):Object
    {
        if (fallback)
        {
            return fallback.toJSON(key);
        }
        else
        {
            return new SimpleLineSymbol().toJSON(key);
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Public Methods
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     *
     * Function called by the SymbolValidationManager.
     * Usually you don't call this method directly.
     * It's used to redraw all the graphics when the symbol changed.
     */
    public function validate():void
    {
        var graphic:Graphic;

        // Cleaning the sprite
        for (var i:int = 0, numGraphics:int = _graphics.length; i < numGraphics; i++)
        {
            graphic = _graphics[i];
            clear(graphic)
            process(graphic);
        }

    }

    private function process(graphic:Graphic):void
    {
        var j:int,
            k:int,
            numViews:int,
            views:Vector.<SegmentsView> = _graphicsViews[graphic],
            pool:SpritePool = _graphicsPools[graphic],
            view:SegmentsView,
            numParts:int,
            linePart:ILinePart;

        const lineParts:IList = this.lineParts;

        pool.initialize();
        for (j = 0, numViews = views.length; j < numViews; j++)
        {
            view = views[j];
            if (view.visible)
            {
                // Each projected segment is no processed by the line parts
                for (k = 0, numParts = lineParts.length; k < numParts; k++)
                {
                    linePart = lineParts.getItemAt(k) as ILinePart;
                    linePart.beginDraw(graphic);
                    linePart.draw(graphic, graphic.attributes, view, pool);
                    linePart.endDraw(graphic);
                }
            }
        }
        pool.commit();
    }


    /**
     * @private
     *
     * Experimental method.
     * Blends all the line parts together.
     * Lose of interaction with Graphics.
     */
    private function process_blendLayer(layer:Layer):void
    {
    /*var i:int,
        j:int,
        k:int,
        numGraphics:int = graphics.length,
        pool:SpritePool,
        graphic:Graphic,
        numParts:int,
        linePart:ILinePart,
        numViews:int,
        views:Vector.<PolylineView>,
        view:PolylineView;

    // Each projected segment is no processed by the line parts
    for (k = 0, numParts = _lineParts.length; k < numParts; k++)
    {
        linePart = _lineParts.getItemAt(k) as ILinePart;
        if (linePart.canDrawOnLayer)
        {
            linePart.begin(layer);
            for (i = 0; i < numGraphics; i++)
            {
                graphic = graphics[i];
                pool = graphicsPools[graphic];
                views = graphicsViews[graphic];
                for (j = 0, numViews = views.length; j < numViews; j++)
                {
                    view = views[j];
                    if (view.visible)
                    {
                        linePart.draw(layer, graphic.attributes, view, pool);
                    }
                }
            }
            linePart.end(layer);
        }
        else
        {
            for (i = 0, numGraphics = graphics.length; i < graphics.length; i++)
            {
                graphic = graphics[i];
                pool = graphicsPools[graphic];
                views = graphicsViews[graphic];
                for (j = 0, numViews = views.length; j < numViews; j++)
                {
                    view = views[j];
                    if (view.visible)
                    {
                        linePart.begin(graphic);
                        linePart.draw(graphic.getChildAt(0) as Sprite, graphic.attributes, view, pool);
                        linePart.end(graphic);
                    }
                }
            }
        }
    }*/
    }

    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //--------------------------------------------------------------------------

    private function linePartsCollectionChangeHandler(event:CollectionEvent):void
    {
        var kind:String = event.kind;
        var linePart:ILinePart,
            i:int,
            n:int = event.items.length;

        if (kind === CollectionEventKind.ADD)
        {
            for (i = 0; i < n; i++)
            {
                linePart = event.items[i];
                linePart.depth = event.location + i;
                linePart.addEventListener(Event.CHANGE, partChangedHandler);
            }
            invalidate();
        }
        else if (kind === CollectionEventKind.REMOVE)
        {
            for (i = 0; i < n; i++)
            {
                linePart = event.items[i];
                linePart.removeEventListener(Event.CHANGE, partChangedHandler);

                var graphic:Graphic;

                // Cleaning the sprite
                for (var j:int = 0, numGraphics:int = _graphics.length; j < numGraphics; j++)
                {
                    graphic = _graphics[j];
                    var pool:SpritePool = _graphicsPools[graphic];
                    pool.disposeSprites(linePart);
                }

                linePart.depth = -1;
            }
            invalidate();
        }
        else if (kind === CollectionEventKind.MOVE)
        {
            for (i = 0; i < n; i++)
            {
                linePart = event.items[i];
                linePart.depth = event.location + i;
            }
            invalidate();
        }
    }

    private function partChangedHandler(event:Event):void
    {
        invalidate();
    }

    private function invalidate():void
    {
        if (_validationManager)
        {
            _validationManager.invalidate(this);
        }
    }
}
}


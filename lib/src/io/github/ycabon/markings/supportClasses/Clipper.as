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

package io.github.ycabon.markings.supportClasses
{

import flash.geom.Rectangle;

[ExcludeClass]

public class Clipper
{
    //--------------------------------------------------------------------------
    //
    //  Class Constants
    //
    //--------------------------------------------------------------------------

    private static const INSIDE:uint = 0x000000; // 0000
    private static const LEFT:uint = 0x000001; // 0001
    private static const RIGHT:uint = 0x000010; // 0010
    private static const BOTTOM:uint = 0x000100; // 0100
    private static const TOP:uint = 0x001000; // 1000


    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    private var xmin:Number;
    private var xmax:Number;
    private var ymin:Number;
    private var ymax:Number;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  clippingRectangle
    //----------------------------------

    private var _clippingRectangle:Rectangle;

    /**
     * Clipping area.
     */
    public function get clippingRectangle():Rectangle
    {
        return _clippingRectangle;
    }

    /**
     * @private
     */
    public function set clippingRectangle(value:Rectangle):void
    {
        _clippingRectangle = value;
        if (_clippingRectangle)
        {
            xmin = _clippingRectangle.x;
            xmax = _clippingRectangle.right;
            ymin = _clippingRectangle.y;
            ymax = _clippingRectangle.bottom;
        }
    }


    //--------------------------------------------------------------------------
    //
    //  Public Methods
    //
    //--------------------------------------------------------------------------

    /**
     * Clip a path of format [x1, y1, x2, y2, x3, y3].
     * 
     * @return a vector of segments of format [x1, y1, x2, y2, x2, y2, x3, y3]
     */
    public function clipPath(path:Vector.<Number>):Vector.<Number>
    {
        var result:Vector.<Number> = new Vector.<Number>();
        // We need at least one segment (2 points == 4 coords)
        if (path.length < 4)
        {
            return result;
        }

        for (var i:int = 0, len:int = path.length - 4; i <= len; )
        {
            clipSegment(path[i + 0], path[i + 1], path[i + 2], path[i + 3], result);
            i += 4;
        }

        return result;
    }


    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     * Cohen–Sutherland clipping algorithm clips a line from
     * P0 = (x0, y0) to P1 = (x1, y1) against a rectangle with
     * diagonal from (xmin, ymin) to (xmax, ymax).
     * 
     * http://en.wikipedia.org/wiki/Cohen%E2%80%93Sutherland_algorithm
     *
     * The result is added to the <code>result</code> vector.
     */
    private function clipSegment(x0:Number, y0:Number, x1:Number, y1:Number, result:Vector.<Number>):void
    {
        var outcode0:uint = computeOutCode(x0, y0);
        var outcode1:uint = computeOutCode(x1, y1);
        var accept:Boolean = false;

        while (true)
        {
            if (!(outcode0 | outcode1))
            {
                // Bitwise OR is 0. Trivially accept and get out of loop
                accept = true;
                break;
            }
            else if (outcode0 & outcode1)
            {
                // Bitwise AND is not 0. Trivially reject and get out of loop
                break;
            }
            else
            {
                // failed both tests, so calculate the line segment to clip
                // from an outside point to an intersection with clip edge
                var x:Number, y:Number;

                // At least one endpoint is outside the clip rectangle; pick it.
                var outcodeOut:uint = outcode0 ? outcode0 : outcode1;

                // Now find the intersection point;
                // use formulas y = y0 + slope * (x - x0), x = x0 + (1 / slope) * (y - y0)
                if (outcodeOut & TOP)
                {
                    // point is above the clip rectangle
                    x = x0 + (x1 - x0) * (ymin - y0) / (y1 - y0);
                    y = ymin;
                }
                else if (outcodeOut & BOTTOM)
                {
                    // point is below the clip rectangle
                    x = x0 + (x1 - x0) * (ymax - y0) / (y1 - y0);
                    y = ymax;
                }
                else if (outcodeOut & RIGHT)
                {
                    // point is to the right of clip rectangle
                    y = y0 + (y1 - y0) * (xmax - x0) / (x1 - x0);
                    x = xmax;
                }
                else if (outcodeOut & LEFT)
                {
                    // point is to the left of clip rectangle
                    y = y0 + (y1 - y0) * (xmin - x0) / (x1 - x0);
                    x = xmin;
                }

                // Now we move outside point to intersection point to clip
                // and get ready for next pass.
                if (outcodeOut == outcode0)
                {
                    x0 = x;
                    y0 = y;
                    outcode0 = computeOutCode(x0, y0);
                }
                else
                {
                    x1 = x;
                    y1 = y;
                    outcode1 = computeOutCode(x1, y1);
                }
            }
        }
        if (accept)
        {
            result.push(x0, y0, x1, y1);
        }
    }

    /**
     * Compute the bit code for a point (x, y) using the clip rectangle
     * bounded diagonally by (xmin, ymin), and (xmax, ymax).
     */
    private function computeOutCode(x:Number, y:Number):uint
    {
        var code:uint = INSIDE; // initialised as being inside of clip window

        if (x < xmin) // to the left of clip window
        {
            code |= LEFT;
        }
        else if (x > xmax) // to the right of clip window
        {
            code |= RIGHT;
        }
        if (y < ymin) // below the clip window
        {
            code |= TOP;
        }
        else if (y > ymax) // above the clip window
        {
            code |= BOTTOM;
        }
        
        return code;
    }

}
}



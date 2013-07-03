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

import com.esri.ags.Map;
import com.esri.ags.MapState;
import com.esri.ags.esri_internal;
import com.esri.ags.geometry.Extent;
import com.esri.ags.geometry.MapPoint;
import com.esri.ags.geometry.Polyline;

import flash.display.GraphicsPath;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.utils.ObjectUtil;

[ExcludeClass]

public class SegmentsView
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    private static var clipper:Clipper = new Clipper();

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    private var _PositionHelper:PositionHelper = new PositionHelper();

    private var _clippedPositionHelper:PositionHelper = new PositionHelper();

    private var _state:MapState;

    private var _clippingRectangle:Rectangle;

    private var _lastScale:Number;

    private var _pathsExtent:Extent = new Extent;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  visible
    //----------------------------------

    private var _visible:Boolean = true;

    public function get visible():Boolean
    {
        return _visible;
    }

    //----------------------------------
    //  paths
    //----------------------------------

    private var _paths:Array;

    public function get paths():Array
    {
        return _paths;
    }

    //----------------------------------
    //  projectedPaths
    //----------------------------------

    private var _projectedPaths:Vector.<Vector.<Number>>;

    /**
     * Paths' points of the Polyline projected on screen.
     */
    public function get projectedPaths():Vector.<Vector.<Number>>
    {
        return _projectedPaths;
    }

    //----------------------------------
    //  segments
    //----------------------------------

    private var _segments:Vector.<Vector.<Number>>;

    /**
     * Clipped view of the projected paths.
     */
    public function get segments():Vector.<Vector.<Number>>
    {
        return _segments;
    }

    //----------------------------------
    //  totalLength
    //----------------------------------

    /**
     * The length in pixel of the Polyline projected.
     */
    public function get totalLength():Number
    {
        return _PositionHelper.totalLength;
    }

    //----------------------------------
    //  clippedLength
    //----------------------------------

    /**
     * The length in pixel of the Polyline projected, clipped on the screen.
     */
    public function get clippedLength():Number
    {
        return _clippedPositionHelper.totalLength;
    }

    //----------------------------------
    //  pathLengths
    //----------------------------------

    //private var _pathLengths:Vector.<Number>;

    /**
     * The length in pixel of each path of the Polyline.
     */
    /*public function get pathLengths():Vector.<Number>
    {
        return _pathLengths;
    }*/

    //----------------------------------
    //  graphicsPath
    //----------------------------------

    private var _graphicsPath:GraphicsPath;

    public function get graphicsPath():GraphicsPath
    {
        return _graphicsPath;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    /**
     * Project and Clip a Polyline on the Map.
     *
     * @param polyline The input Polyline.
     * @param map The Map containing the Polyline.
     */
    public function initialize(paths:Array, map:Map):void
    {
        _state = map.esri_internal::viewport.previousState;
        var extent:Extent = _state.rotatedExtent;

        // check if reprojecting the polyline is necessary.
        //  - the polyline was not visible.
        //  - the map scale has changed.
        //  - the polyline has changed.
        var reproject:Boolean = (_paths == null) || (_lastScale != map.scale) || !_visible;
        if (!reproject && _paths && paths)
        {
            reproject = !equals(_paths, paths);
        }

        if (reproject)
        {
            _paths = ObjectUtil.copy(paths) as Array;

            var xmin:Number = Number.POSITIVE_INFINITY,
                ymin:Number = Number.POSITIVE_INFINITY,
                xmax:Number = Number.NEGATIVE_INFINITY,
                ymax:Number = Number.NEGATIVE_INFINITY;

            var i:int, j:int, p:Array, mp:MapPoint;
            for (i = _paths ? _paths.length - 1 : -1; i >= 0; i--)
            {
                p = _paths[i];
                for (j = p.length - 1; j >= 0; j--)
                {
                    mp = p[j];
                    xmin = Math.min(xmin, mp.x);
                    ymin = Math.min(ymin, mp.y);
                    xmax = Math.max(xmax, mp.x);
                    ymax = Math.max(ymax, mp.y);
                }
            }

            _pathsExtent.update(xmin, ymin, xmax, ymax);
        }

        _visible = true;
        if (!_paths || _paths.length == 0 || !_pathsExtent.intersects(extent))
        {
            _visible = false;
            return;
        }

        if (reproject)
        {
            _lastScale = map.scale;
            _projectedPaths = project(_paths, _state);
            _PositionHelper.initialize(_projectedPaths);
        }

        _clippingRectangle = _state.scrollRect.clone();
        _clippingRectangle.inflate(200, 200);
        _segments = clip(_projectedPaths, _clippingRectangle);
        _clippedPositionHelper.initialize(_segments);
        _graphicsPath = createGraphicsPath(_segments);
    }

    /*private function inflate(_projectedPaths:Vector.<Vector.<Number>>):Vector.<Vector.<Number>>
    {
        var result:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>(_projectedPaths.length, true);
        return _projectedPaths;
    }*/

    private function equals(paths1:Array, paths2:Array):Boolean
    {
        if (paths1.length != paths2.length)
        {
            return false;
        }

        var path1:Array;
        var path2:Array;
        for (var i:int = paths1 ? paths1.length - 1 : -1; i >= 0; i--)
        {
            path1 = paths1[i];
            path2 = paths2[i];
            if ((path1 == null && path2 != null) || (path1 != null && path2 == null))
            {
                return false;
            }
            if (path1 && path2)
            {
                if (path1.length != path2.length)
                {
                    return false;
                }
                for (var j:int = path1.length - 1; j >= 0; j--)
                {
                    if (path1[j].x != path2[j].x || path1[j].y != path2[j].y)
                    {
                        return false;
                    }
                }
            }
        }

        return true;
    }

    public function getDrawInfos(offset:Number, percentOffset:Number, repeat:Number, percentRepeat:Number /* percentStart ... */):Vector.<DrawInfo>
    {
        var result:Vector.<DrawInfo> = new Vector.<DrawInfo>();

        var explicitOffset:Number = isNaN(offset) ? percentOffset * totalLength * 0.01 : offset;
        var explicitRepeat:Number = isNaN(repeat) ? percentRepeat * totalLength * 0.01 : repeat;
        explicitOffset = isNaN(explicitOffset) ? 0 : explicitOffset;

        var di:DrawInfo;
        if (isNaN(explicitRepeat))
        {
            di = _PositionHelper.getDrawInfo(explicitOffset);
            if (di && _clippingRectangle.contains(di.x, di.y))
            {
                result.push(di);
            }
        }
        else
        {
            var numDrawInfos:int = int(clippedLength / explicitRepeat);
            explicitRepeat += (clippedLength - (numDrawInfos * explicitRepeat)) / numDrawInfos;
            for (var i:int = 0; i <= numDrawInfos; i++)
            {
                di = _clippedPositionHelper.getDrawInfo(i * explicitRepeat + explicitOffset);
                if (di && _clippingRectangle.contains(di.x, di.y))
                {
                    result.push(di);
                }
            }
            /*for (var i:int = 0, n:int = totalLength / explicitRepeat; i < n; i++)
            {
                di = _polylinePositionHelper.getDrawInfo(i * explicitRepeat + explicitOffset);
                if (_clippingRectangle.contains(di.x, di.y))
                {
                    result.push(di);
                }
            }*/
        }

        return result;
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     * Project Polyline paths in screen coordinates.
     * @param paths An array of array of MapPoint.
     * @return A vector of segments of format <code>[ x0, y0, x1, y1, x1, y1, x2, y2 ... ]</code>
     */
    private function project(paths:Array, state:MapState):Vector.<Vector.<Number>>
    {
        var result:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>(paths.length, true);

        var projectedPath:Vector.<Number>;
        var mapPoint:MapPoint;
        var path:Array;

        var a:Point = state.mapToLayerXY(0, 0); //intercept
        var b:Point = state.mapToLayerXY(1, 1); //slope
        var twoN:int;
        var ax:Number = a.x,
            ay:Number = a.y,
            bx:Number = b.x - ax,
            by:Number = b.y - ay;

        for (var i:int = 0, len:int = paths.length; i < len; i++)
        {
            path = paths[i];
            if (path.length > 1)
            {
                result[i] = projectedPath = new Vector.<Number>(path.length * 4 - 4, true);

                mapPoint = path[0];
                projectedPath[0] = mapPoint.x * bx + ax;
                projectedPath[1] = mapPoint.y * by + ay;

                mapPoint = path[1];
                projectedPath[2] = mapPoint.x * bx + ax;
                projectedPath[3] = mapPoint.y * by + ay;

                for (var n:int = 1, pathLen:int = path.length - 2; n <= pathLen; n++)
                {
                    mapPoint = path[n + 1];
                    twoN = n * 4;
                    projectedPath[twoN] = projectedPath[twoN - 2];
                    projectedPath[twoN + 1] = projectedPath[twoN - 1];
                    projectedPath[twoN + 2] = mapPoint.x * bx + ax;
                    projectedPath[twoN + 3] = mapPoint.y * by + ay;
                }
            }
        }

        return result;
    }

    /**
     * Clip paths in screen coordinates with a clipping rectangle.
     *
     * @param projectedPaths A vector of vertices of format <code>[ x0, y0, x1, y1, x1, y1, x2, y2 ... ]</code>
     * @param rectangle The clipping rectangle in screen coordinates
     */
    private function clip(projectedPaths:Vector.<Vector.<Number>>, rectangle:Rectangle):Vector.<Vector.<Number>>
    {
        var result:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
        var projectedPath:Vector.<Number>;
        var clippedProjectedPath:Vector.<Number>;

        clipper.clippingRectangle = rectangle;

        for (var i:int = 0, len:int = projectedPaths.length; i < len; i++)
        {
            // Clip the path
            projectedPath = projectedPaths[i];
            if (projectedPath)
            {
                clippedProjectedPath = clipper.clipPath(projectedPath);
                result.push(clippedProjectedPath);
            }
        }

        return result;
    }

    private function createGraphicsPath(segments:Vector.<Vector.<Number>>):GraphicsPath
    {
        var result:GraphicsPath = new GraphicsPath(new Vector.<int>(), new Vector.<Number>);

        var segment:Vector.<Number>;
        var oldX:int,
            oldY:int,
            x:Number,
            y:Number;
        // Yes, old are int and new are Number :)
        for (var i:int = 0, n:int = segments.length; i < n; i++)
        {
            segment = segments[i];
            if (segment.length >= 4)
            {
                // init
                result.moveTo(segment[0], segment[1]);
                x = segment[2];
                y = segment[3];
                result.lineTo(x, y);
                oldX = int(x);
                oldY = int(y);

                for (var j:int = 4, m:int = segment.length - 4; j <= m; )
                {
                    x = segment[j + 0];
                    y = segment[j + 1];

                    // Case where the coordinates of the first point of the segment
                    // don't match the old coordinates.
                    // In that case, it's a MOVE_TO
                    if (int(x) != oldX || int(y) != oldY)
                    {
                        result.moveTo(x, y);
                        oldX = int(x);
                        oldY = int(y);
                    }

                    x = segment[j + 2];
                    y = segment[j + 3];
                    if (int(x) != oldX || int(y) != oldY)
                    {
                        result.lineTo(x, y);
                        oldX = int(x);
                        oldY = int(y);
                    }

                    j += 4;
                }
            }
        }

        return result;
    }

}
}
import io.github.ycabon.markings.supportClasses.DrawInfo;

class PositionHelper
{

    //--------------------------------------------------------------------------
    //
    //  Class Constants
    //
    //--------------------------------------------------------------------------

    private static const RAD_TO_DEG:Number = 57.295779513082320876798154814105;


    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    private var _projectedPaths:Vector.<Vector.<Number>>;

    private var _numProjectedPaths:int;

    /**
     * The length of each path.
     */
    private var _pathLengths:Vector.<Number>;

    private var _pathCumulatedLengths:Vector.<Number>;

    /**
     * The length of each segment of each path.
     */
    private var _pathSegmentsLengths:Vector.<Vector.<Number>>;

    /**
     * The angles of each segment of each path.
     */
    private var _pathSegmentsAngles:Vector.<Vector.<Number>>;


    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  totalLength
    //----------------------------------

    private var _totalLength:Number = 0;

    /**
     * The length of the Polyline at the current resolution
     */
    public function get totalLength():Number
    {
        return _totalLength;
    }


    //--------------------------------------------------------------------------
    //
    //  Public functions
    //
    //--------------------------------------------------------------------------

    public function initialize(projectedPaths:Vector.<Vector.<Number>>):void
    {
        _projectedPaths = projectedPaths;

        _totalLength = 0;
        _numProjectedPaths = projectedPaths.length;
        _pathLengths = new Vector.<Number>(_numProjectedPaths, true);
        _pathCumulatedLengths = new Vector.<Number>(_numProjectedPaths, true);
        _pathSegmentsLengths = new Vector.<Vector.<Number>>(_numProjectedPaths, true);
        _pathSegmentsAngles = new Vector.<Vector.<Number>>(_numProjectedPaths, true);

        for (var i:int = 0; i < _numProjectedPaths; i++)
        {
            if (projectedPaths[i])
            {
                calculateForPath(projectedPaths[i], i);
            }
        }
    }

    public function getDrawInfo(offset:Number):DrawInfo
    {
        // trace("getDrawInfo( " + offset + " )");

        // round robin the offset
        if (offset != totalLength)
        {
            offset = offset % totalLength;
        }

        // finding the right path
        var pathIndex:int = -1;
        var i:int, n:int;
        for (i = 0, n = _numProjectedPaths; i < n; i++)
        {
            if (_pathCumulatedLengths[i] >= offset)
            {
                pathIndex = i;
                break;
            }
            else
            {
                offset -= _pathCumulatedLengths[i];
            }
        }

        if (pathIndex < 0)
        {
            return null;
        }

        // trace("  pathIndex: ", pathIndex);

        const lengths:Vector.<Number> = _pathSegmentsLengths[pathIndex];

        // finding the right segment;
        var lengthIndex:int = -1;
        for (i = 0, n = lengths.length; i < n; i++)
        {
            if (lengths[i] == 0)
            {
                continue;
            }

            if (lengths[i] >= offset)
            {
                lengthIndex = i;
                offset -= lengths[i];
                offset = Math.abs(offset);
                break;
            }
            else
            {
                offset -= lengths[i];
            }
        }

        if (lengthIndex < 0)
        {
            return null;
        }
        // trace("  lengthIndex: ", lengthIndex);

        // segment index is found.
        // get the x and ys.
        const path:Vector.<Number> = _projectedPaths[pathIndex];
        const angles:Vector.<Number> = _pathSegmentsAngles[pathIndex];
        const segmentIndex:Number = lengthIndex * 2;
        var xFrom:Number = path[segmentIndex];
        var yFrom:Number = path[segmentIndex + 1];
        var xTo:Number = path[segmentIndex + 2];
        var yTo:Number = path[segmentIndex + 3];

        // get the ratio of the offset on the line segment
        var ratio:Number = 1 - (offset / lengths[lengthIndex]);

        // x, y, angle
        return new DrawInfo(xFrom + (xTo - xFrom) * ratio, yFrom + (yTo - yFrom) * ratio, angles[lengthIndex]);
    }


    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    private function calculateForPath(path:Vector.<Number>, index:int):void
    {
        var pathLength:Number = 0;

        var deltaX:Number,
            deltaY:Number,
            length:Number;

        if (path.length >= 4)
        {
            _pathSegmentsLengths[index] = new Vector.<Number>(path.length * 0.5 - 1, true);
            _pathSegmentsAngles[index] = new Vector.<Number>(path.length * 0.5 - 1, true);

            for (var i:int = 0, n:int = path.length - 4; i <= n; )
            {
                deltaX = path[i + 2] - path[i]; // xTo - xFrom
                deltaY = path[i + 3] - path[i + 1]; // yTo - yFrom

                // trace("dx, dy: "+ deltaX + ", "+ deltaY);

                // OK  -127.76039596369867,  63.880197981849335
                // NOK -255.5207919273978, -127.76039596369884
                // NOK  255.5207919273978, -127.76039596369884
                // OK   255.5207919273978,  127.76039596369884

                length = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
                pathLength += _pathSegmentsLengths[index][i * 0.5] = length;
                if (length > 0)
                {
                    _pathSegmentsAngles[index][i * 0.5] = Math.acos(deltaX / length) * RAD_TO_DEG;
                    // trace(_pathSegmentsAngles[index][i * 0.5] + " " + length);
                    if (deltaY < 0)
                    {
                        _pathSegmentsAngles[index][i * 0.5] = -_pathSegmentsAngles[index][i * 0.5];
                    }
                }
                else
                {
                    _pathSegmentsAngles[index][i * 0.5] = 0;
                }

                i += 4;
            }
        }
        else
        {
            _pathSegmentsLengths[index] = new Vector.<Number>();
        }

        _pathLengths[index] = pathLength;
        _pathCumulatedLengths[index] = index == 0 ? pathLength : _pathCumulatedLengths[index - 1] + pathLength;
        _totalLength += pathLength;
    }
}

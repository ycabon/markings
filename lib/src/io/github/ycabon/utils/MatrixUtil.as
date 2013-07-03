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

package io.github.ycabon.utils
{

import flash.display.DisplayObject;
import flash.geom.Matrix;
import flash.geom.Point;

[ExcludeClass]

public class MatrixUtil
{

    //--------------------------------------------------------------------------
    //
    //  Class Constants
    //
    //--------------------------------------------------------------------------

    private static const DEG_TO_RAD:Number = Math.PI / 180;
    
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------
    
    private static var transformCenter:Point = new Point();
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     * Rotate a DisplayObject by an angle around a transformation center.
     * 
     * @param displayObject
     * @param angle
     * @param transformCenterX
     * @param transformCenterY
     */
    public static function rotate(displayObject:DisplayObject,
                                  angle:Number,
                                  transformCenterX:Number = 0,
                                  transformCenterY:Number = 0):void
    {
        var m:Matrix = displayObject.transform.matrix;
        transformCenter.setTo(+transformCenterX, +transformCenterY);
        transformCenter = m.transformPoint(transformCenter);
        m.translate(-transformCenter.x, -transformCenter.y);
        m.rotate(angle * DEG_TO_RAD);
        m.translate(transformCenter.x, transformCenter.y);
        displayObject.transform.matrix = m;
    }
}
}

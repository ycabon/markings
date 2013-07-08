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

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Matrix;

import io.github.ycabon.markings.lineClasses.ILinePart;

import spark.components.supportClasses.InvalidatingSprite;
import spark.core.ISharedDisplayObject;

[ExcludeClass]

public class SpritePool
{

    //--------------------------------------------------------------------------
    //
    //  Class Constants
    //
    //--------------------------------------------------------------------------

    private static const POOL:Vector.<ISharedDisplayObject> = new Vector.<ISharedDisplayObject>();

    private static var COUNTER:int = 0;


    //--------------------------------------------------------------------------
    //
    //  Class Methods
    //
    //--------------------------------------------------------------------------

    private static function acquire():ISharedDisplayObject
    {
        var child:InvalidatingSprite;

        if (COUNTER > 0)
        {
            child = POOL[--COUNTER] as InvalidatingSprite;
            return child;
        }

        child = new InvalidatingSprite();
        child.cacheAsBitmap = true;
        child.redrawRequested = true;
        POOL.unshift(child);
        COUNTER++;

        return acquire();
    }

    private static function dispose(sharedDisplayObject:ISharedDisplayObject):void
    {
        // Clear the Graphics before returning in the pool.
        var sp:InvalidatingSprite = sharedDisplayObject as InvalidatingSprite;
        sp.redrawRequested = true;
        sp.graphics.clear();
        sp.x = 0;
        sp.y = 0;
        sp.transform.matrix = new Matrix();
        sp.cacheAsBitmap = true;

        POOL[COUNTER++] = sharedDisplayObject;
    }


    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     */
    public function SpritePool(sprite:Sprite)
    {
        _sprite = sprite;
    }


    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    private var _sprite:Sprite;
    private var _sprite_displayList:Vector.<Sprite> = new Vector.<Sprite>();
    private var _sprite_startIndexes:Vector.<int> = new Vector.<int>();
    private var _sprite_childrenToRemove:Vector.<int> = new Vector.<int>();

    //--------------------------------------------------------------------------
    //
    //  Public Methods
    //
    //--------------------------------------------------------------------------

    public function initialize():void
    {
        for (var i:int = _sprite_displayList.length - 1; i >= 0; i--)
        {
            _sprite_startIndexes[i] = 0;
            if (_sprite_displayList[i])
            {
                _sprite_childrenToRemove[i] = _sprite_displayList[i].numChildren;
            }
            else
            {
                _sprite_childrenToRemove[i] = 0;
            }
        }
    }

    public function getSprites(linePart:ILinePart, howMany:int):Vector.<ISharedDisplayObject>
    {
        var result:Vector.<ISharedDisplayObject> = new Vector.<ISharedDisplayObject>(howMany, true);

        if (howMany > 0)
        {
            var i:int, linePartSprite:Sprite, startIndex:int, childrenToRemove:int, depth:int = linePart.depth;

            //
            // Add the canvas for the line part if it doesn't exist.
            // 
            if (_sprite_displayList.length < depth + 1)
            {
                _sprite_startIndexes.length = _sprite_childrenToRemove.length = _sprite_displayList.length = depth + 1;
                _sprite_displayList[depth] = acquire() as Sprite;
                _sprite_displayList[depth].mouseEnabled = false;
                _sprite_displayList[depth].cacheAsBitmap = false;
                if (_sprite.numChildren <= depth)
                {
                    _sprite.addChild(_sprite_displayList[depth]);
                }
                else
                {
                    _sprite.addChildAt(_sprite_displayList[depth], depth);
                }
                _sprite_startIndexes[depth] = 0;
                _sprite_childrenToRemove[depth] = 0;
            }

            linePartSprite = _sprite_displayList[depth];
            startIndex = _sprite_startIndexes[depth];
            childrenToRemove = _sprite_childrenToRemove[depth];

            var numChildren:int = linePartSprite.numChildren;
            if (linePartSprite.numChildren < (startIndex + howMany))
            {
                childrenToRemove = 0;
                var howManyToAdd:int = (startIndex + howMany) - numChildren;
                for (i = 0; i < howManyToAdd; i++)
                {
                    linePartSprite.addChild(acquire() as DisplayObject);
                }
            }
            else
            {
                childrenToRemove -= howMany;
            }

            for (i = 0; i < howMany; i++)
            {
                result[i] = linePartSprite.getChildAt(i + startIndex) as ISharedDisplayObject;
            }

            startIndex += howMany;
            _sprite_startIndexes[depth] = startIndex;
            _sprite_childrenToRemove[depth] = childrenToRemove;
        }

        return result;
    }

    public function commit():void
    {
        var childrenToRemove:int;
        var sprite:Sprite;
        for (var i:int = _sprite_displayList.length - 1; i >= 0; i--)
        {
            childrenToRemove = _sprite_childrenToRemove[i];
            if (childrenToRemove > 0)
            {
                sprite = _sprite_displayList[i];
                if (sprite.numChildren >= childrenToRemove)
                {
                    for (var index:int = sprite.numChildren - 1, n:int = sprite.numChildren - childrenToRemove; index >= n; index--)
                    {
                        dispose(sprite.removeChildAt(index) as ISharedDisplayObject);
                    }
                }
            }
        }
    }


    public function disposeSprites(linePart:ILinePart):void
    {
        var depth:int = linePart.depth;
        if (_sprite_displayList.length - 1 < depth)
        {
            return;
        }
        var sprite:Sprite = _sprite_displayList[depth];
        if (sprite)
        {
            // for now let the sprite in place
            //_sprite.removeChild(sprite);
            // dispose(sprite as ISharedDisplayObject);
            for (var index:int = sprite.numChildren - 1; index >= 0; index--)
            {
                dispose(sprite.removeChildAt(index) as ISharedDisplayObject);
            }
        }
    }

    public function destroy():void
    {
        var sprite:Sprite;
        for (var i:int, n:int = _sprite_displayList.length; i < n; i++)
        {
            sprite = _sprite_displayList[i];
            if (sprite)
            {
                _sprite.removeChild(sprite);
                dispose(sprite as ISharedDisplayObject);
                for (var index:int = sprite.numChildren - 1; index >= 0; index--)
                {
                    dispose(sprite.removeChildAt(index) as ISharedDisplayObject);
                }
            }
        }
    }

}
}


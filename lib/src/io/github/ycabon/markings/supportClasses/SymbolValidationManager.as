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

import flash.events.Event;

import io.github.ycabon.markings.AdvancedLineSymbol;

import mx.managers.ISystemManager;
import mx.managers.SystemManagerGlobals;

[ExcludeClass]

public class SymbolValidationManager
{


    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  The sole instance of this singleton class.
     */
    private static var instance:SymbolValidationManager;

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    public static function getInstance():SymbolValidationManager
    {
        if (!instance)
        {
            instance = new SymbolValidationManager();
        }

        return instance;
    }


    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *
     */
    public function SymbolValidationManager()
    {
        systemManager = SystemManagerGlobals.topLevelSystemManagers[0];
    }


    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    private var systemManager:ISystemManager;

    private var invalidateSymbolsFlag:Boolean = false;

    private var listenersAttached:Boolean = false;

    private var symbols:Vector.<AdvancedLineSymbol> = new Vector.<AdvancedLineSymbol>();

    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------

    public function invalidate(symbol:AdvancedLineSymbol):void
    {
        if (!invalidateSymbolsFlag && systemManager)
        {
            invalidateSymbolsFlag = true;

            if (!listenersAttached)
            {
                attachListeners(systemManager);
            }
        }
        addSymbol(symbol);
    }

    //--------------------------------------------------------------------------
    //
    //  Public Methods
    //
    //--------------------------------------------------------------------------

    public function validateClient(symbol:AdvancedLineSymbol):void
    {
        if (invalidateSymbolsFlag)
        {
            var symbol:AdvancedLineSymbol;
            var index:int = symbols.lastIndexOf(symbol);
            if (index != -1)
            {
                symbol = symbols[index];
                symbols.splice(index, 1);
                invalidateSymbolsFlag = invalidateSymbolsFlag && symbols.length > 0;
                symbol.validate();
            }
        }
    }

    public function validateSymbols():void
    {
        if (invalidateSymbolsFlag)
        {
            var symbol:AdvancedLineSymbol;
            while (symbols.length)
            {
                symbol = symbols.shift();
                symbol.validate();
            }
            invalidateSymbolsFlag = false;
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    private function addSymbol(symbol:AdvancedLineSymbol):void
    {
        if (symbols.lastIndexOf(symbol) == -1)
        {
            symbols.push(symbol);
        }
    }

    private function attachListeners(systemManager:ISystemManager):void
    {
        systemManager.addEventListener(Event.ENTER_FRAME, systemManagerEnterFrameHandler);
        listenersAttached = true;
    }

    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private function systemManagerEnterFrameHandler(event:Event):void
    {
        systemManager.removeEventListener(Event.ENTER_FRAME, systemManagerEnterFrameHandler);
        listenersAttached = false;
        validateSymbols();
    }
}
}

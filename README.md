Markings
========

Markings is a library of advanced symbols for the [ArcGIS API for Flex](https://developers.arcgis.com/en/flex/). It's designed to give to the developer (You) infinite number of different styles for rendering your Graphics on the Map.

The first featured symbol is the [AdvancedLineSymbol](http://ycabon.github.io/markings/asdoc/io/github/ycabon/markings/AdvancedLineSymbol.html). The ArcGIS API for Flex supports a finite numbers of line styles (solid, dash, dashdot, dashdotdot, dot) through the [SimpleLineSymbol](https://developers.arcgis.com/en/flex/api-reference/com/esri/ags/symbols/SimpleLineSymbol.html). The AdvancedLineSymbol lets you define easily, using MXML or AS3, more meaningful line symbology.

## Requirements.
* [ArcGIS API for Flex SWC](http://links.esri.com/flex-api/latest-download) >= 3.1
* Flash Player >= 11.1

## Getting started.
* Get the Markings SWC.
* Create a new application containing a map and some line Graphic.
* Start styling.

[![Example of AdvancedLineSymbol](https://raw.github.com/ycabon/markings/gh-pages/images/lineRoadSymbol.png "Example of AdvancedLineSymbol")]

```XML
<mk:AdvancedLineSymbol id="lineSymbolRoad">
    <s:ArrayList>

        <!-- White outter stroke -->
        <mk:SolidLinePart>
            <s:SolidColorStroke color="0xFFFFFF" weight="10"/>
        </mk:SolidLinePart>

        <!-- Gray inside stroke -->
        <mk:SolidLinePart>
            <s:SolidColorStroke color="0xAAAAAA" weight="6"/>
        </mk:SolidLinePart>

        <!-- Lane separation -->
        <mk:DashedLinePart pattern="[5, 5]">
            <s:SolidColorStroke color="0xFFFFFF" weight="2"/>
        </mk:DashedLinePart>

        <!-- The car -->
        <mk:IconPart rotate="true">
            <s:BitmapImage width="22" height="15"
                           source="@Embed(source='assets/voiture1.png')"/>
        </mk:IconPart>

    </s:ArrayList>
</mk:AdvancedLineSymbol>
```

## Licensing.

Copyright 2012-2013 Esri

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

A copy of the license is available in the repository's [license.txt](https://raw.github.com/ycabon/markings/develop/license.txt) file.

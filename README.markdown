# GrowlCappuccino</h2>

## What is GrowlCappuccino ?</h3>

GrowlCappuccino is a framework that allows to mimic Growl notificatiom system in Cappuccino


## Build

To build TNKit you can type

    # jake debug ; jake release


## Quick Start</h3>

Simply include the GrowlCappuccino framework in your Frameworks directory and include GrowlCappuccino.js

    @import <GrowlCappuccino/GrowlCappuccino.j>
    
    [...]
    
    var growl = [TNGrowlCenter defaultCenter];
    
    [grow setView:aView];
    [growl pushNotificationWithTitle:@"Hello" message:@"Hello World!"];
    
    [...]


## Demo application

You can see a demo application here: [Demo](http://github.com/primalmotion/GrowlCappuccino-Example/)


## Documentation

To generate the documentation execute the following :

    # jake docs


## Help / Suggestion

You can reach us at irc://irc.freenode.net/#archipel

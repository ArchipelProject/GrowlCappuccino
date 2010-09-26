# GrowlCappuccino</h2>

## What is GrowlCappuccino ?</h3>

GrowlCappuccino is a framework that allows to mimic Growl notificatiom system in Cappuccino

## Quick Start</h3>

Simply include the GrowlCappuccino framework in your Frameworks directory and include GrowlCappuccino.js

	@import <GrowlCappuccino/GrowlCappuccino.j>

	[...]

	var growl = [TNGrowlCenter defaultCenter];

	[grow setView:aView];
	[growl pushNotificationWithTitle:@"Hello" message:@"Hello World!"];

	[...]

## Documentation
To generate the documentation execute the following :

	# doxygen GrowlCappuccino.doxygen

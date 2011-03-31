/*
 * TNGrowlView.j
 *
 * Copyright (C) 2010  Antoine Mercadal <antoine.mercadal@inframonde.eu>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3.0 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

@import <Foundation/Foundation.j>

@import <AppKit/CPImage.j>
@import <AppKit/CPImageView.j>
@import <AppKit/CPTextField.j>
@import <AppKit/CPView.j>



/*! @global
    @group TNGrowlNotification
    The notification sent when life time is over
*/
TNGrowlViewLifeTimeExpirationNotification   = @"TNGrowlViewLifeTimeExpirationNotification";


/*! @ingroup growlcappuccino
    This class represent a single growl notification view
    You should never use this class directly
*/
@implementation TNGrowlView : CPView
{
    id              _actionParameters   @accessors(getter=actionParameters,setter=setActionParameters:);
    id              _target             @accessors(getter=target,setter=setTarget:);
    SEL             _action             @accessors(getter=action,setter=setAction:);

    CPImageView     _icon;
    CPTextField     _message;
    CPTextField     _title;
    CPTimer         _timer;
    float           _lifeTime;
}


#pragma mark -
#pragma mark Initialization

/*! intialize the TNGrowlView
    @param aFrame the frame of the view
    @param aTitle the title of the TNGrowlView
    @param aMessage the message of the TNGrowlView
    @param anIcon the icon of the TNGrowlView
    @param aLifeTime the life time of TNGrowlView
    @param aBackground the background of TNGrowlView
    @return initialized instance of TNGrowlView
*/
- (id)initWithFrame:(CPRect)aFrame title:(CPString)aTitle message:(CPString)aMessage icon:(id)anIcon lifeTime:(float)aLifeTime
{
    if (self = [super initWithFrame:aFrame])
    {
        // title
        _title  = [[CPTextField alloc] initWithFrame:CGRectMake(44, 5, aFrame.size.width - 44, 20)];
        [_title setStringValue:aTitle];
        [_title setFont:[CPFont boldSystemFontOfSize:12]];
        [_title setTextColor:[CPColor whiteColor]];
        [_title setAutoresizingMask:CPViewWidthSizable];
        [self addSubview:_title];

        // message
        _message = [[CPTextField alloc] initWithFrame:CGRectMake(44, 20, aFrame.size.width - 50, aFrame.size.height - 25)];
        [_message setStringValue:aMessage];
        [_message setLineBreakMode:CPLineBreakByWordWrapping];
        [_message setAutoresizingMask:CPViewHeightSizable | CPViewWidthSizable];
        [_message setTextColor:[self valueForThemeAttribute:@"text-color"]];
        [self addSubview:_message];

        // background
        [self setBackgroundColor:[self valueForThemeAttribute:@"background-color"]];
        [self setAlphaValue:[self valueForThemeAttribute:@"alpha-value"]];

        // icon
        _icon       = [[CPImageView alloc] initWithFrame:CGRectMake(5, 6, 36, 36)];
        [_icon setImageScaling:CPScaleProportionally];

        if ([anIcon isKindOfClass:CPImage])
            [_icon setImage:anIcon];
        else
            switch (anIcon)
            {
                case TNGrowlIconInfo:
                    [_icon setImage:[self valueForThemeAttribute:@"icon-info"]];
                    break;

                case TNGrowlIconWarning:
                    [_icon setImage:[self valueForThemeAttribute:@"icon-warning"]];
                    break;

                case TNGrowlIconError:
                    [_icon setImage:[self valueForThemeAttribute:@"icon-error"]];
                    break;
            }
        [self addSubview:_icon];


        // frame height
        var height = [aMessage sizeWithFont:[_message font] inWidth:CGRectGetWidth(aFrame) - 44].height;

        aFrame.size.height = height + 30;

        if (aFrame.size.height < TNGrowlPlacementHeight)
            aFrame.size.height = TNGrowlPlacementHeight

        [self setFrame:aFrame];

        //timer
        _lifeTime = aLifeTime;
        _timer = [CPTimer scheduledTimerWithTimeInterval:_lifeTime target:self selector:@selector(willBeRemoved:) userInfo:nil repeats:NO];
    }

    return self;
}


#pragma mark -
#pragma mark Events

/*! if mouse clicked, set life time to 0
*/
- (void)mouseDown:(CPEvent)anEvent
{
    if ([anEvent type] == CPLeftMouseDown)
    {
        [_timer invalidate];
        [self willBeRemoved:nil];

        if (_target && _action)
            [_target performSelector:_action withObject:self withObject:_actionParameters];
    }

    [super mouseDown:anEvent];
}

/*! if Info.plist parameter TNGrowlUseMouseMoveEvents is set to 1
    this will stop the life time counting (ie let the notification displayed if
    mouse is over)
*/
- (void)mouseEntered:(CPEvent)anEvent
{
    if ([anEvent type] == CPMouseEntered)
    {
        [_timer invalidate];
        [self setAlphaValue:1.0];
    }

    [super mouseEntered:anEvent];
}

/*! if Info.plist parameter TNGrowlUseMouseMoveEvents is set to 1
    this will relaunch the life time counting when mouse is out
*/
- (void)mouseExited:(CPEvent)anEvent
{
    if ([anEvent type] == CPMouseExited)
    {
        _timer = [CPTimer scheduledTimerWithTimeInterval:_lifeTime target:self selector:@selector(willBeRemoved:) userInfo:nil repeats:NO];
    }

    [super mouseExited:anEvent];
}


#pragma mark -
#pragma mark Timer handlers
/*! can be triggered by timer or by mouseDown: message
    post the notification that the life time has expired.
*/
- (void)willBeRemoved:(CPTimer)aTimer
{
    var center = [CPNotificationCenter defaultCenter];

    [center postNotificationName:TNGrowlViewLifeTimeExpirationNotification object:self];
}


#pragma mark -
#pragma mark Theming

+ (CPString)themeClass
{
    return @"growl-view";
}

+ (id)themeAttributes
{
    var bundle = [CPBundle bundleForClass:[self class]],
        backgroundImage = [CPColor colorWithPatternImage:[[CPNinePartImage alloc] initWithImageSlices:[
            [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"Noir/top-left.png"] size:CPSizeMake(10.0, 30.0)],
            [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"Noir/top.png"] size:CPSizeMake(1.0, 30.0)],
            [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"Noir/top-right.png"] size:CPSizeMake(10.0, 30.0)],
            [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"Noir/left.png"] size:CPSizeMake(10.0, 1.0)],
            [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"Noir/center.png"] size:CPSizeMake(1.0, 1.0)],
            [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"Noir/right.png"] size:CPSizeMake(10.0, 1.0)],
            [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"Noir/bottom-left.png"] size:CPSizeMake(10.0, 12.0)],
            [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"Noir/bottom.png"] size:CPSizeMake(1.0, 12.0)],
            [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"Noir/bottom-right.png"] size:CPSizeMake(10.0, 12.0)],
        ]]],
        iconInfo    = [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon-info.png"]],
        iconError   = [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon-error.png"]],
        iconWarning = [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon-warning.png"]];



    return [CPDictionary dictionaryWithObjects:[backgroundImage, iconInfo, iconError, iconWarning, [CPColor whiteColor], 0.8]
                                       forKeys:[@"background-color", @"icon-info", @"icon-error", @"icon-warning", @"text-color", @"alpha-value"]];
}

@end

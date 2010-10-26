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
@import <AppKit/AppKit.j>

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
    id          _target             @accessors(getter=target,setter=setTarget:);
    SEL         _action             @accessors(getter=action,setter=setAction:);
    id          _actionParameters   @accessors(getter=actionParameters,setter=setActionParameters:);
    CPImageView _icon;
    CPTextField _title;
    CPTextField _message;
    CPTimer     _timer;
    float       _lifeTime;
}

/*! intialize the TNGrowlView
    @param aFrame the frame of the view
    @param aTitle the title of the TNGrowlView
    @param aMessage the message of the TNGrowlView
    @param anIcon the icon of the TNGrowlView
    @param aLifeTime the life time of TNGrowlView
    @param aBackground the background of TNGrowlView
    @return initialized instance of TNGrowlView
*/
- (id)initWithFrame:(CPRect)aFrame title:(CPString)aTitle message:(CPString)aMessage icon:(CPImage)anIcon lifeTime:(float)aLifeTime background:(CPColor)aBackground
{
    if (self = [super initWithFrame:aFrame])
    {
        _lifeTime   = aLifeTime;
        _icon       = [[CPImageView alloc] initWithFrame:CGRectMake(5, 6, 36, 36)];
        _title      = [[CPTextField alloc] initWithFrame:CGRectMake(44, 5, aFrame.size.width - 44, 20)];
        _message    = [[CPTextField alloc] initWithFrame:CGRectMake(44, 20, aFrame.size.width - 44, aFrame.size.height - 25)];

        [_icon setImageScaling:CPScaleProportionally];
        [_icon setImage:anIcon];
        [_icon setBorderRadius:5];
        [_title setStringValue:aTitle];
        [_title setFont:[CPFont boldSystemFontOfSize:12]];
        [_title setTextColor:[CPColor whiteColor]];
        [_title setAutoresizingMask:CPViewWidthSizable];
        [_message setStringValue:aMessage];
        [_message setLineBreakMode:CPLineBreakByWordWrapping];
        [_message setAutoresizingMask:CPViewHeightSizable | CPViewWidthSizable];
        [_message setTextColor:[CPColor whiteColor]];

        [self addSubview:_icon];
        [self addSubview:_title];
        [self addSubview:_message];

        [self setBackgroundColor:aBackground];
        _DOMElement.style.backgroundRepeat = "no-repeat";
        _DOMElement.style.backgroundColor = "black";
        [self setBorderRadius:5];
        [self setAlphaValue:0.8];

        var height = [aMessage sizeWithFont:[_message font] inWidth:CGRectGetWidth(aFrame) - 44].height;

        // if (height > aFrame.size.height)
        aFrame.size.height = height + 30;

        if (aFrame.size.height < TNGrowlPlacementHeight)
            aFrame.size.height = TNGrowlPlacementHeight

        [self setFrame:aFrame];

        _timer = [CPTimer scheduledTimerWithTimeInterval:_lifeTime target:self selector:@selector(willBeRemoved:) userInfo:nil repeats:NO];
    }

    return self;
}

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

/*! can be triggered by timer or by mouseDown: message
    post the notification that the life time has expired.
*/
- (void)willBeRemoved:(CPTimer)aTimer
{
    var center = [CPNotificationCenter defaultCenter];

    [center postNotificationName:TNGrowlViewLifeTimeExpirationNotification object:self];
}

- (void)setBorderRadius:(float)aRadius
{
    _DOMElement.style.borderRadius = aRadius + "px";
    _DOMElement.style.MozBorderRadius = aRadius + "px";
}

@end

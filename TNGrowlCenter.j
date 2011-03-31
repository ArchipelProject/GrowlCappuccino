/*
 * TNGrowlCenter.j
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

@import <AppKit/CPView.j>
@import <AppKit/CPViewAnimation.j>

@import "TNGrowlView.j";

/*! @global
    @group TNGrowl
    the defaultCenter pointer
*/
TNGrowlDefaultCenter                    = nil;

/*! @global
    @group TNGrowlIcon
    icon identitier for Info
*/
TNGrowlIconInfo     = @"TNGrowlIconInfo";

/*! @global
    @group TNGrowlIcon
    icon identitier for Error
*/
TNGrowlIconError    = @"TNGrowlIconError";

/*! @global
    @group TNGrowlIcon
    icon identitier for Warning
*/
TNGrowlIconWarning  = @"TNGrowlIconWarning";

/*! @global
    @group TNGrowlPlacement
    the height of TNGrowlView
*/
TNGrowlPlacementWidth           = 250.0

/*! @global
    @group TNGrowlPlacement
    the width of TNGrowlView
*/
TNGrowlPlacementHeight          = 80.0

/*! @global
    @group TNGrowlPlacement
    the margin top value
*/
TNGrowlPlacementMarginTop       = 10.0;

/*! @global
    @group TNGrowlPlacement
    the margin top right
*/
TNGrowlPlacementMarginRight     = 10.0;

/*! @global
    @group TNGrowlAnimation
    Duration of fade in and fade out CPViewAnimation
*/
TNGrowlAnimationDuration    = 0.3;



/*! @ingroup growlcappuccino
    this is the GrowlCappuccino notification center. This is from where you can post Growl notification.
    it provide a class method defaultCenter: that return the default GrowlCappuccino center.
    In the most of the case you should use this default center.

    You can find two option to set in Info.plist
     - TNGrowlUseMouseMoveEvents : 1 or 0. Default: 0. If 1, GrowlCappuccino will set acceptsMouseMovedEvents: to the _view's window. this
     will allow to stop life time counting on mouse over, but it can affect the whole application performance
     - TNGrowlDefaultLifeTime : in seconds. Deafult: 5. The lifeTime of notification.
*/
@implementation TNGrowlCenter : CPObject
{
    BOOL        _useWindowMouseMoveEvents;
    CPArray     _notifications;
    CPRect      _notificationFrame;
    CPView      _view               @accessors(getter=view, setter=setView:);
    float       _defaultLifeTime    @accessors(getter=lifeDefaultTime, setter=setDefaultLifeTime:);
}


#pragma mark -
#pragma mark Initialization

/*! return the defaultCenter
    @return TNGrowlCenter the default center;
*/
+ (id)defaultCenter
{
    if (!TNGrowlDefaultCenter)
        TNGrowlDefaultCenter = [[TNGrowlCenter alloc] init];

    return TNGrowlDefaultCenter;
}

/*! initialize the class
    @return the initialized instance of TNGrowlCenter
*/
- (id)init
{
    if (self = [super init])
    {
        var bundle          = [CPBundle bundleForClass:[self class]];

        _defaultLifeTime            = [bundle objectForInfoDictionaryKey:@"TNGrowlDefaultLifeTime"];
        _notifications              = [CPArray array];
        _notificationFrame          = CGRectMake(10,10, TNGrowlPlacementWidth,TNGrowlPlacementHeight);
        _useWindowMouseMoveEvents   = [bundle objectForInfoDictionaryKey:@"TNGrowlUseMouseMoveEvents"];
    }

    return self;
}


#pragma mark -
#pragma mark Notification handlers

/*! Responder of the message TNGrowlViewLifeTimeExpirationNotification
    this will start fade out the TNGrowlView that sent the notification
    @param aNotification the notification
*/
- (void)didReceivedNotificationEndLifeTime:(CPNotification)aNotification
{
    var center      = [CPNotificationCenter defaultCenter],
        senderView  = [aNotification object],
        animView    = [CPDictionary dictionaryWithObjectsAndKeys:senderView, CPViewAnimationTargetKey, CPViewAnimationFadeOutEffect, CPViewAnimationEffectKey],
        anim        = [[CPViewAnimation alloc] initWithViewAnimations:[animView]];

    [center removeObserver:self name:TNGrowlViewLifeTimeExpirationNotification object:senderView];

    [anim setDuration:TNGrowlAnimationDuration];
    [anim setDelegate:self];
    [anim startAnimation];
}


#pragma mark -
#pragma mark Messaging

/*! display a notification with type TNGrowlIconInfo
    @param aTitle the title of the notification
    @param aMessage the mesage of the notification
*/
- (void)pushNotificationWithTitle:(CPString)aTitle message:(CPString)aMessage
{
    [self pushNotificationWithTitle:aTitle message:aMessage icon:TNGrowlIconInfo];
}

/*! display a notification with given type
    anIconType can be:
     - TNGrowlIconInfo
     - TNGrowlIconError
     - TNGrowlIconWarning

    @param aTitle the title of the notification
    @param aMessage the mesage of the notification
    @param anIconType a type of icon.
*/
- (void)pushNotificationWithTitle:(CPString)aTitle message:(CPString)aMessage icon:(CPString)anIconType
{
    [self pushNotificationWithTitle:aTitle message:aMessage customIcon:anIconType];
}

/*! display a notification with a CPImage as icon.
    @param aTitle the title of the notification
    @param aMessage the mesage of the notification
    @param anIcon a CPImage representing the notification icon
*/
- (void)pushNotificationWithTitle:(CPString)aTitle message:(CPString)aMessage customIcon:(id)anIcon
{
    [self pushNotificationWithTitle:aTitle message:aMessage customIcon:anIcon target:nil action:nil actionParameters:nil];
}

/*! display a notification with a CPImage as icon.
    @param aTitle the title of the notification
    @param aMessage the mesage of the notification
    @param anIcon a CPImage representing the notification icon
    @param aTarget the target of the click responder
    @param anAction a selector of aTarget to perform on click
*/
- (void)pushNotificationWithTitle:(CPString)aTitle message:(CPString)aMessage customIcon:(id)anIcon target:(id)aTarget action:(SEL)anAction actionParameters:(id)anObject
{
    var center      = [CPNotificationCenter defaultCenter],
        notifView   = [[TNGrowlView alloc] initWithFrame:_notificationFrame title:aTitle message:aMessage icon:anIcon lifeTime:_defaultLifeTime],
        frame       = [_view frame],
        notifFrame  = CPRectCreateCopy(_notificationFrame),
        animParams  = [CPDictionary dictionaryWithObjectsAndKeys:notifView, CPViewAnimationTargetKey, CPViewAnimationFadeInEffect, CPViewAnimationEffectKey],
        anim        = [[CPViewAnimation alloc] initWithViewAnimations:[animParams]];

    if (_useWindowMouseMoveEvents && ![[_view window] acceptsMouseMovedEvents])
        [[_view window] setAcceptsMouseMovedEvents:YES];

    [center addObserver:self selector:@selector(didReceivedNotificationEndLifeTime:) name:TNGrowlViewLifeTimeExpirationNotification object:notifView];

    notifFrame.origin.x = frame.size.width - _notificationFrame.size.width - TNGrowlPlacementMarginRight;
    notifFrame.origin.y = TNGrowlPlacementMarginTop;

    for (var i = 0; i < [_notifications count]; i++)
    {
        var isViewInThisFrame = NO,
            tmpFrame;

        for (var j = 0; j < [_notifications count]; j++)
        {
            tmpFrame = [[_notifications objectAtIndex:j] frame];

            if ((notifFrame.origin.y == tmpFrame.origin.y) && (notifFrame.origin.x == tmpFrame.origin.x))
            {
                isViewInThisFrame = YES;
                break;
            }
        }

        if (!isViewInThisFrame)
            break;

        notifFrame.origin.y += tmpFrame.size.height + TNGrowlPlacementMarginTop;

        if ((notifFrame.origin.y + notifFrame.size.height) >= frame.size.height)
        {
            notifFrame.origin.x -= (notifFrame.size.width + TNGrowlPlacementMarginRight);
            notifFrame.origin.y = TNGrowlPlacementMarginTop;
        }
    }

    [_notifications addObject:notifView];

    [notifView setAutoresizingMask:CPViewMinXMargin];
    [notifView setFrame:notifFrame];
    [notifView setTarget:aTarget];
    [notifView setAction:anAction];
    [notifView setActionParameters:anObject];

    [_view addSubview:notifView];

    [anim setDuration:0.3];
    [anim startAnimation];
}


#pragma mark -
#pragma mark Delegates

/*! delegate of CPAnimation. Will remove definitly the TNGrowlView
    from the superview
    @param anAnimation the animation that have ended
*/
- (void)animationDidEnd:(CPAnimation)anAnimation
{
    var senderView = [[[anAnimation viewAnimations] objectAtIndex:0] objectForKey:CPViewAnimationTargetKey];

    [_notifications removeObject:senderView];
    [senderView removeFromSuperview];

    if (_useWindowMouseMoveEvents && [[_view window] acceptsMouseMovedEvents] && [_notifications count] == 0);
        [[_view window] setAcceptsMouseMovedEvents:NO];

}

@end
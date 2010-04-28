/*  
 * TNGrowl.j
 *    
 * Copyright (C) 2010 Antoine Mercadal <antoine.mercadal@inframonde.eu>
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@import "TNGrowlView.j";

TNGrowlDefaultDisplayTime               = 5.0;

TNGrowlDefaultCenter                    = nil;

TNGrowlIconInfo     = @"TNGrowlIconInfo";
TNGrowlIconError    = @"TNGrowlIconError";
TNGrowlIconWarning  = @"TNGrowlIconWarning";
TNGrowlIconCustom   = @"TNGrowlIconCustom";

@implementation TNGrowlCenter : CPObject
{
    float       _defaultLifeTime    @accessors(getter=lifeDefaultTime, setter=setDefaultLifeTime:);
    CPColor     _backgroundColor    @accessors(getter=backgroundColor, setter=setBackgroundColor:);
    CPView      _view               @accessors(getter=view, setter=setView:);
    CPImage     _iconCustom         @accessors(getter=customIcon, setter=setCustomIcon:);
    CPArray     _notifications;
    CPRect      _notificationFrame;
    CPImage     _iconInfo;
    CPImage     _iconWarning;
    CPImage     _iconError;
    Boolean     _useWindowMouseMoveEvents;
}

+ (id)defaultCenter
{
    if (!TNGrowlDefaultCenter)
        TNGrowlDefaultCenter = [[TNGrowlCenter alloc] init];
    
    return TNGrowlDefaultCenter;
}

- (id)init
{
    if (self = [super init])
    {
        var bundle = [CPBundle bundleForClass:[self class]];
        
        _notifications      = [CPArray array];
        _notificationFrame  = CGRectMake(10,10,250,80);
        _defaultLifeTime    = [bundle objectForInfoDictionaryKey:@"TNGrowlDefaultLifeTime"];
        _iconInfo           = [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon-info.png"]];
        _iconError          = [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon-error.png"]];
        _iconWarning        = [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon-warning.png"]];
        _backgroundColor    = [CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"background.png"]]];
        
        _useWindowMouseMoveEvents = [bundle objectForInfoDictionaryKey:@"TNGrowlUseMouseMoveEvents"];
    }
    
    return self;
}

- (void)pushNotificationWithTitle:(CPString)aTitle message:(CPString)aMessage
{
    [self pushNotificationWithTitle:aTitle message:aMessage icon:TNGrowlIconInfo];
}

- (void)pushNotificationWithTitle:(CPString)aTitle message:(CPString)aMessage icon:(CPString)anIconType
{
    var icon;
    
    if (_useWindowMouseMoveEvents && ![[_view window] acceptsMouseMovedEvents])
        [[_view window] setAcceptsMouseMovedEvents:YES];
    
    switch (anIconType)
    {
        case TNGrowlIconInfo:
            icon = _iconInfo;
            break;
        
        case TNGrowlIconWarning:
            icon = _iconWarning;
            break;
        
        case TNGrowlIconError:
            icon = _iconError;
            break;
        
        case TNGrowlIconCustom:
            icon = _iconCustom;
            break;
    }
    
    var center      = [CPNotificationCenter defaultCenter];
    var notifView   = [[TNGrowlView alloc] initWithFrame:_notificationFrame title:aTitle message:aMessage icon:icon lifeTime:_defaultLifeTime background:_backgroundColor];
    var frame       = [_view frame];
    var notifFrame  = CPRectCreateCopy(_notificationFrame);
    var animParams  = [CPDictionary dictionaryWithObjectsAndKeys:notifView, CPViewAnimationTargetKey, CPViewAnimationFadeInEffect, CPViewAnimationEffectKey];
    var anim        = [[CPViewAnimation alloc] initWithViewAnimations:[animParams]];
    
    [center addObserver:self selector:@selector(didReceivedNotificationEndLifeTime:) name:TNGrowlViewWillRemoveViewNotification object:notifView];
    
    for (var i = 0; i < [_notifications count]; i++)
    {
        var isViewInThisFrame = NO;
        
        for (var j = 0; j < [_notifications count]; j++)
        {
            var tmpFrame = [[_notifications objectAtIndex:j] frame];
            
            if (notifFrame.origin.y == tmpFrame.origin.y)
            {
                isViewInThisFrame = YES;
                
                break;
            }
        }
        if (!isViewInThisFrame)
            break;
        
        notifFrame.origin.y += _notificationFrame.size.height + 10;
    }
    
    notifFrame.origin.x = frame.size.width - _notificationFrame.size.width - 20;
    
    [_notifications addObject:notifView];
    
    [notifView setFrame:notifFrame];
    
    [_view addSubview:notifView];
    
    [anim setDuration:0.3];
    [anim startAnimation];
}

- (void)didReceivedNotificationEndLifeTime:(CPNotification)aNotification
{
    var center      = [CPNotificationCenter defaultCenter];
    var senderView  = [aNotification object];
    var animView    = [CPDictionary dictionaryWithObjectsAndKeys:senderView, CPViewAnimationTargetKey, CPViewAnimationFadeOutEffect, CPViewAnimationEffectKey];
    var anim        = [[CPViewAnimation alloc] initWithViewAnimations:[animView]];

    [center removeObserver:self name:TNGrowlViewWillRemoveViewNotification object:senderView];

    [anim setDuration:0.3];
    [anim setDelegate:self];
    [anim startAnimation];
}

- (void)animationDidEnd:(CPAnimation)anAnimation
{
    var senderView = [[[anAnimation viewAnimations] objectAtIndex:0] objectForKey:CPViewAnimationTargetKey];
    
    [_notifications removeObject:senderView];
    [senderView removeFromSuperview];
}

@end
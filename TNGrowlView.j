/*  
 * TNGrowlView.j
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
 
TNGrowlViewWillRemoveViewNotification   = @"TNGrowlViewWillRemoveViewNotification";

@implementation TNGrowlView : CPView
{
    CPImageView _icon;
    CPTextField _title;
    CPTextField _message;
    CPTimer     _timer;
    float       _lifeTime;
}

- (id)initWithFrame:(CPRect)aFrame title:(CPString)aTitle message:(CPString)aMessage icon:(CPImage)anIcon lifeTime:(float)aLifeTime background:(CPColor)aBackground
{
    if (self = [super initWithFrame:aFrame])
    {
        _lifeTime   = aLifeTime;
        _icon       = [[CPImageView alloc] initWithFrame:CGRectMake(8, 8, 64, 64)];
        _title      = [[CPTextField alloc] initWithFrame:CGRectMake(78, 5, aFrame.size.width - 78, 20)];
        _message    = [[CPTextField alloc] initWithFrame:CGRectMake(78, 20, aFrame.size.width - 78, aFrame.size.height - 25)];


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
        [self setBorderRadius:5];
        [self setAlphaValue:0.8];

        _timer = [CPTimer scheduledTimerWithTimeInterval:_lifeTime target:self selector:@selector(willBeRemoved:) userInfo:nil repeats:NO];
    }

    return self;
}

- (void)mouseDown:(CPEvent)anEvent
{
    if ([anEvent type] == CPLeftMouseDown)
    {
        [_timer invalidate];
        [self willBeRemoved:nil];
    }

    [super mouseDown:anEvent];
}

- (void)mouseEntered:(CPEvent)anEvent
{
    if ([anEvent type] == CPMouseEntered)
    {
        [_timer invalidate];
        [self setAlphaValue:1.0];
    }
    
    [super mouseEntered:anEvent];
}

- (void)mouseExited:(CPEvent)anEvent
{
    if ([anEvent type] == CPMouseExited)
    {
        _timer = [CPTimer scheduledTimerWithTimeInterval:_lifeTime target:self selector:@selector(willBeRemoved:) userInfo:nil repeats:NO];
    }
    
    [super mouseExited:anEvent];
}

- (void)willBeRemoved:(CPTimer)aTimer
{
    var center = [CPNotificationCenter defaultCenter];

    [center postNotificationName:TNGrowlViewWillRemoveViewNotification object:self];
}

@end

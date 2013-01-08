/*
 * TNGrowlMessage.j
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

@implementation TNGrowlMessage : CPObject
{
    CPString   title       @accessors;
    CPString   message     @accessors;
    CPImage    icon        @accessors;
    CPDate     date        @accessors;
}

+ (TNGrowlMessage)growlMessageWithTitle:(CPString)aTitle message:(CPString)aMessage icon:(CPImage)anIcon
{
    var growlMessage = [[TNGrowlMessage alloc] init];

    [growlMessage setTitle:aTitle];
    [growlMessage setMessage:aMessage];
    [growlMessage setIcon:anIcon];
    [growlMessage setDate:[CPDate date]];

    return growlMessage;
}

@end

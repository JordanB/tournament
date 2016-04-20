//
//  Player.m
//  Tournament
//
//  Created by Jordan Bonnet on 11/6/15.
//  Copyright (c) 2015 Perso. All rights reserved.
//

#import "Player.h"

@implementation Player

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
        @"name": @"name",
        @"score": @"score"
    };
}

@end

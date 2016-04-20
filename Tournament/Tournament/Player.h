//
//  Player.h
//  Tournament
//
//  Created by Jordan Bonnet on 11/6/15.
//  Copyright (c) 2015 Perso. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface Player : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSNumber *score;

@end

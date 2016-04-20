//
//  AddRecordViewController.h
//  Tournament
//
//  Created by Jordan Bonnet on 11/6/15.
//  Copyright (c) 2015 Perso. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol AddRecordViewControllerDelegate;

@interface AddRecordViewController : UIViewController

@property(nonatomic, weak) id<AddRecordViewControllerDelegate> delegate;

- (instancetype)initWithPlayers:(NSArray *)players;

@end


@protocol AddRecordViewControllerDelegate <NSObject>

- (void)addRecordViewController:(AddRecordViewController *)addRecordViewController didFinishWithUpdatedPlayers:(NSArray *)players;

@end

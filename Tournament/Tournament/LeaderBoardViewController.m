//
//  LeaderBoardViewController.m
//  Tournament
//
//  Created by Jordan Bonnet on 11/6/15.
//  Copyright (c) 2015 Perso. All rights reserved.
//

#import "LeaderBoardViewController.h"

#import "AddRecordViewController.h"
#import "Player.h"

#import <Mantle/Mantle.h>


static NSString *kUserDefaultsPlayers = @"players";


@interface LeaderBoardViewController () <AddRecordViewControllerDelegate>

@property (nonatomic) NSArray *players;

@end


@implementation LeaderBoardViewController

#pragma mark - NSObject

- (id)init
{
    self = [super init];
    if (self) {
        NSArray *playersJSON = [[NSUserDefaults standardUserDefaults] arrayForKey:kUserDefaultsPlayers];
        if (playersJSON.count) {
            self.players = [MTLJSONAdapter modelsOfClass:[Player class] fromJSONArray:playersJSON error:nil];
        }
    }
    return self;
}

#pragma mark - Properties

- (void)setPlayers:(NSArray *)players
{
    _players = [players sortedArrayUsingComparator:^NSComparisonResult(Player *player1, Player *player2) {
        return [player2.score compare:player1.score];
    }];
    
    NSArray *playersJSON = [MTLJSONAdapter JSONArrayFromModels:_players error:nil];
    [[NSUserDefaults standardUserDefaults] setObject:playersJSON forKey:kUserDefaultsPlayers];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Ping Pong Leaderboard";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(_addGameAction)];
    
    self.tableView.rowHeight = 90;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.players.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"player";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont systemFontOfSize:35.0f];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:26.0f];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    Player *player = self.players[indexPath.row];
    cell.textLabel.text = player.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d points", player.score.intValue];

    return cell;
}

#pragma mark - AddRecordViewControllerDelegate

- (void)addRecordViewController:(AddRecordViewController *)addRecordViewController didFinishWithUpdatedPlayers:(NSArray *)players
{
    self.players = players;
    [self.tableView reloadData];
}

#pragma mark - Internals

- (void)_addGameAction
{
    AddRecordViewController *addRecordViewController = [[AddRecordViewController alloc] initWithPlayers:self.players];
    addRecordViewController.delegate = self;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:addRecordViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

@end

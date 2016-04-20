//
//  AddRecordViewController.m
//  Tournament
//
//  Created by Jordan Bonnet on 11/6/15.
//  Copyright (c) 2015 Perso. All rights reserved.
//

#import "AddRecordViewController.h"

#import "Player.h"


static const NSUInteger kBaseScore = 1000;
static const NSUInteger kEloConstant = 32;

typedef NS_ENUM(NSUInteger, AddRecordSection) {
    AddRecordSectionExistingPlayer,
    AddRecordSectionCreatePlayer
};


@interface AddRecordViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) NSMutableArray *players;
@property (nonatomic) NSArray *filteredPlayers;

@property (nonatomic) Player *winner;
@property (nonatomic) Player *loser;
@property (nonatomic) BOOL showCreatePlayerButton;

@property (nonatomic) UIBarButtonItem *doneBarButtonItem;
@property (nonatomic) UITextField *winnerTextField;
@property (nonatomic) UITextField *loserTextField;
@property (nonatomic) UITableView *tableView;

@end


@implementation AddRecordViewController

#pragma mark - Public methods

- (instancetype)initWithPlayers:(NSArray *)players
{
    self = [super init];
    if (self) {
        _players = [NSMutableArray arrayWithArray:players];
        _filteredPlayers = players;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Record Game";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(_cancelAction)];
    
    self.doneBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                           target:self
                                                                           action:@selector(_doneAction)];
    self.doneBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = self.doneBarButtonItem;
    
    CGFloat topY = 20 + 44;
    CGFloat height = 60;
    CGFloat margin = 20;
    CGFloat halfWidth = self.view.frame.size.width / 2;
    CGFloat halfWidthWithMargin = halfWidth - 1.5 * margin;
    
    CGRect winnerTextFieldFrame = CGRectMake(margin, topY + margin, halfWidthWithMargin, height);
    self.winnerTextField = [[UITextField alloc] initWithFrame:winnerTextFieldFrame];
    self.winnerTextField.delegate = self;
    self.winnerTextField.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    self.winnerTextField.font = [UIFont systemFontOfSize:30.0f];
    self.winnerTextField.placeholder = @"Winner";
    self.winnerTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    self.winnerTextField.leftViewMode = UITextFieldViewModeAlways;
    self.winnerTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.winnerTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.winnerTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.view addSubview:self.winnerTextField];
    
    CGRect loserTextFieldFrame = CGRectMake(CGRectGetMaxX(winnerTextFieldFrame) + margin, topY + margin, halfWidthWithMargin, height);
    self.loserTextField = [[UITextField alloc] initWithFrame:loserTextFieldFrame];
    self.loserTextField.delegate = self;
    self.loserTextField.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    self.loserTextField.font = [UIFont systemFontOfSize:30.0f];
    self.loserTextField.placeholder = @"Looser";
    self.loserTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    self.loserTextField.leftViewMode = UITextFieldViewModeAlways;
    self.loserTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.loserTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.loserTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.view addSubview:self.loserTextField];
    
    CGFloat topYTableView = CGRectGetMaxY(loserTextFieldFrame) + margin;
    CGFloat widthTableView = self.view.frame.size.width - 2 * margin;
    
    CGRect tableViewFrame = CGRectMake(margin, topYTableView, widthTableView, self.view.frame.size.height - topYTableView);
    self.tableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 60;
    [self.view addSubview:self.tableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.winnerTextField becomeFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self _updateSuggestionsWithName:textField.text];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self _updateSuggestionsWithName:textField.text];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self _updateSuggestionsWithName:textField.text];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self _updateSuggestionsWithName:textField.text];
    return NO;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (self.showCreatePlayerButton ? AddRecordSectionCreatePlayer : AddRecordSectionExistingPlayer) + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == AddRecordSectionExistingPlayer) {
        return self.filteredPlayers.count;
    }
    
    if (section == AddRecordSectionCreatePlayer) {
        return 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == AddRecordSectionExistingPlayer) {
        static NSString *existingPlayerCellIdentifier = @"existing-player";
        
        cell = [tableView dequeueReusableCellWithIdentifier:existingPlayerCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:existingPlayerCellIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.font = [UIFont systemFontOfSize:24.0f];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:20.0f];
        }

        Player *player = self.filteredPlayers[indexPath.row];
        cell.textLabel.text = player.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d points", player.score.intValue];
    }
    
    if (indexPath.section == AddRecordSectionCreatePlayer) {
        static NSString *createPlayerCellIdentifier = @"create-player";
        
        cell = [tableView dequeueReusableCellWithIdentifier:createPlayerCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:createPlayerCellIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.font = [UIFont systemFontOfSize:24.0f];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:20.0f];
            cell.detailTextLabel.textColor = self.view.tintColor;
        }
        
        cell.textLabel.text = [self _currentTextField].text;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Create new player"];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Player *player;
    
    if (indexPath.section == AddRecordSectionExistingPlayer) {
        player = self.filteredPlayers[indexPath.row];
    } else if (indexPath.section == AddRecordSectionCreatePlayer) {
        player = [[Player alloc] init];
        player.name = [self _currentTextField].text;
        player.score = @(kBaseScore);
        [self.players addObject:player];
    }
    
    if (self.winnerTextField.editing) {
        self.winner = player;
        self.winnerTextField.text = player.name;
        [self.loserTextField becomeFirstResponder];
    } else if (self.loserTextField.editing) {
        self.loser = player;
        self.loserTextField.text = player.name;
        [self.loserTextField resignFirstResponder];
    }
    
    [self _updateSuggestionsWithName:@""];
    
    self.doneBarButtonItem.enabled = self.winner && self.loser;
}

#pragma mark - Internals

- (UITextField *)_currentTextField
{
    if (self.winnerTextField.editing) {
        return self.winnerTextField;
    }
    
    if (self.loserTextField.editing) {
        return self.loserTextField;
    }
    
    return nil;
}

- (void)_updateSuggestionsWithName:(NSString *)name
{
    self.showCreatePlayerButton = NO;
    
    self.filteredPlayers = [self.players sortedArrayUsingComparator:^NSComparisonResult(Player *player1, Player *player2) {
        return [player2.score compare:player1.score];
    }];
    
    if (name.length) {
        NSMutableArray *filteredPlayers = [NSMutableArray array];
        self.showCreatePlayerButton = YES;
        for (Player *player in self.filteredPlayers) {
            if ([player.name.lowercaseString rangeOfString:name.lowercaseString].location != NSNotFound) {
                [filteredPlayers addObject:player];
            }
            if ([player.name.lowercaseString isEqualToString:name.lowercaseString]) {
                self.showCreatePlayerButton = NO;
            }
        }
        self.filteredPlayers = filteredPlayers;
    }
    
    [self.tableView reloadData];
}

- (void)_cancelAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_doneAction
{
    NSUInteger winnerScore = self.winner.score.unsignedIntegerValue;
    NSUInteger loserScore = self.loser.score.unsignedIntegerValue;
    
    double winnerTransformedScore = pow(10.f, winnerScore / 400.f);
    double loserTransformedScore = pow(10.f, loserScore / 400.f);
    
    double winnerExpectedScore = winnerTransformedScore / (winnerTransformedScore + loserTransformedScore);
    double loserExpectedScore = loserTransformedScore / (winnerTransformedScore + loserTransformedScore);
    
    double winnerNewScore = winnerScore + kEloConstant * (1.f - winnerExpectedScore);
    double loserNewScore = loserScore + kEloConstant * (0.f - loserExpectedScore);
    
    self.winner.score = @((NSUInteger)round(winnerNewScore));
    self.loser.score = @((NSUInteger)round(loserNewScore));
    
    [self.delegate addRecordViewController:self didFinishWithUpdatedPlayers:self.players];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

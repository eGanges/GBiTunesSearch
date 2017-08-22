//
//  gbisResultsTableViewController.m
//  GBiTunesSearch
//
//  Created by Edward C Ganges on 8/19/17.
//  Copyright © 2017 Edward C Ganges. All rights reserved.
//

#import "AppDelegate.h"
#import "gbisResultsTableViewController.h"
#import "gbisResultsCell.h"
#import "gbisDetailViewController.h"

@interface gbisResultsTableViewController ()

@property (strong, nonatomic) UISearchController *searchController;
@property (weak, nonatomic) AppDelegate* appDelegate;
@property (weak, nonatomic) NSArray* resultSetArray;
@property (weak, nonatomic) NSDictionary* resultSetItemDict;


typedef NS_ENUM(NSInteger, UYLWorldFactsSearchScope)
{
    searchScopeCountry = 0,
    searchScopeCapital = 1
};

@end

@implementation gbisResultsTableViewController

#pragma mark - === View Life Cycle Management ===
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!_appDelegate) _appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    _resultSetArray = [_appDelegate.searchResultSet objectForKey:@"results"];
    
    
    self.title = NSLocalizedString(@"GBISTableViewTitle", @"GB iTunes Search");
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
    self.tableView.estimatedRowHeight = 64.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _resultSetArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"gbisTrackCellIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    _resultSetItemDict = [_resultSetArray objectAtIndex:indexPath.row];
    [((gbisResultsCell*)cell) configureCellFromDict:_resultSetItemDict];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (kLogIsOn) NSLog(@"resultsTVC %@: \nsender: %@", NSStringFromSelector(_cmd), sender);
    if (kLogIsOn) NSLog(@"resultsTVC %@: \ndest: %@", NSStringFromSelector(_cmd), [segue destinationViewController]);
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"segResultCelToDetail"]) {
        _appDelegate.searchResultSetItemDict = ((gbisResultsCell*)sender).resultSetItemDict;
        
        //((gbisDetailViewController*)[segue destinationViewController]).resultSetItemDict = ((gbisResultsCell*)sender).resultSetItemDict;
    }
}


- (void)didChangePreferredContentSize:(NSNotification *)notification
{
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}



@end

//
//  gbisDetailViewController.m
//  GBiTunesSearch
//
//  Created by Edward C Ganges on 8/19/17.
//  Copyright © 2017 Edward C Ganges. All rights reserved.
//
//  Details View


#import "gbisDetailViewController.h"
#import "AppDelegate.h"

@interface gbisDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *trackNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionView;
@property (weak, nonatomic) IBOutlet UIImageView *artworkImageView;
@property (weak, nonatomic) AppDelegate* appDelegate;

@end

@implementation gbisDetailViewController
@synthesize resultSetItemDict;

- (void)setResultItem:(gbisResultItem *)newResultItem
{
    if (_resultItem != newResultItem)
    {
        _resultItem = newResultItem;
        [self configureView];
    }
}

- (void)configureView
{
    if (!_artworkImageView.image) {
        
        if ([resultSetItemDict isKindOfClass:[NSDictionary class]] && resultSetItemDict) {
            [self configureViewFromDict:resultSetItemDict];
        }
        else {
            if (!_appDelegate) _appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            [self configureViewFromDict:_appDelegate.searchResultSetItemDict];
        }
    }
}

-(void) configureViewFromDict:(NSDictionary*)dict {
    if (kLogIsOn) NSLog(@"detailVC %@: \ndict:%@", NSStringFromSelector(_cmd), dict);
    
    if (!_appDelegate) _appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    _trackNameLabel.text = [dict objectForKey:@"trackName"];
    if ([dict objectForKey:@"description"]) {
        _descriptionView.text =  [dict objectForKey:@"description"];
    } else if ([dict objectForKey:@"longDescription"]) {
        _descriptionView.text =  [dict objectForKey:@"longDescription"];
    } else if ([dict objectForKey:@"shortDescription"]) {
        _descriptionView.text =  [dict objectForKey:@"shortDescription"];
    } else {
        _descriptionView.text = @"Description: NA";
    }
    _artworkImageView.image = _appDelegate.searchPlaceholderImage100x100;
    // lazy load actual image
    NSURL *imageURL = [NSURL URLWithString:[dict objectForKey:@"artworkUrl100"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:imageURL];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    // dispatch Async
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if ( [data length] > 0 && !error ) { // Success
            UIImage* theImage = [UIImage imageWithData:data];
            // return to main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                _artworkImageView.image = theImage;
                //[self updateImageView:_artworkImageView withImage:theImage];
            });
        }
        else {
            if (kLogIsOn) NSLog(@"detailVC %@: async FAIL", NSStringFromSelector(_cmd) );
        }
    }];
    
}


#pragma mark === View Life Cycle Management ===

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)didChangePreferredContentSize:(NSNotification *)notification
{
    [self configureView];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
- (IBAction)unwindToMainMenu:(UIStoryboardSegue*)sender
{
    UIViewController *sourceViewController = sender.sourceViewController;
    // Pull any data from the view controller which initiated the unwind segue.
}

- (IBAction)doneButtonClicked:(id)sender
{
    if (kLogIsOn) NSLog(@"detailVC %@: %@, \nnavCon:%@", NSStringFromSelector(_cmd), sender, self.navigationController);
    
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissModalViewControllerAnimated:YES];
}



/*

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

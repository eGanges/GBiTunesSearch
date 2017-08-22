//
//  gbisSearchViewController.m
//  GBiTunesSearch
//
//  Created by Edward C Ganges on 8/21/17.
//  Copyright © 2017 Edward C Ganges. All rights reserved.
//

#import "gbisSearchViewController.h"
#import "AppDelegate.h"
#import "gbisRetriever.h"

@interface gbisSearchViewController ()
@property (weak, nonatomic) AppDelegate* appDelegate;
@property (nonatomic, strong) NSURLRequest *myRequest;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, strong) UIActivityIndicatorView *progressView;

@end

@implementation gbisSearchViewController
@synthesize contentView, progressView, content, myRequest;

- (void)viewDidLoad {
   if (kLogIsOn) NSLog(@"svc %@: ", NSStringFromSelector(_cmd));
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    contentView = self.view;
    if (!_appDelegate) _appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
     // create our progress indicator for busy feedback while loading web pages,
    CGRect frame = CGRectMake(contentView.center.x - 20.0, contentView.center.y - 20.0, 40.0, 40.0);
    progressView = [[UIActivityIndicatorView alloc] initWithFrame:frame];
    progressView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    progressView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                     UIViewAutoresizingFlexibleRightMargin |
                                     UIViewAutoresizingFlexibleTopMargin |
                                     UIViewAutoresizingFlexibleBottomMargin);
    progressView.hidesWhenStopped = YES;
    [progressView startAnimating];
    [contentView addSubview:progressView];

    // compile Content page
    NSString* theContent = nil;
    if (!theContent) {
        
        // load the search form
        NSError* error = nil;
        NSURL* theURL = [[NSBundle mainBundle] URLForResource:@"gbisSearchView" withExtension:@"html"];;
        NSString* theNewContent = [NSString stringWithContentsOfURL:theURL encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            theNewContent = @"We appologize, there was an error retrieving the credits information.";
        }
        else {
            theNewContent = [self updateSearchFormContent:theNewContent];
            if (kLogIsOn) NSLog(@"svc %@: \n theNewContent: %@ ", NSStringFromSelector(_cmd), theNewContent);
       }
        theContent = [NSString stringWithString:theNewContent];
    }
    // this title will appear in the navigation bar
    self.title = NSLocalizedString(@"", @"");
    self.myRequest = nil;
    self.content = theContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [progressView startAnimating];
    [myWebView loadHTMLString:content baseURL:nil];
}


- (void) viewDidAppear:(BOOL)animated {
    BOOL logIsOn = true;
    if (logIsOn) NSLog(@"svc %@: ", NSStringFromSelector(_cmd));
    
    [super viewDidAppear:animated];
    
    //    [self processSearchRequestForURLString:@"https://itunes.apple.com/search?term=jack+johnson&entity=musicVideo"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Dynamic HTML
- (NSString*) updateSearchFormContent:(NSString*)theContent {
    // replace/inject all relevant strings
    NSString* theNewContent = [NSString stringWithString:theContent];
    int currentStringIndex = 0;
    for (NSString* theSubString in [NSArray arrayWithObjects:
                                    @"<!-- ##appVersion## -->",
                                    @"<!-- ##entityOptions## -->",
                                    nil])
    {
        NSString* theNewString = @"";
        currentStringIndex++;
        NSString* fullStringToReplace = [NSString stringWithFormat:@"%@", theSubString];
        
        // set new calculated value per string
        switch (currentStringIndex) {
            case 1: {
                theNewString = [self updateSearchFormContentAppVersion];
            }
            break;
                
            case 2: {
                theNewString = [self updateSearchFormContentEntityOptions];
            }
            break;
                
            default: {}
            break;
        }
        if (kLogIsOn) NSLog(@"svc %@: \n theNewString %i: %@ ", NSStringFromSelector(_cmd), currentStringIndex, theNewString);
       // update the overall content
        theNewContent = [theNewContent stringByReplacingOccurrencesOfString:fullStringToReplace withString:theNewString];
        if (kLogIsOn) NSLog(@"svc %@: \n theNewContent %d: %@ ", NSStringFromSelector(_cmd), currentStringIndex, theNewContent);
    }
    return theNewContent;
}
- (NSString*) updateSearchFormContentAppVersion {
    // Gather version info
    NSString* theNewString = [NSString stringWithFormat:@"%@.%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    
    return theNewString;
}

- (NSString*) updateSearchFormContentEntityOptions {
    
    // get the opetions from the entities plist
    NSArray *items = [self updateSearchFormContentEntityOptions_getArray];
    if (kLogIsOn) NSLog(@"svc %@: \nitems: %@ ", NSStringFromSelector(_cmd), items);
    
    // use the items array to create the html <options> list
    NSString* theNewString = @"";
    NSString* theKey = nil;
    NSString* theValue = nil;
   for (NSString* keyValuePair in items) {
        NSArray* components = [keyValuePair componentsSeparatedByString:@"|"];
        theKey = [components objectAtIndex:0];
        theValue = [components lastObject];
       theNewString = [theNewString stringByAppendingString:[NSString stringWithFormat: @"<option value='%@'>%@</option>", theKey, theValue]];
   }
    
    //
    return theNewString;
}

- (NSArray*) updateSearchFormContentEntityOptions_getArray {
    // read entities plist from bundle
    NSDictionary* mediaDict = nil;
    NSString *error;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MediaEntity" ofType:@"plist"];
    NSData *plistData = [NSData dataWithContentsOfFile:path];
    NSPropertyListFormat format;
    mediaDict = [NSPropertyListSerialization propertyListFromData:plistData
                                             mutabilityOption:NSPropertyListImmutable
                                                       format:&format
                                             errorDescription:&error];
    if (kLogIsOn) NSLog(@"svc %@: \nitems: %@ \nerror:%@", NSStringFromSelector(_cmd), mediaDict, error);
    
    
    // build Entity Options from the Media/Entity dictionary,
    NSMutableArray* items = [[NSMutableArray alloc] init];
    for (NSString* theMediakey in [mediaDict allKeys]) {
        // where each mediaKey has an array of entityStrings
       for (NSString* theEntityKey in [mediaDict objectForKey:theMediakey]) {
           if ([theEntityKey isEqualToString:theMediakey]) {
               [items addObject:[NSString stringWithFormat:@"%@|%@", theEntityKey, theEntityKey]];
           } else {
               [items addObject:[NSString stringWithFormat:@"%@|%@ - %@", theEntityKey, theMediakey, theEntityKey]];
           }
        }
    }
    
    // return NON-mutable array
    return [NSArray arrayWithArray:items];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"segSearchToResults"]) {
        
    }
}

#pragma mark - Process Submitted Search
- (void) processSearchRequestForURLString:(NSString*)urlSearchString {
    BOOL logIsOn = true;
    if (logIsOn) NSLog(@"svc %@: %@", NSStringFromSelector(_cmd), urlSearchString);
   
    // parse the search string into a dictionary of name/value params
    int implicitIndex = 0;
    NSString* itemKey = nil;
    NSString* itemValue = nil;
    NSArray* urlSegmentArray = [urlSearchString componentsSeparatedByString:@"?"];
    NSArray* enumArray = [[urlSegmentArray lastObject] componentsSeparatedByString:@"&"];
    // log
    if (logIsOn) NSLog(@"svc %@: \n%@ \n%@", NSStringFromSelector(_cmd), urlSegmentArray, enumArray);

    
    NSMutableDictionary* enumDict = [[NSMutableDictionary alloc] initWithCapacity:enumArray.count];
    // if (logIsOn) NSLog(@"enumArray: %@", enumArray);
    
    for (NSString* itemPair in enumArray) {
        NSArray* itemPairArray = [itemPair componentsSeparatedByString:@"="];
        itemKey = [[[itemPairArray objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
        itemValue = [[itemPairArray lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [enumDict setValue:itemValue forKey:itemKey];
        implicitIndex++;
    }
    
    // extract the params
    NSString* theTerm = [enumDict valueForKey:@"term"];
    NSString* theEntity = [enumDict valueForKey:@"entity"];
    
    
    // prepare to listen
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SearchCompletedNotification:) name:kSearchCompletedNotification object:nil];
   
    // retrieve results form iTunes store, using Retriever
    gbisRetriever* retriever = [gbisRetriever sharedInstance];
    [retriever retrieveTerm:theTerm forEntity:theEntity];
    
    // WAIT!
    // and now we wait for the SearchCompletedNotification...
}


- (void) SearchCompletedNotification:(NSNotification*)note {
    if (kLogIsOn) NSLog(@"searchVC %@: \n%@ \nnote:\n%@", NSStringFromSelector(_cmd), _appDelegate, note);

    // stop listening
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSearchCompletedNotification object:nil];
    
    // check for abort
    if (_appDelegate.searchIsAborted) {
        [self notifyUserOfError:_appDelegate.searchIsAbortedMessage];
        return;
    }
    // else ...
    
    
    // hold the resultSet for the tableViewController
    _appDelegate.searchResultSet = note.userInfo;
    
    // stop the spinner
    [progressView stopAnimating];
    
    // segue to the tableview
    [self performSegueWithIdentifier:@"segSearchToResults" sender:self];
}

#pragma mark UIWebView delegate methods


- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (kLogIsOn) NSLog(@"searchVC %@: ", NSStringFromSelector(_cmd));
    
    [progressView startAnimating];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (kLogIsOn) NSLog(@"searchVC %@: \nrequest: %@ \nnType: %ld", NSStringFromSelector(_cmd), request, (long)navigationType);
 
    [progressView startAnimating];
    
    // are these the droids we are looking for?
    NSString* urlString = request.URL.absoluteString;
    if ([[urlString substringToIndex:7] isEqualToString:@"gbis://"]) {
        
        // process search request
        [self processSearchRequestForURLString:urlString];

        // suspend webview update
        return NO;
    }
    // else...
    
    return YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (kLogIsOn) NSLog(@"searchVC %@: ", NSStringFromSelector(_cmd));
    
    [progressView stopAnimating];
}



#pragma mark - Exception handling
- (void)notifyUserOfError:(NSString *)errorText
{
    // basic notification
     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Something Went Wrong"
                                                        message:_appDelegate.searchIsAbortedMessage
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    
    [alertView show];
    
}
@end

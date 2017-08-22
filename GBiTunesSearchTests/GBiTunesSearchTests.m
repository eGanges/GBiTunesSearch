//
//  GBiTunesSearchTests.m
//  GBiTunesSearchTests
//
//  Created by Edward C Ganges on 8/19/17.
//  Copyright © 2017 Edward C Ganges. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AppDelegate.h"
#import "gbisSearchViewController.h"
#import "gbisRetriever.h"
#import "gbisCache.h"
#import "gbisResultsTableViewController.h"
#import "gbisDetailViewController.h"

@interface GBiTunesSearchTests : XCTestCase
@property (weak, nonatomic) AppDelegate* appDelegate;
@property (strong, nonatomic)gbisSearchViewController* gSearchViewController;
@property (strong, nonatomic)gbisRetriever* gRetriever;
@property (strong, nonatomic)gbisCache* gCache;
@property (strong, nonatomic)gbisResultsTableViewController* gResultsTableViewController;
@property (strong, nonatomic)gbisDetailViewController* gDetailViewController;

@end

@implementation GBiTunesSearchTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // init AppDelegate
    if (!_appDelegate) _appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    _appDelegate.searchIsAborted = false;
    _appDelegate.searchIsAbortedMessage = nil;
    _appDelegate.searchIsLoadedFromCache = false;
    _appDelegate.searchResultSet = nil;
    _appDelegate.searchResultSetItemDict = nil;

    // init Other Classes
    _gSearchViewController = [[gbisSearchViewController alloc] init];
    _gRetriever = [gbisRetriever sharedInstance];
    _gCache = [gbisCache sharedInstance];
    _gResultsTableViewController = [[gbisResultsTableViewController alloc] init];
    _gDetailViewController = [[gbisDetailViewController alloc] init];

}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

#pragma mark - ABORTS
- (void)testSearchAbortsOnSearchTermNil {
    
    [_gRetriever retrieveTerm:nil forEntity:@"music"];
    
    XCTAssert(_appDelegate.searchIsAborted);
    XCTAssertNotNil(_appDelegate.searchIsAbortedMessage);
}

- (void)testSearchAbortsOnSearchTermEmpty {
    
    [_gRetriever retrieveTerm:@" " forEntity:@"music"];
    
    XCTAssert(_appDelegate.searchIsAborted);
    XCTAssertNotNil(_appDelegate.searchIsAbortedMessage);
}

- (void)testSearchAbortsOnSearchEntityNil {
    
    [_gRetriever retrieveTerm:@"Wonder" forEntity:nil];
    
    XCTAssert(_appDelegate.searchIsAborted);
    XCTAssertNotNil(_appDelegate.searchIsAbortedMessage);
}

- (void)testSearchAbortsOnSearchEntityEmpty {
    
    [_gRetriever retrieveTerm:@"Wonder" forEntity:@" "];
    
    XCTAssert(_appDelegate.searchIsAborted);
    XCTAssertNotNil(_appDelegate.searchIsAbortedMessage);
}

- (void)todoSearchAbortsOnInvalidNetworkConnection {
    // TO DO
}

- (void)todoSearchAbortsOnInvalidURL {
    // TO DO
}

#pragma mark - CACHE
- (void)testCacheStoresObjects {
    
    NSString* sTerm = @"jack+johnson";
    NSString* sEntity = @"musicVideo";
    NSString* storeURLString = [NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&entity=%@&limit=5", sTerm, sEntity];
    
    // validate not present
    XCTAssertNil([_gCache getSearchForStoreString:storeURLString]);
    
    // validate not added via Get call
    XCTAssertNil([_gCache getSearchForStoreString:storeURLString]);
    
    // add to CACHE
    [_gRetriever retrieveTerm:sTerm forEntity:sEntity];
    
    // verify Added
    XCTAssertNotNil([_gCache getSearchForStoreString:storeURLString]);
    
    // delete it
    [_gCache deleteSearchResultForStoreURLString:storeURLString];
}

- (void)testCacheGetsAreNSDictionary {
    
    NSString* sTerm = @"woman";
    NSString* sEntity = @"musicVideo";
    NSString* storeURLString = [NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&entity=%@&limit=5", sTerm, sEntity];
    
    // add to CACHE (on BG thread)
    [_gRetriever retrieveTerm:sTerm forEntity:sEntity];
    
    // wait for search to complete on BG thread
    [NSThread sleepForTimeInterval:3.0f];
    
    // check object structure
    id resultSet = [_gCache getSearchForStoreString:storeURLString];
    if (kLogIsOn) NSLog(@"test %@: \nclass:%@", NSStringFromSelector(_cmd), resultSet);
    XCTAssertTrue([resultSet isKindOfClass:[NSDictionary class]]);
    
    id resultSetArray = [resultSet objectForKey:@"results"];
    if (kLogIsOn) NSLog(@"test %@: \nclass:%@", NSStringFromSelector(_cmd), resultSetArray);
    XCTAssertTrue([resultSetArray isKindOfClass:[NSArray class]]);
    
    id resultSetItemDict = [resultSetArray lastObject];
    if (kLogIsOn) NSLog(@"test %@: \nclass:%@", NSStringFromSelector(_cmd), resultSetItemDict);
    XCTAssertTrue([resultSetItemDict isKindOfClass:[NSDictionary class]]);
    
    // delete it
    [_gCache deleteSearchResultForStoreURLString:storeURLString];
}

- (void)testCacheDeletes {
    
    NSString* sTerm = @"jack+johnson";
    NSString* sEntity = @"musicVideo";
    NSString* storeURLString = [NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&entity=%@&limit=5", sTerm, sEntity];
    
    // delete it, if necessary - NOTE: this does not prove test
        [_gCache deleteSearchResultForStoreURLString:storeURLString];
    // validate not present
        XCTAssertNil([_gCache getSearchForStoreString:storeURLString]);
    // add to CACHE
        [_gRetriever retrieveTerm:sTerm forEntity:sEntity];
    // verify Added
        XCTAssertNotNil([_gCache getSearchForStoreString:storeURLString]);
    // delete it
        XCTAssertTrue([_gCache deleteSearchResultForStoreURLString:storeURLString]);
    // validate not present
        XCTAssertNil([_gCache getSearchForStoreString:storeURLString]);
}

#pragma mark - Performance Tests
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

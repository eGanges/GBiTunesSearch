//
//  gbisResultsTCell.m
//  GBiTunesSearch
//
//  Created by Edward C Ganges on 8/19/17.
//  Copyright © 2017 Edward C Ganges. All rights reserved.
//

#import "gbisResultsCell.h"
#import "AppDelegate.h"

@interface gbisResultsCell ()
@property (weak, nonatomic) IBOutlet UILabel *trackNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *pricingLabel;
@property (weak, nonatomic) IBOutlet UILabel *entityTypeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *artworkSmallImageView;

@property (copy, nonatomic) NSString *trackName;
@property (copy, nonatomic) NSString *pricing;
@property (copy, nonatomic) NSString *entityType;
@property (copy, nonatomic) UIImage *artworkSmall;


@property (weak, nonatomic) NSString *artworkSmallURLString;
@property (weak, nonatomic) AppDelegate* appDelegate;

@end

@implementation gbisResultsCell
@synthesize resultSetItemDict;

-(void) configureCellFromDict:(NSDictionary*)dict {
    if (kLogIsOn) NSLog(@"resultsCell %@: ", NSStringFromSelector(_cmd));
    
    if (!_appDelegate) _appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    // hold this dictionary for future (details view) use
    resultSetItemDict = [NSDictionary dictionaryWithDictionary:dict];
    _artworkSmallURLString = [resultSetItemDict objectForKey:@"artworkUrl60"];
    
    
    // update this display
    [self setTrackName:[dict objectForKey:@"trackName"]];
    if ([dict objectForKey:@"trackPrice"]) {
        [self setPricing:[NSString stringWithFormat:@"$%@",  [dict objectForKey:@"trackPrice"]]];
    } else {
        [self setPricing:@"NA"];
    }
    [self setEntityType:[dict objectForKey:@"kind"]];
    [self setArtworkSmall:nil];

}


- (void)setTrackName:(NSString *)trackName {
    if (kLogIsOn) NSLog(@"resultsCell %@: ", NSStringFromSelector(_cmd));
    
    if (_trackName != trackName) {
        _trackName = [trackName copy];
        _trackNameLabel.text =trackName;
        _trackNameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    }
}

- (void)setPricing:(NSString *)pricing {
    if (kLogIsOn) NSLog(@"resultsCell %@: ", NSStringFromSelector(_cmd));
    
    if (_pricing != pricing) {
        _pricing = [pricing copy];
        _pricingLabel.text = pricing;
        _pricingLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    }
}

- (void)setEntityType:(NSString *)entityType {
    if (kLogIsOn) NSLog(@"resultsCell %@: ", NSStringFromSelector(_cmd));
    
    if (_entityType != entityType) {
        _entityType = [entityType copy];
        _entityTypeLabel.text = entityType;
        _entityTypeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    }
}

- (void)setArtworkSmall:(UIImage *)artworkSmall {
    if (kLogIsOn) NSLog(@"resultsCell %@: ", NSStringFromSelector(_cmd));

        _artworkSmallImageView.image = _appDelegate.searchPlaceholderImage60x60;
        
        // lazy load actual image
        // dispatch Async
       NSURL *imageURL = [NSURL URLWithString:_artworkSmallURLString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:imageURL];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            if ( [data length] > 0 && !error ) { // Success
                UIImage* theImage = [UIImage imageWithData:data];
                // return to main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateImageView:_artworkSmallImageView withImage:theImage];
                });
             }
            else {
                if (kLogIsOn) NSLog(@"resultsCell %@: async FAIL", NSStringFromSelector(_cmd) );
            }
        }];
}

-(void) updateImageView:(UIImageView*)iv withImage:(UIImage*)img {
    if (kLogIsOn) NSLog(@"resultsCell %@: ", NSStringFromSelector(_cmd));
    iv.image = img;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

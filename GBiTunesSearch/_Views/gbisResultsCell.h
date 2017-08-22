//
//  gbisResultsTCell.h
//  GBiTunesSearch
//
//  Created by Edward C Ganges on 8/19/17.
//  Copyright © 2017 Edward C Ganges. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface gbisResultsCell : UITableViewCell

@property (nonatomic, strong) NSDictionary* resultSetItemDict;

-(void) configureCellFromDict:(NSDictionary*)dict;
@end

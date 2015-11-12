//
//  SearchResultCell.h
//  StoreSearch
//
//  Created by FLY.lxm on 11/10/15.
//  Copyright © 2015 FLY.lxm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel; 
@property (nonatomic, weak) IBOutlet UILabel *sellerNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *artworkImageView;

@end

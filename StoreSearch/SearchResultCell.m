//
//  SearchResultCell.m
//  StoreSearch
//
//  Created by FLY.lxm on 11/10/15.
//  Copyright © 2015 FLY.lxm. All rights reserved.
//

#import "SearchResultCell.h"
#import "SearchResult.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@implementation SearchResultCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UIView *selectedView = [[UIView alloc] initWithFrame:CGRectZero];
    selectedView.backgroundColor = [UIColor colorWithRed:20/255.0f green:160/255.0f blue:160/255.0f alpha:.45f];
    self.selectedBackgroundView = selectedView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureForSearchResult:(SearchResult *)searchResult {
    self.nameLabel.text = searchResult.name ? searchResult.name : @"unknown";
    [self.artworkImageView setImageWithURL:[NSURL URLWithString:searchResult.artworkURL100] placeholderImage:[UIImage imageNamed:@"Placeholder"]];
    
//    if ([searchResult.kind isEqualToString:@"song"] || [searchResult.kind isEqualToString:@"music-video"]) {
//        self.artistNameLabel.text = [NSString stringWithFormat:@"%@(%@)",searchResult.artistName, searchResult.genres[0]];
//        return;
//    }
    
    self.artistNameLabel.text = searchResult.genres[0];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.artworkImageView cancelImageRequestOperation];
    self.nameLabel.text = nil;
    self.artistNameLabel.text = nil;
}

@end

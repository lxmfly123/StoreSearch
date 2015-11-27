//
//  SearchResult.m
//  StoreSearch
//
//  Created by FLY.lxm on 11/10/15.
//  Copyright © 2015 FLY.lxm. All rights reserved.
//

#import "SearchResult.h"

@implementation SearchResult

- (NSString *)kindForDisplay {
    if ([self.kind isEqualToString:@"album"]) {
        return NSLocalizedString(@"Album", @"Localized kind: Album");
    } else if ([self.kind isEqualToString:@"software"]) {
        return NSLocalizedString(@"App", @"Localized kind: software");
    } else if ([self.kind isEqualToString:@"music-video"]) {
        return NSLocalizedString(@"MV", @"Localized kind: music-video");
    } else if ([self.kind isEqualToString:@"song"]) {
        return NSLocalizedString(@"Song", @"Localized kind: song");
    } else {
        return self.kind.capitalizedString;
    }
}

@end

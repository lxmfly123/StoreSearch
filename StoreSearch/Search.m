//
//  Search.m
//  StoreSearch
//
//  Created by FLY.lxm on 11/20/15.
//  Copyright © 2015 FLY.lxm. All rights reserved.
//

#import "Search.h"

@interface Search ()

@property (nonatomic, readwrite, strong) NSMutableArray *searchResults;

@end

@implementation Search

- (void)performSearchForText:(NSString *)text category:(NSInteger)category {
    
}

- (void)dealloc {
    NSLog(@"Dealloc %@", self);
}

@end

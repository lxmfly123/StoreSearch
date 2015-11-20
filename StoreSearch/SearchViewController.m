//
//  SearchViewController.m
//  StoreSearch
//
//  Created by FLY.lxm on 11/10/15.
//  Copyright © 2015 FLY.lxm. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResult.h"
#import "SearchResultCell.h"
#import "DetailViewController.h"
#import "LandscapeViewController.h"
#import "Search.h"
#import <AFNetworking/AFNetworking.h>

static NSString * const SearchResultCellIdentifier = @"SearchResultCell";
static NSString * const NothingFoundCellIdentifier = @"NothingFoundCell";
static NSString * const LoadingCellIdentifier = @"LoadingCell";

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedContol;

@property (nonatomic, strong) Search *search;

@end

@implementation SearchViewController
{
    NSMutableArray *_searchResults;
    BOOL _isLoading;
    NSOperationQueue *_queue;
    LandscapeViewController *_landscapeViewController;
    UIStatusBarStyle _statusBarStyle;
    DetailViewController *_detailViewController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _queue = [NSOperationQueue new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.layer.cornerRadius = 10;
    _statusBarStyle = UIStatusBarStyleDefault;
    
    [self.searchBar becomeFirstResponder];
    
    self.tableView.contentInset = UIEdgeInsetsMake(108, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    self.tableView.rowHeight = 80;
    
    UINib *cellNib = [UINib nibWithNibName:SearchResultCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:SearchResultCellIdentifier];
    
    cellNib = [UINib nibWithNibName:@"NothingFoundCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:NothingFoundCellIdentifier];
    
    cellNib = [UINib nibWithNibName:@"LoadingCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:LoadingCellIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Logic

- (NSURL *)urlWithSearchText:(NSString *)text category:(NSInteger)category {
    NSString *categoryName;
    switch (category) {
        case 0:
            categoryName = @"software";
            break;
            
        case 1:
            categoryName = @"musicTrack";
            break;
            
        default:
            break;
    }
    
    NSString *encodedText = [text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
    
    NSURL *searchURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&country=cn&entity=%@&limit=50", encodedText, categoryName]];
    return searchURL;
}

- (void)showNetworkError {
    UIAlertController *alert =[UIAlertController alertControllerWithTitle:@"Error" 
                                                                  message:@"There is a error in your network." 
                                                           preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancleAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancleAlert];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)parseDictionary:(NSDictionary *)dictionary {
    NSArray *array = dictionary[@"results"];
    
    if (array == nil) {
        [self showNetworkError];
        return;
    }
    
    for (NSDictionary *resultDictionary in array) {
        SearchResult *searchResult;
        
        NSString *wrapperType = resultDictionary[@"wrapperType"];
        
        if ([wrapperType isEqualToString:@"software"]) { 
            searchResult = [self parseApp:resultDictionary];
            [_searchResults addObject:searchResult];
        } else if ([wrapperType isEqualToString:@"track"]) {
            searchResult = [self parseMusic:resultDictionary];
            [_searchResults addObject:searchResult];
        }
    }
}

- (SearchResult *)parseApp:(NSDictionary *)resultDictionary {
    SearchResult *searchResult = [SearchResult new];
    
    searchResult.name = resultDictionary[@"trackCensoredName"];
    searchResult.artistName = resultDictionary[@"artistName"];
    searchResult.artworkURL60 = resultDictionary[@"artworkUrl60"];
    searchResult.artworkURL100 = resultDictionary[@"artworkUrl100"];
    searchResult.artworkURL512 = resultDictionary[@"artworkUrl512"];
    searchResult.trackViewUrl = resultDictionary[@"trackViewUrl"];
    searchResult.kind = resultDictionary[@"kind"];
    searchResult.currency = resultDictionary[@"currency"];
    searchResult.price = resultDictionary[@"formattedPrice"];
    searchResult.genres = (NSArray *)resultDictionary[@"genres"];
    searchResult.storeUrl = resultDictionary[@"trackViewUrl"];
//    searchResult.image = [UIImage imageWithData:<#(nonnull NSData *)#>]
    
    return searchResult;
}

- (SearchResult *)parseMusic:(NSDictionary *)resultDictionary {
    SearchResult *searchResult = [SearchResult new];
    
    searchResult.name = resultDictionary[@"trackCensoredName"];
    searchResult.artistName = resultDictionary[@"artistName"];
    searchResult.artworkURL60 = resultDictionary[@"artworkUrl60"];
    searchResult.artworkURL100 = resultDictionary[@"artworkUrl100"];
    searchResult.trackViewUrl = resultDictionary[@"trackViewUrl"];
    searchResult.kind = resultDictionary[@"kind"];
    searchResult.currency = resultDictionary[@"currency"];
    searchResult.price = @"免费";
    searchResult.genres = @[resultDictionary[@"primaryGenreName"]];
    searchResult.storeUrl = resultDictionary[@"trackViewUrl"];
    //    searchResult.image = [UIImage imageWithData:<#(nonnull NSData *)#>]
    
    return searchResult;
}

- (void)performSearch {
    if ([self.searchBar.text length] > 0) {
        _isLoading = YES;
        _searchResults = [NSMutableArray new];
        [_queue cancelAllOperations];
        
        [self.searchBar resignFirstResponder];
        [self.tableView reloadData];
        
        NSURL *url = [self urlWithSearchText:self.searchBar.text category:self.segmentedContol.selectedSegmentIndex];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            [self parseDictionary:responseObject];
            _isLoading = NO;
            
            [self.tableView reloadData];
            
        } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
            if (operation.isCancelled) {
                return;
            }
            _isLoading = NO;
            [self.tableView reloadData];
        }];
        
        [_queue addOperation:operation];
    } else {
        _searchResults = nil;
        [self.tableView reloadData];
    }
}

// This method is for iOS less than iOS 8.
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        [self hideLandscapeViewWithDuration:duration];
    } else {
        [self showLandscapeViewWithDuration:duration];
    }

}

- (UIInterfaceOrientation)orientationFromTransform:(CGAffineTransform)transform {
    // This method comes from [here](http://blog.inferis.org/blog/2015/04/27/ios8-and-interfaceorientation/)
    
    CGFloat angle = atan2f(transform.b, transform.a);
    NSInteger multiplier = (NSInteger)roundf(angle / M_PI_2);
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (multiplier < 0) {
        // clockwise rotation
        while (multiplier++ < 0) {
            switch (orientation) {
                case UIInterfaceOrientationPortrait:
                    orientation = UIInterfaceOrientationLandscapeLeft;
                    break;
                case UIInterfaceOrientationLandscapeLeft:
                    orientation = UIInterfaceOrientationPortraitUpsideDown;
                    break;
                case UIInterfaceOrientationPortraitUpsideDown:
                    orientation = UIInterfaceOrientationLandscapeRight;
                    break;
                case UIInterfaceOrientationLandscapeRight:
                    orientation = UIInterfaceOrientationPortrait;
                    break;
                default:
                    break;
            }
        }
    } else if (multiplier > 0) {
        // counter-clockwise rotation
        while (multiplier-- > 0) {
            switch (orientation) {
                case UIInterfaceOrientationPortrait:
                    orientation = UIInterfaceOrientationLandscapeRight;
                    break;
                case UIInterfaceOrientationLandscapeRight:
                    orientation = UIInterfaceOrientationPortraitUpsideDown;
                    break;
                case UIInterfaceOrientationPortraitUpsideDown:
                    orientation = UIInterfaceOrientationLandscapeLeft;
                    break;
                case UIInterfaceOrientationLandscapeLeft:
                    orientation = UIInterfaceOrientationPortrait;
                    break;
                default:
                    break;
            }
        }
    }
    
    return orientation;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    if (UIInterfaceOrientationIsPortrait([self orientationFromTransform:[coordinator targetTransform]])) {
        [self hideLandscapeViewWithDuration:0.3];
    } else {
        [self showLandscapeViewWithDuration:0.3];
    }
}

- (void)hideLandscapeViewWithDuration:(NSTimeInterval)duration {
    if (_landscapeViewController) {
        [self.searchBar becomeFirstResponder];
        [_landscapeViewController willMoveToParentViewController:nil];
        
        [UIView animateWithDuration:duration animations:^{
            _landscapeViewController.view.alpha = 0;
            _statusBarStyle = UIStatusBarStyleDefault;
            [self setNeedsStatusBarAppearanceUpdate];
        } completion:^(BOOL finished) {
            [_landscapeViewController.view removeFromSuperview];
            [_landscapeViewController removeFromParentViewController];
            _landscapeViewController = nil;
        }];
    }
}

- (void)showLandscapeViewWithDuration:(NSTimeInterval)duration {
    if (!_landscapeViewController) {
        [_detailViewController dismissFromParentViewController];
        [self.searchBar resignFirstResponder];
        
        _landscapeViewController = [[LandscapeViewController alloc] initWithNibName:@"LandscapeViewController" bundle:nil];
        _landscapeViewController.view.frame = self.view.bounds;
        _landscapeViewController.view.alpha = 0;
        _landscapeViewController.searchResults = _searchResults;
        
        [self.view addSubview:_landscapeViewController.view];
        [self addChildViewController:_landscapeViewController];
        
        [UIView animateWithDuration:duration animations:^{
            _landscapeViewController.view.alpha = 1;
            _statusBarStyle = UIStatusBarStyleLightContent;
            [self setNeedsStatusBarAppearanceUpdate];
        } completion:^(BOOL finished) {
            [_landscapeViewController didMoveToParentViewController:self];
        }];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return _statusBarStyle;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}


#pragma mark - IBAction

- (IBAction)segmentChanged:(UISegmentedControl *)sender {
    
    [self performSearch];
    NSLog(@"segment changed: %ld", sender.selectedSegmentIndex);
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.searchBar resignFirstResponder];
    
    _detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    _detailViewController.searchResult = (SearchResult *)_searchResults[indexPath.row];
    [_detailViewController presentInParentViewController:self];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if ([_searchResults count] > 0) {
        return indexPath;
    }
    return nil; 
}

#pragma mark - TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isLoading) {
        return 1;
    }
    
    if (_searchResults) {
        if ([_searchResults count] == 0) {
            return 1;
        }
        return [_searchResults count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isLoading) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadingCellIdentifier];
        UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:100];
        [spinner startAnimating];
        
        _isLoading = NO;
        
        return cell;
    }
    
    if ([_searchResults count] == 0) {
        return [tableView dequeueReusableCellWithIdentifier:NothingFoundCellIdentifier];
    } else {
        SearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchResultCellIdentifier];
        SearchResult *searchResult = (SearchResult *)_searchResults[indexPath.row];
        [cell configureForSearchResult:searchResult];
        return cell;
    }
}

#pragma mark - SearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self performSearch];
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

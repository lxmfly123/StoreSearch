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
#import <AFNetworking/AFNetworking.h>

static NSString * const SearchResultCellIdentifier = @"SearchResultCell";
static NSString * const NothingFoundCellIdentifier = @"NothingFoundCell";
static NSString * const LoadingCellIdentifier = @"LoadingCell";

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedContol;

@end

@implementation SearchViewController
{
    NSMutableArray *_searchResults;
    BOOL _isLoading;
    NSOperationQueue *_queue;
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
    
    NSURL *searchURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&country=cn&entity=%@&limit=30", encodedText, categoryName]];
    return searchURL;
}

//- (NSString *)performStoreRequestWithURL:(NSURL *)url {
//    NSError *error;
//    NSString *string = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
//    if (string == nil) {
//        NSLog(@"Search Error: '%@'", error);
//    }
//    return string;
//} 
//
//- (NSDictionary *)parseJSON:(NSString *)jsonString {
//    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
//    NSError *error;
//    id resultObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
//    if (resultObject == nil) {
//        NSLog(@"Parse Error: '%@'", error);
//    }
//    return resultObject;
//}

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

#pragma mark - IBAction

- (IBAction)segmentChanged:(UISegmentedControl *)sender {
    
    [self performSearch];
    NSLog(@"segment changed: %ld", sender.selectedSegmentIndex);
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.searchBar resignFirstResponder];
    
    DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    detailViewController.searchResult = (SearchResult *)_searchResults[indexPath.row];
    [detailViewController presentInParentViewController:self];
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
        
//        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//        dispatch_async(queue, ^{
//            NSURL *url = [self urlWithSearchText:searchBar.text];
//            NSString *jsonString = [self performStoreRequestWithURL:url];
//            if (jsonString == nil) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self showNetworkError];
//                });
//                return;
//            }
//            
//            NSDictionary *dictionary = [self parseJSON:jsonString];
//            if (dictionary == nil) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self showNetworkError];
//                });
//                return;
//            }
//            
//            [self parseDictionary:dictionary];
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                _isLoading = NO;
//                [self.tableView reloadData];
//            });
//        });
    
}

//- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
//    _searchResults = nil;
//    NSLog(@"lll");
//    [self.tableView reloadData]; 
//}
//
//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
//    if ([searchText length] == 0) {
//        _searchResults = nil;
//        [self.tableView reloadData];
//    }
//}

//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
//    if ([searchText length] == 0) {
//        []
//        if (!_isLoading) {
//            <#statements#>
//        }
//    }
//}

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

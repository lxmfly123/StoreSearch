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

static NSString * const SearchResultCellIdentifier = @"SearchResultCell";
static NSString * const NothingFoundCellIdentifier = @"NothingFoundCell";

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;

@end

@implementation SearchViewController
{
    NSMutableArray *_searchResults;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    self.tableView.rowHeight = 80;
    
    UINib *cellNib = [UINib nibWithNibName:SearchResultCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:SearchResultCellIdentifier];
    
    cellNib = [UINib nibWithNibName:@"NothingFoundCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:NothingFoundCellIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if ([tableView numberOfRowsInSection:0] > 0) {
        return indexPath;
    }
    return nil;
}

#pragma mark - TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_searchResults) {
        if ([_searchResults count] == 0) {
            return 1;
        }
        return [_searchResults count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_searchResults count] == 0) {
        return [tableView dequeueReusableCellWithIdentifier:NothingFoundCellIdentifier];
    } else {
        SearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchResultCellIdentifier];
        SearchResult *searchResult = (SearchResult *)_searchResults[indexPath.row];
        cell.nameLabel.text = searchResult.name;
        cell.artistNameLabel.text = searchResult.artistName;
        return cell;
    }
}

#pragma mark - SearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    _searchResults = [NSMutableArray new];
    
    if ([searchBar.text isEqualToString:@"lxm"]) {
        for (int i = 1; i <= 3; i++) {
            SearchResult *searchResult = [SearchResult new];
            searchResult.name = [NSString stringWithFormat:@"Search result %d", i];
            searchResult.artistName = searchBar.text;
            [_searchResults addObject:searchResult];
        }
    }
    [self.tableView reloadData];
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

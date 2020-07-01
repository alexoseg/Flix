//
//  MoviesViewController.m
//  Flix
//
//  Created by Alex Oseguera on 6/24/20.
//  Copyright © 2020 Alex Oseguera. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"
#import "MBProgressHUD.h"
#import "Movie.h"
#import "MovieAPIManager.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSArray *filteredData;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
            
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
    [self fetchMovies];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

-(void)fetchMovies {
    MovieAPIManager *manager = [[MovieAPIManager alloc] init];
    typeof(self) __weak weakSelf = self;
    [manager fetchNowPlaying:^(NSArray *movies, NSError *error) {
        if(error){
            NSString *errorMessage = [error localizedDescription];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot get Movies" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
                [weakSelf fetchMovies];
            }];
            [alert addAction:tryAgainAction];
            [weakSelf presentViewController:alert animated:YES completion:^{}];
        }
        else {
            weakSelf.movies = movies;
            weakSelf.filteredData = weakSelf.movies;
            [weakSelf.tableView reloadData];
        }
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.refreshControl endRefreshing];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.filteredData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    
    cell.movie = self.movies[indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    [tableView reloadRowsAtIndexPaths:[[NSArray alloc] initWithObjects: indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)loadImageWithFade:(NSURL *)posterUrl fromCell:(MovieCell *)cell{
    NSURLRequest *request = [NSURLRequest requestWithURL:posterUrl];

    __weak MovieCell *weakSelf = cell;
    [cell.posterView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *imageRequest, NSHTTPURLResponse *imageResponse, UIImage *image) {
                                        
        if (imageResponse) {
            weakSelf.posterView.alpha = 0.0;
            weakSelf.posterView.image = image;
            [UIView animateWithDuration:0.4 animations:^{
                weakSelf.posterView.alpha = 1.0;
            }];
       }
       else {
            weakSelf.posterView.image = image;
       }
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse * response, NSError *error) {
        NSString *errorMessage = [error localizedDescription];
        NSLog(@"%@", errorMessage);
    }];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    self.filteredData = self.movies;
    [self.searchBar resignFirstResponder];
    [self.tableView reloadData];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if(searchText.length != 0){
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            Movie *movie = evaluatedObject;
            NSString *movieTitle = movie.title;
            return [movieTitle containsString:searchText];
        }];
        self.filteredData = [self.movies filteredArrayUsingPredicate:predicate];
    }
    else {
        self.filteredData = self.movies;
    }
    
    [self.tableView reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    Movie *movie = self.filteredData[indexPath.row];
    DetailsViewController *detailsViewController =  [segue destinationViewController];
    detailsViewController.movie = movie;
}


@end

//
//  MoviesGridViewController.m
//  Flix
//
//  Created by Alex Oseguera on 6/24/20.
//  Copyright © 2020 Alex Oseguera. All rights reserved.
//

#import "MoviesGridViewController.h"
#import "MBProgressHUD.h"
#import "MovieCollectionCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface MoviesGridViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *movies;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray* filteredData;

@end

@implementation MoviesGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.searchBar.delegate = self;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self fetchMovies];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5; 
    
    CGFloat postersPerLine = 2;
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine - 1)) / postersPerLine;
    CGFloat itemHeight = itemWidth * 1.5;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight); 
}

-(void)fetchMovies {
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=8ec68e637b241eb6bc5b97abcd358733"];
          NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
          NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
          
          typeof(self) __weak weakSelf = self;
    
          NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                 if (error != nil) {
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
                     NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                     
                     weakSelf.movies = dataDictionary[@"results"];
                     weakSelf.filteredData = weakSelf.movies;
                     [weakSelf.collectionView reloadData]; 
                 }
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
             }];
          [task resume];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    self.filteredData = self.movies;
    [self.searchBar resignFirstResponder];
    [self.collectionView reloadData];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if(searchText.length != 0){
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            NSDictionary *movie = evaluatedObject;
            NSString *movieTitle = movie[@"title"];
            return [movieTitle containsString:searchText];
        }];
        self.filteredData = [self.movies filteredArrayUsingPredicate:predicate];
    }
    else {
        self.filteredData = self.movies;
    }
    
    [self.collectionView reloadData];
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    UICollectionViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:tappedCell];
    NSDictionary *movie = self.movies[indexPath.item];
    
    DetailsViewController *detailsViewController = [segue destinationViewController];
    detailsViewController.movie = movie;
}

-(void)loadImageWithFade:(NSURL *)posterURLLowQuality withHighQuality:(NSURL *)posterURLHighQuality fromCell:(MovieCollectionCell *)cell{
    NSURLRequest *requestLowQuality = [NSURLRequest requestWithURL:posterURLLowQuality];
    NSURLRequest *requestHighQuality = [NSURLRequest requestWithURL:posterURLHighQuality];

    __weak MovieCollectionCell *weakSelf = cell;
    
    [cell.posterView setImageWithURLRequest:requestLowQuality placeholderImage:nil success:^(NSURLRequest *imageRequest, NSHTTPURLResponse *imageResponse, UIImage *lowImage) {
        if (imageResponse) {
            weakSelf.posterView.alpha = 0.0;
            weakSelf.posterView.image = lowImage;
            [UIView animateWithDuration:0.2 animations:^{
                weakSelf.posterView.alpha = 1.0;
            } completion:^(BOOL finished) {
                [weakSelf.posterView setImageWithURLRequest:requestHighQuality placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull highImage) {
                    weakSelf.posterView.image = highImage;
                } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                    weakSelf.posterView.image = lowImage;
                }];
            }];
       }
       else {
            weakSelf.posterView.image = lowImage;
       }
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse * response, NSError *error) {
        NSString *errorMessage = [error localizedDescription];
        NSLog(@"%@", errorMessage);
    }];
}


- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MovieCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieCollectionCell" forIndexPath:indexPath];
    
    NSDictionary *movie = self.filteredData[indexPath.item];
    
    NSString *baseURLStringHighQuality = @"https://image.tmdb.org/t/p/original";
    NSString *baseURLStringLowQuality = @"https://image.tmdb.org/t/p/w45";
    
    NSString *posterURLString = movie[@"poster_path"];
    
    NSString *fullPosterURLStringHighQuality = [baseURLStringHighQuality stringByAppendingString:posterURLString];
    NSString *fullPosterURLStringLowQuality = [baseURLStringLowQuality stringByAppendingString:posterURLString];
       
    NSURL *posterURLHighQuality = [NSURL URLWithString:fullPosterURLStringHighQuality];
    NSURL *posterURLLowQuality = [NSURL URLWithString:fullPosterURLStringLowQuality];
    
    cell.posterView.image = nil;
    [self loadImageWithFade:posterURLLowQuality withHighQuality:posterURLHighQuality fromCell:cell];
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filteredData.count;
}

@end

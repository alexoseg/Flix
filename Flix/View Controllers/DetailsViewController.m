//
//  DetailsViewController.m
//  Flix
//
//  Created by Alex Oseguera on 6/24/20.
//  Copyright © 2020 Alex Oseguera. All rights reserved.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "TrailerViewController.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backdropView;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
//    NSString *posterURLString = self.movie[@"poster_path"];
//    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
//
//    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    [self loadImageWithFade:self.movie.posterURL fromImageView:self.posterView];
    
//    NSString *backdropURLString = self.movie[@"backdrop_path"];
    if(![self.movie.backdropPathURL isKindOfClass:[NSNull class]]){
//        NSString *fullBackdropURLString = [baseURLString stringByAppendingString:backdropURLString];
        
//        NSURL *backdropURL = [NSURL URLWithString:fullBackdropURLString];
        [self loadImageWithFade:self.movie.backdropPathURL fromImageView:self.backdropView];
    }
    
    
//    self.titleLabel.text = self.movie[@"title"];
    self.titleLabel.text = self.movie.title;
//    self.synopsisLabel.text = self.movie[@"overview"];
    self.synopsisLabel.text = self.movie.overview;
    
    [self.titleLabel sizeToFit];
    [self.synopsisLabel sizeToFit];
}

- (IBAction)onTapPoster:(UITapGestureRecognizer *)sender {
    [self performSegueWithIdentifier:@"trailerSegue" sender:nil]; 
}

-(void)loadImageWithFade:(NSURL *)posterUrl fromImageView:(UIImageView *)detailImageView{
    NSURLRequest *request = [NSURLRequest requestWithURL:posterUrl];

    __weak UIImageView *weakSelf = detailImageView;
    [detailImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *imageRequest, NSHTTPURLResponse *imageResponse, UIImage *image) {
                                        
        if (imageResponse) {
            weakSelf.alpha = 0.0;
            weakSelf.image = image;
            [UIView animateWithDuration:0.4 animations:^{
                weakSelf.alpha = 1.0;
            }];
       }
       else {
            weakSelf.image = image;
       }
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse * response, NSError *error) {
        NSString *errorMessage = [error localizedDescription];
        NSLog(@"%@", errorMessage);
    }];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *baseUrlString = @"https://api.themoviedb.org/3/movie/";
//    NSString *movieId = self.movie[@"id"];
    NSString *movieId = self.movie.movieId;
    NSString *endingString = @"/videos?api_key=8ec68e637b241eb6bc5b97abcd358733&language=en-US";
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", baseUrlString, movieId, endingString];
    NSURL *url = [NSURL URLWithString:urlString];
    
    TrailerViewController *trailerView = [segue destinationViewController];
    trailerView.apiURL = url;
}


@end

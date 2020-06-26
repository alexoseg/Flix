//
//  TrailerViewController.m
//  Flix
//
//  Created by Alex Oseguera on 6/25/20.
//  Copyright © 2020 Alex Oseguera. All rights reserved.
//

#import "TrailerViewController.h"
#import <WebKit/WebKit.h>



@interface TrailerViewController ()
@property (weak, nonatomic) IBOutlet WKWebView *trailerWebView;

@end

@implementation TrailerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *baseUrlString = @"https://api.themoviedb.org/3/movie/";
    NSString *movieId = self.movie[@"id"];
    NSString *endingString = @"/videos?api_key=8ec68e637b241eb6bc5b97abcd358733&language=en-US";
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", baseUrlString, movieId, endingString];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"Error");
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               NSArray *results = dataDictionary[@"results"];
               NSDictionary *videoDictionary = results[0];
               NSString *baseYouTubeUrl = @"https://www.youtube.com/watch?v=";
               NSString *videoUrlString = [NSString stringWithFormat:@"%@%@", baseYouTubeUrl, videoDictionary[@"key"]];
               NSURL *videoUrl = [NSURL URLWithString:videoUrlString];
               NSURLRequest *request = [NSURLRequest requestWithURL:videoUrl
                   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
               timeoutInterval:10.0];
               [self.trailerWebView loadRequest:request];
           }
       }];
    [task resume];
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

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
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.apiURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    typeof(self) __weak weakSelf = self;
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"Error");
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               
               NSString *baseYouTubeUrl = @"https://www.youtube.com/watch?v=";
               NSString *youtubeKey = dataDictionary[@"results"][0][@"key"];
               
               NSString *videoUrlString = [NSString stringWithFormat:@"%@%@", baseYouTubeUrl, youtubeKey];
               NSURL *videoUrl = [NSURL URLWithString:videoUrlString];
               NSURLRequest *request = [NSURLRequest requestWithURL:videoUrl
                   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
               timeoutInterval:10.0];
               [weakSelf.trailerWebView loadRequest:request];
           }
       }];
    [task resume];
}

@end

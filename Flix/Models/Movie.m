//
//  Movie.m
//  Flix
//
//  Created by Alex Oseguera on 7/1/20.
//  Copyright © 2020 Alex Oseguera. All rights reserved.
//

#import "Movie.h"

@implementation Movie

-(id)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    
    self.title = dictionary[@"title"];
    self.overview = dictionary[@"overview"];
    self.movieId = dictionary[@"id"]; 
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    
    NSString *posterURLString = dictionary[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    self.posterURL = [NSURL URLWithString:fullPosterURLString];
    
    NSString *backdropURLString = dictionary[@"backdrop_path"];
    NSString *fullBackdropURLString = [baseURLString stringByAppendingString:backdropURLString];
    self.backdropPathURL = [NSURL URLWithString:fullBackdropURLString];
    
    return self; 
}

@end

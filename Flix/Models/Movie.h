//
//  Movie.h
//  Flix
//
//  Created by Alex Oseguera on 7/1/20.
//  Copyright © 2020 Alex Oseguera. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Movie : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *overview;
@property (nonatomic, strong) NSString *movieId;
@property (nonatomic, strong) NSURL *backdropPathURL;
@property (nonatomic, strong) NSURL *posterURL;

- (id)initWithDictionary:(NSDictionary *)dictionary;
+ (NSArray *)moviesWithDictionaries:(NSArray *)dictionaries;

@end

NS_ASSUME_NONNULL_END

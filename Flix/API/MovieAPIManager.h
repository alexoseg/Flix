//
//  MovieAPIManager.h
//  Flix
//
//  Created by Alex Oseguera on 7/1/20.
//  Copyright © 2020 Alex Oseguera. All rights reserved.
//

#ifndef MovieAPIManager_h
#define MovieAPIManager_h

@interface MovieAPIManager : NSObject

- (void)fetchNowPlaying:(void(^)(NSArray *movies, NSError *error))completion;

@end


#endif /* MovieAPIManager_h */

//
//  MovieCell.m
//  Flix
//
//  Created by Alex Oseguera on 6/24/20.
//  Copyright © 2020 Alex Oseguera. All rights reserved.
//

#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"

@implementation MovieCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMovie:(Movie *)movie{
    _movie = movie;
    
    self.titleLabel.text = self.movie.title;
    self.synopsisLabel.text = self.movie.overview;
    
    self.posterView.image = nil;
    if(![self.movie.posterURL isKindOfClass:[NSNull class]]){
        [self.posterView setImageWithURL:self.movie.posterURL];
    }
}

@end

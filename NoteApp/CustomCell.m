//
//  CustomCell.m
//  NoteApp
//
//  Created by yueling zhang on 5/26/13.
//  Copyright (c) 2013 yueling. All rights reserved.
//

#import "CustomCell.h"

@implementation CustomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.textView = [[UITextView alloc]initWithFrame:CGRectMake(5, 5, 300, 160)];
        self.textView.backgroundColor = [UIColor clearColor];
        self.textView.font = [UIFont systemFontOfSize:20];
        self.textView.userInteractionEnabled = NO;
        [self addSubview:self.textView];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

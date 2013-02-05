//
//  YFTableViewCell.h
//  rails-saas-ios
//
//  Created by Chris Richards on 04/02/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

@interface YFTableViewCell : UITableViewCell

@property (nonatomic, strong, readonly) SSTextField *textField;
@property (nonatomic, assign) BOOL editingText;

+ (CGFloat)cellHeight;

- (void)setEditingAction:(SEL)editAction forTarget:(id)target;
- (void)updateFonts;

@end

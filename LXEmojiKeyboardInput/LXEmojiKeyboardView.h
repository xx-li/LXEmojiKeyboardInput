//
//  LXEmojiKeyboardView.h
//  LXEmojiKeyboard
//
//  Created by 李新星 on 15/11/18.
//  Copyright © 2015年 xx-li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXEmojiKeyboardView : UIView<UIInputViewAudioFeedback>

@property (nonatomic,assign) id<UITextInput>textView;

@property (strong, nonatomic, readonly) UIScrollView * scrollView;
@property (strong, nonatomic, readonly) UIPageControl * pageControl;

@property (strong, nonatomic) UIImage * deleteNormalImage;
@property (strong, nonatomic) UIImage * deleteHlightedImage;
@property (assign, nonatomic) NSInteger rowCount;
@property (assign, nonatomic) NSInteger columnCount;
@property (assign, nonatomic) NSInteger bottomEdgeSpacing;
@property (assign, nonatomic) NSInteger horizontalEdgeSpacing;

+ (id) keybaordViewWithFrame:(CGRect)frame;

/*! 刷新界面 */
- (void) layoutAllButtons;

@end

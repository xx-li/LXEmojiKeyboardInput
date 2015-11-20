//
//  LXGrowingInputView.h
//  LXEmojiKeyboard
//
//  Created by 李新星 on 15/11/18.
//  Copyright © 2015年 xx-li. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LXGrowingInputView;

typedef NS_ENUM(NSInteger, LXKeyboardType) {
    LXKeyboardTypeDefault,
    LXKeyboardTypeEmoji,
};


@protocol LXGrowingInputViewDelegate <NSObject>

@optional

- (void)inputView:(LXGrowingInputView *)inputView willChangeHeight:(float)height;
- (void)inputView:(LXGrowingInputView *)inputView keyboardChangeButtonClick:(UIButton *)button keyboardType:(LXKeyboardType)type;
- (void)didInputViewSendButtonClick:(LXGrowingInputView *)inputView;


@end

@interface LXGrowingInputView : UIView

@property (nonatomic, strong, readonly) UITextView *textView;

@property (weak, nonatomic) id<LXGrowingInputViewDelegate> delegate;

@property (assign, nonatomic, readonly) LXKeyboardType keyboardType;

@end

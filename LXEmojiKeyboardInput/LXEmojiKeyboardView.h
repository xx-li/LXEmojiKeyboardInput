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

+ (id) keybaordViewWithFrame:(CGRect)frame;


@end

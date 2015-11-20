//
//  ViewController.m
//  LXEmojiKeyboard
//
//  Created by 李新星 on 15/11/18.
//  Copyright © 2015年 xx-li. All rights reserved.
//

#import "ViewController.h"
#import "LXEmojiKeyboardView.h"
#import "LXGrowingInputView.h"

#import <Masonry.h>

@interface ViewController () <LXGrowingInputViewDelegate> {
    BOOL _isForKeybaordTypeChange;
}

@property (strong, nonatomic) LXEmojiKeyboardView * emojiView;
@property (strong, nonatomic) LXGrowingInputView * inputView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.emojiView = [[LXEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    
    LXGrowingInputView * inputView = [[LXGrowingInputView alloc] init];
    inputView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:inputView];
    [inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.height.mas_equalTo(45);
    }];
    inputView.delegate = self;
    _inputView = inputView;
    
}

- (void) leftButtonClick {

    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerForKeyboardNotifications];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeObserverForKeyboardNotifications];
}

#pragma mark - Delegate
- (void) didInputViewSendButtonClick:(LXGrowingInputView *)inputView {
    NSLog(@"didInputViewSendButtonClick");
    _isForKeybaordTypeChange = NO;
    
    [inputView.textView resignFirstResponder];
}

- (void) inputView:(LXGrowingInputView *)inputView willChangeHeight:(float)height {
    
    if (height > 100) {
        return;
    }
    
    [_inputView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];

}

- (void)inputView:(LXGrowingInputView *)inputView keyboardChangeButtonClick:(UIButton *)button keyboardType:(LXKeyboardType)type {
    
    _isForKeybaordTypeChange = YES;
    
    NSTimeInterval durtion = 0;
    if ([inputView.textView isFirstResponder]) {
        durtion = 0.06;
    }
    
    [inputView.textView resignFirstResponder];

    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(durtion * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (type == LXKeyboardTypeDefault) {
            _emojiView.textView = nil;
        }
        else {
            _emojiView.textView = _inputView.textView;
        }
        
        [_inputView.textView reloadInputViews];
        [_inputView.textView becomeFirstResponder];
    });

}


#pragma mark - UIKeyboard
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
- (void)removeObserverForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}



- (void)keyboardWillShown:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    CGSize kbSize = [[dict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSTimeInterval durtion = [[dict objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat keyboardHeight = kbSize.height;
    [_inputView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).with.offset(-keyboardHeight);
    }];
    
    [UIView animateWithDuration:durtion - 0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillBeHidden:(NSNotification *)notification
{
    if (_isForKeybaordTypeChange) {
        return;
    }
    
    NSDictionary *dict = [notification userInfo];
    NSTimeInterval durtion = [[dict objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [_inputView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
    }];
    
    [UIView animateWithDuration:durtion animations:^{
        [self.view layoutIfNeeded];
    }];
}




@end

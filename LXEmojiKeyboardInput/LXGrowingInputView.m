//
//  LXGrowingInputView.m
//  LXEmojiKeyboard
//
//  Created by 李新星 on 15/11/18.
//  Copyright © 2015年 xx-li. All rights reserved.
//

#import "LXGrowingInputView.h"
#import <Masonry.h>



@interface LXGrowingInputView()<UITextViewDelegate>

@property (assign, nonatomic) CGFloat contentHeight;

@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;

@end

@implementation LXGrowingInputView
@synthesize textView = _textView;

#pragma mark - Life cycle
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _keyboardType = LXKeyboardTypeDefault;
    
    [self addSubview:self.leftButton];
    [self addSubview:self.rightButton];
    [self addSubview:self.textView];

    [self setupViewConstraints];
}

- (void) setupViewConstraints {
    
    UIImageView * bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LXEmojiKeyboardInput.bundle/inputview_background"]];
    [self addSubview:bgView];
    [self sendSubviewToBack:bgView];

    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(5);
        make.bottom.equalTo(self).with.offset(-8);
        make.width.mas_equalTo(40);
    }];
    
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).with.offset(-10);
        make.bottom.equalTo(self).with.offset(-8);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(28);

    }];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.leftButton.mas_right).offset(5);
        make.right.equalTo(self.rightButton.mas_left).offset(-10);
        make.bottom.equalTo(self).offset(-5);
        make.top.equalTo(self).offset(5);
    }];
}

#pragma mark - Setter and getter
- (UITextView *)textView
{
    if (!_textView)
    {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        _textView.bounces = NO;
        _textView.returnKeyType = UIReturnKeyDone;
        _textView.font = [UIFont systemFontOfSize:15.0f];
        _textView.delegate = self;
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.layer.cornerRadius = 5.0;
        _textView.layer.borderWidth = 1.0;
        _textView.layer.borderColor =  [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:205.0/255.0 alpha:1.0].CGColor;
    }
    return _textView;
}


- (void)setContentHeight:(CGFloat)contentHeight {
    
    if (_contentHeight == contentHeight) {
        return;
    }
    
    _contentHeight = contentHeight;

    //加上 上下间距
    CGFloat allHeight = _contentHeight + 10.0;
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputView:willChangeHeight:)]) {
        [self.delegate inputView:self willChangeHeight:allHeight];
    }
}

- (UIButton *)leftButton
{
    if (!_leftButton)
    {
        _leftButton = [[UIButton alloc] init];
        [_leftButton setImage:[UIImage imageNamed:@"LXEmojiKeyboardInput.bundle/keyboard_btn_default"] forState:UIControlStateNormal];
        [_leftButton setImage:[UIImage imageNamed:@"LXEmojiKeyboardInput.bundle/keyboard_btn_emoji"] forState:UIControlStateSelected];
        _leftButton.translatesAutoresizingMaskIntoConstraints = NO;
        _leftButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [_leftButton addTarget:self action:@selector(keyboardTypeChangeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftButton;
}

- (UIButton *)rightButton
{
    if (!_rightButton)
    {
        _rightButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _rightButton.translatesAutoresizingMaskIntoConstraints = NO;
        _rightButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        _rightButton.layer.cornerRadius = 5.0;
        _rightButton.clipsToBounds = YES;
        [_rightButton setTitle:@"发送" forState:UIControlStateNormal];
        [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _rightButton.backgroundColor = [UIColor orangeColor];
        [_rightButton addTarget:self action:@selector(sendButtonClick:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _rightButton;
}

#pragma mark - Event response
- (void)sendButtonClick:(UIButton *)sender {
    
    if (_delegate && [_delegate respondsToSelector:@selector(didInputViewSendButtonClick:)]) {
        [_delegate didInputViewSendButtonClick:self];
    }

}

- (void)keyboardTypeChangeButtonClick:(UIButton *)sender {
    
    if (_textView.isFirstResponder) {
        sender.selected = !sender.selected;
        _keyboardType = sender.selected ? LXKeyboardTypeEmoji : LXKeyboardTypeDefault;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(inputView:keyboardChangeButtonClick:keyboardType:)]) {
        [_delegate inputView:self keyboardChangeButtonClick:sender keyboardType:_keyboardType];
    }
    
}

#pragma mark - UITextViewDelegate
- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//    NSString * curText = [textView.text stringByReplacingCharactersInRange:range withString:text];
//    NSLog(@"%@", curText);
    
    if ([text isEqualToString:@"\n"]) {
        
        if (_delegate && [_delegate respondsToSelector:@selector(didInputViewSendButtonClick:)]) {
            [_delegate didInputViewSendButtonClick:self];
        }
        
        return NO;
    }
    
    return YES;
}

- (void) textViewDidChange:(UITextView *)textView {
    
    self.contentHeight = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, FLT_MAX)].height;
    
    /*解决编辑的时候，光标位置异常的问题*/
    CGRect line = [textView caretRectForPosition:
                   textView.selectedTextRange.start];
    CGFloat overflow = line.origin.y + line.size.height
    - ( textView.contentOffset.y + textView.bounds.size.height
       - textView.contentInset.bottom - textView.contentInset.top );
    if ( overflow > 0 ) {
        CGPoint offset = textView.contentOffset;
        offset.y += overflow + 7; // leave 7 pixels margin
        [textView setContentOffset:offset];
    }
    /*end*/
}

@end

//
//  LXEmojiKeyboardView.m
//  LXEmojiKeyboard
//
//  Created by 李新星 on 15/11/18.
//  Copyright © 2015年 xx-li. All rights reserved.
//

#import "LXEmojiKeyboardView.h"

//4行6列
#define EMOJI_DEFAULT_ROW  4
#define EMOJI_DEFAULT_COLUMN 6

//emoji表情与底部的间距
#define Emoji_Bottom_Edge_Spacing 30

//emoji表情与水平两边的间距
#define Emoji_horizontal_Edge_Spacing 10

@interface LXEmojiKeyboardView ()<UIScrollViewDelegate>  {
    UIScrollView * _scrollView;
    UIPageControl * _pageControl;
    NSInteger _pageCount;
    CGSize _oldLayoutSize;
}

@property (strong, nonatomic, readonly) NSArray * allEmojis;
@property (strong, nonatomic, readonly) NSArray * allButtons;


@end

@implementation LXEmojiKeyboardView
@synthesize allEmojis = _allEmojis, allButtons = _allButtons;

+ (id) keybaordViewWithFrame:(CGRect)frame {
    return [[self alloc] initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIScrollView * scrollView = [[UIScrollView alloc] init];
        scrollView.bounces = NO;
        scrollView.pagingEnabled = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.backgroundColor = [UIColor colorWithWhite:0.961 alpha:1.000];;
        scrollView.delegate = self;
        [self addSubview:scrollView];
        scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        //覆盖self
        [self addConstraints:@[
                               [NSLayoutConstraint constraintWithItem:scrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0],
                               [NSLayoutConstraint constraintWithItem:scrollView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0],
                               [NSLayoutConstraint constraintWithItem:scrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual  toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
                               [NSLayoutConstraint constraintWithItem:scrollView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0]
                               ]];
        _scrollView = scrollView;
        
        UIPageControl * pageControl = [[UIPageControl alloc] init];
        pageControl.numberOfPages = [self getPageCount:self.allEmojis.count];
        pageControl.currentPage = 0;
        pageControl.userInteractionEnabled = NO;
        pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
        [self addSubview:pageControl];
        pageControl.translatesAutoresizingMaskIntoConstraints = NO;
        //距离底部10，居中
        [self addConstraints:@[
                               [NSLayoutConstraint constraintWithItem:pageControl attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0],
                               [NSLayoutConstraint constraintWithItem:pageControl attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-5]
                               ]];
        _pageControl = pageControl;

    }
    return self;
}

#pragma mark - private Method
#pragma mark Text Operation
- (BOOL)textInputShouldReplaceTextInRange:(UITextRange *)range replacementText:(NSString *)replacementText {
    
    BOOL shouldChange = YES;
    
    NSInteger startOffset = [self.textView offsetFromPosition:self.textView.beginningOfDocument toPosition:range.start];
    NSInteger endOffset = [self.textView offsetFromPosition:self.textView.beginningOfDocument toPosition:range.end];
    NSRange replacementRange = NSMakeRange(startOffset, endOffset - startOffset);
    
    if ([self.textView isKindOfClass:UITextView.class]) {
        UITextView *textView = (UITextView *)self.textView;
        if ([textView.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]){
            shouldChange = [textView.delegate textView:textView shouldChangeTextInRange:replacementRange replacementText:replacementText];
        }
    }
    
    if ([self.textView isKindOfClass:UITextField.class]) {
        UITextField *textField = (UITextField *)self.textView;
        if ([textField.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
            shouldChange = [textField.delegate textField:textField shouldChangeCharactersInRange:replacementRange replacementString:replacementText];
        }
    }
    
    return shouldChange;
}

- (void)replaceTextInRange:(UITextRange *)range withText:(NSString *)text {
    if (range && [self textInputShouldReplaceTextInRange:range replacementText:text]) {
        [self.textView replaceRange:range withText:text];
    }
}

//输入文本
- (void)inputText:(NSString *)text {
    [self replaceTextInRange:self.textView.selectedTextRange withText:text];
}

- (BOOL)stringIsEmoji:(NSString *)str {
    return [self.allEmojis containsObject:str];
}

#pragma mark - Setter and getter
- (NSInteger) getPageCount:(NSInteger)emojiCount {
    //每页最后有一个删除按钮
    NSInteger pageEmojiCount = EMOJI_DEFAULT_ROW * EMOJI_DEFAULT_COLUMN - 1;
    
    return (emojiCount / pageEmojiCount) + (emojiCount % pageEmojiCount == 0 ? 0 : 1);
}

//从本地Emoji.plist文件获取显示的emoji
- (NSArray *)allEmojis {
    if (!_allEmojis) {
        NSString * emojiPath = [[NSBundle mainBundle] pathForResource:@"LXEmojiKeyboardInput.bundle/Emoji" ofType:@"plist"];
        NSDictionary * dic = [NSDictionary dictionaryWithContentsOfFile:emojiPath];
        return [dic objectForKey:@"People"];
    }
    return _allEmojis;
}

//获取所有按钮
- (NSArray *) allButtons {
    if (!_allButtons) {
        NSArray * emojis = self.allEmojis;
        //页数
        NSInteger pageCount = [self getPageCount:emojis.count];
        //每页按钮的最大个数
        NSInteger pageBtnCount = EMOJI_DEFAULT_ROW * EMOJI_DEFAULT_COLUMN;
        NSMutableArray * array = [NSMutableArray arrayWithCapacity:emojis.count];
        for (int i = 0; i < pageCount; i ++) {
            for (int j = 0; j < pageBtnCount; j ++) {
                
                NSString * emojiTitle = nil;
                NSInteger emojiIndex = i * (pageBtnCount - 1) + j - i;
                if (j != pageBtnCount - 1) {
                    //执行到了末尾
                    if (emojiIndex < emojis.count) {
                        emojiTitle = emojis[emojiIndex];
                    }
                }
                
                UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.titleLabel.font = [UIFont systemFontOfSize:28];
                btn.tag = i;

                if (emojiTitle) {
                    [btn setTitle:emojiTitle forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(emojiButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                }
                else {
                    [btn setImage:[UIImage imageNamed:@"LXEmojiKeyboardInput.bundle/emoji_del_btn_hl"] forState:UIControlStateHighlighted];
                    [btn setImage:[UIImage imageNamed:@"LXEmojiKeyboardInput.bundle/emoji_del_btn_nor"] forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                }
                
                [_scrollView addSubview:btn];
                [array addObject:btn];
                
                //执行到了末尾
                if (emojiIndex >= emojis.count) {
                    break;
                }

            }
        }
        
        _allButtons = [NSArray arrayWithArray:array];
    }
    return _allButtons;
}

- (void)setTextView:(id<UITextInput>)textView {

    if (textView == nil) {
        if ([_textView isKindOfClass:[UITextView class]]) {
            [(UITextView *)_textView setInputView:nil];
        }
        else if ([_textView isKindOfClass:[UITextField class]]) {
            [(UITextField *)_textView setInputView:nil];
        }
    }
    else {
        if ([textView isKindOfClass:[UITextView class]]) {
            [(UITextView *)textView setInputView:self];
        }
        else if ([textView isKindOfClass:[UITextField class]]) {
            [(UITextField *)textView setInputView:self];
        }
    }
    _textView = textView;
}

#pragma mark - Layout UI
//所有的按钮布局
- (void) layoutAllButtons {
    
    NSArray * buttons = self.allButtons;
    //页数
    NSInteger pageCount = [self getPageCount:self.allEmojis.count];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat buttonWidht = (width - Emoji_horizontal_Edge_Spacing * 2) / EMOJI_DEFAULT_COLUMN;
    CGFloat buttonHeight = (height - Emoji_Bottom_Edge_Spacing) / EMOJI_DEFAULT_ROW;
    
    for (int i = 0; i < pageCount; i ++) {
        for (int j = 0; j < EMOJI_DEFAULT_ROW; j ++) {
            for (int k = 0; k < EMOJI_DEFAULT_COLUMN; k ++) {
                
                NSInteger buttonIndex = k + (EMOJI_DEFAULT_COLUMN * j) + (i * EMOJI_DEFAULT_ROW * EMOJI_DEFAULT_COLUMN);
                if (buttonIndex >= buttons.count) {
                    break;
                }
                UIButton * btn = buttons[buttonIndex];
                
                CGFloat buttonX = Emoji_horizontal_Edge_Spacing + buttonWidht * k + i * width;
                CGFloat buttonY = buttonHeight * j;
                btn.frame = CGRectMake(buttonX, buttonY, buttonWidht, buttonHeight);
                
            }
        }
    }
    
    _scrollView.contentSize = CGSizeMake(width * pageCount, height);
    _scrollView.contentOffset = CGPointMake(width * _pageControl.currentPage, 0);

    _oldLayoutSize = self.bounds.size;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //Size有变化，则重新布局
    if (!CGSizeEqualToSize(_oldLayoutSize, self.bounds.size)) {
        [self layoutAllButtons];
    }
}

#pragma mark - Event response
- (void) emojiButtonClick:(UIButton *)button {
    [[UIDevice currentDevice] playInputClick];
    NSString * title = [button currentTitle];
    [self inputText:title];
//    [self.textView insertText:title];  使用此方法，textView的delegate无法正常监听
}

- (void) deleteButtonClick:(UIButton *)button {
    
    [[UIDevice currentDevice] playInputClick];
    if (self.textView.selectedTextRange.empty) {
        /*
         三种情况：
         1、待删除的emoji占一个字符
         2、待删除emoji占2个字符
         3、待删除的非emoji，也是一个字符
         */        
        UITextRange * emojiRange =
        [self.textView textRangeFromPosition:self.textView.selectedTextRange.start
                                  toPosition:[self.textView positionFromPosition:self.textView.selectedTextRange.start
                                                                          offset:-2]];
        NSString *emojiText = [self.textView textInRange:emojiRange];
        if ([self stringIsEmoji:emojiText]) {
            [self replaceTextInRange:emojiRange withText:@""];
        }
        else {
            UITextRange *rangeToDelete =
            [self.textView textRangeFromPosition:self.textView.selectedTextRange.start
                                      toPosition:[self.textView positionFromPosition:self.textView.selectedTextRange.start
                                                                              offset:-1]];
            [self replaceTextInRange:rangeToDelete withText:@""];
        }
    }
    else {
        [self replaceTextInRange:self.textView.selectedTextRange withText:@""];
    }
    
    //    [self.textView deleteBackward] 使用此方法，textView的delegate无法正常监听
}

#pragma mark protocol UIInputViewAudioFeedback
- (BOOL)enableInputClicksWhenVisible {
    return YES;
}

#pragma mark UIScrollViewDelegate
- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _pageControl.currentPage = (NSInteger)(scrollView.contentOffset.x / CGRectGetWidth(self.frame));
}



@end

//
//  KMAlertView.m
//  CocospodDemo
//
//  Created by Kami Sama on 2019/4/29.
//  Copyright © 2019 Kami Sama. All rights reserved.
//

#import "KMAlertView.h"
#import "KM_Config.h"







@interface KMAlertView ()

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIView *titleView;
@property (strong, nonatomic) UIImageView *iconImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *messageLabel;
@property (assign, nonatomic) NSTextAlignment textAlignment;

@property (strong, nonatomic) NSMutableArray *buttonArray;
@property (strong, nonatomic) NSMutableArray *buttonTitleArray;

@end

CGFloat contentViewWidth;
CGFloat contentViewHeight;

@implementation KMAlertView

- (instancetype)init {
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        self.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(event:)];
        _isCanUserInterface = YES;
        _backgroundView = [[UIView alloc] initWithFrame:self.frame];
        _backgroundView.backgroundColor = [UIColor blackColor];
        [_backgroundView addGestureRecognizer:tapGesture];
        [self addSubview:_backgroundView];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title icon:(UIImage *)icon message:(NSString *)message textAlignment:(NSTextAlignment)textAlignment delegate:(id<KMAlertViewDelegate> )delegate buttonTitles:(NSString *)buttonTitles, ... {
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        self.center = CGPointMake(KM_ScreenWidth/2.0, KM_ScreenHeight/2.0);
        _icon = icon;
        _title = title;
        _message = message;
        _textAlignment = textAlignment;
        _delegate = delegate;
        _buttonArray = [NSMutableArray array];
        _buttonTitleArray = [NSMutableArray array];
        
        va_list args;
        va_start(args, buttonTitles);
        if (buttonTitles)
        {
            [_buttonTitleArray addObject:buttonTitles];
            while (1)
            {
                NSString *  otherButtonTitle = va_arg(args, NSString *);
                if(otherButtonTitle == nil) {
                    break;
                } else {
                    [_buttonTitleArray addObject:otherButtonTitle];
                }
            }
        }
        va_end(args);
        
        self.backgroundColor = [UIColor clearColor];
        
        _backgroundView = [[UIView alloc] initWithFrame:self.frame];
        _backgroundView.backgroundColor = [UIColor blackColor];
        [self addSubview:_backgroundView];
        [self initContentView];
    }
    return self;
}

- (void)setContentView:(UIView *)contentView {
    _contentView = contentView;
    _contentView.center = self.center;
    [self addSubview:_contentView];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [self initContentView];
}

- (void)setIcon:(UIImage *)icon {
    _icon = icon;
    [self initContentView];
}

- (void)setMessage:(NSString *)message {
    _message = message;
    [self initContentView];
}

// Init the content of content view
- (void)initContentView {
    contentViewWidth = 240 * self.frame.size.width / 320;
    contentViewHeight = MARGIN_TOP;
    
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.95];
    _contentView.layer.cornerRadius = 10.0;
    _contentView.layer.masksToBounds = YES;
    
    [self initTitleAndIcon];
    [self initMessage];
    [self initAllButtons];
    
    _contentView.frame = CGRectMake(0, 0, contentViewWidth, contentViewHeight);
    _contentView.center = self.center;
    [self addSubview:_contentView];
}

// Init the title and icon
- (void)initTitleAndIcon {
    _titleView = [[UIView alloc] init];
    if (_icon != nil) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.image = _icon;
        _iconImageView.frame = CGRectMake(0, 0, 20, 20);
        [_titleView addSubview:_iconImageView];
    }
    
    CGSize titleSize = [self getTitleSize];
    if (_title != nil && ![_title isEqualToString:@""]) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = _title;
        _titleLabel.textColor = KM_RGBA(28, 28, 28, 1.0);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont boldSystemFontOfSize:TITLE_FONT_SIZE];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.frame = CGRectMake(_iconImageView.frame.origin.x + _iconImageView.frame.size.width, 1, titleSize.width+SPACE_LARGE, titleSize.height);
        [_titleView addSubview:_titleLabel];
    }
    
    _titleView.frame = CGRectMake(0, MARGIN_TOP, _iconImageView.frame.size.width + SPACE_LARGE + titleSize.width, MAX(_iconImageView.frame.size.height, titleSize.height));
    _titleView.center = CGPointMake(contentViewWidth / 2, MARGIN_TOP + _titleView.frame.size.height / 2);
    if (_titleLabel != nil) {
        _titleLabel.frame = CGRectMake(0, 0, _titleView.frame.size.width, 30);
    }
    [_contentView addSubview:_titleView];
    contentViewHeight += _titleView.frame.size.height;
}

// Init the message
- (void)initMessage {
    if (_message != nil) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.text = _message;
        _messageLabel.textColor = KM_Color333;
        _messageLabel.numberOfLines = 0;
        _messageLabel.font = [UIFont systemFontOfSize:MESSAGE_FONT_SIZE];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineSpacing = MESSAGE_LINE_SPACE;
        NSDictionary *attributes = @{NSParagraphStyleAttributeName:paragraphStyle};
        _messageLabel.attributedText = [[NSAttributedString alloc]initWithString:_message attributes:attributes];
        _messageLabel.textAlignment = _textAlignment;
        
        CGSize messageSize = [self getMessageSize];
        _messageLabel.frame = CGRectMake(MARGIN_LEFT_LARGE, _titleView.frame.origin.y + _titleView.frame.size.height + SPACE_LARGE, MAX(contentViewWidth - MARGIN_LEFT_LARGE - MARGIN_RIGHT_LARGE, messageSize.width), messageSize.height);
        [_contentView addSubview:_messageLabel];
        contentViewHeight += SPACE_LARGE + _messageLabel.frame.size.height;
    }
}

// Init all the buttons according to button titles
- (void)initAllButtons {
    if (_buttonTitleArray.count > 0) {
        contentViewHeight += SPACE_LARGE + 45;
        UIView *horizonSperatorView = [[UIView alloc] initWithFrame:CGRectMake(0, _messageLabel.frame.origin.y + _messageLabel.frame.size.height + SPACE_LARGE, contentViewWidth, 1)];
        horizonSperatorView.backgroundColor = KM_RGBA(218, 218, 222, 1.0);
        [_contentView addSubview:horizonSperatorView];
        
        CGFloat buttonWidth = contentViewWidth / _buttonTitleArray.count;
        for (NSString *buttonTitle in _buttonTitleArray) {
            NSInteger index = [_buttonTitleArray indexOfObject:buttonTitle];
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(index * buttonWidth, horizonSperatorView.frame.origin.y + horizonSperatorView.frame.size.height, buttonWidth, 44)];
            button.titleLabel.font = [UIFont boldSystemFontOfSize:BUTTON_FONT_SIZE];
            [button setTitle:buttonTitle forState:UIControlStateNormal];
            [button setTitleColor:KM_BaseColor forState:UIControlStateNormal];
            [button addTarget:self action:@selector(buttonWithPressed:) forControlEvents:UIControlEventTouchUpInside];
            [_buttonArray addObject:button];
            [_contentView addSubview:button];
            
            if (index < _buttonTitleArray.count - 1) {
                UIView *verticalSeperatorView = [[UIView alloc] initWithFrame:CGRectMake(button.frame.origin.x + button.frame.size.width, button.frame.origin.y, 1, button.frame.size.height)];
                verticalSeperatorView.backgroundColor = KM_RGBA(218, 218, 222, 1.0);
                [_contentView addSubview:verticalSeperatorView];
            }
        }
    }
}

// Get the size fo title
- (CGSize)getTitleSize {
    UIFont *font = [UIFont systemFontOfSize:TITLE_FONT_SIZE];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    CGSize size = [_title boundingRectWithSize:CGSizeMake(contentViewWidth - (MARGIN_LEFT_SMALL + MARGIN_RIGHT_SMALL + _iconImageView.frame.size.width + SPACE_SMALL), 2000)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:attributes context:nil].size;
    
    size.width = ceil(size.width);
    size.height = ceil(size.height);
    
    return size;
}

// Get the size of message
- (CGSize)getMessageSize {
    UIFont *font = [UIFont systemFontOfSize:MESSAGE_FONT_SIZE];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = MESSAGE_LINE_SPACE;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    CGSize size = [_message boundingRectWithSize:CGSizeMake(contentViewWidth - (MARGIN_LEFT_LARGE + MARGIN_RIGHT_LARGE), 2000)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:attributes context:nil].size;
    
    size.width = ceil(size.width);
    size.height = ceil(size.height);
    
    return size;
}

- (void)buttonWithPressed:(UIButton *)button {
    if (self.touchAlterButton) {
        NSInteger index = [_buttonTitleArray indexOfObject:button.titleLabel.text];
        self.touchAlterButton(index);
    }
    [self hide];
}

- (void)show {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;//[Methods lastWindow];
    NSArray *windowViews = [window subviews];
    if(windowViews && [windowViews count] > 0){
        UIView *subView = [windowViews objectAtIndex:[windowViews count]-1];
        for(UIView *aSubView in subView.subviews)
        {
            [aSubView.layer removeAllAnimations];
        }
        [window addSubview:self];
        [self showBackground];
        [self showAlertAnimation];
    }
}

- (void)showInCurrentVC:(UIViewController *)vc{
    [vc.view addSubview:self];
    [self showBackground];
    [self showAlertAnimation];
}
- (void)showInCurrentView:(UIView *)view{
    [view addSubview:self];
    [self showBackground];
    [self showAlertAnimation];
}
- (void)hide {
    _contentView.hidden = YES;
    [self hideAlertAnimation];
    [self removeFromSuperview];
}

- (void)setTitleColor:(UIColor *)color fontSize:(CGFloat)size {
    if (color != nil) {
        _titleLabel.textColor = color;
    }
    
    if (size > 0) {
        _titleLabel.font = [UIFont systemFontOfSize:size];
    }
}

- (void)setMessageColor:(UIColor *)color fontSize:(CGFloat)size {
    if (color != nil) {
        _messageLabel.textColor = color;
    }
    
    if (size > 0) {
        _messageLabel.font = [UIFont systemFontOfSize:size];
    }
}

- (void)setButtonTitleColor:(UIColor *)color fontSize:(CGFloat)size atIndex:(NSInteger)index {
    UIButton *button = _buttonArray[index];
    if (color != nil) {
        [button setTitleColor:color forState:UIControlStateNormal];
    }
    
    if (size > 0) {
        button.titleLabel.font = [UIFont systemFontOfSize:size];
    }
}

- (void)showBackground
{
    _backgroundView.alpha = 0;
    [UIView beginAnimations:@"fadeIn" context:nil];
    [UIView setAnimationDuration:0.35];
    _backgroundView.alpha = 0.5;
    [UIView commitAnimations];
}

-(void)showAlertAnimation
{
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.30;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    [_contentView.layer addAnimation:animation forKey:nil];
}

- (void)hideAlertAnimation {
    [UIView beginAnimations:@"fadeIn" context:nil];
    [UIView setAnimationDuration:0.35];
    _backgroundView.alpha = 0.0;
    [UIView commitAnimations];
}
-(void)event:(UITapGestureRecognizer *)gesture{
    if (!self.isCanUserInterface) {
    }else{
        [self hide];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

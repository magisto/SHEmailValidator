//
//  SHAutocorrectSuggestionView.m
//  SHEmailValidator
//
//  Created by Eric Kuck on 10/12/13.
//  Copyright (c) 2013 SpotHero.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

#import "SHAutocorrectSuggestionView.h"
#import <QuartzCore/QuartzCore.h>

static const NSInteger kCornerRadius = 10;
static const NSInteger kArrowHeight = 10;
static const NSInteger kArrowWidth = 10;
static const NSInteger kMaxWidth = 240;
static const NSInteger kDismissButtonWidth = 30;

@interface SHAutocorrectSuggestionView ()

@property (nonatomic, strong) UIView *target;
@property (nonatomic, strong) NSString *title;
@property (nonatomic) CGRect titleRect;
@property (nonatomic) CGRect suggestionRect;

@end

@implementation SHAutocorrectSuggestionView
{
    BOOL _flipXPosition;
}

+ (instancetype)showFromView:(UIView *)target inContainerView:(UIView *)container title:(NSString *)title autocorrectSuggestion:(NSString *)suggestion withSetupBlock:(SetupBlock)block
{
    SHAutocorrectSuggestionView *suggestionView = [[SHAutocorrectSuggestionView alloc] initWithTarget:target title:title autocorrectSuggestion:suggestion withSetupBlock:block];
    
    [suggestionView showFromView:target inContainerView:container];
    return suggestionView;
}

+ (instancetype)showFromView:(UIView *)target title:(NSString *)title autocorrectSuggestion:(NSString *)suggestion withSetupBlock:(SetupBlock)block
{
    return [SHAutocorrectSuggestionView showFromView:target inContainerView:target.superview title:title autocorrectSuggestion:suggestion withSetupBlock:block];
}

+ (UIColor *)defaultFillColor
{
    return [UIColor blackColor];
}

+ (UIColor *)defaultTitleColor
{
    return [UIColor whiteColor];
}

+ (UIColor *)defaultSuggestionColor
{
    return [UIColor colorWithRed:65.0/255 green:235.0/255 blue:175.0/255 alpha:1];
}

+ (UIFont*)defaultTitleFont
{
    return [UIFont fontWithName:@"Value" size:18];
}

+ (UIFont*)defaultSuggestionFont
{
    return [UIFont fontWithName:@"Value" size:18];
}

- (instancetype)initWithTarget:(UIView *)target title:(NSString *)title autocorrectSuggestion:(NSString *)suggestion withSetupBlock:(SetupBlock)block
{
    if ((self = [super init])) {
        self.title = title;
        self.suggestedText = suggestion;
        
        BOOL isLTR = [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionLeftToRight;
        _flipXPosition = isLTR ? NO : YES;
        
        if (!self.titleFont) {
            self.titleFont = [SHAutocorrectSuggestionView defaultTitleFont];
        }
        
        if (!self.suggestionFont) {
            self.suggestionFont = [SHAutocorrectSuggestionView defaultSuggestionFont];
        }

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        NSMutableParagraphStyle * paragraphTitleStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphTitleStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphTitleStyle.alignment = NSTextAlignmentNatural;
        paragraphTitleStyle.lineHeightMultiple = 0.85;
        
        NSMutableParagraphStyle * paragraphSuggestedStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphSuggestedStyle.lineBreakMode = NSLineBreakByCharWrapping;
        paragraphSuggestedStyle.alignment = NSTextAlignmentNatural;
        paragraphSuggestedStyle.lineHeightMultiple = 0.85;
        
        CGRect titleSizeRect = [title boundingRectWithSize:CGSizeMake(kMaxWidth - kDismissButtonWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleFont, NSParagraphStyleAttributeName:paragraphTitleStyle, NSForegroundColorAttributeName:[UIColor whiteColor]} context:nil];
        CGSize titleSize = titleSizeRect.size;
        
        CGRect suggestionSizeRect = [suggestion boundingRectWithSize:CGSizeMake(kMaxWidth - kDismissButtonWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.suggestionFont, NSParagraphStyleAttributeName:paragraphSuggestedStyle, NSForegroundColorAttributeName:[SHAutocorrectSuggestionView defaultSuggestionColor]} context:nil];
        CGSize suggestionSize = suggestionSizeRect.size;
#else
        CGSize titleSize = [title sizeWithFont:self.titleFont constrainedToSize:CGSizeMake(kMaxWidth - kDismissButtonWidth, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        CGSize suggestionSize = [suggestion sizeWithFont:self.suggestionFont constrainedToSize:CGSizeMake(kMaxWidth - kDismissButtonWidth, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
#endif
        CGFloat width = MAX(titleSize.width, suggestionSize.width) + kDismissButtonWidth + kCornerRadius * 2;
        CGFloat height = titleSize.height + suggestionSize.height + kArrowHeight + kCornerRadius * 2 - 5;
        CGFloat left = MAX(10, target.center.x - width / 2);
        CGFloat top = target.frame.origin.y - height + 4;
        
        self.frame = CGRectIntegral(CGRectMake(left, top, width, height));
        self.opaque = NO;
        if (!_flipXPosition) {
            self.titleRect = CGRectMake(kCornerRadius, kCornerRadius, titleSize.width, titleSize.height);
            self.suggestionRect = CGRectMake(kCornerRadius, kCornerRadius + titleSize.height, suggestionSize.width, suggestionSize.height);
        } else {
            self.titleRect = CGRectMake(self.frame.size.width - titleSize.width - kCornerRadius, kCornerRadius, titleSize.width, titleSize.height);
            self.suggestionRect = CGRectMake(kCornerRadius+kDismissButtonWidth, kCornerRadius + titleSize.height, suggestionSize.width, suggestionSize.height);
        }
        
        if (block) {
            block(self);
        }
        
        if (!self.fillColor) {
            self.fillColor = [SHAutocorrectSuggestionView defaultFillColor];
        }
        
        if (!self.titleColor) {
            self.titleColor = [SHAutocorrectSuggestionView defaultTitleColor];
        }
        
        if (!self.suggestionColor) {
            self.suggestionColor = [SHAutocorrectSuggestionView defaultSuggestionColor];
        }
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGSize contentSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height - kArrowHeight);
    CGPoint arrowBottom = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height);
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, arrowBottom.x, arrowBottom.y);
    CGPathAddLineToPoint(path, NULL, arrowBottom.x - kArrowWidth, arrowBottom.y - kArrowHeight);
    
    CGPathAddArcToPoint(path, NULL, 0, contentSize.height, 0, contentSize.height - kCornerRadius, kCornerRadius);
    CGPathAddArcToPoint(path, NULL, 0, 0, kCornerRadius, 0, kCornerRadius);
    CGPathAddArcToPoint(path, NULL, contentSize.width, 0, contentSize.width, kCornerRadius, kCornerRadius);
    CGPathAddArcToPoint(path, NULL, contentSize.width, contentSize.height, contentSize.width - kCornerRadius, contentSize.height, kCornerRadius);
    
    CGPathAddLineToPoint(path, NULL, arrowBottom.x + kArrowWidth, arrowBottom.y - kArrowHeight);
    
    CGPathCloseSubpath(path);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGContextSetFillColorWithColor(context, self.fillColor.CGColor);
    CGContextFillRect(context, self.bounds);
    
    CGContextRestoreGState(context);
    CGPathRelease(path);
    
    if (!_flipXPosition) {
        CGFloat separatorX = contentSize.width - kDismissButtonWidth;
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextSetLineWidth(context, 1);
        CGContextMoveToPoint(context, separatorX, 0);
        CGContextAddLineToPoint(context, separatorX, contentSize.height);
        CGContextStrokePath(context);
        
        CGFloat xSize = 10;
        CGContextSetLineWidth(context, 1);
        CGContextMoveToPoint(context, separatorX + (kDismissButtonWidth - xSize) / 2, (contentSize.height - xSize) / 2);
        CGContextAddLineToPoint(context, separatorX + (kDismissButtonWidth + xSize) / 2, (contentSize.height + xSize) / 2);
        CGContextStrokePath(context);
        CGContextMoveToPoint(context, separatorX + (kDismissButtonWidth - xSize) / 2, (contentSize.height + xSize) / 2);
        CGContextAddLineToPoint(context, separatorX + (kDismissButtonWidth + xSize) / 2, (contentSize.height - xSize) / 2);
        CGContextStrokePath(context);
    } else {
        CGFloat separatorX = kDismissButtonWidth;
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextSetLineWidth(context, 1);
        CGContextMoveToPoint(context, separatorX, 0);
        CGContextAddLineToPoint(context, separatorX, contentSize.height);
        CGContextStrokePath(context);
        
        CGFloat xSize = 10;
        CGContextSetLineWidth(context, 1);
        CGContextMoveToPoint(context, (kDismissButtonWidth - xSize) / 2, (contentSize.height - xSize) / 2);
        CGContextAddLineToPoint(context, (kDismissButtonWidth + xSize) / 2, (contentSize.height + xSize) / 2);
        CGContextStrokePath(context);
        CGContextMoveToPoint(context, (kDismissButtonWidth - xSize) / 2, (contentSize.height + xSize) / 2);
        CGContextAddLineToPoint(context, (kDismissButtonWidth + xSize) / 2, (contentSize.height - xSize) / 2);
        CGContextStrokePath(context);
    }
    
    [self.titleColor set];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    NSMutableParagraphStyle * paragraphTitleStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphTitleStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphTitleStyle.alignment = NSTextAlignmentNatural;
    paragraphTitleStyle.lineHeightMultiple = 0.85;
    NSMutableParagraphStyle * paragraphSuggestedStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphSuggestedStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paragraphSuggestedStyle.alignment = NSTextAlignmentNatural;
    paragraphSuggestedStyle.lineHeightMultiple = 0.85;
    [self.title drawInRect:self.titleRect withAttributes:@{NSFontAttributeName:self.titleFont, NSParagraphStyleAttributeName:paragraphTitleStyle, NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self.suggestionColor set];
    [self.suggestedText drawInRect:self.suggestionRect withAttributes:@{NSFontAttributeName:self.suggestionFont, NSParagraphStyleAttributeName:paragraphSuggestedStyle, NSForegroundColorAttributeName:[SHAutocorrectSuggestionView defaultSuggestionColor]}];
#else
    [self.title drawInRect:self.titleRect withFont:self.titleFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    [self.suggestionColor set];
    [self.suggestedText drawInRect:self.suggestionRect withFont:self.suggestionFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
#endif
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (touches.count == 1) {
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInView:self];
        
        CGSize viewSize = self.bounds.size;
        if (touchPoint.x >= 0 && touchPoint.x < viewSize.width && touchPoint.y >= 0 && touchPoint.y < viewSize.height - kArrowHeight) {
            if (!_flipXPosition) {
                if (touchPoint.x <= viewSize.width - kDismissButtonWidth && self.suggestedText) {
                    [self.delegate suggestionView:self wasDismissedWithAccepted:YES];
                    [self dismiss];
                } else {
                    [self.delegate suggestionView:self wasDismissedWithAccepted:NO];
                    [self dismiss];
                }
            } else {
                if (touchPoint.x >= kDismissButtonWidth && self.suggestedText) {
                    [self.delegate suggestionView:self wasDismissedWithAccepted:YES];
                    [self dismiss];
                } else {
                    [self.delegate suggestionView:self wasDismissedWithAccepted:NO];
                    [self dismiss];
                }
            }
        }
    }
}

- (void)showFromView:(UIView *)target inContainerView:(UIView *)container
{
    self.target = target;
    
    self.alpha = 0.2;
    self.transform = CGAffineTransformMakeScale(0.6, 0.6);
    
    // Frame is in target.superview coordinates
    self.frame = [target.superview convertRect:self.frame toView:container];
    [container addSubview:self];
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.alpha = 1;
                         self.transform = CGAffineTransformMakeScale(1.1, 1.1);
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.1
                                          animations:^{
                                              self.transform = CGAffineTransformIdentity;
                                          }];
                     }];
}

- (void)updatePosition
{
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat left = MAX(10, self.target.center.x - width / 2);
    CGFloat top = self.target.frame.origin.y - height;
    
    self.frame = CGRectIntegral([self.target.superview convertRect:CGRectMake(left, top, width, height) toView:self.superview]);
}

- (void)dismiss
{
    [UIView animateWithDuration:0.1
                     animations:^{
                         self.transform = CGAffineTransformMakeScale(1.1, 1.1);
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2
                                          animations:^{
                                              self.alpha = 0.2;
                                              self.transform = CGAffineTransformMakeScale(0.6, 0.6);
                                          }
                                          completion:^(BOOL innerFinished) {
                                              [self removeFromSuperview];
                                              self.target = nil;
                                          }];
                     }];
}

@end

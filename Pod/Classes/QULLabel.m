//
//  QULLabel.m
//  Pods
//
//  Created by Scott Chou on 24/05/2017.
//
//

#import "QULLabel.h"

@implementation QULLabel

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
	CGRect insetRect = UIEdgeInsetsInsetRect(bounds, self.textInsets);
	CGRect textRect = [super textRectForBounds:insetRect limitedToNumberOfLines:self.numberOfLines];
	UIEdgeInsets invertedInsets = UIEdgeInsetsMake(-self.textInsets.top,
												   -self.textInsets.left,
												   -self.textInsets.bottom,
												   -self.textInsets.right);
	return UIEdgeInsetsInsetRect(textRect, invertedInsets);
}

- (void)drawTextInRect:(CGRect)rect {
	[super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.textInsets)];
}

@end

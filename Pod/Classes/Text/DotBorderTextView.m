//
//  DotBorderTextView.m
//  Pods
//
//  Created by Scott Chou on 25/05/2017.
//
//

#import "DotBorderTextView.h"

@interface DotBorderTextView ()

@property (strong, nonatomic) CAShapeLayer *dotLayer;

@end

@implementation DotBorderTextView

- (void)layoutSubviews {
	self.dotLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius].CGPath;
	self.dotLayer.frame = self.bounds;
}

#pragma mark - Public methods

- (void)showDotBorder:(BOOL)show {
	self.dotLayer.hidden = !show;
}

#pragma mark - Getter

- (CAShapeLayer *)dotLayer {
	if (_dotLayer) {
		return _dotLayer;
	}

	_dotLayer = [CAShapeLayer layer];
	_dotLayer.strokeColor = [UIColor colorWithRed:107/255.f green:107/255.f blue:107/255.f alpha:1].CGColor; // #6B6B6B
	_dotLayer.fillColor = nil;
	_dotLayer.lineDashPattern = @[@5, @8];
	[self.layer addSublayer:_dotLayer];

	return _dotLayer;
}

@end

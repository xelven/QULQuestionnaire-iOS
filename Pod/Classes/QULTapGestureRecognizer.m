//
//  QULTapGestureRecognizer.m
//  Pods
//
//  Created by Allen Chan on 06/02/2017.
//
//

#import "QULTapGestureRecognizer.h"

@implementation QULButton

-(void)setSelected:(BOOL)selected
{
	[super setSelected:selected];
	if(self.labelObj){
		if(selected == YES){
			self.labelObj.font = [UIFont boldSystemFontOfSize:17];
		} else {
			self.labelObj.font = [UIFont systemFontOfSize:17];
		}
	}
}

@end

@implementation QULTapGestureRecognizer

@end

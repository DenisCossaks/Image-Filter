#import "CustomCell.h"

@implementation CustomCell

@synthesize image1,image2,image3,image4;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{

if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
	// Initialization code
		image1=[[UIButton alloc] initWithFrame:CGRectMake(5+10+5,05,90,90)];
		image2=[[UIButton alloc] initWithFrame:CGRectMake(5+90+5+10+5,5,90,90)];
		image3=[[UIButton alloc] initWithFrame:CGRectMake(5+90+5+90+5+10+5,5,90,90)];

		[self.contentView addSubview:image1];
		[self.contentView addSubview:image2];
		[self.contentView addSubview:image3];
	}
    return self;
}

-(void)layoutSubviews
{
    image1.frame = CGRectMake(5+10+5,05,90,90);
	image2.frame = CGRectMake(5+90+5+10+5,5,90,90);
	image3.frame = CGRectMake(5+90+5+90+5+10+5,5,90,90);
	[super layoutSubviews];
}


@end

//
//  2015 Magna cum laude. PD
//

#import "UIDevice+MachineProperties.h"

#import <sys/utsname.h>


typedef struct
{
    enum { kMachineSimulator = 0, kMachinePod = 1, kMachinePhone = 2, kMachinePad = 3, kMachineTV } kind;
    short major, minor;
} machine_t;

@implementation UIDevice (MachineSpecific)

- (NSString *)machineString
{
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

- (machine_t)machine
{
    NSString *machineString = self.machineString;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(iPod|iPhone|iPad|AppleTV)([0-9]+),([0-9]+)" options:0 error:NULL];
    NSArray *c = [regex matchesInString:machineString options:0 range:NSMakeRange(0, machineString.length)];
    if (c.count >= 3)
        return (machine_t)
    {
        [c[0] isEqualToString:@"iPod"]?		kMachinePod :
        [c[0] isEqualToString:@"iPhone"]?	kMachinePhone :
		[c[0] isEqualToString:@"iPad"]?		kMachinePad :
		[c[0] isEqualToString:@"AppleTV"]?	kMachineTV :
											kMachineSimulator,
        [c[1] shortValue],
        [c[2] shortValue]
    };
    else
        return (machine_t){ kMachineSimulator };
}

- (CGFloat)pointsPerInch
{
    machine_t machine = self.machine;
    
    if (machine.kind == kMachineSimulator)
        // iPhone Simulator: rely on the UI idiom (wrong results on iPhone 6(S)+, iPad Mini)
        switch (self.userInterfaceIdiom)
        {
            case UIUserInterfaceIdiomPad: return 132.0f;
			case UIUserInterfaceIdiomPhone: return 163.0f;
#if TARGET_OS_TV
            case UIUserInterfaceIdiomTV: return 55.0f; // ~40 inch display driven at 1080p
#endif
            default: return 163.0f;
        }
	
	else if (machine.kind == kMachineTV)
		// Apple TV: single pixels, pixels-per-inch dependent on connected display
		// TODO: read actual display parameters once such an API exists within tvOS
		return 55.0f; // ~40 inch display driven at 1080p
    
    else if (machine.kind == kMachinePhone && machine.major == 7 && machine.minor == 1)
        // iPhone 6 Plus: triple pixels, 401 pixels-per-inch
        return 133.667f;
	
	else if (machine.kind == kMachinePhone && machine.major == 8 && machine.minor == 2)
		// iPhone 6S Plus: triple pixels, 401 pixels-per-inch
		return 133.667f;
	
    else if (machine.kind != kMachinePad)
        // iPhone, 3G, 3GS / iPod Touch 1st, 2nd, or 3rd gen: single pixels
        // iPhone / iPod Touch (all later models): double pixels, 326 pixels-per-inch
        return 163.0f;
    
    else if (machine.major == 2 && machine.minor >= 5 && machine.minor <= 7)
        // iPad Mini 1: single pixels
        return 163.0f;
    
    else if (machine.major == 4 && machine.minor >= 4 && machine.minor <= 9)
        // iPad Mini 2 or 3: double pixels, 326 pixels-per-inch
        return 163.0f;
	
	else if (machine.major == 5 && machine.minor >= 1 && machine.minor <= 2)
		// iPad 4: double pixels, 326 pixels-per-inch
		return 163.0f;
	
    else
        // iPad or iPad 2: single pixels
        // iPad, 3rd or 4th gen: double pixels, 264 pixels-per-inch
        // iPad Air 1 or 2: double pixels, 264 pixels-per-inch
		// iPad Pro: double pixels, 264 pixels-per-inch
        return 132.0f;
}

@end
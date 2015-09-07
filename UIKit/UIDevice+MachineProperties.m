//
//  2015 Magna cum laude. PD
//

#import "UIDevice+MachineProperties.h"

#import <sys/utsname.h>


typedef struct
{
    enum { kMachineSimulator = 0, kMachinePod = 1, kMachinePhone = 2, kMachinePad = 3 } kind;
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
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(iPod|iPhone|iPad)([0-9]+),([0-9]+)" options:0 error:NULL];
    NSArray *c = [regex matchesInString:machineString options:0 range:NSMakeRange(0, machineString.length)];
    if (c.count >= 3)
        return (machine_t)
    {
        [c[0] isEqualToString:@"iPod"]? kMachinePod :
        [c[0] isEqualToString:@"iPhone"]? kMachinePhone :
        [c[0] isEqualToString:@"iPad"]? kMachinePad : kMachineSimulator,
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
        // iPhone Simulator: rely on the UI idiom (wrong results on iPhone 6+, iPad Mini)
        return (self.userInterfaceIdiom == UIUserInterfaceIdiomPad)? 132.0f : 163.0f;
    
    else if (machine.kind == kMachinePhone && machine.major == 7 && machine.minor == 1)
        // iPhone 6 Plus (triple pixels, 401 PixPI)
        return 133.667f;
    
    else if (machine.kind != kMachinePad)
        // iPhone, 3G, 3GS / iPod Touch 1st, 2nd, or 3rd gen (single pixels)
        // iPhone 4, 4S, 5, 5C, 5S, 6 / iPod Touch 4th or 5th gen (double pixels, 326 PixPI)
        return 163.0f;
    
    else if (machine.major == 2 && machine.minor >= 5)
        // iPad Mini 1 (single pixels)
        return 163.0f;
    
    else if (machine.major == 4 && machine.minor >= 4)
        // iPad Mini 2 or 3 (double pixels, 326 PixPI)
        return 163.0f;
    
    else
        // iPad or iPad 2 (single pixels)
        // iPad, 3rd or 4th gen (double pixels, 264 PixPI)
        // iPad Air 1 or 2 (double pixels, 264 PixPI)
        return 132.0f;
}

@end
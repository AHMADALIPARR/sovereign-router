#import <Foundation/Foundation.h>
#include <stdint.h>
#include <errno.h>
#include <caml/mlvalues.h>
#include <caml/callback.h>
#include <caml/alloc.h>
#include <caml/memory.h>
#include <caml/fail.h>

@interface SovereignTraceRouter : NSObject
- (NSString *)routeExecutionTraceWithBudget:(uint32_t)budget;
@end

@implementation SovereignTraceRouter
- (NSString *)routeExecutionTraceWithBudget:(uint32_t)budget {
    CAMLparam0();
    CAMLlocal2(argument, result);
    if (budget > UINT32_MAX / 2) {
        [NSException raise:NSInvalidArgumentException format:@"Budget exceeds checked uint32 trace domain"];
    }
    const value *closure = caml_named_value("torus_trace_calc");
    if (!closure) [NSException raise:NSInternalInconsistencyException format:@"Trace backend not registered"];
    char decimal[32];
    snprintf(decimal, sizeof decimal, "%u", budget);
    argument = caml_copy_string(decimal);
    result = caml_callback_exn(*closure, argument);
    if (Is_exception_result(result)) [NSException raise:NSInternalInconsistencyException format:@"Trace backend rejected input"];
    NSString *trace = [NSString stringWithUTF8String:String_val(result)];
    CAMLreturnT(NSString *, trace);
}
@end

int main(int argc, char **argv) {
    if (argc > 3) { fprintf(stderr, "usage: sovereign_router [budget [ledger.jsonl]]\n"); return 2; }
    const char *input = argc > 1 ? argv[1] : "9959";
    char *end = NULL;
    errno = 0;
    unsigned long long budget = strtoull(input, &end, 10);
    if (errno || !*input || *end || *input == '-' || budget > UINT32_MAX / 2) {
        fprintf(stderr, "budget must be in [0,2147483647]\n"); return 2;
    }
    char *runtime_args[] = {"sovereign_router", NULL};
    caml_startup(runtime_args);
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    int status = 0;
    @try {
        SovereignTraceRouter *router = [SovereignTraceRouter new];
        NSString *trace = [router routeExecutionTraceWithBudget:(uint32_t)budget];
        NSDictionary *entry = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedLongLong:budget], @"budget", trace, @"trace", @"Isabelle/OCaml", @"backend", nil];
        NSError *error = nil;
        NSData *json = [NSJSONSerialization dataWithJSONObject:entry options:0 error:&error];
        if (!json) [NSException raise:NSInternalInconsistencyException format:@"JSON encoding failed: %@", error];
        NSMutableData *line = [NSMutableData dataWithData:json];
        [line appendData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
        if (argc == 3) {
            FILE *ledger = fopen(argv[2], "ab");
            if (!ledger) [NSException raise:NSInternalInconsistencyException format:@"Cannot open ledger"];
            BOOL wrote = fwrite([line bytes], 1, [line length], ledger) == [line length];
            int closed = fclose(ledger);
            if (!wrote || closed) [NSException raise:NSInternalInconsistencyException format:@"Ledger write failed"];
        }
        fwrite([line bytes], 1, [line length], stdout);
        [router release];
    } @catch (NSException *error) {
        fprintf(stderr, "%s\n", [[error reason] UTF8String]); status = 1;
    }
    [pool drain];
    return status;
}

//
//  LuaTest.m
//  APP
//
//  Created by Yu Cheng on 12-11-13.
//  Copyright (c) 2012年 RYTong. All rights reserved.
//

#import "LuaTest1.h"
#import "RYTConfig.h"
#import "RYTBodyControl.h"
#import "RYTControl.h"

extern "C"
{
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
}


@implementation LuaTest1

static LuaTest1 *sharedLuaTest1 = nil;
static     lua_State *lua_s;

+(id)sharedLuaObject {
    @synchronized ([LuaTest1 class]) {
        if (sharedLuaTest1 == nil) {
            [[LuaTest1 alloc] init];
            return sharedLuaTest1;
        }
    }
    return sharedLuaTest1;
}

+ (id)alloc {
    @synchronized ([LuaTest1 class]) {
        sharedLuaTest1 = [super alloc];
        return sharedLuaTest1;
    }
    return nil;
}

static int startTest(lua_State *lua) {
    RYTControl *tag = (RYTControl *)lua_touserdata(lua, 1);
    
    NSLog(@"1111111111==%@", tag);
    
    return 0;
}

- (void)openTest:(lua_State *)lua {
    lua_s = lua;
    /*注册自定义方法startTest*/
	lua_pushcfunction(lua, startTest);
	lua_setfield(lua,-2,"startTest");
}

@end

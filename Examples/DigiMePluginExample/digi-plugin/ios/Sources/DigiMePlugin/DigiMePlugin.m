//
//  DigiMePlugin.m
//  DigiMePlugin
//
//  Created on 16/07/2024.
//

#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

CAP_PLUGIN(DigiPluginPlugin, "DigiPlugin",
           CAP_PLUGIN_METHOD(fetchHealthData, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(dismissView, CAPPluginReturnPromise);
           )

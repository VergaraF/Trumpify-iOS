//
//  AppConfig.swift
//  
//
//  Created by Fabian Vergara on 2017-01-28.
//
//

import Foundation

//NUANCE API CREDENTIALS
var SKSAppKey     = "5e5b5c3ea65ddfbf9ca7c7787781bb3c4d38710d92b82253538cf7e8e836bc46911885377564f6120bbd8a823f46be8c7e2f9a10e8bc633b485a233090df7722"
var SKSAppId      = "NMDPTRIAL_f_vergar_encs_concordia_ca20170128115213"
var SKSServerHost = "sslsandbox-nmdp.nuancemobility.net"
var SKSServerPort = "443"

var SKSLanguage   = "eng-USA"

var SKSServerUrl = String(format: "nmsps://NMDPTRIAL_f_vergar_encs_concordia_ca20170128115213@sslsandbox-nmdp.nuancemobility.net:443", SKSAppId, SKSServerHost, SKSServerPort)

// Only needed if using NLU/Bolt
//var SKSNLUContextTag = "!NLU_CONTEXT_TAG!"


let LANGUAGE = SKSLanguage == "!LANGUAGE!" ? "eng-USA" : SKSLanguage

//SEMANTRIA API CREDENTIALS
var SEMANTRIAKey    = "e6376d5a-2175-4c05-930d-83d1ff52453b"
var SEMANTRIASecret = "3c4c4ae6-94fe-42da-800c-828fa991318f"

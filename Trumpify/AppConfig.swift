//
//  AppConfig.swift
//  
//
//  Created by Fabian Vergara on 2017-01-28.
//
//

import Foundation

//NUANCE API CREDENTIALS
var SKSAppKey     = "NONE"
var SKSAppId      = "NONE"
var SKSServerHost = "NONE"
var SKSServerPort = "NONE"

var SKSLanguage   = "eng-USA"

var SKSServerUrl = String(format: "NONE")
// Only needed if using NLU/Bolt
//var SKSNLUContextTag = "!NLU_CONTEXT_TAG!"


let LANGUAGE = SKSLanguage == "!LANGUAGE!" ? "eng-USA" : SKSLanguage

//SEMANTRIA API CREDENTIALS
var SEMANTRIAKey    = "NONE"
var SEMANTRIASecret = "NONE"

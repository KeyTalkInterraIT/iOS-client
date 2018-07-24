//
//  INIParser.swift
//  KeyTalk
//
//  Created by Paurush on 5/18/18.
//  Copyright © 2018 Paurush. All rights reserved.
//

import Foundation

class INIParser {
    
    public class func parseIni(aIniString: String) -> String {
        
        var lContentString = aIniString
        
        if !lContentString.hasPrefix("{"){
            lContentString = "{" + lContentString
        }
        if !lContentString.hasSuffix("}"){
            lContentString = lContentString + "}"
        }
        
        lContentString = lContentString.replacingOccurrences(of: "\n", with: "")
        lContentString = lContentString.replacingOccurrences(of: "\t", with: "")
        lContentString = lContentString.replacingOccurrences(of: "\r", with: "")
        
        var lRange = lContentString.range(of: "  ")
        while (lRange != nil) {
            lContentString = lContentString.replacingOccurrences(of: "  ", with: " ")
            lRange = lContentString.range(of: "  ")
        }
        
        lContentString = lContentString.replacingOccurrences(of: "://", with: "HACK01")
        lContentString = lContentString.replacingOccurrences(of: ":", with: "HACK02")
        
        lContentString = lContentString.replacingOccurrences(of: " = ", with: ":")
        lContentString = lContentString.replacingOccurrences(of: "= ", with: ":")
        lContentString = lContentString.replacingOccurrences(of: " =", with: ":")
        lContentString = lContentString.replacingOccurrences(of: "=", with: ":")
        
        lContentString = lContentString.replacingOccurrences(of: ";", with: ",")
        lContentString = lContentString.replacingOccurrences(of: "(", with: "[")
        lContentString = lContentString.replacingOccurrences(of: ")", with: "]")
        
        lContentString = lContentString.replacingOccurrences(of: ",}", with: "}")
        lContentString = lContentString.replacingOccurrences(of: ", }", with: "}")
        lContentString = lContentString.replacingOccurrences(of: ",]", with: "]")
        lContentString = lContentString.replacingOccurrences(of: ", ]", with: "]")
        
        lContentString = lContentString.replacingOccurrences(of: ":", with: "\":")
        lContentString = lContentString.replacingOccurrences(of: "{ ", with: "{")
        lContentString = lContentString.replacingOccurrences(of: "{", with: "{\"")
        
        lContentString = lContentString.replacingOccurrences(of: ",{", with: "HACK03")
        lContentString = lContentString.replacingOccurrences(of: ", { ", with: "HACK03")
        lContentString = lContentString.replacingOccurrences(of: ",\"", with: "HACK04")
        lContentString = lContentString.replacingOccurrences(of: ", \"", with: "HACK04")
        lContentString = lContentString.replacingOccurrences(of: ", ", with: ",")
        lContentString = lContentString.replacingOccurrences(of: ",", with: ",\"")
        
        lContentString = lContentString.replacingOccurrences(of: "HACK04", with: ",\"")
        lContentString = lContentString.replacingOccurrences(of: "HACK03", with: ",{")
        lContentString = lContentString.replacingOccurrences(of: "HACK02", with: ":")
        lContentString = lContentString.replacingOccurrences(of: "HACK01", with: "://")
        lContentString = lContentString.replacingOccurrences(of: "\"{", with: "{")
        
        return lContentString
    }
    
}

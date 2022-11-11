//
//  TagsService.swift
//  Highcharts-Code-Sample
//
//  Created by Shekhar Shelke on 04/11/22.
//

import Foundation
import UIKit

class TagsService
{
    /// function to parse sample data from JSON file [data.json]
    func fetchTagsData() -> [String: Any]
    {
        var array: [String: Any]?
        let Tags = type(of: self)
        let bundle = Bundle(for: Tags.self)
        if let url = bundle.path(forResource: "data", ofType: "json")
        {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: url), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? [String: Any] {
                    array = jsonResult
                }
                return jsonResult as! [String : Any]
            }
            catch {
                print("ERROR")
            }
        }
        return array ?? [:]
    }
}
    
    

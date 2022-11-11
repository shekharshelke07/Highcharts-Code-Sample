//
//  String + extension.swift
//  Highcharts-Code-Sample
//
//  Created by Shekhar Shelke on 03/11/22.
//

import Foundation

extension String
{
    func trimSpaces() -> String
    {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}


//
//  AnalyticsDataModel.swift
//  Highcharts-Code-Sample
//
//  Created by Shekhar Shelke on 04/11/22.
//

import Foundation

enum TagType
{
    case system
    case manual
}

struct AnalyticsDataModel
{
    var tagsMetrics: [TagMetrics]?
    
    init?(json: [String: Any])
    {
        guard let data = json["data"] as? [String: Any], let analytics = data["analytics"] as? [String: Any] else {
            return nil
        }
        if let tagsMetric = analytics["tagsMetrics"] as? [String: Any], let metrics = tagsMetric["metrics"] as? [[String: Any]] {
            tagsMetrics = metrics.compactMap {TagMetrics(metric: $0)}
        }
        
        if tagsMetrics == nil {
            return nil
        }
    }
}

struct Metrics
{
    var label: String
    var averageTotalValue: AnalyticsValue?
    var averageFilteredValue: AnalyticsValue?
    var countTotalValue: AnalyticsValue?
    var countFilteredValue: AnalyticsValue?
    
    init?(totalMetric: [String: Any])
    {
        guard let metrics = totalMetric["metrics"] as? [[String: Any]], let metricsData = metrics.first else {
            return nil
        }
        
        label = metricsData["label"] as? String ?? ""
        if let totalValue = (metricsData["average"] as? [String: Any])?["totalValue"] as? [String: Double] {
            averageTotalValue = AnalyticsValue(totalValue: totalValue)
        }
        
        if let filteredValue = (metricsData["average"] as? [String: Any])?["filteredValue"] as? [String: Double] {
            averageFilteredValue = AnalyticsValue(totalValue: filteredValue)
        }
        
        if let totalValue = (metricsData["count"] as? [String: Any])?["totalValue"] as? [String: Double] {
            countTotalValue = AnalyticsValue(totalValue: totalValue)
        }
        
        if let filteredValue = (metricsData["count"] as? [String: Any])?["filteredValue"] as? [String: Double] {
            countFilteredValue = AnalyticsValue(totalValue: filteredValue)
        }
        
    }
}

struct AnalyticsValue
{
    var value: Double
    var percentage: Double
    
    init(totalValue: [String: Double])
    {
        value = totalValue["value"] ?? 0.0
        percentage = totalValue["percentage"] ?? 0.0
    }
}

struct TagMetrics
{
    var entity: TagEntityModel?
    var total: TagData
    var positive: TagData
    var neutral: TagData
    var negative: TagData
    var tagType = TagType.system
    
    init?(metric: [String: Any])
    {
        guard let entityData = metric["entity"] as? [String: Any] else {
            return nil
        }
        guard let totalData = metric["total"] as? [String: Any], let positiveData = metric["positive"] as? [String: Any] else {
            return nil
        }
        guard let neutralData = metric["neutral"] as? [String: Any], let negativeData = metric["negative"] as? [String: Any] else {
            return nil
        }
        entity = TagEntityModel(data: entityData)
        total = TagData(data: totalData)
        positive = TagData(data: positiveData)
        neutral = TagData(data: neutralData)
        negative = TagData(data: negativeData)
        if entityData["ruleset"] as? [String: Any] != nil {
            tagType = .manual
        }
    }
}

struct TagData
{
    var value: Int
    var percentage: Double
    var plotPercentage: Double
    
    init(data: [String: Any])
    {
        value = data["value"] as? Int ?? 0
        percentage = data["percentage"] as? Double ?? 0.0
        plotPercentage = data["plotPercentage"] as? Double ?? 0.0
    }
}

struct TagEntityModel
{
    var tagName: String
    var tagId: Int
    var tagNameLocalised: String
    
    init?(data: [String: Any])
    {
        guard let id = data["id"], let label = data["label"] as? [String: String] else {
            return nil
        }
        if let idAsInt = id as? Int {
            tagId = idAsInt
        } else if let idAsString = id as? String, let value =  Int(idAsString) {
            tagId = value
        } else {
            return nil
        }
        tagName = data["name"] as? String ?? ""
        tagNameLocalised = label.values.first ?? ""
    }
}

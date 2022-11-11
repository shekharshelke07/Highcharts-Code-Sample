//
//  AnalyticsModels.swift
//  Highcharts-Code-Sample
//
//  Created by Shekhar Shelke on 04/11/22.
//

import UIKit

struct AnalyticsDataViewModel
{
    var tags: [TagsViewModel]
    var isTagsExpanded: Bool = false
    var isNewData: Bool = true
    
    init(analyticsData: AnalyticsDataModel)
    {
        tags = analyticsData.tagsMetrics?.compactMap {TagsViewModel(tag: $0, totalCount: 10000)} ?? []
        if tags.count <= 10 {
            isTagsExpanded = true
        }
    }
    
    mutating func updateTagsExpandedStatus(_ status: Bool)
    {
        isTagsExpanded = status
    }
    
    mutating func updateIsNewDataStatus(_ status: Bool)
    {
        isNewData = status
    }
}

struct TagsViewModel
{
    var label: String
    var id: Int
    var total: Double
    var positive: Double
    var neutral: Double
    var negative: Double
    var tagType: TagType
    
    init?(tag: TagMetrics, totalCount: Int)
    {
        guard let labelName = tag.entity?.tagNameLocalised, let tagId = tag.entity?.tagId else { return nil }
        label = labelName
        id = tagId
        tagType = tag.tagType
        if totalCount != 0 {
            positive = ((Double(tag.positive.value) / Double(totalCount)) * 100).rounded(toPlaces: 2)
            neutral = ((Double(tag.neutral.value) / Double(totalCount)) * 100).rounded(toPlaces: 2)
            negative = ((Double(tag.negative.value) / Double(totalCount)) * 100).rounded(toPlaces: 2)
        } else {
            positive = 0.0
            neutral = 0.0
            negative = 0.0
        }
        total = (positive + neutral + negative).rounded(toPlaces: 2)
    }
}


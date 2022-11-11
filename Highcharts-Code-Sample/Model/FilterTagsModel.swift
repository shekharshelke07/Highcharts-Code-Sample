//
//  FilterTagsModel
//  Highcharts-Code-Sample
//
//  Created by Shekhar Shelke on 04/11/22.
//
enum FilterIdEnum: Int
{
    case completeTagId = -1
    case sentimentTagId = -2
}

enum FilterType
{
    case completeIncomplete
    case sentiment
    case tag
}

enum Sentiment: String
{
    case positive = "POSITIVE"
    case neutral = "NEUTRAL"
    case negative =  "NEGATIVE"
}

class FilterModel: Equatable
{
    var name: String
    var id: Int
    var type: FilterType
    var value: Any?
    var tagType: TagType?
    
    init(name: String, id: Int, type: FilterType, value: Any? = nil, tagType: TagType? = nil)
    {
        self.name = name
        self.id = id
        self.type = type
        self.value = value
        self.tagType = tagType
    }
    
    static func == (lhs: FilterModel, rhs: FilterModel) -> Bool
    {
        return lhs.id == rhs.id
    }
    
    var localisedName: String {
        switch type {
        case .sentiment, .completeIncomplete:
            return name
        case .tag:
            return name
        }
    }
}

class FilterViewModel
{
    var filters = [FilterModel]()
    var isEmpty: Bool {
        return filters.isEmpty
    }
    func checkIfFiltersAlreadyPresent(_ filterArray: [FilterModel]) -> Bool
    {
        for item in filterArray {
            if !filters.contains(where: {$0.name == item.name}) {
                return false
            }
        }
        return true
    }
    
    func updateFilterViewModel(_ filterModel: FilterModel, isAdd: Bool = false)
    {
        if isAdd {
            if let index = filters.firstIndex(of: filterModel) {
                filters[index] = filterModel
            } else {
                filters.append(filterModel)
            }
        } else if let index = filters.firstIndex(of: filterModel) {
            filters.remove(at: index)
        }
    }
   
}

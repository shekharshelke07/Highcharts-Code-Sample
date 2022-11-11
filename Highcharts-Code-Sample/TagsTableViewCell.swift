//
//  TagsTableViewCell.swift
//  Highcharts-Code-Sample
//
//  Created by Shekhar Shelke on 04/11/22.
//

import UIKit
import Highcharts

protocol TagsTableViewCellDelegate: AnyObject
{
    func seeMoreTagsAction()
}

class TagsTableViewCell: UITableViewCell
{
    @IBOutlet weak var tagsTitleLabel: UILabel!
    @IBOutlet weak var negativeButton: UIButton!
    @IBOutlet weak var neutralButton: UIButton!
    @IBOutlet weak var positiveButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var graphContainerView: UIView!
    @IBOutlet weak var seeMoreTagsButton: UIButton!
    @IBOutlet weak var seeMoreTagsButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var seeMoreTagsButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var graphViewHeightConstraint: NSLayoutConstraint!
    
    var hideSeeMoreTagsButton: Bool = false {
        didSet {
            seeMoreTagsButton.isHidden = hideSeeMoreTagsButton
            if hideSeeMoreTagsButton {
                seeMoreTagsButtonHeightConstraint.constant = 0.0
                seeMoreTagsButtonBottomConstraint.constant = 0.0
            } else {
                seeMoreTagsButtonHeightConstraint.constant = 30.0
                seeMoreTagsButtonBottomConstraint.constant = 8.0
            }
        }
    }
    
    var tagViewModel: [TagsViewModel]!
    var allTags: [TagsViewModel]!
    private let initialTagsDisplayCount: Int = 10
    
    var chartView: HIChartView!
    weak var delegate: TagsTableViewCellDelegate?
    
    private let fontFamily = "IBMPlexSans-Regular"
    private let appTextColor = "rgb(37, 55, 70)"
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_ :)), for: .editingChanged)
        let placeHolderText = "Search Tags"
        searchTextField.attributedPlaceholder = NSAttributedString(string: placeHolderText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    }
    
    
    func configureCell(_ tags: [TagsViewModel], isExpanded: Bool, isNewData: Bool)
    {
        // Remove previously added chart.
        graphContainerView.subviews.forEach { chart in
            chart.removeFromSuperview()
        }
        if isNewData {
            positiveButton.isSelected = false
            negativeButton.isSelected = false
            neutralButton.isSelected = false
        }
        searchTextField.text = ""
        setSentimentButtonText()
        allTags = tags
        hideSeeMoreTagsButton = isExpanded
        prepareTagsView()
        prepareGraph()
    }
    
    private func prepareTagsView()
    {
        let filteredTags = filterAndSortTags(allTags)
        tagViewModel = hideSeeMoreTagsButton ? filteredTags : Array(filteredTags.prefix(initialTagsDisplayCount))
        
        let tagsCountForHeight = tagViewModel.isEmpty ? (Array(allTags.prefix(initialTagsDisplayCount))).count : tagViewModel.count
        let numberOfTagToShow = tagsCountForHeight > initialTagsDisplayCount ? initialTagsDisplayCount : tagsCountForHeight
        let expectedHeight: CGFloat = CGFloat(calculateGraphHeight(tagsCount: numberOfTagToShow))
        graphViewHeightConstraint.constant = expectedHeight
    }
    
    private func filterAndSortTags(_ tags: [TagsViewModel]) -> [TagsViewModel]
    {
        var filteredTags = tags.filter { model in
            
            if positiveButton.isSelected {
                return model.positive == 0.0 ? false : true
            } else if neutralButton.isSelected {
                return model.neutral == 0.0 ? false : true
            } else if negativeButton.isSelected {
                return model.negative == 0.0 ? false : true
            } else {
                return (model.positive == 0.0 && model.neutral == 0.0 && model.negative == 0.0) ? false : true
            }
        }
        filteredTags.sort { tag1, tag2 in
            if positiveButton.isSelected {
                return tag1.positive > tag2.positive
            } else if neutralButton.isSelected {
                return tag1.neutral > tag2.neutral
            } else if negativeButton.isSelected {
                return tag1.negative > tag2.negative
            } else {
                return tag1.total > tag2.total
            }
        }
        return filteredTags
    }
    
    private func setSentimentButtonText()
    {
        tagsTitleLabel.text = "Tags"
        tagsTitleLabel.adjustsFontSizeToFitWidth = true
        
        let placeHolderText = "Search Tags"
        searchTextField.attributedPlaceholder = NSAttributedString(string: placeHolderText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        seeMoreTagsButton.setTitle("See More Tags", for: .normal)
        positiveButton.setTitle("Positive", for: .normal)
        neutralButton.setTitle("Neutral", for: .normal)
        negativeButton.setTitle("Negative", for: .normal)
        
        [positiveButton, neutralButton, negativeButton].forEach { button in
            button.titleLabel?.minimumScaleFactor = 0.7
            button.titleLabel?.numberOfLines = 1
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.lineBreakMode = .byClipping
        }
    }
    
    private func calculateGraphHeight(tagsCount: Int) -> Int
    {
        let barHeight = 40
        return (tagsCount + 1) * barHeight
    }
    
}

extension TagsTableViewCell
{
    // To display total label
    private var stackLabels: HIStackLabels {
        let labels = HIStackLabels()
        labels.enabled = true
        labels.align = "right"
        labels.x = 1000
        let function = HIFunction(jsFunction: "function() { if ((this.total - Math.floor(this.total)) == 0) { return Highcharts.numberFormat(this.total, 0) + '%' ; } else { return Highcharts.numberFormat(this.total, 2) + '%' ; } }")
        labels.formatter = function
        
        let stackLabelStyle = HICSSObject()
        stackLabelStyle.color = appTextColor
        stackLabelStyle.fontFamily = fontFamily
        stackLabelStyle.fontSize = "14px"
        labels.style = stackLabelStyle
        return labels
    }
    
    // Y Axis for chart
    private var yAxix: HIYAxis {
        let yaxis = HIYAxis()
        yaxis.min = 0
        yaxis.maxPadding = 0.5
        yaxis.showLastLabel = false
        yaxis.title = HITitle()
        yaxis.title.text = ""
        // opposite to use to show bottom or top.
        yaxis.opposite = true
        yaxis.reversed = false
        yaxis.tickAmount = 4
        yaxis.labels = HILabels()
        yaxis.labels.style = HICSSObject()
        yaxis.labels.style.color = "rgb(96, 96, 96)"
        yaxis.labels.style.fontFamily = fontFamily
        yaxis.labels.style.fontSize = "12px"
        return yaxis
    }
    
   // X Axis for chart
    private func xAxis(_ model: [TagsViewModel]) -> HIXAxis
    {
        let xaxis = HIXAxis()
        xaxis.labels = HILabels()
        xaxis.labels.style = HICSSObject()
        xaxis.labels.useHTML = true
        xaxis.labels.allowOverlap = true
        xaxis.labels.style.textOverflow = "allow"
        // MARK: Truncation of Labels Issue
        /// for the label to be multiline we are adding below line which is not accessible here
        //xaxis.labels.style.wordBreak = "break-all"
        xaxis.labels.style.color = appTextColor
        xaxis.labels.style.fontFamily = fontFamily
        xaxis.labels.style.fontSize = "14px"
        xaxis.labels.align = "left"
        xaxis.labels.reserveSpace = true
        xaxis.categories = model.map {$0.label}
        xaxis.opposite = false
        return xaxis
    }
    
    // This emptyXAxix is used to remove last vertical line.
    // Means last tick which was crosing % values on right side.
    private var emptyXAxix: HIXAxis {
        let secondAxis = HIXAxis()
        secondAxis.opposite = true
        secondAxis.type = "category"
        secondAxis.lineWidth = 1
        secondAxis.lineColor = HIColor(uiColor: .white)
        secondAxis.tickWidth = 0
        return secondAxis
    }
    
    // function gets called once when the graph getting prepared and sets initially
    private func prepareGraph()
    {
        chartView = HIChartView(frame: graphContainerView.bounds)
        let options = HIOptions()
        
        let exporting = HIExporting()
        exporting.enabled = false
        options.exporting = exporting
        
        let chart = HIChart()
        chart.scrollablePlotArea = HIScrollablePlotArea()
        let expectedHeight = calculateGraphHeight(tagsCount: tagViewModel.count)
        chart.scrollablePlotArea.minHeight = NSNumber(value: expectedHeight)
        chart.scrollablePlotArea.scrollPositionY = 0
        
        chart.type = "bar"
        options.chart = chart
        
        let title = HITitle()
        title.text = ""
        options.title = title
        
        let xaxis = xAxis(tagViewModel)
        options.xAxis = [xaxis, emptyXAxix]
        
        let yaxis = yAxix
        yaxis.stackLabels = stackLabels
        options.yAxis = [yaxis]
        
        let tooltip = HITooltip()
        // To show/hide tooltip / annotation
        tooltip.enabled = false
        options.tooltip = tooltip
        
        let plotOptions = HIPlotOptions()
        plotOptions.series = HISeries()
        plotOptions.series.stacking = "normal"
        options.plotOptions = plotOptions
        
        let credits = HICredits()
        credits.enabled = false
        options.credits = credits
        
        options.series = prepareGraphSeriesFor(data: tagViewModel)
        chartView.plugins = ["no-data-to-display"]
        
        let lang = HILang()
        lang.noData = "No Data to Display"
        chartView.lang = lang
        
        options.plotOptions = plotOptions
        
        chartView.options = options
        
        graphContainerView.addSubview(chartView)
        chartView.bindFrameToSuperviewBounds()
    }
    
    // function in which bars added with 3 different colors[positive, neutral, negative] for the respective type of data in series:-
    private func prepareGraphSeriesFor(data: [TagsViewModel]) -> [HISeries]
    {
        let states = HIStates()
        states.inactive = HIInactive()
        states.inactive.enabled = false
        
        let positive = HIBar()
        positive.showInLegend = false
        positive.name = "Positive"
        positive.data = data.map {$0.positive}
        positive.color = HIColor(rgb: 25, green: 139, blue: 103)
        positive.pointWidth = 20
        positive.states = states
        
        let neutral = HIBar()
        neutral.showInLegend = false
        neutral.name = "Neutral"
        neutral.data = data.map {$0.neutral}
        neutral.color = HIColor(rgb: 96, green: 96, blue: 96)
        neutral.pointWidth = 20
        neutral.states = states
        
        let negative = HIBar()
        negative.showInLegend = false
        negative.name = "Negative"
        negative.data = data.map {$0.negative}
        negative.color = HIColor(rgb: 212, green: 56, blue: 49)
        negative.pointWidth = 20
        negative.states = states
        
        var series = [HISeries]()
        
        if positiveButton.isSelected {
            series = [positive]
        } else if neutralButton.isSelected {
            series = [neutral]
        } else if negativeButton.isSelected {
            series = [negative]
        } else {
            series = [positive, neutral, negative]
        }
        return series
    }
    
    // function getting called every time when the searching or filtering with buttons starts
    private func updateGraphWith(data: [TagsViewModel])
    {
        let filteredTags = filterAndSortTags(data)
        let xaxis = xAxis(filteredTags)
        chartView.options.xAxis = [xaxis, emptyXAxix]
        
        let yaxis = yAxix
        yaxis.stackLabels = stackLabels
        chartView.options.yAxis = [yaxis]
        
        chartView.options.series = prepareGraphSeriesFor(data: filteredTags)
        
        let expectedHeight = calculateGraphHeight(tagsCount: filteredTags.count)
        chartView.options.chart.scrollablePlotArea.minHeight = NSNumber(value: expectedHeight)
        chartView.options.chart.scrollablePlotArea.scrollPositionY = 0
    }
    
    private func updateGraphForSentiment()
    {
        if tagViewModel.isEmpty {
            tagViewModel = hideSeeMoreTagsButton ? allTags : Array(allTags.prefix(initialTagsDisplayCount))
        }
        
        let text = (searchTextField.text ?? "").trimSpaces()
        if text.isEmpty {
            updateGraphWith(data: tagViewModel)
        } else {
            updateGraphWithSearchText(text)
        }
    }
    
    private func updateGraphWithSearchText(_ text: String)
    {
        let filteredItems = allTags.filter { model in
            return model.label.lowercased().localizedCaseInsensitiveContains(text)
        }
        updateGraphWith(data: filteredItems)
    }
    
    
    private func selectedGraphLabel(_ label: String)
    {
        var filterModel = [FilterModel]()
        if positiveButton.isSelected {
            filterModel.append(FilterModel(name: "Positive", id: FilterIdEnum.sentimentTagId.rawValue, type: .sentiment, value: Sentiment.positive.rawValue, tagType: nil))
        } else if neutralButton.isSelected {
            filterModel.append(FilterModel(name: "Neutral", id: FilterIdEnum.sentimentTagId.rawValue, type: .sentiment, value: Sentiment.neutral.rawValue, tagType: nil))
        } else if negativeButton.isSelected {
            filterModel.append(FilterModel(name: "Negative", id: FilterIdEnum.sentimentTagId.rawValue, type: .sentiment, value: Sentiment.negative.rawValue, tagType: nil))
        }
        
        if let selectedTag = (allTags.filter {$0.label == label}).first {
            let filterValueModel = FilterModel(name: selectedTag.label, id: selectedTag.id, type: .tag, value: nil, tagType: selectedTag.tagType)
            filterModel.append(filterValueModel)
        }
    }
    
}

extension TagsTableViewCell
{
    @IBAction func negativeButtonClicked(_ sender: UIButton)
    {
        sender.isSelected.toggle()
        neutralButton.isSelected = false
        positiveButton.isSelected = false
        updateGraphForSentiment()
    }
    
    @IBAction func neutralButtonClicked(_ sender: UIButton)
    {
        sender.isSelected.toggle()
        positiveButton.isSelected = false
        negativeButton.isSelected = false
        updateGraphForSentiment()
    }
    
    @IBAction func positiveButtonClicked(_ sender: UIButton)
    {
        sender.isSelected.toggle()
        neutralButton.isSelected = false
        negativeButton.isSelected = false
        updateGraphForSentiment()
    }
    
    @IBAction func searchButtonAction(_ sender: Any)
    {
        searchTextField.becomeFirstResponder()
    }
    
    @IBAction func seeMoreTagsButtonClicked(_ sender: Any)
    {
        delegate?.seeMoreTagsAction()
        //tagViewModel = allTags
        hideSeeMoreTagsButton = true
        //updateGraphWith(data: tagViewModel)
        
        let text = (searchTextField.text ?? "").trimSpaces()
        if text.isEmpty {
            tagViewModel = allTags
            updateGraphWith(data: tagViewModel)
        } else {
            updateGraphWithSearchText(text)
        }
    }
}

extension TagsTableViewCell: UITextFieldDelegate
{
    @objc func textFieldDidChange(_ textField: UITextField)
    {
        let text = (textField.text ?? "").trimSpaces()
        if text.isEmpty {
            if hideSeeMoreTagsButton {
                tagViewModel = allTags
            }
            updateGraphWith(data: tagViewModel)
        } else {
            updateGraphWithSearchText(text)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        return true
    }
}

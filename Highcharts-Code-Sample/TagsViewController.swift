//
//  ViewController.swift
//  Highcharts-Code-Sample
//
//  Created by Shekhar Shelke on 31/10/22.
//

import UIKit
import Highcharts

class TagsViewController: UIViewController, TagsTableViewCellDelegate
{
    // Outlets
    @IBOutlet weak var tableView: UITableView!
    var analyticsDataViewModel: AnalyticsDataViewModel?
    var filterViewModel = FilterViewModel()
    var service: TagsService = TagsService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAnalyticsData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func getAnalyticsData()
    {
        let tagsData = service.fetchTagsData()
        if let analyticsData = AnalyticsDataModel(json: tagsData) {
            let anayticsDataViewModel =  AnalyticsDataViewModel(analyticsData: analyticsData)
            self.analyticsDataViewModel = anayticsDataViewModel
        }
        tableView.reloadData()

        // Setting isNewData = false to unselect sentiment button when new data fetched from server.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.analyticsDataViewModel?.updateIsNewDataStatus(false)
        }
    }
}

extension TagsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagsTableViewCell") as! TagsTableViewCell
        if let tagViewModel = analyticsDataViewModel?.tags {
            cell.configureCell(tagViewModel, isExpanded: analyticsDataViewModel!.isTagsExpanded, isNewData: analyticsDataViewModel!.isNewData)
            cell.delegate = self
        }
        return cell
    }
}

extension TagsViewController
{
    func seeMoreTagsAction()
    {
        if var analyticsData = analyticsDataViewModel {
            analyticsData.updateTagsExpandedStatus(!analyticsData.isTagsExpanded)
            analyticsDataViewModel = analyticsData
        }
    }
}


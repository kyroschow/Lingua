//
//  EnglishAnswersController.swift
//  iOS
//
//  Created by Cluster 5 on 7/31/18.
//  Copyright © 2018 MBIENTLAB, INC. All rights reserved.
//

import UIKit
import MetaWear

class ChineseAnswersController: UITableViewController {
    @IBOutlet var answersTableView: UITableView!
    @IBOutlet weak var promptText: UILabel!
    @IBOutlet weak var proceedButton: UIButton!
    
    private var storyManager: StoryManager!
    var device: MBLMetaWear? = nil
    private var answers: [String] = []
    private var hasChosenAnswers: [Bool] = []
    private var answerSelected: IndexPath? = nil
    
    override func viewDidLoad() {
        //background
        let background = UIImageView(frame: self.answersTableView.bounds)
        background.image = #imageLiteral(resourceName: "map2")
        self.answersTableView.backgroundView = background
        
        //StoryManager as data source
        self.storyManager = StoryManager(promptsAndResponses: Stories.CHINESE_MALL_1, device: device!)
        self.storyManager.subscribeToDeviceUpdates()
        self.loadNext()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return the number of answers possible
        if (!self.storyManager.hasNext()) {
            self.proceedButton.setTitle("Done", for: .normal)
        } else if (answers.count == 0) {
            self.proceedButton.setTitle("Next", for: .normal)
        } else {
            self.proceedButton.setTitle("Submit", for: .normal)
        }
        return answers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //TODO: configure the cell and load information
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChineseAnswerCell", for: indexPath) as! ChineseAnswerCell
        cell.responseTitle.text = "Response \(indexPath.row + 1)"
        cell.responseText.text = answers[indexPath.row]
        cell.contentView.backgroundColor = self.hasChosenAnswers[indexPath.row] ? UIColor(red: 0.95686, green: 0.78039, blue: 0.76471, alpha: 1.0) : UIColor(red: 0.99608, green: 0.92549, blue: 0.58039, alpha: 1.0)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.answerSelected = indexPath
        self.storyManager.playCurrentAnswer(indexPath.row)
    }
    
    private func loadNext() {
        self.answerSelected = nil
        if storyManager.hasNext() {
            let (prompt, answers) = storyManager.next()
            self.promptText.text = prompt
            self.answers = answers
            self.hasChosenAnswers = Array(repeating: false, count: answers.count)
            self.answersTableView.reloadData()
            self.storyManager.playCurrentPrompt()
        }
    }
    
    @IBAction func tryProceed(_ sender: UIButton) {
        if (!storyManager.hasNext()) {
            self.navigationController?.popViewController(animated: true)
        } else if (answers.count == 0) {
            self.loadNext()
        } else if let chosenRow = self.answerSelected?.row{
            if (self.storyManager.checkAnswer(answerIndex: chosenRow)) {
                self.loadNext()
            } else {
                self.hasChosenAnswers[chosenRow] = true
                self.answersTableView.reloadData()
            }
        }
        self.answerSelected = nil
    }
    
    @IBAction func onPromptReplayClicked(_ sender: UIButton) {
        self.storyManager.playCurrentPrompt()
    }
}

class ChineseAnswerCell: UITableViewCell {
    @IBOutlet weak var responseTitle: UILabel!
    @IBOutlet weak var responseText: UILabel!
}

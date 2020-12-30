//
//  ReportViewController.swift
//  Haystack
//
//  Created by Frezghi Noel on 8/1/2020.
//  Copyright © 2020 Haystack. All rights reserved.
//

import UIKit
import Firebase

var report: String!

class ReportViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var viewTranslation = CGPoint(x: 0, y: 0)
    var panGestureRecognizer: UIPanGestureRecognizer!
    var dismissButton: UIButton!
    var reportTitle: UILabel!
    var infoLabel: UILabel!
    var submitButton: UIButton!
    
    var burnerCell: UITableViewCell = UITableViewCell()
    var firstCell: UITableViewCell = UITableViewCell()
    var secondCell: UITableViewCell = UITableViewCell()
    var thirdCell: UITableViewCell = UITableViewCell()
    var fourthCell: UITableViewCell = UITableViewCell()
    var fifthCell: UITableViewCell = UITableViewCell()
    var sixthCell: UITableViewCell = UITableViewCell()
    
    var reportTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleDismiss))
        self.panGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(self.panGestureRecognizer)
        
        dismissButton = UIButton()
        let dismissButtonImage = UIImage(named: "dismissblack")
        dismissButton.setImage(dismissButtonImage, for: .normal)
        dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dismissButton)
        
        reportTitle = UILabel()
        reportTitle.font = UIFont.init(name: "AvenirNext-DemiBold", size: 20)
        reportTitle.text = "Choose a reason for reporting"
        reportTitle.textColor = .black
        reportTitle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(reportTitle)
        
        reportTableView = UITableView()
        reportTableView.separatorInset = .zero
        reportTableView.delegate = self
        reportTableView.dataSource = self
        reportTableView.isScrollEnabled = false
        reportTableView.alwaysBounceVertical = false
        reportTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(reportTableView)
        
        burnerCell.isUserInteractionEnabled = false
        burnerCell.backgroundColor = .white
        burnerCell.selectionStyle = .none
        
        firstCell.textLabel?.text = "Prohibited Item"
        firstCell.backgroundColor = .white
        firstCell.selectionStyle = .none
        firstCell.textLabel?.font = UIFont.init(name: "AvenirNext-Medium", size: 17)
        
        secondCell.textLabel?.text = "Counterfeit Item"
        secondCell.backgroundColor = .white
        secondCell.selectionStyle = .none
        secondCell.textLabel?.font = UIFont.init(name: "AvenirNext-Medium", size: 17)
        
        thirdCell.textLabel?.text = "Stolen Item"
        thirdCell.backgroundColor = .white
        thirdCell.selectionStyle = .none
        thirdCell.textLabel?.font = UIFont.init(name: "AvenirNext-Medium", size: 17)
        
        fourthCell.textLabel?.text = "Objectionable Content"
        fourthCell.backgroundColor = .white
        fourthCell.selectionStyle = .none
        fourthCell.textLabel?.font = UIFont.init(name: "AvenirNext-Medium", size: 17)
        
        fifthCell.textLabel?.text = "Advertising/Soliciting"
        fifthCell.backgroundColor = .white
        fifthCell.selectionStyle = .none
        fifthCell.textLabel?.font = UIFont.init(name: "AvenirNext-Medium", size: 17)
        
        sixthCell.textLabel?.text = "Other"
        sixthCell.backgroundColor = .white
        sixthCell.selectionStyle = .none
        sixthCell.textLabel?.font = UIFont.init(name: "AvenirNext-Medium", size: 17)
        
        infoLabel = UILabel()
        infoLabel.font = UIFont.init(name: "AvenirNext-DemiBold", size: 10)
        infoLabel.text = "Reported listings are reviewed within 24 hours. Inappropriate listings will be removed and the seller will be ejected."
        infoLabel.textAlignment = .center
        infoLabel.textColor = .black
        infoLabel.lineBreakMode = .byWordWrapping
        infoLabel.numberOfLines = 2
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(infoLabel)
        
        submitButton = UIButton()
        submitButton.setTitle("Submit", for: .normal)
        submitButton.isUserInteractionEnabled = false
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        submitButton.titleLabel?.font = UIFont.init(name: "AvenirNext-DemiBold", size: 23)
        submitButton.backgroundColor = .lightGray
        submitButton.layer.cornerRadius = 25
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(submitButton)

        
        setUpConstraints()
        
    }
    
    func setUpConstraints() {
        
        NSLayoutConstraint.activate([dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15), dismissButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25)])
        
        NSLayoutConstraint.activate([reportTitle.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor), reportTitle.topAnchor.constraint(equalTo: dismissButton.bottomAnchor, constant: 50)])
        
        NSLayoutConstraint.activate([reportTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor), reportTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor), reportTableView.topAnchor.constraint(equalTo: reportTitle.bottomAnchor), reportTableView.bottomAnchor.constraint(equalTo: reportTableView.topAnchor, constant: 360)])
        
        NSLayoutConstraint.activate([infoLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: -150),infoLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 150), infoLabel.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -25)])
        
        NSLayoutConstraint.activate([submitButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: -150), submitButton.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: -50), submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20), submitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 150)])
    }
    
    @objc func handleDismiss(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:

            viewTranslation = sender.translation(in: view)
            UIView.animate(withDuration: 0.0, delay: 0, options: .beginFromCurrentState, animations: {
                if self.viewTranslation.y >= 0.0 {
                    self.view.transform = CGAffineTransform(translationX: 0, y: self.viewTranslation.y)
                }
            })
        case .ended:
            if viewTranslation.y < 100 {
                UIView.animate(withDuration: 0.0, delay: 0, options: .beginFromCurrentState, animations: {
                    self.view.transform = .identity
                })
            } else {
                dismiss(animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
    @objc func dismissButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc func submitButtonTapped() {
        Analytics.logEvent("report_submited", parameters: ["report": report])
        NetworkManager.createReport()
        dismiss(animated: true)
    }


}

extension ReportViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        reportTableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        reportTableView.cellForRow(at: indexPath)?.textLabel?.font = UIFont.init(name: "AvenirNext-DemiBold", size: 17.5)
        submitButton.backgroundColor = UIColor(red: 155.0/255.0, green: 085.0/255.0, blue: 160.0/255.0, alpha: 1.0)
        submitButton.isUserInteractionEnabled = true
        report = reportTableView.cellForRow(at: indexPath)?.textLabel?.text
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        reportTableView.cellForRow(at: indexPath)?.accessoryType = .none
        reportTableView.cellForRow(at: indexPath)?.textLabel?.font = UIFont.init(name: "AvenirNext-Medium", size: 17.5)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}

extension ReportViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch(indexPath.section) {
        case 0:
            switch(indexPath.row) {
            case 0: return burnerCell
            case 1: return firstCell
            case 2: return secondCell
            case 3: return thirdCell
            case 4: return fourthCell
            case 5: return fifthCell
            case 6: return sixthCell
            default: fatalError("Unknown row in section 0")
            }
        default: fatalError("Unknown section")
        
        }

    }
    
}

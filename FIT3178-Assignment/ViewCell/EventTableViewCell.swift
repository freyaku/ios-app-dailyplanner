//
//  EventTableViewCell.swift
//  FIT3178-Assignment
//
//  Created by Zhi Ning Ku on 27/4/2023.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var eventLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

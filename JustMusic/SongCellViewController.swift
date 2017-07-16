//
//  SongCellViewTableViewCell.swift
//  JustMusic
//
//  Created by Shekar on 4/28/17.
//  Copyright © 2017 Shekar. All rights reserved.
//

import UIKit

class SongCellViewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

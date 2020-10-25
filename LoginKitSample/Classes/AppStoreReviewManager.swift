//
//  AppStoreReviewManager.swift
//  LoginKitSample
//
//  Created by Frezghi Noel on 9/24/20.
//  Copyright © 2020 Snap Inc. All rights reserved.
//

import Foundation
import StoreKit

enum AppStoreReviewManager {
  static func requestReviewIfAppropriate() {
    SKStoreReviewController.requestReview()
  }
}

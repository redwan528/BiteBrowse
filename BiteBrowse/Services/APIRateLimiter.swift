//
//  APIRateLimiter.swift
//  BiteBrowse
//
//  Created by Redwan Khan on 4/19/24.
//

import Foundation
import Combine

class APIRateLimiter {
    private var cancellables: Set<AnyCancellable> = []
    private let interval: TimeInterval
    private let apiQueue = DispatchQueue(label: "api-rate-limiter-queue")
    private var lastRequestDate: Date?

    init(interval: TimeInterval) {
        self.interval = interval
    }

    func perform(_ action: @escaping () -> Void) {
        apiQueue.async {
            let now = Date()
            let timeSinceLastRequest = now.timeIntervalSince(self.lastRequestDate ?? .distantPast)

            if timeSinceLastRequest < self.interval {
                let delay = self.interval - timeSinceLastRequest
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    self.lastRequestDate = Date()
                    action()
                }
            } else {
                DispatchQueue.main.async {
                    self.lastRequestDate = Date()
                    action()
                }
            }
        }
    }
}



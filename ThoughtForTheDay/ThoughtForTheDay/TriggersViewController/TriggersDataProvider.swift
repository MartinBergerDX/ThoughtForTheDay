//
//  TriggersDataProvider.swift
//  ThoughtForTheDay
//
//  Created by Martin on 7/15/18.
//  Copyright © 2018 heavydebugging. All rights reserved.
//

import Foundation
import Services

class TriggersDataProvider {
    fileprivate var validEvents: [QuoteEvent] = []
    fileprivate var cancelledEvents: [QuoteEvent] = []
    
    func load() {
        self.validEvents = QuoteEventDao().findAll()
    }
    
    func cancelled() -> Bool {
        return self.cancelledEvents.count > 0
    }
    
    func cancel() {
        let dao: QuoteEventDao = QuoteEventDao()
        let _ = dao.deleteEntities(self.cancelledEvents, save: true)
        self.cancelledEvents.removeAll()
    }
    
    func appendCancelled(_ quoteEvent: QuoteEvent) {
        self.cancelledEvents.append(quoteEvent)
    }
    
    func setToCancel(_ index: Int) {
        let quoteEvent: QuoteEvent = self.validEvents.remove(at: index)
        self.appendCancelled(quoteEvent)
    }
    
    func count() -> Int {
        return self.validEvents.count
    }
    
    func object(at index: Int) -> QuoteEvent {
        return self.validEvents[index]
    }
    
    func updateChanges() {
        if (self.cancelled()) {
            self.cancel()
            ServiceRegistry.shared.notification.reschedule()
        }
    }
}

import Foundation

@Observable class FeedViewModel {
    var releases = [ReleaseHolder]()
    var pastReleases = [ReleaseHolder]()
    var lastUpdatedReleases: Date? = nil
    var gotReleases = false
    var gotPastReleases = false
    var upvotes = [String]()
    var downvotes = [String]()
    var viewId = UUID()

    func getReleases() {
        DispatchQueue.main.async {
            self.lastUpdatedReleases = Date()
        }
        
        DispatchQueue.global(qos: .background).async {
            ReleaseService().GetNewReleases { data in
                let calendar = Calendar.current
                let formatter = DateFormatter()
                
                formatter.dateFormat = "EEEE, MMMM d"
                
                let groupedReleases = Dictionary(grouping: data) { release -> String in
                    let date = release.releaseTime.dateValue()
                    return formatter.string(from: date)
                }
                
                var releaseHolders = groupedReleases.map { (dateString, releases) in
                    let firstReleaseDate = releases.first?.releaseTime.dateValue() ?? Date()
                    
                    let adjustedDateString: String
                    if calendar.isDateInToday(firstReleaseDate) {
                        adjustedDateString = "Today"
                    } else if calendar.isDateInTomorrow(firstReleaseDate) {
                        adjustedDateString = "Tomorrow"
                    } else {
                        adjustedDateString = formatter.string(from: firstReleaseDate)
                    }
                    
                    let sortedReleases = releases.sorted {
                        $0.releaseTime.dateValue() < $1.releaseTime.dateValue()
                    }
                    
                    return ReleaseHolder(dateString: adjustedDateString, releases: sortedReleases)
                }
                
                releaseHolders.sort {
                    let date1 = $0.releases.first?.releaseTime.dateValue() ?? Date.distantFuture
                    let date2 = $1.releases.first?.releaseTime.dateValue() ?? Date.distantFuture
                    return date1 < date2
                }
                
                if !areReleasesEqual(self.releases, releaseHolders) {
                    DispatchQueue.main.async {
                        self.releases = releaseHolders
                        self.gotReleases = true
                        self.viewId = UUID()
                    }
                }
            }
        }
    }
    
    func getOldReleases() {
        if !self.pastReleases.isEmpty {
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            ReleaseService().GetOldReleases { data in
                let calendar = Calendar.current
                let formatter = DateFormatter()
                
                formatter.dateFormat = "EEEE, MMMM d"
                
                let groupedReleases = Dictionary(grouping: data) { release -> String in
                    let date = release.releaseTime.dateValue()
                    return formatter.string(from: date)
                }
                
                var releaseHolders = groupedReleases.map { (dateString, releases) in
                    let firstReleaseDate = releases.first?.releaseTime.dateValue() ?? Date()
                    
                    let adjustedDateString: String
                    if calendar.isDateInYesterday(firstReleaseDate) {
                        adjustedDateString = "Yersterday"
                    } else {
                        adjustedDateString = formatter.string(from: firstReleaseDate)
                    }
                    
                    let sortedReleases = releases.sorted {
                        $0.releaseTime.dateValue() < $1.releaseTime.dateValue()
                    }
                    
                    return ReleaseHolder(dateString: adjustedDateString, releases: sortedReleases)
                }
                
                releaseHolders.sort {
                    let date1 = $0.releases.first?.releaseTime.dateValue() ?? Date.distantFuture
                    let date2 = $1.releases.first?.releaseTime.dateValue() ?? Date.distantFuture
                    return date1 > date2
                }
                
                DispatchQueue.main.async {
                    self.pastReleases = releaseHolders
                    self.gotPastReleases = true
                }
            }
        }
    }
    func upVote(releaseId: String?) {
        if let releaseId, !releaseId.isEmpty {
            ReleaseService().upVote(releaseId: releaseId)
            ReleaseService().removeDownVote(releaseId: releaseId)
        }
    }
    func removeUpVote(releaseId: String?) {
        if let releaseId, !releaseId.isEmpty {
            ReleaseService().removeUpVote(releaseId: releaseId)
        }
    }
    func downVote(releaseId: String?) {
        if let releaseId, !releaseId.isEmpty {
            ReleaseService().downVote(releaseId: releaseId)
            ReleaseService().removeUpVote(releaseId: releaseId)
        }
    }
    func removeDownVote(releaseId: String?) {
        if let releaseId, !releaseId.isEmpty {
            ReleaseService().removeDownVote(releaseId: releaseId)
        }
    }
}

func isAtLeastOneMinuteOld(from date: Date) -> Bool {
    let oneMinuteAgo = Date().addingTimeInterval(-60)
    return date <= oneMinuteAgo
}

func isWithin15Sec(from date: Date) -> Bool {
    let fifteenSecAgo = Date().addingTimeInterval(-15)
    return date > fifteenSecAgo
}

func isWithinXsec(from date: Date, sec: Int) -> Bool {
    let xBack = Date().addingTimeInterval(-Double(sec))
    return date > xBack
}

func isWithinXmin(from date: Date, min: Int) -> Bool {
    let xBack = Date().addingTimeInterval(-Double(60 * min))
    return date > xBack
}

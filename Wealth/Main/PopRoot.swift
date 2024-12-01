import Foundation
import SwiftUI

class PopToRoot: ObservableObject {
    @Published var tab: Int = 1
    @Published var tap: Int = 0
    
    @Published var showAlert: Bool = false
    @Published var alertReason: String = ""
    @Published var alertImage: String = ""
    var alertID: String = ""
    
    @Published var snapImage: UIImage?
    @Published var focusLocation: (CGFloat, CGFloat)?
    
    var botInStock = true
    var lastCheckInStock: Date? = nil
    var joinedWaitlist = false
    var randomVal = ""
    @Published var unSeenProfileCheckouts = 0
    @Published var soldQuantities: SoldQuantities? = nil
    
    @Published var userResiLogin: String? = nil
    @Published var userResiPassword: String? = nil
    @Published var resisData: BandwidthDetails? = nil
    
    func presentAlert(image: String, text: String) {
        DispatchQueue.main.async {
            self.alertReason = text
            self.alertImage = image
            withAnimation(.easeInOut(duration: 0.2)){
                self.showAlert = true
            }
        }
    }
}

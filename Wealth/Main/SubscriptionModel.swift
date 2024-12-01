import StoreKit

enum PurchaseError: Error {
    case verificationFailed(Error) // Unverified purchase
    case transactionPending        // Pending approval
    case userCancelled             // User cancelled purchase
    case unknownState              // Unknown purchase state
    case generalError(Error)       // General purchase failure
}

@MainActor
class SubscriptionsManager: NSObject, ObservableObject {
    let productIDs: [String] = ["12345678"]
    @Published var products: [Product] = []
    var hasInfoAccess = false
    var infoWasSet = false
    var updates: Task<Void, Never>? = nil
    
    override init() {
        super.init()
        self.updates = observeTransactionUpdates()
    }
    
    deinit {
        updates?.cancel()
    }
    
    func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await _ in Transaction.updates {
                await self.updatePurchasedProducts()
            }
        }
    }
    
    func loadProducts() async {
        do {
            self.products = try await Product.products(for: productIDs)
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }
    
    func buyProduct(_ product: Product) async throws {
        do {
            let result = try await product.purchase()
            
            switch result {
            case let .success(.verified(transaction)):
                // Successful purchase
                await transaction.finish()
                await self.updatePurchasedProducts()
                
            case let .success(.unverified(_, error)):
                // Purchase succeeded but verification failed
                throw PurchaseError.verificationFailed(error)
                
            case .pending:
                // Transaction waiting on approval
                throw PurchaseError.transactionPending
                
            case .userCancelled:
                // User cancelled the purchase
                throw PurchaseError.userCancelled
                
            @unknown default:
                // Unknown state
                throw PurchaseError.unknownState
            }
        } catch {
            // General purchase error
            throw PurchaseError.generalError(error)
        }
    }
    
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            if transaction.revocationDate != nil {
                // Handle subscription cancellation
                self.hasInfoAccess = false
            } else if transaction.expirationDate != nil, transaction.expirationDate! < Date() {
                // Handle subscription expiration
                self.hasInfoAccess = false
            } else {
                // Subscription is active
                self.hasInfoAccess = true
            }
            self.infoWasSet = true
        }
    }
    
    func restorePurchases() async {
        for await result in Transaction.all {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            if productIDs.contains(transaction.productID) {
                self.hasInfoAccess = true
            }
        }
        
        self.infoWasSet = true
    }
}

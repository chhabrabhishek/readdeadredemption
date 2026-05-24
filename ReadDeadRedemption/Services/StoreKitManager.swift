import Foundation
import StoreKit

/// Manages in-app subscriptions and premium features
@Observable
final class StoreKitManager {
    static let shared = StoreKitManager()
    
    var products: [Product] = []
    var purchasedProductIDs: Set<String> = []
    var isPremium: Bool = false
    
    private let productIDs = [
        "com.readdeadredemption.pro.monthly",
        "com.readdeadredemption.pro.yearly",
        "com.readdeadredemption.pro.lifetime"
    ]
    
    private var updateListenerTask: Task<Void, Error>?
    
    private init() {
        updateListenerTask = listenForTransactions()
        Task { await loadProducts() }
        Task { await updatePurchasedProducts() }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Load Products
    
    func loadProducts() async {
        do {
            products = try await Product.products(for: productIDs)
                .sorted { $0.price < $1.price }
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    // MARK: - Purchase
    
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()
            return transaction
            
        case .userCancelled:
            return nil
            
        case .pending:
            return nil
            
        @unknown default:
            return nil
        }
    }
    
    // MARK: - Restore
    
    func restorePurchases() async {
        try? await AppStore.sync()
        await updatePurchasedProducts()
    }
    
    // MARK: - Transaction Listener
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updatePurchasedProducts()
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    // MARK: - Verification
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Update Purchased
    
    private func updatePurchasedProducts() async {
        var purchased: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                purchased.insert(transaction.productID)
            } catch {
                continue
            }
        }
        
        purchasedProductIDs = purchased
        isPremium = !purchased.isEmpty
    }
    
    // MARK: - Helpers
    
    var monthlyProduct: Product? {
        products.first { $0.id == "com.readdeadredemption.pro.monthly" }
    }
    
    var yearlyProduct: Product? {
        products.first { $0.id == "com.readdeadredemption.pro.yearly" }
    }
    
    var lifetimeProduct: Product? {
        products.first { $0.id == "com.readdeadredemption.pro.lifetime" }
    }
}

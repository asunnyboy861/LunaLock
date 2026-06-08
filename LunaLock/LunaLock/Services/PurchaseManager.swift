import Foundation
import Combine
import StoreKit

@MainActor
class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    @Published var isPro = false
    @Published var isLoading = false
    @Published var product: Product?

    private let proProductID = "com.zzoutuo.LunaLock.pro"
    private let isProKey = "lunalock.ispro"
    private var transactionListener: Task<Void, Never>?

    init() {
        isPro = UserDefaults.standard.bool(forKey: isProKey)
        transactionListener = listenForTransactions()
        Task { await loadProduct() }
    }

    deinit {
        transactionListener?.cancel()
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                if case .verified(let transaction) = result {
                    if transaction.productID == self.proProductID {
                        await MainActor.run {
                            self.isPro = true
                            UserDefaults.standard.set(true, forKey: self.isProKey)
                        }
                    }
                    await transaction.finish()
                }
            }
        }
    }

    func loadProduct() async {
        do {
            let products = try await Product.products(for: [proProductID])
            product = products.first
        } catch {}
    }

    func purchase() async -> Bool {
        guard let product = product else { return false }
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    isPro = true
                    UserDefaults.standard.set(true, forKey: isProKey)
                    await transaction.finish()
                    return true
                }
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {}
        return false
    }

    func restorePurchases() async {
        do {
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    if transaction.productID == proProductID {
                        isPro = true
                        UserDefaults.standard.set(true, forKey: isProKey)
                        await transaction.finish()
                    }
                }
            }
        } catch {}
    }
}

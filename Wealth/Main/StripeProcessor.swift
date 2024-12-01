import SwiftUI
import Stripe
import StripeApplePay
import PassKit

func createStripePaymentIntent(secretKey: String, amount: Int, currency: String, completion: @escaping (Result<Data, Error>) -> Void) {
    guard let url = URL(string: "https://api.stripe.com/v1/payment_intents") else {
        completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    let parameters: [String: String] = [
        "amount": String(amount),
        "currency": currency
    ]
    request.httpBody = parameters.map { "\($0.key)=\($0.value)" }
                                  .joined(separator: "&")
                                  .data(using: .utf8)
    
    let authValue = "Bearer \(secretKey)"
    request.addValue(authValue, forHTTPHeaderField: "Authorization")
    request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
            return
        }
        
        if let data = data {
            completion(.success(data))
        } else {
            completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
        }
    }
    
    task.resume()
}

struct ApplePayButtonView: UIViewControllerRepresentable {
    let merchantIdentifier: String
    let countryCode: String
    let currency: String
    let randomVal: String
    let amount: Double
    let businessName: String
    var completion: (Result<Void, Error>) -> Void
    
    func makeUIViewController(context: Context) -> CheckoutViewController {
        let controller = CheckoutViewController(
            merchantIdentifier: merchantIdentifier,
            countryCode: countryCode,
            currency: currency,
            randomVal: randomVal,
            amount: amount,
            businessName: businessName,
            completion: completion
        )
        controller.preferredContentSize = CGSize(width: UIScreen.main.bounds.width - 60, height: 55)
        return controller
    }

    func updateUIViewController(_ uiViewController: CheckoutViewController, context: Context) {}
}

class CheckoutViewController: UIViewController {
    private let merchantIdentifier: String
    private let countryCode: String
    private let currency: String
    private let randomVal: String
    private let amount: Double
    private let businessName: String
    private let completion: (Result<Void, Error>) -> Void

    private let applePayButton = PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: .automatic)

    init(
        merchantIdentifier: String,
        countryCode: String,
        currency: String,
        randomVal: String,
        amount: Double,
        businessName: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        self.merchantIdentifier = merchantIdentifier
        self.countryCode = countryCode
        self.currency = currency
        self.randomVal = randomVal
        self.amount = amount
        self.businessName = businessName
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(applePayButton)
        applePayButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            applePayButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            applePayButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            applePayButton.heightAnchor.constraint(equalToConstant: 55),
            applePayButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        applePayButton.isHidden = !StripeAPI.deviceSupportsApplePay()
        applePayButton.addTarget(self, action: #selector(handleApplePayButtonTapped), for: .touchUpInside)
    }

    @objc func handleApplePayButtonTapped() {
        let paymentRequest = StripeAPI.paymentRequest(
            withMerchantIdentifier: merchantIdentifier,
            country: countryCode,
            currency: currency
        )

        paymentRequest.paymentSummaryItems = [
            PKPaymentSummaryItem(label: businessName, amount: NSDecimalNumber(value: amount))
        ]

        if let applePayContext = STPApplePayContext(paymentRequest: paymentRequest, delegate: self) {
            applePayContext.presentApplePay()
        } else {
            print("Error: Apple Pay is not configured properly.")
        }
    }
}

extension CheckoutViewController: STPApplePayContextDelegate {
    func applePayContext(_ context: StripeApplePay.STPApplePayContext, didCompleteWith status: StripePayments.STPPaymentStatus, error: (any Error)?) {
        switch status {
        case .success:
            completion(.success(()))
        case .error:
            completion(.failure(error ?? NSError(domain: "com.example.payment", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])))
        case .userCancellation:
            completion(.failure(error ?? NSError(domain: "com.example.payment", code: -1, userInfo: [NSLocalizedDescriptionKey: "User cancelled payment"])))
        @unknown default:
            completion(.failure(error ?? NSError(domain: "com.example.payment", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])))
        }
    }

    func applePayContext(
        _ context: STPApplePayContext,
        didCreatePaymentMethod paymentMethod: STPPaymentMethod,
        paymentInformation: PKPayment,
        completion: @escaping STPIntentClientSecretCompletionBlock
    ) {
        let amountInCents = Int(round(amount * 100))
        
        createStripePaymentIntent(secretKey: randomVal, amount: amountInCents, currency: currency) { result in
            switch result {
            case .success(let data):
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let clientSecret = jsonObject["client_secret"] as? String {
                        completion(clientSecret, nil)
                    } else {
                        completion(nil, NSError(domain: "ParsingError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse client_secret"]))
                    }
                } catch {
                    completion(nil, error)
                }
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}

import Foundation
import Combine
import Alamofire

public final class MultipartRequestSubscription<S: Subscriber>: Subscription where S.Input == DataResponse<Data>, S.Failure == Error {
    private let apiClient: APIClient
    private let apiRequest: APIRequest
    private var uploadRequest: UploadRequest?
    private var uploadProgressObserver: ((Progress) -> Void)? = nil
    private var isRequestInProgress = false
    private var subscriber: S?

    init(subscriber: S,
         apiClient: APIClient,
         apiRequest: APIRequest,
         uploadProgressObserver: ((Progress) -> Void)? = nil) {
        self.subscriber = subscriber
        self.apiClient = apiClient
        self.apiRequest = apiRequest
        self.uploadProgressObserver = uploadProgressObserver
    }

    public func request(_ demand: Subscribers.Demand) {
        var headers = [String: String]()
        switch apiRequest.configureHeaders() {
        case .success(let configuredHeaders):
            headers = configuredHeaders
        case .failure(let responseError):
            subscriber?.receive(completion: .failure(responseError))
        }
        let requestInputMultipartData = apiRequest.multipartFormData ?? [String: URL]()
        isRequestInProgress = true
        apiClient.manager.upload(multipartFormData: { multipartFormData in
            for requestMultipartData in requestInputMultipartData {
                multipartFormData.append(requestMultipartData.value,
                                         withName: requestMultipartData.key)
            }
        }, to: apiRequest.configurePath(baseUrl: apiClient.baseURL),
           method: apiRequest.method,
           headers: headers) { [weak self] result in
            switch result {
            case .success(let uploadRequest, _, _):
                self?.uploadRequest = uploadRequest
                uploadRequest.uploadProgress(closure: { [weak self] progress in
                    self?.uploadProgressObserver?(progress)
                })
                uploadRequest.responseData(completionHandler: { dataResponse in
                    self?.isRequestInProgress = false
                    guard let error = dataResponse.error else {
                        _ = self?.subscriber?.receive(dataResponse)
                        return
                    }
                    self?.subscriber?.receive(completion: .failure(error))
                })
            case .failure(let encodingError):
                self?.isRequestInProgress = false
                self?.subscriber?.receive(completion: .failure(encodingError))
            }
        }
    }

    public func cancel() {
        if isRequestInProgress {
            uploadRequest?.cancel()
        }
        uploadRequest = nil
        subscriber = nil
    }
}

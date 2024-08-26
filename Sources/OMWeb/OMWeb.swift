// The Swift Programming Language
// https://docs.swift.org/swift-book
import WebKit
import Combine

public class OMWebManager: NSObject {
    public init(configuration: WKWebViewConfiguration = .init()) {
        self.configuration = configuration
        self.view = WKInputAccessoryWebView(frame: .zero, configuration: configuration)
        super.init()
        setup()
    }
    
    public let view: WKInputAccessoryWebView
    
    public let state = CurrentValueSubject<OMWebState, Never>(.init())

    private let configuration: WKWebViewConfiguration
    
    var cancellables = Set<AnyCancellable>()
    
    var backForwardListObserve: NSKeyValueObservation?
    func setup() {
        view.underPageBackgroundColor = .clear
    }
    
    
    public func refresh() {
        view.reload()
    }
     
    public func cancel() {
        view.stopLoading()
    }
    
    public func forward() {
        if view.canGoForward {
            view.goForward()
        }
    }
    
    public func back() {
        if view.canGoBack {
            view.goBack()
        }
    }
    
    public func go(url: URLRequest) {
        guard view.url != url.url else { return }
        view.load(url)
    }
    
    public func go(string: String) {
        // search
        var url: URL?
        
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))
            if let match = matches.first, let range = Range(match.range, in: string) {
                var urlString = String(string[range])
                if !urlString.starts(with: "http") {
                    urlString = "https://" + urlString
                }
                url =  URL(string: urlString)
            } else if let searchURL = URL(string:"https://www.google.com/search?q=\(string)") {
                url = searchURL
            }
        } catch {
            
        }

        if let url, view.url != url {
            let request = URLRequest(url: url)
            view.load(request)
        }
        
    }
}


public struct OMWebItem: Identifiable, Equatable {
    public init(title: String?, url: URL) {
        self.title = title
        self.url = url
    }
    public let id = UUID()
    public  let title: String?
    public  let url: URL
}
public struct OMWebState:  Equatable {
    public init() {}
    
    public var url: URL? = nil
    public var title: String? = nil
    public var isLoading: Bool = false
    public var loadingProgress: Double? = nil
    
    public var canGoBack: Bool = false
    public var canGoForward: Bool = false
    
    // inputIsURL: Bool = false
    
    public var backList: [OMWebItem] = []
    public var forwardList: [OMWebItem] = []
    
}




import SwiftUI
#if os(iOS)
public struct OMWebView: UIViewRepresentable {
    public init(view: WKWebView) {
        self.view = view
    }

    public let view: WKWebView
    public func makeUIView(context: Context) -> some UIView {
        view
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {}
}

#endif

#if os(macOS)

import AppKit
struct OMWebView: NSViewRepresentable {
    let view: WKWebView
    func makeNSView(context: Context) -> some NSView {
        view
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {}
}
#endif



public struct OMURLView: View {
    @State var isEditing = false
    @State var isLoading = false
    @FocusState var isFocused: Bool
    @State var text = ""
    
    public var body: some View {
        ZStack {
       
            HStack {
                // menu
                // title
                Button(action: {  }) {
                    Text("google.com")
                        .tint(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    
                }
                
                // refresh or cancel
                if isLoading {
                    Button(action: {}) {
                        Image(systemName: "xmark")
                            .padding(6)
                            .background {
                                Rectangle()
                                    .fill(.secondary.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                    }
                } else {
                    Button(action: {}) {
                        Image(systemName: "arrow.counterclockwise")
//                            .tint(.primary)
                            .padding(6)
                            .background {
                                Rectangle()
                                    .fill(.secondary.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                    }
                }
                
                Button(action: {}) {
                    Image(systemName: "ellipsis.circle")
                        .padding(6)
                        .background {
                            Rectangle()
                                .fill(.secondary.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                }
               
                    
              
            }
//            .opacity(!isFocused ? 1 : 0)
//            .disabled(!isFocused)
//            .zIndex(!isFocused ? 1 : 0)

            
            HStack {
                TextField("Search or URL...", text: $text)
                Button(action: clear) {
                    Image(systemName: "xmark.circle.fill")
                        .tint(.secondary)
                        .opacity(0.6)
                }
                // clear
            }
            .disabled(isFocused)
            .opacity(isFocused ? 1 : 0)
            .zIndex(isFocused ? 1 : 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
//        .frame(height: 56)
        .frame(maxWidth: .infinity)
        .background {
            Color.secondary
                .opacity(0.2)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
    
    
    func reload() {}
    func cancel() {}
    func clear() {}
}



public class _WKInputAccessoryWebView: WKWebView {

  override init(frame: CGRect,configuration : WKWebViewConfiguration) {
       super.init(frame: frame, configuration:configuration)
  }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
  public var accessoryView : UIView?
  public override var inputAccessoryView: UIView? {
       return accessoryView
   }

}

public class WKInputAccessoryWebView: _WKInputAccessoryWebView {

    override init(frame: CGRect,configuration : WKWebViewConfiguration) {
      super.init(frame: frame, configuration: configuration)
   }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override var inputAccessoryView: UIView? {
        get { return self.accessoryView }
        set { self.accessoryView = newValue }
   }
}

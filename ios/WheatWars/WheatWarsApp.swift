import UIKit
import WebKit

/// Wheat Wars for iPhone & iPad: the same game file as the PC, Android and web versions,
/// bundled in the app and run fully offline in a WKWebView.
@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let w = UIWindow(frame: UIScreen.main.bounds)
        w.backgroundColor = .black
        w.rootViewController = GameViewController()
        w.makeKeyAndVisible()
        window = w
        return true
    }
}

final class GameViewController: UIViewController, WKNavigationDelegate {
    private var web: WKWebView!

    override func loadView() {
        let cfg = WKWebViewConfiguration()
        cfg.allowsInlineMediaPlayback = true                 // intro video plays in the game, not full-screen player
        cfg.mediaTypesRequiringUserActionForPlayback = []    // PC-speaker sound effects
        cfg.websiteDataStore = .default()                    // saved games, scores & nickname persist
        cfg.applicationNameForUserAgent = "WheatWarsApp/2.2.0"  // the game hides browser-only buttons in the app
        #if DEBUG
        // test builds: record JavaScript errors so the simulator check can report them
        cfg.userContentController.addUserScript(WKUserScript(
            source: "window.__errs=[];addEventListener('error',e=>__errs.push(String(e.message)+' @'+e.lineno));",
            injectionTime: .atDocumentStart, forMainFrameOnly: true))
        #endif
        web = WKWebView(frame: .zero, configuration: cfg)
        web.navigationDelegate = self
        web.isOpaque = false
        web.backgroundColor = .black
        web.scrollView.backgroundColor = .black
        web.scrollView.bounces = false
        web.scrollView.isScrollEnabled = false
        web.scrollView.contentInsetAdjustmentBehavior = .never
        web.allowsLinkPreview = false
        view = web
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true      // keep the screen awake while playing
        if let dir = Bundle.main.url(forResource: "game", withExtension: nil) {
            web.loadFileURL(dir.appendingPathComponent("index.html"), allowingReadAccessTo: dir)
        } else {
            #if DEBUG
            diag("game folder missing from bundle")
            #endif
        }
        #if DEBUG
        diag("viewDidLoad")
        #endif
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(saveNow), name: UIApplication.willResignActiveNotification, object: nil)
        nc.addObserver(self, selector: #selector(saveNow), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    /// Save the moment the app leaves the screen: iOS may close a background app without warning.
    @objc private func saveNow() {
        web.evaluateJavaScript("window.wwPause&&window.wwPause()", completionHandler: nil)
    }

    // stay inside the game; nothing external opens
    func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(action.request.url?.isFileURL == true ? .allow : .cancel)
    }

    #if DEBUG
    private func diag(_ line: String) {
        print("WW-DIAG " + line)
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("diag.txt")
        let old = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
        try? (old + line + "\n").write(to: url, atomically: true, encoding: .utf8)
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        diag("didFinish \(webView.url?.absoluteString ?? "-")")
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            let js = "JSON.stringify({mode:(window.S&&S.mode)||null,errs:window.__errs,ver:(window.WW&&WW.APP_VERSION),touch:window.TOUCH,app:window.APPSHELL,w:innerWidth,h:innerHeight,txt:(document.getElementById('scr')||{}).textContent?.slice(0,80),ls:(()=>{try{localStorage.setItem('x','1');return localStorage.getItem('x')}catch(e){return 'LS-ERR '+e}})()})"
            webView.evaluateJavaScript(js) { r, e in diag("state \(r ?? "nil") err \(String(describing: e))") }
        }
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) { diag("didFail \(error)") }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) { diag("didFailProvisional \(error)") }
    #endif

    // if iOS reclaims the web view's memory in the background, reload (the save is already on disk)
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) { webView.reload() }

    override var prefersStatusBarHidden: Bool { true }
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { .bottom }
}

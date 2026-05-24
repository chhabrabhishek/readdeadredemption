import SwiftUI
import PDFKit

/// Native PDF reader with page tracking and scroll velocity detection
struct PDFReaderView: UIViewRepresentable {
    let url: URL
    var onPageChange: (Int) -> Void
    var onScrollVelocity: (Double) -> Void
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: url)
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.usePageViewController(true)
        
        // Set up delegate
        context.coordinator.pdfView = pdfView
        
        // Observe page changes
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.pageChanged(_:)),
            name: .PDFViewPageChanged,
            object: pdfView
        )
        
        // Add scroll velocity tracking
        if let scrollView = pdfView.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
            scrollView.delegate = context.coordinator
        }
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onPageChange: onPageChange, onScrollVelocity: onScrollVelocity)
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        weak var pdfView: PDFView?
        let onPageChange: (Int) -> Void
        let onScrollVelocity: (Double) -> Void
        private var lastPageIndex: Int = 0
        
        init(onPageChange: @escaping (Int) -> Void, onScrollVelocity: @escaping (Double) -> Void) {
            self.onPageChange = onPageChange
            self.onScrollVelocity = onScrollVelocity
        }
        
        @objc func pageChanged(_ notification: Notification) {
            guard let pdfView = pdfView,
                  let currentPage = pdfView.currentPage,
                  let document = pdfView.document else { return }
            
            let pageIndex = document.index(for: currentPage)
            if pageIndex != lastPageIndex {
                lastPageIndex = pageIndex
                DispatchQueue.main.async {
                    self.onPageChange(pageIndex)
                }
            }
        }
        
        // MARK: - UIScrollViewDelegate
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let velocity = abs(scrollView.panGestureRecognizer.velocity(in: scrollView).y)
            if velocity > 100 {
                DispatchQueue.main.async {
                    self.onScrollVelocity(Double(velocity))
                }
            }
        }
    }
}

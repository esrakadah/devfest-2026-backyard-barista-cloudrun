import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController
    self.minSize = NSSize(width: 1100, height: 760)

    if let screenFrame = self.screen?.visibleFrame ?? NSScreen.main?.visibleFrame {
      let targetWidth = min(max(1280.0, self.frame.size.width), screenFrame.size.width)
      let targetHeight = min(max(860.0, self.frame.size.height), screenFrame.size.height)
      let originX = screenFrame.origin.x + (screenFrame.size.width - targetWidth) / 2.0
      let originY = screenFrame.origin.y + (screenFrame.size.height - targetHeight) / 2.0
      let centeredFrame = NSRect(x: originX, y: originY, width: targetWidth, height: targetHeight)
      self.setFrame(centeredFrame, display: true)
    }

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}

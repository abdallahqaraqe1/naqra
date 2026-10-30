import AppKit

@MainActor
final class StatusBarController: NSObject, NSMenuDelegate {
    private let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let menu = NSMenu()

    override init() {
        super.init()
        if let button = item.button {
            button.image = Self.menuBarIcon
            button.toolTip = "Naqra — drag files, then press a modifier key"
        }
        menu.delegate = self
        item.menu = menu
    }

    /// A template version of the Naqra app icon: a cursor arrow with click ripples and radial wheel arc.
    static let menuBarIcon: NSImage = {
        let image = NSImage(size: NSSize(width: 18, height: 18), flipped: true) { rect in
            NSColor.black.setStroke()
            NSColor.black.setFill()

            // Outer radial wheel arc
            let wheelArc = NSBezierPath()
            wheelArc.appendArc(withCenter: NSPoint(x: 9.2, y: 9.2), radius: 6.8, startAngle: -92, endAngle: 150, clockwise: false)
            wheelArc.lineWidth = 1.65
            wheelArc.lineCapStyle = .round
            wheelArc.stroke()

            // Click ripple arc around the cursor tip
            let ripple = NSBezierPath()
            ripple.appendArc(withCenter: NSPoint(x: 7.0, y: 6.4), radius: 2.6, startAngle: 135, endAngle: 325, clockwise: false)
            ripple.lineWidth = 1.25
            ripple.lineCapStyle = .round
            ripple.stroke()

            // Cursor arrow
            let cursor = NSBezierPath()
            cursor.move(to: NSPoint(x: 6.8, y: 5.8))
            cursor.line(to: NSPoint(x: 8.2, y: 14.0))
            cursor.line(to: NSPoint(x: 10.1, y: 12.1))
            cursor.line(to: NSPoint(x: 12.1, y: 15.1))
            cursor.line(to: NSPoint(x: 13.6, y: 14.1))
            cursor.line(to: NSPoint(x: 11.6, y: 11.1))
            cursor.line(to: NSPoint(x: 14.1, y: 10.0))
            cursor.close()
            cursor.fill()
            return true
        }
        image.isTemplate = true
        image.accessibilityDescription = "Naqra"
        return image
    }()

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        let settings = AppSettings.shared

        let hint = NSMenuItem(title: L10n.t("Drag files, then press \(settings.convertModifier.symbol) \(settings.toolsModifier.symbol) \(settings.actionsModifier.symbol)"),
                              action: nil, keyEquivalent: "")
        hint.isEnabled = false
        menu.addItem(hint)
        menu.addItem(.separator())

        menu.addItem(action("New Float", #selector(newFloat), key: "n"))
        let close = action("Close All Floats", #selector(closeFloats), key: "")
        close.isEnabled = FloatManager.shared.hasFloats
        menu.addItem(close)
        menu.addItem(action("Create QR Code…", #selector(createQR), key: ""))
        menu.addItem(.separator())
        menu.addItem(action("Welcome Guide…", #selector(showWelcome), key: ""))
        menu.addItem(action("Settings…", #selector(showSettings), key: ","))
        menu.addItem(.separator())
        menu.addItem(action("Quit Naqra", #selector(quit), key: "q"))
    }

    private func action(_ title: String, _ selector: Selector, key: String) -> NSMenuItem {
        let item = NSMenuItem(title: L10n.t(title), action: selector, keyEquivalent: key)
        item.target = self
        return item
    }

    @objc private func newFloat() { FloatManager.shared.createFloat() }
    @objc private func closeFloats() { FloatManager.shared.closeAll() }
    @objc private func createQR() { QRWindow.openFromMenu() }
    @objc private func showWelcome() { WelcomeController.shared.show() }
    @objc private func showSettings() { SettingsController.shared.show() }
    @objc private func quit() { NSApp.terminate(nil) }
}

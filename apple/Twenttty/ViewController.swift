//
//  ViewController.swift
//  Twenttty
//
//  Created by Michał Pierzchała on 25/12/2019.
//  Copyright © 2019 Michał Pierzchała. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextFieldDelegate {
    @IBOutlet weak var timer: NSTextField!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var statusImage: NSImageView!
    @IBOutlet weak var preferences: NSButton!
    @IBOutlet weak var appNameLabel: NSTextField!
    @IBOutlet weak var isMutedButton: NSButton!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    var activityStatus: ActivityStatus! // injected
    var interval: Timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(macOS 11, *) {
            adjustConstraintsForBigSur()
        }
    }

    @available(macOS 11, *)
    func adjustConstraintsForBigSur() {
        let leading = CGFloat(14)
        let trailing = CGFloat(-14)

        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        statusImage.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        timer.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            appNameLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: leading),
            statusLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: leading),
            progressBar.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: leading),
            progressBar.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: trailing),
            statusImage.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: trailing),
            timer.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: trailing),
        ])
    }

    func setup() {
        progressBar.minValue = 0
        progressBar.maxValue = activityStatus.activityTime
        
        timer.font = NSFont.monospacedDigitSystemFont(ofSize: 20, weight: NSFont.Weight.regular)

        setAppNameLabel()
        displayStatus()
        displayTimer()

        interval = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.displayStatus()
            self.displayTimer()
        })
        RunLoop.current.add(interval, forMode: .common)
    }

    func teardown() {
        interval.invalidate()
    }

    func setAppNameLabel() {
        appNameLabel.stringValue = AppVersion.getAppName()
    }

    func displayTimer() {
        let initialValue = (String(Int(floor(activityStatus.activityTime / 60)))).padding(toLength: 2, withPad: "0", startingAt: 0) + ":00"
        let now = Date()
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad

        if (AppState.status == Status.Active) {
            timer.stringValue = formatter.string(from: now, to: activityStatus.activityTimer.fireDate) ?? initialValue
            progressBar.maxValue = activityStatus.activityTime
            progressBar.doubleValue = ((activityStatus.activityTime - activityStatus.activityTimer.fireDate.timeIntervalSinceNow) / activityStatus.activityTime) * activityStatus.activityTime
            timer.textColor = NSColor.textColor
        } else if (AppState.status == Status.Break) {
            timer.stringValue = formatter.string(from: now, to: activityStatus.breakTimer.fireDate) ?? initialValue
            progressBar.maxValue = activityStatus.breakTime
            progressBar.doubleValue = ((activityStatus.breakTime - activityStatus.breakTimer.fireDate.timeIntervalSinceNow) / activityStatus.breakTime) * activityStatus.breakTime
            timer.textColor = NSColor.systemRed
        } else {
            timer.stringValue = initialValue
            timer.textColor = NSColor.textColor
            progressBar.doubleValue = 0
        }
    }

    func displayStatus() {
        let (image, label) = mapStatusToLabelData(AppState.status)
        statusLabel.stringValue = label
        statusImage.image = image
    }

    func mapStatusToLabelData(_ status: Status) -> (NSImage, String) {
        switch status {
        case Status.Active:
            return (NSImage(named: "NSStatusAvailable")!, NSLocalizedString("status_active", comment: ""))
        case Status.Break:
            return (NSImage(named: "NSStatusUnavailable")!, NSLocalizedString("status_break", comment: ""))
        default:
            return (NSImage(named: "NSStatusNone")!, NSLocalizedString("status_inactive", comment: ""))
        }
    }
}

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
  var contentHandler: ((UNNotificationContent) -> Void)?
  var bestAttemptContent: UNMutableNotificationContent?

  override func didReceive(
    _ request: UNNotificationRequest,
    withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
  ) {
    self.contentHandler = contentHandler
    bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

    guard
      let content = bestAttemptContent,
      let imageUrlString = request.content.userInfo["image_url"] as? String,
      let imageUrl = URL(string: imageUrlString)
    else {
      contentHandler(request.content)
      return
    }

    downloadImage(from: imageUrl) { attachment in
      if let attachment = attachment {
        content.attachments = [attachment]
      }
      contentHandler(content)
    }
  }

  override func serviceExtensionTimeWillExpire() {
    if let contentHandler = contentHandler, let content = bestAttemptContent {
      contentHandler(content)
    }
  }

  private func downloadImage(from url: URL, completion: @escaping (UNNotificationAttachment?) -> Void) {
    URLSession.shared.downloadTask(with: url) { location, _, _ in
      guard let location = location else { completion(nil); return }
      let tmpDir = FileManager.default.temporaryDirectory
      let ext = url.pathExtension.isEmpty ? "jpg" : url.pathExtension
      let dest = tmpDir.appendingPathComponent(UUID().uuidString + "." + ext)
      try? FileManager.default.moveItem(at: location, to: dest)
      let attachment = try? UNNotificationAttachment(identifier: "", url: dest, options: nil)
      completion(attachment)
    }.resume()
  }
}

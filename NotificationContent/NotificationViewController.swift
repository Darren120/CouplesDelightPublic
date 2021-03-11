

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var label: UILabel?
    @IBOutlet var imageView: UIImageView?
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
//
//        let attachments = notification.request.content.attachments
//        for attachment in attachments {
//            if attachment.identifier == "picture" {
//                print("imgae url: \(attachment.url)")
//            }
//        }
      
        
        self.label?.text = "fmclak"
    }

}

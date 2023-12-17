import Foundation

let dateFormatter: DateFormatter = {
    lazy var dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .none
    return dateFormatter
}()



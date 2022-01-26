import Foundation
import CoreLocation

extension CLLocation {
    var latitude: Double {
        return self.coordinate.latitude
    }

    var longitude: Double {
        return self.coordinate.longitude
    }
}

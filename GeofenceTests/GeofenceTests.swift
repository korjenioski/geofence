import XCTest
import Foundation
import CoreLocation
@testable import Geofence

class GeofenceTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEmptyPlaceMark() throws {
        let serviceSpy = makeLocationViewModelProtocolSpy()
        let locationCoordinates = CLLocationCoordinate2D(latitude: 40.7579747, longitude: -73.9855426)
        let location = CLLocation(latitude: 40.7579747, longitude: -73.9855426)

        serviceSpy.setupRegion(coordinate: locationCoordinates, radius: 10, identifier: "Times Square")
        serviceSpy.changeAuthorizationStatus(.authorizedAlways)
        serviceSpy.changeLocation(location)
        serviceSpy.geocode()

        XCTAssertNil(serviceSpy.placemark)
    }

    func testAuthorizationStatus() throws {
        let status: CLAuthorizationStatus = .authorizedAlways
        let serviceSpy = makeLocationViewModelProtocolSpy()
        serviceSpy.changeAuthorizationStatus(.authorizedAlways)

        XCTAssertNotNil(serviceSpy.status)
        XCTAssertEqual(serviceSpy.status, status)
    }

    func makeLocationViewModelProtocolSpy() -> LocationViewModelProtocolSpy {
        return LocationViewModelProtocolSpy()
    }
}

final class LocationViewModelProtocolSpy: LocationViewModelProtocol {
    var status: CLAuthorizationStatus?

    var location: CLLocation?

    var region: CLCircularRegion?

    var didEnterRegion: CLRegion?

    var didExitRegion: CLRegion?

    var placemark: CLPlacemark?

    func setupRegion(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String) {
        region = CLCircularRegion(
            center: coordinate,
            radius: radius,
            identifier: identifier)
    }

    func changeAuthorizationStatus(_ status: CLAuthorizationStatus) {
        self.status = status
    }

    func changeLocation(_ location: CLLocation) {
        self.location = location
    }

    func geocode() {
        guard let location = self.location else { return }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: { (places, error) in
            if error == nil {
                self.placemark = places?[0]
            } else {
                self.placemark = nil
            }
        })
    }
}

import Foundation
import CoreLocation
import Combine

// MARK: - LocationViewModelProtocol

public protocol LocationViewModelProtocol: ObservableObject {
    var status: CLAuthorizationStatus? { get set }
    var location: CLLocation? { get set }
    var region: CLCircularRegion? { get set }
    var didEnterRegion: CLRegion? { get set }
    var didExitRegion: CLRegion? { get set }
    var placemark: CLPlacemark? { get set }
    func setupRegion(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String)
}

class LocationViewModel: NSObject {
    // MARK: - Instance properties

    private let geocoder = CLGeocoder()
    private let locationManager = CLLocationManager()
    let objectWillChange = PassthroughSubject<Void, Never>()

    @Published var status: CLAuthorizationStatus? {
        willSet { objectWillChange.send() }
    }

    @Published var location: CLLocation? {
        willSet { objectWillChange.send() }
    }

    @Published var region: CLCircularRegion? {
        willSet { objectWillChange.send() }
    }

    @Published var didEnterRegion: CLRegion? {
        willSet { objectWillChange.send() }
    }

    @Published var didExitRegion: CLRegion? {
        willSet { objectWillChange.send() }
    }

    @Published var placemark: CLPlacemark? {
        willSet { objectWillChange.send() }
    }

    // MARK: - Initialization

    override init() {
        super.init()

        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()

        let locationCoordinates = CLLocationCoordinate2D(latitude: 40.7579747, longitude: -73.9855426)
        let maxDistance = locationManager.maximumRegionMonitoringDistance
        setupRegion(coordinate: locationCoordinates, radius: maxDistance, identifier: "Times Square")
    }

    // MARK: - Functions

    private func geocode() {
        guard let location = self.location else { return }
        geocoder.reverseGeocodeLocation(location, completionHandler: { (places, error) in
            if error == nil {
                self.placemark = places?[0]
            } else {
                self.placemark = nil
            }
        })
    }
}

// MARK: - LocationViewModelProtocol

extension LocationViewModel: LocationViewModelProtocol {
    func setupRegion(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String) {
        region = CLCircularRegion(
            center: coordinate,
            radius: radius,
            identifier: identifier)
        guard let region = region else { return }

        region.notifyOnEntry = true
        region.notifyOnExit = true
        locationManager.startMonitoring(for: region)
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.status = status
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        self.geocode()
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        self.didEnterRegion = region
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        self.didExitRegion = region
    }
}

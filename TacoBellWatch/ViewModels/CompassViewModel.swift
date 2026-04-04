import SwiftUI
import CoreLocation
import MapKit
import Combine

class CompassViewModel: ObservableObject {
    /// Device heading (0-360, dial rotates by negative of this)
    @Published var headingAngle: Double = 0
    /// Taco Bell bearing relative to heading (bearing - heading). Taco marker uses this.
    @Published var tacoRelativeAngle: Double = 0
    /// Whether the user is facing Taco Bell (within 15 degrees)
    @Published var isOnTarget: Bool = false
    @Published var distance: Double = 0
    @Published var isLoading: Bool = true
    @Published var tacoBellName: String = ""
    @Published var errorMessage: String? = nil

    let locationService = LocationService()
    private let searchService = TacoBellSearchService()
    private let soundPlayer = SoundPlayer()
    private var nearestTacoBell: MKMapItem?
    private var lastSearchLocation: CLLocation?
    private var cancellables = Set<AnyCancellable>()
    private var hasSearched = false

    init() {
        locationService.$userLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                self?.onLocationUpdate(location)
            }
            .store(in: &cancellables)

        locationService.$heading
            .compactMap { $0 }
            .sink { [weak self] _ in
                self?.updateCompass()
            }
            .store(in: &cancellables)
    }

    func start() {
        locationService.requestPermissionAndStart()
    }

    func stop() {
        locationService.stop()
    }

    private func onLocationUpdate(_ location: CLLocation) {
        let shouldSearch = !hasSearched ||
            (lastSearchLocation.map { location.distance(from: $0) > 500 } ?? true)

        if shouldSearch {
            hasSearched = true
            lastSearchLocation = location
            searchForTacoBell(near: location)
        }

        updateCompass()
    }

    private func searchForTacoBell(near location: CLLocation) {
        isLoading = true
        errorMessage = nil

        Task { @MainActor in
            do {
                let result = try await searchService.findNearestTacoBell(near: location)
                if let item = result {
                    nearestTacoBell = item
                    tacoBellName = item.name ?? "Taco Bell"
                    isLoading = false
                    updateCompass()
                } else {
                    errorMessage = "No Taco Bell found nearby"
                    isLoading = false
                }
            } catch {
                errorMessage = "Search failed: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }

    private func updateCompass() {
        guard let userLoc = locationService.userLocation,
              let heading = locationService.heading,
              let targetItem = nearestTacoBell else { return }

        let targetCoord = targetItem.placemark.coordinate

        let bearing = BearingCalculator.bearing(
            from: userLoc.coordinate,
            to: targetCoord
        )

        let headingDegrees = heading.trueHeading >= 0 ? heading.trueHeading : heading.magneticHeading

        headingAngle = headingDegrees
        tacoRelativeAngle = bearing - headingDegrees

        let targetLocation = CLLocation(latitude: targetCoord.latitude, longitude: targetCoord.longitude)
        distance = userLoc.distance(from: targetLocation)

        let angleDiff = BearingCalculator.angleDifference(bearing, headingDegrees)
        let wasOnTarget = isOnTarget
        isOnTarget = abs(angleDiff) <= 15.0

        if isOnTarget && !wasOnTarget {
            soundPlayer.play()
        }
    }
}

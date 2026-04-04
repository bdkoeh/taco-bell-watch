import MapKit

class TacoBellSearchService {
    func findNearestTacoBell(near location: CLLocation) async throws -> MKMapItem? {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Taco Bell"
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 16_000,
            longitudinalMeters: 16_000
        )
        request.resultTypes = .pointOfInterest

        let search = MKLocalSearch(request: request)
        let response = try await search.start()

        return response.mapItems.min(by: { a, b in
            let distA = location.distance(from: CLLocation(
                latitude: a.placemark.coordinate.latitude,
                longitude: a.placemark.coordinate.longitude
            ))
            let distB = location.distance(from: CLLocation(
                latitude: b.placemark.coordinate.latitude,
                longitude: b.placemark.coordinate.longitude
            ))
            return distA < distB
        })
    }
}

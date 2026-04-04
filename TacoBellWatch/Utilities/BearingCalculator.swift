import CoreLocation

enum BearingCalculator {
    /// Returns the initial bearing (in degrees, 0-360) from one coordinate to another.
    static func bearing(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let lat1 = from.latitude.degreesToRadians
        let lat2 = to.latitude.degreesToRadians
        let dLon = (to.longitude - from.longitude).degreesToRadians

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)

        return (radiansBearing.radiansToDegrees + 360).truncatingRemainder(dividingBy: 360)
    }

    /// Returns the smallest signed angle difference between two headings (in degrees).
    /// Result is in the range [-180, 180].
    static func angleDifference(_ a: Double, _ b: Double) -> Double {
        var diff = a - b
        while diff > 180 { diff -= 360 }
        while diff < -180 { diff += 360 }
        return diff
    }
}

extension Double {
    var degreesToRadians: Double { self * .pi / 180.0 }
    var radiansToDegrees: Double { self * 180.0 / .pi }
}

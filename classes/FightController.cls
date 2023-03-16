public with sharing class FightController {
	@AuraEnabled(cacheable=true)
	public static List<Airport__c> getAirports() {
		try {
			return [
				SELECT IATA_Code__c, Location__Latitude__s, Location__Longitude__s
				FROM Airport__c
				WITH SECURITY_ENFORCED
			];
		} catch (Exception e) {
			Utils.logError(e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static Flight__c saveFlight(Airport__c departure, Airport__c arrival) {
		try {
			Decimal distanceInKm =
				calculateDistance(
					departure.Location__Latitude__s,
					departure.Location__Longitude__s,
					arrival.Location__Latitude__s,
					arrival.Location__Longitude__s
				) / 1000;
			Flight__c flight = new Flight__c(
				Departure__c = departure.Id,
				Arrival__c = arrival.Id,
				Distance__c = distanceInKm
			);

			insert flight;

			return flight;
		} catch (Exception e) {
			Utils.logError(e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	private static Decimal calculateDistance(
		Decimal latitude1,
		Decimal longitude1,
		Decimal latitude2,
		Decimal longitude2
	) {
		Integer earthRadius = 6371 * 1000; // in meters
		// Transform coordinates from degrees to radians
		Decimal latitudeRadians1 = latitude1 * Math.PI / 180;
		Decimal latitudeRadians2 = latitude2 * Math.PI / 180;
		// Latitude and longitude differences in radians
		Decimal latitudeDelta = (latitude2 - latitude1) * Math.PI / 180;
		Decimal longitudeDelta = (longitude2 - longitude1) * Math.PI / 180;
		Decimal a =
			Math.sin(latitudeDelta / 2) * Math.sin(latitudeDelta / 2) +
			Math.cos(latitudeRadians1) * Math.cos(latitudeRadians2) * Math.sin(longitudeDelta / 2) *
			Math.sin(longitudeDelta / 2);
		Decimal arc = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
		Decimal distance = earthRadius * arc; // in metres
		return distance;
	}
}

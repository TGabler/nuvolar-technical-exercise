@IsTest
public with sharing class FightControllerTest {
	@TestSetup
	static void makeData() {
		Airport__c warsaw = new Airport__c(
			Name = 'Warsaw',
			IATA_Code__c = 'WAW',
			Location__Latitude__s = 52.1672369,
			Location__Longitude__s = 20.9678911
		);
		Airport__c madrid = new Airport__c(
			Name = 'Madrid',
			IATA_Code__c = 'MAD',
			Location__Latitude__s = 40.4839361,
			Location__Longitude__s = -3.5679514999999355
		);
		Airport__c london = new Airport__c(
			Name = 'London',
			IATA_Code__c = 'LHR',
			Location__Latitude__s = 51.4700223,
			Location__Longitude__s = -0.4542954999999438
		);
		insert new List<Airport__c>{ warsaw, madrid, london };
	}

	@IsTest
	static void getAirportsTest() {
		// GIVEN
		Set<String> expectedIATACodes = new Set<String>{ 'WAW', 'MAD', 'LHR' };

		// WHEN
		List<Airport__c> availableAirports = FightController.getAirports();

		// THEN
		System.assertNotEquals(null, availableAirports);
		System.assertEquals(3, availableAirports.size());

		Set<String> actualAIATACodes = new Set<String>{
			availableAirports.get(0).IATA_Code__c,
			availableAirports.get(1).IATA_Code__c,
			availableAirports.get(2).IATA_Code__c
		};
		System.assert(actualAIATACodes.containsAll(expectedIATACodes));
	}

	@IsTest
	static void saveFlightTest() {
		// GIVEN
		Map<String, Airport__c> airportByIATACode = new Map<String, Airport__c>();
		for (Airport__c airport : [
			SELECT IATA_Code__c, Location__Latitude__s, Location__Longitude__s
			FROM Airport__c
		]) {
			airportByIATACode.put(airport.IATA_Code__c, airport);
		}
		Airport__c warsaw = airportByIATACode.get('WAW');
		Airport__c madrid = airportByIATACode.get('MAD');
		Double expectedDistance = 2271;

		// WHEN
		Flight__c flight = FightController.saveFlight(warsaw, madrid);

		// THEN
		System.assertNotEquals(null, flight);
		System.assertNotEquals(null, flight.Id);
		System.assertEquals(warsaw.Id, flight.Departure__c);
		System.assertEquals(madrid.Id, flight.Arrival__c);
		System.assertEquals(expectedDistance, Math.round(flight.Distance__c));
	}

	@IsTest
	static void saveFlightBadArgumentTest() {
		// GIVEN
		Airport__c anyAirport = [
			SELECT IATA_Code__c, Location__Latitude__s, Location__Longitude__s
			FROM Airport__c
			LIMIT 1
		];

		// WHEN
		Boolean isAuraException = false;
		try {
			Flight__c flight = FightController.saveFlight(anyAirport, null);
		} catch (AuraHandledException e) {
			isAuraException = true;
		}

		// THEN
		System.assert(isAuraException, 'Expected NPE rethrown as Aura Exception.');
	}
}

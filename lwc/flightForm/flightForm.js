import { LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import getAirports from "@salesforce/apex/FightController.getAirports";
import saveFlight from "@salesforce/apex/FightController.saveFlight";

export default class FlightForm extends LightningElement {
	departure;
	arrival;
	savedFlight;

	@wire(getAirports, {})
	wiredAirports;

	get airports() {
		return this.wiredAirports.data || [];
	}

	get isSaveButtonDisabled() {
		return this.departure == null || this.arrival == null;
	}

	get airportOptions() {
		return this.airports.map((airport) => ({
			label: airport.IATA_Code__c,
			value: airport.IATA_Code__c
		}));
	}

	async saveFlight() {
		try {
			this.savedFlight = await saveFlight({
				departure: this.departure,
				arrival: this.arrival
			});
			this.showTostSuccess(`Flight created! Distance is ${this.savedFlight.Distance__c}km.`);
		} catch (error) {
			this.handleError(error);
		}
	}

	handleError(error) {
		this.dispatchEvent(
			new ShowToastEvent({
				title: "Error creating flight",
				message: error.body.message,
				variant: "error"
			})
		);
	}

	showTostSuccess(message) {
		this.dispatchEvent(
			new ShowToastEvent({
				title: "Success",
				message,
				variant: "success"
			})
		);
	}

	handleAirportChange(event) {
		this[event.target.dataset.name] = this.airports.find(
			(airport) => airport.IATA_Code__c === event.target.value
		);
	}
}

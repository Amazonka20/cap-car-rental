sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"carmaintenance/test/integration/pages/CarsList",
	"carmaintenance/test/integration/pages/CarsObjectPage"
], function (JourneyRunner, CarsList, CarsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('carmaintenance') + '/test/flp.html#app-preview',
        pages: {
			onTheCarsList: CarsList,
			onTheCarsObjectPage: CarsObjectPage
        },
        async: true
    });

    return runner;
});


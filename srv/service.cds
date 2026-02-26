using car.rental from '../db/schema';

service CarRentalService {
    @odata.draft.enabled

    entity Cars          as projection on rental.Cars;
    entity Customers     as projection on rental.Customers;
    entity Rentals       as projection on rental.Rentals;
    entity Maintenance   as projection on rental.Maintenance;
    entity CarStatuses   as projection on rental.CarStatuses;
    entity CarCategories as projection on rental.CarCategories;
}

annotate CarRentalService.Cars with @Capabilities.InsertRestrictions.Insertable : true;
annotate CarRentalService.Maintenance with @Capabilities.InsertRestrictions.Insertable : true;

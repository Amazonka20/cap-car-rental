using car.rental from '../db/schema';

service CarRentalService {
    entity Cars as projection on rental.Cars;
    entity Customers as projection on rental.Customers;
    entity Rentals as projection on rental.Rentals;
    entity Maintenance as projection on rental.Maintenance;
    entity CarStatuses as projection on rental.CarStatuses;
    entity CarCategories as projection on rental.CarCategories;
}
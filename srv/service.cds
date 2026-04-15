using car.rental from '../db/schema';

service CarRentalService {
    @odata.draft.enabled

    entity Cars          as
        projection on rental.Cars {
            *,
            (
                case
                    when exists rentals[rentalDate < $now
                         and returnDate            > $now]
                         then 'CAR_RENTED'
                    when exists maintenance[startDate <  $now
                         and (
                             endDate                  is null
                             or endDate               >  $now
                         )]
                         then 'CAR_UNDER_MAINTENANCE'
                    else 'CAR_AVAILABLE'
                end
            ) as status_code : String(30),
            status           : Association to CarStatuses
                                   on status.code = status_code
        };

    entity Customers     as projection on rental.Customers;

    entity Rentals       as
        projection on rental.Rentals {
            *,
            car.dailyPrice * days_between(
                rentalDate, returnDate
            ) as totalPrice : Decimal(10, 2)
        };

    entity Maintenance   as projection on rental.Maintenance;
    entity CarStatuses   as projection on rental.CarStatuses;
    entity CarCategories as projection on rental.CarCategories;
}

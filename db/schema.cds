using {sap} from '@sap/cds/common';

namespace car.rental;

entity CarStatuses : sap.common.CodeList {
    key code        : String(30);
        criticality : Integer;
}

entity CarCategories {
    key code : String(20);
        name : String(50);
}


entity Cars {
    key licensePlate : String;
        brand        : String(50)                 @mandatory;
        model        : String                     @mandatory;
        year         : Integer                    @mandatory;
        dailyPrice   : Decimal(10, 2)             @mandatory;
        status       : Association to CarStatuses @mandatory;
        category     : Association to CarCategories;
        rentals      : Association to many Rentals
                           on rentals.car = $self;
        maintenance  : Association to many Maintenance
                           on maintenance.car = $self;
}

entity Customers {
    key driverLicense : String(50);
    key email         : String(100);
        firstName     : String(50) @mandatory;
        lastName      : String(50) @mandatory;
        phone         : String(20) @mandatory;
        address       : String(200);
        rentals       : Association to many Rentals
                            on rentals.customer = $self;
}

entity Rentals {
    key ID         : UUID;
        rentalDate : Date                     @mandatory;
        returnDate : Date                     @mandatory;
        totalPrice : Decimal(10, 2)           @mandatory;
        customer   : Association to Customers @mandatory;
        car        : Association to Cars      @mandatory;
}

entity Maintenance {
    key ID          : UUID;
        startDate   : Date                @mandatory;
        endDate     : Date;
        description : String(500)         @mandatory;
        cost        : Decimal(10, 2);
        car         : Association to Cars @mandatory;

}

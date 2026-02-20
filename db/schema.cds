namespace car.rental;

entity Cars {
    key licensePlate : String;
        brand        : String(50)     @mandatory;
        model        : String         @mandatory;
        year         : Integer        @mandatory;
        dailyPrice   : Decimal(10, 2) @mandatory;
        status       : String default 'Available';
        category     : String(20);
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

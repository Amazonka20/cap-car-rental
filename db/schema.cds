using {cuid} from '@sap/cds/common';

namespace car.rental;

aspect MyCodeList : {
    key code : String(20);
        name : String(50);
}

entity CarStatuses : MyCodeList {
    criticality : Integer;
}

entity CarCategories : MyCodeList {}

entity Cars {
    key licensePlate : String;
        brand        : String(50)                    @mandatory;
        model        : String                        @mandatory;
        year         : Integer                       @mandatory;
        dailyPrice   : Decimal(10, 2)                @assert.range        : [
            (0),
            _
        ]
                                                     @assert.range.message: 'Daily Rental Price must be greater than 0.'
                                                     @mandatory;
        category     : Association to CarCategories  @assert.target  @mandatory;
        rentals      : Association to many Rentals
                           on rentals.car = $self;
        maintenance  : Composition of many Maintenance
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

entity Rentals : cuid {
    rentalDate : Date                     @mandatory;
    returnDate : Date                     @mandatory;
    customer   : Association to Customers @mandatory;
    car        : Association to Cars      @mandatory;
}

entity Maintenance : cuid {
    startDate   : Date                @mandatory;
    endDate     : Date;
    description : String(500)         @mandatory;
    cost        : Decimal(10, 2)      @mandatory;
    car         : Association to Cars @mandatory;
}

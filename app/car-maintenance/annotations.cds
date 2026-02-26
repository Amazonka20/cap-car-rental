using CarRentalService as service from '../../srv/service';

annotate service.Cars with @(
    UI.FieldGroup #MainInfo     : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Label: '{i18n>LicensePlate}',
                Value: licensePlate
            },
            {
                $Type: 'UI.DataField',
                Label: '{i18n>Brand}',
                Value: brand
            },
            {
                $Type: 'UI.DataField',
                Label: '{i18n>Model}',
                Value: model
            }
        ]
    },

    UI.FieldGroup #PricingStatus: {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Label: '{i18n>Year}',
                Value: year
            },
            {
                $Type: 'UI.DataField',
                Label: '{i18n>DailyPrice}',
                Value: dailyPrice
            },
            {
                $Type      : 'UI.DataField',
                Label      : '{i18n>Status}',
                Value      : status_code,
                Criticality: status.criticality
            },
            {
                $Type: 'UI.DataField',
                Label: '{i18n>Category}',
                Value: category_code
            }
        ]
    },
    UI.Facets                   : [
        {
            $Type : 'UI.ReferenceFacet',
            Label : '{i18n>Rentals}',
            ID    : 'Rentals',
            Target: 'rentals/@UI.LineItem#Rentals',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : '{i18n>Maintenance}',
            ID    : 'Maintenance',
            Target: 'maintenance/@UI.LineItem#Maintenance',
        },
    ],
    UI.LineItem                 : [
        {
            $Type: 'UI.DataField',
            Label: '{i18n>LicensePlate}',
            Value: licensePlate,
        },
        {
            $Type: 'UI.DataField',
            Label: '{i18n>Brand}',
            Value: brand,
        },
        {
            $Type: 'UI.DataField',
            Label: '{i18n>Model}',
            Value: model,
        },
        {
            $Type: 'UI.DataField',
            Label: '{i18n>Year}',
            Value: year,
        },
        {
            $Type: 'UI.DataField',
            Label: '{i18n>DailyPrice}',
            Value: dailyPrice,
        },
    ],
    UI.HeaderFacets             : [
        {
            $Type : 'UI.ReferenceFacet',
            Label : '{i18n>MainInfo}',
            Target: '@UI.FieldGroup#MainInfo'
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : '{i18n>PricingStatus}',
            Target: '@UI.FieldGroup#PricingStatus'
        }
    ],
    UI.FieldGroup #Rentals      : {
        $Type: 'UI.FieldGroupType',
        Data : [],
    },
    UI.FieldGroup #Maintenance  : {
        $Type: 'UI.FieldGroupType',
        Data : [],
    },
    UI.SelectionFields          : [
        status_code,
        category_code,
        year,
        licensePlate,
    ],
);

annotate service.Cars with {
    status  @Common.ValueListWithFixedValues: true;
    status  @Common.Text: status.name  @Common.TextArrangement: #TextOnly
};

annotate service.Cars with {
    category @Common.Text           : category.name;
    category @Common.TextArrangement: #TextOnly;
};


annotate service.Cars with {
    licensePlate @Common.ValueList: {
        $Type         : 'Common.ValueListType',
        CollectionPath: 'Cars',
        Parameters    : [
            {
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: licensePlate,
                ValueListProperty: 'licensePlate'
            },
            {
                $Type            : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'brand'
            },
            {
                $Type            : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'model'
            }
        ]
    }
};

annotate service.Cars with {
    category @Common.ValueList               : {
        $Type         : 'Common.ValueListType',
        CollectionPath: 'CarCategories',
        Parameters    : [{
            $Type            : 'Common.ValueListParameterDisplayOnly',
            ValueListProperty: 'name'
        }]
    };

    category @Common.ValueListWithFixedValues: true;
};


annotate service.Cars with {
    status       @Common.Label: '{i18n>Status}';
    category     @Common.Label: '{i18n>Category}';
    year         @Common.Label: '{i18n>Year}';
    licensePlate @Common.Label: '{i18n>LicensePlate}';
    brand        @Common.Label: '{i18n>Brand}';
    model        @Common.Label: '{i18n>Model}';
};


annotate service.Rentals with @(UI.LineItem #Rentals: [
    {
        $Type: 'UI.DataField',
        Value: car.rentals.car_licensePlate,
        Label: '{i18n>Carlicenseplate}',
    },
    {
        $Type: 'UI.DataField',
        Value: car.rentals.customer_driverLicense,
        Label: '{i18n>Customerdriverlicense}',
    },
    {
        $Type: 'UI.DataField',
        Value: car.rentals.customer_email,
        Label: '{i18n>Customeremail}',
    },
    {
        $Type: 'UI.DataField',
        Value: car.rentals.ID,
        Label: '{i18n>ID}',
    },
    {
        $Type: 'UI.DataField',
        Value: car.rentals.rentalDate,
        Label: '{i18n>Rentaldate}',
    },
    {
        $Type: 'UI.DataField',
        Value: car.rentals.returnDate,
        Label: '{i18n>Returndate}',
    },
    {
        $Type: 'UI.DataField',
        Value: car.rentals.totalPrice,
        Label: '{i18n>Totalprice}',
    },
]);

annotate service.Maintenance with @(UI.LineItem #Maintenance: [
    {
        $Type: 'UI.DataField',
        Value: car_licensePlate,
        Label: '{i18n>Carlicenseplate}',
    },
    {
        $Type: 'UI.DataField',
        Value: cost,
        Label: '{i18n>Cost}',
    },
    {
        $Type: 'UI.DataField',
        Value: description,
        Label: '{i18n>Description}',
    },
    {
        $Type: 'UI.DataField',
        Value: startDate,
        Label: '{i18n>Startdate}',
    },
    {
        $Type: 'UI.DataField',
        Value: endDate,
        Label: '{i18n>Enddate}',
    },
    {
        $Type: 'UI.DataField',
        Value: ID,
        Label: '{i18n>ID}',
    },
]);

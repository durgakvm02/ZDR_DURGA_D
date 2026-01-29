@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BOOKSUPPL PROJECTI VIEW ENTITY FOR DRAFT'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
@Metadata.allowExtensions: true
define view entity ZDR_C_BOOKINGSUPPLEMENT_D as projection on ZDR_R_BOOKINGSUPPLEMENT_D
{
    key BooksupplUuid,
    TravelUuid,
    bookingUuid,
    @Search.defaultSearchElement: true
    BookingSupplementId,
    @ObjectModel.text.element: [ 'SupplementDescription' ]
    @Consumption.valueHelpDefinition: [{ entity : {name : '/dmo/i_supplement_stdvh',element : 'supplementId'  },
    additionalBinding : [ { localElement : 'Price', element : 'Price',usage : #RESULT},
                         { localElement : 'CurrencyCode', element : 'CurrencyCode',usage : #RESULT}
    ],
    useForValidation : true } ]
    SupplementId,
    _supplementtext.Description as SupplementDescription : localized,
     @Semantics.amount.currencyCode: 'CurrencyCode'
    Price,
    @Consumption.valueHelpDefinition: [{ entity : {name : 'i_currencystdvh',element : 'Currency'  },useForValidation : true }]
    CurrencyCode,
    LocalLastChangedAt,
    /* Associations */
    _Booking : redirected to parent ZDR_C_BOOKING_D,
    _product,
    _supplementtext,
    _Travel : redirected to ZDR_C_TRAVEL_D
}




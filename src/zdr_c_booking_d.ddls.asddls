@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BOOKING PROJECTION VIEW ENTITY FOR DRAFT'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity ZDR_C_BOOKING_D
  as projection on ZDR_R_BOOKING_D
{
  key BookingUuid,
      TravelUuid,

      @Search.defaultSearchElement: true
      BookingId,

      BookingDate,

      @Search.defaultSearchElement: true
      @ObjectModel.text.element: [ 'CustomerName' ]
      @Consumption.valueHelpDefinition: [{
        entity : { name : '/DMO/I_Customer_STDVH', element : 'CustomerID' },
        useForValidation : true
      }]
      CustomerId,

      _customer.LastName as CustomerName,

      @ObjectModel.text.element: [ 'CarrierName' ]
      @Consumption.valueHelpDefinition: [{
        entity : { name : '/DMO/I_Carrier', element : 'AirlineID' },
        useForValidation : true
      }]
      AirlineId,

      _carrier.Name as CarrierName,

      @Consumption.valueHelpDefinition: [{
        entity : { name : '/DMO/I_Flight_STDVH', element : 'ConnectionID' },
        additionalBinding : [
          { localElement : 'AirlineId',  element : 'AirlineID',  usage : #FILTER },
          { localElement : 'FlightDate', element : 'FlightDate', usage : #FILTER },
          { localElement : 'FlightPrice', element : 'Price', usage : #RESULT },
          { localElement : 'CurrencyCode', element : 'CurrencyCode', usage : #RESULT }
        ],
        useForValidation : false
      }]
      ConnectionId,

      FlightDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,

      @Consumption.valueHelpDefinition: [{
        entity : { name : 'I_CurrencyStdVH', element : 'Currency' },
        useForValidation : true
      }]
      CurrencyCode,

      @ObjectModel.text.element: ['BookingStatusText']
      @Consumption.valueHelpDefinition: [{
        entity : { name : '/DMO/I_Booking_Status_VH', element : 'BookingStatus' }
      }]
      BookingStatus,

      _bookingstatus._Text.Text as BookingStatusText : localized,

      LocalLastChangedAt,

      _customer,
      _carrier,
      _connection,
      _bookingstatus,
      _Bookingsupplement : redirected to composition child ZDR_C_BOOKINGSUPPLEMENT_D,
      _Travel            : redirected to parent ZDR_C_TRAVEL_D
}

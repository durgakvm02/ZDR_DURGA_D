@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BOOKING VIEW ENTITY FOR DRAFT REFSEN'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZDR_R_BOOKING_D
  as select from /dmo/a_booking_d 
  association to parent ZDR_R_TRAVEL_D as _Travel on $projection.TravelUuid = _Travel.TravelUUID
  composition [0..*] of ZDR_R_BOOKINGSUPPLEMENT_D as _Bookingsupplement
  association [0..1] to /DMO/I_Customer          as _customer      on  $projection.CustomerId = _customer.CustomerID
  association [0..1] to /DMO/I_Carrier           as _carrier       on  $projection.AirlineId = _carrier.AirlineID
  association [0..1] to /DMO/I_Connection        as _connection    on  $projection.AirlineId    = _connection.AirlineID
                                                                   and $projection.ConnectionId = _connection.ConnectionID
  association [1..1] to /DMO/I_Booking_Status_VH as _bookingstatus on  $projection.BookingStatus = _bookingstatus.BookingStatus
{
  key booking_uuid          as BookingUuid,
      parent_uuid           as TravelUuid,
      booking_id            as BookingId,
      booking_date          as BookingDate,
      customer_id           as CustomerId,
      carrier_id            as AirlineId,
      connection_id         as ConnectionId,
      flight_date           as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price          as FlightPrice,
      currency_code         as CurrencyCode,
      booking_status        as BookingStatus,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      
      //Associations
      _Travel,
      _Bookingsupplement,
      _customer,
      _carrier,
      _connection,
      _bookingstatus
}

@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BOOKSUPPL VIEW ENTITY FOR DRAFT REFSEN'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZDR_R_BOOKINGSUPPLEMENT_D
  as select from /dmo/a_bksuppl_d
  association        to parent ZDR_R_BOOKING_D as _Booking        on $projection.bookingUuid = _Booking.BookingUuid
  association [1..1] to ZDR_R_TRAVEL_D         as _Travel         on $projection.TravelUuid = _Travel.TravelUuid
  association [1..1] to /DMO/I_Supplement      as _product        on $projection.SupplementId = _product.SupplementID
  association [1..*] to /DMO/I_SupplementText  as _supplementtext on $projection.SupplementId = _supplementtext.SupplementID

{
  key booksuppl_uuid        as BooksupplUuid,
      root_uuid             as TravelUuid,
      parent_uuid           as bookingUuid,
      booking_supplement_id as BookingSupplementId,
      supplement_id         as SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      //Associations
      _Booking,
      _Travel,
      _product,
      _supplementtext
}

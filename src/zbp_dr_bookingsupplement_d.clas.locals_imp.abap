CLASS lhc_ZDR_R_BOOKINGSUPPLEMENT_D DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zdr_r_bookingsupplement_d~calculateTotalPrice.

    METHODS SetBookSupplNumber FOR DETERMINE ON SAVE
      IMPORTING keys FOR zdr_r_bookingsupplement_d~SetBookSupplNumber.
    METHODS validateSupplement FOR VALIDATE ON SAVE
      IMPORTING keys FOR ZDR_R_BOOKINGSUPPLEMENT_D~validateSupplement.

ENDCLASS.

CLASS lhc_ZDR_R_BOOKINGSUPPLEMENT_D IMPLEMENTATION.

  METHOD calculateTotalPrice.
    READ ENTITIES OF zdr_r_travel_d IN LOCAL MODE
    ENTITY zdr_r_bookingsupplement_d BY \_Travel
           FIELDS ( TravelUUID )
           WITH CORRESPONDING #( keys )
           RESULT DATA(lt_travels).

    MODIFY ENTITIES OF zdr_r_travel_d IN LOCAL MODE
    ENTITY zdr_r_travel_d
    EXECUTE reCalcTotalPrice
    FROM CORRESPONDING #( lt_travels ).

  ENDMETHOD.

  METHOD SetBookSupplNumber.
    DATA : lv_max_bookingsupplementid   TYPE /dmo/booking_supplement_id,
           lt_bookingsupplements_update TYPE TABLE FOR UPDATE zdr_r_travel_d\\zdr_r_bookingsupplement_d.

    READ ENTITIES OF zdr_r_travel_d IN LOCAL MODE
    ENTITY zdr_r_bookingsupplement_d BY \_Booking
    FIELDS ( BookingUuid )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_bookings).

    LOOP AT lt_bookings INTO DATA(ls_booking).
      READ ENTITIES OF zdr_r_travel_d IN LOCAL MODE
      ENTITY zdr_r_booking_d BY \_Bookingsupplement
      FIELDS ( BookingSupplementId )
      WITH VALUE #( ( %tky = ls_booking-%tky ) )
      RESULT DATA(bookingsupplements).

      lv_max_bookingsupplementid = '00'.
      LOOP AT bookingsupplements INTO DATA(bookingsupplement).
        IF bookingsupplement-BookingSupplementId > lv_max_bookingsupplementid .
          lv_max_bookingsupplementid = bookingsupplement-BookingSupplementId.
        ENDIF.

        LOOP AT bookingsupplements INTO bookingsupplement WHERE BookingSupplementId IS INITIAL.
          lv_max_bookingsupplementid += 1.
          APPEND VALUE #( %tky = bookingsupplement-%tky
                          BookingSupplementId = lv_max_bookingsupplementid
                           ) TO lt_bookingsupplements_update.
        ENDLOOP.
      ENDLOOP.

      MODIFY ENTITIES OF zdr_r_travel_d IN LOCAL MODE
      ENTITY zdr_r_bookingsupplement_d
      UPDATE FIELDS ( BookingSupplementId ) WITH lt_bookingsupplements_update.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateSupplement.
  ENDMETHOD.

ENDCLASS.

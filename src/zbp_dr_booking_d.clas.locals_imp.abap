CLASS lhc_ZDR_R_BOOKING_D DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zdr_r_booking_d~calculateTotalPrice.

    METHODS SetBookingDate FOR DETERMINE ON SAVE
      IMPORTING keys FOR zdr_r_booking_d~SetBookingDate.

    METHODS SetBookingNumber FOR DETERMINE ON SAVE
      IMPORTING keys FOR zdr_r_booking_d~SetBookingNumber.
    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR zdr_r_booking_d~validateCustomer.

ENDCLASS.

CLASS lhc_ZDR_R_BOOKING_D IMPLEMENTATION.

  METHOD calculateTotalPrice.
    READ ENTITIES OF zdr_r_travel_d IN LOCAL MODE
          ENTITY zdr_r_booking_d BY \_Travel
          FIELDS ( TravelUUID )
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt_travels).

    IF lt_travels IS INITIAL.
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF zdr_r_travel_d IN LOCAL MODE
    ENTITY zdr_r_travel_d
    EXECUTE reCalcTotalPrice
    FROM CORRESPONDING #( lt_travels ).
  ENDMETHOD.

  METHOD SetBookingDate.
    READ ENTITIES OF zdr_r_travel_d IN LOCAL MODE
    ENTITY zdr_r_booking_d
    FIELDS ( BookingId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_bookings).

    DELETE lt_bookings WHERE BookingDate IS NOT INITIAL.
    IF lt_bookings IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_bookings ASSIGNING FIELD-SYMBOL(<booking>).
      <booking>-BookingDate = cl_abap_context_info=>get_system_date(  ).
    ENDLOOP.

    MODIFY ENTITIES OF zdr_r_travel_d IN LOCAL MODE
    ENTITY zdr_r_booking_d
    UPDATE FIELDS ( BookingDate )
    WITH CORRESPONDING #( lt_bookings ).

  ENDMETHOD.

  METHOD SetBookingNumber.
    DATA : lv_max_bookingid   TYPE /dmo/booking_id,
           lt_bookings_update TYPE TABLE FOR UPDATE zdr_r_travel_d\\zdr_r_booking_d.

    READ ENTITIES OF zdr_r_travel_d IN LOCAL MODE
    ENTITY zdr_r_booking_d BY \_Travel
    FIELDS ( TravelUUID )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travels).

    LOOP AT lt_travels INTO DATA(ls_travel).
      READ ENTITIES OF zdr_r_travel_d IN LOCAL MODE
      ENTITY zdr_r_travel_d BY \_booking
      FIELDS ( BookingId )
      WITH VALUE #( (  %tky = ls_travel-%tky ) )
      RESULT DATA(lt_bookings).

      lv_max_bookingid = '0000'.
      LOOP AT lt_bookings INTO DATA(booking).
        IF booking-BookingId > lv_max_bookingid.
          lv_max_bookingid = booking-BookingId.
        ENDIF.
      ENDLOOP.

      LOOP AT lt_bookings INTO booking WHERE BookingId IS INITIAL.
        lv_max_bookingid += 1.

        APPEND VALUE #( %tky = booking-%tky
                        bookingid = lv_max_bookingid
                         ) TO lt_bookings_update.
      ENDLOOP.
    ENDLOOP.
    MODIFY ENTITIES OF zdr_r_travel_d IN LOCAL MODE
    ENTITY zdr_r_booking_d
    UPDATE FIELDS ( BookingId )
    WITH lt_bookings_update.
  ENDMETHOD.

  METHOD validateCustomer.
    READ ENTITIES OF zdr_r_travel_d IN LOCAL MODE
    ENTITY zdr_r_booking_d
    FIELDS (  CustomerId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(bookings).

    READ ENTITIES OF zdr_r_travel_d IN LOCAL MODE
    ENTITY zdr_r_booking_d BY \_Travel
    FROM CORRESPONDING #( bookings )
    LINK DATA(travel_booking_links).

    DATA : customers TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    customers = CORRESPONDING #( bookings DISCARDING DUPLICATES MAPPING customer_id = CustomerId EXCEPT * ).
    DELETE customers WHERE customer_id IS INITIAL.

    IF customers IS NOT INITIAL.
      SELECT FROM /dmo/customer
      FIELDS customer_id
      FOR ALL ENTRIES IN @customers
      WHERE customer_id = @customers-customer_id
      INTO TABLE @DATA(valid_customers).
    ENDIF.
    LOOP AT bookings INTO DATA(booking).
      APPEND VALUE #( %tky = booking-%tky
                      %state_area = 'VALIDATE_CUSTOMER'
                       ) TO reported-zdr_r_booking_d.

      IF booking-CustomerId IS INITIAL.
        APPEND VALUE #( %tky = booking-%tky ) TO failed-zdr_r_booking_d.
        APPEND  VALUE #(
             %tky = booking-%tky
             %state_area = 'VALIDATE_CUSTOMER'
             %msg = NEW /dmo/cm_flight_messages( textid = /dmo/cm_flight_messages=>enter_customer_id
                                                 severity = if_abap_behv_message=>severity-error )
                                                 %path = VALUE #( zdr_r_travel_d-%tky = travel_booking_links[ KEY id source-%tky = booking-%tky ]-target-%tky )
                                                 %element-customerid = if_abap_behv=>mk-on ) TO reported-zdr_r_booking_d.

      ELSEIF booking-customerid IS NOT INITIAL AND NOT line_exists( valid_customers[ customer_id = booking-CustomerId  ] ) .
        APPEND VALUE #( %tky = booking-%tky ) TO failed-zdr_r_booking_d.

        APPEND VALUE #( %tky = booking-%tky
                        %state_area = 'VALIDATE_CUSTOMER'
                        %msg = NEW /dmo/cm_flight_messages(
                        textid = /dmo/cm_flight_messages=>enter_customer_id
                        customer_id = booking-CustomerId
                        severity = if_abap_behv_message=>severity-error )
                        %path = VALUE #(
                        zdr_r_travel_d-%tky = travel_booking_links[ KEY id source-%tky = booking-%tky ]-target-%tky )
                       %element-customerid = if_abap_behv=>mk-on ) TO reported-zdr_r_booking_d.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

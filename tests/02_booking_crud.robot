*** Settings ***
Library     RequestsLibrary
Library     Collections
Resource    ../resources/keywords.resource
Suite Setup    Run Keywords    Create Session To API    AND    Setup Suite
Suite Teardown    Teardown Suite

*** Variables ***
${BOOKING_ID}    ${EMPTY}
${TOKEN}         ${EMPTY}

*** Keywords ***
Setup Suite
    ${token}=    Get Auth Token
    Set Suite Variable    ${TOKEN}    ${token}
    ${id}=    Create Booking    Somchai    Jaidee    500    ${True}
    Set Suite Variable    ${BOOKING_ID}    ${id}

Teardown Suite
    Delete Booking    ${BOOKING_ID}    ${TOKEN}

*** Test Cases ***
TC01 - Get all bookings
    [Tags]    booking    smoke
    ${response}=    GET On Session    booker    /booking
    Should Be Equal As Strings    ${response.status_code}    200
    ${bookings}=    Set Variable    ${response.json()}
    Should Not Be Empty    ${bookings}

TC02 - Get single booking
    [Tags]    booking    smoke
    ${response}=    GET On Session    booker    /booking/${BOOKING_ID}
    Should Be Equal As Strings    ${response.status_code}    200
    ${booking}=    Set Variable    ${response.json()}
    Should Be Equal As Strings    ${booking}[firstname]    Somchai
    Should Be Equal As Strings    ${booking}[lastname]    Jaidee
    Dictionary Should Contain Key    ${booking}    firstname
    Dictionary Should Contain Key    ${booking}    lastname
    Dictionary Should Contain Key    ${booking}    totalprice
    Dictionary Should Contain Key    ${booking}    depositpaid
    Dictionary Should Contain Key    ${booking}    bookingdates
    Should Be True    isinstance(${booking}[totalprice], int) or isinstance(${booking}[totalprice], float)
    Should Be True    isinstance(${booking}[depositpaid], bool)

TC03 - Create booking
    [Tags]    booking    smoke
    ${id}=    Create Booking    John    Doe    300    ${False}
    Should Be True    ${id} > 0
    Delete Booking    ${id}    ${TOKEN}

TC04 - Update booking (PUT)
    [Tags]    booking    smoke
    ${headers}=    Create Dictionary    Cookie=token=${TOKEN}
    ${dates}=    Create Dictionary    checkin=2025-02-01    checkout=2025-02-10
    ${body}=    Create Dictionary
    ...    firstname=Updated
    ...    lastname=Name
    ...    totalprice=999
    ...    depositpaid=${True}
    ...    bookingdates=${dates}
    ...    additionalneeds=Lunch
    ${response}=    PUT On Session    booker    /booking/${BOOKING_ID}
    ...    json=${body}    headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    200
    Should Be Equal As Strings    ${response.json()}[firstname]    Updated

TC05 - Partial update booking (PATCH)
    [Tags]    booking    smoke
    ${headers}=    Create Dictionary    Cookie=token=${TOKEN}
    ${body}=    Create Dictionary    firstname=Patched
    ${response}=    PATCH On Session    booker    /booking/${BOOKING_ID}
    ...    json=${body}    headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    200
    Should Be Equal As Strings    ${response.json()}[firstname]    Patched

TC06 - Get booking that does not exist
    [Tags]    booking    negative
    ${response}=    GET On Session    booker    /booking/99999999
    ...    expected_status=any
    Should Be Equal As Strings    ${response.status_code}    404

TC07 - Delete booking without token
    [Tags]    booking    negative
    ${response}=    DELETE On Session    booker    /booking/${BOOKING_ID}
    ...    expected_status=any
    Should Be Equal As Strings    ${response.status_code}    403
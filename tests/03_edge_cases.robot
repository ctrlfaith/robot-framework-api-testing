*** Settings ***
Library     RequestsLibrary
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
    ${id}=    Create Booking    EdgeCase    Test    100    ${True}
    Set Suite Variable    ${BOOKING_ID}    ${id}

Teardown Suite
    Delete Booking    ${BOOKING_ID}    ${TOKEN}

*** Test Cases ***
TC01 - Create booking with missing required field
    [Tags]    edge    negative
    ${body}=    Create Dictionary    firstname=NoLastName    totalprice=100
    ${response}=    POST On Session    booker    /booking
    ...    json=${body}    expected_status=any
    Should Not Be Equal As Strings    ${response.status_code}    200

TC02 - Create booking with zero price
    [Tags]    edge    negative
    ${id}=    Create Booking    Zero    Price    0    ${True}
    Should Be True    ${id} > 0
    Delete Booking    ${id}    ${TOKEN}

TC03 - Create booking with very long name
    [Tags]    edge    negative
    ${long_name}=    Evaluate    'A' * 100
    ${id}=    Create Booking    ${long_name}    Test    100    ${True}
    Should Be True    ${id} > 0
    Delete Booking    ${id}    ${TOKEN}

TC04 - SQL injection in firstname
    [Tags]    edge    security
    ${id}=    Create Booking    ' OR '1'='1    Test    100    ${True}
    Should Be True    ${id} > 0
    Delete Booking    ${id}    ${TOKEN}

TC05 - XSS in firstname
    [Tags]    edge    security
    ${id}=    Create Booking    <script>alert('xss')</script>    Test    100    ${True}
    Should Be True    ${id} > 0
    Delete Booking    ${id}    ${TOKEN}

TC06 - Update booking with expired/invalid token
    [Tags]    edge    security
    ${headers}=    Create Dictionary    Cookie=token=invalidtoken123
    ${dates}=    Create Dictionary    checkin=2025-01-01    checkout=2025-01-10
    ${body}=    Create Dictionary
    ...    firstname=Hacker
    ...    lastname=Test
    ...    totalprice=1
    ...    depositpaid=${False}
    ...    bookingdates=${dates}
    ...    additionalneeds=None
    ${response}=    PUT On Session    booker    /booking/${BOOKING_ID}
    ...    json=${body}    headers=${headers}    expected_status=any
    Should Be Equal As Strings    ${response.status_code}    403

TC07 - Delete booking with invalid token
    [Tags]    edge    security
    ${headers}=    Create Dictionary    Cookie=token=invalidtoken123
    ${response}=    DELETE On Session    booker    /booking/${BOOKING_ID}
    ...    headers=${headers}    expected_status=any
    Should Be Equal As Strings    ${response.status_code}    403

TC08 - Health check endpoint
    [Tags]    edge    smoke
    ${response}=    GET On Session    booker    /ping
    Should Be Equal As Strings    ${response.status_code}    201

TC09 - Create booking with invalid date format
    [Tags]    edge    bug
    ${dates}=    Create Dictionary    checkin=not-a-date    checkout=also-not-a-date
    ${body}=    Create Dictionary
    ...    firstname=Test
    ...    lastname=User
    ...    totalprice=100
    ...    depositpaid=${True}
    ...    bookingdates=${dates}
    ...    additionalneeds=None
    ${response}=    POST On Session    booker    /booking    json=${body}
    Should Be Equal As Strings    ${response.status_code}    200
    Log    BUG: API accepts invalid date format - checkin: ${response.json()}[booking][bookingdates][checkin]    WARN

TC10 - Create booking with negative price
    [Tags]    edge    bug
    ${dates}=    Create Dictionary    checkin=2025-06-01    checkout=2025-06-07
    ${body}=    Create Dictionary
    ...    firstname=Test
    ...    lastname=User
    ...    totalprice=-999
    ...    depositpaid=${True}
    ...    bookingdates=${dates}
    ...    additionalneeds=None
    ${response}=    POST On Session    booker    /booking    json=${body}
    Should Be Equal As Strings    ${response.status_code}    200
    Log    BUG: API accepts negative price - totalprice: ${response.json()}[booking][totalprice]    WARN

TC11 - Create booking with checkout before checkin
    [Tags]    edge    bug
    ${dates}=    Create Dictionary    checkin=2025-12-31    checkout=2025-01-01
    ${body}=    Create Dictionary
    ...    firstname=Test
    ...    lastname=User
    ...    totalprice=100
    ...    depositpaid=${True}
    ...    bookingdates=${dates}
    ...    additionalneeds=None
    ${response}=    POST On Session    booker    /booking    json=${body}
    Should Be Equal As Strings    ${response.status_code}    200
    Log    BUG: API accepts checkout before checkin    WARN

TC12 - Get booking with string ID
    [Tags]    edge    negative
    ${response}=    GET On Session    booker    /booking/abc
    ...    expected_status=any
    Should Be Equal As Strings    ${response.status_code}    404

TC13 - Create booking with missing fields returns 500
    [Tags]    edge    bug
    ${body}=    Create Dictionary    firstname=NoLastName    totalprice=100
    ${response}=    POST On Session    booker    /booking
    ...    json=${body}    expected_status=any
    Should Be Equal As Strings    ${response.status_code}    500
    Log    BUG: Missing required fields returns 500 Internal Server Error instead of 400 Bad Request    WARN
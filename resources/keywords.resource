*** Settings ***
Library     RequestsLibrary
Resource    variables.resource

*** Keywords ***
Create Session To API
    Create Session    booker    ${BASE_URL}    verify=true

Get Auth Token
    ${body}=    Create Dictionary    username=${USERNAME}    password=${PASSWORD}
    ${response}=    POST On Session    booker    /auth    json=${body}
    Should Be Equal As Strings    ${response.status_code}    200
    ${token}=    Set Variable    ${response.json()}[token]
    RETURN    ${token}

Create Booking
    [Arguments]    ${firstname}    ${lastname}    ${totalprice}    ${depositpaid}
    ${dates}=    Create Dictionary    checkin=2025-01-01    checkout=2025-01-10
    ${body}=    Create Dictionary
    ...    firstname=${firstname}
    ...    lastname=${lastname}
    ...    totalprice=${totalprice}
    ...    depositpaid=${depositpaid}
    ...    bookingdates=${dates}
    ...    additionalneeds=Breakfast
    ${response}=    POST On Session    booker    /booking    json=${body}
    Should Be Equal As Strings    ${response.status_code}    200
    RETURN    ${response.json()}[bookingid]

Delete Booking
    [Arguments]    ${booking_id}    ${token}
    ${headers}=    Create Dictionary    Cookie=token=${token}
    ${response}=    DELETE On Session    booker    /booking/${booking_id}    headers=${headers}
    Should Be Equal As Strings    ${response.status_code}    201
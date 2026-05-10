*** Settings ***
Library     RequestsLibrary
Resource    ../resources/keywords.resource
Suite Setup    Create Session To API

*** Test Cases ***
TC01 - Get auth token successfully
    [Tags]    auth    smoke
    ${token}=    Get Auth Token
    Should Not Be Empty    ${token}
    Log    Token: ${token}

TC02 - Auth with invalid credentials
    [Tags]    auth    negative
    ${body}=    Create Dictionary    username=wrong    password=wrong
    ${response}=    POST On Session    booker    /auth    json=${body}
    Should Be Equal As Strings    ${response.status_code}    200
    ${body_text}=    Set Variable    ${response.text}
    Should Contain    ${body_text}    Bad credentials
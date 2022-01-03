*** Settings ***
Documentation     Order robots from RobotSpareBin Industries Inc
Library           RPA.Browser
Library           RPA.FileSystem
Library           RPA.HTTP
Library           RPA.Tables
Library           Dialogs
Library           RPA.PDF
Library           RPA.Robocloud.Secrets
Library           RPA.core.notebook
Library           RPA.Archive

*** Keywords ***
Open the robot order website
  ${website}=   Get Secret  websitedata
  Open Available Browser   ${website}[url]
  Maximize Browser Window


*** Keywords ***
Download Csv File
  ${csv_url}=  Get Value From User   Please enter the csv url   https://robotsparebinindustries.com/orders.csv
  Download  ${csv_url}   orders.csv

*** Keywords ***
Fill the orders
   [Arguments]   ${order_file}
   Select From List By Value     id:head  ${order_file}[Head]
   Click Element  id-body-${order_file}[Body]
   Wait Until Element Is Enabled  xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input  
   Input Text  xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input  ${order_file}[Legs]
   Wait Until Element Is Enabled    id:address
   Input Text     id:address    ${order_file}[Address]
   Wait Until Element Is Enabled    id:preview
   Click Button    id:preview
   Sleep    3 seconds
   Click Button  id:order
   Sleep  3
   ${error} =    Is Element Enabled    order
   IF    ${error}
        Click Button    order
        Sleep    5
   END
    ${error} =    Is Element Enabled    order
    IF    ${error}
        Click Button    order
        Sleep    5
        ${error} =    Is Element Enabled    order
    END
    ${error} =    Is Element Enabled    order
    IF    ${error}
        Click Button    order
        Sleep    5
    END
    ${error} =    Is Element Enabled    order
    IF    ${error}
        Click Button    order
        Sleep    5
    END

*** Keywords ***
Fill the form
    Click Button    OK
    ${order}=    Read table from CSV     orders.csv    
     FOR    ${order_file}    IN    @{order}
            Fill the orders    ${order_file}
            Take a screenshot of robot    ${order_file}
     END

*** Keywords ***
Take a screenshot of robot
  [Arguments]  ${order_file}
  Sleep  2 Seconds
  Screenshot  id:robot-preview-image  ${CURDIR}${/}robots${/}${order_file}[Order number].png
  Sleep  2 seconds
  Wait Until Element Is Visible    id:order-completion
  ${reciept_data}=    Get Element Attribute    id:order-completion    outerHTML
  Html To Pdf    ${reciept_data}    ${CURDIR}${/}output${/}${order_file}[Order number].pdf
  Click Button  id:order-another
  Click Button   OK

*** Keywords ***
Zip File
  Archive Folder With Zip  ${CURDIR}${/}output  reciepts.zip  recursive=True  include=*.pdf  exclude=/.*



*** Tasks ***
Order robots from RobotSpareBin Industries Inc
     Open the robot order website
     Download Csv file
     Fill the form
     Zip File
     [Teardown]  Close Browser






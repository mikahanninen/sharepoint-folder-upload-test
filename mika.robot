*** Settings ***
Library     RPA.FileSystem
Library     OperatingSystem
Library     RPA.Browser.Selenium
Library     RPA.Robocorp.Vault
Library     String


*** Variables ***
${SUBFOLDER}                    Robotfiles
${FILENAME}                     %{FILE_TO_UPLOAD=test8.txt}
${TEMPFOLDER}                   ${EXECDIR}${/}${SUBFOLDER}
${VACCINATION_CARD_FOLDER}      https://beissi.sharepoint.com/SiteAssets/Forms/AllItems.aspx
${USERNAME_MAIL}                ---
${PASSWORD_MAIL}                ---
${MAX_UPLOAD_TIME}              30s


*** Tasks ***
Test Robot by Mika
    RPA.FileSystem.Create Directory    ${TEMPFOLDER}
    RPA.FileSystem.Create File    ${TEMPFOLDER}${/}${FILENAME}    This is a testfile    overwrite=True
    Sleep    3s
    Open Base Folder
    Upload Folder


*** Keywords ***
Open Base Folder
    ${secrets}=    Get Secret    sharepoint
    Open Available Browser    ${VACCINATION_CARD_FOLDER}
    Input Text When Element Is Visible    id:i0116    ${secrets}[user]
    RPA.Browser.Selenium.Press Keys    id:i0116    RETURN
    Input Text When Element Is Visible    id:i0118    ${secrets}[pass]
    RPA.Browser.Selenium.Press Keys    id:i0118    RETURN
    # Following 2 keywords are needed if security is asking if
    # authentication should be remembered
    Run Keyword And Ignore Error    Click Element When Visible    id:KmsiCheckboxField
    Run Keyword And Ignore Error    Click Element When Visible    id:idSIButton9

Does Sharepoint Folder Exist
    [Arguments]    ${folder_name_to_find}
    @{folders}=    Get WebElements    //div[@data-automationid="ListCell"]//div[@data-automationid="DetailsRow"]
    ${do_folder_upload}=    Set Variable    ${TRUE}
    FOR    ${f}    IN    @{folders}
        ${data}=    Evaluate    $f.get_attribute("aria-label")
        ${folder_name}    ${post}=    Split String    ${data}    ,    1
        IF    "${folder_name}" == "${folder_name_to_find}"    RETURN    ${f}
    END
    RETURN    ${NONE}

Upload Folder
    Sleep    3s
    ${folder}=    Does Sharepoint Folder Exist    ${SUBFOLDER}
    IF    ${folder}
        ${rowindex}=    Evaluate    $folder.get_attribute("aria-rowindex")
        Click Element    //div[@aria-rowindex="${rowindex}"]//div[@aria-colindex="3"]//button
        Sleep    3s
        Sharepoint Upload    Files    commandFileInput    ${TEMPFOLDER}${/}${FILENAME}
    ELSE
        Create Sharepoint Folder    ${SUBFOLDER}
        Sleep    1s
        ${folder}=    Does Sharepoint Folder Exist    ${SUBFOLDER}
        IF    ${folder}
            ${rowindex}=    Evaluate    $folder.get_attribute("aria-rowindex")
            Click Element    //div[@aria-rowindex="${rowindex}"]//div[@aria-colindex="3"]//button
            Sleep    3s
            Sharepoint Upload    Files    commandFileInput    ${TEMPFOLDER}${/}${FILENAME}
        END
        #Sharepoint Upload    Folder    commandFolderInput    ${TEMPFOLDER}
    END
    Sleep    3s
    RPA.Browser.Selenium.Screenshot
    ${count}=    Get Element Count    //span[contains(text(),'Replace')]
    IF    ${count}    Click Element    //span[contains(text(),'Replace')]
    Sleep    ${MAX_UPLOAD_TIME}

Sharepoint Upload
    [Arguments]    ${uploadtype}    ${uploadinput}    ${uploadname}
    Log    Uploading:${uploadname}
    RPA.Browser.Selenium.Click Element    //span[contains(text(),'Upload')]
    Sleep    1s
    RPA.Browser.Selenium.Click Element    //span[contains(text(),'${uploadtype}')]
    Sleep    1s
    ${folderinput}=    Get WebElement    //input[@data-automationid='${uploadinput}']
    Call Method    ${folder_input}    send_keys    ${uploadname}
    #Evaluate    $folderinput.send_keys("${PAYLOAD}")

Create Sharepoint Folder
    [Arguments]    ${folder_name}
    RPA.Browser.Selenium.Click Element    //span[contains(text(),'New')]
    Sleep    1s
    RPA.Browser.Selenium.Click Element    //span[contains(text(),'Folder')]
    Sleep    1s
    Input Text When Element Is Visible
    ...    //input[@aria-label="Enter your folder name"]
    ...    ${folder_name}
    RPA.Browser.Selenium.Press Keys    //input[@aria-label="Enter your folder name"]    RETURN

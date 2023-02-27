Import-Module $PSScriptRoot\..\AkamaiPowershell.psm1 -DisableNameChecking -Force
# Setup shared variables
$Script:EdgeRCFile = $env:PesterEdgeRCFile
$Script:SafeEdgeRCFile = $env:PesterSafeEdgeRCFile
$Script:Section = 'default'
$Script:TestConfigID = 88541
$Script:TestConfigVersion = 1
$Script:TestPolicyID = 'DEF1_196240'
$Script:TestCustomBotCategoryName = 'AkamaiPowerShellBots'
$Script:TestCustomBotJson = '{"botName":"CHANGEME","categoryId":"CHANGEME","conditions":[{"name":["ImABadBot"],"nameWildcard":true,"positiveMatch":true,"type":"requestHeaderCondition","value":["true"],"valueCase":false,"valueWildcard":true}]}'
$Script:TestCustomBot = ConvertFrom-Json $TestCustomBotJson
$Script:TestCustomBotName = 'AkamaiPowerShellBot'
$TestCustomBot.botName = $TestCustomBotName
$Script:TestCustomClientJson = '{"customClientName":"CHANGEME","customClientType":"NATIVE_APP","requestConditions":[{"name":["ImAGoodBoy"],"nameWildcard":true,"positiveMatch":true,"type":"requestHeaderCondition","value":["true"],"valueCase":false,"valueWildcard":true}]}'
$Script:TestCustomClient = ConvertFrom-Json $TestCustomClientJson
$Script:TestCustomClientName = 'AkamaiPowerShellCustomClient'
$TestCustomClient.customClientName = $TestCustomClientName
$Script:TestBotCategoryExceptionsJson = '{"akamaiBotCategoryIds":[],"customBotCategoryIds":[]}'
$Script:TestBotCategoryExceptions = ConvertFrom-Json $TestBotCategoryExceptionsJson
$Script:TestTransactionalEndpointJson = '{"apiEndPointId":817948,"operationId":"23e48e4a-82a5-4dce-90c6-d7760604a1e2","telemetryTypeStates":{"inline":{"enabled":false},"nativeSdk":{"disabledAction":"monitor","enabled":false},"standard":{"enabled":true}},"traffic":{"standardTelemetry":{"aggressiveAction":"deny","overrideThresholds":false,"strictAction":"monitor"}}}'
$Script:TestTransactionalEndpoint = ConvertFrom-Json $TestTransactionalEndpointJson
$Script:TestCustomDenyActionJson = '{"actionName":"AkamaiPowerShellCustomDeny","customResponseBody":"{\"no\":\"badboy\"}","preventBrowserCaching":true,"responseContentType":"application/json","responseStatusCode":403}'
$Script:TestCustomDenyAction = ConvertFrom-Json $TestCustomDenyActionJson
$Script:TestConditionalActionJson = '{"actionId":"cond_action_113164","actionName":"AkamaiPowerShellConditionalAction","conditionalActionRules":[{"action":"slow","conditions":[{"name":["TheKids"],"nameWildcard":true,"positiveMatch":true,"type":"requestHeaderCondition","value":["alright"],"valueCase":true,"valueWildcard":true}],"percentageOfTraffic":100}],"defaultAction":"monitor"}'
$Script:TestConditionalAction = ConvertFrom-Json $TestConditionalActionJson
$Script:TestServeAlternateActionJson = '{"actionId":"serve_alt_113170","actionName":"AkamaiPowershellServeAlternateAction","addAkamaiReferenceId":true,"alternateHostname":"deny.akamaipowershell-testing.edgesuite.net"}'
$Script:TestServeAlternateAction = ConvertFrom-Json $TestServeAlternateActionJson
$Script:TestChallengeActionJson = '{"actionId":"challenge_113171","actionName":"AkamaiPowerShellChallengeAction","challengeIntervalInSeconds":300,"challengeType":"GOOGLE_RECAPTCHA","googleReCaptchaSiteKey":"12345","googleReCaptchaSecretKey":"12345"}'
$Script:TestChallengeAction = ConvertFrom-Json $TestChallengeActionJson

Describe 'Safe Botman Tests' {

    BeforeDiscovery {
        
    }

    #------------------------------------------------#
    #             Akamai Bot Categories              #
    #------------------------------------------------#

    ### List-BotManAkamaiBotCategories
    $Script:AkamaiBotCategories = List-BotManAkamaiBotCategories -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-BotManAkamaiBotCategories returns a list' {
        $AkamaiBotCategories.count | Should -Not -Be 0
    }

    ### Get-BotManAkamaiBotCategory
    $Script:AkamaiBotCategory = Get-BotManAkamaiBotCategory -CategoryID $AkamaiBotCategories[0].categoryId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-BotManAkamaiBotCategory returns the correct data' {
        $AkamaiBotCategory.categoryId | Should -Be $AkamaiBotCategories[0].categoryId
    }

    #------------------------------------------------#
    #              Akamai Defined Bots               #
    #------------------------------------------------#

    ### List-BotManAkamaiDefinedBots
    $Script:AkamaiDefinedBots = List-BotManAkamaiDefinedBots -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-BotManAkamaiDefinedBots returns a list' {
        $AkamaiDefinedBots.count | Should -Not -Be 0
    }

    ### Get-BotManAkamaiDefinedBot
    $Script:AkamaiDefinedBot = Get-BotManAkamaiDefinedBot -BotID $AkamaiDefinedBots[0].botId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-BotManAkamaiDefinedBot returns a list' {
        $AkamaiDefinedBot.botId | Should -Be $AkamaiDefinedBots[0].botId
    }

    #------------------------------------------------#
    #          Akamai Bot Category Actions           #
    #------------------------------------------------#

    ### List-AppSecPolicyAkamaiBotCategoryActions
    $Script:BotCategoryActions = List-AppSecPolicyAkamaiBotCategoryActions -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -PolicyID $TestPolicyID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecPolicyAkamaiBotCategoryActions returns a list' {
        $BotCategoryActions.count | Should -Not -Be 0
    }

    ### Get-AppSecPolicyAkamaiBotCategoryAction
    $Script:BotCategoryAction = Get-AppSecPolicyAkamaiBotCategoryAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -PolicyID $TestPolicyID -CategoryID $BotCategoryActions[0].categoryId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecPolicyAkamaiBotCategoryAction returns the correct data' {
        $BotCategoryAction.categoryId | Should -Be $BotCategoryActions[0].categoryId
    }

    ### Set-AppSecPolicyAkamaiBotCategoryAction
    $Script:SetBotCategoryAction = Set-AppSecPolicyAkamaiBotCategoryAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -PolicyID $TestPolicyID -CategoryID $BotCategoryActions[0].categoryId -Action deny -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecPolicyAkamaiBotCategoryAction returns the correct data' {
        $SetBotCategoryAction.categoryId | Should -Be $BotCategoryActions[0].categoryId
    }

    #------------------------------------------------#
    #             Custom Bot Categories              #
    #------------------------------------------------#

    ### New-BotManCustomBotCategory
    $Script:NewCustomBotCategory = New-BotManCustomBotCategory -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -CategoryName $TestCustomBotCategoryName -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-BotManCustomBotCategory returns the correct data' {
        $NewCustomBotCategory.categoryName | Should -Be $TestCustomBotCategoryName
    }

    ### List-BotManCustomBotCategories
    $Script:CustomBotCategories = List-BotManCustomBotCategories -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-BotManCustomBotCategories returns a list' {
        $CustomBotCategories | Should -Not -BeNullOrEmpty
    }

    ### Get-BotManCustomBotCategory
    $Script:CustomBotCategory = Get-BotManCustomBotCategory -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -CategoryID $NewCustomBotCategory.categoryId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-BotManCustomBotCategory returns the correct data' {
        $CustomBotCategory.categoryId | Should -Be $NewCustomBotCategory.categoryId
    }

    ### Set-BotManCustomBotCategory
    $Script:SetCustomBotCategory = ($CustomBotCategory | Set-BotManCustomBotCategory -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -CategoryID $NewCustomBotCategory.categoryId -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-BotManCustomBotCategory updates successfully' {
        $SetCustomBotCategory.categoryId | Should -Be $NewCustomBotCategory.categoryId
    }

    #------------------------------------------------#
    #       Recategorized Akamai-defined Bots        #
    #------------------------------------------------#

    ### Move-BotManAkamaiDefinedBot
    $Script:RecategorizedBot = Move-BotManAkamaiDefinedBot -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -BotID $AkamaiDefinedBots[0].botId -CustomBotCategoryID $CustomBotCategory.categoryId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Move-BotManAkamaiDefinedBot moves successfully' {
        $RecategorizedBot.customBotCategoryId | Should -Be $CustomBotCategory.categoryId
    }

    ### List-BotManRecategorizedAkamaiDefinedBots
    $Script:RecategorizedBots = List-BotManRecategorizedAkamaiDefinedBots -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-BotManRecategorizedAkamaiDefinedBots returns a list with the correct data' {
        $RecategorizedBots[0].botId | Should -Not -BeNullOrEmpty
    }

    ### Get-BotManRecategorizedAkamaiDefinedBot
    $Script:RecategorizedBot = Get-BotManRecategorizedAkamaiDefinedBot -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -BotID $RecategorizedBots[0].botId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-BotManRecategorizedAkamaiDefinedBot returns the correct bot ID' {
        $RecategorizedBot.botId | Should -Be $RecategorizedBots[0].botId
    }

    ### Move-BotManRecategorizedAkamaiDefinedBot
    $Script:MovedRecategorizedBot = Move-BotManRecategorizedAkamaiDefinedBot -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -BotID $RecategorizedBots[0].botId -CustomBotCategoryID $CustomBotCategory.categoryId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Move-BotManRecategorizedAkamaiDefinedBot returns the correct category' {
        $MovedRecategorizedBot.customBotCategoryId | Should -Be $CustomBotCategory.categoryId
    }

    ### Remove-BotManRecategorizedAkamaiDefinedBot
    it 'Remove-BotManRecategorizedAkamaiDefinedBot removes successfully' {
        { Remove-BotManRecategorizedAkamaiDefinedBot -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -BotID $RecategorizedBot.botId -EdgeRCFile $EdgeRCFile -Section $Section } | Should -Not -Throw
    }

    #------------------------------------------------#
    #             Custom-Defined Bots                #
    #------------------------------------------------#

    ### New-BotManCustomDefinedBot
    $TestCustomBot.categoryId = $NewCustomBotCategory.categoryId
    $Script:NewCustomBot = New-BotManCustomDefinedBot -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -Bot $TestCustomBot -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-BotManCustomDefinedBot returns the correct name' {
        $NewCustomBot.botName | Should -Be $TestCustomBotName
    }

    ### List-BotManCustomDefinedBots
    $Script:CustomBots = List-BotManCustomDefinedBots -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-BotManCustomBotCategories returns a list' {
        $CustomBots[0].botId | Should -Not -BeNullOrEmpty
    }

    ### Get-BotManCustomDefinedBot
    $Script:CustomBot = Get-BotManCustomDefinedBot -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -BotID $NewCustomBot.botID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-BotManCustomDefinedBot returns the correct bot' {
        $CustomBot.botId | Should -Be $NewCustomBot.botID
    }

    ### Set-BotManCustomDefinedBot
    $Script:SetCustomBot = ($NewCustomBot | Set-BotManCustomDefinedBot -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -BotID $NewCustomBot.botID -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-BotManCustomDefinedBot updates correctly' {
        $SetCustomBot.botId | Should -Be $NewCustomBot.botID
    }

    ### Remove-BotManCustomDefinedBot
    it 'Remove-BotManCustomDefinedBot removes successfully' {
        { Remove-BotManCustomDefinedBot -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -BotID $NewCustomBot.botID -EdgeRCFile $EdgeRCFile -Section $Section } | Should -Not -Throw
    }

    #------------------------------------------------#
    #          Custom Bot Category Actions           #
    #------------------------------------------------#

    ### List-AppSecPolicyCustomBotCategoryActions
    $Script:CustomBotCategoryActions = List-AppSecPolicyCustomBotCategoryActions -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -PolicyID $TestPolicyID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecPolicyAkamaiBotCategoryActions returns a list' {
        $CustomBotCategoryActions[0].action | Should -Not -BeNullOrEmpty
    }

    ### Get-AppSecPolicyCustomBotCategoryAction
    $Script:CustomBotCategoryAction = Get-AppSecPolicyCustomBotCategoryAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -PolicyID $TestPolicyID -CategoryID $CustomBotCategoryActions[0].categoryId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecPolicyCustomBotCategoryAction returns the correct data' {
        $CustomBotCategoryAction.categoryId | Should -Be $CustomBotCategoryActions[0].categoryId
    }

    ### Set-AppSecPolicyAkamaiBotCategoryAction
    $Script:SetCustomBotCategoryAction = Set-AppSecPolicyCustomBotCategoryAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -PolicyID $TestPolicyID -CategoryID $CustomBotCategoryActions[0].categoryId -Action deny -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecPolicyAkamaiBotCategoryAction returns the correct data' {
        $SetCustomBotCategoryAction.categoryId | Should -Be $CustomBotCategoryActions[0].categoryId
    }

    #------------------------------------------------#
    #          Custom Bot Category Sequence          #
    #------------------------------------------------#

    ### Get-BotManCustomBotCategorySequence
    $Script:CustomBotCategorySequence = Get-BotManCustomBotCategorySequence -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-BotManCustomBotCategorySequence returns the correct data' {
        $CustomBotCategorySequence.sequence | Should -Not -BeNullOrEmpty
    }

    ### Set-BotManCustomBotCategorySequence
    $Script:SetCustomBotCategorySequence = ($CustomBotCategorySequence | Set-BotManCustomBotCategorySequence -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-BotManCustomBotCategorySequence updates correctly' {
        $CustomBotCategorySequence.sequence | Should -Not -BeNullOrEmpty
    }

    #------------------------------------------------#
    #                Custom Clients                  #
    #------------------------------------------------#

    ### New-BotManCustomClient
    $Script:NewCustomClient = New-BotManCustomClient -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -CustomClient $TestCustomClient -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-BotManCustomClient returns the correct data' {
        $NewCustomClient.customClientName | Should -Be $TestCustomClientName
    }

    ### List-BotManCustomClients
    $Script:CustomClients = List-BotManCustomClients -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-BotManCustomClients returns a list' {
        $CustomClients | Should -Not -BeNullOrEmpty
    }

    ### Get-BotManCustomClient
    $Script:CustomClient = Get-BotManCustomClient -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -CustomClientID $NewCustomClient.customClientId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-BotManCustomClient returns the correct data' {
        $CustomClient.customClientId | Should -Be $NewCustomClient.customClientId
    }

    ### Set-BotManCustomClient
    $Script:SetCustomClient = ($CustomClient | Set-BotManCustomClient -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -CustomClientID $NewCustomClient.customClientId -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-BotManCustomClient updates successfully' {
        $SetCustomClient.customClientId | Should -Be $NewCustomClient.customClientId
    }

    ### Remove-BotManCustomClient
    it 'Remove-BotManCustomClient removes successfully' {
        { Remove-BotManCustomClient -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -CustomClientID $NewCustomClient.customClientId -EdgeRCFile $EdgeRCFile -Section $Section} | Should -Not -Throw
    }

    #------------------------------------------------#
    #             Client Side Security               #
    #------------------------------------------------#

    ### Get-BotManClientSideSecurity
    $Script:ClientSideSecurity = Get-BotManClientSideSecurity -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-BotManClientSideSecurity returns the correct data' {
        $ClientSideSecurity.useSameSiteCookies | Should -Not -BeNullOrEmpty
    }

    ### Set-BotManClientSideSecurity
    $Script:SetClientSideSecurity = ($ClientSideSecurity | Set-BotManClientSideSecurity -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-BotManClientSideSecurity updates correctly' {
        $SetClientSideSecurity.useSameSiteCookies | Should -Be $ClientSideSecurity.useSameSiteCookies
    }

    #------------------------------------------------#
    #        Bot Analytics Cookie Settings           #
    #------------------------------------------------#

    # ### Get-BotManBotAnalyticsCookieSettings
    # $Script:BotAnalyticsCookieSettings = Get-BotManBotAnalyticsCookieSettings -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    # it 'Get-BotManBotAnalyticsCookieSettings returns the correct data' {
    #     $BotAnalyticsCookieSettings.enableBotSignal | Should -Not -BeNullOrEmpty
    # }

    # ### Set-BotManBotAnalyticsCookieSettings
    # $Script:SetBotAnalyticsCookieSettings = ($BotAnalyticsCookieSettings | Set-BotManBotAnalyticsCookieSettings -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section)
    # it 'Set-BotManBotAnalyticsCookieSettings updates correctly' {
    #     $SetBotAnalyticsCookieSettings.enableBotSignal | Should -Be $BotAnalyticsCookieSettings.enableBotSignal
    # }

    #------------------------------------------------#
    #         Bot Analytics Cookie Values            #
    #------------------------------------------------#

    # ### Get-BotManBotAnalyticsCookieValues
    # $Script:BotAnalyticsCookieValues = Get-BotManBotAnalyticsCookieValues -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    # it 'Get-BotManBotAnalyticsCookieValues returns the correct data' {
    #     $BotAnalyticsCookieValues.count | Should -Not -Be 0
    # }

    # ### Update-BotManBotAnalyticsCookieValues
    # $Script:NewBotAnalyticsCookieValues = Update-BotManBotAnalyticsCookieValues -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    # it 'Update-BotManBotAnalyticsCookieValues returns the correct data' {
    #     $NewBotAnalyticsCookieValues.count | Should -Not -Be 0
    # }

    #------------------------------------------------#
    #           Bot Category Exceptions              #
    #------------------------------------------------#

    ### Set-AppSecPolicyBotCategoryExceptions
    $TestBotCategoryExceptions.customBotCategoryIds += $NewCustomBotCategory.categoryId
    $Script:SetBotCategoryExceptions = ($TestBotCategoryExceptions | Set-AppSecPolicyBotCategoryExceptions -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -PolicyID $TestPolicyID -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecPolicyBotCategoryExceptions returns the correct data' {
        $SetBotCategoryExceptions.customBotCategoryIds | Should -Not -BeNullOrEmpty
    }

    ### List-AppSecPolicyBotCategoryExceptions
    $Script:BotCategoryExceptions = List-AppSecPolicyBotCategoryExceptions -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -PolicyID $TestPolicyID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecPolicyBotCategoryExceptions returns the correct data' {
        $BotCategoryExceptions.customBotCategoryIds | Should -Not -BeNullOrEmpty
    }

    #------------------------------------------------#
    #               Bot Detections                   #
    #------------------------------------------------#

    ### List-BotManBotDetections
    $Script:BotDetections = List-BotManBotDetections -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-BotManBotDetections returns a list' {
        $BotDetections.count | Should -Not -Be 0
    }

    ### Get-BotManBotDetection
    $Script:BotDetection = Get-BotManBotDetection -DetectionID $BotDetections[0].detectionId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-BotManBotDetection returns the correct data' {
        $BotDetection.detectionId | Should -Be $BotDetections[0].detectionId
    }

    #------------------------------------------------#
    #            Bot Detection Actions               #
    #------------------------------------------------#

    ### List-AppSecPolicyBotDetectionActions
    $Script:BotDetectionActions = List-AppSecPolicyBotDetectionActions -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -PolicyID $TestPolicyID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecPolicyBotDetectionActions returns a list' {
        $BotDetectionActions.count | Should -Not -Be 0
    }

    ### Get-AppSecPolicyBotDetectionAction
    $Script:BotDetectionAction = Get-AppSecPolicyBotDetectionAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -PolicyID $TestPolicyID -DetectionID $BotDetectionActions[0].detectionId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecPolicyBotDetectionAction returns the correct data' {
        $BotDetectionAction.detectionId | Should -Be $BotDetectionActions[0].detectionId
    }

    ### Set-AppSecPolicyBotDetectionAction
    $Script:SetBotDetectionAction = ($BotDetectionAction | Set-AppSecPolicyBotDetectionAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -PolicyID $TestPolicyID -DetectionID $BotDetectionAction.detectionId -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecPolicyBotDetectionAction returns the correct data' {
        $SetBotDetectionAction.detectionId | Should -Be $BotDetectionAction.detectionId
    }

    #------------------------------------------------#
    #        Bot Endpoint Coverage Reports           #
    #------------------------------------------------#

    ### List-BotManBotEndpointCoverageReports
    $Script:BotEndpointCoverageReports = List-BotManBotEndpointCoverageReports -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-BotManBotEndpointCoverageReports returns the correct data' {
        $BotEndpointCoverageReports.validation | Should -Not -BeNullOrEmpty
    }

    ### Get-BotManConfigBotEndpointCoverageReport
    $Script:BotEndpointCoverageReport = Get-BotManConfigBotEndpointCoverageReport -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-BotManConfigBotEndpointCoverageReport returns the correct data' {
        $BotEndpointCoverageReport.validation | Should -Not -BeNullOrEmpty
    }

    #------------------------------------------------#
    #            Bot Management Settings             #
    #------------------------------------------------#

    ### List-AppSecPolicyBotManagementSettings
    $Script:BotManagementSettings = List-AppSecPolicyBotManagementSettings -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -PolicyID $TestPolicyID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecPolicyBotManagementSettings returns the correct data' {
        $BotManagementSettings.enableBotManagement | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPolicyBotManagementSettings
    $Script:SetBotManagementSettings = ($BotManagementSettings | Set-AppSecPolicyBotManagementSettings -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -PolicyID $TestPolicyID -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecPolicyBotManagementSettings returns the correct data' {
        $SetBotManagementSettings.enableBotManagement | Should -Be $BotManagementSettings.enableBotManagement
    }

    #------------------------------------------------#
    #           Javascript Injection Rules           #
    #------------------------------------------------#

    ### List-AppSecPolicyJavascriptInjection
    $Script:JavascriptInjection = List-AppSecPolicyJavascriptInjection -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -PolicyID $TestPolicyID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecPolicyJavascriptInjection returns the correct data' {
        $JavascriptInjection.injectJavaScript | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPolicyJavascriptInjection
    $Script:SetJavascriptInjection = ($JavascriptInjection | Set-AppSecPolicyJavascriptInjection -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -PolicyID $TestPolicyID -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecPolicyJavascriptInjection returns the correct data' {
        $SetJavascriptInjection.injectJavaScript | Should -Be $JavascriptInjection.injectJavaScript
    }

    #------------------------------------------------#
    #            Transactional Endpoints             #
    #------------------------------------------------#

    ### New-AppSecPolicyTransactionalEndpoint
    $Script:NewTransactionalEndpoint = New-AppSecPolicyTransactionalEndpoint -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -PolicyID $TestPolicyID -Endpoint $TestTransactionalEndpoint -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-AppSecPolicyTransactionalEndpoint returns the correct data' {
        $NewTransactionalEndpoint.operationId | Should -Not -BeNullOrEmpty
    }

    ### List-AppSecPolicyTransactionalEndpoints
    $Script:TransactionalEndpoints = List-AppSecPolicyTransactionalEndpoints -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -PolicyID $TestPolicyID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecPolicyTransactionalEndpoints returns a list' {
        $TransactionalEndpoints | Should -Not -BeNullOrEmpty
    }

    ### Get-AppSecPolicyTransactionalEndpoint
    $Script:TransactionalEndpoint = Get-AppSecPolicyTransactionalEndpoint -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -PolicyID $TestPolicyID -OperationID $NewTransactionalEndpoint.operationId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecPolicyTransactionalEndpoint returns the correct data' {
        $TransactionalEndpoint.apiEndPointId | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPolicyTransactionalEndpoint
    $Script:SetTransactionalEndpoint = ($TransactionalEndpoint | Set-AppSecPolicyTransactionalEndpoint -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -PolicyID $TestPolicyID -OperationID $NewTransactionalEndpoint.operationId -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecPolicyTransactionalEndpoint updates successfully' {
        $SetTransactionalEndpoint.apiEndPointId | Should -Be $TransactionalEndpoint.apiEndPointId
    }

    ### Remove-AppSecPolicyTransactionalEndpoint
    it 'Remove-AppSecPolicyTransactionalEndpoint removes successfully' {
        { Remove-AppSecPolicyTransactionalEndpoint -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -PolicyID $TestPolicyID -OperationID $NewTransactionalEndpoint.operationId -EdgeRCFile $EdgeRCFile -Section $Section} | Should -Not -Throw
    }

    #------------------------------------------------#
    #       Transactional Endpoint Protection        #
    #------------------------------------------------#

    ### List-BotManTransactionalEndpointProtections
    $Script:TransactionalEndpointProtections = List-BotManTransactionalEndpointProtections -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-BotManTransactionalEndpointProtections returns the correct data' {
        $TransactionalEndpointProtections.standardTelemetry | Should -Not -BeNullOrEmpty
    }

    ### Set-BotManTransactionalEndpointProtections
    $Script:SetTransactionalEndpointProtections = ($TransactionalEndpointProtections |  Set-BotManTransactionalEndpointProtections -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-BotManTransactionalEndpointProtections updates correctly' {
        $SetTransactionalEndpointProtections.standardTelemetry | Should -Not -BeNullOrEmpty
    }

    #------------------------------------------------#
    #                Response Actions                #
    #------------------------------------------------#

    ### List-BotManResponseActions
    $Script:ResponseActions = List-BotManResponseActions -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-BotManResponseActions returns the correct data' {
        $ResponseActions.count | Should -Not -BeNullOrEmpty
    }

    #------------------------------------------------#
    #          Challenge Interception Rules          #
    #------------------------------------------------#

    ### List-BotManChallengeInterceptionRules
    $Script:ChallengeInterceptionRules = List-BotManChallengeInterceptionRules -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-BotManChallengeInterceptionRules returns the correct data' {
        $ChallengeInterceptionRules.interceptAllRequests | Should -Not -BeNullOrEmpty
    }

    ### Set-BotManChallengeInterceptionRules
    $Script:SetChallengeInterceptionRules = ($ChallengeInterceptionRules | Set-BotManChallengeInterceptionRules -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-BotManChallengeInterceptionRules returns the correct data' {
        $SetChallengeInterceptionRules.interceptAllRequests | Should -Be $ChallengeInterceptionRules.interceptAllRequests
    }

    #------------------------------------------------#
    #              Custom Deny Actions               #
    #------------------------------------------------#

    ### New-AppSecPolicyTransactionalEndpoint
    $Script:NewCustomDenyAction = New-BotManCustomDenyAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -Action $TestCustomDenyAction -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-AppSecPolicyTransactionalEndpoint returns the correct data' {
        $NewCustomDenyAction.actionId | Should -Not -BeNullOrEmpty
    }

    ### List-BotManCustomDenyActions
    $Script:CustomDenyActions = List-BotManCustomDenyActions -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-BotManCustomDenyActions returns a list' {
        $CustomDenyActions.count | Should -Not -Be 0
    }

    ### Get-BotManCustomDenyAction
    $Script:CustomDenyAction = Get-BotManCustomDenyAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -ActionID $NewCustomDenyAction.actionId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-BotManCustomDenyAction returns the correct data' {
        $CustomDenyAction.actionId | Should -Be $NewCustomDenyAction.actionId
    }

    ### Set-BotManCustomDenyAction
    $Script:SetCustomDenyAction = ($CustomDenyAction | Set-BotManCustomDenyAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -ActionID $CustomDenyAction.actionId -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-BotManCustomDenyAction updates successfully' {
        $SetCustomDenyAction.actionId | Should -Be $CustomDenyAction.actionId
    }

    ### Remove-BotManCustomDenyAction
    it 'Remove-BotManCustomDenyAction removes successfully' {
        { Remove-BotManCustomDenyAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -ActionID $CustomDenyAction.actionId -EdgeRCFile $EdgeRCFile -Section $Section} | Should -Not -Throw
    }

    #------------------------------------------------#
    #              Conditional Actions               #
    #------------------------------------------------#

    ### New-BotManConditionalAction
    $Script:NewConditionalAction = New-BotManConditionalAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -Action $TestConditionalAction -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-BotManConditionalAction creates correctly' {
        $NewConditionalAction.actionId | Should -Not -BeNullOrEmpty
    }

    ### List-BotManConditionalActions
    $Script:ConditionalActions = List-BotManConditionalActions -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-BotManConditionalActions returns a list' {
        $ConditionalActions.count | Should -Not -Be 0
    }

    ### Get-BotManConditionalAction
    $Script:ConditionalAction = Get-BotManConditionalAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -ActionID $NewConditionalAction.actionId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-BotManConditionalAction returns the correct data' {
        $ConditionalAction.actionId | Should -Be $NewConditionalAction.actionId
    }

    ### Set-BotManConditionalAction
    $Script:SetConditionalAction = ($ConditionalAction | Set-BotManConditionalAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -ActionID $ConditionalAction.actionId -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-BotManConditionalAction updates successfully' {
        $SetConditionalAction.actionId | Should -Be $ConditionalAction.actionId
    }

    ### Remove-BotManConditionalAction
    it 'Remove-BotManConditionalAction removes successfully' {
        { Remove-BotManConditionalAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -ActionID $ConditionalAction.actionId -EdgeRCFile $EdgeRCFile -Section $Section} | Should -Not -Throw
    }

    #------------------------------------------------#
    #            Serve Alternate Actions             #
    #------------------------------------------------#

    ### New-BotManServeAlternateAction
    $Script:NewServeAlternateAction = New-BotManServeAlternateAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -Action $TestServeAlternateAction -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-BotManServeAlternateAction creates correctly' {
        $NewServeAlternateAction.actionId | Should -Not -BeNullOrEmpty
    }

    ### List-BotManServeAlternateActions
    $Script:ServeAlternateActions = List-BotManServeAlternateActions -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-BotManServeAlternateActions returns a list' {
        $ServeAlternateActions.count | Should -Not -Be 0
    }

    ### Get-BotManServeAlternateAction
    $Script:ServeAlternateAction = Get-BotManServeAlternateAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -ActionID $NewServeAlternateAction.actionId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-BotManServeAlternateAction returns the correct data' {
        $ServeAlternateAction.actionId | Should -Be $NewServeAlternateAction.actionId
    }

    ### Set-BotManServeAlternateAction
    $Script:SetServeAlternateAction = ($ServeAlternateAction | Set-BotManServeAlternateAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -ActionID $ServeAlternateAction.actionId -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-BotManServeAlternateAction updates successfully' {
        $SetServeAlternateAction.actionId | Should -Be $ServeAlternateAction.actionId
    }

    ### Remove-BotManConditionalAction
    it 'Remove-BotManConditionalAction removes successfully' {
        { Remove-BotManServeAlternateAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -ActionID $ServeAlternateAction.actionId -EdgeRCFile $EdgeRCFile -Section $Section} | Should -Not -Throw
    }

    #------------------------------------------------#
    #               Challenge Actions                #
    #------------------------------------------------#

    ### New-BotManChallengeAction
    $Script:NewChallengeAction = New-BotManChallengeAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -Action $TestChallengeAction -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-BotManChallengeAction creates correctly' {
        $NewChallengeAction.actionId | Should -Not -BeNullOrEmpty
    }

    ### List-BotManChallengeActions
    $Script:ChallengeActions = List-BotManChallengeActions -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-BotManChallengeActions returns a list' {
        $ChallengeActions.count | Should -Not -Be 0
    }

    ### Get-BotManChallengeAction
    $Script:ChallengeAction = Get-BotManChallengeAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -ActionID $NewChallengeAction.actionId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-BotManChallengeAction returns the correct data' {
        $ChallengeAction.actionId | Should -Be $NewChallengeAction.actionId
    }

    ### Set-BotManChallengeAction
    $Script:SetChallengeAction = ($ChallengeAction | Set-BotManChallengeAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -ActionID $ChallengeAction.actionId -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-BotManChallengeAction updates successfully' {
        $SetChallengeAction.actionId | Should -Be $ChallengeAction.actionId
    }

    ### Remove-BotManChallengeAction
    it 'Remove-BotManChallengeAction removes successfully' {
        { Remove-BotManChallengeAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -ActionID $ChallengeAction.actionId -EdgeRCFile $EdgeRCFile -Section $Section} | Should -Not -Throw
    }

    #------------------------------------------------#
    #                   Removals                     #
    #------------------------------------------------#

    ### Remove-BotManCustomBotCategory
    it 'Remove-BotManCustomBotCategory removes successfully' {
        { Remove-BotManCustomBotCategory -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -CategoryID $NewCustomBotCategory.categoryId -EdgeRCFile $EdgeRCFile -Section $Section } | Should -Not -Throw
    }

    AfterAll {

    }
    
}

Describe 'Unsafe Botman Tests' {
    # ### Get-CPSDVHistory
    # $Script:DVHistory = Get-CPSDVHistory -EnrollmentID $TestEnrollmentID -EdgeRCFile $SafeEdgeRCFile -Section $Section
    # it 'Get-CPSDVHistory returns history' {
    #     $DVHistory.count | Should -BeGreaterThan 0
    # }
    
}

# SIG # Begin signature block
# MIIoaAYJKoZIhvcNAQcCoIIoWTCCKFUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUEKeS/xdJXbJ33kkejJeNGH3G
# AuiggiGYMIIFjTCCBHWgAwIBAgIQDpsYjvnQLefv21DiCEAYWjANBgkqhkiG9w0B
# AQwFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVk
# IElEIFJvb3QgQ0EwHhcNMjIwODAxMDAwMDAwWhcNMzExMTA5MjM1OTU5WjBiMQsw
# CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cu
# ZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQw
# ggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC/5pBzaN675F1KPDAiMGkz
# 7MKnJS7JIT3yithZwuEppz1Yq3aaza57G4QNxDAf8xukOBbrVsaXbR2rsnnyyhHS
# 5F/WBTxSD1Ifxp4VpX6+n6lXFllVcq9ok3DCsrp1mWpzMpTREEQQLt+C8weE5nQ7
# bXHiLQwb7iDVySAdYyktzuxeTsiT+CFhmzTrBcZe7FsavOvJz82sNEBfsXpm7nfI
# SKhmV1efVFiODCu3T6cw2Vbuyntd463JT17lNecxy9qTXtyOj4DatpGYQJB5w3jH
# trHEtWoYOAMQjdjUN6QuBX2I9YI+EJFwq1WCQTLX2wRzKm6RAXwhTNS8rhsDdV14
# Ztk6MUSaM0C/CNdaSaTC5qmgZ92kJ7yhTzm1EVgX9yRcRo9k98FpiHaYdj1ZXUJ2
# h4mXaXpI8OCiEhtmmnTK3kse5w5jrubU75KSOp493ADkRSWJtppEGSt+wJS00mFt
# 6zPZxd9LBADMfRyVw4/3IbKyEbe7f/LVjHAsQWCqsWMYRJUadmJ+9oCw++hkpjPR
# iQfhvbfmQ6QYuKZ3AeEPlAwhHbJUKSWJbOUOUlFHdL4mrLZBdd56rF+NP8m800ER
# ElvlEFDrMcXKchYiCd98THU/Y+whX8QgUWtvsauGi0/C1kVfnSD8oR7FwI+isX4K
# Jpn15GkvmB0t9dmpsh3lGwIDAQABo4IBOjCCATYwDwYDVR0TAQH/BAUwAwEB/zAd
# BgNVHQ4EFgQU7NfjgtJxXWRM3y5nP+e6mK4cD08wHwYDVR0jBBgwFoAUReuir/SS
# y4IxLVGLp6chnfNtyA8wDgYDVR0PAQH/BAQDAgGGMHkGCCsGAQUFBwEBBG0wazAk
# BggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAC
# hjdodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURS
# b290Q0EuY3J0MEUGA1UdHwQ+MDwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwEQYDVR0gBAowCDAGBgRV
# HSAAMA0GCSqGSIb3DQEBDAUAA4IBAQBwoL9DXFXnOF+go3QbPbYW1/e/Vwe9mqyh
# hyzshV6pGrsi+IcaaVQi7aSId229GhT0E0p6Ly23OO/0/4C5+KH38nLeJLxSA8hO
# 0Cre+i1Wz/n096wwepqLsl7Uz9FDRJtDIeuWcqFItJnLnU+nBgMTdydE1Od/6Fmo
# 8L8vC6bp8jQ87PcDx4eo0kxAGTVGamlUsLihVo7spNU96LHc/RzY9HdaXFSMb++h
# UD38dglohJ9vytsgjTVgHAIDyyCwrFigDkBjxZgiwbJZ9VVrzyerbHbObyMt9H5x
# aiNrIv8SuFQtJ37YOtnwtoeW/VvRXKwYw02fc7cBqZ9Xql4o4rmUMIIGrjCCBJag
# AwIBAgIQBzY3tyRUfNhHrP0oZipeWzANBgkqhkiG9w0BAQsFADBiMQswCQYDVQQG
# EwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNl
# cnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQwHhcNMjIw
# MzIzMDAwMDAwWhcNMzcwMzIyMjM1OTU5WjBjMQswCQYDVQQGEwJVUzEXMBUGA1UE
# ChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQg
# UlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENBMIICIjANBgkqhkiG9w0BAQEF
# AAOCAg8AMIICCgKCAgEAxoY1BkmzwT1ySVFVxyUDxPKRN6mXUaHW0oPRnkyibaCw
# zIP5WvYRoUQVQl+kiPNo+n3znIkLf50fng8zH1ATCyZzlm34V6gCff1DtITaEfFz
# sbPuK4CEiiIY3+vaPcQXf6sZKz5C3GeO6lE98NZW1OcoLevTsbV15x8GZY2UKdPZ
# 7Gnf2ZCHRgB720RBidx8ald68Dd5n12sy+iEZLRS8nZH92GDGd1ftFQLIWhuNyG7
# QKxfst5Kfc71ORJn7w6lY2zkpsUdzTYNXNXmG6jBZHRAp8ByxbpOH7G1WE15/teP
# c5OsLDnipUjW8LAxE6lXKZYnLvWHpo9OdhVVJnCYJn+gGkcgQ+NDY4B7dW4nJZCY
# OjgRs/b2nuY7W+yB3iIU2YIqx5K/oN7jPqJz+ucfWmyU8lKVEStYdEAoq3NDzt9K
# oRxrOMUp88qqlnNCaJ+2RrOdOqPVA+C/8KI8ykLcGEh/FDTP0kyr75s9/g64ZCr6
# dSgkQe1CvwWcZklSUPRR8zZJTYsg0ixXNXkrqPNFYLwjjVj33GHek/45wPmyMKVM
# 1+mYSlg+0wOI/rOP015LdhJRk8mMDDtbiiKowSYI+RQQEgN9XyO7ZONj4KbhPvbC
# dLI/Hgl27KtdRnXiYKNYCQEoAA6EVO7O6V3IXjASvUaetdN2udIOa5kM0jO0zbEC
# AwEAAaOCAV0wggFZMBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYDVR0OBBYEFLoW2W1N
# hS9zKXaaL3WMaiCPnshvMB8GA1UdIwQYMBaAFOzX44LScV1kTN8uZz/nupiuHA9P
# MA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEFBQcDCDB3BggrBgEFBQcB
# AQRrMGkwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBBBggr
# BgEFBQcwAoY1aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1
# c3RlZFJvb3RHNC5jcnQwQwYDVR0fBDwwOjA4oDagNIYyaHR0cDovL2NybDMuZGln
# aWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcmwwIAYDVR0gBBkwFzAI
# BgZngQwBBAIwCwYJYIZIAYb9bAcBMA0GCSqGSIb3DQEBCwUAA4ICAQB9WY7Ak7Zv
# mKlEIgF+ZtbYIULhsBguEE0TzzBTzr8Y+8dQXeJLKftwig2qKWn8acHPHQfpPmDI
# 2AvlXFvXbYf6hCAlNDFnzbYSlm/EUExiHQwIgqgWvalWzxVzjQEiJc6VaT9Hd/ty
# dBTX/6tPiix6q4XNQ1/tYLaqT5Fmniye4Iqs5f2MvGQmh2ySvZ180HAKfO+ovHVP
# ulr3qRCyXen/KFSJ8NWKcXZl2szwcqMj+sAngkSumScbqyQeJsG33irr9p6xeZmB
# o1aGqwpFyd/EjaDnmPv7pp1yr8THwcFqcdnGE4AJxLafzYeHJLtPo0m5d2aR8XKc
# 6UsCUqc3fpNTrDsdCEkPlM05et3/JWOZJyw9P2un8WbDQc1PtkCbISFA0LcTJM3c
# HXg65J6t5TRxktcma+Q4c6umAU+9Pzt4rUyt+8SVe+0KXzM5h0F4ejjpnOHdI/0d
# KNPH+ejxmF/7K9h+8kaddSweJywm228Vex4Ziza4k9Tm8heZWcpw8De/mADfIBZP
# J/tgZxahZrrdVcA6KYawmKAr7ZVBtzrVFZgxtGIJDwq9gdkT/r+k0fNX2bwE+oLe
# Mt8EifAAzV3C+dAjfwAL5HYCJtnwZXZCpimHCUcr5n8apIUP/JiW9lVUKx+A+sDy
# Divl1vupL0QVSucTDh3bNzgaoSv27dZ8/DCCBrAwggSYoAMCAQICEAitQLJg0pxM
# n17Nqb2TrtkwDQYJKoZIhvcNAQEMBQAwYjELMAkGA1UEBhMCVVMxFTATBgNVBAoT
# DERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UE
# AxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MB4XDTIxMDQyOTAwMDAwMFoXDTM2
# MDQyODIzNTk1OVowaTELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJ
# bmMuMUEwPwYDVQQDEzhEaWdpQ2VydCBUcnVzdGVkIEc0IENvZGUgU2lnbmluZyBS
# U0E0MDk2IFNIQTM4NCAyMDIxIENBMTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCC
# AgoCggIBANW0L0LQKK14t13VOVkbsYhC9TOM6z2Bl3DFu8SFJjCfpI5o2Fz16zQk
# B+FLT9N4Q/QX1x7a+dLVZxpSTw6hV/yImcGRzIEDPk1wJGSzjeIIfTR9TIBXEmtD
# mpnyxTsf8u/LR1oTpkyzASAl8xDTi7L7CPCK4J0JwGWn+piASTWHPVEZ6JAheEUu
# oZ8s4RjCGszF7pNJcEIyj/vG6hzzZWiRok1MghFIUmjeEL0UV13oGBNlxX+yT4Us
# SKRWhDXW+S6cqgAV0Tf+GgaUwnzI6hsy5srC9KejAw50pa85tqtgEuPo1rn3MeHc
# reQYoNjBI0dHs6EPbqOrbZgGgxu3amct0r1EGpIQgY+wOwnXx5syWsL/amBUi0nB
# k+3htFzgb+sm+YzVsvk4EObqzpH1vtP7b5NhNFy8k0UogzYqZihfsHPOiyYlBrKD
# 1Fz2FRlM7WLgXjPy6OjsCqewAyuRsjZ5vvetCB51pmXMu+NIUPN3kRr+21CiRshh
# WJj1fAIWPIMorTmG7NS3DVPQ+EfmdTCN7DCTdhSmW0tddGFNPxKRdt6/WMtyEClB
# 8NXFbSZ2aBFBE1ia3CYrAfSJTVnbeM+BSj5AR1/JgVBzhRAjIVlgimRUwcwhGug4
# GXxmHM14OEUwmU//Y09Mu6oNCFNBfFg9R7P6tuyMMgkCzGw8DFYRAgMBAAGjggFZ
# MIIBVTASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQWBBRoN+Drtjv4XxGG+/5h
# ewiIZfROQjAfBgNVHSMEGDAWgBTs1+OC0nFdZEzfLmc/57qYrhwPTzAOBgNVHQ8B
# Af8EBAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUHAwMwdwYIKwYBBQUHAQEEazBpMCQG
# CCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQQYIKwYBBQUHMAKG
# NWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290
# RzQuY3J0MEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydFRydXN0ZWRSb290RzQuY3JsMBwGA1UdIAQVMBMwBwYFZ4EMAQMw
# CAYGZ4EMAQQBMA0GCSqGSIb3DQEBDAUAA4ICAQA6I0Q9jQh27o+8OpnTVuACGqX4
# SDTzLLbmdGb3lHKxAMqvbDAnExKekESfS/2eo3wm1Te8Ol1IbZXVP0n0J7sWgUVQ
# /Zy9toXgdn43ccsi91qqkM/1k2rj6yDR1VB5iJqKisG2vaFIGH7c2IAaERkYzWGZ
# gVb2yeN258TkG19D+D6U/3Y5PZ7Umc9K3SjrXyahlVhI1Rr+1yc//ZDRdobdHLBg
# XPMNqO7giaG9OeE4Ttpuuzad++UhU1rDyulq8aI+20O4M8hPOBSSmfXdzlRt2V0C
# FB9AM3wD4pWywiF1c1LLRtjENByipUuNzW92NyyFPxrOJukYvpAHsEN/lYgggnDw
# zMrv/Sk1XB+JOFX3N4qLCaHLC+kxGv8uGVw5ceG+nKcKBtYmZ7eS5k5f3nqsSc8u
# pHSSrds8pJyGH+PBVhsrI/+PteqIe3Br5qC6/To/RabE6BaRUotBwEiES5ZNq0RA
# 443wFSjO7fEYVgcqLxDEDAhkPDOPriiMPMuPiAsNvzv0zh57ju+168u38HcT5uco
# P6wSrqUvImxB+YJcFWbMbA7KxYbD9iYzDAdLoNMHAmpqQDBISzSoUSC7rRuFCOJZ
# DW3KBVAr6kocnqX9oKcfBnTn8tZSkP2vhUgh+Vc7tJwD7YZF9LRhbr9o4iZghurI
# r6n+lB3nYxs6hlZ4TjCCBsAwggSooAMCAQICEAxNaXJLlPo8Kko9KQeAPVowDQYJ
# KoZIhvcNAQELBQAwYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJ
# bmMuMTswOQYDVQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2
# IFRpbWVTdGFtcGluZyBDQTAeFw0yMjA5MjEwMDAwMDBaFw0zMzExMjEyMzU5NTla
# MEYxCzAJBgNVBAYTAlVTMREwDwYDVQQKEwhEaWdpQ2VydDEkMCIGA1UEAxMbRGln
# aUNlcnQgVGltZXN0YW1wIDIwMjIgLSAyMIICIjANBgkqhkiG9w0BAQEFAAOCAg8A
# MIICCgKCAgEAz+ylJjrGqfJru43BDZrboegUhXQzGias0BxVHh42bbySVQxh9J0J
# dz0Vlggva2Sk/QaDFteRkjgcMQKW+3KxlzpVrzPsYYrppijbkGNcvYlT4DotjIdC
# riak5Lt4eLl6FuFWxsC6ZFO7KhbnUEi7iGkMiMbxvuAvfTuxylONQIMe58tySSge
# TIAehVbnhe3yYbyqOgd99qtu5Wbd4lz1L+2N1E2VhGjjgMtqedHSEJFGKes+JvK0
# jM1MuWbIu6pQOA3ljJRdGVq/9XtAbm8WqJqclUeGhXk+DF5mjBoKJL6cqtKctvdP
# bnjEKD+jHA9QBje6CNk1prUe2nhYHTno+EyREJZ+TeHdwq2lfvgtGx/sK0YYoxn2
# Off1wU9xLokDEaJLu5i/+k/kezbvBkTkVf826uV8MefzwlLE5hZ7Wn6lJXPbwGqZ
# IS1j5Vn1TS+QHye30qsU5Thmh1EIa/tTQznQZPpWz+D0CuYUbWR4u5j9lMNzIfMv
# wi4g14Gs0/EH1OG92V1LbjGUKYvmQaRllMBY5eUuKZCmt2Fk+tkgbBhRYLqmgQ8J
# JVPxvzvpqwcOagc5YhnJ1oV/E9mNec9ixezhe7nMZxMHmsF47caIyLBuMnnHC1mD
# jcbu9Sx8e47LZInxscS451NeX1XSfRkpWQNO+l3qRXMchH7XzuLUOncCAwEAAaOC
# AYswggGHMA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQM
# MAoGCCsGAQUFBwMIMCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATAf
# BgNVHSMEGDAWgBS6FtltTYUvcyl2mi91jGogj57IbzAdBgNVHQ4EFgQUYore0GH8
# jzEU7ZcLzT0qlBTfUpwwWgYDVR0fBFMwUTBPoE2gS4ZJaHR0cDovL2NybDMuZGln
# aWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFt
# cGluZ0NBLmNybDCBkAYIKwYBBQUHAQEEgYMwgYAwJAYIKwYBBQUHMAGGGGh0dHA6
# Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBYBggrBgEFBQcwAoZMaHR0cDovL2NhY2VydHMu
# ZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVT
# dGFtcGluZ0NBLmNydDANBgkqhkiG9w0BAQsFAAOCAgEAVaoqGvNG83hXNzD8deNP
# 1oUj8fz5lTmbJeb3coqYw3fUZPwV+zbCSVEseIhjVQlGOQD8adTKmyn7oz/AyQCb
# Ex2wmIncePLNfIXNU52vYuJhZqMUKkWHSphCK1D8G7WeCDAJ+uQt1wmJefkJ5ojO
# fRu4aqKbwVNgCeijuJ3XrR8cuOyYQfD2DoD75P/fnRCn6wC6X0qPGjpStOq/CUkV
# NTZZmg9U0rIbf35eCa12VIp0bcrSBWcrduv/mLImlTgZiEQU5QpZomvnIj5EIdI/
# HMCb7XxIstiSDJFPPGaUr10CU+ue4p7k0x+GAWScAMLpWnR1DT3heYi/HAGXyRkj
# gNc2Wl+WFrFjDMZGQDvOXTXUWT5Dmhiuw8nLw/ubE19qtcfg8wXDWd8nYiveQclT
# uf80EGf2JjKYe/5cQpSBlIKdrAqLxksVStOYkEVgM4DgI974A6T2RUflzrgDQkfo
# QTZxd639ouiXdE4u2h4djFrIHprVwvDGIqhPm73YHJpRxC+a9l+nJ5e6li6FV8Bg
# 53hWf2rvwpWaSxECyIKcyRoFfLpxtU56mWz06J7UWpjIn7+NuxhcQ/XQKujiYu54
# BNu90ftbCqhwfvCXhHjjCANdRyxjqCU4lwHSPzra5eX25pvcfizM/xdMTQCi2NYB
# DriL7ubgclWJLCcZYfZ3AYwwggfZMIIFwaADAgECAhAJi6B8zycIi8m1Q3xkIZDn
# MA0GCSqGSIb3DQEBCwUAMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2Vy
# dCwgSW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25p
# bmcgUlNBNDA5NiBTSEEzODQgMjAyMSBDQTEwHhcNMjMwMTExMDAwMDAwWhcNMjMw
# MzAxMjM1OTU5WjCB3jETMBEGCysGAQQBgjc8AgEDEwJVUzEZMBcGCysGAQQBgjc8
# AgECEwhEZWxhd2FyZTEdMBsGA1UEDwwUUHJpdmF0ZSBPcmdhbml6YXRpb24xEDAO
# BgNVBAUTBzI5MzM2MzcxCzAJBgNVBAYTAlVTMRYwFAYDVQQIEw1NYXNzYWNodXNl
# dHRzMRIwEAYDVQQHEwlDYW1icmlkZ2UxIDAeBgNVBAoTF0FrYW1haSBUZWNobm9s
# b2dpZXMgSW5jMSAwHgYDVQQDExdBa2FtYWkgVGVjaG5vbG9naWVzIEluYzCCAiIw
# DQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBALFDEw1oBMbHbJBtOuHBaSg6zH1h
# MhdPWEtWOgnEO7TgO6LGXoRuP6gZmX844/W6kH+CRIMAzei+6AQ2AUzOAWH7ipwS
# cikJHPmxUWM/+yNWJLrnZtgOtPJalsqm3oTjCF/+WDGEVul5EMhlKb6WIg50gzWr
# 3HbG0ym564cdqZQJtn1k6m13FNtIIykgDuR9ttFdh1tsBBYOrSP6W1uu+NNpDBwr
# 16njSQtmqZTwgO+VZT/dNRvalW1a4vlAgN+U/Xo72aNqIiVnByFP2Gj6IWbUezNj
# gOFMkSe7u52cVu51GfL2XjKWup0X0gfluU06P3QZN+wiZFBfsdmXiGAXPd+UysAG
# Uh1XJ+2lnVQyHD9L1Qmw11wWD/pNYQIvjWdpzxU5NdaXEH/lbBouF+94C8HI74ty
# zsSW/E9mb+enLAebUp4jemguKMhsZC3WG2PhqlIdvPDWmaGmg6td5flco4W9xUkg
# f8LpgYrCUaqWwQ/JXht0dl4ITqgJwHorK4MT2B3X0Ft+/cTHLxSBm8TcggwTEPXQ
# HCiZjbxuHNvAZQga7+0NC4cljUhbCbhLTe7gX+XAq9LwcAtlSzN/aVF6tpPMyCj/
# xuFCBjWtML079FoIST69sVfhdjFYUfS1goauFy+CqXda3Rgirv48tm11MmpgJf5u
# zFy9+sdRhWzLC66pAgMBAAGjggIFMIICATAfBgNVHSMEGDAWgBRoN+Drtjv4XxGG
# +/5hewiIZfROQjAdBgNVHQ4EFgQULvUKZAEQ6oPpuyNAwiZsQgGlULIwDgYDVR0P
# AQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMIG1BgNVHR8Ega0wgaowU6BR
# oE+GTWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNENv
# ZGVTaWduaW5nUlNBNDA5NlNIQTM4NDIwMjFDQTEuY3JsMFOgUaBPhk1odHRwOi8v
# Y3JsNC5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRDb2RlU2lnbmluZ1JT
# QTQwOTZTSEEzODQyMDIxQ0ExLmNybDA9BgNVHSAENjA0MDIGBWeBDAEDMCkwJwYI
# KwYBBQUHAgEWG2h0dHA6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzCBlAYIKwYBBQUH
# AQEEgYcwgYQwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBc
# BggrBgEFBQcwAoZQaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0
# VHJ1c3RlZEc0Q29kZVNpZ25pbmdSU0E0MDk2U0hBMzg0MjAyMUNBMS5jcnQwDAYD
# VR0TAQH/BAIwADANBgkqhkiG9w0BAQsFAAOCAgEAulx9aewYZWl0UyqeAts4V+P0
# 6gcLf+4Hsnwtn8hAlqT8o+8hnPB5LplZCR3OJT98gIq6dXAvPQJWNq1pc/RD0OTI
# pEDsmqzw0c/OHPrnZcuxQxHojQe2J2Gx9E5u6AobLHFTz1+kmgQzRGyCMBecdPRW
# ubXxTyL9SiHE2XN/oXZMBWQdmpl3a79wia495lO2rstz/VNCjX0Hc5FOo+ewExly
# 4WfPqYmAVH1cJ3AKrh79dFJhgaeLd/+3szgImHJ8C7EsvobpwKPW9JGbNf6QnvQ/
# ZbTNdqAzedwtAziNw0F26+EKuf2P2VVBIHiepF51Dh+wSo8qA+A9NFxMb17zMXnN
# x8XcQd/dAULN3X7XT3J3OaSvxMKTMcboh0r5T3OLTy61KYGBa4UCYuVPrMCv0Lji
# vCdqVRfWlZNTrsD0dOIUtpjrK/JLxpwRx0I50QQMsPzs5BJLHS+3ULv82xftwwfM
# bbLBZicDSmLRN0HVzY0hfxTRwRJAKYmCdhSfH/IcwuKyn4kGeXIkaEtGYAhDvLfy
# xjXDd5VcQeScaq7x+EXW5wgISNwxf2kUFgthzEvDNObsnQ3Lr9TwPy/+5Lkj1Oa5
# Q2CEnALMLhFL55Cz7xHggTSuzdnNLmJPMXj0XwVbDITd0lVjQ9Vn7WNa4U38vn6X
# jw+A6gdW445gtFLdy/4xggY6MIIGNgIBATB9MGkxCzAJBgNVBAYTAlVTMRcwFQYD
# VQQKEw5EaWdpQ2VydCwgSW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBH
# NCBDb2RlIFNpZ25pbmcgUlNBNDA5NiBTSEEzODQgMjAyMSBDQTECEAmLoHzPJwiL
# ybVDfGQhkOcwCQYFKw4DAhoFAKBwMBAGCisGAQQBgjcCAQwxAjAAMBkGCSqGSIb3
# DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEV
# MCMGCSqGSIb3DQEJBDEWBBS/bQ479Q2tLnpFJ1TuDFXU8/nvDzANBgkqhkiG9w0B
# AQEFAASCAgCZi/dWs0n7Oqhg6rSt3YARXaeDX71hgWwLty9hYJOanoxX4Hn9NR79
# adJ+R/dsf+cIwqd5p4KxePc58InXrtbhcAMbAQkGWPApQrxScgW3E5BU9EoO2z61
# ErOEicBoy2ow/is9OK2z2dwVszbfb0HMf4Qja3JpwrXR7b6Nc/pbH7+t/IUs9TKk
# F/d70kNHHa0PmWyOG9axzCrTupDXR+HbpLpAT/gyA7v++j5RGXDWy5SWM1n2atPT
# B1KoeG0TyfIfB8S7o+mT1pHUMyBJJQ9XNHoR2iTsxBUYH61IhD7AZ+NyZWEBt0Ig
# JUi8h1UGiKC3ZwVK6CGG8ycQG2x1wjzFFtZqEa/QznoKKxbTdRYyQ64F60r21yNw
# saIliQ+mt8vypgpSlr8k8W1sW7b6CS+4+Jn5bjkfPTQeEmBIe89bLGbl0+yI0Tmm
# jrs7IjxJiNaubzCon5ZOOyUcjSicoNtpgP0sdwdHdUGlxT70IuRliJH5ocEH4nHE
# PcIEY9Azvbj4U4JE6pYzon9s7m5zvwh/MODTidUAyvhQrKfOHDgvm2HoKiJa/RSv
# 3zjR6oEIsRtw4q5q5AvucCmP3RRBHUWhv7fmHUN1nZAw23ZY710nfTGeXYbLff4p
# Bu3AYPOUdQivNs5FNo0xVgVcOtkro1aoDLrU6yfk220ZLoDULarx/aGCAyAwggMc
# BgkqhkiG9w0BCQYxggMNMIIDCQIBATB3MGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQK
# Ew5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBS
# U0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0ECEAxNaXJLlPo8Kko9KQeAPVow
# DQYJYIZIAWUDBAIBBQCgaTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqG
# SIb3DQEJBTEPFw0yMzAyMjcxNjI5MTdaMC8GCSqGSIb3DQEJBDEiBCDPpx95bwGP
# /K+qUWOJdO0SrHIMKbckMQU/+der4jFodTANBgkqhkiG9w0BAQEFAASCAgDHn8Kw
# 1NhFAcxQHBgLtxDFTJ/E/Uy3m/IgELAobpwNMNFAXYp4SmwtZJ91kfo9rlKOg31O
# KPKA13Ebc6Sd3isHd0ww5bKmZ9f+vQzbpBcbSiCv5G/xz+YauADCLYacNT0xTHG5
# isE1UaQJoYWF6p1gXvlz9fzPzS9CEL52+kbZg2E71W37ZZdrjs3hBxuNUfy9Mjxs
# 7ZVKG58Z9BW5FnlG1k2mHFd6BqOo45LYzJ/opJxf8bcvKEkGaYd3LktMpy12enp5
# IGoDDycKZQZNl5yto7jIZE/gEhsDaHbTBSEpv6U6tfqMqlyiOK3P032bqkCJZZ/6
# o98u0XwGGGjZukadPInZAUgWA4dM4QQrLmW/7rKRfjje9dp5zDjagG5Kg9RNKa4c
# wBAIhX4U/U2+fSjQNj85mKpIkayCDjY6poi+u+Eu5hSo9SDtDDwG4Wk6m8p3VVlv
# Gu8vLJTSR+o8UwAjw145T0hE0gYvZ5ZHiC/29BUHga6r2vBiLzRsyWVv+yVrC1ac
# Gv/ekPs/Y28WeyxtTEfYJUyRRm9qog80USYfPbrtkDh7WhKrQ3OXg1LoEsoOcIyg
# LfoGXiDXQ/mjhd1vt2NGMp1JY5/EQBDflhpFWLNyz4uK7MuyQt/CwUnNtAhhIFfT
# qTqQjVR1wVMDCJ429V5TcvVhlQN6wvJ98TD0sg==
# SIG # End signature block

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
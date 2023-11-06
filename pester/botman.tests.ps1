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
# MIIpogYJKoZIhvcNAQcCoIIpkzCCKY8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDLH6GINKnph6py
# sVctgFILRXDETmnSCeBYJ8u7Bp4yUqCCDo4wggawMIIEmKADAgECAhAIrUCyYNKc
# TJ9ezam9k67ZMA0GCSqGSIb3DQEBDAUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNV
# BAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDAeFw0yMTA0MjkwMDAwMDBaFw0z
# NjA0MjgyMzU5NTlaMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcg
# UlNBNDA5NiBTSEEzODQgMjAyMSBDQTEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAw
# ggIKAoICAQDVtC9C0CiteLdd1TlZG7GIQvUzjOs9gZdwxbvEhSYwn6SOaNhc9es0
# JAfhS0/TeEP0F9ce2vnS1WcaUk8OoVf8iJnBkcyBAz5NcCRks43iCH00fUyAVxJr
# Q5qZ8sU7H/Lvy0daE6ZMswEgJfMQ04uy+wjwiuCdCcBlp/qYgEk1hz1RGeiQIXhF
# LqGfLOEYwhrMxe6TSXBCMo/7xuoc82VokaJNTIIRSFJo3hC9FFdd6BgTZcV/sk+F
# LEikVoQ11vkunKoAFdE3/hoGlMJ8yOobMubKwvSnowMOdKWvObarYBLj6Na59zHh
# 3K3kGKDYwSNHR7OhD26jq22YBoMbt2pnLdK9RBqSEIGPsDsJ18ebMlrC/2pgVItJ
# wZPt4bRc4G/rJvmM1bL5OBDm6s6R9b7T+2+TYTRcvJNFKIM2KmYoX7BzzosmJQay
# g9Rc9hUZTO1i4F4z8ujo7AqnsAMrkbI2eb73rQgedaZlzLvjSFDzd5Ea/ttQokbI
# YViY9XwCFjyDKK05huzUtw1T0PhH5nUwjewwk3YUpltLXXRhTT8SkXbev1jLchAp
# QfDVxW0mdmgRQRNYmtwmKwH0iU1Z23jPgUo+QEdfyYFQc4UQIyFZYIpkVMHMIRro
# OBl8ZhzNeDhFMJlP/2NPTLuqDQhTQXxYPUez+rbsjDIJAsxsPAxWEQIDAQABo4IB
# WTCCAVUwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQUaDfg67Y7+F8Rhvv+
# YXsIiGX0TkIwHwYDVR0jBBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0P
# AQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUFBwMDMHcGCCsGAQUFBwEBBGswaTAk
# BggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAC
# hjVodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9v
# dEc0LmNydDBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5j
# b20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNybDAcBgNVHSAEFTATMAcGBWeBDAED
# MAgGBmeBDAEEATANBgkqhkiG9w0BAQwFAAOCAgEAOiNEPY0Idu6PvDqZ01bgAhql
# +Eg08yy25nRm95RysQDKr2wwJxMSnpBEn0v9nqN8JtU3vDpdSG2V1T9J9Ce7FoFF
# UP2cvbaF4HZ+N3HLIvdaqpDP9ZNq4+sg0dVQeYiaiorBtr2hSBh+3NiAGhEZGM1h
# mYFW9snjdufE5BtfQ/g+lP92OT2e1JnPSt0o618moZVYSNUa/tcnP/2Q0XaG3Ryw
# YFzzDaju4ImhvTnhOE7abrs2nfvlIVNaw8rpavGiPttDuDPITzgUkpn13c5Ubdld
# AhQfQDN8A+KVssIhdXNSy0bYxDQcoqVLjc1vdjcshT8azibpGL6QB7BDf5WIIIJw
# 8MzK7/0pNVwfiThV9zeKiwmhywvpMRr/LhlcOXHhvpynCgbWJme3kuZOX956rEnP
# LqR0kq3bPKSchh/jwVYbKyP/j7XqiHtwa+aguv06P0WmxOgWkVKLQcBIhEuWTatE
# QOON8BUozu3xGFYHKi8QxAwIZDwzj64ojDzLj4gLDb879M4ee47vtevLt/B3E+bn
# KD+sEq6lLyJsQfmCXBVmzGwOysWGw/YmMwwHS6DTBwJqakAwSEs0qFEgu60bhQji
# WQ1tygVQK+pKHJ6l/aCnHwZ05/LWUpD9r4VIIflXO7ScA+2GRfS0YW6/aOImYIbq
# yK+p/pQd52MbOoZWeE4wggfWMIIFvqADAgECAhAByZH9J50Asj/oHHbeHclzMA0G
# CSqGSIb3DQEBCwUAMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcg
# UlNBNDA5NiBTSEEzODQgMjAyMSBDQTEwHhcNMjMwNjEzMDAwMDAwWhcNMjQwMzAy
# MjM1OTU5WjCB3jETMBEGCysGAQQBgjc8AgEDEwJVUzEZMBcGCysGAQQBgjc8AgEC
# EwhEZWxhd2FyZTEdMBsGA1UEDwwUUHJpdmF0ZSBPcmdhbml6YXRpb24xEDAOBgNV
# BAUTBzI5MzM2MzcxCzAJBgNVBAYTAlVTMRYwFAYDVQQIEw1NYXNzYWNodXNldHRz
# MRIwEAYDVQQHEwlDYW1icmlkZ2UxIDAeBgNVBAoTF0FrYW1haSBUZWNobm9sb2dp
# ZXMgSW5jMSAwHgYDVQQDExdBa2FtYWkgVGVjaG5vbG9naWVzIEluYzCCAiIwDQYJ
# KoZIhvcNAQEBBQADggIPADCCAgoCggIBANdcrYnd5Y2q/LVByT4/w8A8XsvNZyET
# aJPcPw3DKpswy7TCGFLdVd5sD923zWlXy5VmXqYB/QQ1+yPjgSdgxiOFuhxL8tll
# 8OSb6auUUyrnIXx4PbcDAOKfd9J0IkQuBGNZvnMom9DkxTEpunaLEqjVFo08i53H
# 4VNmPgr7//qbEBCCulDYAg6K6HV7vckP/dTwqJ17jP3Qw0N8rnjcoxf6AwuuKcxl
# lQ4Zdr9q1yYUkvuAw6I5Vw78ODwb1Q+/nK+rYMY+Lx4W7YeAsvAXKWlUE5AXLgVC
# 3N7Xa5ZtAsaLzXJIcqW3HhCEWTygP0lTaPN9CIMnQqLtbve1PVaHH4bXG8hV9kuR
# hT5ZjvVGPDAJ9+xZap9AV+oVNp7QcbQ/p4r104TDGMA2j1wGUmRBcZobo2ypOREd
# jaI4xymenRenRhnxuAdU6Vm3yYam6XiWrIJszEk0i23bFs6wDy5wSPqr11lxn3Zh
# ksb04q+UvU+IhNkStSfwS5wizLA/KSuUjBkU7+sEd5lJaFEHHj3sH192ajODOi4s
# 3empeuwFjZbWukcq8fTLHiTkhyPoPgjvYq+6l0pZdH48pZA6utqMDO/0xIHl+PAy
# oQDVZgufYvvzsAGGF7cyFRyS7F/Tprxbd11w8DNv9I0MR+1zCMRPldAQ4aMYEakI
# kSHYuPZjXWVnAgMBAAGjggICMIIB/jAfBgNVHSMEGDAWgBRoN+Drtjv4XxGG+/5h
# ewiIZfROQjAdBgNVHQ4EFgQU4lrKPnD2cLwdOGv6x3R0iO+5q64wDgYDVR0PAQH/
# BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMIG1BgNVHR8Ega0wgaowU6BRoE+G
# TWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNENvZGVT
# aWduaW5nUlNBNDA5NlNIQTM4NDIwMjFDQTEuY3JsMFOgUaBPhk1odHRwOi8vY3Js
# NC5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRDb2RlU2lnbmluZ1JTQTQw
# OTZTSEEzODQyMDIxQ0ExLmNybDA9BgNVHSAENjA0MDIGBWeBDAEDMCkwJwYIKwYB
# BQUHAgEWG2h0dHA6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzCBlAYIKwYBBQUHAQEE
# gYcwgYQwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBcBggr
# BgEFBQcwAoZQaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1
# c3RlZEc0Q29kZVNpZ25pbmdSU0E0MDk2U0hBMzg0MjAyMUNBMS5jcnQwCQYDVR0T
# BAIwADANBgkqhkiG9w0BAQsFAAOCAgEA0yVWE59ZytC1egGLlmnUVBJk6TmpFZ2s
# dl8UtpZvb8YvDM105QhMGPtnEd4ffoqPqvgQwU7GZe7ZXrWxUu0C/ui5R5sp0fFI
# eahFBPc7cfz54jD/z+AIYDmw+Q/RgFCkAY9N2OF1KNjssKhj6cd6Z7aSc3Zj7FG3
# crXhXAmUWVosvFunEKkHXWXYbpv8edv8FC8ASvVUmVqdrHaXXSS8HigZEh/HE+XK
# A+CbBy2vQvwHq12brc7tkpSk6r15aG+RRdWmP8BirKeNYOzMZNP3XcgemmaK1SjO
# jOw/A3zyQXNEaDiAULvze1gtf8r6WT/nItgthpvKQhFejNhaAaBqlrS1YbOSvTtK
# CZMsKSTb+DEbN0dG/wcnJ4vWk4dOrgdgIDpNBhPy7q7l1v+woOWRH5UJsGNq0oFn
# wxOEdKYJ5Qn+5EMw++NMax1VlJaRrDL1nTPJudpuhpf1h1JOPhiNBsJHtCJXcxX/
# n6SUpn/VR+6Y0Lx/Knii2f8wZRFd8pCbnDLlQbwR1AxlGbQ9FlICmy+rIk+gHXC4
# 7P2JRO6uOBQcbwQDFUFC882CtKHhUtveU39LUBzkhPBByqx0e1ACcUyRIMwj4pC1
# ZS6sTPp622OBbsv0NKXZIpaSdcsF7Lak56ZQwHlO9tUDKm9KzVQHrp2v/0tdv9cz
# moABt8TK7rsxghpqMIIaZgIBATB9MGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5E
# aWdpQ2VydCwgSW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2Rl
# IFNpZ25pbmcgUlNBNDA5NiBTSEEzODQgMjAyMSBDQTECEAHJkf0nnQCyP+gcdt4d
# yXMwDQYJYIZIAWUDBAIBBQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0B
# CQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAv
# BgkqhkiG9w0BCQQxIgQgoAAAuEXlQluwmQFyo3W7rulR4rCPvtvNQVdB2Tjrvcow
# DQYJKoZIhvcNAQEBBQAEggIAL52l6PHGFf4L6KZBeq1HC8/4wYNKxG8Nye4UX+SS
# 8Rw0Gu1MNUEipSRrzaNQ770OBgf2sbZrnWb/p6GZCUJGtnPEr1zM53yuvrhNcHK0
# R92bNO2FvtU7d6cSUDpuXOLNp9+CLOUJ0twiWFNUNvYjfuUfFPUMcDD4vDKJHQm/
# Jr/h/B56eAU2JQkudKCllLiof8heS+uHJaqZuRV5zFxI8zbPwrUElgLfoENCmXvJ
# HfKnqko/dMF4A/iFLxC9bU5CPXeUf8FQ040jk+jN2Zj65biB4DSIoaspRg+eMvS/
# tWH/Asr8LTuJmAX7hNXblbe66IkQoyxs2FcaxYHfaIOLSvMG80PzVNT7geGp31WY
# rSxnlmRLnzw8ti+f0ypYk+UCWn4TUmbuzBmJPhrHm/3i5XuPrrHmga4+50tG+D2X
# ecJmoNLcJcgIuLlGFkghO8ftWmL2tMAiTYr8f/WyZ6VvqvH1OQJilftrQhATQYfl
# bld9pL4DdeMOiEsrTUEOB2ynMD37Y0aRh/TzYopHXA5yuB8jim4CR39GG/1A+NUP
# ajbj3DBYedD8aHWuQkMvFMoY3BkYs7xNEHqVJFfT9Kk0pSt+j/yXX+3ahldqA3Yb
# 0Gt0Kekc9ehBfYpHpIVuC9E+3U9aBqUTqwAcx5exmg3MJGyJ3xbea0XcV+Mn3GIe
# yGyhghdAMIIXPAYKKwYBBAGCNwMDATGCFywwghcoBgkqhkiG9w0BBwKgghcZMIIX
# FQIBAzEPMA0GCWCGSAFlAwQCAQUAMHgGCyqGSIb3DQEJEAEEoGkEZzBlAgEBBglg
# hkgBhv1sBwEwMTANBglghkgBZQMEAgEFAAQgllBoeT23MGdT/3+qTT9MkQkvxdrj
# qnOE9Z4TX555+GYCEQC0mLJ+6OcPaktO5z9iU+wbGA8yMDIzMTEwNjE3MTEyMFqg
# ghMJMIIGwjCCBKqgAwIBAgIQBUSv85SdCDmmv9s/X+VhFjANBgkqhkiG9w0BAQsF
# ADBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNV
# BAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1w
# aW5nIENBMB4XDTIzMDcxNDAwMDAwMFoXDTM0MTAxMzIzNTk1OVowSDELMAkGA1UE
# BhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMSAwHgYDVQQDExdEaWdpQ2Vy
# dCBUaW1lc3RhbXAgMjAyMzCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
# AKNTRYcdg45brD5UsyPgz5/X5dLnXaEOCdwvSKOXejsqnGfcYhVYwamTEafNqrJq
# 3RApih5iY2nTWJw1cb86l+uUUI8cIOrHmjsvlmbjaedp/lvD1isgHMGXlLSlUIHy
# z8sHpjBoyoNC2vx/CSSUpIIa2mq62DvKXd4ZGIX7ReoNYWyd/nFexAaaPPDFLnkP
# G2ZS48jWPl/aQ9OE9dDH9kgtXkV1lnX+3RChG4PBuOZSlbVH13gpOWvgeFmX40Qr
# StWVzu8IF+qCZE3/I+PKhu60pCFkcOvV5aDaY7Mu6QXuqvYk9R28mxyyt1/f8O52
# fTGZZUdVnUokL6wrl76f5P17cz4y7lI0+9S769SgLDSb495uZBkHNwGRDxy1Uc2q
# TGaDiGhiu7xBG3gZbeTZD+BYQfvYsSzhUa+0rRUGFOpiCBPTaR58ZE2dD9/O0V6M
# qqtQFcmzyrzXxDtoRKOlO0L9c33u3Qr/eTQQfqZcClhMAD6FaXXHg2TWdc2PEnZW
# pST618RrIbroHzSYLzrqawGw9/sqhux7UjipmAmhcbJsca8+uG+W1eEQE/5hRwqM
# /vC2x9XH3mwk8L9CgsqgcT2ckpMEtGlwJw1Pt7U20clfCKRwo+wK8REuZODLIivK
# 8SgTIUlRfgZm0zu++uuRONhRB8qUt+JQofM604qDy0B7AgMBAAGjggGLMIIBhzAO
# BgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEF
# BQcDCDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwHwYDVR0jBBgw
# FoAUuhbZbU2FL3MpdpovdYxqII+eyG8wHQYDVR0OBBYEFKW27xPn783QZKHVVqll
# MaPe1eNJMFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5j
# cmwwgZAGCCsGAQUFBwEBBIGDMIGAMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5k
# aWdpY2VydC5jb20wWAYIKwYBBQUHMAKGTGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdD
# QS5jcnQwDQYJKoZIhvcNAQELBQADggIBAIEa1t6gqbWYF7xwjU+KPGic2CX/yyzk
# zepdIpLsjCICqbjPgKjZ5+PF7SaCinEvGN1Ott5s1+FgnCvt7T1IjrhrunxdvcJh
# N2hJd6PrkKoS1yeF844ektrCQDifXcigLiV4JZ0qBXqEKZi2V3mP2yZWK7Dzp703
# DNiYdk9WuVLCtp04qYHnbUFcjGnRuSvExnvPnPp44pMadqJpddNQ5EQSviANnqlE
# 0PjlSXcIWiHFtM+YlRpUurm8wWkZus8W8oM3NG6wQSbd3lqXTzON1I13fXVFoaVY
# JmoDRd7ZULVQjK9WvUzF4UbFKNOt50MAcN7MmJ4ZiQPq1JE3701S88lgIcRWR+3a
# EUuMMsOI5ljitts++V+wQtaP4xeR0arAVeOGv6wnLEHQmjNKqDbUuXKWfpd5OEhf
# ysLcPTLfddY2Z1qJ+Panx+VPNTwAvb6cKmx5AdzaROY63jg7B145WPR8czFVoIAR
# yxQMfq68/qTreWWqaNYiyjvrmoI1VygWy2nyMpqy0tg6uLFGhmu6F/3Ed2wVbK6r
# r3M66ElGt9V/zLY4wNjsHPW2obhDLN9OTH0eaHDAdwrUAuBcYLso/zjlUlrWrBci
# I0707NMX+1Br/wd3H3GXREHJuEbTbDJ8WC9nR2XlG3O2mflrLAZG70Ee8PBf4NvZ
# rZCARK+AEEGKMIIGrjCCBJagAwIBAgIQBzY3tyRUfNhHrP0oZipeWzANBgkqhkiG
# 9w0BAQsFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkw
# FwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVz
# dGVkIFJvb3QgRzQwHhcNMjIwMzIzMDAwMDAwWhcNMzcwMzIyMjM1OTU5WjBjMQsw
# CQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRp
# Z2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENB
# MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxoY1BkmzwT1ySVFVxyUD
# xPKRN6mXUaHW0oPRnkyibaCwzIP5WvYRoUQVQl+kiPNo+n3znIkLf50fng8zH1AT
# CyZzlm34V6gCff1DtITaEfFzsbPuK4CEiiIY3+vaPcQXf6sZKz5C3GeO6lE98NZW
# 1OcoLevTsbV15x8GZY2UKdPZ7Gnf2ZCHRgB720RBidx8ald68Dd5n12sy+iEZLRS
# 8nZH92GDGd1ftFQLIWhuNyG7QKxfst5Kfc71ORJn7w6lY2zkpsUdzTYNXNXmG6jB
# ZHRAp8ByxbpOH7G1WE15/tePc5OsLDnipUjW8LAxE6lXKZYnLvWHpo9OdhVVJnCY
# Jn+gGkcgQ+NDY4B7dW4nJZCYOjgRs/b2nuY7W+yB3iIU2YIqx5K/oN7jPqJz+ucf
# WmyU8lKVEStYdEAoq3NDzt9KoRxrOMUp88qqlnNCaJ+2RrOdOqPVA+C/8KI8ykLc
# GEh/FDTP0kyr75s9/g64ZCr6dSgkQe1CvwWcZklSUPRR8zZJTYsg0ixXNXkrqPNF
# YLwjjVj33GHek/45wPmyMKVM1+mYSlg+0wOI/rOP015LdhJRk8mMDDtbiiKowSYI
# +RQQEgN9XyO7ZONj4KbhPvbCdLI/Hgl27KtdRnXiYKNYCQEoAA6EVO7O6V3IXjAS
# vUaetdN2udIOa5kM0jO0zbECAwEAAaOCAV0wggFZMBIGA1UdEwEB/wQIMAYBAf8C
# AQAwHQYDVR0OBBYEFLoW2W1NhS9zKXaaL3WMaiCPnshvMB8GA1UdIwQYMBaAFOzX
# 44LScV1kTN8uZz/nupiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggr
# BgEFBQcDCDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3Nw
# LmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2VydHMuZGlnaWNl
# cnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0fBDwwOjA4oDag
# NIYyaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RH
# NC5jcmwwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcBMA0GCSqGSIb3
# DQEBCwUAA4ICAQB9WY7Ak7ZvmKlEIgF+ZtbYIULhsBguEE0TzzBTzr8Y+8dQXeJL
# Kftwig2qKWn8acHPHQfpPmDI2AvlXFvXbYf6hCAlNDFnzbYSlm/EUExiHQwIgqgW
# valWzxVzjQEiJc6VaT9Hd/tydBTX/6tPiix6q4XNQ1/tYLaqT5Fmniye4Iqs5f2M
# vGQmh2ySvZ180HAKfO+ovHVPulr3qRCyXen/KFSJ8NWKcXZl2szwcqMj+sAngkSu
# mScbqyQeJsG33irr9p6xeZmBo1aGqwpFyd/EjaDnmPv7pp1yr8THwcFqcdnGE4AJ
# xLafzYeHJLtPo0m5d2aR8XKc6UsCUqc3fpNTrDsdCEkPlM05et3/JWOZJyw9P2un
# 8WbDQc1PtkCbISFA0LcTJM3cHXg65J6t5TRxktcma+Q4c6umAU+9Pzt4rUyt+8SV
# e+0KXzM5h0F4ejjpnOHdI/0dKNPH+ejxmF/7K9h+8kaddSweJywm228Vex4Ziza4
# k9Tm8heZWcpw8De/mADfIBZPJ/tgZxahZrrdVcA6KYawmKAr7ZVBtzrVFZgxtGIJ
# Dwq9gdkT/r+k0fNX2bwE+oLeMt8EifAAzV3C+dAjfwAL5HYCJtnwZXZCpimHCUcr
# 5n8apIUP/JiW9lVUKx+A+sDyDivl1vupL0QVSucTDh3bNzgaoSv27dZ8/DCCBY0w
# ggR1oAMCAQICEA6bGI750C3n79tQ4ghAGFowDQYJKoZIhvcNAQEMBQAwZTELMAkG
# A1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRp
# Z2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBSb290IENB
# MB4XDTIyMDgwMTAwMDAwMFoXDTMxMTEwOTIzNTk1OVowYjELMAkGA1UEBhMCVVMx
# FTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNv
# bTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEAv+aQc2jeu+RdSjwwIjBpM+zCpyUuySE98orY
# WcLhKac9WKt2ms2uexuEDcQwH/MbpDgW61bGl20dq7J58soR0uRf1gU8Ug9SH8ae
# FaV+vp+pVxZZVXKvaJNwwrK6dZlqczKU0RBEEC7fgvMHhOZ0O21x4i0MG+4g1ckg
# HWMpLc7sXk7Ik/ghYZs06wXGXuxbGrzryc/NrDRAX7F6Zu53yEioZldXn1RYjgwr
# t0+nMNlW7sp7XeOtyU9e5TXnMcvak17cjo+A2raRmECQecN4x7axxLVqGDgDEI3Y
# 1DekLgV9iPWCPhCRcKtVgkEy19sEcypukQF8IUzUvK4bA3VdeGbZOjFEmjNAvwjX
# WkmkwuapoGfdpCe8oU85tRFYF/ckXEaPZPfBaYh2mHY9WV1CdoeJl2l6SPDgohIb
# Zpp0yt5LHucOY67m1O+SkjqePdwA5EUlibaaRBkrfsCUtNJhbesz2cXfSwQAzH0c
# lcOP9yGyshG3u3/y1YxwLEFgqrFjGESVGnZifvaAsPvoZKYz0YkH4b235kOkGLim
# dwHhD5QMIR2yVCkliWzlDlJRR3S+Jqy2QXXeeqxfjT/JvNNBERJb5RBQ6zHFynIW
# IgnffEx1P2PsIV/EIFFrb7GrhotPwtZFX50g/KEexcCPorF+CiaZ9eRpL5gdLfXZ
# qbId5RsCAwEAAaOCATowggE2MA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFOzX
# 44LScV1kTN8uZz/nupiuHA9PMB8GA1UdIwQYMBaAFEXroq/0ksuCMS1Ri6enIZ3z
# bcgPMA4GA1UdDwEB/wQEAwIBhjB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUHMAGG
# GGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDovL2Nh
# Y2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNydDBF
# BgNVHR8EPjA8MDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNl
# cnRBc3N1cmVkSURSb290Q0EuY3JsMBEGA1UdIAQKMAgwBgYEVR0gADANBgkqhkiG
# 9w0BAQwFAAOCAQEAcKC/Q1xV5zhfoKN0Gz22Ftf3v1cHvZqsoYcs7IVeqRq7IviH
# GmlUIu2kiHdtvRoU9BNKei8ttzjv9P+Aufih9/Jy3iS8UgPITtAq3votVs/59Pes
# MHqai7Je1M/RQ0SbQyHrlnKhSLSZy51PpwYDE3cnRNTnf+hZqPC/Lwum6fI0POz3
# A8eHqNJMQBk1RmppVLC4oVaO7KTVPeix3P0c2PR3WlxUjG/voVA9/HYJaISfb8rb
# II01YBwCA8sgsKxYoA5AY8WYIsGyWfVVa88nq2x2zm8jLfR+cWojayL/ErhULSd+
# 2DrZ8LaHlv1b0VysGMNNn3O3AamfV6peKOK5lDGCA3YwggNyAgEBMHcwYzELMAkG
# A1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdp
# Q2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQQIQ
# BUSv85SdCDmmv9s/X+VhFjANBglghkgBZQMEAgEFAKCB0TAaBgkqhkiG9w0BCQMx
# DQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTIzMTEwNjE3MTEyMFowKwYL
# KoZIhvcNAQkQAgwxHDAaMBgwFgQUZvArMsLCyQ+CXc6qisnGTxmcz0AwLwYJKoZI
# hvcNAQkEMSIEIMuy+IwHezLSUJlHS3/kVHKbYcreljsVEViG9YdAdwwxMDcGCyqG
# SIb3DQEJEAIvMSgwJjAkMCIEINL25G3tdCLM0dRAV2hBNm+CitpVmq4zFq9NGprU
# DHgoMA0GCSqGSIb3DQEBAQUABIICAEi9MgApXdmoug/22iJzS8oKhS/SvL+bb/s4
# hV+VcH03aq9Bajd5JP2XMFI+gsRisuhFB135Q9grTTn1jPhJYeWLOZ1fPsmmxS7i
# 2iiBPcnynozJGS4oysHc2jWKnnz+YDEbapOle3Bnuqdyjr6x3K3bvDlG1pXzZtyd
# QAB120LpOdoEvlu6PTda2Lq0QRzRXM1R7o78VAl/RQ/LtlMyl7O36wxCknmZgohW
# hovDes/OZjtkrFitohdoV5SggsKyS0BVwpiaMLeNOcsZKgSYF3bBXnXD2HcEw6m3
# p735/fuwkjbHhXYHpsAFCLJ+zSq5JdLZh/vnBpfvC4qhS0/4PhQ1wTChWXt+aVqK
# mHQoIaHDnvx4n8PdVhN3ELdXYHMsLhf8SFVECB5gObVStU6szt73TO5CpXKgUxB1
# hnHEHWvUT2iGOA7Hy1Z4GfzY3wsNDhYILndVGpJT8Nq5wbEvOVe1IOb/1lh/M8Ci
# Ou7OtQOWPQlJZbJ5x/T9Q66SmE1bZRihn+BgI2vOOWK+t3xTuzBBLx/Xh3NlrX5m
# Mqo+GB8PuddEph5MxrcOIko6O+lqgpZD5cK7myLew4pQ2YySiFowVx1XSpHZShD8
# NX07olCwcduUfgGLylU5L5wER900Lj+AKFsjE6MEAeONdFgA6mce+p52r+bsuE16
# XPnMZEsR
# SIG # End signature block

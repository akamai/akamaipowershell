Import-Module $PSScriptRoot\..\AkamaiPowershell.psm1 -DisableNameChecking -Force
# Setup shared variables
$Script:EdgeRCFile = $env:PesterEdgeRCFile
$Script:SafeEdgeRCFile = $env:PesterSafeEdgeRCFile
$Script:SafeAuthFile = $env:PesterSafeAuthFile
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

    ### List-AppSecAkamaiBotCategories
    $Script:AkamaiBotCategories = List-AppSecAkamaiBotCategories -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecAkamaiBotCategories returns a list' {
        $AkamaiBotCategories.count | Should -Not -Be 0
    }

    ### Get-AppSecAkamaiBotCategory
    $Script:AkamaiBotCategory = Get-AppSecAkamaiBotCategory -CategoryID $AkamaiBotCategories[0].categoryId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecAkamaiBotCategory returns the correct data' {
        $AkamaiBotCategory.categoryId | Should -Be $AkamaiBotCategories[0].categoryId
    }

    #------------------------------------------------#
    #              Akamai Defined Bots               #
    #------------------------------------------------#

    ### List-AppSecAkamaiDefinedBots
    $Script:AkamaiDefinedBots = List-AppSecAkamaiDefinedBots -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecAkamaiDefinedBots returns a list' {
        $AkamaiDefinedBots.count | Should -Not -Be 0
    }

    ### Get-AppSecAkamaiDefinedBot
    $Script:AkamaiDefinedBot = Get-AppSecAkamaiDefinedBot -BotID $AkamaiDefinedBots[0].botId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecAkamaiDefinedBot returns a list' {
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

    ### New-AppSecCustomBotCategory
    $Script:NewCustomBotCategory = New-AppSecCustomBotCategory -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -CategoryName $TestCustomBotCategoryName -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-AppSecCustomBotCategory returns the correct data' {
        $NewCustomBotCategory.categoryName | Should -Be $TestCustomBotCategoryName
    }

    ### List-AppSecCustomBotCategories
    $Script:CustomBotCategories = List-AppSecCustomBotCategories -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecCustomBotCategories returns a list' {
        $CustomBotCategories | Should -Not -BeNullOrEmpty
    }

    ### Get-AppSecCustomBotCategory
    $Script:CustomBotCategory = Get-AppSecCustomBotCategory -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -CategoryID $NewCustomBotCategory.categoryId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecCustomBotCategory returns the correct data' {
        $CustomBotCategory.categoryId | Should -Be $NewCustomBotCategory.categoryId
    }

    ### Set-AppSecCustomBotCategory
    $Script:SetCustomBotCategory = ($CustomBotCategory | Set-AppSecCustomBotCategory -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -CategoryID $NewCustomBotCategory.categoryId -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecCustomBotCategory updates successfully' {
        $SetCustomBotCategory.categoryId | Should -Be $NewCustomBotCategory.categoryId
    }

    #------------------------------------------------#
    #       Recategorized Akamai-defined Bots        #
    #------------------------------------------------#

    ### Move-AppSecAkamaiDefinedBot
    $Script:RecategorizedBot = Move-AppSecAkamaiDefinedBot -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -BotID $AkamaiDefinedBots[0].botId -CustomBotCategoryID $CustomBotCategory.categoryId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Move-AppSecAkamaiDefinedBot moves successfully' {
        $RecategorizedBot.customBotCategoryId | Should -Be $CustomBotCategory.categoryId
    }

    ### List-AppSecRecategorizedAkamaiDefinedBots
    $Script:RecategorizedBots = List-AppSecRecategorizedAkamaiDefinedBots -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecRecategorizedAkamaiDefinedBots returns a list with the correct data' {
        $RecategorizedBots[0].botId | Should -Not -BeNullOrEmpty
    }

    ### Get-AppSecRecategorizedAkamaiDefinedBot
    $Script:RecategorizedBot = Get-AppSecRecategorizedAkamaiDefinedBot -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -BotID $RecategorizedBots[0].botId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecRecategorizedAkamaiDefinedBot returns the correct bot ID' {
        $RecategorizedBot.botId | Should -Be $RecategorizedBots[0].botId
    }

    ### Move-AppSecRecategorizedAkamaiDefinedBot
    $Script:MovedRecategorizedBot = Move-AppSecRecategorizedAkamaiDefinedBot -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -BotID $RecategorizedBots[0].botId -CustomBotCategoryID $CustomBotCategory.categoryId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Move-AppSecRecategorizedAkamaiDefinedBot returns the correct category' {
        $MovedRecategorizedBot.customBotCategoryId | Should -Be $CustomBotCategory.categoryId
    }

    ### Remove-AppSecRecategorizedAkamaiDefinedBot
    it 'Remove-AppSecRecategorizedAkamaiDefinedBot removes successfully' {
        { Remove-AppSecRecategorizedAkamaiDefinedBot -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -BotID $RecategorizedBot.botId -EdgeRCFile $EdgeRCFile -Section $Section } | Should -Not -Throw
    }

    #------------------------------------------------#
    #             Custom-Defined Bots                #
    #------------------------------------------------#

    ### New-AppSecCustomDefinedBot
    $TestCustomBot.categoryId = $NewCustomBotCategory.categoryId
    $Script:NewCustomBot = New-AppSecCustomDefinedBot -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -Bot $TestCustomBot -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-AppSecCustomDefinedBot returns the correct name' {
        $NewCustomBot.botName | Should -Be $TestCustomBotName
    }

    ### List-AppSecCustomDefinedBots
    $Script:CustomBots = List-AppSecCustomDefinedBots -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecCustomBotCategories returns a list' {
        $CustomBots[0].botId | Should -Not -BeNullOrEmpty
    }

    ### Get-AppSecCustomDefinedBot
    $Script:CustomBot = Get-AppSecCustomDefinedBot -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -BotID $NewCustomBot.botID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecCustomDefinedBot returns the correct bot' {
        $CustomBot.botId | Should -Be $NewCustomBot.botID
    }

    ### Set-AppSecCustomDefinedBot
    $Script:SetCustomBot = ($NewCustomBot | Set-AppSecCustomDefinedBot -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -BotID $NewCustomBot.botID -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecCustomDefinedBot updates correctly' {
        $SetCustomBot.botId | Should -Be $NewCustomBot.botID
    }

    ### Remove-AppSecCustomDefinedBot
    it 'Remove-AppSecCustomDefinedBot removes successfully' {
        { Remove-AppSecCustomDefinedBot -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -BotID $NewCustomBot.botID -EdgeRCFile $EdgeRCFile -Section $Section } | Should -Not -Throw
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

    ### Get-AppSecCustomBotCategorySequence
    $Script:CustomBotCategorySequence = Get-AppSecCustomBotCategorySequence -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecCustomBotCategorySequence returns the correct data' {
        $CustomBotCategorySequence.sequence | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecCustomBotCategorySequence
    $Script:SetCustomBotCategorySequence = ($CustomBotCategorySequence | Set-AppSecCustomBotCategorySequence -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecCustomBotCategorySequence updates correctly' {
        $CustomBotCategorySequence.sequence | Should -Not -BeNullOrEmpty
    }

    #------------------------------------------------#
    #                Custom Clients                  #
    #------------------------------------------------#

    ### New-AppSecCustomClient
    $Script:NewCustomClient = New-AppSecCustomClient -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -CustomClient $TestCustomClient -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-AppSecCustomClient returns the correct data' {
        $NewCustomClient.customClientName | Should -Be $TestCustomClientName
    }

    ### List-AppSecCustomClients
    $Script:CustomClients = List-AppSecCustomClients -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecCustomClients returns a list' {
        $CustomClients | Should -Not -BeNullOrEmpty
    }

    ### Get-AppSecCustomClient
    $Script:CustomClient = Get-AppSecCustomClient -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -CustomClientID $NewCustomClient.customClientId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecCustomClient returns the correct data' {
        $CustomClient.customClientId | Should -Be $NewCustomClient.customClientId
    }

    ### Set-AppSecCustomClient
    $Script:SetCustomClient = ($CustomClient | Set-AppSecCustomClient -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -CustomClientID $NewCustomClient.customClientId -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecCustomClient updates successfully' {
        $SetCustomClient.customClientId | Should -Be $NewCustomClient.customClientId
    }

    ### Remove-AppSecCustomClient
    it 'Remove-AppSecCustomClient removes successfully' {
        { Remove-AppSecCustomClient -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -CustomClientID $NewCustomClient.customClientId -EdgeRCFile $EdgeRCFile -Section $Section} | Should -Not -Throw
    }

    #------------------------------------------------#
    #             Client Side Security               #
    #------------------------------------------------#

    ### Get-AppSecClientSideSecurity
    $Script:ClientSideSecurity = Get-AppSecClientSideSecurity -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecClientSideSecurity returns the correct data' {
        $ClientSideSecurity.useSameSiteCookies | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecClientSideSecurity
    $Script:SetClientSideSecurity = ($ClientSideSecurity | Set-AppSecClientSideSecurity -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecClientSideSecurity updates correctly' {
        $SetClientSideSecurity.useSameSiteCookies | Should -Be $ClientSideSecurity.useSameSiteCookies
    }

    #------------------------------------------------#
    #        Bot Analytics Cookie Settings           #
    #------------------------------------------------#

    # ### Get-AppSecBotAnalyticsCookieSettings
    # $Script:BotAnalyticsCookieSettings = Get-AppSecBotAnalyticsCookieSettings -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    # it 'Get-AppSecBotAnalyticsCookieSettings returns the correct data' {
    #     $BotAnalyticsCookieSettings.enableBotSignal | Should -Not -BeNullOrEmpty
    # }

    # ### Set-AppSecBotAnalyticsCookieSettings
    # $Script:SetBotAnalyticsCookieSettings = ($BotAnalyticsCookieSettings | Set-AppSecBotAnalyticsCookieSettings -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section)
    # it 'Set-AppSecBotAnalyticsCookieSettings updates correctly' {
    #     $SetBotAnalyticsCookieSettings.enableBotSignal | Should -Be $BotAnalyticsCookieSettings.enableBotSignal
    # }

    #------------------------------------------------#
    #         Bot Analytics Cookie Values            #
    #------------------------------------------------#

    # ### Get-AppSecBotAnalyticsCookieValues
    # $Script:BotAnalyticsCookieValues = Get-AppSecBotAnalyticsCookieValues -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    # it 'Get-AppSecBotAnalyticsCookieValues returns the correct data' {
    #     $BotAnalyticsCookieValues.count | Should -Not -Be 0
    # }

    # ### Update-AppSecBotAnalyticsCookieValues
    # $Script:NewBotAnalyticsCookieValues = Update-AppSecBotAnalyticsCookieValues -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    # it 'Update-AppSecBotAnalyticsCookieValues returns the correct data' {
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

    ### List-AppSecBotDetections
    $Script:BotDetections = List-AppSecBotDetections -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecBotDetections returns a list' {
        $BotDetections.count | Should -Not -Be 0
    }

    ### Get-AppSecBotDetection
    $Script:BotDetection = Get-AppSecBotDetection -DetectionID $BotDetections[0].detectionId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecBotDetection returns the correct data' {
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

    ### List-AppSecBotEndpointCoverageReports
    $Script:BotEndpointCoverageReports = List-AppSecBotEndpointCoverageReports -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecBotEndpointCoverageReports returns the correct data' {
        $BotEndpointCoverageReports.validation | Should -Not -BeNullOrEmpty
    }

    ### Get-AppSecConfigBotEndpointCoverageReport
    $Script:BotEndpointCoverageReport = Get-AppSecConfigBotEndpointCoverageReport -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecConfigBotEndpointCoverageReport returns the correct data' {
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

    ### List-AppSecTransactionalEndpointProtections
    $Script:TransactionalEndpointProtections = List-AppSecTransactionalEndpointProtections -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecTransactionalEndpointProtections returns the correct data' {
        $TransactionalEndpointProtections.standardTelemetry | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecTransactionalEndpointProtections
    $Script:SetTransactionalEndpointProtections = ($TransactionalEndpointProtections |  Set-AppSecTransactionalEndpointProtections -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecTransactionalEndpointProtections updates correctly' {
        $SetTransactionalEndpointProtections.standardTelemetry | Should -Not -BeNullOrEmpty
    }

    #------------------------------------------------#
    #                Response Actions                #
    #------------------------------------------------#

    ### List-AppSecResponseActions
    $Script:ResponseActions = List-AppSecResponseActions -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecResponseActions returns the correct data' {
        $ResponseActions.count | Should -Not -BeNullOrEmpty
    }

    #------------------------------------------------#
    #          Challenge Interception Rules          #
    #------------------------------------------------#

    ### List-AppSecChallengeInterceptionRules
    $Script:ChallengeInterceptionRules = List-AppSecChallengeInterceptionRules -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecChallengeInterceptionRules returns the correct data' {
        $ChallengeInterceptionRules.interceptAllRequests | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecChallengeInterceptionRules
    $Script:SetChallengeInterceptionRules = ($ChallengeInterceptionRules | Set-AppSecChallengeInterceptionRules -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecChallengeInterceptionRules returns the correct data' {
        $SetChallengeInterceptionRules.interceptAllRequests | Should -Be $ChallengeInterceptionRules.interceptAllRequests
    }

    #------------------------------------------------#
    #              Custom Deny Actions               #
    #------------------------------------------------#

    ### New-AppSecPolicyTransactionalEndpoint
    $Script:NewCustomDenyAction = New-AppSecCustomDenyAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -Action $TestCustomDenyAction -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-AppSecPolicyTransactionalEndpoint returns the correct data' {
        $NewCustomDenyAction.actionId | Should -Not -BeNullOrEmpty
    }

    ### List-AppSecCustomDenyActions
    $Script:CustomDenyActions = List-AppSecCustomDenyActions -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecCustomDenyActions returns a list' {
        $CustomDenyActions.count | Should -Not -Be 0
    }

    ### Get-AppSecCustomDenyAction
    $Script:CustomDenyAction = Get-AppSecCustomDenyAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -ActionID $NewCustomDenyAction.actionId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecCustomDenyAction returns the correct data' {
        $CustomDenyAction.actionId | Should -Be $NewCustomDenyAction.actionId
    }

    ### Set-AppSecCustomDenyAction
    $Script:SetCustomDenyAction = ($CustomDenyAction | Set-AppSecCustomDenyAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -ActionID $CustomDenyAction.actionId -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecCustomDenyAction updates successfully' {
        $SetCustomDenyAction.actionId | Should -Be $CustomDenyAction.actionId
    }

    ### Remove-AppSecCustomDenyAction
    it 'Remove-AppSecCustomDenyAction removes successfully' {
        { Remove-AppSecCustomDenyAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -ActionID $CustomDenyAction.actionId -EdgeRCFile $EdgeRCFile -Section $Section} | Should -Not -Throw
    }

    #------------------------------------------------#
    #              Conditional Actions               #
    #------------------------------------------------#

    ### New-AppSecConditionalAction
    $Script:NewConditionalAction = New-AppSecConditionalAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -Action $TestConditionalAction -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-AppSecConditionalAction creates correctly' {
        $NewConditionalAction.actionId | Should -Not -BeNullOrEmpty
    }

    ### List-AppSecConditionalActions
    $Script:ConditionalActions = List-AppSecConditionalActions -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecConditionalActions returns a list' {
        $ConditionalActions.count | Should -Not -Be 0
    }

    ### Get-AppSecConditionalAction
    $Script:ConditionalAction = Get-AppSecConditionalAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -ActionID $NewConditionalAction.actionId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecConditionalAction returns the correct data' {
        $ConditionalAction.actionId | Should -Be $NewConditionalAction.actionId
    }

    ### Set-AppSecConditionalAction
    $Script:SetConditionalAction = ($ConditionalAction | Set-AppSecConditionalAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -ActionID $ConditionalAction.actionId -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecConditionalAction updates successfully' {
        $SetConditionalAction.actionId | Should -Be $ConditionalAction.actionId
    }

    ### Remove-AppSecConditionalAction
    it 'Remove-AppSecConditionalAction removes successfully' {
        { Remove-AppSecConditionalAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -ActionID $ConditionalAction.actionId -EdgeRCFile $EdgeRCFile -Section $Section} | Should -Not -Throw
    }

    #------------------------------------------------#
    #            Serve Alternate Actions             #
    #------------------------------------------------#

    ### New-AppSecServeAlternateAction
    $Script:NewServeAlternateAction = New-AppSecServeAlternateAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -Action $TestServeAlternateAction -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-AppSecServeAlternateAction creates correctly' {
        $NewServeAlternateAction.actionId | Should -Not -BeNullOrEmpty
    }

    ### List-AppSecServeAlternateActions
    $Script:ServeAlternateActions = List-AppSecServeAlternateActions -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecServeAlternateActions returns a list' {
        $ServeAlternateActions.count | Should -Not -Be 0
    }

    ### Get-AppSecServeAlternateAction
    $Script:ServeAlternateAction = Get-AppSecServeAlternateAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -ActionID $NewServeAlternateAction.actionId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecServeAlternateAction returns the correct data' {
        $ServeAlternateAction.actionId | Should -Be $NewServeAlternateAction.actionId
    }

    ### Set-AppSecServeAlternateAction
    $Script:SetServeAlternateAction = ($ServeAlternateAction | Set-AppSecServeAlternateAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -ActionID $ServeAlternateAction.actionId -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecServeAlternateAction updates successfully' {
        $SetServeAlternateAction.actionId | Should -Be $ServeAlternateAction.actionId
    }

    ### Remove-AppSecConditionalAction
    it 'Remove-AppSecConditionalAction removes successfully' {
        { Remove-AppSecServeAlternateAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -ActionID $ServeAlternateAction.actionId -EdgeRCFile $EdgeRCFile -Section $Section} | Should -Not -Throw
    }

    #------------------------------------------------#
    #               Challenge Actions                #
    #------------------------------------------------#

    ### New-AppSecChallengeAction
    $Script:NewChallengeAction = New-AppSecChallengeAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -Action $TestChallengeAction -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-AppSecChallengeAction creates correctly' {
        $NewChallengeAction.actionId | Should -Not -BeNullOrEmpty
    }

    ### List-AppSecChallengeActions
    $Script:ChallengeActions = List-AppSecChallengeActions -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecChallengeActions returns a list' {
        $ChallengeActions.count | Should -Not -Be 0
    }

    ### Get-AppSecChallengeAction
    $Script:ChallengeAction = Get-AppSecChallengeAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -ActionID $NewChallengeAction.actionId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecChallengeAction returns the correct data' {
        $ChallengeAction.actionId | Should -Be $NewChallengeAction.actionId
    }

    ### Set-AppSecChallengeAction
    $Script:SetChallengeAction = ($ChallengeAction | Set-AppSecChallengeAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -ActionID $ChallengeAction.actionId -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecChallengeAction updates successfully' {
        $SetChallengeAction.actionId | Should -Be $ChallengeAction.actionId
    }

    ### Remove-AppSecChallengeAction
    it 'Remove-AppSecChallengeAction removes successfully' {
        { Remove-AppSecChallengeAction -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -ActionID $ChallengeAction.actionId -EdgeRCFile $EdgeRCFile -Section $Section} | Should -Not -Throw
    }

    #------------------------------------------------#
    #                   Removals                     #
    #------------------------------------------------#

    ### Remove-AppSecCustomBotCategory
    it 'Remove-AppSecCustomBotCategory removes successfully' {
        { Remove-AppSecCustomBotCategory -ConfigID $TestConfigID -VersionNumber $TestConfigVersion -CategoryID $NewCustomBotCategory.categoryId -EdgeRCFile $EdgeRCFile -Section $Section } | Should -Not -Throw
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
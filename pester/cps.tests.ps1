Import-Module $PSScriptRoot\..\AkamaiPowershell.psm1 -DisableNameChecking -Force
# Setup shared variables
$Script:EdgeRCFile = $env:PesterEdgeRCFile
$Script:SafeEdgeRCFile = $env:PesterSafeEdgeRCFile
$Script:Section = 'default'
$Script:TestContract = '1-1NC95D'
$Script:TestEnrollmentID = 68669
$Script:NewEnrollmentBody = '{
    "adminContact": {
        "email": "r1d1@akamai.com",
        "firstName": "R1",
        "lastName": "D1",
        "phone": "617-555-0111"
    },
    "certificateType": "san",
    "changeManagement": true,
    "csr": {
        "c": "US",
        "cn": "akamaipowershell.test.akamai.com",
        "l": "Cambridge",
        "o": "Akamai",
        "ou": "WebEx",
        "sans": [
            "akamaipowershell.test.akamai.com"
        ],
        "st": "MA"
    },
    "enableMultiStackedCertificates": false,
    "networkConfiguration": {
        "quicEnabled": true,
        "secureNetwork": "standard-tls",
        "sniOnly": true,
        "geography": "core",
        "dnsNameSettings": {
            "cloneDnsNames": true
        }
    },
    "org": {
        "addressLineOne": "150 Broadway",
        "addressLineTwo": null,
        "city": "Cambridge",
        "country": "US",
        "name": "Akamai Technologies",
        "phone": "617-555-0111",
        "postalCode": "02142",
        "region": "MA"
    },
    "ra": "lets-encrypt",
    "signatureAlgorithm": "SHA-256",
    "techContact": {
        "email": "r2d2@akamai.com",
        "firstName": "R2",
        "lastName": "D2",
        "phone": "617-555-0111"
    },
    "validationType": "dv"
}'

Describe 'Safe CPS Tests' {

    BeforeDiscovery {
        ### New-CPSEnrollment
        $Script:NewEnrollmentCreation = New-CPSEnrollment -ContractId $TestContract -Body $NewEnrollmentBody -EdgeRCFile $EdgeRCFile -Section $Section
        it 'New-CPSEnrollment creates an enrollment' {
            $NewEnrollmentCreation.enrollment | Should -Not -BeNullOrEmpty
        }
        $NewEnrollmentID = $NewEnrollmentCreation.enrollment.replace("/cps/v2/enrollments/","")
        $Script:NewEnrollment = Get-CPSEnrollment -EnrollmentID $NewEnrollmentID -EdgeRCFile $EdgeRCFile -Section $Section
    }

    ### List-CPSEnrollments
    $Script:Enrollments = List-CPSEnrollments -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-CPSEnrollments returns a list' {
        $Enrollments.count | Should -Not -BeNullOrEmpty
    }

    ### Get-CPSEnrollment
    $Script:Enrollment = Get-CPSEnrollment -EnrollmentID $TestEnrollmentID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-CPSEnrollment returns a enrollment' {
        $Enrollment.id | Should -Be $TestEnrollmentID
    }

    ### Get-CPSCertificateHistory
    $Script:CertHistory = Get-CPSCertificateHistory -EnrollmentID $TestEnrollmentID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-CPSCertificateHistory returns history' {
        $CertHistory[0].deploymentStatus | Should -Not -BeNullOrEmpty
    }

    ### Get-CPSChangeHistory
    $Script:ChanegHistory = Get-CPSChangeHistory -EnrollmentID $TestEnrollmentID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-CPSChangeHistory returns history' {
        $ChanegHistory.count | Should -BeGreaterThan 0
    }

    ### List-CPSDeployments
    $Script:Deployments = List-CPSDeployments -EnrollmentID $TestEnrollmentID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-CPSDeployments returns deployments' {
        $Deployments.staging | Should -Not -BeNullOrEmpty
    }

    ### List-CPSProductionDeployments
    $Script:ProdDeployments = List-CPSProductionDeployments -EnrollmentID $TestEnrollmentID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-CPSProductionDeployments returns deployments' {
        $ProdDeployments | Should -Not -BeNullOrEmpty
    }

    ### List-CPSStagingDeployments
    $Script:StagingDeployments = List-CPSStagingDeployments -EnrollmentID $TestEnrollmentID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-CPSStagingDeployments returns deployments' {
        $StagingDeployments | Should -Not -BeNullOrEmpty
    }

    ### Set-CPSEnrollment
    $Script:SetDeployment = $NewEnrollment | Set-CPSEnrollment -EnrollmentID $NewEnrollmentID -AllowCancelPendingChanges -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-CPSEnrollment updates correctly' {
        $SetDeployment.enrollment | Should -Match $NewEnrollmentID
    }

    AfterAll {
        ### Remove-CPSEnrollment
        $Script:RemoveEnrollment = Remove-CPSEnrollment -EnrollmentID $NewEnrollment.id -AllowCancelPendingChanges -EdgeRCFile $EdgeRCFile -Section $Section
        it 'New-CPSEnrollment creates an enrollment' {
            $RemoveEnrollment.enrollment | Should -Be "/cps/v2/enrollments/$RemoveEnrollmentID"
        }
    }
    
}

Describe 'Unsafe CPS Tests' {
    ### Get-CPSDVHistory
    $Script:DVHistory = Get-CPSDVHistory -EnrollmentID $TestEnrollmentID -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Get-CPSDVHistory returns history' {
        $DVHistory.count | Should -BeGreaterThan 0
    }
    
}
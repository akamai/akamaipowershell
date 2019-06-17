Describe "Identity Management Tests" {
    # Setup shared variables
    $EdgeRC = $env:PesterEdgeRC
    $Section = "default"

    $GrantableRoles = List-IDMGrantableRoles -EdgeRCFile $EdgeRC -Section $Section
    $Groups = List-IDMGroups -EdgeRCFile $EdgeRC -Section $Section
    $Group = Get-IDMGroup -GroupID $Groups[0].groupId -EdgeRCFile $EdgeRC -Section $Section
    $Properties = List-IDMProperties -EdgeRCFile $EdgeRC -Section $Section
    $Property = Get-IDMProperty -PropertyID $Properties[0].propertyId -GroupID $Properties[0].groupId -EdgeRCFile $EdgeRC -Section $Section
    $Roles = List-IDMRoles -EdgeRCFile $EdgeRC -Section $Section
    $Role = Get-IDMRole -RoleID $Roles[0].roleId -EdgeRCFile $EdgeRC -Section $Section
    $Users = List-IDMUsers -GroupID $Group.groupId -EdgeRCFile $EdgeRC -Section $Section
    $User = Get-IDMUser -UIIdentityID $Users[0].uiIdentityId -EdgeRCFile $EdgeRC -Section $Section
    $PropertyResources = List-IDMPropertyResources -PropertyID $Property.propertyId -GroupID $Property.groupId -EdgeRCFile $EdgeRC -Section $Section
    $PropertyUsers = List-IDMUsersForProperty -PropertyID $Property.propertyId -EdgeRCFile $EdgeRC -Section $Section
    $IDMProfile = Get-IDMUserProfile -EdgeRCFile $EdgeRC -Section $Section

    it "List-IDMGrantableRoles lists grantable roles" {
        $GrantableRoles.count | Should -BeGreaterThan 0
    }

    it "List-IDMGroups should list groups" {
        $Groups.count | Should -BeGreaterThan 0
    }

    it "Get-IDMGroup should get a group" {
        $Group.groupId | Should -not -BeNullOrEmpty
    }

    it "List-IDMProperties should list properties" {
        $Properties.count | Should -BeGreaterThan 0
    }

    it "Get-IDMProperty should get a property" {
        $Property.propertyId | Should -not -BeNullOrEmpty
    }

    it "List-IDMRoles should list roles" {
        $Roles.count | Should -BeGreaterThan 0
    }

    it "Get-IDMRole should get a role" {
        $Role.roleId | Should -not -BeNullOrEmpty
    }

    it "List-IDMUsers should list users" {
        $Users.count | Should -BeGreaterThan 0
    }

    it "Get-IDMUSer should get a user" {
        $User.uiIdentityId | Should -not -BeNullOrEmpty
    }

    it "List-IDMPropertyResources should list resources" {
        $PropertyResources.count | Should -BeGreaterThan 0
    }

    it "List-IDMPropertyUsers should list property users" {
        $PropertyUsers.count | Should -BeGreaterThan 0
    }

    it "Get-IDMUserProfile should get the profile of the calling user" {
        $IDMProfile.uiIdentityId | Should -not -BeNullOrEmpty
    }
}
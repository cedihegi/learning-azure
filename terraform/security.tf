# File responsibility:
# Setting up groups and assigning users to groups

data "azuread_client_config" "current" {}

data "azuread_user" "cedihegi" {
    user_principal_name = "cedric.hegglin_noser.com#EXT#@cedihegi.onmicrosoft.com"
}

// Creating a group
resource "azuread_group" "global-owner-group" {
    display_name = "Global Subscription Owner"
    owners = [data.azuread_client_config.current.object_id]
    security_enabled = true
}

// example: an existing group
data "azuread_group" "data-consumers" {
    display_name = "data-consumers"
}


resource "azuread_group_member" "cedi-global-owner" {
    group_object_id = azuread_group.global-owner-group.object_id
    member_object_id = data.azuread_user.cedihegi.object_id
}

resource "azuread_group_member" "cedi-data-consumer" {
    group_object_id = data.azuread_group.data-consumers.object_id
    member_object_id = data.azuread_user.cedihegi.object_id
}

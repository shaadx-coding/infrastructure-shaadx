# Let's define here the different entities

resource "vault_identity_entity" "shaadx" {
  name = "shaadx"
  
  metadata = {
    full_name          = "Shaadx Shaadx"
    given_name         = "Shaadx"
    middle_name        = ""
    family_name        = "Shaadx Shaadx"
    preferred_username = "shaadx"
    
    email = "shaadx@protonmail.com"
    
    zoneinfo = "Europe/Paris"
    locale   = "en-US"
  }
}

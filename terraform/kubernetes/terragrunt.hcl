include "root" {
  path = find_in_parent_folders()
}

dependency "persistent" {
  config_path = "../persistent"
}

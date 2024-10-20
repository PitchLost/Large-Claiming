fx_version 'cerulean'
game 'gta5'

author 'Johno'
description 'Large Claiming Script'
repository 'None'
version '0.1'

resource_type 'gametype' { name = 'Freeroam' }

client_script {
     'client/*'
}

ui_page {
    'ui/claiming.html'
}

files {
    'ui/*'
}
server_script { 
    'server/*'
}
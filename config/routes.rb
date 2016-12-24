# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get 'qswebticket' => 'qswebticket#index'
get 'qswebticket/hub'
get 'qswebticket/qmc'
get 'qswebticket/users'      => "qsuserdata#users"
get 'qswebticket/attributes' => "qsuserdata#attributes"

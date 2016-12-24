require 'net/http'

class QsuserdataController < ActionController::Base

# unloadable 

  before_filter :check_enabled

  def users
    res = ActiveRecord::Base.connection.exec_query("SELECT distinct users.id as ID, users.login as userid, concat(users.lastname,', ',users.firstname) as name from users where status = 1 and type = 'User';")
    render json:res
  end

  def attributes
    res = ActiveRecord::Base.connection.exec_query("SELECT distinct users.id as ID, users.login as userid, 'email' as type, email_addresses.address as value, 'redmine' as 'group' from users, email_addresses where status = 1 and type = 'User' and users.id = email_addresses.user_id and email_addresses.is_default=1 union SELECT users.id as ID, users.login as userid, 'redmine_group' as type, grp.lastname as value, 'redmine' as `group` FROM `groups_users`, users, users grp WHERE `users`.`status`=1 AND `users`.`type` = 'USER' AND `users`.`id` = `groups_users`.`user_id` AND grp.id = groups_users.group_id union SELECT users.id as ID, users.login as userid, 'project_group_member' as type, concat(projects.identifier,';',roles.name) as value, 'redmine' as `group` FROM `members`, `users`, `projects`, `member_roles`, `roles` WHERE `users`.`status`=1 AND `users`.`type` = 'USER' AND `members`.`project_id` = `projects`.`id` AND `members`.`user_id` = `users`.`id` AND `members`.`id` = `member_roles`.`member_id` AND `roles`.`id` = `member_roles`.`role_id` ")
    render json:res
  end

  protected

  def check_enabled
    logger.error("check enabled of userdatacontroller")
    User.current = nil

    api_key = Setting.plugin_redmine_qswebticket['qswebticket_apikey']

    unless !api_key.blank? && params[:key].to_s == api_key
      render :text => 'Access denied. Userdata fetch is disabled or key is invalid.', :status => 403
      return false
    end
  end
end

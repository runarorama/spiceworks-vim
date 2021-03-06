function! SavePlugin()
ruby << EOF
require 'uri'
require 'net/http'
require 'yaml'

# Change these to your environments
Config = {'environments' => 
                  [ {'title'=>'Production',
                      'user'=>'yourusername', 
                      'pass'=>'yourpassword', 
                      'url'=>'http://production_server'}]}

begin
  # Get the contents of the file and parse out the GUID
  content = nil

  File.open($curbuf.name) do |f|
    content = f.read
  end

  #### PARAMETERS #####
  # parse the parameters
  guid = content[/\@guid\s+([\w\d-]+)$/, 1]
  env = content[/\@env\s+([\w\d-]+)$/, 1]
  name = content[/\@name\s+(.+)$/, 1]
  description = content[/\@description\s+(.+)$/, 1]
  version = content[/\@version\s+(.+)$/, 1]

  items = Config['environments']
  deploy_to = items.select {|i| i['title'] == env}[0]
  
  if !deploy_to.nil?  
    url = URI.parse(deploy_to['url'])
    user = deploy_to['user']
    password = deploy_to['pass']
    
    ##### PERFORM THE REQUESTS TO SAVE #####
    save_res = nil

    Net::HTTP.new(url.host, url.port).start do |http|
      login_page_get = Net::HTTP::Get.new('/login')
      login_page_res = http.request(login_page_get)
      md = login_page_res.body.match(/input.*name=.*authenticity_token.*value=[\'\"]([^\'\"]+)[\'\"]/)

      auth_token = md[1]

      # Post to log the user in.
      login_post = Net::HTTP::Post.new('/account/login')
      login_post.set_form_data( {'user[password]'=>password, 'user[email]'=>user, 'authenticity_token'=>auth_token} )
      login_post['Cookie'] = login_page_res['Set-Cookie']
      login_res = http.request(login_post)

      if login_res.is_a?(Net::HTTPSuccess)
        puts "Unauthorized user, please check your login and password."
        break
      end

      # put the new file up on the server
      save_put = Net::HTTP::Put.new("/settings/plugins/#{guid}")
      save_put.set_form_data({'plugin[content]'=>content, 'authenticity_token'=>auth_token})
      save_put['Cookie'] = login_res['Set-Cookie']
      save_put['Accept'] = '*/*'
      save_res = http.request(save_put)

      case save_res
      when Net::HTTPSuccess
        puts "Published Plugin #{name} to #{deploy_to['title']}"
      when Net::HTTPRedirection
        puts "redirected? #{save_res.header['location']}"
      when Net::HTTPNotAcceptable
        # put the new file up on the server
        create_post = Net::HTTP::Post.new("/settings/plugins/import")
        create_post.set_form_data({'authenticity_token'=>auth_token, 'data'=>{:guid=>guid, :name=>name, :description=>description, :version=>version, :content=>content}.to_yaml})
        create_post['Cookie'] = login_res['Set-Cookie']
        create_post['Accept'] = 'text/javascript'
        create_res = http.request(create_post)

        case create_res
        when Net::HTTPRedirection
          http.get("/settings/plugins/#{guid}/edit?make_local=true")
          puts "Imported Plugin #{name} to #{deploy_to['title']}"
        end

      else
        puts "There was a problem saving to #{deploy_to['title']}: #{save_res.inspect}"
      end
    end
  end
rescue Errno::ECONNREFUSED => e
  puts "Connection Refused: Most likely, your server is not running or you have the wrong server address or port."
rescue
  puts "#{$!.message}"
end
EOF
endfunction

au BufRead,BufNewFile *.swjs  set filetype=javascript
au BufWritePost *.swjs  call SavePlugin()


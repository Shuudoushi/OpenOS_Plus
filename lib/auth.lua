--Some of this was made with the help of SuPeRMiNoR2

local sha = require("sha256")

local auth = {}

passwdfile = "/etc/passwd"

local function split(str,sep)
    local array = {}
    local reg = string.format("([^%s]+)",sep)
    for mem in string.gmatch(str,reg) do
        table.insert(array, mem)
    end
    return array
end

local function buildDB()
    users = {}
    u = io.open(passwdfile, "r")
    raw = u:read(1000)
    
    if raw ~= nil then
    
    temp = split(raw, "\n")
    
    for _,data in pairs(temp) do
      t = split(data, ":")
      users[t[1]] = {password=t[2], su=t[3]}
    end

    end
    
    return users  
end

local function saveDB(db)
  buff = ""
  for u, d in pairs(db) do
    buff = buff .. u .. ":" .. d["password"].. ":" .. d["su"] .. "\n"
  end
  f = io.open(passwdfile, "w")
  f:write(buff)
  f:close()
end

function auth.addUser(username, password, su)
  users = buildDB()
  if su == true then sub = "1" end 
  if su == false then sub = "0" end

  users[username] = {password=sha.sha256(password), su=sub}
  saveDB(users)
end

function auth.rmUser(username)
  users = buildDB()
  for user,_ in pairs(users) do
    if user == username then
      users[username] = nil
    end
  end
  saveDB(users)
end

function auth.validate(username, password) 
  users = buildDB()
  
  validated = false
  superuser = false

  for user,data in pairs(users) do
    if user == username and data["password"] == sha.sha256(password) then
      validated = true
    end
    if data["su"] == "1" then
      superuser = true
    end
  end
  return validated, superuser
end

return auth